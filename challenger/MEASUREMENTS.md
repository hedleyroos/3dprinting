# MEASUREMENTS — 1973 Charger tail-light housing (left light)

Every number in `charger73_taillight_housing.scad` is marked `// est.` until you enter a
reading here; then re-run `./render.sh`.

Units: **mm**. Write `—` if a feature does not exist on your part.

Photo tool: `.venv/bin/python tools/photo_measure.py` can convert photo pixels to mm
(`ticks`, `measure`, `grid` commands) once a scale rule is in frame; the originals in
this folder give roughly 3 px/mm, i.e. good enough for ~±2 mm on big features only.
Photo pass 2026-09-12: scale objects confirmed the ~3 px/mm class; nothing finer was
readable, so tape/caliper readings below are what matters.

---

## A — Tape measure (fit on car and lens)

| SCAD variable | plan est. | your reading | how to measure |
|---|---|---|---|
| `body_len` | 610 | | length of the front rim, plate end excluded |
| `body_h` | 140 | | front rim height (at the outboard end) |
| rear outline length | 610−2×8 | | rear face length (checks `rear_inset_end`) |
| rear outline height | 140−2×5 | | rear face height (checks `rear_inset_side`) |
| `shell_depth` | 45 | | rim front plane → flat back floor (at a bowl edge) |
| rim → dome apex | 100 | | front plane → highest point of a rear dome |
| rim → socket tip | 102 | | front plane → outermost point of the socket boss |
| `opening_len` | 558 | | opening L inside the lip (plate root → outboard) |
| `opening_h` | 92 | | opening H inside the lip |
| lens outline L × H | — | | back of the lens where it seats (sanity check vs opening) |
| bay edges (4 bays) | see plan | | start/end x of each window + divider width, from the plate root: bowl1 141 / d10 / bowl2 145 / d5 / flat 110 / d5 / bowl3 138 |
| `stud_x_in` | 90, 250, 395, 540 | | x of the 4 lens studs (both edges same?) |
| `stud_y` | 50 | | stud distance from the centreline |
| `rim_w_side` | 24 | | outer edge → lip across the long sides |
| `rim_w_inboard` | 22 | | outer edge → lip at the plate end |
| `rim_w_outboard` | 30 | | outer edge → lip at the rounded end |
| `r_out` | 60 | | outboard corner radius (trace on paper) |
| `r_in` | 15 | | inboard corner radius (trace on paper) |
| plate projection `wing_ext` | 35 | | inboard of the housing's end face |
| plate height | =body_h | | is the plate as tall as the housing? |
| plate curl start `wing_z0` | −27.5 | | how far behind the rim the plate root sits |
| plate curl radius `wing_r` | 15 | | trace the J on card, measure the bend |
| plate curl angle | 90° | | |
| plate tail `wing_tail` | 10 | | straight part after the bend |
| plate thickness `wing_t` | 3 | | |
| plate holes | none | | any? dia + position |
| harness exit | top edge | | position along the top edge + hole dia |

## B — Calipers (detail)

| SCAD variable | plan est. | your reading | how to measure |
|---|---|---|---|
| `wall_t` | 3 | | side wall thickness |
| `floor_t` | 3 | | back floor thickness (⚠ floor keys use it) |
| `lip_w` / `lip_h` | 2.5 / 2.5 | | raised lip loop width / height |
| `bulge_r` | 13 | | lip bulge radius around a stud |
| `stud_hole_d` | 6 | | hole through the rim at a bulge |
| `channel_r` / `channel_depth` | 13 / 46 | | stud channel behind the bulge |
| `boss_d` / `boss_h` | 12 / 8 | | rear boss diameter / height |
| `boss_hole_d` | 6.5 | | rear boss hole |
| `socket_d` | 27 | | socket hole diameter |
| `socket_pad_d` | 45 | | flat pad diameter at the dome apex |
| socket notches | 2 | | count / width / depth of bayonet notches |
| `socket_land_h` | 2 | | how far the socket area stands proud |
| `bowl_depth` | 55 | | per bowl: floor → apex (measure each of the 3) |
| `bowl_curve` | 1.3 | | how full the dome is: 1.0 = straight cone |
| flat-bay holes | 2 × Ø6 | | do they exist? dia + x/y position |
| flat pan (rear) | 10 / 3 | | margin / height of the raised pan behind the flat bay |
| `steel_tab_*` | 20 × 3 × 33, Ø6 | | width, thickness, rearward, hole |
| `bracket_*` | 25 × 3 × 30 | | both brackets; one has a screw hole — which? |
| `end_rib` | 3 × 8 | | width, how far it stands off the rear |
| `stud_x_in` / `stud_y` | — | | confirm against lens: studs must line up |

## Photos still useful (add to this folder)

1. outboard (rounded) end shot straight on — corner radius + draft check
2. plate end from directly above, ruler alongside — curl trace
3. bottom edge straight on — steel tab, brackets, rib positions

---

### Notes for the model author (me)
- After updating values, check: `./render.sh` → `renders/compare/sheet_*.png` and the
  bbox line printed by `tools/stl_stats.py` (should equal `body_len+wing_ext` × `body_h`
  × `shell_depth+bowl_depth+socket_land_h` within ~1 mm).
- The flat bay is bay 3 of 4 from the inboard end (bowl1 | bowl2 | flat | bowl3).
