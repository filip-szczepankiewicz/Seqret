function seqret_tests_main(cfg)
% Runs all Seqret reference tests (see seqret_run_all.m).
if ~isempty(cfg.pulseqPath), addpath(cfg.pulseqPath); end
cfg = seqret_defaults(cfg);
if isempty(which('mr.Sequence'))
    error('MATLAB Pulseq is not on the path. Set pulseqPath in seqret_run_all.m.');
end
here = fileparts(mfilename('fullpath'));
if ~exist(cfg.outDir, 'dir'), mkdir(cfg.outDir); end
logFile = fullfile(cfg.outDir, 'log.txt');
fidLog = fopen(logFile, 'w'); cleanLog = onCleanup(@() fclose(fidLog));
logf = @(varargin) seqret_log(fidLog, varargin{:});

% environment
env = struct();
env.matlab = version; env.isOctave = exist('OCTAVE_VERSION', 'builtin') > 0;
env.pulseqDir = fileparts(fileparts(fileparts(which('mr.Sequence')))); % .../matlab
try [a, b, c] = mr.aux.version('pulseq'); env.pulseqVersion = [a b c]; catch, env.pulseqVersion = []; end
try [a, b, c] = mr.aux.version('output'); env.outputVersion = [a b c]; catch, env.outputVersion = []; end
env.pulseqGit = '';
try
    [st, h] = system(sprintf('git -C "%s" rev-parse --short HEAD', env.pulseqDir));
    if st == 0, env.pulseqGit = strtrim(h); end
catch
end
env.date = datestr(now, 31);
seqret_writejson(fullfile(cfg.outDir, 'environment.json'), env);
logf('MATLAB %s, Pulseq %s (git %s) in %s', env.matlab, mat2str(env.pulseqVersion), env.pulseqGit, env.pulseqDir);

oldVis = get(0, 'DefaultFigureVisible'); set(0, 'DefaultFigureVisible', 'off');
restoreVis = onCleanup(@() set(0, 'DefaultFigureVisible', oldVis));
oldWarn = warning; warning('off', 'all'); restoreWarn = onCleanup(@() warning(oldWarn));
tAll = tic;

% 1. Seqret's own test sequences
if cfg.runCases
    caseDir = fullfile(cfg.outDir, 'cases_work'); if ~exist(caseDir, 'dir'), mkdir(caseDir); end
    try
        files = seqret_cases(caseDir);
        for i = 1:numel(files)
            [~, nm] = fileparts(files{i});
            seqret_reference(files{i}, fullfile(cfg.outDir, ['case_' nm]), 'case', cfg, logf);
        end
    catch e
        logf('ERROR building the test cases: %s', seqret_errtext(e));
    end
    try rmdir(caseDir, 's'); catch, end
end

% 2. Pulseq's demo sequences
if cfg.runDemos
    demoDir = fullfile(env.pulseqDir, 'demoSeq');
    if isempty(cfg.demoList)
        d = dir(fullfile(demoDir, 'write*.m')); names = {d.name};
    else
        names = cellfun(@(s) [regexprep(s, '\.m$', '') '.m'], cfg.demoList, 'UniformOutput', false);
    end
    for i = 1:numel(names)
        [~, dn] = fileparts(names{i});
        work = fullfile(cfg.outDir, ['demo_' dn], 'work');
        if ~exist(work, 'dir'), mkdir(work); end
        t0 = tic;
        try
            [produced, derr] = seqret_run_demo(fullfile(demoDir, names{i}), work);
        catch e
            produced = {}; derr = seqret_errtext(e);
        end
        close all force;
        if isempty(derr), derr = 'the demo ended without an error (some demos stop when Python/sigpy is missing)'; end
        if isempty(produced)
            logf('demo %s: no .seq file written (%.1f s): %s', dn, toc(t0), derr);
            try rmdir(fileparts(work), 's'); catch, end
            continue;
        end
        for j = 1:numel(produced)
            [~, sn] = fileparts(produced{j});
            tag = ['demo_' dn]; if numel(produced) > 1, tag = [tag '__' sn]; end
            seqret_reference(produced{j}, fullfile(cfg.outDir, tag), 'demo', cfg, logf);
        end
        try rmdir(work, 's'); catch, end % the demo's own files (the .seq file has been copied)
        logf('demo %s: done (%.1f s)', dn, toc(t0));
    end
end

% 3. your own sequences
if ~isempty(cfg.mySeqDir) && exist(cfg.mySeqDir, 'dir')
    d = dir(fullfile(cfg.mySeqDir, '*.seq'));
    for i = 1:numel(d)
        [~, nm] = fileparts(d(i).name);
        seqret_reference(fullfile(cfg.mySeqDir, d(i).name), fullfile(cfg.outDir, ['user_' nm]), 'user', cfg, logf);
    end
end
bytes = seqret_dirbytes(cfg.outDir);
logf('all done in %.1f s. Output: %s (%.0f MB)', toc(tAll), cfg.outDir, bytes/1e6);
end

function b = seqret_dirbytes(d)
b = 0; L = dir(d);
for i = 1:numel(L)
    if L(i).isdir
        if ~any(strcmp(L(i).name, {'.', '..'})), b = b + seqret_dirbytes(fullfile(d, L(i).name)); end
    else
        b = b + L(i).bytes;
    end
end
end

function seqret_log(fid, varargin)
s = sprintf(varargin{:}); fprintf('%s\n', s); fprintf(fid, '%s\n', s);
end
