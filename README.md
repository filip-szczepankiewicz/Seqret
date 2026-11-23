# Seqret

**Seqret** is a lightweight and fast, browser-based viewer for [Pulseq](https://pulseq.github.io/) `.seq` files, that also includes an image preview.

Open a sequence and interactively explore the RF and gradient waveforms, ADC events, flags, sequence structure, k-space trajectory, and the resulting simulated MR image. Seqret runs entirely in the browser and does not require installation, server, internet connection, or file upload.

## Features

* Responsive sequence diagram with RF, gradients, slew rate, k-vector, ADC, labels and more
* Built-in 3D image simulation using the actual sequence timing and k-space trajectory
* Simulation of T1/T2/T2\*, fat, diffusion, noise, susceptibility and eddy-current effects
* Analytic head and abdomen phantoms
* Automatic identification of shots and volumes (based on RF and flags)
* Segmented acquisitions: show only the shots that make one image, with the time between them left out (experimental, based on the SEG label)
* Visualization of (multiple) slice/slab positions in 3D space
* Navigate and inspect individual blocks, shots, and volumes
* 3D k-space trajectory visualization
* Peripheral and cardiac nerve-stimulation estimates using the SAFE model
* Concomitant gradients, their k-space shift and the generalized Maxwell index
* b-value, b-tensor and its eigenvalues per shot, from the actual gradient waveforms
* Spin- and gradient-echo markers in the sequence diagram and the k-space trajectory
* Linked browser tabs for comparing sequences; dropping several files opens each in its own linked tab
* Publication figures: PNG of the diagram, k-space or image at a chosen size, resolution, font and theme
* Multiple light and dark themes
* Pulseq formats 1.2–1.5, and Pulseq binary files (`.bin`)
* Works offline and keeps sequence data local
* Built-in frame-rate test, and a lower diagram quality for slower computers
* Development package with sources, tests and design instructions that enable LLM-supported further development (see [Development](#development))

## Usage

Download and open `seqret.html` in a modern web browser, then drag and drop a `.seq` file onto the page or click on the **Open .seq** button. In Chrome and Edge, **Open .seq** starts in the folder of the last opened file, and the reload button reads the file again after it has changed on disk.

Go to **Display › Shots and volumes** to define how shots and volumes are identified. Click on volume or shot to focus on it. Use the arrow keys to step across volumes, shots or individual blocks.

For segmented acquisitions, where one image is read in several shots that each fill part of k-space (e.g. segmented EPI or TSE), click **Group segments** in the toolbar. The diagram then shows only the shots of one image, side by side, each up to its last event. The time between them (shots of other slices and the TR fill) is left out and marked by a narrow box that says how much time was left out. The **Image** stepper moves to the next image. This is experimental: the images are found from the labels only, as shots with the same SLC (and REP, AVG, SET, PHS) and different SEG values, so it needs a sequence that sets SEG per shot. Mark reversed EPI lines with the REV flag; a sequence that changes SEG within a shot is not grouped. `materials/demoSeq/epi_seg3_2slc.seq` is an example (two slices, each read in three segments).

Use the tabs on the right to view detailed information, view k-space or the simulated image. The shot card in the **Selection** tab gives the shot's b-value, b-tensor and eigenvalues (ms/µm²), computed from all gradients from the excitation to the echo. **Display › Save figure…** saves a PNG for publications.

Go to **Display › Echo markers** to mark spin echoes (▼), gradient echoes at k = 0 (●) and the other gradient echoes along the readouts (○), in the diagram and on the k-space trajectory. Hovering a marker gives its time after the excitation and, for a spin echo, how far the nearest k = 0 gradient echo is from it. By default the markers are drawn only while at most 4 shots are in view.

Go to **Display › Concomitant** to show the concomitant gradients:

* **Gc**: the concomitant gradient seen by spins at a chosen position r. It is computed from the full field of the gradient coils, not from its second-order expansion. The field model includes the asymmetry *a* of the z coil and a non-Maxwell term *f*.
* **kc**: the zeroth moment of Gc, which is the k-space shift of the spins at r.
* **μ**: the generalized Maxwell index, μ(t) = (γ/B0)·|∫ **g**(t)<sup>⊗2</sup> h(t) dt|, the Frobenius norm of the running integral of the gradient's outer product. It is given in 1/m² with γ = 42.58 MHz/T, and depends only on the gradients and B0.

kc and μ are reset at each excitation and change sign at each refocusing pulse, as the k-vector does. **Settings…** sets r (default (5, 6, 7) cm), B0 (3 T), *a* (0.5) and *f* (0 T/m), and the values are kept in the browser. The sequence's x, y and z axes are taken as the scanner's, with B0 along z.

## Performance

The sequence diagram is redrawn on every pan and zoom, and how fast the browser turns that drawing into pixels depends on its graphics renderer. In Chrome and Edge this matters more than the graphics card: on a Windows PC with an NVIDIA RTX 3080 and a high-resolution screen, the diagram ran at 30–40 fps with Chrome's older renderer and at the screen's full 120 fps with **Skia Graphite**.

If panning or zooming feels sluggish:

1. Run the frame-rate test (**⋯ › Run frame-rate test**) with the whole sequence in view. If *blank diagram* reaches your screen's refresh rate but *normal, panning* does not, the browser's drawing is the limit, not Seqret.
2. Open `chrome://gpu` (`edge://gpu` in Edge) and look for **Skia Graphite** under *Graphics Feature Status*. If it says *Disabled*, enable `chrome://flags/#skia-graphite` (`edge://flags/#skia-graphite`) and restart the browser. This is an experimental browser setting that a browser update may reset.
3. On a laptop, Chrome's Energy Saver mode limits pages to 30 fps while on battery (*Settings › Performance*).
4. If none of this helps, lower **Display › View › Quality**. *Standard* draws coarser waveforms when zoomed out; *fast* also draws the diagram at a quarter of the pixels on high-resolution screens (at 2×), with slightly softer lines and text. Saved PNGs stay sharp. The frame-rate test shows the rate each quality gives.

## Development

Seqret is developed with LLM coding assistants. To continue its development, use the latest development package, `materials/devResources/seqret-dev-x.xx.x.zip`. It holds the sources from which `seqret.html` is built (the build reproduces it byte for byte), the build script, tests and tools, and the instructions for both human and machine agents: `AGENTS.md` (working rules for LLM coding assistants; `CLAUDE.md` points to it) and `DEVELOPMENT.md` (architecture, performance rules, validation and release procedure). Give the unpacked folder to the assistant and ask it to read `AGENTS.md` first. Older packages in the same folder are kept for reference.

## Related tools and software

### Pulseq

Seqret is based on, and designed for, sequences using the [Pulseq](https://pulseq.github.io/) format. [PyPulseq](https://github.com/imr-framework/pypulseq), the Python implementation of Pulseq, was used to validate Seqret. Its test-suite reference files check how files are read and how gradient waveforms and k-space are computed. Its waveforms were also compared with the nerve-stimulation input and used for the independent checks of the concomitant gradients, kc and μ.

> Layton KJ, et al. Pulseq: A rapid and hardware-independent pulse sequence prototyping framework. Magn Reson Med. 2017;77:1544–1552. [doi:10.1002/mrm.26235](https://doi.org/10.1002/mrm.26235)

> Ravi KS, Geethanath S, Vaughan JT. PyPulseq: a Python package for MRI pulse sequence design. J Open Source Softw. 2019;4(42):1725. [doi:10.21105/joss.01725](https://doi.org/10.21105/joss.01725)

### Nerve stimulation (SAFE model on Siemens systems)

Peripheral (PNS) and cardiac (CNS) nerve stimulation are predicted with the SAFE model, as implemented in [safe_pns_prediction](https://github.com/filip-szczepankiewicz/safe_pns_prediction). Seqret's implementation was checked against it. The prediction requires the gradient system's stimulation parameters, which can be loaded from the scanner's hardware files (`MP_GPA_*.asc` or `MP_GradSys_*.asc`) or entered by hand. The example hardware of safe_pns_prediction is included for testing and does not describe a real scanner.

> Hebrank FX, Gebhardt M. SAFE-Model - A New Method for Predicting Peripheral Nerve Stimulations in MRI, [Proc Intl Soc Mag Reson Med. 2000;8:2007](https://cds.ismrm.org/ismrm-2000/PDF7/2007.PDF).

> Szczepankiewicz F, Witzel T. SAFE-model in MATLAB [github.com/filip-szczepankiewicz/safe_pns_prediction](https://github.com/filip-szczepankiewicz/safe_pns_prediction)

### Concomitant gradients and the Maxwell index

Gc and kc use the field model of Bernstein et al., extended by the asymmetry *a* and the term *f*. Gc, kc and μ are computed as in Olsson et al. The Maxwell index was introduced by Szczepankiewicz et al.

> Bernstein MA, Zhou XJ, Polzin JA, et al. Concomitant gradient terms in phase contrast MR: analysis and correction. Magn Reson Med. 1998;39:300–308. [doi:10.1002/mrm.1910390218](https://doi.org/10.1002/mrm.1910390218)

> Szczepankiewicz F, Westin CF, Nilsson M. Maxwell-compensated design of asymmetric gradient waveforms for tensor-valued diffusion encoding. Magn Reson Med. 2019;82:1424–1437. [PMC6626569](https://pmc.ncbi.nlm.nih.gov/articles/PMC6626569/)

> Olsson V, Mortensen F, Ljungberg E, Testud F, Wirestam R, Molendowska M, Szczepankiewicz F. Concomitant gradient effects across field strengths and gradient amplitudes: improved estimation of errors and correction of concomitant dephasing and diffusion weighting. Magn Reson Med. 2026;96:1178–1191. [doi:10.1002/mrm.70422](https://doi.org/10.1002/mrm.70422)

## Author

Designed and coded by **Filip Szczepankiewicz**, Lund University.  
HTML implementation and testing scripts by **Claude**, Anthropic.

## License

Seqret is released under the **MIT License**.

Copyright © 2026 Filip Szczepankiewicz

