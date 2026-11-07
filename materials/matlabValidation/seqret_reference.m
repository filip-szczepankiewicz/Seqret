function seqret_reference(seqFile, caseDir, source, cfg, logf)
% MATLAB Pulseq's reading of seqFile, saved for Seqret's tests:
%   caseDir/<name>.seq        copy of the file
%   caseDir/<name>.bin        the same sequence as a Pulseq binary file (seq.writeBinary)
%   caseDir/<name>_v141.seq   the same sequence in the v1.4.1 text format (seq.write_v141), if asked (cfg.v141)
%   caseDir/ref_*.f64         what MATLAB computes from <name>.seq (see seqret_save_refs)
%   caseDir/v141_*.f64        what MATLAB computes from <name>_v141.seq (read with 'detectRFuse')
%   caseDir/manifest.json     sizes of all arrays, versions, errors
[~, name] = fileparts(seqFile);
if ~exist(caseDir, 'dir'), mkdir(caseDir); end
t0 = tic;
cfg = seqret_defaults(cfg);
M = struct('name', name, 'source', source, 'file', [name '.seq'], 'errors', {{}});
M.arrays = struct();
dst = fullfile(caseDir, [name '.seq']);
if ~strcmp(seqFile, dst), copyfile(seqFile, dst); end

% reference from the text file
try
    seq = mr.Sequence(); seq.read(dst);
    [M, ok] = seqret_save_refs(seq, caseDir, 'ref_', cfg, M); %#ok<ASGLU>
catch e
    M.errors{end+1} = ['read: ' seqret_errtext(e)]; seq = [];
end

% binary file
if ~isempty(seq)
    try
        seq.writeBinary(fullfile(caseDir, [name '.bin']));
        M.bin = [name '.bin'];
        seqB = mr.Sequence(); seqB.readBinary(fullfile(caseDir, [name '.bin']));
        M.binBlocks = numel(seqB.blockDurations); M.binDuration = sum(seqB.blockDurations);
    catch e
        M.errors{end+1} = ['binary: ' seqret_errtext(e)];
    end
end

% v1.4.1 text file, and MATLAB's reading of it
if ~isempty(seq)
    try
        hasRot = false; try hasRot = ~isempty(seq.rotationLibrary.keys); catch, end
        if strcmp(cfg.v141, 'none') || (strcmp(cfg.v141, 'cases') && ~strcmp(source, 'case'))
            M.v141 = ''; % not asked for
        elseif hasRot
            M.v141 = 'skipped: the sequence uses the rotation extension';
        else
            f141 = fullfile(caseDir, [name '_v141.seq']);
            seq.write_v141(f141);
            % files < 1.5 do not state what an RF pulse is for: without 'detectRFuse' MATLAB treats every
            % pulse as an excitation; with it, as Seqret, pulses above 90 degrees as refocusing
            seqV = mr.Sequence(); seqV.read(f141, 'detectRFuse');
            M.v141 = [name '_v141.seq'];
            M = seqret_save_refs(seqV, caseDir, 'v141_', cfg, M);
        end
    catch e
        M.errors{end+1} = ['v141: ' seqret_errtext(e)];
    end
end
M.seconds = toc(t0);
seqret_writejson(fullfile(caseDir, 'manifest.json'), M);
if isempty(M.errors)
    logf('%s: ok (%.1f s)', name, M.seconds);
else
    logf('%s: %d problem(s) (%.1f s): %s', name, numel(M.errors), M.seconds, strjoin(M.errors, ' | '));
end
end
