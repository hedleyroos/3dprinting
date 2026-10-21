# Front frame — 1973 Charger tail-light housing (left light)

Frame-first restart (2026-10-14, extended 2026-10-21 from the IMG_7527–7533 photos).
The rear of the original can't be taken apart to measure, so `charger73_front_frame.scad`
models everything **except** the three reflector bowls and the flat bay's pan. Those come
later as separate parts that sit in the four cutouts in the floor.

What the model has, front to back:

- the flat front face with the raised lip loop, which detours inward round each lens stud;
- 8 stud holes;
- a thin outer **skirt** with the perimeter **groove** behind it, open to the rear (body seal);
- the outer **wall**, drafted inward toward the rear;
- the flat **floor** (the flange ring the bowls stand on), with four bay cutouts and the
  divider bands between them; its underside is chamfered at 45° so it prints face down;
- 8 **stud bosses** on the floor's rear face, each on a square pad reaching the wall
  (the real part also has a small fin from each boss to the bowl; that comes with the bowls);
- the inboard **mounting plate**, set deep: its back face is ~37 mm behind the front face, a
  few mm in front of the floor's rear face, with a fillet into the end wall, a 90° curl toward
  the lens side, and a notch at its far bottom corner. (The photos bracket the plate's depth
  between 35 and 42 mm; it is the least certain dimension in the model.)

```
 section through a long edge (outside left, front face on top)
                                       __ lip
 ####################################|  |   front face
 ## ^ ##   groove, open to the rear, between skirt and wall
      ##
       ##         drafted wall
        ####### /      o  stud hole runs on to the boss
        ########/______|___   floor: flat flange, 45° chamfer under it
                       [ ]    boss with nut face
```

Sources: `unnamed.jpg` (front) for the opening, stud and divider positions;
`IMG_7441.jpeg` (rear) for the overall size; `IMG_7527–7533.HEIC` for the back structure
(`convert IMG_7533.HEIC x.jpg` makes a viewable copy). `unrelated_bezel_model/` is a different
design; ignore it.

**Photo caveats.** IMG_7441 was shot close with the wide lens: anything standing above the
front face (the bosses, the flange) is pushed outward by parallax, up to 60 mm at the ends.
Don't take positions of raised features from it. The front photo is keystoned (the inboard end
~16 % larger), which is corrected in the stud and divider fractions below. The black band
round the front face is paint, not the gasket: the gasket is a 5 mm rubber strip that follows
the lip. IMG_7443 (plate end from above) has the ruler at 7.02 px/mm on the floor, but the part's
top edge is ~150 mm nearer the camera (~9.5 px/mm) and the view is oblique, so only ratios
between features at the same height can be read from it. IMG_7527–7533 have no scale at all.

## Parts

| `part` | what |
|---|---|
| `frame` | the whole frame; `side = "R"` mirrors it; `with_wing = false` leaves the plate off |
| `test` | 60 mm slice of the top edge round stud `test_stud`: groove, stud hole, flange chamfer and boss. Lip left off; prints face down with no support. Try the gasket in the groove and a lens stud through it. |
| `wing` | the mounting plate alone, cut off at the end wall's outer face and stood on its long edge, so the J-profile is extruded straight up with no overhang. Glue it to the end wall. (On the frame it would be a 60 mm overhang 37 mm up.) |
| `section` | 2D cut at `section_x` |

`./render_frame.sh` re-renders everything into `renders/frame/`; the `compare_*.png` sheets
there put the renders beside the photos (`tools/montage.py`).

Printing: the frame prints face down. The floor's chamfer and the divider keels keep every
overhang at 45° or steeper. At ~660 mm it still has to be split for the bed; that comes once
the outline is confirmed. The wing prints standing on its long edge as its own part.

## Measurements wanted (every value in the .scad is a photo estimate)

Tape:

| variable | estimate | how to measure |
|---|---|---|
| `body_len` | 660 | outer length, inboard edge (plate root) → outboard end |
| `h_in` / `h_out` | 155 / 148 | outer height at each end; the top edge is straight, the bottom tapers |
| `floor_z` | 42 | front face → the flat floor at the back (measure at a divider) |
| `stud_frac` / stud spacing | 92, 249, 406, 564 from the inboard edge | **easiest off the lens**: the four stud positions along one edge, and the distance between the two rows |
| `stud_inset` | 25 | outer edge → stud centre |
| `band_side` / `band_in` / `band_out` | 29 / 36 / 48 | outer edge → outside of the lip, sides / inboard end / outboard end |
| `div_frac` | dividers at 199, 344, 464 | divider centres from the inboard edge |
| `mp_z` | 34 | **most wanted**: front face → the plate's front face; or the step between the plate's back face and the floor's rear face (model: 5 mm) |
| `mp_straight`, `mp_r`, `mp_tail`, `mp_h` | 42, 15, 6, 145 | plate: straight run from the end wall, curl radius, tail after the curl, height |
| `notch_w` / `notch_h` | 20 / 26 | the notch at the plate's far bottom corner |

Calipers:

| variable | estimate | how to measure |
|---|---|---|
| `skirt_t` / `skirt_h` | 2 / 8 | skirt thickness / depth from the front face |
| `groove_w` / depth | 1.8 / 4.5 | groove width and depth (depth = `skirt_h − face_t`) |
| `face_t` / `wall_t` / `floor_t` | 3.5 / 3 / 3 | front plate, wall, floor thicknesses |
| `wall_in_side` / `wall_in_end` | 14 / 8 | outer edge → outside of the wall at the floor (the draft) |
| `pan_inset_side` / `_in` / `_out` | 31 / 18 / 20 | outer edge → where the bowl rises from the floor |
| `div_w` | 8 | divider width at the floor |
| `boss_d` / `boss_h` / `stud_hole_d` | 10 / 8 / 5.5 | boss diameter, height above the floor, hole |
| `pad_w` / `pad_h` | 14 / 3 | the square pad under the boss |
| `lip_w` / `lip_h` | 2 / 2.5 | lip width / height |
| `r_out` / `r_in` | 35 / 8 | outer corner radii |

Not modelled yet: the steel mounting tab on the bottom edge, the harness hole in the inboard
end wall, the SAE text, the fins from the bosses to the bowls, the bowls and the flat pan.
