# Seqret reference tests in MATLAB

These scripts make MATLAB Pulseq the reference for Seqret. They write test sequences, let MATLAB Pulseq
read them back, and save what MATLAB computes from them, so that Seqret's Node test
(`tests/compare_matlab.mjs` in the development package) can compare Seqret against MATLAB number by number.

## Running

1. Use MATLAB Pulseq from the current master (v1.5.2 or later).
2. Open `seqret_run_all.m`, set `pulseqPath` if Pulseq is not on the path, and run it.
3. Output goes to `out\` (and a log to `out\log.txt`). Hand the whole `out` folder back.

What it runs:
- **Seqret's test cases** (`seqret_cases.m`): label order, arbitrary gradients with corners, the Pulseq
  1.5/1.5.1 extensions (rotations, RF shims, soft delays, custom labels, ADC phase modulation, triggers, RF
  purposes, ppm offsets) and a gradient that continues across blocks.
- **Twelve of Pulseq's demo sequences** (`matlab/demoSeq`), one per feature, listed in `demoList`
  (`{}` runs all of them). Demos that fail or stop early (some need Python with sigpy) are logged with the
  reason and skipped. Figures stay hidden, and each demo's own files are deleted once its `.seq` is copied.
- **Your own sequences**: any `.seq` file you put in `my_seq\`. Nothing leaves your machine.

For every sequence the output folder holds the `.seq` file, the same sequence as a Pulseq binary file
(`.bin`), for Seqret's test cases also in the v1.4.1 format (`_v141.seq`; setting `v141`), plus MATLAB's
waveforms, RF, k-space at the ADC samples, label values and soft delays as raw float64 files (`ref_*.f64`,
`v141_*.f64`) described in `manifest.json`. `seqret_save_refs.m` lists them.

The references cover the first `maxBlocks` (2000) blocks of each sequence, or fewer if their gradient, RF
and ADC samples exceed `maxPoints` (100,000), so each sequence gives a few MB. With the default settings
the whole output is about 30 MB and the run takes a few minutes; it can be deleted once compared.

Files with custom labels (`mr.addCustomLabel`) can only be read by MATLAB Pulseq after the same labels have
been registered: call `mr.addCustomLabel('NAME')` before running the script.

## Comparing

In the development package: `node tests/compare_matlab.mjs path\to\out` prints, per sequence, how far
Seqret is from MATLAB (gradients, |RF|, excitation/refocusing times, k-space, labels) and whether the `.bin`
file gives the same sequence as the `.seq` file, and writes `out\compare_summary.json`.
