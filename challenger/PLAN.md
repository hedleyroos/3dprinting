# Plan: Parametric OpenSCAD model of the 1973 Dodge Charger tail-light housing (user's LEFT light)

> **Superseded 2026-10-14.** Work restarted frame-first in `charger73_front_frame.scad`; see `FRAME.md`.
> The `bezel*` files referenced below show a different design and now live in `unrelated_bezel_model/`.
> Ignore them.

Prepared 2026-09-12 from the photos in this directory. Implement in a fresh session by following the steps below.

## Context

The user has an **original die-cast factory housing** on the bench (SAE marking "73", part-number line on the flat
panel) and wants a clean, fully parametric OpenSCAD model of it: renderable to STL, splittable into printer-bed
sections with alignment keys, mirrorable for the other side. Photos carry a 30 cm scale rule, so proportions are
ruler-calibrated; the user will replace the estimates with tape-measure readings now and caliper readings later
(calipers still to be bought, so small features stay estimates for a while).

Inputs in `/data4/projects/3dprinting/challenger` (read ALL of them before writing code):
* **Original**: `IMG_7441.jpeg` rear, lying face down, SAE text upright, plate end at left – *top of photo = top of
  housing*; `IMG_7442.jpeg` rear/side view standing on its long edge, rounded end at top; `IMG_7443.jpeg` plate end
  from above (J-curl visible); `IMG_7445.jpeg` front close-up of a lip bulge, stud hole and bulb; `unnamed.jpg`
  **front face**, rounded end at top, plate end at bottom, ruler at left.
* **Reproduction** (someone else's FDM print, sectioned/glued): `bezel001-013.jpg`; CAD renders of its modular
  design `bezelfile001-004.png`. Use only where the original is not visible (bowl interior shape, flat-bay holes).
  Its rear was simplified/wrong in places (square blocks, plain socket tubes, boss positions) – the original governs.

Orientation facts confirmed by the user:
* the **rounded end is OUTBOARD** (outer edge of the car); the **flat plate ("wing") end is INBOARD**;
* the harness exits at the TOP edge; the steel mounting tab and the text baseline are on the BOTTOM edge;
* the inboard plate curls toward the LENS side;
* the front rim under the black gasket is FLAT (no rail/rebate step);
* the raised lip is ONE loop around all four bays, with flat divider bands between bays;
* the 8 rear bosses take the lens's studs (nuts from behind); the gasket is only for waterproofing;
* the housing mounts to the car with the curled plate, the steel tab and a further screw tab.
* The user calls this the **left light** (left as seen from behind the car). The model reproduces this exact part;
  `side = "R"` mirrors it. Label files `L` per the user's usage.

Decisions taken with the user: full detail in v1; part selector + dowel keys; a Python virtualenv may be created.
Tooling: OpenSCAD 2026.06.12 at `/usr/local/bin/openscad` (manifold backend); Python 3 + PIL + numpy available;
create `/data4/projects/3dprinting/challenger/.venv` with `pillow numpy` for image work. Lives in the 3dprinting git
repo (moved from `/data4/projects/mopar` on 2026-10-14); `.venv/`, `*.stl` and `*.3mf` are git-ignored there.

## Geometry

Coordinate frame: **x = 0 at the inboard end of the body (plate root), +x outboard** toward the rounded end;
**y up**, y = 0 on the centreline; **z = front**, front rim plane at z = 0, shell extends to −z, plate curls to +z.
Default OpenSCAD view (from +z) shows the front. All mm.

Bay order from the inboard plate end: **bowl 1 | bowl 2 | flat bay | bowl 3 | rounded outboard end**.

Ruler-calibrated estimates (front photo ≈2.9 px/mm at the face, rear photo ≈2.75–2.9 px/mm). Every value is
`// est.` until the user replaces it:

| variable | est. mm | note |
|---|---|---|
| body_len (front rim, excl. plate) | 610 | 600–625 from the two photos; tape decides |
| body_h (front rim) | 140 | |
| rear_inset_end / rear_inset_side | 8 / 5 | walls are drafted: rear outline smaller, r ≈ 14 |
| r_out (outboard corners, front) / r_in (inboard corners) / r_rear | 60 / 15 / 14 | outboard end near-semicircular |
| rim_w side / inboard end / outboard end | 24 / 22 / 30 | flat band (gasket seat) from outer edge to lip |
| opening (inside lip) | 558 × 92 | derived |
| bays (widths, from inboard) | bowl1 141, bowl2 145, flat 110, bowl3 138 | dividers 10, 5, 5 |
| bay corner radius | 10 | bowl 3 outboard end follows the outer radius (~25) |
| lip_w / lip_h | 2.5 / 2.5 | |
| stud_x (lens studs, from inboard end) | 90, 250, 395, 540 | 4 positions × top & bottom = 8 |
| stud_y | ±50 (= opening_h/2 + 4) | hole sits in the rim band just outside the lip |
| stud_hole_d / bulge_r / channel_r | 6 / 13 / 13 | lip detours round the lens boss; channel runs down the bowl wall |
| boss_d / boss_h / boss_hole_d (rear, same x,y) | 12 / 8 / 6.5 | nut seats |
| shell_depth (rim → floor) / wall_t / floor_t | 45 / 3 / 3 | |
| bowl_depth below floor / bowl_curve | 55 / 1.3 | bell-shaped loft |
| socket_d / socket_pad_d / socket_notch_n | 27 / 45 / 2 | twist-lock socket, notches to measure |
| flat-bay holes | 2 × Ø6 at (cx ± 20, −15) | from the reproduction; verify on the original |
| plate (wing): ext / r / angle / tail / t / h | 35 / 15 / 90° / 10 / 3 / body_h | rectangular, curls to +z |
| steel_tab | at x ≈ 380 bottom edge, 20 w × 3 t, 33 rearward, Ø6 hole | |
| rear_bracket_x | bowl1/bowl2 and flat/bowl3 boundaries, 25 × 3 × 30 rearward | one has a screw hole |
| end_rib | vertical rib on the rear at the outboard end, 3 thick × 8 tall | |
| sae_text | `SAE STIAR 73 W 22 ★ CC` + part-number line, 1 mm raised, off by default | read exact text from IMG_7441 |

Feature inventory: drafted rounded-rectangle shell with flat rear floor; flat front rim band (gasket seat); one
raised lip loop with 8 semicircular bulges; 8 stud holes; flat divider bands; three lofted reflector bowls with
half-round stud channels; socket pad + keyed hole per bowl; flat bay with two holes, SAE text (optional), steel
tab; 8 rear bosses; two rear brackets; outboard end rib; inboard curled plate. Not modelled: gasket, lens, harness.

## Files to create (all in `/data4/projects/3dprinting/challenger/`)

* `charger73_taillight_housing.scad` – single file: PARAMETERS block (Customizer groups `[A fit – tape]`,
  `[B detail – calipers]`, `[C print]`), helpers, feature modules, `housing()`, `section(n)`, `main()`.
* `render.sh` – PNG views + full STL + per-section STLs + mirrored side via the openscad CLI
  (`--backend=manifold`, `--export-format=binstl`, `--summary=all` for bounding boxes).
* `MEASUREMENTS.md` – checklist below, one row per variable with a blank for the reading.
* `tools/photo_measure.py` – crops/zooms regions of the 5712-px originals and converts pixel distances to mm via
  the ruler (used to refine the table above; kept for new photos). `tools/stl_stats.py` – numpy binary-STL
  bbox/volume/triangle count.
* `renders/` – outputs; `.venv/` – python env.

## Construction techniques

* **2D helpers**: `rrect4(w,h,[r_tl,r_tr,r_br,r_bl])` = hull of four circles (different radii per corner);
  `slab(z){…}` = `translate([0,0,z]) linear_extrude(0.01)`; `stroke2d(path,w)` = hull of circles along a path;
  `arc(c,r,a0,a1)`.
* **Shell**: `hull(){ slab(0) front_outline(); slab(-shell_depth-floor_t) rear_outline(); }` minus the same hull
  of `offset(-wall_t)` outlines from z = −shell_depth up through the front → drafted walls + floor for free. The
  front opening is `opening_2d()` (= rrect4 shrunk by the rim widths, unioned with the 8 bulge circles) cut through
  the rim; the lip = `linear_extrude(lip_h) difference(){offset(lip_w) opening_2d(); opening_2d();}` so it wraps
  round the bulges automatically (see IMG_7445). Stud holes = cylinders at (stud_x, ±stud_y) through the rim.
* **Dividers**: flat bands between bays at z = −lip_h (recess level), full opening height, `divider_t` wide;
  thickened to `split_wall_t` where a print split lands.
* **Bowls** (`bowl_loft`): hull chain of N slices; slice t is a rounded rect interpolating (w,h,r) → (d,d,d/2) so
  the final slice is an exact circle and every slice is convex; z(t) = −shell_depth − bowl_depth·ease(t) with
  `ease(t) = 1 − cos(90t)` blended by `bowl_curve` (1 = straight cone as in the reproduction, >1 = fuller dome as on
  the original). Outer = grown by `wall_t`, inner subtracted after the union; the loft starts at z = −lip_h so it
  overlaps the rim. Stud channels = half-cylinders (`channel_r`) at the bulge positions, axis along z, from the rim
  down `channel_depth`, added outside / subtracted inside with the same grow trick.
* **Socket**: flat pad (`socket_pad_d`) at the apex + through hole `socket_d` + `socket_notch_n` bayonet notches;
  `socket_style = "tube"` keeps the reproduction's collar as an option.
* **Plate/wing**: plan-view centreline path `[[0,0]] + arc(...) + tail` in the x–z plane, `stroke2d` with
  `wing_t`, `linear_extrude(wing_h)` rotated so the path lies in x–z and the extrusion runs along y;
  `wing_bend_dir = +1` (toward the lens) selectable; root blended to the body's inboard end with a small fillet.
* **Rear fittings** from position lists: `boss(d,h,hole)` at the 8 stud points on the rear floor band;
  `steel_tab()` (L-shaped plate with hole); `rear_bracket()` ×2; `end_rib()`; `sae_text()` via `text()` (optional).
* **Assembly**: `housing()` = difference(union(shell, lip, dividers, bowls_outer, pads, plate, bosses, tab,
  brackets, rib, text), shell_inner, opening, bowls_inner, socket holes, stud holes, flat holes, boss holes,
  channels_inner).
* **Sides**: `side = "L"` as photographed; `"R"` → `mirror([1,0,0])`.
* **Print split**: `split_x = [bay boundaries]` → 4 sections (plate stays with bay 1); `part = "all" | 1..4 |
  "plate"`; `section(n) = intersection(housing(), cut box)`. **Keys**: `key_boss` blocks (8×8×24) on the inside of
  the top/bottom walls and two on the floor straddle each split; `dowel_d = 3.2 × dowel_l = 20` holes centred on the
  split plane are subtracted inside `housing()` so both halves get matching half-depth holes (3 mm filament or
  steel pins); optional `splice_plate` (40×20×4, two holes) as `part = "splice"`. `bed = 250` checked by echoing
  each section's extents.
* **Quality**: `$fn = $preview ? 32 : 96`, `bowl_slices = $preview ? 8 : 20`.

## Implementation steps

1. venv + `tools/photo_measure.py`; crop/zoom the originals (ruler ticks, lip line, bulges, bay edges, socket, plate
   J-profile, bosses, tab) and refine the table; read the part-number line.
2. Write the params block and 2D outlines; render the front as a flat plate and compare with `unnamed.jpg`
   (rotated so the rounded end is at the right) – fix bay ratios first.
3. Add lip, bulges, stud holes, dividers → compare with `IMG_7445` / `bezel006-008`.
4. Bowls + channels + socket pads → rear render vs `IMG_7441` (rotated) and `IMG_7442` silhouettes.
5. Plate, rear fittings, text → vs `IMG_7443`, `IMG_7441`.
6. Sections + keys; STL export (full L, full R, sections); bbox/manifold checks; MEASUREMENTS.md; render.sh;
   comparison sheet (renders beside photos) sent to the user via SendUserFile.

## MEASUREMENTS.md contents (variable ← reading)

**Tape now (A – fit on car and lens)**: body_len (rim, plate excluded); body_h at both ends; rear outline length
and height (draft); depth rim→floor, rim→dome apex, rim→socket tip; opening inside the lip L × H; lens outline
L × H; bay start/end positions along the front from the plate root (4 bays) and divider widths; the 4 stud x
positions and stud_y; plate: projection, height, curl start, curl radius (trace on card), tail, thickness, any
holes; outboard end radius (trace on paper); rim band widths (side/ends).
**Calipers later (B)**: socket hole dia, pad dia, notch count/width/depth, socket flange dia; boss dia/height/hole;
stud hole dia; bulge/channel radius and channel depth; lip width/height; wall thickness; steel tab and bracket
sizes; end rib; flat-bay holes (present? dia, positions); dome height per bowl.
**Photos still useful**: outboard end straight on; plate end from directly above with the ruler; bottom edge.

## Verification

1. `openscad --backend=manifold` STL export with no manifold warnings; `tools/stl_stats.py` bbox equals
   body_len × body_h × (shell_depth + bowl_depth + pad) within 1 mm.
2. Orthographic PNGs (front, rear, outboard 3/4, plate close-up) viewed beside the photos; iterate until the
   silhouettes and bay ratios match (bay edges within ±2 % of body_len).
3. Sections 1–4: bbox ≤ bed on X and Y; echoed dowel-hole coordinates identical on both sides of each split.
4. `side = "R"` is the exact x-mirror (bbox x-range negated).
5. Preview render time stays interactive at preview `$fn`.

## Out of scope (follow-ups)

Lens/bezel grid model; gasket; harness clips; precise bayonet geometry until calipers arrive; other-side-specific
differences if the other original is not a true mirror.
