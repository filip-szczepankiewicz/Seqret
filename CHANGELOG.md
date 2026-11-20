# Seqret changelog

All versions, newest first. The About dialog of the page shows the latest 5.

## 1.48.4 (2026-11-20)

- Fixed: with the ROTATIONS extension, the slew could show spikes (up to about 370 T/m/s) in the diagram and in the peak slew of the Sequence tab. It happened where one gradient event ended inside a rotated block while another was ramping, such as an EPI blip that ends during a readout ramp. To catch steps at event edges, the rotated waveform got an extra vertex 1 ps after the end of every event, even one that was already 0 there; the gradient is stored as float32, and its rounding (about 0.016 Hz/m at 234 kHz/m) over 1 ps is 367 T/m/s. Edge vertices are now added only where an event is non-zero at its edge, so real steps are still drawn.
- Checked on an EPI file with stacks rotated 0°, 60° and 120° about y (mdfwf-seepi): peak slew 158.7 / 142.3 / 157.4 T/m/s (x / y / z), the same as an independent calculation in the physical axes; before, 367 T/m/s on z. Peak gradients unchanged.

## 1.48.3 (2026-11-20)

- Start page with recent files: the list is shown in two columns of compact entries (smaller padding and text), and the box widens from 460 to 680 px to hold them; the drawing at the top is kept at 400 px wide. With 8 recent files the start page is 519 px tall instead of 784 px, so the drawing, the title and the whole list fit in the plot area at 1366 × 768 and larger. Before, the list pushed the drawing and the title out above the frame. Without recent files the start page is as before.
- Recent files (start page and the list under the arrow next to Open .seq): the second line shows the date first, then the last two folders of the path (…\Pulseq\seq_0); the full path is still in the tooltip. Before, a long path was cut at the end and hid the date.
- The start page is centred so that, where it is taller than the plot area (small windows), it scrolls from its top instead of losing the top above the frame. One column of recent files in a window narrower than 620 px.

## 1.48.2 (2026-11-20)

- Display panel in two columns: channels on the left (RF, gradients, concomitant, readout, stimulation), and echo markers, view, shots and volumes and saving on the right. The panel is about half as tall as before: 413 px instead of 756 px at 1500 × 900, so it fits under the toolbar on a laptop screen and all of it is seen at once. It is 860 px wide (at most the window's width less 16 px).
- Within it: the RF unit and "as magnitude / real and imaginary" sit on the line of the RF chips, the gradient unit and "One axis" on the line of Gx, Gy, Gz, and "Settings…" and "Specifications…" next to their chips. Fit Y and Mark pauses share one row, Quality and Peaks the next, and "Only when zoomed in" follows the echo chips.
- Echoes moved from Channels to their own section, "Echo markers": they mark the RF lane and k-space and are not lanes.
- In a window narrower than 760 px the panel is one column again (624 px tall at 700 × 900).
- Every floating panel (Display, recent files, ⋯) now stays within the window's height and scrolls inside when the window is too short. Before, its lower part ran off the bottom of the window.
- Nothing else changed: the controls, their ids, tooltips and saved settings are the same as in 1.48.1.

## 1.48.1 (2026-11-15)

- Fixed: in files older than Pulseq 1.4, a shape whose stored length equals its number of samples was read as uncompressed. Those files always store shapes compressed, so the equal length is a coincidence (a derivative without repeated values: short shapes, noisy waveforms) and the shape is now decompressed like any other, as MATLAB Pulseq and PyPulseq do when they read such files (forceConvertUncompressed in readShapes). Example: 0.2, 0.3, −0.1, −0.4 with num_samples 4 was kept as it stood and is now read as 0.2, 0.5, 0.4, 0, the same as PyPulseq 1.5.0's decompress_shape gives. Files in format 1.4 and newer are read as before; the demo's shapes, gradients, block times, k-space samples and statistics are bit-identical to 1.48.0.
- Sharper diagram, overview, k-space, image and 3D view: each canvas now has the size of its own box. Before, it was given the size of the frame around it, which includes the frame's 1 px border on every side, so the canvas held 2 CSS px more each way than it is shown at and the browser scaled it down (the diagram by about 0.2 %, the overview's 52 rows into 50, a 420 px k-space plot into 417.5). That blurred lines drawn on whole pixels and put the pointer up to 2 px off at the right and lower edges. Canvas and shown size now agree to within half a device pixel (checked at 1×, 1.25×, 1.5× and 2×).
- Less work per frame while panning and zooming. The position of the pointer over the diagram is taken from the canvas's rectangle, kept between events (read again after a resize or a scroll, when the pointer enters or presses, and at the latest after half a second), instead of from offsetX/offsetY, which made the browser lay the page out in every wheel and move event. The readout, the navigation fields (volume, shot, block) and the ADC legend are written only when their content changes. In a software-drawn test browser, demo file, 240 frames at 2×: zooming with the pointer at rest, 241 page layouts → 6, layout time 163 → 2 ms and time on the main thread 5.5 → 4.2 s; with the pointer moving every frame the readout changes every frame, so there is still one layout per frame and the gain is small (script time about a tenth less, one style pass per frame instead of two). Dragging the overview uses the same idea.
- Many lanes on: the name of a low lane no longer runs into its scale numbers ("k-vector" into "30844", "RF phase" into "π"). Where the two do not fit side by side in a lane lower than 38 px, the scale is shown under the name as one range (±max or 0–max, with the unit where it fits); below 25 px only the name is shown. Higher lanes are drawn as before.
- Values at the cursor: where the stack of values (x, y, z) is higher than the lane, they are placed side by side on one line across the lane's middle, instead of running on over the values of the lanes below.
- Saved figures are unchanged (the same file, byte for byte, in the test).

## 1.48.0 (2026-11-12)

- Several files at once: dropping two or more .seq or .bin files (or choosing several with Open .seq) asks whether to open each in its own Seqret tab, linked by time, shot or volume (or not linked), or only the first. This tab opens the first file; the others get new tabs that are handed their file directly (postMessage, so it also works for the page opened from disk). Other dropped files (e.g. .txt) are ignored when there is at least one .seq or .bin.
- If the browser blocks the extra tabs (most allow one new tab per click), the dialog stays open with a button that opens the next file, one per click; allowing pop-ups for the page opens all at once.
- A single file opens directly, as before.

## 1.47.0 (2026-11-12)

- k-space: Nominal or Actual (k + kc) trajectory, under the k-space options. Actual is the k-vector plus the concomitant shift kc at the position set under Concomitant gradients, as in lane k + kc. A file corrected for concomitant fields (MxwlCorrParams in [DEFINITIONS]) has a distorted nominal trajectory; the field it was corrected for can be taken over in one click. Checked on a corrected EPI (B0 = 0.01 T): its actual trajectory at the slice centres is within 2.8 m⁻¹ (of 249) of the nominal trajectory of the uncorrected file.
- Diagram: a lane's y-zoom tag has a larger, centred × and a red cross that resets the zoom (double-clicking the lane's name still works).
- Recent files: the last 8 opened files are listed on the start page and under the arrow next to Open .seq; in Chrome and Edge they reopen directly from disk.
- Reload button (with label) next to Open .seq, greyed out when the file cannot be re-read.
- Sequence tab: when the file was written; clicking the md5 badge shows the full hash and copies it. The file-format note at the bottom is removed (credited in About).
- File name in the header: hovering shows the full path (for files opened from MATLAB with seqret.m) and clicking copies it.
- Shorter Concomitant gradients dialog, with the position boxes aligned with the others. "Pulseq viewer" removed next to the logo.
- About: PyPulseq and Olsson et al. credits revised (μ added to the latter); the latest 5 versions are shown.

## 1.46.0 (2026-11-08)

- Faster k-space plot: the trajectory is drawn into a pixel buffer, and long trajectories are thinned while the plot moves (the info line says when it is also thinned at rest). Redraw at rest: million-block file 18.5 s → 70 ms, 20,000-shot ZTE 6.4 s → 21 ms, EPI 0.96 → 0.13 s. Trajectory lines are now 1 device pixel wide, without anti-aliasing; saved figures still use vector lines.
- Faster image simulation: each shot's excitation is found once and kept, instead of re-reading the gradients in every search for the TR. ZTE (20,000 shots) 22 s → 0.8 s, with identical shot information.
- Faster non-Cartesian reconstruction on the CPU: the exact inverse Fourier sum is computed as a matrix product. Spiral 6.2 → 4.3 s; same image within 2·10⁻¹⁴ of its peak.

## 1.45.0 (2026-11-08)

- Faster drawing of zoomed-out diagrams: a dense pixel column is two rectangles instead of four (no band edges), and shot and volume boundaries are rectangles. Frame-rate test on a laptop: 118 fps, against 54 fps with the drawing of 1.44. Same values; bands have no darker edges and shot boundaries are solid and fainter.
- Faster k-vector, kc and k + kc lanes: the integral of a block without RF is kept per combination of events instead of per block. 8,806-block file: 0.8 → 0.03 s per frame.
- Min/max summaries with a factor 4 between levels (before 16): fewer steps per pixel column, identical drawing.

## 1.44.0 (2026-11-08)

- Diagram quality auto (new default): drawn as fast while the view moves and as high when it stops.
- Frame-rate test: the verdict names Seqret only when its work is also at least half the frame.
- Mark pauses: the hatch covers every lane; the k-vector, kc, k + kc and μ lanes have the same background as the others (veil removed).
- Y zoom per lane with Ctrl + scroll (×0.25 to ×10,000); double-click the lane's name to reset.
- Touchpad pinch zooms time, or y over a lane's name; Safari's pinch now zooms the diagram instead of the page.
- Fixed: the k-vector, kc, k + kc and μ lanes rescaled with every pan and zoom with Fit Y off. Fit Y no longer stops at the first 400 active stretches in view.

## 1.43.0 (2026-11-08)

- Concomitant gradients at the slice centre of each shot (Concomitant › Settings… › Position), or at a fixed r as before. The Gc and kc lanes, cursor readout and tabs follow.
- New lane k + kc: the k-vector plus kc.
- Checked against an independent calculation on four sequences: kc within 1.6·10⁻⁷ of its largest value; unchanged with the fixed position.

## 1.42.2 (2026-11-08)

- Fixed: with the ROTATIONS extension, a gradient continuing into the next block dropped to 0 at the joint, giving spikes in the diagram and a huge peak slew in the Sequence tab. Vertex times are now snapped to 0.1 ns.
- Sequence tab: each gradient peak links to the first block that reaches it.
- Selection tab: shot and volume cards list the peak gradient and slew per axis.

## 1.42.1 (2026-11-07)

- Rotated slice stacks: an image uses only shots with the same excitation frequency and slice orientation. Before, rotated stacks that reuse frequencies were merged into one image (all 11 in the rotated-stacks test). The same applies to image lists, k-space colours, the 3D view and the TR.
- The FOV definition is read in the sequence's logical axes, so oblique readouts get their prescribed FOV and Crop to FOV works.
- Checked: demo and 3D slab images bit-identical; browser tests pass.

## 1.42.0 (2026-11-07)

- Opens Pulseq binary files (.bin, format 1.5.2).
- Arbitrary gradients: corners on raster edges are restored as MATLAB Pulseq does (before off by slew·Δt/4 at each corner).
- Labels: LABELSET is applied before LABELINC, as the specification says.
- Files in format 1.4 and older: start and end of arbitrary gradients found as MATLAB Pulseq does.
- Checked against MATLAB Pulseq 1.5.2: gradients within 2.6·10⁻⁷ of the peak and k within 6·10⁻⁸ (before 1.2·10⁻² and 2.6·10⁻⁴).

## 1.41.0 (2026-10-31)

- Echo markers (Display › Echoes): spin echoes, gradient echoes at k = 0 and other gradient echoes, in the diagram and on the k-space trajectory. Hovering gives the timing.
- Checked against PyPulseq-based calculations on four sequences: the same echoes, times within 0.04 ns.

## 1.40.0 (2026-10-31)

- Hovering a row of the labels lane shades that row across the whole diagram, from its name in the margin to the right edge, so a label is easy to pair with its values (and the values the cursor shows for it). It follows the mouse in the margin too, and is off while panning.
- In the side tabs, hovering a name or a value shades the whole row from name to value (all name–value lists, e.g. the label counters in the Selection tab). The spacing between rows and columns is unchanged; it is now padding, so the shaded row is one band.

## 1.39.0 (2026-10-31)

- b-tensor per shot in the Selection tab: b-value, tensor and eigenvalues, integrated exactly over all gradients from the excitation to the echo. The simulation's b-value is now its trace.
- Checked against PyPulseq-based calculations on five sequences: within 1.5·10⁻⁷.

## 1.38.0 (2026-10-27)

- Concomitant gradient lanes: Gc (from the full coil field, not the second-order expansion), kc (its zeroth moment) and the Maxwell index μ.
- Settings for the position r, B0, z-coil asymmetry a and non-Maxwell term f.
- The cursor readout, Selection and Sequence tabs and saved figures include them; Display panel regrouped.
- References: Olsson V et al. Magn Reson Med 2026;96(3):1178–1191, doi:10.1002/mrm.70422; Bernstein MA et al. Magn Reson Med 1998;39(2):300–308, doi:10.1002/mrm.1910390218.
- Checked against PyPulseq-based calculations on four sequences: kc within 4·10⁻⁷, μ within 3·10⁻⁷; k-vector unchanged bit for bit.

## 1.37.0 (2026-10-02)

- Save figure, diagram: traces are drawn as one line of even width everywhere (steep ramps and readout trains were thinner than the rest), with the line width chosen in pt.
- Y axes with round values: each lane's scale goes up to the next round value above its peak (58.3 mT/m: 60; 19.3 µT: 20), with an axis line and ticks at round steps (e.g. 0, ±30, ±60), as many as fit; the time axis has a title, Time (ms). The coloured bars beside the lanes are left out.
- New options: gradients on one axis or a lane each (independent of the screen), fill under traces on or off, font (Arial, Helvetica, Times or the system font). Block shading stays its own switch.

## 1.36.0 (2026-10-02)

- Save figure…: a publication PNG of the diagram, k-space or image, with printed size, dpi, text size, theme, background and an optional version stamp.

## 1.35.1 (2026-10-02)

- Selection colour (selected volume, shot or block) toned down in the newer themes: warm grey in RedZ, muted ochre in Paper, soft yellow in Universal, sage green in Forest.
- Forest is a little brighter (background, panels, plot and grid lines).

## 1.35.0

- *No notes were kept for this version.*

## 1.34.0 (2026-10-02)

- Multi-echo sequences: each echo is its own image in the k-space and Image tabs, found from the ECO label or from the k-space lines.
- All readouts by type: overlapping images mix their colours.
- Phase-encoding line statistics are per echo.

## 1.33.6 (2026-10-02)

- k-space: the Colour option (acquisition order or ADC type) is gone. The arrows above the plot are always shown and step through the kinds of readout (imaging, reference, navigator, noise), each coloured by acquisition order; the last view shows all readouts together, coloured by type (and imaging by image). With one kind of readout, the arrows switch between it and that last view.

## 1.33.5 (2026-10-02)

- Slew rate: the trace no longer runs diagonally from the end of a ramp to the next event, as it still did in 1.33.4 at some zoom levels, e.g. right before and after the 180° pulses of the demo. Where a ramp ends at its block's end, the rounding of the two blocks' edge times could put the zero after the ramp before the ramp's last value in a pixel column, in exact peaks mode. Slew is now zero whenever the gradient is constant or off.

## 1.30.2 – 1.33.4

- *No notes were kept for the versions between 1.30.1 and 1.33.5.*

## 1.30.1 (2026-10-01)

- Fixed: with the Image tab open, Ctrl+clicking a second volume did not outline its slices in the 3D view until another image was chosen with the arrows. The image shown stays the same, so the cached result was reused with the selection it was computed for. The 3D view now always uses the current selection and is redrawn when it changes.

## 1.30.0 (2026-10-01)

- Volume and shot bars: click selects, double-click zooms; stepping keeps the zoom.
- Several volumes or shots can be selected (Ctrl+click, Shift+click).
- Image tab: arrows step through the images of a selection; the 3D view outlines the other selected slices.

## 1.29.1 (2026-09-30)

- Fixed: the OFF label (data not for online reconstruction; Pulseq specification and MATLAB toolbox) was shown as a counter. It is now a flag, drawn and read out like NAV or REF.
- Fixed: for a sequence without excitation pulses the Image tab stayed blank; it now says that there are no shots to simulate.

## 1.29.0 (2026-09-30)

- Pauses: the hatch lines are twice as far apart (16 px) and drawn only in the RF and gradient lanes. Display › View › Mark pauses turns them on or off; the choice is remembered.

## 1.28.0 (2026-09-30)

- Pauses: blocks without RF, gradients, ADC or trigger (delays, and blocks that only set labels) get a faint diagonal hatch over the lanes, so it is clear that nothing happens there. Consecutive pause blocks share one hatch; it fades in when a pause is 4–10 px wide on screen and moves with the diagram when panning.
- The cost is small: the pauses are found once per file (18 ms for 744,000 blocks), and drawing them takes under 0.03 ms per frame even in the whole-file view of that file. The frame-rate test has a new case without the texture, for comparison on real hardware.

## 1.27.0 (2026-09-29)

- Triggers: trigger events (Pulseq TRIGGERS extension) are shown as a TRIG row at the bottom of the labels lane, from their start to their end. Output pulses (osc0, osc1, ext1) are dark; waits for an external trigger (physio1, physio2) are orange. Zoomed in, each bar is labelled with its channel; hovering shows e.g. 'osc0 output'; the Selection tab describes them ('output pulse on osc0, delay 100 µs, 1000 µs long'). The labels lane now also appears for files with triggers but no labels.
- Checked on a generated sequence with both kinds (tools/make_triggers.py): the times, durations and channels of all 34 triggers agree with PyPulseq's reading of the file (largest difference 2e-16 s).

## 1.26.1 (2026-09-29)

- Fixed: the PNS and CNS lanes labelled their axis '104' at the height of the limit, which read as a limit of 104 %. The lane's top is 4 % above the larger of the limit and the peak (headroom), and its label hid the '100' of the limit line. The limit line is now labelled '100', and the top of the axis is labelled only when it is clear of it (a peak well above the limit).

## 1.26.0 (2026-09-29)

- k-space: hold the right mouse button and drag to pan, for example to look closely at the edge of k-space after zooming in. The left button still rotates, and the scroll wheel zooms about the centre of the plot, so what is in the middle stays there. Choosing a projection (kx–ky, kx–kz, ky–kz, 3D) resets the pan and zoom. The pan is limited to the extent of the data, so the plot cannot be lost off screen.

## 1.25.0 (2026-09-29)

- k-space: zoomed in, the samples are drawn as dots up to 6 px across (before: 1–2 px at every zoom), so it is easy to see where k-space is sampled. The size follows the space per sample in view; the full view looks as before (pixel for pixel on the demo).
- k-space: hovering a sample rings it and shows its number in the ADC event, the ADC event and shot, the block, the time (and time after the excitation), k in m⁻¹, the ADC type and the label values. The cursor in the diagram moves to that time, so the sample can be found in the sequence.

## 1.24.4 (2026-09-29)

- Fixed: Image › k-space drew the reconstruction grid cell by cell as a square, so a readout with oversampling (smaller Δk along the readout) looked as if it reached twice as far in k-space. It is now drawn in physical k, with the same scale on both axes: an oversampled readout covers the same k range as the phase encoding, with samples twice as dense. Checked on the demo (2× oversampling): the drawn data is now as wide as it is high (width/height 1.01, before 1.88), and on the rotated stacks, including the ones shown transposed.

## 1.24.3 (2026-09-29)

- Fixed: images of slab-selective 3D scans with 8–64 partitions lay in the readout × slab-normal plane. 2D images unchanged.
- Frame-rate test: the path-drawn rectangle cases removed.
- Unused code removed (4 kB smaller).
- Development package: comparison with PyPulseq on 31 sequences (within 10⁻⁶) and more browser tests.

## 1.24.2 (2026-09-29)

- Frame-rate test: the suggestion blames Seqret's own work only when it takes most of what the screen allows per frame (80 % of a blank diagram's frame time). Before, it compared Seqret's time with the slow frame itself, so on a wide window at 100 Hz (Seqret 5 ms, frames 10–20 ms, the rest the browser's drawing) it wrongly said Seqret was the limit.

## 1.24.1 (2026-09-29)

- A button at the right end of the toolbar (or the \ key) hides the side panel with its tabs, so the diagram fills the width of the window; pressing it again brings the panel back. The choice is remembered. While the panel is hidden, the k-space and the simulated image are not recomputed as the view moves; they update when the panel is shown again.

## 1.24.0 (2026-09-29)

- Peaks › exact (new default): short features are drawn through their extremes at their true times (M4 method: Jugel U et al. PVLDB 2014;7(10):797–808), so narrow RF pulses are thin spikes. Demo in full view: pixels differing from an exact drawing 3.4 % → 2.0 %; frame rate unchanged.
- Peaks › per column keeps the previous drawing.
- Fixed: Quality showed ultra while high was drawn.

## 1.23.3 (2026-09-29)

- Fixed: zooming in very far could hang the page for many seconds per frame (reproduced on the demo with the k-vector lane on: 13.8 s per frame). The k-vector (1.22.3) and the area under a trace (1.23.0) find where a line crosses each pixel column's edges, and a line from a point far off screen made that loop run over millions of columns off screen. It now runs over the columns on screen only.
- The view is at least 0.1 ms wide (before: 0.2 µs).

## 1.23.2 (2026-09-29)

- Faster zoomed-out diagram, most in high and ultra quality: dense stretches were joined column to column by stroked lines that the column's own span already covers. The width of a pixel column was estimated as the smallest spacing between any two points, which a single sample near a column centre made tiny, so almost every join counted as a gap. On a ZTE-like sequence in full view that was about 100,000–190,000 pixels of anti-aliased line per frame in the gradient lane (the frame-rate test showed high at 26 fps against 84 fps for standard). The column width now comes from the column grid itself; the lines are gone (about 2,600 pixels of line per frame remain, mostly the grid and axes).
- The look is the same: on the demo at three zoom levels at most 0.35 % of pixels differ, on the ZTE-like sequence 0–2.3 %, where dense spans now fill their whole column.

## 1.23.1 (2026-09-29)

- The faster area drawing of 1.23.0 also covers the gradients when each is drawn in its own lane (Display › Gradients › One axis off), where the area lies on both sides of the zero line: 1.23.0 filled only the part above it. Now one rectangle per pixel column above and one below. Checked against 1.20.0 with separate gradient lanes on the demo and a ZTE-like sequence at two zoom levels: no pixel differs by more than a trace.

## 1.23.0 (2026-09-29)

- Much faster with many RF pulses in view: the faint area under the RF |B1| trace was one filled polygon through every point of the trace. For a ZTE sequence (a pulse per spoke) that is tens of thousands of vertices, and the frame-rate test on a 46,818-block ZTE sequence showed it as nearly all of the frame: 6 fps with it, 36 fps without. It is now drawn as one faint rectangle per pixel column, from the base to the highest point the trace reaches there; the look is the same (239 pixels of the demo's diagram differ slightly in shade).
- Frame-rate test: when the browser's drawing is the limit and leaving out one part raises the frame rate by more than half, the suggestion names that part.

## 1.22.3 (2026-09-29)

- Faster k-vector lane after 1.22.2: drawn with rectangles only. On a 40,000-block ZTE-like file the frame rate with it on equals the rate without it.
- Per-block k-vector data kept for up to about a million vertices.

## 1.22.2 (2026-09-29)

- k-vector lane: at an excitation the curve starts anew at zero instead of being joined to it by a line from the last k-position; the reset is a jump, not a path through k-space. Where one pixel column holds both sides of the reset, it is split there: the part before is drawn up to the reset, the part after starts from zero. Zoomed far out, where one column holds whole spokes, the column's range still spans both. The sign flip at a refocusing pulse is still drawn as a vertical line.

## 1.22.1 (2026-09-29)

- Fixed (from 1.22.0): the k-vector lane showed broken lines, correct only when zoomed far in. To save drawing, 1.22.0 left out every line between two pixel columns that each have a solid min–max rectangle, but such a line is only redundant when it passes from one rectangle into the other; elsewhere it is the curve itself (a ramp across a few columns, a flat stretch between readouts). Now a line is left out only between neighbouring columns and only where it runs inside both rectangles. Checked on the demo and on a 40,000-block ZTE-like sequence at several zoom levels against 1.20.0; the cost stays as in 1.22.0 (12–15 fps with the k-vector on in full view in a test browser, 15 fps without).

## 1.22.0 (2026-09-29)

- Faster k-vector lane: on a 40,000-block ZTE-like file 3 → 12–15 fps (veil instead of fading, opaque rectangles, no covered lines).
- Per-block k-vector summaries are kept after the first computation.
- Shapes are clipped to their lane.
- Quality ultra: two anti-aliased columns per screen pixel.

## 1.21.0 (2026-09-29)

- Faster k-vector lane. Its traces were drawn twice, once at full strength clipped to the active stretches and once pale clipped to the rest, and with many active stretches (every spoke of a ZTE sequence) the clip paths held thousands of rectangles, which every one of the many drawing calls had to pass through. The traces are now drawn once into a lane-sized image, faded outside the active stretches, and copied onto the diagram. On a 40,000-block ZTE-like sequence in full view, in a slow test browser: Seqret's time for the lane 163 → about 20 ms per frame, the whole frame 350 → 150 ms. The look is the same (0.6 % of pixels differ slightly in shade).
- What remains is the cost of drawing three dense traces, as in the gradient lane: zoomed out on such a file each lane draws about 25,000 rectangles per frame.

## 1.20.0 (2026-09-27)

- Open .seq starts in the folder of the last opened file, also after the browser is restarted (Chrome and Edge; the file's handle is kept in the browser's storage, which gives no access to the file by itself). Files opened by dragging them onto the page count too.
- Display panel regrouped: one row per kind of channel with its settings next to it — RF (|B1|, phase, unit, shown as), gradients (Gx, Gy, Gz, slew, k-vector, unit, one axis), readout (ADC, labels) and stimulation (PNS, CNS, L2 norm, specifications); fit Y and quality under View.
- Removed the time-weighted fill of dense waveforms (1.19.0): it added little and was slow on large files. The frame-rate test keeps the improved suggestion from 1.19.0.

## 1.19.0 (2026-09-27)

- Dense waveforms › time-weighted fill (option): each level shaded by the time the waveform spends there. Several times the band's cost; falls back to the band above 10,000 blocks.
- Frame-rate test: better suggestions when Seqret's own work limits the frame.

## 1.18.1 (2026-09-27)

- Frame-rate test: the suggestion now tells apart the two limits. When Seqret's own work takes most of the frame (large files zoomed out), it says so instead of pointing to the browser's renderer; it points to the renderer only when the frame takes much longer than Seqret's work.

## 1.18.0 (2026-09-27)

- Diagram quality high (new default): one column per screen pixel, so RF pulses keep their true width. Up to about twice Seqret's time per frame on small files.
- Diagram quality (high, standard, fast) replaces diagram resolution.
- Frame-rate test compares the qualities.

## 1.17.0 (2026-09-27)

- Display › Diagram resolution: sharp (default) or fast. Fast draws the diagram and the overview at 1× pixel density on high-density screens (a quarter of the pixels at 2×) and lets the browser scale them up, for computers or browsers where drawing limits the frame rate; lines and text are slightly softer. The cursor overlay, k-space and image stay sharp, PNG export is always at full density, and the setting is remembered. On a 1× screen it changes nothing.
- Frame-rate test: when the browser's drawing limits the frame rate (a blank diagram much faster than the normal one), the result says so and suggests the fast diagram resolution (with the rate it gave) and Chrome's Skia Graphite renderer. With fast resolution on, the test compares against full pixel density instead.

## 1.16.7 (2026-09-27)

- Frame-rate test: new cases that separate where the time goes: without page updates (cursor readout, steppers, legend), a blank diagram (nothing drawn, page still updated), a blank diagram without page updates (what the browser needs for an empty frame), and, on high-density screens, the diagram at 1× pixel density (a quarter of the pixels at 2×, same shapes).
- Seqret time now includes all of Seqret's work in a frame (the diagram, the overview, the cursor overlay, page updates and the k-space when shown), and the header says which tab was open.

## 1.16.6 (2026-09-27)

- Frame-rate test: the columns are named by quantity (frame rate, frame time, Seqret time), with their units (fps, ms) on a second header line. The frame-time panel says 'Seqret time' in the same way.

## 1.16.5 (2026-09-27)

- Fixed (from 1.16.4): the phase-encoding FOV of rotated stacks was 0.8 % too long. Checked over 11 rotated stacks; other images unchanged.

## 1.16.4 (2026-09-27)

- Fixed: rotated stacks with the readout mostly along z were simulated 64×8 instead of 64×64. The FOV definition now applies only when it fits the axis and the sampling. Other images unchanged.

## 1.16.3 (2026-09-27)

- The About dialog shows the three latest versions; the complete version history moved to CHANGELOG.md in the source code repository, which the dialog links to. The page is about 26 kB smaller.

## 1.16.2 (2026-09-27)

- Faster drawing when zoomed out: the merged rectangles of min/max bands, their edges and dense trace columns are drawn with fillRect again, each with its left and right edges on whole screen pixels, instead of being collected into one path (as since 1.14.2). A graphics card draws rectangles directly but a path of hundreds of rectangles as a general shape. Measured with the frame-rate test on a laptop, whole demo in view: 111 → 170 fps panning, 115 → 146 fps zooming.
- The look is the same; single pixels at the edges of bands can differ slightly in shade, most on screens with 1.25× or 1.75× pixels, where neighbouring rectangles now meet on whole pixels.
- The frame-rate test keeps the path drawing of 1.14.2–1.16.1 as a case, for comparison.

## 1.16.1 (2026-09-27)

- Frame-rate test (⋯ › Run frame-rate test): from the current view, the diagram is moved on every screen frame for about half a minute (panning, then zooming), and the frame rate is measured with everything drawn, with each part left out in turn (block shading, min/max bands, area under RF, labels lane, overview), and with an alternative way of drawing the batched rectangles (single fillRect calls instead of one path). The table is shown in the frame-time panel and copied to the clipboard; the view and settings are restored.
- This measures the browser's whole frame, including drawing on the graphics card, on the machine where it is run, which a test browser cannot reproduce. The normal drawing is unchanged.

## 1.16.0 (2026-09-26)

- Readout oversampling in the image simulation: it is detected from the flat-top sample spacing of the readouts and the FOV definition, and the image is reconstructed from all samples over the whole sampled FOV, so objects outside the prescribed FOV no longer fold in along the readout. Image options › Oversampling: Crop to FOV (as a scanner does; default) or Show all; switching is instant. The FOV label and matrix size follow the setting.
- Before, a file with an FOV definition was reconstructed on the prescribed FOV even when oversampled, so the benefit of oversampling was lost (a phantom wider than the FOV folded in). Files without oversampling give identical images.

## 1.15.1 (2026-09-26)

- Frame times panel (⋯ › Show frame times, Shift+D): adds the frame rate while the view moves, measured from the screen frames the browser delivers (frames over the time they took, with the slowest frame), so stutter counts in full. It is measured only while the panel is open and the view is moving.

## 1.15.0 (2026-09-26)

- RF can be shown as its real and imaginary parts (Display › Axes › RF as), on a signed axis, so a sinc shows its negative lobes and phase-modulated pulses their complex shape. It is the RF shape amp·mag·e^{iφ} with the shape's own phase, without the phase and frequency offsets, as in Pulseq's rf.signal; it matches PyPulseq's rf.signal to 1e-7 of the peak. The cursor readout and hover values give both parts; the setting is remembered.

## 1.14.2 (2026-09-26)

- Faster zoomed-out views, with the same look. Drawing calls per frame are cut from up to 32,000 to at most about 600: the rectangles of envelopes, spans, ADC types and label flags are collected into one path per style and filled once, and short envelope bands are drawn in three calls instead of three each.
- On high-density screens, traces use two columns per pixel only when zoomed in (where it sharpens curves); zoomed out they use one. This replaces a timing-based switch that flipped between the two on alternate frames, so that every other frame was slow; at a twentieth of a long file, a frame took up to 123 ms and now takes about 14 ms (main thread, measured).
- The look matches 1.14.1: identical on normal screens; on high-density screens zoomed-out traces are drawn at the screen's CSS resolution, which makes dense stretches very slightly bolder.

## 1.14.1 (2026-09-26)

- Reverted the drawing changes of 1.14.0 (column bars when zoomed out, stretched previews while zooming, banded label rows): they looked worse and ran worse in real use. They had been tuned with timings from a software-rendering test browser, which misrepresents a normal GPU-accelerated one. Drawing is as in 1.13.3.
- Kept from 1.14.0: the fix for PNS and CNS curves drawn as separate points when zoomed in far.

## 1.14.0 (2026-09-26)

- Zoomed out, where every pixel column holds many samples, traces are drawn as an overview: one bar per column from the minimum to the maximum, a light band with crisp edges. It shows the shape and range of what is going on at a fraction of the drawing cost; at the scale of a volume or shot, traces are drawn as lines as before.
- Label rows: counters that change more often than every other pixel are drawn as bands, and flags that switch at every readout merge into bars (these rows were the costliest part of a zoomed-out frame).
- Zooming and panning stay smooth on long files: while the view moves, the last full frame is stretched and shifted, and the frame is drawn in full 160 ms after the movement stops. On a 1,008-shot sequence, 24 mouse-wheel steps were handled in 1.5 s instead of 5.9 s.
- Fixed: the PNS and CNS curves were drawn as separate points ('sticks') when zoomed in further than one sample per pixel; they are joined lines again.

## 1.13.3 (2026-09-26)

- Icon: the mark is centred on its tile at every size (it sat up to 4 % to the right and 3 % low), and the dashed line starts and ends with a full dash.

## 1.13.2 (2026-09-26)

- New icon: the viewer's mark (gradient trapezoid over a dashed RF line) on a rounded tile, as seqret.ico (Windows, 16–256 px), seqret.icns (macOS) and PNG; the page uses it as its favicon, so shortcuts created from the browser get it too.

## 1.13.1 (2026-09-26)

- The M0 lane is renamed k-vector and is always shown in 1/m (the values are unchanged: the zeroth moment of gradients in Hz/m is k). The cursor readout and the Selection tab say k.

## 1.13.0 (2026-09-26)

- New M0 lane: the zeroth gradient moment, reset at each excitation and sign-flipped at each refocusing pulse; also in the cursor readout and Selection tab.
- Checked against PyPulseq: within 10⁻⁷.

## 1.12.3 (2026-09-26)

- Faster with the PNS and CNS lanes on. The lanes are drawn as the upper envelope of each trace (one line per trace, the norm with a faint area under it) at one column per screen pixel: on a high-resolution screen this halved the drawing time of the whole file and cut panning at shot scale about threefold.
- The stimulation pass runs in a background worker, so the page stays responsive while it computes; the lanes show its progress. Closing the specifications dialog no longer restarts the pass when nothing changed. Results are bit-identical to before.

## 1.12.2 (2026-09-26)

- About: link to the source code repository (github.com/filip-szczepankiewicz/Seqret), also included in the citation.
- About: acknowledgements for PyPulseq, used to validate the viewer, and for safe_pns_prediction, the implementation of the SAFE model used for nerve stimulation.

## 1.12.1 (2026-09-26)

- New built-in demo (Load demo): seqret_default.seq, a diffusion-weighted spin-echo EPI (mdfwf-seepi, Pulseq 1.5.1) with three slices and three volumes, supplied by F. Szczepankiewicz and embedded unchanged.

## 1.12.0 (2026-09-26)

- Renamed from SeqView to Seqret. The page is now seqret.html and the MATLAB helper seqret.m. Settings, the theme and the stimulation parameters saved by SeqView in this browser are carried over; tabs of SeqView and Seqret do not link to each other.
- Entries below this one describe SeqView.

## 1.11.0 (2026-09-26)

- PNS and cardiac stimulation lanes with the SAFE model (Hebrank and Gebhardt, ISMRM 2000), as in safe_pns_prediction.
- System specifications from .asc files, typed in, or the example hardware; checked as in safe_hw_check and safe_hw_verify.
- Peaks in the Sequence tab, block, shot and volume cards and the cursor readout.
- Checked against safe_gwf_to_pns in Octave: within 10⁻¹⁵.

## 1.10.0 (2026-09-26)

- Reload button (↻, key R) next to Open: reads the current file again and keeps the zoom, selection, history, tab and settings. The header says when it was reloaded, and whether the file had changed on disk.
- In Chrome and Edge, Open and drag-and-drop keep a handle to the file on disk, so a sequence rewritten by MATLAB or Python is picked up by Reload. Other browsers keep the file as it was given: Reload works while it is unchanged, and after a change asks for it to be opened again. The demo and files embedded by seqview.m have no reload.
- On narrow screens the Open button is labelled 'Open' so the header stays on one row.

## 1.9.0 (2026-09-26)

- Decluttered layout: above the diagram only the Volume, Shot and Block steppers and the zoom buttons remain; channels, units, shots and volumes rules and Save as PNG moved to a Display panel. New tab, linked tabs and the theme moved to a menu (⋯) next to Open .seq, which shows a green dot while tabs are linked.
- k-space and Image tabs: path, colours, the explanation and Save as PNG, and the simulation settings, are behind an options button. While folded away, the Image tab shows a one-line summary of the simulation settings; click it to open them.
- Floating panels close on a click outside or on Escape; keys pressed inside a panel no longer step or zoom the diagram.

## 1.8.0 (2026-09-26)

- Selection tab: RF blocks show the slice they select (orientation, position, thickness, bandwidth, fat shift; refocusing against excited slice).
- Pulseq 1.5 ppm frequency offsets are used (before, a ppm fat saturation saturated water).
- Inversion recovery follows the actual inversion cycle (before, Mz could exceed 1, e.g. MPRAGE).

## 1.7.3 (2026-09-25)

- Smoother waveforms when zoomed out: traces are computed per device pixel, and where many samples fall into one pixel the min/max band is drawn as a filled envelope with thin edges instead of vertical strokes.

## 1.7.2 (2026-09-25)

- Fixed: the block shading flickered on and off while panning. It is now decided per block from its width on screen (fading in between 2 and 6 px), so it no longer depends on how many blocks happen to be in view.

## 1.7.1 (2026-09-25)

- Fixed: switching a non-Cartesian (e.g. spiral) image to coronal or sagittal could lock the page. Where the nose, neck and brainstem overlap the head, the overlap correction was a direct sum over tens of thousands of patches times all samples; it now uses FFT maps read at the samples (within 1 % of the exact sum, about 700× faster).
- The far-field maps of the air bubble are at most 1024², and their FFTs run as parallel tasks, with the page yielding between them.

## 1.7.0 (2026-09-25)

- Image simulation on the graphics card (WebGL2): the phantom evaluation, the exact inverse Fourier sum and the air bubble's direct sum run as GPU kernels when a hardware GPU is available. Checked against the CPU: images agree within one grey level.
- Falls back to the CPU workers automatically without WebGL2, with software-emulated WebGL, without floating-point render targets, or if the GPU fails during a calculation. The info line says which was used.

## 1.6.0 (2026-09-25)

- Image simulation in parallel background workers: the phantom evaluation, the exact inverse Fourier sum for non-Cartesian data and the bubble's direct sum are split over the processor cores; the page itself does only the setup and never freezes.
- Recent images are kept (up to 12): stepping back to a volume or echo just seen shows it at once.
- Faster loading: the md5 signature check runs in its own worker in parallel with parsing, and shots are handed to the page as packed arrays (about 1 s less for an 82 MB file).
- 3D view rendered on the graphics card (WebGL2) with the same algorithm; the CPU renderer remains as a fallback.

## 1.5.3 (2026-09-25)

- Fixed: with the air bubble on, spiral (and other non-Cartesian) images could freeze the page for tens of seconds: the calculation now yields to the browser within long readouts and while building the field patches.
- Non-Cartesian images with the bubble use the same near/far split as Cartesian ones (exact sum near the sphere, power series through oversampled FFT maps elsewhere): about 3× faster for a spiral, 60× for radial, within 2 % of the exact sum on the radial example.
- Non-Cartesian images are reconstructed with the exact inverse Fourier sum up to much larger sizes (spirals previously fell back to nearest-neighbour gridding).

## 1.5.2 (2026-09-24)

- Stepping through volumes or shots with the arrows keeps the zoom level: zoomed inside an item, the view keeps the same offset into the next one; otherwise it centres on the next one. A first selection still shows the whole item.

## 1.5.1 (2026-09-24)

- Image tab: multiple echoes per shot. A readout that revisits a k-space line already acquired starts a new echo (split at the largest time gap, e.g. at the refocusing pulse), so two full EPI trains around a refocusing pulse give two images; arrows above the image step between them and show each echo's TE. Turbo spin echo, whose lines are all different, stays one image.
- Fixed: when a grid point was acquired in several shots (3D partitions, averages), its timing was averaged in absolute time, so T2 decay could be evaluated seconds away from the right time (MPRAGE images had absurd intensities). Timing is now averaged relative to each sample's own excitation.
- T1 steady state for spin echoes now follows the magnetization through every refocusing pulse (each at its own flip angle) instead of using only the last one; identical to the textbook formula for a single spin echo, and correct for double echoes and turbo spin echo.

## 1.5.0 (2026-09-24)

- Rotation extension (Pulseq 1.5 ROTATIONS): a block's gradient events are played rotated, G_physical = R·G_logical with R from the unit quaternion (w, x, y, z), as in Pulseq's own code. The diagram, slew, statistics, k-space, volume detection and image simulation all use the rotated (physical) gradients.
- The Selection tab shows a block's rotation as an angle about an axis; the Sequence tab summarises the rotated blocks.
- Checked with a demo whose shots are rotated in 30° steps: the k-space of every ADC sample equals the rotated k-space of the unrotated demo (differences at the level of the quaternion's rounding).

## 1.4.3 (2026-09-24)

- Fixed: grouping volumes by a label for shots without a readout (dummy scans). Such a shot is now read where its readout would have been (its excitation plus the typical excitation-to-ADC time), so labels set after the excitation, as in mdfwf, are taken into account.

## 1.4.2 (2026-09-24)

- Fixed: grouping volumes by a label (e.g. SET) now includes shots without a readout (dummy scans): each shot takes the label value at its first ADC, or at its excitation if it has none.
- Image tab: a shot without a readout (e.g. a dummy scan) is no longer imaged with data borrowed from other shots; the tab says there is no data to reconstruct. A selected volume is imaged from its shots that have data.

## 1.4.1 (2026-09-24)

- Image tab: tidier controls — a toolbar with the view, the 3D toggle and PNG export above the image, and the settings grouped in a compact panel (phantom, slices, contrast, artefacts, reconstruction) with toggle chips; full explanations in tooltips.

## 1.4.0 (2026-09-24)

- Image tab: optional residual eddy currents (typical or poorly compensated, illustrative): exponential responses (1 ms and 50 ms) to the gradient slew on each axis plus a B0 term. The signal is taken at the actual k-space position, so diffusion directions show their own shift, shear and scaling; the info line gives the k-space error in pixels.

## 1.3.7 (2026-09-24)

- Image tab: the 3D view can be switched off.
- Image tab: 'Slice position from sequence' can be switched off; every shot is then imaged in the plane through the air bubble's centre, with orientation and thickness still from the sequence.

## 1.3.6 (2026-09-24)

- Fixed: when the file does not state an RF pulse's purpose (Pulseq < 1.5, or 'u'), a saturation pulse above 90° was taken as a refocusing pulse and assigned to the previous shot. Purposes are now inferred with context as well: a pulse with no readout before the next excitation is a preparation pulse (inversion near 180°, otherwise saturation), and an off-resonant pulse without a gradient is a saturation pulse. Stated purposes are never changed.
- As a result, older files (e.g. MPRAGE in Pulseq 1.2–1.4) now recognise their inversion pulses, so shots split at preparation pulses as for 1.5 files.

## 1.3.5 (2026-09-24)

- Head phantom: the nose and neck now join the head, with a brainstem running from the brain into the neck.
- Phantom model: top-level regions may overlap; the later one wins, and the double-counted signal is subtracted exactly (checked on a proton-density image: overlaps show the winning tissue's value within 0.02).

## 1.3.4 (2026-09-24)

- Head phantom: a nose and a neck make its orientation obvious in the 3D view, the scout and the simulated images.
- 3D view: always rendered at full resolution.

## 1.3.3 (2026-09-24)

- 3D view: rendered per pixel by ray casting through the analytic phantom, so tissue in front of a slice hides part of it and the shading follows the true path lengths; it stays smooth while rotating (half resolution during a drag).

## 1.3.2 (2026-09-24)

- 3D view: depth cueing (fog) and volume shading, so near and far parts of the phantom and the slice planes are easier to tell apart.

## 1.3.1 (2026-09-24)

- Image tab: a rotatable 3D view below the image shows the translucent phantom (exact ellipsoid outlines), the air bubble, the current slice with its thickness and image axes, and the other slices of the volume.

## 1.3.0 (2026-09-24)

- Image tab: the phantoms are now 3D (3D Shepp–Logan head, abdomen of ellipsoids). Each image is a section at the slice the sequence excites: position from the RF frequency offset and slice gradient, thickness from the RF bandwidth, orientation (including oblique) from the gradient during the pulse and the principal axes of k-space.
- Image tab: choose which sequence axis is head–foot (axial, coronal or sagittal); the image edges are labelled (A/P, L/R, S/I) and a scout inset shows where the slice lies. 3D-encoded scans show one partition; non-selective 2D scans a projection.
- Image tab: the air bubble's field is the 3D dipole relative to B0, so its pattern changes with the slice orientation, and a slice passing near the bubble is distorted even when it does not cut it.
- Image tab: faster for scans that acquire the same k-space point many times (3D partitions, averages).

## 1.2.1 (2026-09-24)

- Image tab: the air bubble is 20–400× faster (256×256 in about 6 s instead of an estimated 45 min) and 5–15× more accurate: patches near the surface are refined, tissue edges use partial volumes, rows sharing one timing pattern share one FFT, and the far field is included everywhere through a power series in the phase.
- Image tab: Cartesian k-space is now evaluated exactly on the grid (with the sample timing interpolated), instead of interpolating half-offset samples, which had damped fine detail and shaded the image edges. Filled lines now include the bubble's field too.
- Diagram: right-drag pans along time; left-drag still zooms into the dragged range.

## 1.2.0 (2026-09-24)

- New Image tab: simulates the image the selected volume would give, from an analytic phantom (head or abdomen) sampled at the sequence's own k-space positions and sample times.
- Includes T1 steady state, inversion and frequency-selective saturation pulses, T2 and T2′ decay, six-peak fat with its chemical shift, spin-echo refocusing, diffusion weighting from the gradient waveform (b-value per shot), an optional air bubble with its field, and noise scaled with bandwidth; 1.5, 3 or 7 T.
- Lines not acquired (parallel imaging, partial Fourier) are filled as an ideal reconstruction would restore them, or zero-filled; the k-space view shows which.
- The demo's fat saturation is now tuned (95°) so that fat is suppressed.

## 1.1.5 (2026-09-24)

- Fixed: with very many shots (hundreds of thousands), the Sequence tab summary failed after loading.
- SeqView can open a file embedded in the page itself (groundwork for opening .seq files by double-click; not yet in use).

## 1.1.4 (2026-09-24)

- Credits: designed and coded by Filip Szczepankiewicz (Lund University); coded by Claude (Anthropic).
- Released under the MIT License; the licence text is included in the file and in the About dialog.

## 1.1.3 (2026-09-24)

- Uses the operating system's own interface font instead of a downloaded web font, so the page makes no network requests and works fully offline.
- Shorter acknowledgements in the About dialog.

## 1.1.2 (2026-09-24)

- The built-in demo is now a generic diffusion-weighted spin-echo EPI written directly in the Pulseq format for SeqView, with no third-party toolbox involved.
- Links to the Pulseq paper (doi:10.1002/mrm.26235) and website on the start screen, in the Sequence tab and in the About dialog.

## 1.1.1 (2026-09-24)

- Fixed: the interface flickered while moving the cursor. The cursor readout could wrap onto a second line, which resized and redrew the diagram; it now has a fixed one-line height, and canvases are only resized when their size really changes.

## 1.1.0 (2026-09-24)

- Each block gets a short description (for example RF90 excitation, RF180 refocusing, Navigator, Phase blip, Crusher, Diffusion encoding, Spoiler, Pause), shown in the Selection tab and in the cursor readout.
- The Selection tab has a header that stays visible while scrolling and shows what is selected: block, shot or volume, with its description and position.

## 1.0.2 (2026-09-24)

- Removed the "All" range from the k-space tab (Visible, Shot and Volume remain).
- Fixed: grouping volumes by a label (for example SET) again uses every ADC, as before 1.0.0. Since the ADC types were added, only imaging ADCs had been used, so files whose ADCs carry the NAV, REF or NOISE flag could lose their volume boundaries.
- Automatic volume detection falls back to all ADCs when a file has no imaging-type ADCs.

## 1.0.1 (2026-09-24)

- The k-space tab now opens on "Shot" instead of "All". A remembered "All" from version 1.0.0 is reset once.
- "All" and "Visible" draw at most 500,000 ADC samples and a 200,000-point path, and show a message while computing large ranges.

## 1.0.0 (2026-09-24)

- First versioned release. Earlier development builds were not numbered.
- Reads Pulseq 1.2 to 1.5, checks the md5 signature, and loads files of about 100 MB in a background thread.
- Diagram with RF magnitude and phase, gradients (separate or on one axis), slew rate, ADC events coloured by type, and a labels lane.
- Detects shots and volumes; block, shot and volume steppers keep the zoom when stepping.
- Inspector for blocks, shots and volumes; k-space in 2D and 3D, coloured by acquisition order or ADC type.
- Linked tabs (same time, shot or volume), settings kept between sessions, PNG export.
