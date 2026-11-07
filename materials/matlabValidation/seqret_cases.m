function files = seqret_cases(outDir)
% Test sequences for the parts of MATLAB Pulseq that PyPulseq does not have, or does differently.
% Each is written to outDir/<name>.seq; the list of files is returned.
sys = mr.opts('MaxGrad', 40, 'GradUnit', 'mT/m', 'MaxSlew', 150, 'SlewUnit', 'T/m/s', ...
    'rfRingdownTime', 20e-6, 'rfDeadTime', 100e-6, 'adcDeadTime', 10e-6, 'B0', 3);
files = {};
files{end+1} = case_labels(sys, outDir);
files{end+1} = case_arb_corners(sys, outDir);
files{end+1} = case_features(sys, outDir);
files{end+1} = case_crossblock(sys, outDir);
end

%% labels: LABELSET and LABELINC in the same block, in both orders
function f = case_labels(sys, d)
seq = mr.Sequence(sys);
adc = mr.makeAdc(16, 'Dwell', 10e-6, 'system', sys);
seq.addBlock(adc, mr.makeLabel('INC', 'LIN', 1), mr.makeLabel('SET', 'LIN', 5));   % spec: 5 + 1 = 6
seq.addBlock(adc, mr.makeLabel('SET', 'LIN', 5), mr.makeLabel('INC', 'LIN', 1));   % spec: 6
seq.addBlock(adc, mr.makeLabel('INC', 'LIN', 2));                                  % 8
seq.addBlock(adc, mr.makeLabel('SET', 'SLC', 3), mr.makeLabel('INC', 'SLC', -1), mr.makeLabel('SET', 'NAV', 1)); % SLC 2, NAV 1
seq.addBlock(adc, mr.makeLabel('INC', 'SLC', 4), mr.makeLabel('SET', 'SLC', 0), mr.makeLabel('SET', 'NAV', 0));  % SLC 4, NAV 0
seq.addBlock(mr.makeLabel('SET', 'REP', 1), mr.makeLabel('INC', 'REP', 1));        % label-only block: REP 2
seq.addBlock(adc);
seq.setDefinition('Name', 'labels');
f = fullfile(d, 'labels.seq'); seq.write(f);
end

%% arbitrary gradients sampled at the raster centres, with corners on the raster edges
function f = case_arb_corners(sys, d)
seq = mr.Sequence(sys); dt = sys.gradRasterTime; g = sys.gamma;
rf = mr.makeBlockPulse(pi/2, 'Duration', 0.2e-3, 'system', sys, 'use', 'excitation');
% (a) a trapezoid given as samples: 30 mT/m, 300 us ramps, 300 us plateau
A = 30e-3*g; nr = 30; nf = 30; n = 2*nr + nf; t = ((1:n) - 0.5)*dt;
w = A*min([t/(nr*dt); ones(size(t)); (n*dt - t)/(nr*dt)]);
ga = mr.makeArbitraryGrad('x', w, 'first', 0, 'last', 0, 'system', sys);
% (b) a smooth shape (control: no corners)
n2 = 80; t2 = ((1:n2) - 0.5)*dt; gb = mr.makeArbitraryGrad('y', 0.5*A*sin(pi*t2/(n2*dt)), 'first', 0, 'last', 0, 'system', sys);
% (c) a free waveform built from straight pieces (corners at 7 places), on z
v = [0 20 20 -25 -25 10 10 0]*1e-3*g; tv = [0 20 40 75 100 125 140 160]*dt;
tc = ((1:round(tv(end)/dt)) - 0.5)*dt; wc = interp1(tv, v, tc);
gc = mr.makeArbitraryGrad('z', wc, 'first', 0, 'last', 0, 'system', sys);
% (d) a trapezoid (x) plus an arbitrary gradient (x) in one block: mr.addGradients
tr = mr.makeTrapezoid('x', 'Amplitude', 15e-3*g, 'RiseTime', 200e-6, 'FlatTime', 400e-6, 'system', sys);
n4 = 60; t4 = ((1:n4) - 0.5)*dt; arb = mr.makeArbitraryGrad('x', 10e-3*g*sin(pi*t4/(n4*dt)).^2, 'first', 0, 'last', 0, 'system', sys);
gd = mr.addGradients({tr, arb}, sys);
% (e) the same free waveform with oversampling (time_id -1)
tco = (1:(2*round(tv(end)/dt) - 1))*dt/2; wco = interp1(tv, v, tco);
ge = mr.makeArbitraryGrad('y', wco, 'first', 0, 'last', 0, 'oversampling', true, 'system', sys);
% readout to see k
adc = mr.makeAdc(64, 'Dwell', 10e-6, 'system', sys);
gro = mr.makeTrapezoid('x', 'Amplitude', 10e-3*g, 'FlatTime', 64*10e-6, 'system', sys); adc.delay = gro.riseTime;
for blk = {{ga, gb, gc}, {gd}, {ge}}
    seq.addBlock(rf);
    seq.addBlock(blk{1}{:});
    seq.addBlock(gro, adc);
    seq.addBlock(mr.makeDelay(2e-3));
end
seq.setDefinition('Name', 'arb_corners');
f = fullfile(d, 'arb_corners.seq'); seq.write(f);
end

%% Pulseq 1.5 / 1.5.1 features that PyPulseq does not read: rotations, RF shims, soft delays, custom labels,
%% ADC phase modulation, flags, triggers, RF purposes and ppm offsets
function f = case_features(sys, d)
seq = mr.Sequence(sys); g = sys.gamma;
rf = mr.makeBlockPulse(pi/2, 'Duration', 0.2e-3, 'system', sys, 'use', 'excitation');
fs = mr.makeGaussPulse(110*pi/180, 'system', sys, 'Duration', 8e-3, 'freqPPM', -3.35, 'phasePPM', 0.0841, 'use', 'saturation');
inv = mr.makeBlockPulse(pi, 'Duration', 0.5e-3, 'system', sys, 'use', 'inversion');
n = 64;
adc = mr.makeAdc(n, 'Dwell', 10e-6, 'system', sys, 'phaseModulation', linspace(0, pi, n)', 'freqPPM', 1.2, 'phasePPM', 0.3);
gro = mr.makeTrapezoid('x', 'Amplitude', 10e-3*g, 'FlatTime', n*10e-6, 'system', sys); adc.delay = gro.riseTime;
gpre = mr.makeTrapezoid('x', 'Area', -gro.area/2, 'system', sys);
mr.addCustomLabel('MYLBL');
sd = mr.makeSoftDelay(0, 'TE', 'offset', -1e-3, 'factor', 2);
sd2 = mr.makeSoftDelay(1, 'TR', 'offset', -2e-3, 'factor', 1);
rot = mr.makeRotation([1 1 1], pi/5);
shim = mr.makeRfShim([1; 0.7*exp(1i*pi/2)]);
trig = mr.makeTrigger('physio1', 'duration', 2e-3);
out = mr.makeDigitalOutputPulse('osc0', 'duration', 100e-6);
dt = sys.gradRasterTime; n2 = 60; t2 = ((1:n2) - 0.5)*dt;
garb = mr.makeArbitraryGrad('y', 20e-3*g*min([t2/(20*dt); ones(size(t2)); (n2*dt - t2)/(20*dt)]), 'first', 0, 'last', 0, 'system', sys);
seq.addBlock(trig);
seq.addBlock(inv);
seq.addBlock(mr.makeDelay(5e-3));
for rep = 1:2
    seq.addBlock(fs, mr.makeLabel('SET', 'TRID', rep));
    seq.addBlock(rf, shim, out, mr.makeLabel('SET', 'MYLBL', rep), mr.makeLabel('SET', 'OFF', rep == 1));
    seq.addBlock(gpre, garb, rot);
    seq.addBlock(mr.makeDelay(3e-3), sd);
    seq.addBlock(gro, adc, rot, mr.makeLabel('SET', 'ONCE', 1));
    seq.addBlock(gro, adc, mr.makeLabel('INC', 'MYLBL', 1), mr.makeLabel('SET', 'ONCE', 0));
    seq.addBlock(mr.makeDelay(5e-3), sd2);
end
seq.setDefinition('Name', 'features');
f = fullfile(d, 'features.seq'); seq.write(f);
end

%% an arbitrary gradient that continues from one block into the next (spiral-like), without time shapes,
%% to test how a v1.4.1 file (which has no first/last fields) is read
function f = case_crossblock(sys, d)
seq = mr.Sequence(sys); dt = sys.gradRasterTime; g = sys.gamma;
rf = mr.makeBlockPulse(pi/2, 'Duration', 0.2e-3, 'system', sys, 'use', 'excitation');
A = 20e-3*g; n = 60; t = ((1:2*n) - 0.5)*dt; s = @(x) A*sin(pi*x/(2*n*dt)).^2 .* (1 + 0.3*sin(7*pi*x/(2*n*dt)));
w = s(t); mid = s(n*dt);
g1 = mr.makeArbitraryGrad('x', w(1:n), 'first', 0, 'last', mid, 'system', sys);
g2 = mr.makeArbitraryGrad('x', w(n+1:end), 'first', mid, 'last', 0, 'system', sys);
h1 = mr.makeArbitraryGrad('y', 0.5*w(1:n), 'first', 0, 'last', 0.5*mid, 'system', sys);
h2 = mr.makeArbitraryGrad('y', 0.5*w(n+1:end), 'first', 0.5*mid, 'last', 0, 'system', sys);
adc = mr.makeAdc(n, 'Dwell', 9e-6, 'system', sys);
seq.addBlock(rf); seq.addBlock(g1, h1, adc); seq.addBlock(g2, h2, adc); seq.addBlock(mr.makeDelay(1e-3));
seq.setDefinition('Name', 'crossblock');
f = fullfile(d, 'crossblock.seq'); seq.write(f);
end
