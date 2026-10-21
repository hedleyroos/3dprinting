# Handoff — 1973 Charger tail-light housing, rear unit (2026-10-21)

Read this and `FRAME.md` first. Work only from the user's own photos; `unrelated_bezel_model/`
is a different design. The repo rules are in `.github/copilot_instructions.md` (one
self-contained `.scad` per model, `part` selector, `$fa = 1; $fs = 0.4`, avoid supports).

## First job (done 2026-10-21): "I see one light, there should be three"

Cause: `charger73_rear_unit.scad` had `part = "piece1"` as its default, which renders only
piece 1 (bay 0's bell on its slice of skin). The geometry was fine: `part = "unit"` exports
genus 3 (three socket holes) and `unit_positive()` loops `for (i = [0, 1, 3])`.
Fix: the default is now `part = "unit"` (the whole back, skin down, 643 mm); `piece1..piece4`
are unchanged and are still what you print. The `assembled_front.png` camera in
`render_unit.sh` was backed off (eye z 300 -> 400) so the whole skin is in frame.
`./render_unit.sh` was re-run and the checks below repeated: overlap volume 0.00 (one
zero-thickness sheet at z = -42, the glue face), piece genus 1/1/0/1, bay sizes match.

## State of the repo

- `/data4/projects/3dprinting`, branch `develop`. Last commit `747967a` = the front frame.
- **Uncommitted** (don't commit until the user says so): `charger73_front_frame.scad`
  (cutouts shrunk by `bay_wall = 3`), `FRAME.md` (rear-unit section), new
  `charger73_rear_unit.scad` and `render_unit.sh`. `charger73_bowls.scad` (four separate
  bowls, superseded) was deleted before ever being committed.
- `challenger/.gitignore` keeps photos, `renders/`, the bezel files and `__pycache__` out.
- Python venv: `challenger/.venv` (`--system-site-packages`, has PIL + numpy).
  OpenSCAD 2026.06 at `/usr/local/bin/openscad` (manifold backend).

## What the two models are

- `charger73_front_frame.scad` — the frame that carries the lens: front plate, lip loop with
  stud detours, 8 stud holes, rear-opening perimeter groove behind a skirt, drafted wall, flat
  floor with four bay cutouts (45° chamfer + divider keels so it prints face-down), 8 stud
  bosses on pads on the floor's rear face, deep inboard mounting plate (`part = "wing"`, prints
  separately standing on its long edge). `./render_frame.sh`.
- `charger73_rear_unit.scad` — the whole back as one part glued onto the frame: a 3 mm skin
  covering the frame's floor (front face = glue face), three bells standing on it, the flat
  bay closed by the skin. The frame's 8 bosses/pads pass through holes in the skin and locate
  it. Each bell's inside is flush with its cutout (cutout = bay outline inset by `bay_wall`).
  Prints skin-down with no support at the defaults (`bowl_curve = 0`, `socket_pad_len = 70`:
  every wall ≤ 44°); `bowl_curve > 0` + round pad = the original's dome, needs support inside.
  Printed as `piece1..4`, cut at the divider centres (191/145/120/188 mm). `./render_unit.sh`.
- The `[Shared]` parameter block in the rear unit is a copy of the frame's and **must stay
  identical** (no `include` between model files). Cutouts in both are the same formula
  (`cut_2d` in the frame, `cutout_2d` in the unit).

## Verification that was done (repeat after any change)

- Manifold exports: frame genus 20 (1 opening + 4 cutouts + 16 stud tunnels − 1), test piece 2,
  wing 0; unit pieces 1/2/4 genus 1 (socket hole), piece 3 genus 0.
- Frame-vs-unit overlap: export `part="assembled"` of the unit to `renders/unit/assembled.stl`,
  then an OpenSCAD scratch file with
  `intersection(){ import("…/renders/frame/frame_L.stl"); import("…/renders/unit/assembled.stl"); }`
  exported with `--backend=manifold`; `tools/stl_stats.py` on the result must give volume 0.00
  (coplanar contact only). It did.
- Bay sizes: frame echo "bowl feet [177, 137, 112, 172] cutouts [171, 131, 106, 166]" must
  equal the unit echo's bells L at the foot.

## Open items

- Measurements (all values are photo estimates): plate depth behind the front face (model 34,
  photos say 35–42), overall length (660), the four stud positions and row spacing (take them
  off the lens), bowl depth (55), socket pad/hole diameters (45/27), bayonet notches, bell
  roundness (card template).
- Not modelled: steel mounting tab (bottom edge), harness hole in the inboard end wall, SAE
  text, boss-to-bowl fins, the frame's bed split (use the divider centres, same as the unit).
- The flat bay is recessed 3 mm behind the floor; `part = "pan_insert"` fills it if wanted.
- Unidentified: a small grey slotted part next to the housing in IMG_7527.

## Photo notes

- IMG_7441 (rear, lying face down): ruler 7.12 px/mm; shot close with the wide lens, so raised
  features are pushed outward by parallax (up to 60 mm at the ends) — don't take positions of
  bosses/flange from it.
- unnamed.jpg (front): keystoned, inboard end ~16 % too large; stud/divider fractions already
  corrected.
- IMG_7443 (plate end from above): ruler 7.02 px/mm on the floor, but the part's top edge is
  ~150 mm nearer (~9.5 px/mm) and the view is oblique — only same-height ratios are usable.
- IMG_7527–7533 (HEIC; `convert x.HEIC x.jpg`): close-ups of the back, no scale.
- The black band round the front face is paint; the gasket is a 5 mm strip following the lip.
