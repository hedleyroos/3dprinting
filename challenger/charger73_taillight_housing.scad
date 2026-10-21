// ============================================================================
//  1973 Dodge Charger tail-light housing  (the user's LEFT light:
//  left as seen from behind the car)  --  parametric OpenSCAD model, all mm.
//
//  Orientation (user-confirmed):
//    * rounded end OUTBOARD, flat plate ("wing") end INBOARD
//    * harness at the TOP edge; steel mounting tab + text baseline at BOTTOM
//    * inboard plate curls toward the LENS side (+z)
//    * rim under the gasket is FLAT; ONE raised lip loop around all four bays
//    * 8 rear bosses take the lens studs (nuts from behind)
//
//  Frame: x = 0 at the inboard end of the body (plate root), +x outboard,
//         y = 0 on the centreline (up +), z = front rim plane +, shell back -.
//  Bays from the inboard plate end:  bowl1 | bowl2 | flat | bowl3 | rounded end
//
//  side = "L" reproduces the part as photographed; "R" mirrors it.
//
//  EVERY value marked `// est.` is a photo-calibrated estimate:
//  replace with tape (group A) / caliper (group B) readings, see MEASUREMENTS.md
// ============================================================================

/* [Side and part] */
side = "L";            // [L, R]
part = "all";          // [all, plate, 1, 2, 3, 4, keys, splice]
quality = "final";     // [fast, final]

/* [A fit - tape] */
body_len = 610;        // est.  front rim length, plate excluded
body_h = 140;          // est.  front rim height
rear_inset_end = 8;    // est.  rear outline smaller: per end (draft)
rear_inset_side = 5;   // est.  rear outline smaller: per side (draft)
r_out = 60;            // est.  outboard front corners (near-semicircular end)
r_in = 15;             // est.  inboard front corners
r_rear = 14;           // est.  rear outline inboard corners
rim_w_side = 24;       // est.  flat band (gasket seat) outer edge -> lip, sides
rim_w_inboard = 22;    // est.  ... at the inboard end
rim_w_outboard = 30;   // est.  ... at the outboard end
bowl1_w = 141;         // est.  bay widths from the inboard end
div1_w = 10;           // est.  divider widths between bays
bowl2_w = 145;         // est.
div2_w = 5;            // est.
flat_w = 110;          // est.
div3_w = 5;            // est.
bowl3_w = 138;         // est.
bay_r = 10;            // est.  bay corner radius
bay_out_r = 25;        // est.  bay 3 outboard corners (follows the end radius)
opening_r_in = 8;      // est.  opening inboard corners
stud_x_in = [90, 250, 395, 540];   // est. lens stud x positions (4 x top & bottom)
stud_y = 50;           // est.  lens stud distance from centreline
shell_depth = 45;      // est.  front rim -> rear floor plane
bowl_depth = 55;       // est.  floor -> dome apex

/* [B detail - calipers] */
wall_t = 3;            // est.
floor_t = 3;           // est.  (floor keys: groove depth follows this!)
lip_w = 2.5;           // est.  raised lip loop width
lip_h = 2.5;           // est.  raised lip loop height
stud_hole_d = 6;       // est.  hole through the rim bulge
bulge_r = 13;          // est.  lip bulge radius around each stud
channel_r = 13;        // est.  stud channel radius behind each bulge
channel_depth = 46;    // est.  channel reach from the rim (46 = through floor)
boss_d = 12;           // est.  rear boss diameter
boss_h = 8;            // est.  rear boss height
boss_hole_d = 6.5;     // est.  rear boss hole (stud clearance)
socket_d = 27;         // est.  socket hole
socket_pad_d = 45;     // est.  flat pad / dome apex diameter
socket_notch_n = 2;    // est.  socket bayonet notches
socket_notch_w = 5;    // est.  notch width
socket_notch_d = 2;    // est.  notch depth beyond the hole
socket_land_h = 2;     // est.  pad land height at the apex
bowl_curve = 1.3;      // est.  dome fullness (1 = straight cone)
flat_hole_d = 6;       // est.  flat bay holes
flat_hole_dx = 20;     // est.  ... at +/- this from the bay centre
flat_hole_y = -15;     // est.
flat_pan_inset = 10;   // est.  flat-bay raised pan margin on the rear
flat_pan_h = 3;        // est.
wing_ext = 35;         // est.  plate projection inboard (from x = 0)
wing_r = 15;           // est.  plate curl radius
wing_angle = 90;       // est.  plate curl angle
wing_tail = 10;        // est.  straight tail after the curl
wing_t = 3;            // est.  plate thickness
wing_z0 = -27.5;       // est.  plate root position below the rim plane
steel_tab_x = 380;     // est.  steel tab position (bottom edge)
steel_tab_w = 20;      // est.
steel_tab_t = 3;       // est.
steel_tab_l = 33;      // est.  rearward
steel_tab_hole_d = 6;  // est.
bracket_w = 25;        // est.  rear brackets at bowl1|div1 and div3|bowl3
bracket_t = 3;         // est.
bracket_l = 30;        // est.  rearward
bracket_hole_d = 4;    // est.
end_rib_w = 3;         // est.  rib at the outboard end of the rear
end_rib_protrude = 8;  // est.
show_sae_text = false; // text is 1 mm raised; off for printing
sae_size = 13;         // est.

/* [C print] */
bed = 250;             // [100, 180, 200, 220, 250, 300]  printer bed size
bed_margin = 5;        // keep sections smaller than this
dowel_d = 3.2;         // est.  alignment pins (3 mm filament)
dowel_l = 20;          // est.  pin length -> 10 mm into each section
dowel_clear = 0.3;     // hole clearance for the pins
key_l = 24;            // key blocks: length along x (12 each side of a split)
key_w = 8;             // key cross-section
key_h = 8;             // wall keys: height into the cavity
floor_key_h = 1.4;     // floor keys: height (floor_t is only ~3!)
key_clear = 0.4;       // pocket clearance
splice_l = 40;         // optional splice plate
splice_w = 20;
splice_t = 4;
$fn = (quality == "final") ? 96 : 32;
bowl_slices = (quality == "final") ? 20 : 8;

// --------------------------------------------------------------- functions

function clampv(v, lo, hi) = min(max(v, lo), hi);
function opening_len() = body_len - rim_w_inboard - rim_w_outboard;
function opening_h() = body_h - 2 * rim_w_side;

// bay left edges before scaling (bays and dividers laid out from inboard)
function bay_raw() = [
  0,
  bowl1_w, bowl1_w + div1_w,
  bowl1_w + div1_w + bowl2_w, bowl1_w + div1_w + bowl2_w + div2_w,
  bowl1_w + div1_w + bowl2_w + div2_w + flat_w,
  bowl1_w + div1_w + bowl2_w + div2_w + flat_w + div3_w,
  bowl1_w + div1_w + bowl2_w + div2_w + flat_w + div3_w + bowl3_w
];
function bay_scale() = opening_len() / bay_raw()[7];
// scaled positions (x) of the 8 bay/divider edges between rim bands
function bay_edges() = [for (e = bay_raw()) rim_w_inboard + e * bay_scale()];
function bay_cx(i) = (bay_edges()[2 * i] + bay_edges()[2 * i + 1]) / 2;  // i = 0..3
function bay_w(i) = bay_edges()[2 * i + 1] - bay_edges()[2 * i];
function div_cx(j) = (bay_edges()[2 * j + 1] + bay_edges()[2 * j + 2]) / 2;  // j = 0..2
function div_w(j) = bay_edges()[2 * j + 2] - bay_edges()[2 * j + 1];
// print split planes: divider centres
function splits_default() = [div_cx(0), div_cx(1), div_cx(2)];

// dome shape: fraction of size/depth travelled at parameter t
// bowl_curve = 1 -> straight cone, > 1 -> fuller (bell) dome
function be(t) = let (kk = max(bowl_curve, 1))
  t + (1 - cos(90 * t) - t) * (kk - 1) / kk;

// ------------------------------------------------------------ 2D utilities

module rrect4(w, h, rr) {   // rounded rect, centred; rr = [bl, br, tr, tl]
  r = [for (v = rr) clampv(v, 0.5, min(w, h) / 2)];
  hull() {
    translate([-w / 2 + r[0], -h / 2 + r[0]]) circle(r[0]);
    translate([ w / 2 - r[1], -h / 2 + r[1]]) circle(r[1]);
    translate([ w / 2 - r[2],  h / 2 - r[2]]) circle(r[2]);
    translate([-w / 2 + r[3],  h / 2 - r[3]]) circle(r[3]);
  }
}

module slab(z) {            // thin extrusion of a 2D child at height z
  translate([0, 0, z]) linear_extrude(0.01) children();
}

module stroke2d(path, w) {  // round-capped stroke along a polyline
  for (i = [0 : len(path) - 2])
    hull() {
      translate(path[i]) circle(w / 2);
      translate(path[i + 1]) circle(w / 2);
    }
}

// -------------------------------------------------------------- 2D outlines

module front_outline() {
  translate([body_len / 2, 0])
    rrect4(body_len, body_h, [r_in, r_out, r_out, r_in]);
}

module rear_outline() {
  translate([body_len / 2, 0])
    rrect4(body_len - 2 * rear_inset_end, body_h - 2 * rear_inset_side,
           [r_rear, r_out - rear_inset_end, r_out - rear_inset_end, r_rear]);
}

module inner_rear() {
  offset(delta = -wall_t) rear_outline();
}

module opening_2d() {       // lens opening (inside the lip)
  translate([body_len / 2, 0])
    rrect4(opening_len(), opening_h(),
           [opening_r_in, bay_out_r, bay_out_r, opening_r_in]);
}

module opening_bulged() {   // opening + the 8 stud bulges
  union() {
    opening_2d();
    for (sx = stud_x_in)
      for (s = [1, -1])
        translate([sx, s * stud_y]) circle(bulge_r);
  }
}

module lip_2d() {
  difference() {
    offset(delta = lip_w) opening_bulged();
    opening_bulged();
  }
}

module rim_2d() {           // everything outside the opening (for bulge clips)
  difference() {
    translate([body_len / 2, 0])
      square([3 * body_len, 4 * body_h], center = true);
    opening_2d();
  }
}

// -------------------------------------------------------------- shell parts

module shell_outer() {
  hull() { slab(0) front_outline(); slab(-shell_depth) rear_outline(); }
}

module shell_cavity() {
  // cavity front slice sits just above the rim plane, so the flat rim band
  // (rim_w_*) comes out of the interpolation at z = 0
  hull() {
    slab(lip_h / 5) opening_2d();
    slab(-(shell_depth - floor_t)) inner_rear();
  }
}

module lip() {
  translate([0, 0, -0.5]) linear_extrude(lip_h + 0.5) lip_2d();
}

module bulge_bosses() {     // raised round boss at each stud (rim side only)
  for (sx = stud_x_in)
    for (s = [1, -1])
      intersection() {
        translate([sx, s * stud_y, -1]) cylinder(r = bulge_r, h = lip_h + 1);
        translate([0, 0, -1]) linear_extrude(lip_h + 1) rim_2d();
      }
}

module dividers() {         // flat recessed bands between the bays
  let (E = bay_edges())
    intersection() {
      union()
        for (j = [0 : 2])
          translate([E[2 * j + 1], -body_h / 2, -(shell_depth - floor_t) - 1])
            cube([div_w(j), body_h, (shell_depth - floor_t) + 1 - lip_h]);
      shell_outer();
    }
}

// -------------------------------------------------------------- bowl lofting

module bowl_slice(i, cx, w0, h0, r0, grow, z0) {
  t = i / (bowl_slices - 1);
  e = be(t);
  w = w0 + (socket_pad_d - w0) * e + 2 * grow;
  h = h0 + (socket_pad_d - h0) * e + 2 * grow;
  r = r0 + (socket_pad_d / 2 - r0) * e + grow;
  slab(z0 - bowl_depth * e) translate([cx, 0]) rrect4(w, h, [r, r, r, r]);
}

module bowl_loft(cx, w0, h0, r0, grow, z0) {
  for (i = [0 : bowl_slices - 2])
    hull() {
      bowl_slice(i, cx, w0, h0, r0, grow, z0);
      bowl_slice(i + 1, cx, w0, h0, r0, grow, z0);
    }
}

module bowls_outer() {      // three bells (bowl bays 0, 1, 3), grown by wall_t
  for (i = [0, 1, 3])
    bowl_loft(bay_cx(i), bay_w(i), opening_h(), bay_r, wall_t, -shell_depth);
}

module bowls_inner() {      // hollows; start above the rear face so the
  for (i = [0, 1, 3])       // cavity connects through the floor into the bell
    bowl_loft(bay_cx(i), bay_w(i), opening_h(), bay_r, 0,
              -(shell_depth - floor_t));
}

module socket_lands() {     // small land at each dome apex
  for (i = [0, 1, 3])
    translate([bay_cx(i), 0, -(shell_depth + bowl_depth) - socket_land_h])
      cylinder(d = socket_pad_d, h = socket_land_h + 0.6);
}

module socket_holes() {
  for (i = [0, 1, 3]) {
    translate([bay_cx(i), 0, -socket_d - shell_depth - bowl_depth - 2])
      cylinder(d = socket_d, h = 2 * socket_d + 8);
    for (j = [0 : socket_notch_n - 1])
      rotate([0, 0, 90 + 360 * j / max(socket_notch_n, 1)])
        translate([bay_cx(i) + socket_d / 2 + socket_notch_d / 2 - 0.5, 0,
                   -(shell_depth + bowl_depth) + 0.5])
          cube([socket_notch_w, socket_notch_d + 1, 2 * socket_land_h + 5],
               center = true);
  }
}

// ------------------------------------------------------- studs and channels

module stud_holes() {
  for (sx = stud_x_in)
    for (s = [1, -1])
      translate([sx, s * stud_y, -shell_depth + 1])
        cylinder(d = stud_hole_d, h = shell_depth + 9);
}

module channels() {         // groove behind each bulge, down to the boss
  for (sx = stud_x_in)
    for (s = [1, -1])
      translate([sx, s * stud_y, -channel_depth])
        cylinder(r = channel_r, h = channel_depth - 1);
}

// ------------------------------------------------------------ rear fittings

module flat_pan() {         // raised pan on the rear behind the flat bay
  translate([bay_cx(2), 0, -shell_depth - flat_pan_h])
    linear_extrude(flat_pan_h + 0.5)
      rrect4(bay_w(2) + 2 * flat_pan_inset, opening_h() + 2 * flat_pan_inset,
             [10, 10, 10, 10]);
}

module flat_holes() {
  for (s = [1, -1])
    translate([bay_cx(2) + s * flat_hole_dx, flat_hole_y,
               -shell_depth - flat_pan_h - 2])
      cylinder(d = flat_hole_d, h = flat_pan_h + shell_depth + 4);
}

module bosses() {
  for (sx = stud_x_in)
    for (s = [1, -1]) {
      translate([sx, s * stud_y, -shell_depth - boss_h])
        cylinder(d = boss_d, h = boss_h + 2);
      translate([sx, s * stud_y, -shell_depth - boss_h - 3])
        cylinder(d = boss_hole_d, h = boss_h + 5);
    }
}

module steel_tab() {
  y0 = -body_h / 2 + rear_inset_side;
  translate([steel_tab_x - steel_tab_w / 2, y0, -(shell_depth + steel_tab_l)])
    cube([steel_tab_w, steel_tab_t, steel_tab_l + 2]);
}

module rear_brackets() {
  y0 = -body_h / 2 + rear_inset_side;
  for (bx = [div_cx(0), div_cx(2)])
    translate([bx - bracket_w / 2, y0, -(shell_depth + bracket_l)])
      cube([bracket_w, bracket_t, bracket_l + 2]);
}

module fitting_holes() {    // screw holes through the tab / second bracket
  y0 = -body_h / 2 + rear_inset_side;
  translate([steel_tab_x, y0 + steel_tab_t / 2, -shell_depth - 25])
    rotate([90, 0, 0]) cylinder(d = steel_tab_hole_d, h = steel_tab_t + 6, center = true);
  translate([div_cx(2), y0 + bracket_t / 2, -shell_depth - 20])
    rotate([90, 0, 0]) cylinder(d = bracket_hole_d, h = bracket_t + 6, center = true);
}

module end_rib() {
  translate([body_len - rear_inset_end - 9, -25, -(shell_depth + end_rib_protrude)])
    cube([end_rib_w, 50, end_rib_protrude + 1.5]);
}

module sae_text() {
  translate([div_cx(0), -30, -shell_depth - 1.2])
    linear_extrude(1.3)
      scale([-1, 1]) text("SAE STIAR 73 W 22", size = sae_size, halign = "left");
  translate([div_cx(0), -46, -shell_depth - 1.2])
    linear_extrude(1.3)
      scale([-1, 1]) text("MOPAR 3674 812", size = sae_size * 0.8, halign = "left");
}

// -------------------------------------------------------------- inboard plate

module wing() {
  r = wing_r;
  inb = wing_ext - wing_t / 2;          // centreline reach of the inboard-most point
  x1 = -(inb - r);                      // straight part ends here
  n = max(6, round(wing_angle / 10));
  path = concat(
    [[8, wing_z0], [x1, wing_z0]],
    [for (i = [0 : n]) let (a = 270 - wing_angle * i / n)
        [x1 + r * cos(a), wing_z0 + r + r * sin(a)]],
    [[x1 - r, wing_z0 + r + wing_tail]]
  );
  translate([0, 0, 0]) rotate([90, 0, 0])
    linear_extrude(body_h, center = true) stroke2d(path, wing_t);
}

// --------------------------------------------------------- print keys/dowels

module key_grooves() {      // open keyways the printed keys sit in
  for (sx = [div_cx(0), div_cx(1), div_cx(2)]) {
    for (s = [1, -1])       // top / bottom walls (sloped: cut deep enough to open)
      translate([sx - key_l / 2, s > 0 ? 40 : -62, -26])
        cube([key_l, 22, 8]);
    for (s = [1, -1])       // floor (flat face: shallow groove)
      translate([sx - key_l / 2, s > 0 ? 48 : -56,
                 -(shell_depth - floor_t) - floor_key_h - 0.2])
        cube([key_l, 8, floor_key_h + 0.9]);
  }
}

module keys_printed() {     // the printed blocks (part = "keys")
  for (i = [0 : 5])
    translate([(i % 3) * (key_l + 4), floor((i / 3)) * (key_w + 4), 0])
      cube([key_l, key_w - key_clear, key_h]);
  for (i = [0 : 5])
    translate([(i % 3) * (key_l + 4), 24 + floor(i / 3) * 12, 0])
      cube([key_l, key_w - key_clear, floor_key_h]);
}

module dowels() {           // pin holes at the top/bottom walls of each split
  for (sx = [div_cx(0), div_cx(1), div_cx(2)])
    for (s = [1, -1])
      translate([sx, s * 61, -12])
        rotate([0, 90, 0])
          cylinder(d = dowel_d + dowel_clear, h = dowel_l, center = true);
}

module splice_plate() {
  difference() {
    cube([splice_l, splice_w, splice_t], center = true);
    for (s = [1, -1])
      translate([s * 15, 0, 0]) cylinder(d = dowel_d + dowel_clear, h = splice_t + 2, center = true);
  }
}

// ----------------------------------------------------------------- assembly

module housing_positive() {   // no cut planes: the printable master model
  difference() {
    union() {
      housing_positive_core();
      dividers();
    }
    key_grooves();
    dowels();
  }
}

// the shell/bowls/fittings part only (separated so dividers can be added
// after the cavity subtraction without being hollowed)
module housing_positive_core() {
  difference() {
    union() {
      shell_outer();
      lip();
      bulge_bosses();
      bowls_outer();
      socket_lands();
      flat_pan();
      bosses();
      steel_tab();
      rear_brackets();
      end_rib();
      wing();
      if (show_sae_text) sae_text();
    }
    shell_cavity();
    stud_holes();
    channels();
    bowls_inner();
    socket_holes();
    flat_holes();
    fitting_holes();
  }
}

module housing() {
  mirror([side == "R" ? 1 : 0, 0, 0]) housing_positive();
}

// ------------------------------------------------------------------ sections

module cut_box(x0, x1) {
  translate([(x0 + x1) / 2, 0, -60])
    cube([x1 - x0, 4 * body_h, 4 * (shell_depth + bowl_depth + 40)], center = true);
}

module section(n) {
  intersection() {
    housing();
    if (n == 1) cut_box(-80, div_cx(0));
    else if (n == 2) cut_box(div_cx(0), div_cx(1));
    else if (n == 3) cut_box(div_cx(1), div_cx(2));
    else cut_box(div_cx(2), body_len + 80);
  }
}

module plate_only() {
  intersection() { housing(); cut_box(-80, 2); }
}

// --------------------------------------------------------------------- facts

echo("== charger73 taillight housing ==");
echo("bay edges x", bay_edges());
echo("split x (dividers)", [div_cx(0), div_cx(1), div_cx(2)]);
echo("opening LxH", opening_len(), opening_h());
echo("depth total", shell_depth + bowl_depth + socket_land_h, " (rim to socket tip; +lip is", shell_depth + bowl_depth + socket_land_h + lip_h, ")");
echo("expected bbox X", -(wing_ext), "..", body_len, " Y", -body_h / 2, "..", body_h / 2,
     " Z", -(shell_depth + bowl_depth + socket_land_h), "..", lip_h);
echo("dowel holes", [for (sx = [div_cx(0), div_cx(1), div_cx(2)]) sx], " y +/-61  z -12");
for (n = [1 : 4]) {
  echo(str("section ", n, " extents approx"));
}

// --------------------------------------------------------------------- main

module main() {
  color([0.72, 0.72, 0.75]) {
    if (part == "all") housing();
    else if (part == "plate") plate_only();
    else if (part == "1") section(1);
    else if (part == "2") section(2);
    else if (part == "3") section(3);
    else if (part == "4") section(4);
    else if (part == "keys") color([0.85, 0.6, 0.3]) keys_printed();
    else if (part == "splice") color([0.85, 0.6, 0.3]) splice_plate();
  }
}

main();
