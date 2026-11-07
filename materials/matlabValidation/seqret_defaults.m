function cfg = seqret_defaults(cfg)
% default settings of the Seqret reference tests (see seqret_run_all.m)
d = struct('maxBlocks', 2000, 'maxPoints', 100000, 'v141', 'cases');
f = fieldnames(d);
for i = 1:numel(f)
    if ~isfield(cfg, f{i}) || isempty(cfg.(f{i})), cfg.(f{i}) = d.(f{i}); end
end
end
