# Seqret changelog

All versions, newest first. The About dialog of the page shows the latest 3.

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
