# Seqret changelog

All versions, newest first. The About dialog of the page shows the latest 3.

## 1.42.2 (2026-11-08)

- ROTATIONS extension: a gradient that continues from a rotated block into the next (EPI blips split across readout blocks) now keeps its value at the block end. Before, the rotated waveform got an extra vertex 1 ps after the block end with the value 0, and vertex times of different events were compared exactly, so an event ending at 0.0006599999999999999 s was 0 at another's end at 0.00066 s. The diagram drew a spike to 0 at every such joint, and for about a third of block durations the Sequence tab's peak slew was that jump over 1 ps (up to 2.7·10⁹ T/m/s instead of 133 T/m/s in the test). Vertex times are now snapped to 0.1 ns and the rotated waveform is kept inside its block. k-space, the image simulation, stimulation and the concomitant lanes were not affected (k within 10⁻¹⁶).
- Sequence tab, Gradient peaks: each amplitude and slew value is a link to the first block that reaches it (selects the block and zooms to it).
- Selection tab: the shot and volume cards list the peak gradient amplitude and slew per physical axis over the whole shot or volume, each a link to the first block that reaches it. Before, a selected shot showed only the event cards of its first block (in the demo, the excitation: RF and Gz), which read as if the shot had no x or y gradients; that block's heading now says it is the first block of the shot or volume.
- Checked: new regression test (tests/rot_edge: a rotated 660 µs block, a label-only block and a continuation block, and 971 block durations from 300 µs to 10 ms); the demo, the demo rotated 45° about y, and the 11-stack and 3D-slab tests give the same peak gradients and slews, and k within 1.1·10⁻¹⁶ of its maximum.

## 1.42.1 (2026-11-07)

- Rotated slice stacks: an image now uses only the shots whose excitation has the same frequency and the same slice orientation. Before, the frequency alone decided, so stacks rotated with the ROTATIONS extension, which reuse the frequencies of the unrotated stack, were combined into one image when they fell in the same volume. In a test with four stacks at 0°, 45°, 90° and 135° about y, six of eight images combined two orientations; in the 11 rotated stacks test, all 11 stacks were one image. The same rule now holds for the image list of a selection, the image colours of the k-space tab's all-readouts view, the other slices of the stack in the 3D view, and the TR used for T1 saturation (the time to the previous excitation of the same slice; before, it could be an excitation of another orientation: 0.1 s instead of fully relaxed for the 11 rotated stacks).
- The FOV definition is read in the sequence's own (logical) axes. The image's readout and phase directions are turned back through the rotation of the readout block, or, when the readout is rotated by hand in a shot whose excitation carries the ROTATIONS extension (as MATLAB sequences that rotate only some blocks with the extension write), through the excitation's rotation if that brings the readout onto a logical axis (within ~5°). Before, the definition was compared with the rotated directions, so an oblique readout, between x (220 mm) and z (a 20 mm slab), had no prescribed FOV: the image showed the whole oversampled readout (447–632 mm) uncropped and Crop to FOV did nothing. Gradients rotated by hand throughout (no extension anywhere) are read as before. The phase-encoding line statistics read the definition the same way.
- Checked: the demo and the 3D slab test give bit-identical images, line statistics and slice lists; the four-rotation test now gives 220 × 220 mm images at 2.05× readout oversampling for every rotation; browser tests pass.

## 1.42.0 (2026-11-07)

- Pulseq binary files (.bin, written by MATLAB Pulseq's seq.writeBinary, format 1.5.2) open like .seq files: Open, drop or Reload. Their md5 signature is checked. Shape samples in a binary file are single precision. A custom label (mr.addCustomLabel) has no name in a binary file; it is shown as LABEL<number>, with a note.
- Arbitrary gradients sampled at the raster centres are drawn as MATLAB Pulseq draws them (mr.restoreAdditionalShapeSamples): where the samples imply a corner on a raster edge, as for a trapezoid or a free waveform given as samples, or a trapezoid added to an arbitrary gradient (mr.addGradients), the corner is restored instead of being cut by a straight line between the samples. The line was off by slew·Δt/4 at each corner (0.25 mT/m at 100 T/m/s), which also changed the slew lane there, the area slightly, and the peak where a corner is the peak (a triangle); the restored waveform has exactly the area of the samples. Curved shapes such as spirals are unchanged. Everything computed from the gradients follows: k-space, b-tensor, echoes, concomitant lanes, stimulation.
- Labels: in a block that both sets and increments a label, every LABELSET is applied before any LABELINC, as the Pulseq specification and the scanner do, whatever their order in the file. Before, they were applied in the order of the extension list, which MATLAB Pulseq writes in reverse, so addBlock(adc, SET LIN 5, INC LIN 1) gave LIN 5 instead of 6. (MATLAB's own evalLabels and plot have the same problem.)
- Files in format 1.4 and older, which do not store where an arbitrary gradient starts and ends: these values are now found as MATLAB Pulseq's read does: the start from the end of the gradient on the same axis in the previous block, the end by restoring the raster edges. Before, both were extrapolated from the first and last two samples. For a gradient that continues from one block into the next, the two differ by up to 0.3 % of the peak at the joint (in the test, MATLAB's estimate is 0.14 % from the true value, the old one 0.48 %).
- Checked against MATLAB Pulseq 1.5.2 (run in Octave) with new reference tests (tests/matlab, tests/compare_matlab.mjs): gradients within 2.6·10⁻⁷ of the peak and k within 6·10⁻⁸ of its maximum on sequences with corners, rotations, RF shims, soft delays, custom labels and ADC phase modulation (before: 1.2·10⁻² and 2.6·10⁻⁴); a v1.4.1 file within 2.2·10⁻⁷ (before 2.4·10⁻³); a .bin file and its .seq file give the same blocks and timing, gradients within 2.2·10⁻⁷ and k within 1.2·10⁻⁷.

## 1.41.0 (2026-10-31)

- Echo markers, switched under Display › Echoes: spin echoes (▼), gradient echoes at k = 0 (●) and the other gradient echoes along the readouts (○). In the diagram they sit at the top of the RF lane, spin echoes in one row and gradient echoes in the row below, so a spin echo and a gradient echo at the same time line up. Hovering a marker names it, gives its time after the excitation and, for a spin echo, how far the nearest k = 0 gradient echo is from it (and the reverse); for an echo on another line, |k| there. By default they are drawn only while the view covers at most 4 shots (Only when zoomed in); without it, new shots are computed within 12 ms per frame, so zooming out stays responsive.
- k-space tab: the same markers on the trajectory, where each echo lies in k-space: a spin echo off the centre shows a mismatch between the spin echo and the k-space centre. Gradient echoes follow the kind of readout shown (imaging, reference, navigator); at most 400 shots are marked.
- Spin echoes: where the dephasing time τ returns to zero; τ starts at the excitation and changes sign at each refocusing pulse, at the pulses' centres (2·t₁₈₀ − t₉₀ for a Hahn echo, each echo of a train). Stimulated and secondary echoes are not marked. Gradient echoes: only during readouts (not noise); along a straight readout, where the k component along the readout crosses zero, solved exactly (it is quadratic between gradient vertices); k = 0 when the rest of k is zero too (within 10⁻⁴ of the largest |k| at the readouts' ends). A curved readout (spiral) has only k = 0 echoes, where k comes to zero in its block, e.g. where a spiral-out's gradient starts.
- Checked against separate calculations from PyPulseq (own k integration of its gradient waveforms on a grid of at most 0.5 µs, readouts from its ADC times, zero crossings by interpolation): the demo, an oblique SE-EPI, a gradient echo and a turbo spin echo give the same 22 spin echoes, 52 k = 0 and 540 other gradient echoes, with times within 0.04 ns. 10,240 shots take about 0.12 s.

## 1.40.0 (2026-10-31)

- Hovering a row of the labels lane shades that row across the whole diagram, from its name in the margin to the right edge, so a label is easy to pair with its values (and the values the cursor shows for it). It follows the mouse in the margin too, and is off while panning.
- In the side tabs, hovering a name or a value shades the whole row from name to value (all name–value lists, e.g. the label counters in the Selection tab). The spacing between rows and columns is unchanged; it is now padding, so the shaded row is one band.

## 1.39.0 (2026-10-31)

- b-tensor per shot in the Selection tab (shot card): the b-value, the 3×3 b-tensor in the scanner's x, y and z, and its eigenvalues, in ms/µm². B = (2π)² ∫ k kᵀ dt from the excitation to the echo, the readout sample closest to k = 0 in the shot's first echo, with k reset at the excitation and mirrored at each refocusing pulse as in the k-vector lane. All gradients count (diffusion, slice selection, crushers, readout prephasers), so cross-terms with the imaging gradients are included. A shot with only reference readouts uses those; a multi-echo shot says how many echoes it has. Hover the row names for the definition.
- The integral is exact: k is quadratic between gradient vertices and RF centres, so k kᵀ is integrated with 3-point Gauss–Legendre on each piece. The image simulation's b-value is now the trace of this tensor (before, 25 points per block, within 5·10⁻⁵ for diffusion-weighted shots and 2·10⁻³ for b ≈ 0).
- Checked against separate calculations from PyPulseq's gradient waveforms (own k integration with PyPulseq's excitation and refocusing times) on five sequences: the demo, a spin echo with one diffusion pair along (1, 2, 2)/3, an oblique slice-selective SE-EPI with two orthogonal diffusion pairs, a gradient echo with a bipolar gradient and a turbo spin echo. The tensors agree to 1.4·10⁻⁷ of b, the eigenvalues to 1.5·10⁻⁷, and the echo is the same readout sample as PyPulseq's nearest to k = 0 in every shot (22 of 22). The single pair matches the Stejskal–Tanner b for trapezoids, b n nᵀ, to 10⁻¹⁵.

## 1.38.0 (2026-10-27)

- Concomitant gradients, in a new Concomitant row of the Display panel. Lane Gc is the gradient that spins at a chosen position r see on top of the nominal one, ∇|B| − g, from the full field of the gradient coils (Bz = B0 + g·r, Bx = gx z − a gz x + f y, By = gy z + (a − 1) gz y + f x) rather than its second-order expansion, with x, y and z in the gradient colours. It is computed in a form that avoids subtracting two nearly equal numbers, [v p + w q − g (p² + q²)/(Bd + N)]/N: against a 60-digit reference it is accurate to 2·10⁻¹⁵ of Gc, where taking ∇|B| − g directly loses about 5·10⁻¹⁰.
- Lane kc: the zeroth moment ∫Gc dt (1/m), the k-space shift of the spins at r. It is reset at each excitation and sign-flipped at each refocusing pulse like the k-vector, and veiled outside the stretches from an excitation to its last readout.
- Lane Maxwell μ (chip μ): the generalized Maxwell index μ(t) = (γ/B0)|∫g⊗g h dt|, the Frobenius norm of the running integral of the gradient's outer product, in 1/m² with γ = 42.58 MHz/T. It is reset at each excitation, and h flips sign at each refocusing pulse. The six distinct components of the integral are computed exactly (the gradients are piecewise linear); the lane is drawn through up to 24 points per gradient stretch. μ depends only on the gradients and B0, and is the same for the physical and the logical gradients.
- Settings… (in the Concomitant row, or ⋯ › Concomitant gradients…): the position r (default (5, 6, 7) cm), B0 (3 T), the asymmetry a of the z coil (0.5) and a non-Maxwell term f (0 T/m), kept in this browser. Computed from the physical (rotated) gradients, taking the sequence's x, y and z as the scanner's, with B0 along z. f is constant in time, so with f ≠ 0 Gc is not zero where the gradients are off and kc keeps changing in pauses; the dialog says so.
- With the lanes on, the cursor readout gives Gc, kc and μ, the Selection tab the peak Gc of a block and kc at its end, and the Sequence tab the peak Gc and the largest |kc| in blocks with a readout.
- Display panel regrouped: Gx, Gy, Gz and One axis on one row, Slew and k-vector below them, then the gradient unit; Gc, kc, μ and Settings… in the new Concomitant row.
- Save figure… and Save diagram as PNG include the new lanes (Lanes in the figure dialog). In a figure, lanes too low for the unit on its own line before (k-vector, Gc, kc and μ at the default size) now keep it under the name, with the x y z legend after it; the gutter widens to fit.
- References in the dialog and under About › Acknowledgements: Olsson V, Mortensen F, Ljungberg E, Testud F, Wirestam R, Molendowska M, Szczepankiewicz F. Concomitant gradient effects across field strengths and gradient amplitudes: improved estimation of errors and correction of concomitant dephasing and diffusion weighting. Magn Reson Med 2026;96(3):1178–1191, doi:10.1002/mrm.70422; and for the field model Bernstein MA, Zhou XJ, Polzin JA, et al. Magn Reson Med 1998;39(2):300–308, doi:10.1002/mrm.1910390218.
- Checked against separate calculations from PyPulseq's gradient waveforms (sampled every 0.25 µs, integrated with PyPulseq's excitation and refocusing times) on four sequences, one of them rotated: kc agrees to 4·10⁻⁷ of its largest value over three settings including f ≠ 0, the drawn Gc lane to 0.1 %; μ agrees to 3·10⁻⁷, the drawn μ lane to 2.3·10⁻⁴. The k-vector now shares its code with kc and μ and is unchanged, bit for bit (750,430 values compared with 1.37.0).

## 1.37.0 (2026-10-02)

- Save figure, diagram: traces are drawn as one line of even width everywhere (steep ramps and readout trains were thinner than the rest), with the line width chosen in pt.
- Y axes with round values: each lane's scale goes up to the next round value above its peak (58.3 mT/m: 60; 19.3 µT: 20), with an axis line and ticks at round steps (e.g. 0, ±30, ±60), as many as fit; the time axis has a title, Time (ms). The coloured bars beside the lanes are left out.
- New options: gradients on one axis or a lane each (independent of the screen), fill under traces on or off, font (Arial, Helvetica, Times or the system font). Block shading stays its own switch.

## 1.36.0 (2026-10-02)

- Save figure… (Display menu, and next to Save as PNG in the k-space and Image tabs): a PNG of the sequence diagram, k-space or simulated image for publications. Choose the printed size (mm or inches, with column-width presets), the resolution (dpi) and the text size in points at that size; lines and marks scale with the text. The PNG carries its resolution, so layout programs place it at the chosen size.
- Contents: for the diagram the lanes (independent of the screen), the volume and shot strips, time axis, lane names and units, value ranges, block numbers, block shading, selection and pause hatching; for k-space the path, axes, |k| range, legend and group boxes; for the image the text, directions, scout, cropping to the image and sharp pixels. Colours from any theme (e.g. Paper while working in Dark), with the theme's, a white or a transparent background, and optionally the Seqret version, file and date below. The figure shows the current view (time range, k-space view, image).

## 1.35.1 (2026-10-02)

- Selection colour (selected volume, shot or block) toned down in the newer themes: warm grey in RedZ, muted ochre in Paper, soft yellow in Universal, sage green in Forest.
- Forest is a little brighter (background, panels, plot and grid lines).

## 1.35.0

- *No notes were kept for this version.*

## 1.34.0 (2026-10-02)

- Multi-echo sequences (several images per excitation, e.g. multi-spin echo): the k-space arrows show each echo's readouts separately (Imaging readouts, echo 1, echo 2, …), each with its own trajectory, and the last view, all readouts by type, gives each echo's image its own colour. Echoes are found from the ECO label, or else from the k-space lines: readouts at the same position in each shot that cover the same lines are echoes of separate images, also when a refocusing pulse mirrors echo 2 onto the opposite line. Turbo spin echo and EPI trains stay one image.
- All readouts by type: where samples of two images lie on each other (echoes or slices covering the same k-space), their colours mix half and half, so the overlap shows; a lone image keeps its full colour. Dots are sized by the largest image rather than all samples together, so overlapping images do not shrink them.
- The image tab uses the same echo detection (a multi-spin echo without ECO label was one image before), and the phase-encoding line statistics are per echo, in both tabs.

## 1.33.6 (2026-10-02)

- k-space: the Colour option (acquisition order or ADC type) is gone. The arrows above the plot are always shown and step through the kinds of readout (imaging, reference, navigator, noise), each coloured by acquisition order; the last view shows all readouts together, coloured by type (and imaging by image). With one kind of readout, the arrows switch between it and that last view.

## 1.33.5 (2026-10-02)

- Slew rate: the trace no longer runs diagonally from the end of a ramp to the next event, as it still did in 1.33.4 at some zoom levels, e.g. right before and after the 180° pulses of the demo. Where a ramp ends at its block's end, the rounding of the two blocks' edge times could put the zero after the ramp before the ramp's last value in a pixel column, in exact peaks mode. Slew is now zero whenever the gradient is constant or off.

## 1.30.2 – 1.33.4

- *No notes were kept for the versions between 1.30.1 and 1.33.5.*

## 1.30.1 (2026-10-01)

- Fixed: with the Image tab open, Ctrl+clicking a second volume did not outline its slices in the 3D view until another image was chosen with the arrows. The image shown stays the same, so the cached result was reused with the selection it was computed for. The 3D view now always uses the current selection and is redrawn when it changes.

## 1.30.0 (2026-10-01)

- Volumes and shots: a click on a bar above the diagram selects it without zooming; a double-click zooms to it.
- Stepping through volumes or shots (arrows, steppers) keeps the zoom and keeps the left edge of the selected item where it was on screen, instead of centring the next one.
- Several volumes or shots can be selected: Ctrl+click (Cmd+click on a Mac) adds or removes one, Shift+click selects the range from the last clicked one, Ctrl+Shift+click adds that range. Arrow keys step from the focused one and select it alone.
- Image tab: when the selection holds several images (several slices of a volume, or several volumes or shots), arrows step through them ('Image 2 / 6 · volume 3 · shot 14'); the echo arrows stay as before. The 3D view outlines the slices of the other selected images with dashed lines, numbered as in the arrows, so fields of view in other positions or orientations (e.g. rotated stacks) are seen together. The outlines are drawn on top of the phantom (tissue in front does not hide them). Their planes equal those of the simulated images to within 4e-13 (checked on 11 rotated stacks, oblique slabs and the demo).

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

- Fixed: the simulated image of a slab-selective 3D scan was taken in the plane of the readout and the slab normal (e.g. 64×8 pixels for a 64×64×8 scan) whenever the partitions spread k-space about as far as the phase encoding, which was the case for 8 to 64 partitions. The slab normal (the gradient during the excitation) is now never an image axis, so the image lies in the readout × phase-encoding plane, also for oblique slabs. Checked on slabs rotated 20° about x and y, 35° about z and 90° about x: the image axes are perpendicular to the slab normal to within 1e-6. Images of 2D sequences (demo, rotated stacks, EPI, spiral) are unchanged, bit for bit.
- Frame-rate test: the two cases that drew the rectangles as one path are gone. They showed in 1.16 that single rectangles are faster on real graphics cards. The peaks comparison stays until exact peaks are confirmed on real hardware.
- Unused code removed (the 2D phantoms replaced by the 3D ones, and some unused functions and variables). The page is 4 kB smaller and behaves the same.
- Development package: a script compares waveforms, RF shapes and k-space with PyPulseq on its 31 test sequences (all agree to within 1e-6 relative, most to 1e-7), and the browser tests check settings, their migration, the diagram qualities and peaks, the side panel, stepping and linked tabs.

## 1.24.2 (2026-09-29)

- Frame-rate test: the suggestion blames Seqret's own work only when it takes most of what the screen allows per frame (80 % of a blank diagram's frame time). Before, it compared Seqret's time with the slow frame itself, so on a wide window at 100 Hz (Seqret 5 ms, frames 10–20 ms, the rest the browser's drawing) it wrongly said Seqret was the limit.

## 1.24.1 (2026-09-29)

- A button at the right end of the toolbar (or the \ key) hides the side panel with its tabs, so the diagram fills the width of the window; pressing it again brings the panel back. The choice is remembered. While the panel is hidden, the k-space and the simulated image are not recomputed as the view moves; they update when the panel is shown again.

## 1.24.0 (2026-09-29)

- Less blocky waveforms when zoomed out: Display › View › Peaks › exact (new default). Each pixel column now also keeps the times of its first, minimum, maximum and last value, and short features (RF pulses, ramps, crushers; stretches of fewer than 24 dense columns) are drawn through their extremes at the times they happen, as a line. An RF pulse a pixel or two wide is now a thin pointed spike instead of a flat-topped bar a column or two wide. This is the M4 method: Jugel U, Jerzak Z, Hackenbroich G, Markl V. M4: A Visualization-Oriented Time Series Data Aggregation. PVLDB 2014;7(10):797–808.
- Checked against a drawing of every vertex at its own time: on the demo in full view 2.0 % of pixels differ from it (3.4 % before), zoomed in 0.01 % (0.8 % before). Long dense stretches (readout trains, a ZTE sequence) are drawn as before, which keeps them cheap; the frame rate is unchanged in a test browser (demo, a spiral and a 40,000-block ZTE-like sequence).
- Peaks › per column gives the previous drawing, pixel for pixel, for comparison; the frame-rate test compares the two.
- Fixed (from 1.22.0): without saved settings, Display › View › Quality showed 'ultra' although the diagram was drawn in high (the default).

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

- Faster k-vector lane again, after the reset change of 1.22.2 made it slow: breaking the curve at every excitation turned each spoke of a ZTE sequence into a ramp that had to be stroked as an anti-aliased line (tens of thousands of pixels of line per frame, at medium zoom). The k-vector is now drawn only with rectangles: one opaque rectangle per pixel column and stretch of the curve, from the lowest to the highest point the curve reaches there (its samples, the column's summary, and where its lines cross the column's edges), at least a line wide. Resets still start the curve anew.
- Measured on a 40,000-block ZTE-like sequence in a test browser, the frame rate with the k-vector on now equals the rate without it at every zoom level tried (full view to single spokes; before: half at medium zoom). Sloped stretches look slightly more stepped than an anti-aliased line; ultra quality smooths them.
- The k-vector's per-block data is now kept for up to about a million vertices instead of 4,096 blocks.

## 1.22.2 (2026-09-29)

- k-vector lane: at an excitation the curve starts anew at zero instead of being joined to it by a line from the last k-position; the reset is a jump, not a path through k-space. Where one pixel column holds both sides of the reset, it is split there: the part before is drawn up to the reset, the part after starts from zero. Zoomed far out, where one column holds whole spokes, the column's range still spans both. The sign flip at a refocusing pulse is still drawn as a vertical line.

## 1.22.1 (2026-09-29)

- Fixed (from 1.22.0): the k-vector lane showed broken lines, correct only when zoomed far in. To save drawing, 1.22.0 left out every line between two pixel columns that each have a solid min–max rectangle, but such a line is only redundant when it passes from one rectangle into the other; elsewhere it is the curve itself (a ramp across a few columns, a flat stretch between readouts). Now a line is left out only between neighbouring columns and only where it runs inside both rectangles. Checked on the demo and on a 40,000-block ZTE-like sequence at several zoom levels against 1.20.0; the cost stays as in 1.22.0 (12–15 fps with the k-vector on in full view in a test browser, 15 fps without).

## 1.22.0 (2026-09-29)

- The k-vector lane now costs no more than the gradient lane: on a 40,000-block ZTE-like sequence in full view, turning it on took the frame rate in a test browser from 15 to 3 fps in 1.20.0 and 9 fps in 1.21.0; now 12–15 fps. Three causes, all fixed: (1) the traces were faded outside the active stretches with clip paths or an extra image; they are now drawn at full strength, and the stretches outside the active ones (after the last readout) are marked by a pale veil over the lane's background instead. (2) Dense stretches of the k-vector are drawn as one opaque rectangle per pixel column from minimum to maximum, without the half-transparent band and its edges. (3) Lines between neighbouring columns that those rectangles already cover are left out; they were thousands of long strokes per frame.
- The per-block k-vector summaries are kept after they are first computed; before, a sequence with more than 4,096 excitations recomputed them while drawing.
- Lines and rectangles are limited to the lane's rows as they are built (exactly, inside the lane), so values far outside a lane's scale no longer make the browser draw very long shapes.
- Display › View › Quality › ultra: two columns per screen pixel, drawn anti-aliased, for the smoothest waveforms when zoomed out on computers that draw fast. Its cost grows with the file: on the ZTE-like sequence it took Seqret's time per frame from 12 to 69 ms in a slow test browser (high stays the default). The frame-rate test compares it with the other qualities.

## 1.21.0 (2026-09-29)

- Faster k-vector lane. Its traces were drawn twice, once at full strength clipped to the active stretches and once pale clipped to the rest, and with many active stretches (every spoke of a ZTE sequence) the clip paths held thousands of rectangles, which every one of the many drawing calls had to pass through. The traces are now drawn once into a lane-sized image, faded outside the active stretches, and copied onto the diagram. On a 40,000-block ZTE-like sequence in full view, in a slow test browser: Seqret's time for the lane 163 → about 20 ms per frame, the whole frame 350 → 150 ms. The look is the same (0.6 % of pixels differ slightly in shade).
- What remains is the cost of drawing three dense traces, as in the gradient lane: zoomed out on such a file each lane draws about 25,000 rectangles per frame.

## 1.20.0 (2026-09-27)

- Open .seq starts in the folder of the last opened file, also after the browser is restarted (Chrome and Edge; the file's handle is kept in the browser's storage, which gives no access to the file by itself). Files opened by dragging them onto the page count too.
- Display panel regrouped: one row per kind of channel with its settings next to it — RF (|B1|, phase, unit, shown as), gradients (Gx, Gy, Gz, slew, k-vector, unit, one axis), readout (ADC, labels) and stimulation (PNS, CNS, L2 norm, specifications); fit Y and quality under View.
- Removed the time-weighted fill of dense waveforms (1.19.0): it added little and was slow on large files. The frame-rate test keeps the improved suggestion from 1.19.0.

## 1.19.0 (2026-09-27)

- Display › Dense waveforms › time-weighted fill (option; the default stays min/max band). Where the waveform goes back and forth within a pixel column, each level is shaded by the fraction of the column's time the waveform spends at that level or beyond it (further from zero). A readout train that spends half its time at +G and half at −G shows as two smooth blocks at half strength, and levels passed only briefly stay faint; the opaque min/max edges are kept, so extremes stay visible. Smooth stretches that are merely finely sampled (free waveforms) stay lines, so the fill marks oscillation, not sampling density.
- The fill is computed exactly from every segment under the dense stretches, per frame. With more than 10,000 blocks under them in a lane (large files zoomed out), the band is drawn instead, decided from the view alone. In a slow test browser it took about 20–45 ms per frame on the demo and a 7,600-block file, several times the band's cost; the frame-rate test includes a case comparing the two.
- Frame-rate test: the suggestion no longer blames the browser when Seqret's own work is most of the frame; it then says so, notes that zooming in helps, and lists the lower settings that were faster.

## 1.18.1 (2026-09-27)

- Frame-rate test: the suggestion now tells apart the two limits. When Seqret's own work takes most of the frame (large files zoomed out), it says so instead of pointing to the browser's renderer; it points to the renderer only when the frame takes much longer than Seqret's work.

## 1.18.0 (2026-09-27)

- Smoother waveforms when zoomed out: Display › Diagram quality › high (new default) draws the waveforms with one column per screen pixel at every zoom level. Dense stretches keep their shape: RF pulses are drawn at their true width instead of as blocks, and readout trains and ramps are finer. Before, zoomed out used one column per CSS pixel, 1.75 to 2 screen pixels wide on high-density screens. On 1× screens nothing changes.
- Diagram quality replaces diagram resolution: high (new), standard (the drawing of 1.14.2–1.17.0) and fast (standard at 1× pixel density, as 'fast' in 1.17.0). A saved 'sharp' becomes high. Cost of high when zoomed out: up to about twice Seqret's time per frame on small files (3.6 → 8.1 ms on the demo in a slow test browser) and 15–30 % more on a 45,000-block file, plus more rectangles for the browser to draw. Zoomed in, and on 1× screens, high and standard are the same.
- Frame-rate test: compares the current quality with the other two, and when drawing limits the frame rate, suggests the lower qualities with the rates they gave.

## 1.17.0 (2026-09-27)

- Display › Diagram resolution: sharp (default) or fast. Fast draws the diagram and the overview at 1× pixel density on high-density screens (a quarter of the pixels at 2×) and lets the browser scale them up, for computers or browsers where drawing limits the frame rate; lines and text are slightly softer. The cursor overlay, k-space and image stay sharp, PNG export is always at full density, and the setting is remembered. On a 1× screen it changes nothing.
- Frame-rate test: when the browser's drawing limits the frame rate (a blank diagram much faster than the normal one), the result says so and suggests the fast diagram resolution (with the rate it gave) and Chrome's Skia Graphite renderer. With fast resolution on, the test compares against full pixel density instead.

## 1.16.7 (2026-09-27)

- Frame-rate test: new cases that separate where the time goes: without page updates (cursor readout, steppers, legend), a blank diagram (nothing drawn, page still updated), a blank diagram without page updates (what the browser needs for an empty frame), and, on high-density screens, the diagram at 1× pixel density (a quarter of the pixels at 2×, same shapes).
- Seqret time now includes all of Seqret's work in a frame (the diagram, the overview, the cursor overlay, page updates and the k-space when shown), and the header says which tab was open.

## 1.16.6 (2026-09-27)

- Frame-rate test: the columns are named by quantity (frame rate, frame time, Seqret time), with their units (fps, ms) on a second header line. The frame-time panel says 'Seqret time' in the same way.

## 1.16.5 (2026-09-27)

- Fixed (from 1.16.4): in the Image tab, a rotated slice stack whose readout has no FOV in the definition had its phase-encoding axis 0.8 % too long (221.8 instead of 220 mm for 64 lines), because the line spacing was estimated from positions rounded to a coarse step. It is now the median step between the actual line positions, and the FOV definition is used for each image axis on its own, so the phase-encoding axis of a stack rotated about it gets its FOV from the definition.
- Checked across 11 stacks rotated about the phase-encoding axis: slice normals and positions exact, the pixel size the same in every stack, each image matches the phantom in the plane it claims to show (better than any mirrored or rotated version), and the profile along the phase-encoding axis through the isocentre, which lies in the central slice of every stack, agrees between stacks (correlation 0.992). Images of the demo, the PyPulseq test sequences and the stress sequences are unchanged.

## 1.16.4 (2026-09-27)

- Fixed: in the Image tab, slice stacks rotated so that their readout ran mostly along z were simulated a few pixels wide (64×8 instead of 64×64). The FOV definition gives the FOV along the sequence's x, y and z, and it was applied to the image axes by their nearest sequence axis, so such a readout took the slab thickness as its FOV.
- The FOV definition now applies to an image axis only when every sequence axis it has a component along has the same FOV (an axis along x, or any direction in the x–y plane when x and y have the same FOV, as for radial), and only when it agrees with the sampling: along the readout the sample spacing may be finer than 1/FOV (oversampling) but not coarser, across Cartesian lines it may be coarser (parallel imaging) but not finer. Otherwise the grid follows the sampling itself.
- Checked on the demo, the PyPulseq test sequences and the stress sequences: identical images to 1.16.3. A rotated-stack sequence (11 stacks rotated about the phase-encoding axis) is now a test case.

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

- New M0 lane (switch it on under Display): the zeroth gradient moment on x, y and z in the gradient colours, reset at each excitation and sign-flipped at each refocusing pulse (at the RF centres, as Pulseq's calculateKspacePP), from the physical gradients. It is shown at full strength from each excitation to the end of the last readout before the next one and faded elsewhere; a stretch without a readout is faded throughout.
- Units follow the gradient unit: mT·ms/m with gradients in mT/m, or 1/m (the same as k) with gradients in kHz/m. The lane scales to the largest moment in the visible active stretches, since moments differ by orders of magnitude between imaging, diffusion encoding and spoiling.
- The cursor readout shows M0 when the lane is on, and the Selection tab shows M0 at the end of the selected block.
- Checked against a reference built from PyPulseq (gradients, their integral and the RF times) over whole trajectories: agreement to 1e-7 relative or better, including a turbo spin echo with many refocusing pulses.

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

- Peripheral (PNS) and cardiac (CNS) nerve stimulation predicted with the SAFE model (Hebrank and Gebhardt, ISMRM 2000) as implemented in safe_pns_prediction by F. Szczepankiewicz and T. Witzel: two new lanes, switched on under Display, with x, y and z in the gradient colours, the L2 norm in grey (optional) and the 100 % limit.
- System specifications (Display panel or the ⋯ menu): load MP_GPA_*.asc or MP_GradSys_*.asc files (a file with $INCLUDE together with the file it includes), type the parameters in, or load the example hardware of safe_pns_prediction (not a real scanner). The parameters are checked as in safe_hw_check, compared with the library of known systems (SHA-256, as in safe_hw_verify), and kept only in this browser.
- Computed in the background over the whole sequence from the physical gradients on the gradient raster; the Sequence tab gives the peak of the norm and of each axis with a link to its time, block, shot and volume cards give their own peaks, and the cursor readout the values at the cursor.
- Checked against safe_gwf_to_pns running in Octave on five sequences (agreement about 1e-15 relative) and against PyPulseq's gradient waveforms.

## 1.10.0 (2026-09-26)

- Reload button (↻, key R) next to Open: reads the current file again and keeps the zoom, selection, history, tab and settings. The header says when it was reloaded, and whether the file had changed on disk.
- In Chrome and Edge, Open and drag-and-drop keep a handle to the file on disk, so a sequence rewritten by MATLAB or Python is picked up by Reload. Other browsers keep the file as it was given: Reload works while it is unchanged, and after a change asks for it to be opened again. The demo and files embedded by seqview.m have no reload.
- On narrow screens the Open button is labelled 'Open' so the header stays on one row.

## 1.9.0 (2026-09-26)

- Decluttered layout: above the diagram only the Volume, Shot and Block steppers and the zoom buttons remain; channels, units, shots and volumes rules and Save as PNG moved to a Display panel. New tab, linked tabs and the theme moved to a menu (⋯) next to Open .seq, which shows a green dot while tabs are linked.
- k-space and Image tabs: path, colours, the explanation and Save as PNG, and the simulation settings, are behind an options button. While folded away, the Image tab shows a one-line summary of the simulation settings; click it to open them.
- Floating panels close on a click outside or on Escape; keys pressed inside a panel no longer step or zoom the diagram.

## 1.8.0 (2026-09-26)

- Selection tab: RF blocks show the slice they select: slice gradient, normal and orientation, position from isocentre and slice centre (x, y, z), thickness (FWHM of the small-tip profile), bandwidth and time–bandwidth product, fat shift, and for pulses after the excitation (refocusing) the comparison with the excited slice, including the separation of the fat slices when the slice gradients have opposite signs. A warning when the gradient varies during the pulse.
- Pulseq 1.5 ppm frequency offsets (freqPPM) are now used: the total frequency at the Image tab's B0 is shown, and the simulation places ppm-specified pulses correctly. Before, a fat saturation written the PyPulseq 1.5 way (0 Hz, −3.45 ppm) saturated water instead of fat.
- Inversion recovery in the simulation follows the actual inversion cycle (all pulses acting on the slice until the next inversion, in the steady state). The previous formula could give a longitudinal magnetization above 1 (MPRAGE); it now agrees with a step-by-step calculation over the whole file.
- Pulse purpose inference and block descriptions treat a ppm offset as off-resonance.

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
