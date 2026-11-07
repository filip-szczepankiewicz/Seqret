function s = seqret_errtext(e)
s = e.message;
if ~isempty(e.stack), s = sprintf('%s (%s, line %d)', s, e.stack(1).name, e.stack(1).line); end
end
