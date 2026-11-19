# Project Ground Rules — 3D Printing OpenSCAD Models

## Standalone files only

Every `.scad` file must be **completely self-contained**.
- No `use <other.scad>` or `include <other.scad>` between project files.
- A `.scad` file defines its own parameters, derived variables, modules, and render logic.
- If a file was previously split (e.g. a "parent" and a "sliced" variant), merge the parent's geometry into the variant and delete the parent.

## File structure

A single `.scad` file contains:
1. **Header comment** — what the model is, coordinate system, units.
2. **Customizer parameters** — grouped under `/* [Category] */` comments.
3. **Derived variables** — computed from the parameters.
4. **Modules** — all geometry modules defined locally.
5. **Render section** — an `if/else` chain on a `part` variable.

## Part selector

The `part` variable controls what renders:

```openscad
part = "both";  // bottom | top | both | exploded
```

- `"bottom"` — lower half only (print orientation).
- `"top"` — upper half only (print orientation).
- `"both"` — assembled, for fit checking.
- `"exploded"` — pieces laid flat on the XY plane, arranged to fit a 270×270 mm bed, with a visible gap between parts.

## Exploded view layout

For two-piece models, the exploded view places both pieces **flat on the print bed**:
- Bottom piece: natural orientation (floor down).
- Top piece: upside-down (brim/flat-top down).
- Flat back walls face each other across a small gap (typically 5 mm).
- Curved fronts point outward to opposite bed edges.
- The layout must fit within a 270 × 270 mm rectangle centred at the origin.

## Design considerations

Consider the stresses a printed item may need to withstand (shear, tensile, compaction etc), and orient the
model accordingly. We must however try and avoid supports when printing if possible. If the stresses are
such that a single orientation will not suffice, then split the model into components that can be assembled.

## Columns at free wall ends

**A thin wall whose vertical edge ends free while it prints gets a column along that edge, the full height
of the wall.** Design it in from the start, along with the wall.

The reason is how a tall thin wall prints. It is held only at its foot and wherever it meets another wall.
Where two walls meet, each braces the other edge-on, so a corner doesn't move. A free end has nothing but
the thin wall behind it. As the wall grows, that end flexes away from the nozzle, each layer lands slightly off
the one below, and the edge drifts out of line toward the top. This was seen on the medicine tray: 1.6 mm walls
160 mm high flexed at their free ends, while their corners stayed true. The two bins printed without columns
drifted so far that they didn't fit their neighbours and had to be reprinted.

- **"Free" means free on the print bed, not in use.** A wall left open to lock onto a neighbouring part,
  which is common in models split to fit the bed, is a free end while it prints, even though it is closed
  once assembled.
- **Make the column deep across the wall.** Depth across the wall resists the flex, and stiffness grows with
  the cube of that depth. About 10 mm across, i.e. the wall plus about 8 mm standing proud, works. The
  medicine tray uses a 10 × 4.85 mm post.
- **Run it the full height, from the floor to the top.** A column that stops partway leaves the wall above
  it free again. Features that are banded to save time, such as joint rails, can stay banded, but the column
  can't.
- **Grow it from the bed or floor**, so it needs no support.
- **If the end carries a joint, the joint's post is the column.** Keep any channel a mating part slides
  through open for the full height, so the parts still assemble.
- **It is cheap.** On the medicine tray, two columns cost about 30 min and 5 g on a 4–6 h bin.
- **Check:** in the print orientation, every vertical wall edge either meets another wall or has a column.

## Reinforcing collars for tube sockets

**Any printed socket that grips tubing and carries real load gets a separate slide-on collar,
printed in a different orientation.** This is not optional and not a later refinement — it is the
only way to carry torque into a printed socket, and it must be designed in from the start.

The reason is layer adhesion. A socket is a box around the tube, and whichever of its walls lie
**parallel to the layer planes are whole layers**. Lever the tube sideways and those walls are not
bent, they are peeled off the stack in pure tension across the layer bonds — the one direction FDM
has no fibre in. Thicker walls and denser infill do not help, because the load is carried across the
bonds rather than along them. The tube itself is far stiffer than the bracket, so all of the torque
arrives at that interface.

A collar solves it by changing the direction of the material, not the amount:

- Print the collar **standing, closed-face down**, so its layers run perpendicular to the host
  part's. The bursting load then acts as **hoop tension, in-plane** for the collar.
- Size the bore to the socket's outer section plus ~0.15 mm per side, with a flared mouth.
- Cover the socket **mouth**, where the reaction from a levered tube peaks.
- **Bore corners must be SHARP, plus corner relief** (~1 mm). The section being slid over has sharp
  arrises; `corner_round` in a profile becomes rounded *edges running across* the collar, not
  rounded corners of the section. A rounded bore binds — verify with `intersection()` against the
  host part and require an empty result.
- Run the socket's self-tapper **through the collar as well**, so one screw pins collar, host and
  tube together and the collar cannot creep.

**Leave the collar somewhere to land.** A collar can only be fitted if the socket's outside has a
constant-section run reaching an open end. Gussets, webs and fillets crowding a socket's exterior
make it permanently unreinforceable — the collar simply cannot be slid on afterwards. Plan that
landing at the same time as the socket, before adding bracing.

## Mesh quality / resolution

Every `.scad` file MUST define global quality variables under a `/* [Quality] */`
Customizer block:

```openscad
/* [Quality] */
$fa = 1;   // Minimum angle — 1° gives max 360 facets per full circle
$fs = 0.4; // Minimum facet edge length (mm) — matched to a 0.4 mm nozzle
```

- **Do NOT set a global `$fn`.** It locks every circle to a fixed segment count
  regardless of size, producing faceted large curves and wasteful density on small
  holes. OpenSCAD picks the approach that produces the fewest fragments among
  `$fn`, `$fa`, and `$fs` — a low `$fn` cripples the adaptive pair.
- `$fa=1; $fs=0.4;` with no `$fn` is the correct default for FDM printing with a
  0.4 mm nozzle. It produces ~0.8 mm facets on a 90 mm diameter curve (glassy
  smooth) while keeping small features efficient.
- Local `$fn` overrides are allowed on specific features where a fixed polygon
  count is intentional (e.g. `cylinder($fn=6)` for a hexagon, `sphere($fn=24)`
  for a tiny rounding detail, or `$fn=24` on an M3 clearance hole).

## Slicer check (OrcaSlicer)

**Every model must slice cleanly in OrcaSlicer with its declared settings.** A face-angle check
is not enough: Orca also catches regions that start in mid-air over a void, cantilevers, and parts
that don't fit the printer, all of which a model can pass a 45° overhang check and still have.

- **Declare the print settings in the model.** Each `.scad` header carries one or more
  `// ORCA:` lines with shell-style `key=value` words, next to its printing notes:

  ```openscad
  // ORCA: printer="Qidi Q2 0.4 nozzle @Q2 0.4" process="0.20mm Standard @Qidi Q2"
  // ORCA: filament="SUNLU PLA+ 2.0 @Q2 0.4" brim_type=no_brim
  // ORCA: note="two-colour labels: filament change at layer 160.2 mm"
  ```

  `printer`, `process` and `filament` are preset names exactly as in Orca's dropdowns (the
  user presets are in `slicer/orca_q2_presets/`). Any other key is an Orca setting overridden on
  top of them, and the sliced G-code is checked to show it took. `note=` is printed with the
  settings. Leaving a key out gives the everyday default (PLA, `0.20mm Standard`).
- **Every export runs the check.** Each Makefile rule that writes a 3MF runs
  `orca_check.py <3mf> --scad <scad>` right after the export (see the root `Makefile`). It
  prints the presets, the estimated print time and filament, and Orca's verdict. Any Orca
  warning or failure fails the export, and the 3MF is deleted. A new Makefile must do the same.
  `CHECK=0` skips the check for a quick export; `make -j4` slices several models at once.
- **A model isn't done until it passes.** Fix the geometry rather than switching supports on,
  unless the design needs them; then say so with `enable_support=1` on the `ORCA:` line. A
  warning that is genuinely fine (e.g. a bridge the printer handles) can be accepted with
  `accept="<part of the warning text>"`, with a comment on the line above saying why.
- **Report the estimate** (time and filament from the check) when presenting a model or a
  change to one.
