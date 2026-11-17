# Plan: Medicine cupboard — one slide-out tray with 6 labelled compartments

Revised 2026-11-17 (walls 160 mm; single walls with dovetail joints). Model: `medicine/medicine_tray.scad`.
Build: in `medicine/`, `make` gives `bin_1.3mf` … `bin_6.3mf` (solid walls), `make hex` gives
`bin_1_hex.3mf` … `bin_6_hex.3mf` (hex-mesh walls), `make joint_test` gives `joint_test.3mf`, and
`make renders` gives `renders/*.png`. Repo ground rules: `../.github/copilot_instructions.md`.

## Goal

The user keeps medicine on one cupboard shelf, grouped by category. On a deep shelf the boxes at the back
can't be reached or seen. The fix is **one tray that slides in and out, divided into six compartments**, each with
a printed category label.

## Measured shelf (user-supplied, 2026-11-16)

| What | Value | Notes |
|---|---|---|
| Clear width the tray slides out through (door/hinges) | **360 mm** | The shelf itself is ~370 wide. |
| Usable depth | **565 mm** | Measured from the back wall. Nothing may protrude beyond it. |
| Height | **350 mm** | To the underside of whatever is above. |

Material: **SUNLU PLA**, printed with the normal profile (user, 2026-11-17). Printer: Qidi Q2, 270 × 270 bed,
256 mm Z.

## Decisions taken with the user (2026-11-17) — do not re-litigate

1. **One tray, six compartments.** No rails, no rack: the tray slides on the shelf on its own floor.
2. **Mesh floor, solid walls by default.** Mesh side walls take far too long to print. A hex-wall option exists
   so the user can compare filament and print time; it must never replace the solid default.
3. **A label tab at the top of each compartment** with the category printed on it (e.g. "Cold & Flu").
4. **Keep the filament down.** The earlier rack design (below) came to 3.3 kg and was rejected for that.
5. **Walls 160 mm high**, solid and hex alike (was 60).
6. **Every wall is printed once.** The bins lock together into a single tray; no wall is doubled where two bins
   meet.

## Design

- **Six bins, 2 across × 3 deep.** The 354 × 560 tray is far bigger than the bed, so each compartment is its own
  bin, printed floor-down with one bin per plate. Compartments are 174.6 × 184.5 mm inside.
- **Footprint:** 354 wide (3 mm door clearance each side) × 560 deep (5 mm spare). Height 160 + 0.6 mm text,
  leaving 189 mm headroom.
- **Walls:** 1.6 mm, every one printed once.
  - **Who owns which wall:** the left bins (1, 3, 5) own the centre wall, so the right bins (2, 4, 6) have no
    left wall. Every bin owns its front wall, so bins 1–4 have no back wall: the bin behind closes them. Bins 5
    and 6 own the tray's back wall. Bins 2 and 4 are left with two walls, bins 1, 3 and 6 with three, and bin 5
    with four.
  - `wall_style = "solid"` (default): plain walls.
  - `wall_style = "hex"`: every wall gets a hex mesh, 9 rows of holes 14 wide × 20.6 tall with 2.5 mm struts.
    It keeps 6 mm solid rails at the top and bottom, a 12 mm solid band at each wall end (it carries the
    joints), and solid wall behind the label tab. The holes have **45° roofs**, because regular hexes' 30° roofs
    would need support.
- **Joints.** These replace glued double walls. All 7 places where an open bin meets a neighbour's wall use the
  same two joints:
  - **Wall joint (10 of them):** each of the open bin's walls that ends against the neighbour finishes in a
    **post** (10.0 × 4.85 mm) with a dovetail **socket**. The neighbour's wall carries a dovetail **rail**
    (3 mm neck, 6 mm head, 3 mm deep) with a tapered lead-in at its top.
  - **Floor joint (21 of them, 3 per open side):** dovetail **keys** (5 mm neck, 10 mm head, 5 mm deep, floor
    thickness) stick out from the foot of the neighbour's wall into sockets in the open bin's floor. The floor
    keeps a 10 mm solid band along an open side to hold them.
  - Everything is vertical, so **a bin goes in by lowering it straight down** into place, and nothing stops it
    moving straight up again. A drop of CA on each floor key stops that. Sideways and pulled apart, the joints
    lock.
  - **Fit:** 0.25 mm clearance per side (`joint_clear`), which gives 0.56 mm of play when a joint is pulled
    apart. Sockets flare 0.4 mm at 45° at the bed, so the first layer's squish can't bind.
  - **Banded:** rails and posts run only 30 mm up from the floor and 30 mm down from the wall top
    (`joint_band`, 0 = full height). Each upper band grows out of its wall on a 42° chamfer. Small dovetail
    outlines on every layer cost far more time than their plastic: full-height joints made the tray slower to
    print than the old double walls (see the print list). Between the bands, a wall end simply butts against
    its neighbour.
- **Floor:** 2 mm, hex holes 14 mm across flats with 2.5 mm struts, inside a 4 mm solid band along the walls
  (10 mm along an open side).
- **Label tab:** a 110 × 16.6 mm ledge on the inside of each bin's front wall. It's flush with the wall top and
  carried by a 45° gusset, so it needs no supports. The gusset leaves the wall 143 mm above the shelf, so only
  boxes taller than that, standing right against the front wall, meet it. The category text is raised 0.6 mm
  above the wall top, reading from the front. A filament change at z = 160 prints it in a second colour.
  - Text is 8 mm high. Longer labels shrink to fit the tab, and an assert refuses any that would go below 5 mm.
  - Labels are `label_1` … `label_6` in the Customizer: front-left, front-right, middle-left, middle-right,
    back-left, back-right. **They're still placeholders** ("Cold & Flu", "Pain & Fever", "Tummy", "Allergy",
    "First Aid", "Vitamins").
- **Tipping:** a loaded tray slid out past about half its depth tips forward off the shelf. To reach the back
  row, lift it out from underneath, not by a wall.

## Assembly

1. **Print `joint_test` first** (15 min, 5 g). Slide the right piece down onto the left one: the rail should run
   through its socket, and the key drop into its slot, by hand, with no slop. If it's too tight or too loose,
   change `joint_clear` and print the test again **before** printing any bins.
2. **Dry-fit:** on a flat surface, stand bin 5 in its place. Lower each other bin into its place from above, its
   sockets over its neighbours' rails and keys. Any order works; 5, 3, 1, 6, 4, 2 is easy.
3. **Glue:** take the tray apart and rebuild it, putting a drop of CA on each floor key just before lowering the
   bin over it. A key only enters its socket in the last 2 mm, so no glue is dragged along a rail. Acetone does
   not weld PLA.

## Verification (2026-11-17)

- **Asserts:** door width, shelf depth and height, bed fit with a 5 mm margin for every bin including its keys
  (largest 182.8 × 192.7), printer Z, tab and gusset sizes, label length, dovetail shapes, socket walls, key
  band, keys clear of the corner posts, label tab clear of the posts, and joint bands that can't meet.
- **No supports:** all 12 bins (both wall styles) and the joint test have 0 mm² of overhang steeper than 45° and
  no flat underside above the bed. Each bin is a single shell; the joint test is two.
- **Fit**, by intersecting bins in place:
  - All 15 bin pairs meet with zero volume: they touch only face to face.
  - **Locks:** a bin slid 0.35 mm along its neighbour collides, as does one pulled away 0.66 mm. One pulled away
    0.46 mm doesn't, which brackets the 0.56 mm of play.
  - **Lowering:** bins 1, 2, 4 and 6 raised above their places by 0.3–159 mm (12 heights each, through every
    band crossing) never touch their owners, so each bin can be lowered straight in.

### Print list: filament and time (sliced)

OrcaSlicer 2.5.0-dev (the user's own build, CLI) with stock presets, each resolved through its full
inheritance chain: printer `Qidi Q2 0.4 nozzle`, process `0.20mm Standard @Qidi Q2`, filament
`SUNLU PLA+ 2.0 @System` (1.21 g/cm³, 12 mm³/s max flow). These are Orca's estimates for each bin sliced on
its own plate.

| Bin | Walls owned | Solid | Hex |
|---|---|---|---|
| 1 front-left | front, left, centre | 5 h 32 min, 208 g | 6 h 53 min, 126 g |
| 2 front-right | front, right | 4 h 20 min, 150 g | 5 h 13 min, 96 g |
| 3 middle-left | front, left, centre | 5 h 48 min, 210 g | 7 h 03 min, 128 g |
| 4 middle-right | front, right | 4 h 31 min, 151 g | 5 h 19 min, 98 g |
| 5 back-left | all four | 6 h 39 min, 261 g | 8 h 20 min, 145 g |
| 6 back-right | front, right, back | 5 h 31 min, 204 g | 6 h 53 min, 120 g |
| **Tray** | | **32 h 21 min, 1,185 g** (407 m) | **39 h 40 min, 714 g** (245 m) |

Plus `joint_test`: 15 min, 5 g.

How the joints compare, for the whole tray at 160 mm, sliced the same way:

| Design | Solid | Hex |
|---|---|---|
| Old: closed bins, glued wall to wall (double walls) | 36 h 11 min, 1,530 g | 47 h 51 min, 799 g |
| Single walls, full-height joints (`joint_band = 0`) | 36 h 54 min, 1,228 g | 43 h 14 min, 756 g |
| **Single walls, banded joints (default)** | **32 h 21 min, 1,185 g** | **39 h 40 min, 714 g** |

- **Single walls save 345 g (23 %) and 3 h 50 min on the solid tray**, and 85 g and 8 h 11 min on the hex one.
- **Hex walls save filament but cost time:** 471 g less than solid, 7 h 19 min longer. Each hole adds its own
  wall loop on every layer, plus travel and retractions.
- **The 12 mm³/s cap on SUNLU PLA+ 2.0 limits the walls** to about 143 mm/s. A max-flow calibration, followed by
  raising the cap, is the main way left to print faster.

## Superseded: two-tier lane rack (2026-11-16)

The first design had six pull-out lanes, three across on each of two tiers, in a fully printed lattice rack. It
was modelled and verified in `medicine/medicine_rack.scad`, which is kept for reference and has no Makefile
targets. It came to **3.3 kg** of ABS over 15 prints, and the user dropped it for this tray.
