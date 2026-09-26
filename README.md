# Seqret

**Seqret** is a lightweight and fast, browser-based viewer for [Pulseq](https://pulseq.github.io/) `.seq` files, that also includes an image preview.

Open a sequence and interactively explore the RF and gradient waveforms, ADC events, flags, sequence structure, k-space trajectory, and the resulting simulated MR image. Seqret runs entirely in the browser — no installation, server, internet connection, or file upload required.

## Features

- Responsive sequence diagram with RF, gradients, ADC and labels
- Navigate and inspect individual blocks, shots and volumes
- 2D and 3D k-space trajectory visualization
- Built-in 3D image simulation using the actual sequence timing and k-space trajectory
- Simulation of T1/T2/T2*, fat, diffusion, noise, susceptibility and eddy-current effects
- Peripheral and cardiac nerve-stimulation estimates using the SAFE model
- Linked browser tabs for comparing sequences
- PNG export of sequence diagrams, k-space trajectories and simulated images
- Light and dark themes
- Pulseq formats **1.2–1.5**
- Works offline and keeps sequence data local

## Usage

Open `seqview.html` in a modern web browser, then drag and drop a `.seq` file onto the page or click **Open .seq**.

Go to **Display/Shots and volumes** to define how shots and volumes are identified. Click on volume or shot to focus on it. Use the arrow keys to step across volumes, steps or individual blocks.

Use the tabs on the right to view detailed information, view k-space or the simulated image.

## Pulseq

SeqView is designed for sequences using the open [Pulseq](https://pulseq.github.io/) format.

> Layton KJ, et al. *Pulseq: A rapid and hardware-independent pulse sequence prototyping framework.* Magn Reson Med. 2017;77:1544–1552. [doi:10.1002/mrm.26235](https://doi.org/10.1002/mrm.26235)

## Author

Designed and coded by **Filip Szczepankiewicz**, Lund University.  
Coded with **Claude (Anthropic)**.

## License

SeqView is released under the **MIT License**.

Copyright © 2026 Filip Szczepankiewicz