// ============================================================================
//  1973 Dodge Charger tail-light housing -- FRONT FRAME
//  (the user's LEFT light: left as seen from behind the car)
//
//  Frame-first model: everything except the three reflector bowls and the
//  flat bay's pan, which come later as separate parts that sit in the four
//  floor cutouts. Modelled from the user's own photos (IMG_7441 rear view,
//  unnamed.jpg front view, IMG_7527..7533 details).
//
//  Section through a long edge (outside on the left, front face on top):
//
//                                      __ lip (+z)
//      ####################################|  |   z = 0 front face, face_t thick
//      ## ^ ##   <- groove between the outer skirt and the wall,
//      ##   ##      open to the rear, holds the body seal
//           ##
//            ##       <- outer wall, drafted inward toward the rear
//             ##               o   <- stud hole continues to the boss
//              ####### /       |
//              ########/_______|___  <- floor: flat flange ring at -floor_z,
//                      \ chamfer      45-degree underside so it prints face
//                         ######|##     down; the boss stands on its rear face
//                               [ ]  <- stud boss with nut face
//
//  Frame: x = 0 at the inboard outer edge (plate end), +x outboard;
//         y = 0 on the centreline, +y the top (harness) edge;
//         z = 0 on the front face, rear is -z.  All mm.
//  The top edge is straight; the body tapers on the bottom edge.
//  Every value marked `est.` is read off the photos: replace it with a
//  tape or caliper reading (see FRAME.md).
// ============================================================================

/* [Part] */
part = "frame";        // [frame, test, wing, section]
side = "L";            // [L, R]
with_wing = true;      // include the inboard mounting plate in the frame
keels = true;          // 45-degree keels under the floor dividers (printing aid)

/* [Outline - tape] */
body_len = 660;        // est.  outer length, inboard edge -> outboard end
h_in = 155;            // est.  outer height at the inboard end
h_out = 148;           // est.  outer height at the outboard end
r_in = 8;              // est.  inboard outer corner radius
r_out = 35;            // est.  outboard outer corner radius

/* [Front face] */
face_t = 3.5;          // est.  front plate thickness
band_side = 29;        // est.  outer edge -> outside of the lip, long sides
band_in = 36;          // est.  ... at the inboard end
band_out = 48;         // est.  ... at the outboard end
r_open_in = 5;         // est.  lip corner radius, inboard end
r_open_out = 12;       // est.  lip corner radius, outboard end
lip_w = 2;             // est.
lip_h = 2.5;           // est.

/* [Lens studs] */
stud_frac = [0.097, 0.370, 0.642, 0.916];  // est.  along the opening, from the inboard end
stud_inset = 25;       // est.  outer edge -> stud centre
stud_hole_d = 5.5;     // est.
bulge_r = 11.5;        // est.  lip detour radius round each stud
bulge_fillet = 5;      // est.  rounding where the detour meets the lip

/* [Groove and wall - calipers] */
skirt_t = 2;           // est.  outer skirt thickness
skirt_h = 8;           // est.  skirt depth, front face -> rear edge
groove_w = 1.8;        // est.  groove width at the front plate
floor_z = 42;          // est.  front face -> floor (rear face of the flange)
floor_t = 3;           // est.  floor thickness
wall_t = 3;            // est.  wall thickness
wall_in_side = 14;     // est.  outer edge -> wall outer face at the floor, long sides
wall_in_end = 8;       // est.  ... at the ends

/* [Floor] */
pan_inset_side = 31;   // est.  outer edge -> bay cutout, long sides
pan_inset_in = 18;     // est.  ... inboard end
pan_inset_out = 20;    // est.  ... outboard end
div_frac = [0.283, 0.535, 0.743];  // est.  divider centres along the opening
div_w = 8;             // est.  divider width at the floor
bay_r = 10;            // est.  bay cutout corner radius
chamfer_h = 12;        // flange underside chamfer height
keel_h = 8;            // divider keel: how far the 45-degree faces reach

/* [Stud bosses] */
boss_d = 10;           // est.
boss_h = 8;            // est.  above the floor's rear face
pad_w = 14;            // est.  square pad under the boss, reaching the wall
pad_h = 3;             // est.

/* [Mounting plate] */
mp_z = 34;             // est.  front face -> the plate's front face (35..42 from the photos)
mp_t = 3;              // est.
mp_straight = 42;      // est.  straight run from the end wall to the curl
mp_r = 15;             // est.  curl radius (centreline)
mp_angle = 90;         // est.  curl angle, toward the lens side
mp_tail = 6;           // est.  straight tail after the curl
mp_h = 145;            // est.  plate height
mp_fillet = 8;         // est.  fillet between the plate's back and the end wall (capped by the step)
notch_w = 20;          // est.  notch at the far bottom corner
notch_h = 26;          // est.

/* [Test piece and section] */
test_stud = 1;         // stud the test slice is centred on (0..3, inboard first)
test_len = 60;         // slice length along the top edge
test_w = 45;           // slice reach in from the outer edge
section_x = 250;       // x of the cut shown by part = "section"

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
function div_x(j) = opening_x0 + opening_len * div_frac[j];
function stud_y(x, s) = s > 0 ? y_top - stud_inset : y_bot(x) + stud_inset;

wall_out_front = skirt_t + groove_w;   // wall outer face at the front plate
z_floor_front = -floor_z + floor_t;    // the floor's front face
// outer face of the end wall at depth z (drafts inward toward the floor)
function x_wall(z) = wall_out_front
  + (wall_in_end - wall_out_front) * (-z - face_t) / (floor_z - face_t);

function bay_x0(i) = i == 0 ? pan_inset_in : div_x(i - 1) + div_w / 2;
function bay_x1(i) = i == 3 ? body_len - pan_inset_out : div_x(i) - div_w / 2;

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

// the outline inset by dx_in (inboard end), dx_out (outboard end), dy (sides)
module outline_in(dx_in, dx_out, dy, ra = undef, rb = undef) {
  x0 = dx_in;
  x1 = body_len - dx_out;
  rr(x0, x1, y_bot(x0) + dy, y_bot(x1) + dy, y_top - dy,
     is_undef(ra) ? r_in - max(dx_in, dy) : ra,
     is_undef(rb) ? r_out - max(dx_out, dy) : rb);
}

module outline_2d() { outline_in(0, 0, 0); }

module stud_circles(r) {
  for (i = [0 : 3], s = [1, -1])
    translate([stud_x(i), stud_y(stud_x(i), s)]) circle(r);
}

module lip_outside_2d() {   // lip loop, detouring inward round each stud
  offset(r = bulge_fillet) offset(delta = -bulge_fillet)
    difference() {
      outline_in(band_in, band_out, band_side, r_open_in, r_open_out);
      stud_circles(bulge_r);
    }
}

module opening_2d() { offset(r = -lip_w) lip_outside_2d(); }

// floor cutout of bay i, optionally stretched toward a neighbouring divider
module bay_2d(i, grow_in = 0, grow_out = 0) {
  x0 = bay_x0(i) - grow_in;
  x1 = bay_x1(i) + grow_out;
  rr(x0, x1, y_bot(x0) + pan_inset_side, y_bot(x1) + pan_inset_side,
     y_top - pan_inset_side, bay_r, bay_r);
}

module stroke_2d(path, w) { // round-ended stroke along a polyline
  for (i = [0 : len(path) - 2])
    hull() {
      translate(path[i]) circle(d = w);
      translate(path[i + 1]) circle(d = w);
    }
}

module slab(z) { translate([0, 0, z]) linear_extrude(0.01) children(); }

// ------------------------------------------------------------------- parts

module face() {
  translate([0, 0, -face_t])
    linear_extrude(face_t) difference() { outline_2d(); opening_2d(); }
}

module lip() {
  translate([0, 0, -0.01])
    linear_extrude(lip_h + 0.01)
      difference() { lip_outside_2d(); opening_2d(); }
}

module skirt() {
  translate([0, 0, -skirt_h])
    linear_extrude(skirt_h)
      difference() { outline_2d(); outline_in(skirt_t, skirt_t, skirt_t); }
}

// The block overlaps the plate's back by 0.01; the cavity cut starts 0.02 in,
// so no skin of the block is left across the lens opening.
module shell_block() {      // drafted wall and floor, still solid
  hull() {
    slab(-face_t + 0.01) outline_in(wall_out_front, wall_out_front, wall_out_front);
    slab(-floor_z) outline_in(wall_in_end, wall_in_end, wall_in_side);
  }
}

module cavity() {           // hollow behind the plate, chamfered into the floor
  w = wall_out_front + wall_t;
  hull() {
    slab(-face_t + 0.02) outline_in(w, w, w);
    slab(z_floor_front + chamfer_h)
      outline_in(wall_in_end + wall_t, wall_in_end + wall_t, wall_in_side + wall_t);
    slab(z_floor_front)
      outline_in(pan_inset_in - 1, pan_inset_out - 1, pan_inset_side - 1);
  }
}

module bay_cuts() {         // through the floor; keels form between them
  for (i = [0 : 3]) {
    gi = (i > 0 && keels) ? keel_h : 0;
    go = (i < 3 && keels) ? keel_h : 0;
    hull() {
      slab(-floor_z - 0.01) bay_2d(i);
      slab(z_floor_front) bay_2d(i);
      slab(z_floor_front + keel_h) bay_2d(i, gi, go);
    }
  }
}

module bosses() {           // on the floor's rear face, pad reaching the wall
  for (i = [0 : 3], s = [1, -1]) {
    x = stud_x(i);
    y = stud_y(x, s);
    y_wall = s > 0 ? y_top - wall_in_side : y_bot(x) + wall_in_side;
    y0 = s > 0 ? y - boss_d / 2 - 1 : y_wall;
    y1 = s > 0 ? y_wall : y + boss_d / 2 + 1;
    translate([x, y, -floor_z - boss_h]) cylinder(d = boss_d, h = boss_h + 0.01);
    translate([x - pad_w / 2, y0, -floor_z - pad_h]) cube([pad_w, y1 - y0, pad_h + 0.01]);
  }
}

module stud_holes() {
  for (i = [0 : 3], s = [1, -1])
    translate([stud_x(i), stud_y(stud_x(i), s), -floor_z - boss_h - 1])
      cylinder(d = stud_hole_d, h = floor_z + boss_h + lip_h + 2);
}

// mounting plate: profile in the x-z plane, extruded along y
module wing_profile_2d() {
  zc = -mp_z - mp_t / 2;                  // plate centreline
  zb = -mp_z - mp_t;                      // plate back face
  x1 = -mp_straight;                      // the curl starts here
  a_end = 270 - mp_angle;
  n = max(6, ceil(mp_angle / 6));
  p_end = [x1 + mp_r * cos(a_end), zc + mp_r + mp_r * sin(a_end)];
  path = concat(
    [[x_wall(zc) + wall_t / 2, zc]],      // root buried in the end wall
    [for (i = [0 : n]) let (a = 270 - mp_angle * i / n)
        [x1 + mp_r * cos(a), zc + mp_r + mp_r * sin(a)]],
    [p_end + mp_tail * [sin(a_end), -cos(a_end)]]
  );
  stroke_2d(path, mp_t);
  // fillet in the corner between the plate's back face and the end wall;
  // it can only be as deep as the step down to the floor's rear face
  f = min(mp_fillet, floor_z + zb);
  if (f > 0.2)
    translate([x_wall(zb) - f, zb - f])
      difference() {
        square([f + 2, f]);
        circle(r = f);
      }
}

module wing() {
  y_mid = (y_top + y_bot(0)) / 2;
  x_far = -(mp_straight + mp_r + mp_t / 2);
  difference() {
    translate([0, y_mid, 0]) rotate([90, 0, 0])
      linear_extrude(mp_h, center = true) wing_profile_2d();
    translate([x_far - 1, y_mid - mp_h / 2 - 1, -floor_z - 1])
      cube([notch_w + 1, notch_h + 1, floor_z + 2]);
  }
}

// ---------------------------------------------------------------- assembly

module frame_positive(with_lip = true, wing_on = with_wing) {
  difference() {
    union() {
      face();
      if (with_lip) lip();
      skirt();
      shell_block();
      bosses();
      if (wing_on) wing();
    }
    cavity();
    bay_cuts();
    stud_holes();
  }
}

module frame() {
  mirror([side == "R" ? 1 : 0, 0, 0]) frame_positive();
}

// A slice of the top edge round one stud: groove, stud hole, flange chamfer
// and boss, for test-fitting the gasket and a lens stud. Lip left off so
// the front face lies flat on the bed; it prints face down without support.
module test_piece() {
  xc = stud_x(test_stud);
  translate([-xc, -(y_top - test_w / 2), 0])
    mirror([0, 0, 1])
      intersection() {
        frame_positive(with_lip = false, wing_on = false);
        translate([xc - test_len / 2, y_top - test_w, -floor_z - boss_h - 1])
          cube([test_len, test_w + 5, floor_z + boss_h + 2]);
      }
}

// the mounting plate on its own, cut off at the end wall's outer face and
// stood on its long edge: the J profile is extruded straight up, so there
// is no overhang anywhere. Glue it to the end wall after printing.
module wing_print() {
  translate([0, 0, mp_h / 2]) rotate([-90, 0, 0])
    difference() { wing(); shell_block(); }
}

// cross-section at x = section_x: rear to the left, front face at the right
module section_2d() {
  projection(cut = true)
    rotate([0, 90, 0]) translate([-section_x, 0, 0]) frame_positive();
}

// ------------------------------------------------------------------ report

echo(str("frame ", body_len, " x ", h_in, "/", h_out, " mm; floor at -", floor_z,
         "; groove ", groove_w, " wide x ", skirt_h - face_t, " deep"));
echo(str("opening x ", opening_x0 + lip_w, " .. ", opening_x1 - lip_w,
         " (", opening_len - 2 * lip_w, " long)"));
echo(str("stud x ", [for (i = [0 : 3]) round(stud_x(i))],
         "  y +", y_top - stud_inset, " / ", [for (i = [0 : 3]) round(y_bot(stud_x(i)) + stud_inset)]));
echo(str("divider x ", [for (j = [0 : 2]) round(div_x(j))],
         "  bays ", [for (i = [0 : 3]) round(bay_x1(i) - bay_x0(i))]));
echo(str("plate: back face ", mp_z + mp_t, " behind the front face, step to the floor ",
         floor_z - mp_z - mp_t, ", reach ", mp_straight + mp_r + mp_t / 2, " inboard"));

// ------------------------------------------------------------------ render

if (part == "frame")
  color([0.72, 0.72, 0.75]) frame();
else if (part == "test")
  color([0.85, 0.6, 0.3]) test_piece();
else if (part == "wing")
  color([0.85, 0.6, 0.3]) wing_print();
else if (part == "section")
  section_2d();
