%% Seqret reference tests: MATLAB Pulseq as the reference for Seqret's parser and waveforms
%
% Run this script in MATLAB from this folder. It writes test sequences with MATLAB Pulseq, lets MATLAB
% Pulseq read them back, and saves what MATLAB computes from them (gradient and RF waveforms, k-space at
% the ADC samples, labels, soft delays, ...) as plain binary files in .\out. Seqret's Node test
% (tests/compare_matlab.mjs) loads the same files with Seqret's parser and compares.
%
% Each sequence is also written as a Pulseq binary file (.bin, seq.writeBinary) and, for Seqret's own test
% cases, in the v1.4.1 text format (seq.write_v141), for which MATLAB's reading of that file is the reference.
%
% With the settings below the output is about 30 MB and the run takes a few minutes.
% Requirements: MATLAB Pulseq, current master (v1.5.2 or later), on the path or set in pulseqPath below.
% Nothing is sent anywhere; all output stays in the out folder.

%% settings
pulseqPath = '';     % folder that contains +mr, e.g. 'C:\code\pulseq\matlab'; empty if Pulseq is on the path
runCases   = true;   % Seqret's own test sequences (seqret_cases.m), small
runDemos   = true;   % demo sequences that come with Pulseq (matlab/demoSeq), the ones in demoList
demoList   = { ...   % one demo per feature; {} runs all of them (several hundred MB with v141 = 'all')
    'writeGradientEcho', ...                % gradient echo, automatic labels
    'writeEpiRS_label_softdelay', ...       % EPI with labels, soft delays and ADC phase modulation
    'writeEpiDiffusionRS', ...              % diffusion spin echo EPI (refocusing, crushers)
    'writeTSE', ...                         % turbo spin echo (extended trapezoids across blocks)
    'writeHASTE', ...                       % single-shot TSE with split gradients
    'writeSpiral', ...                      % spiral (oversampled arbitrary gradients)
    'writeRadialGradientEcho_rotExt', ...   % rotation extension
    'writeGRE_rfShim', ...                  % RF shim extension
    'writeUTE', ...                         % half pulses, ramp sampling
    'writeSelectiveRf', ...                 % 2D selective arbitrary RF with arbitrary gradients
    'writeTrufi', ...                       % balanced SSFP
    'writeMPRAGE'};                         % inversion pulse, 3D (needs Python with sigpy, skipped otherwise)
mySeqDir   = fullfile(fileparts(mfilename('fullpath')), 'my_seq'); % optional: your own .seq files go here
maxBlocks  = 2000;    % references cover at most the first maxBlocks blocks of each sequence ...
maxPoints  = 100000;  % ... and fewer if their gradient, RF and ADC samples exceed this (about 3 MB per sequence)
v141       = 'cases'; % also write and check the v1.4.1 format: 'cases' (Seqret's test cases), 'all' or 'none'
outDir     = fullfile(fileparts(mfilename('fullpath')), 'out');

%% run
cfg = struct('pulseqPath', pulseqPath, 'runCases', runCases, 'runDemos', runDemos, 'mySeqDir', mySeqDir, ...
             'maxBlocks', maxBlocks, 'maxPoints', maxPoints, 'v141', v141, 'outDir', outDir);
cfg.demoList = demoList;
seqret_tests_main(cfg);
