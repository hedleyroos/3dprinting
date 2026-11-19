# Plan: Medicine cupboard — one slide-out tray with 6 labelled compartments

Revised 2026-11-19 (bins 1 and 2 reprinted with end columns). Earlier: real labels from the user's medicine,
a 220 mm back-left bin for braces and end columns at free wall ends (2026-11-18); walls 160 mm, single walls
with dovetail joints, regular wall hexes. Model: `medicine/medicine_tray.scad`.
Build: in `medicine/`, `make` gives `bin_1.3mf` … `bin_6.3mf` (solid walls), `make hex` gives
`bin_1_hex.3mf` … `bin_6_hex.3mf` (hex-mesh walls), `make joint_test` gives `joint_test.3mf`, and
`make renders` gives `renders/*.png`. Each 3MF is sliced by OrcaSlicer as it's exported, with the presets
on the `// ORCA:` lines in the model's header, which prints its time and filament and fails on any slicer
warning. Repo ground rules: `../.github/copilot_instructions.md`.

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
7. **Wall hexes match the floor's:** regular 14 mm hexes, never stretched to fit a wall. The first stretched
   ones (14 × 20.6 mm) looked elongated next to the floor.
8. **Labels (2026-11-18)** come from photos of the user's actual medicine, not
   placeholders. "Cold & Flu" was kept as it was, on bin 1 (front-left). See *Compartments* below.
9. **Braces get a tall bin at the back (2026-11-18):** elbow braces and other supports are bulky, so the
   back-left bin's walls are **220 mm** (the rest stay 160).
10. **Bins 1 and 2 are reprinted with end columns (2026-11-19).** They were printed first (2026-11-18), with
    their posts banded like the rails. Their free wall ends drifted so far out of line that the bins didn't
    fit, so they are reprinted with full-height columns like the rest (decision 11). Their labels, rails, keys
    and sockets are unchanged; only the posts are. The banded-post option (`banded_bins`) is gone, since no bin
    uses it.
11. **End columns at free wall ends (2026-11-18).** Printing bin 2, the user saw a wall standing alone flex as
    it got taller, so its layers drifted out of line. A corner, where two walls meet, didn't flex. Every free
    wall end in the tray is where an open bin's wall stops against its neighbour, and its joint post ran only
    in the two 30 mm bands, leaving a bare 1.6 mm edge from 30 to 130 mm. **The posts now run the full height,
    as columns; the rails stay banded.** Bins 1 and 2 followed when they were reprinted (decision 10). This is
    now a repo ground rule (*Columns at free wall ends*).

## Design

- **Six bins, 2 across × 3 deep.** The 354 × 560 tray is far bigger than the bed, so each compartment is its own
  bin, printed floor-down with one bin per plate. Compartments are 174.6 × 184.5 mm inside.
- **Footprint:** 354 wide (3 mm door clearance each side) × 560 deep (5 mm spare). Height 160 + 0.6 mm text;
  the tall bin 5 is 220 + 0.6, leaving 129 mm headroom.
- **Tall bin:** bin 5 (back-left) is `tall_h` = 220 mm high (`tall_bins = [5]`). It owns all four of its walls,
  so it rises on its own; bins 3 and 6, whose open sides it closes, stay 160 and see a taller wall. The rails
  on its walls stop at 160, where those bins' posts are. Back-right couldn't be tall alone: its left side is
  bin 5's wall, so it would be open above 160 (an assert refuses it). 220.6 mm still fits the printer's 256.
- **Walls:** 1.6 mm, every one printed once.
  - **Who owns which wall:** the left bins (1, 3, 5) own the centre wall, so the right bins (2, 4, 6) have no
    left wall. Every bin owns its front wall, so bins 1–4 have no back wall: the bin behind closes them. Bins 5
    and 6 own the tray's back wall. Bins 2 and 4 are left with two walls, bins 1, 3 and 6 with three, and bin 5
    with four.
  - `wall_style = "solid"` (default): plain walls.
  - `wall_style = "hex"`: every wall gets the floor's honeycomb: regular holes 14 mm across flats with 2.5 mm
    struts, turned **flats top and bottom**. Their sides lean 30° from vertical and each roof is a flat
    **8.1 mm bridge**, so they print without support (a hex standing on a corner has 30° roofs, which droop).
    Only whole holes are cut, centred on each wall, so every wall's mesh is mirror-symmetric. The wall stays
    solid at least 6 mm at the top and bottom, 12 mm at each wall end (it carries the joints), and behind the
    label tab. What's left between whole holes goes to those bands: about 7 mm top and bottom, 23 mm at each
    end of a front or back wall (9 columns) and 14 mm at each end of a side wall (11 columns).
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
  - **Banded rails:** rails run only 30 mm up from the floor and 30 mm down from the open bin's wall top
    (`joint_band`, 0 = full height), so on the tall bin's walls the upper rails run 130–160, not up to 220.
    Each upper band grows out of its wall on a 42° chamfer. Small dovetail outlines on every layer cost far
    more time than their plastic: full-height joints made the tray slower to print than the old double walls
    (see the print list).
  - **End columns (decision 11):** a post always sits at a wall's free end, so the posts run the **full
    height** as columns that stop the end flexing while it prints. The socket stays open all the way up, so a
    neighbour's rails pass through it as the bin is lowered in. Between the rail bands, the post simply butts
    against the neighbour's wall. Columns are on bins 1, 2, 3, 4 and 6, two each; bin 5 has no free ends.
- **Floor:** 2 mm, hex holes 14 mm across flats with 2.5 mm struts, inside a 4 mm solid band along the walls
  (10 mm along an open side).
- **Label tab:** a 110 × 16.6 mm ledge on the inside of each bin's front wall. It's flush with the wall top and
  carried by a 45° gusset, so it needs no supports. The gusset leaves the wall 143 mm above the shelf (203 mm
  in the tall bin), so only boxes taller than that, standing right against the front wall, meet it. The
  category text is raised 0.6 mm above the wall top, reading from the front. A filament change just above the
  wall top (layer 160.2 mm, or 220.2 mm on bin 5) prints it in a second colour.
  - Text is 8 mm high. Longer labels shrink to fit the tab, and an assert refuses any that would go below 5 mm.
    All six current labels print at the full 8 mm ("Braces & Supports" just fits).
  - Labels are `label_1` … `label_6` in the Customizer: front-left, front-right, middle-left, middle-right,
    back-left, back-right.
- **Tipping:** a loaded tray slid out past about half its depth tips forward off the shelf. To reach the back
  row, lift it out from underneath, not by a wall.

## Compartments (2026-11-18)

From photos of the user's four existing boxes (Muscle + Pain, Allergy + Cold, Skin, Misc) and two lots not yet
unpacked. The most-used compartments are at the front.

| | Left | Right |
|---|---|---|
| **Front** | 1 **Cold & Flu** | 2 **Pain & Muscle** |
| **Middle** | 3 **First Aid** | 4 **Skin** |
| **Back** | 5 **Braces & Supports** (220 mm) | 6 **Tummy & Sleep** |

- **Pain & Muscle:** paracetamol, ibuprofen + paracetamol, the prescription painkillers, the pharmacy
  envelopes, a methyl salicylate and eucalyptus rub.
- **Cold & Flu:** Med-Lemon sachets, throat lozenges, a chest rub, nasal and dropper bottles. The allergy items
  (hayfever wipes, antihistamines) go here too, as in the old Allergy + Cold box.
- **First Aid:** plasters (three kinds, from three boxes), alcohol pads, a crepe bandage, tape, tweezers,
  thermometers.
- **Skin:** sunburn gel, a cold-sore product, ointments and creams, insect repellent.
- **Braces & Supports:** elbow braces, a black strap brace, a fabric support.
- **Tummy & Sleep:** nausea and motion sickness tablets, a laxative, sleeping tablets, an eye mask, earplugs,
  supplements.

## Assembly

1. **Print `joint_test` first** (15 min, 5 g). Slide the right piece down onto the left one: the rail should run
   through its socket, and the key drop into its slot, by hand, with no slop. If it's too tight or too loose,
   change `joint_clear` and print the test again **before** printing any bins.
2. **Dry-fit:** on a flat surface, stand bin 5 in its place. Lower each other bin into its place from above, its
   sockets over its neighbours' rails and keys. Any order works; 5, 3, 1, 6, 4, 2 is easy.
3. **Glue:** take the tray apart and rebuild it, putting a drop of CA on each floor key just before lowering the
   bin over it. A key only enters its socket in the last 2 mm, so no glue is dragged along a rail. Acetone does
   not weld PLA.

## Verification (2026-11-17; tall bin 2026-11-18)

- **Asserts:** door width, shelf depth and height, bed fit with a 5 mm margin for every bin including its keys
  (largest 182.8 × 192.7), printer Z, tab and gusset sizes, label length, dovetail shapes, socket walls, key
  band, keys clear of the corner posts, label tab clear of the posts, joint bands that can't meet, and no bin
  taller than the bin whose wall closes its side.
- **No supports:** all 12 bins (both wall styles) and the joint test have 0 mm² of overhang steeper than 45°. The
  only flat undersides above the bed are the hex-wall roofs (their area equals holes × 8.08 × 1.6 mm, and no
  piece is wider than 8.08 mm); Orca prints them as bridged overhang walls, with support off. Solid bins and
  the joint test have none. Each bin is a single shell; the joint test is two.
- **Nothing floating:** OrcaSlicer's "floating regions" check passes on all 12 bins and the joint test, and
  again on all 12 with the tall bin 5 (no slicer warnings at all). The banded posts first printed on bins 1
  and 2 needed a sloped far cheek to pass it: without one, Orca flagged every bin with posts, because the
  cheek started in mid-air over the socket's void. A face-angle check can't catch that, because the cheek's
  underside was a legal 42° slope; only the void beneath it was wrong. Full-height columns have no such cheek.
- **Fit**, by intersecting bins in place:
  - All 15 bin pairs meet with zero volume (under 0.001 mm³, both wall styles): they touch only face to face.
  - **Locks:** a bin slid 0.35 mm along its neighbour collides, as does one pulled away 0.66 mm. One pulled away
    0.46 mm doesn't, which brackets the 0.56 mm of play.
  - **Lowering:** at all 7 joints, the open bin raised above its place by 0.3–159 mm (27 heights each, through
    every band crossing, both wall styles) never touches its owner, so each bin can be lowered straight in.
  - **Tall bin (re-run 2026-11-18):** all 15 pairs again meet with zero volume, both styles, and bins 3 and 6
    lowered beside bin 5 from 0.3 to 219 mm (31 heights, both styles) never touch it.
  - **End columns (re-run 2026-11-18):** all 15 pairs meet with zero volume in both styles. Pairs that touch
    leave only a flat contact sheet; others are empty. At the 4 joints where a column bin is the open one
    (3 into 5, 4 into 6, 4 into 3, 6 into 5), the open bin raised by 0.3 to 159 mm, and up to 219 mm beside
    bin 5 (34 to 40 heights, through every band crossing, both styles), never touches its owner, so the
    full-height posts leave the rail channels clear. A control run shows the check would catch a blocked
    channel: bin 4 raised 15 mm and shifted 0.35 mm sideways hits bin 6's rail (8.6 mm³).
  - **Orca (2026-11-18, end columns):** all 12 bins slice with no warnings, floating regions included.
  - **Bins 1 and 2 with end columns (2026-11-19):** bins 3 to 6 export byte-identical STLs to before, so only
    bins 1 and 2 changed. The 9 pairs that include bin 1 or 2 meet with zero volume in both styles. At the 3
    joints where bin 1 or 2 is the open one (1 into 3, 2 into 1, 2 into 4), the open bin raised by 0.3 to
    159 mm (44 heights, through every band crossing, both styles) never touches its owner. Controls: bin 2
    raised 15 mm and shifted 0.35 mm along bin 1's centre wall hits its rail (8.6 mm³), and bin 1 raised 15 mm
    and shifted 0.35 mm sideways hits bin 3's rail (17.2 mm³). Orca slices both bins in both styles with no
    warnings.

### Print list: filament and time (sliced)

OrcaSlicer 2.5.0-dev (the user's own build, CLI, through `orca_check.py` on `make`) with the presets on the
model's `// ORCA:` lines: printer `Qidi Q2 0.4 nozzle @Q2 0.4`, process `0.20mm Standard @Qidi Q2`, filament
`SUNLU PLA+ 2.0 @Q2 0.4` (1.21 g/cm³, 12 mm³/s max flow), no brim. These are Orca's estimates for each bin
sliced on its own plate, as of 2026-11-19 (real labels, tall bin 5, end columns on every bin with a free wall
end).

| Bin | Walls owned | Solid | Hex |
|---|---|---|---|
| 1 Cold & Flu | front, left, centre | 6 h 5 min, 211 g | 6 h 43 min, 129 g |
| 2 Pain & Muscle | front, right | 4 h 58 min, 154 g | 5 h 14 min, 101 g |
| 3 First Aid | front, left, centre | 6 h 18 min, 214 g | 6 h 55 min, 131 g |
| 4 Skin | front, right | 4 h 51 min, 155 g | 5 h 19 min, 103 g |
| 5 Braces & Supports, 220 mm | all four | 8 h 19 min, 342 g | 9 h 33 min, 194 g |
| 6 Tummy & Sleep | front, right, back | 5 h 54 min, 208 g | 6 h 39 min, 131 g |
| **Tray** | | **36 h 25 min, 1,284 g** (about 441 m) | **40 h 23 min, 789 g** (about 271 m) |
| Reprint (bins 1 and 2) | | 11 h 3 min, 365 g | 11 h 57 min, 230 g |

Plus `joint_test`: 15 min, 5 g. The tall bin costs 81 g and 1 h 40 min more than at 160 mm when solid
(6 h 39 min, 261 g before), 40 g and 2 h more in hex. The end columns cost 25 to 43 min and about 5 g per bin
(solid, bins 1, 2, 3, 4 and 6 were 5 h 28 min / 206 g, 4 h 15 min / 148 g, 5 h 42 min / 209 g,
4 h 26 min / 150 g and 5 h 26 min / 203 g): 2 h 49 min and about 26 g on the solid tray, 2 h 11 min and about
26 g on the hex one.

How the joints compare, for the whole tray with every wall 160 mm (sliced 2026-11-17):

| Design | Solid | Hex |
|---|---|---|
| Old: closed bins, glued wall to wall (double walls) | 36 h 11 min, 1,530 g | 47 h 51 min, 799 g |
| Single walls, full-height joints (`joint_band = 0`) | 36 h 54 min, 1,228 g | 43 h 14 min, 756 g |
| **Single walls, banded joints (default)** | **32 h 21 min, 1,185 g** | **39 h 40 min, 714 g** |

The comparison's hex column used the first, stretched wall hexes; the regular hexes printed the same tray in
36 h 41 min, 732 g. The current tray, with the tall bin 5, is in the print list above.

- **Single walls save 345 g (23 %) and 3 h 50 min on the solid tray**, and 85 g and 8 h 11 min on the hex one.
- **Hex walls save filament but cost time:** on the current tray, 495 g less than solid, 3 h 58 min longer. Each hole adds its own
  wall loop on every layer, plus travel and retractions, and each roof is bridged at 10 mm/s. The regular
  hexes have 1,399 holes to the stretched ones' 1,291, yet print 3 h faster, for 18 g more.
- **The 12 mm³/s cap on SUNLU PLA+ 2.0 limits the walls** to about 143 mm/s. A max-flow calibration, followed by
  raising the cap, is the main way left to print faster.

## Superseded: two-tier lane rack (2026-11-16)

The first design had six pull-out lanes, three across on each of two tiers, in a fully printed lattice rack. It
was modelled and verified in `medicine/medicine_rack.scad`, which is kept for reference and has no Makefile
targets. It came to **3.3 kg** of ABS over 15 prints, and the user dropped it for this tray.
