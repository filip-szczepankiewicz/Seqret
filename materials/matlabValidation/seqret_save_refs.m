function [M, ok] = seqret_save_refs(seq, caseDir, prefix, cfg, M)
% Saves what MATLAB Pulseq computes from a sequence (all in SI units, raw little-endian float64,
% column-major; the size of each array is in manifest.json under arrays.<prefix><name>):
%   blockdur     block durations (s), all blocks
%   g1, g2, g3   gradient waveforms x, y, z as [t; g] (s; Hz/m), waveforms_and_times, physical axes
%   rf           RF as [t; real; imag] (s; Hz), including frequency and phase offsets (appendRF)
%   texc, tref   excitation and refocusing [t; freq; phase] (waveforms_and_times)
%   fpadc        ADC [freq; phase] per sample (Hz; rad), including ppm parts and phase modulation
%   pmadc        ADC phase modulation per sample (rad), only if there is any
%   kadc         [t; kx; ky; kz] at every ADC sample (s; 1/m), calculateKspacePP
%   lbl_<NAME>   label values at each ADC (evalLabels 'evolution','adc', i.e. in extension-chain order)
% Everything except blockdur covers the first n blocks (manifest: <prefix>refBlocks): at most cfg.maxBlocks,
% and fewer if needed to keep the gradient, RF and ADC samples in them within cfg.maxPoints, so that each
% sequence gives a few MB at most.
ok = true;
nb = numel(seq.blockDurations);
n = seqret_ref_blocks(seq, cfg);
M.([prefix 'blocks']) = nb; M.([prefix 'refBlocks']) = n; M.([prefix 'duration']) = sum(seq.blockDurations);
% older keys, read by compare_matlab.mjs
M.([prefix 'waveBlocks']) = n; M.([prefix 'rfBlocks']) = n; M.([prefix 'kBlocks']) = n; M.([prefix 'lblBlocks']) = n;
try M.([prefix 'B0']) = seq.sys.B0; M.([prefix 'gamma']) = seq.sys.gamma; catch, end
M = put(M, caseDir, prefix, 'blockdur', seq.blockDurations(:)');
try
    [w, tfe, tfr, ~, fp, pm] = seq.waveforms_and_times(true, [1 n]);
    for j = 1:3
        if numel(w) >= j && ~isempty(w{j}), M = put(M, caseDir, prefix, sprintf('g%d', j), w{j}); end
    end
    if numel(w) >= 4 && ~isempty(w{4}), r = w{4}; M = put(M, caseDir, prefix, 'rf', [real(r(1,:)); real(r(2,:)); imag(r(2,:))]); end
    M = put(M, caseDir, prefix, 'texc', tfe); M = put(M, caseDir, prefix, 'tref', tfr);
    if size(fp, 1) == 2
        M = put(M, caseDir, prefix, 'fpadc', fp);
    elseif ~isempty(fp) % MATLAB Pulseq adds the (column) phase modulation to the (row) sample times and gets a matrix
        M.errors{end+1} = sprintf('%sfpadc: waveforms_and_times returned %d x %d instead of 2 x N (ADC phase modulation); not saved', prefix, size(fp, 1), size(fp, 2));
    end
    if any(pm(:)), M = put(M, caseDir, prefix, 'pmadc', pm); end
catch e
    M.errors{end+1} = [prefix 'waveforms: ' seqret_errtext(e)]; ok = false;
end
try
    [ka, ta] = seq.calculateKspacePP('blockRange', [1 n]);
    M = put(M, caseDir, prefix, 'kadc', [ta(:)'; ka]);
catch e
    M.errors{end+1} = [prefix 'kspace: ' seqret_errtext(e)]; ok = false;
end
try
    L = seq.evalLabels('blockRange', [1 n], 'evolution', 'adc');
    f = fieldnames(L);
    for i = 1:numel(f), M = put(M, caseDir, prefix, ['lbl_' f{i}], double(L.(f{i}))); end
catch e
    M.errors{end+1} = [prefix 'labels: ' seqret_errtext(e)];
end
try
    sd = seq.getDefaultSoftDelayValues();
    if ~isempty(fieldnames(sd)), M.([prefix 'softDelays']) = sd; end
catch
end
end

function n = seqret_ref_blocks(seq, cfg)
% the first n blocks (n <= cfg.maxBlocks) whose gradient, RF and ADC samples add up to at most cfg.maxPoints
nb = numel(seq.blockDurations); nMax = min(nb, cfg.maxBlocks);
try
    pts = 0; n = 0;
    for i = 1:nMax
        e = seq.blockEvents{i}; p = 0; % e = [delay rf gx gy gz adc ext]
        if e(2), p = p + seq.shapeLibrary.data(seq.rfLibrary.data(e(2)).array(2)).array(1); end
        for a = 3:5
            if e(a)
                if seq.gradLibrary.type(e(a)) == 't', p = p + 4;
                else, p = p + seq.shapeLibrary.data(seq.gradLibrary.data(e(a)).array(4)).array(1); end
            end
        end
        if e(6), p = p + 2*seq.adcLibrary.data(e(6)).array(1); end % k-space and ADC phase
        if pts + p > cfg.maxPoints && n > 0, break; end
        pts = pts + p; n = i;
    end
catch
    n = min(nMax, 200); % library layout not as expected (older Pulseq): a short stretch
end
n = max(n, 1);
end

function M = put(M, d, prefix, name, A)
A = double(A);
fid = fopen(fullfile(d, [prefix name '.f64']), 'w', 'ieee-le');
fwrite(fid, A, 'double'); fclose(fid);
M.arrays.([prefix name]) = size(A);
end
