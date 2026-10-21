// ============================================================================
//  1973 Dodge Charger tail-light housing -- REAR UNIT
//  (the user's LEFT light: left as seen from behind the car)
//
//  The whole back of the housing as one part that glues onto the front
//  frame (charger73_front_frame.scad): a flat skin that covers the frame's
//  floor, the three reflector bells standing on it round the frame's bay
//  cutouts, and the flat bay closed off by the skin. The frame's eight stud
//  bosses and pads pass through holes in the skin and locate the unit; the
//  skin's front face is the glue face.
//
//  Section across the frame at a bowl (front face up):
//
//      front plate   ================================================
//      wall           \\                                          //
//      frame floor     #####|      cutout       |#################   z = -floor_z
//      skin            #####|                   |#################   z = -floor_z - skin_t
//                          ||                   ||   <- bell wall stands on the skin,
//                           \\                 //       its inside flush with the cutout
//                            \\_______   _____//      apex pad, socket hole
//
//  Same coordinates as the frame: x = 0 at the inboard outer edge, +x
//  outboard; y = 0 on the centreline, +y the top edge; z = 0 on the front
//  face, rear is -z. All mm. The [Shared] block is copied from the frame
//  file and must stay identical to it: each model file stands alone.
//
//  Printing: skin down, bells up, no support with the defaults: the bells
//  are straight-sided (bowl_curve = 0) and the apex pad is stretched along
//  the frame (socket_pad_len), so no wall leans more than 45 degrees and
//  the pad's inside is bridged; the echo reports the lean. bowl_curve > 0
//  with socket_pad_len = socket_pad_d gives the original's round dome,
//  which then needs support inside the bells for the last 20-25 mm below
//  the pad. The unit is 650 mm long: print it as the four pieces, cut at
//  the divider centres.
// ============================================================================

/* [Part] */
// "unit" shows the whole back; print it as piece1..piece4 (cut at the divider centres)
part = "unit";         // [unit, piece1, piece2, piece3, piece4, pan_insert, assembled, cutaway, section]
side = "L";            // [L, R]
section_bowl = 0;      // [0, 1, 3]  bay shown by cutaway and section

/* [Shared with charger73_front_frame.scad - keep identical] */
body_len = 660;        // est.
h_in = 155;            // est.
h_out = 148;           // est.
r_in = 8;              // est.
r_out = 35;            // est.
band_in = 36;          // est.
band_out = 48;         // est.
pan_inset_side = 31;   // est.  outer edge -> outside of the bowl wall, long sides
pan_inset_in = 18;     // est.
pan_inset_out = 20;    // est.
bay_wall = 3;          // the bowl wall's footprint: the frame's cutout is the bay inset by this
div_frac = [0.283, 0.535, 0.743];  // est.
div_w = 8;             // est.
bay_r = 10;            // est.
floor_z = 42;          // est.
floor_t = 3;           // est.
wall_in_side = 14;     // est.
wall_in_end = 8;       // est.
stud_frac = [0.097, 0.370, 0.642, 0.916];  // est.
stud_inset = 25;       // est.
boss_d = 10;           // est.
boss_h = 8;            // est.
pad_w = 14;            // est.

/* [Bells] */
bowl_depth = 55;       // est.  floor's rear face -> outside of the apex pad
bowl_curve = 0;        // 0 = straight sides (prints without support), 1 = full dome
wall_t = 2.6;          // bell wall, measured square to the surface
pad_t = 3;             // apex pad thickness
socket_pad_d = 45;     // est.  apex pad width (round in the original)
socket_pad_len = 70;   // pad length along the frame: = socket_pad_d for round
socket_d = 27;         // est.  socket hole
socket_notch_n = 2;    // est.  bayonet notches
socket_notch_w = 5;    // est.
socket_notch_d = 2;    // est.  beyond the hole's radius
slices = 24;           // loft steps

/* [Skin] */
skin_t = 3;            // skin thickness (the boss pads are this tall)
skin_clear = 0.5;      // skin edge inside the frame wall's foot
hole_clear = 0.4;      // round the boss pads
clearance = 0.3;       // bell foot inside the bay outline
insert_t = 2.6;        // pan insert: fills the frame's flat-bay cutout

/* [Quality] */
$fa = 1;               // minimum angle
$fs = 0.4;             // minimum facet edge, matched to a 0.4 mm nozzle

// ------------------------------------------------------------------ derived

taper = h_in - h_out;
y_top = h_in / 2;
function y_bot(x) = -h_in / 2 + taper * x / body_len;
opening_x0 = band_in;
opening_x1 = body_len - band_out;
opening_len = opening_x1 - opening_x0;
function stud_x(i) = opening_x0 + opening_len * stud_frac[i];
function stud_y(x, s) = s > 0 ? y_top - stud_inset : y_bot(x) + stud_inset;
function div_x(j) = opening_x0 + opening_len * div_frac[j];
function bay_x0(i) = i == 0 ? pan_inset_in : div_x(i - 1) + div_w / 2;
function bay_x1(i) = i == 3 ? body_len - pan_inset_out : div_x(i) - div_w / 2;
function bay_len(i) = bay_x1(i) - bay_x0(i);

z_floor = -floor_z;                     // the floor's rear face: the skin's front face
z_apex = z_floor - bowl_depth;          // outside of the apex pad
t_end = 1 - pad_t / bowl_depth;         // the hollow stops here: the pad

// the bay (outside of the bowl wall) as four corner-circle centres
// [bl, br, tr, tl], radius bay_r; the apex pad likewise
function bay_corners(i) = let (
    x0 = bay_x0(i), x1 = bay_x1(i), r = bay_r,
    yb0 = y_bot(x0) + pan_inset_side, yb1 = y_bot(x1) + pan_inset_side,
    yt = y_top - pan_inset_side)
  [[x0 + r, yb0 + r], [x1 - r, yb1 + r], [x1 - r, yt - r], [x0 + r, yt - r]];
function bay_centre(i) = let (c = bay_corners(i)) (c[0] + c[1] + c[2] + c[3]) / 4;
function bay_h(i) = let (c = bay_corners(i)) c[3][1] - c[0][1] + 2 * bay_r;
function pad_corners(i) = let (c = bay_centre(i), e = [max(socket_pad_len - socket_pad_d, 0) / 2, 0])
  [c - e, c + e, c + e, c - e];

// bell profile: g = 0 at the base, 1 at the apex; cone blended with a dome
function g_of(t) = (1 - bowl_curve) * t + bowl_curve * (1 - sqrt(max(0, 1 - t * t)));
function gprime(t) = (1 - bowl_curve) + bowl_curve * t / sqrt(max(1e-4, 1 - t * t));
function z_of(t) = z_floor - bowl_depth * t;
// lean of the wall from vertical along the long axis and the short axis
function lean(i, t) = atan((bay_len(i) - socket_pad_len) / 2 * gprime(t) / bowl_depth);
function lean_side(i, t) = atan((bay_h(i) - socket_pad_d) / 2 * gprime(t) / bowl_depth);
// inset from the bay outline to the inside of the wall: at least the frame's
// cutout, and enough that the wall is wall_t square to its lean
function d_in(i, t) = max(bay_wall, clearance + wall_t / cos(min(lean(i, t), 70)));
// first t where a lean passes 45 degrees (1 if none does)
function t45(i) = let (ts = [for (k = [0 : 100])
    if (max(lean(i, k / 100), lean_side(i, k / 100)) > 45) k / 100])
  len(ts) == 0 ? 1 : ts[0];

function piece_x0(n) = n == 1 ? -10 : div_x(n - 2);
function piece_x1(n) = n == 4 ? body_len + 10 : div_x(n - 1);

// --------------------------------------------------------------- 2D shapes

// rounded quad: bottom edge from (x0, yb0) to (x1, yb1), straight top at yt
module rr(x0, x1, yb0, yb1, yt, r0, r1) {
  a = max(r0, 0.5);
  b = max(r1, 0.5);
  hull() {
    translate([x0 + a, yb0 + a]) circle(a);
    translate([x1 - b, yb1 + b]) circle(b);
    translate([x1 - b, yt - b]) circle(b);
    translate([x0 + a, yt - a]) circle(a);
  }
}

// the frame's outline inset by dx_in (inboard end), dx_out (outboard), dy (sides)
module outline_in(dx_in, dx_out, dy, ra = undef, rb = undef) {
  x0 = dx_in;
  x1 = body_len - dx_out;
  rr(x0, x1, y_bot(x0) + dy, y_bot(x1) + dy, y_top - dy,
     is_undef(ra) ? r_in - max(dx_in, dy) : ra,
     is_undef(rb) ? r_out - max(dx_out, dy) : rb);
}

module slice_2d(i, t, d = 0) {          // the bell's outline at t, inset by d
  g = g_of(t);
  bc = bay_corners(i);
  pc = pad_corners(i);
  r = (1 - g) * bay_r + g * socket_pad_d / 2;
  offset(delta = -d)
    hull() for (k = [0 : 3]) translate((1 - g) * bc[k] + g * pc[k]) circle(r);
}

module cutout_2d(i) { slice_2d(i, 0, bay_wall); }   // the frame's cutout (its cut_2d)

// a 0.01 slab just below z, so a loft that starts at the floor plane ends
// exactly there and never pokes into the frame
module slab(z) { translate([0, 0, z - 0.01]) linear_extrude(0.01) children(); }

// ------------------------------------------------------------------- parts

module skin() {                         // covers the frame's floor; open at the bells
  translate([0, 0, z_floor - skin_t])
    linear_extrude(skin_t)
      difference() {
        outline_in(wall_in_end + skin_clear, wall_in_end + skin_clear, wall_in_side + skin_clear);
        for (i = [0, 1, 3]) cutout_2d(i);
      }
}

module pad_holes() {                    // the frame's stud bosses and pads pass through
  for (i = [0 : 3], s = [1, -1]) {
    x = stud_x(i);
    y = stud_y(x, s);
    y_wall = s > 0 ? y_top - wall_in_side : y_bot(x) + wall_in_side;
    y0 = (s > 0 ? y - boss_d / 2 - 1 : y_wall - 2) - hole_clear;
    y1 = (s > 0 ? y_wall + 2 : y + boss_d / 2 + 1) + hole_clear;
    translate([x - pad_w / 2 - hole_clear, y0, z_floor - skin_t - 1])
      cube([pad_w + 2 * hole_clear, y1 - y0, skin_t + 2]);
  }
}

module bell_outer(i) {
  for (k = [0 : slices - 1]) {
    t0 = k / slices;
    t1 = (k + 1) / slices;
    hull() {
      slab(z_of(t0)) slice_2d(i, t0, clearance);
      slab(z_of(t1)) slice_2d(i, t1, clearance);
    }
  }
}

module bell_inner(i) {                  // the hollow, from above the skin down to the pad
  for (k = [0 : slices - 1]) {
    t0 = t_end * k / slices;
    t1 = t_end * (k + 1) / slices;
    hull() {
      slab(z_of(t0) + (k == 0 ? 0.02 : 0)) slice_2d(i, t0, d_in(i, t0));
      slab(z_of(t1)) slice_2d(i, t1, d_in(i, t1));
    }
  }
}

module socket_cut(i) {                  // hole through the pad plus bayonet notches
  c = bay_centre(i);
  translate([c[0], c[1], z_apex - 1]) {
    cylinder(d = socket_d, h = pad_t + 8);
    for (k = [0 : socket_notch_n - 1])
      rotate([0, 0, 90 + 360 * k / socket_notch_n])
        translate([socket_d / 2 - 1, -socket_notch_w / 2, 0])
          cube([socket_notch_d + 1, socket_notch_w, pad_t + 8]);
  }
}

module unit_positive() {                // the whole unit in frame coordinates
  difference() {
    union() {
      skin();
      for (i = [0, 1, 3]) bell_outer(i);
    }
    for (i = [0, 1, 3]) {
      bell_inner(i);
      socket_cut(i);
    }
    pad_holes();
  }
}

module piece(n) {                       // the unit between two divider centres
  intersection() {
    unit_positive();
    translate([piece_x0(n), -h_in, -200])
      cube([piece_x1(n) - piece_x0(n), 2 * h_in, 200]);
  }
}

module pan_insert() {                   // fills the frame's flat-bay cutout, flat
  c = bay_centre(2);
  translate([-c[0], -c[1], 0])
    linear_extrude(insert_t) offset(delta = -clearance) cutout_2d(2);
}

// ------------------------------------------------------------- placements

module handed() { mirror([side == "R" ? 1 : 0, 0, 0]) children(); }

// skin's front face on the bed, bells up (a rotation, so the handedness holds)
module print_pose() { translate([0, 0, z_floor]) rotate([180, 0, 0]) handed() children(); }

module piece_print(n) {
  print_pose() translate([-(piece_x0(n) + piece_x1(n)) / 2, 0, 0]) piece(n);
}

module unit_print() {
  print_pose() translate([-body_len / 2, 0, 0]) unit_positive();
}

module bay_region(i) {                  // the unit round one bay, centred, skin down
  c = bay_centre(i);
  print_pose() translate([-c[0], -c[1], 0])
    intersection() {
      unit_positive();
      translate([bay_x0(i) - 25, -h_in, -200]) cube([bay_len(i) + 50, 2 * h_in, 200]);
    }
}

module cutaway() {                      // near half removed
  difference() {
    bay_region(section_bowl);
    translate([-250, -250, -1]) cube([500, 250, 300]);
  }
}

module section_2d() {                   // x-z section through the socket, apex up
  projection(cut = true) rotate([-90, 0, 0]) bay_region(section_bowl);
}

// ------------------------------------------------------------------ report

echo(str("rear unit: skin ", round(body_len - 2 * (wall_in_end + skin_clear)), " long; bells L x H at the foot ",
         [for (i = [0, 1, 3]) [round(bay_len(i)), round(bay_h(i))]], "; pieces ",
         [for (n = [1 : 4]) round(min(piece_x1(n), body_len - wall_in_end) - max(piece_x0(n), wall_in_end))],
         " long"));
for (i = [0, 1, 3])
  echo(str("bell ", i == 3 ? 3 : i + 1, ": wall lean from vertical, long axis ", round(lean(i, 0)), "-",
           round(lean(i, t_end)), " deg, short axis ", round(lean_side(i, 0)), "-",
           round(lean_side(i, t_end)), " deg",
           t45(i) < 1 ? str("; over 45 for the last ", round(bowl_depth * (1 - t45(i))),
                            " mm below the pad: needs support inside")
                      : "; prints without support"));

// ------------------------------------------------------------------ render

if (part == "unit")           color([0.72, 0.72, 0.75]) unit_print();
else if (part == "piece1")    color([0.72, 0.72, 0.75]) piece_print(1);
else if (part == "piece2")    color([0.72, 0.72, 0.75]) piece_print(2);
else if (part == "piece3")    color([0.72, 0.72, 0.75]) piece_print(3);
else if (part == "piece4")    color([0.72, 0.72, 0.75]) piece_print(4);
else if (part == "pan_insert") color([0.85, 0.6, 0.3]) pan_insert();
else if (part == "assembled") color([0.72, 0.72, 0.75]) handed() unit_positive();
else if (part == "cutaway")   color([0.72, 0.72, 0.75]) cutaway();
else if (part == "section")   section_2d();
