function [seqret__produced, seqret__err] = seqret_run_demo(seqret__script, seqret__work)
% Runs a copy of one Pulseq demo script in the folder seqret__work and returns the .seq files it wrote (the
% demo folder itself is not touched: run() changes to the folder of the script it runs). The demo runs inside
% this function, so its variables stay here, and its output to the command window is suppressed. Errors
% after the .seq file was written (plots, test reports) are ignored.
[seqret__src, seqret__nm, seqret__ext] = fileparts(seqret__script);
copyfile(seqret__script, fullfile(seqret__work, [seqret__nm seqret__ext]));
setappdata(0, 'seqret_demo_back', cd(seqret__work));
setappdata(0, 'seqret_demo_path', seqret__src); addpath(seqret__src, '-end'); % for helper files next to the demo
seqret__before = dir('*.seq'); setappdata(0, 'seqret_demo_before', {seqret__before.name});
setappdata(0, 'seqret_demo_work', seqret__work);
setappdata(0, 'seqret_demo_err', '');
try
    evalc('run(fullfile(seqret__work, [seqret__nm seqret__ext]))');
catch seqret__e
    setappdata(0, 'seqret_demo_err', seqret_errtext(seqret__e)); % keep whatever was written before the error
end
seqret__err = getappdata(0, 'seqret_demo_err');
seqret__work = getappdata(0, 'seqret_demo_work'); cd(seqret__work);
rmpath(getappdata(0, 'seqret_demo_path'));
seqret__after = dir('*.seq'); seqret__after = {seqret__after.name};
seqret__new = setdiff(seqret__after, getappdata(0, 'seqret_demo_before'));
seqret__produced = cellfun(@(f) fullfile(seqret__work, f), seqret__new, 'UniformOutput', false);
cd(getappdata(0, 'seqret_demo_back'));
end
