# Seqret

**Seqret** is a lightweight and fast, browser-based viewer for [Pulseq](https://pulseq.github.io/) `.seq` files, that also includes an image preview.

Open a sequence and interactively explore the RF and gradient waveforms, ADC events, flags, sequence structure, k-space trajectory, and the resulting simulated MR image. Seqret runs entirely in the browser and does not require installation, server, internet connection, or file upload.

## Features

* Responsive sequence diagram with RF, gradients, ADC and labels
* Navigate and inspect individual blocks, shots and volumes
* 2D and 3D k-space trajectory visualization
* Built-in 3D image simulation using the actual sequence timing and k-space trajectory
* Simulation of T1/T2/T2\*, fat, diffusion, noise, susceptibility and eddy-current effects
* Peripheral and cardiac nerve-stimulation estimates using the SAFE model
* Linked browser tabs for comparing sequences
* PNG export of sequence diagrams, k-space trajectories and simulated images
* Light and dark themes
* Pulseq formats **1.2–1.5**
* Works offline and keeps sequence data local
* Graphical performance benchmark to track frame rate

## Usage

Download and open `seqret.html` in a modern web browser, then drag and drop a `.seq` file onto the page or click on the **Open .seq** button.

Go to **Display/Shots and volumes** to define how shots and volumes are identified. Click on volume or shot to focus on it. Use the arrow keys to step across volumes, shots or individual blocks.

Use the tabs on the right to view detailed information, view k-space or the simulated image.

## Performance

The sequence diagram is redrawn on every pan and zoom, and how fast the browser turns that drawing into pixels depends on its graphics renderer. In Chrome and Edge this matters more than the graphics card: on a Windows PC with an NVIDIA RTX 3080 and a high-resolution screen, the diagram ran at 30–40 fps with Chrome's older renderer and at the screen's full 120 fps with **Skia Graphite**.

If panning or zooming feels sluggish:

1. Run the frame-rate test (**⋯ › Run frame-rate test**) with the whole sequence in view. If *blank diagram* reaches your screen's refresh rate but *normal, panning* does not, the browser's drawing is the limit, not Seqret.
2. Open `chrome://gpu` (`edge://gpu` in Edge) and look for **Skia Graphite** under *Graphics Feature Status*. If it says *Disabled*, enable `chrome://flags/#skia-graphite` (`edge://flags/#skia-graphite`) and restart the browser. This is an experimental browser setting that a browser update may reset.
3. On a laptop, Chrome's Energy Saver mode limits pages to 30 fps while on battery (*Settings › Performance*).

## Related tools and software

### Pulseq

Seqret is based on, and designed for, sequences using the [Pulseq](https://pulseq.github.io/) format.

> Layton KJ, et al. \*Pulseq: A rapid and hardware-independent pulse sequence prototyping framework.\* Magn Reson Med. 2017;77:1544–1552. \[doi:10.1002/mrm.26235](https://doi.org/10.1002/mrm.26235)

### Nerve stimulation (SAFE model on Siemens systems)

Peripheral (PNS) and cardiac (CNS) nerve stimulation are predicted with the SAFE model, as implemented in [safe\_pns\_prediction](https://github.com/filip-szczepankiewicz/safe_pns_prediction). Seqret's implementation was checked against it. The prediction requires the gradient system's stimulation parameters, which can be loaded from the scanner's hardware files (`MP\_GPA\_\*.asc` or `MP\_GradSys\_\*.asc`) or entered by hand. The example hardware of safe\_pns\_prediction is included for testing and does not describe a real scanner.

> Hebrank FX, Gebhardt M. \*SAFE-Model: a new method for predicting peripheral nerve stimulations in MRI.\* Proc Intl Soc Mag Reson Med. 2000;8:2007.

> Szczepankiewicz F, Witzel T. \*safe\_pns\_prediction.\* \[github.com/filip-szczepankiewicz/safe\_pns\_prediction](https://github.com/filip-szczepankiewicz/safe\_pns\_prediction)

## Authors

Designed and coded by **Filip Szczepankiewicz**, Lund University.  
Code and testing scripts by **Claude**, Anthropic.

## License

Seqret is released under the **MIT License**.

Copyright © 2026 Filip Szczepankiewicz

