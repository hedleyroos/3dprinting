// ============================================================
// 90 Degree Beam Corner Jig
//
// A right-angle channel jig for holding two large timber beams
// square to each other while they are glued, screwed or bolted.
//
// The jig is an L-shaped tray that drops down over the corner
// from above. Each arm is a full U-groove: an outer wall and an
// inner wall capture BOTH side faces of its beam, so the beams
// cannot splay or twist. The top plate holds them coplanar.
//
// The two outer walls meet at the origin and form the 90 degree
// reference; the two inner walls form a matching 90 degree
// reference at (gb, ga). The corner square itself is left open
// (no inner walls) so it works whichever beam runs through and
// whichever butts into it.
//
// Coordinate system (as used, "demo" part):
//   Origin  = outer corner of the joint.
//   +X      = along beam A, +Y = along beam B.
//   z = 0   = top face of the beams / underside of the plate.
//   Plate occupies z = 0 .. plate_thickness.
//   Walls hang down, z = -groove_depth .. 0.
//
// The "jig" part flips this so the plate lies on the bed and the
// walls point up — prints as a shallow tray, no supports, and the
// layer lines run across the walls rather than along the joint.
//
// Print two and use them as a pair, one gripping the top of the beams
// and one the bottom. Turn the lower one over about the diagonal of its
// own corner and its grooves land back on the same two beams. See
// part = "pair".
//
// Note that turning it over is the ONLY way to invert it and still land
// on the same beams, and that rotation swaps the two arms. So anything
// asymmetric between the arms — see t_relief — swaps over with it, and
// the two halves of a pair are then not the same print.
//
// It does T joints as well as L joints; see t_relief.
//
// Standalone — no external dependencies.
//
// All units: millimeters.
// ============================================================

/* [Beams] */
beam_a_width  = 38;   // Width of beam A, measured across the X arm
beam_b_width  = 38;   // Width of beam B, measured across the Y arm
beam_depth    = 220;  // Beam depth — the dimension the walls reach down
groove_depth  = 20;   // How far the walls reach down the beam sides
clearance     = 0.8;  // Slip fit added to each groove width

/* [Jig] */
arm_length      = 150;  // Length of each arm, from the outer corner
plate_thickness = 5;    // Top plate thickness
wall_thickness  = 5;    // Wall thickness
fillet_radius   = 4;    // Fillet at the root of every wall
lead_in         = 2;    // Chamfer flaring the mouth of the grooves

/* [T Joint] */
// Gap the outer wall where it crosses a groove, so that beam can run
// straight on through the corner instead of ending at it — which turns
// the L jig into a T jig. The plate is untouched: it passes over the
// through beam, so the jig loses no stiffness.
//   "none" — L joint only, both outer walls continuous
//   "a"    — beam A runs through, beam B butts into it
//   "b"    — beam B runs through, beam A butts into it
//   "both" — either. The ONLY setting where a top-and-bottom pair of the
//            same printed part both open the same way — see part = "pair"
t_relief = "a";  // [none, a, b, both]

/* [Fixings] */
screw_holes    = false;  // Holes through the walls for temporary screws
screw_diameter = 5.5;    // Clearance diameter (5.5 suits a 5 mm screw)

/* [Demo] */
demo_beam_overrun = 90;  // Beam length beyond the jig, demo parts only

/* [Quality] */
$fa = 1;
$fs = 0.4;

/* [Render] */
part = "jig";  // [jig, demo, pair]

// ============================================================
// DERIVED
// ============================================================

ga = beam_a_width + clearance;   // Groove width of the X arm
gb = beam_b_width + clearance;   // Groove width of the Y arm
wt = wall_thickness;
pt = plate_thickness;
al = arm_length;

eps = 0.01;

// Sanity guards — these would produce inverted geometry rather than
// an obvious error, so fail loudly instead.
assert(al > max(ga, gb) + wt,
       "arm_length must be longer than the wider groove plus a wall");
assert(groove_depth > fillet_radius + lead_in,
       "groove_depth must exceed fillet_radius + lead_in");
// A top and a bottom jig grip opposite ends of the same beam depth, so
// between them they must not meet in the middle.
assert(2 * groove_depth < beam_depth,
       "groove_depth must be under half beam_depth, or a top and bottom jig collide");
assert(t_relief == "none" || t_relief == "a" || t_relief == "b" || t_relief == "both",
       "t_relief must be none, a, b or both");

// ============================================================
// 2D OUTLINES
// ============================================================

// Groove cavity of the X arm — open at x = al, closed at x = 0.
module cavity_a() {
    square([al, ga]);
}

// Groove cavity of the Y arm — open at y = al, closed at y = 0.
module cavity_b() {
    square([gb, al]);
}

// The full L-shaped cavity.
module cavity_outline() {
    cavity_a();
    cavity_b();
}

// Footprint of the walls: each cavity grown by one wall thickness on
// its outer and inner edge. The two outer walls run right through the
// corner and meet there — that continuous corner is what sets the
// 90 degree reference, and it ties the two arms together.
module wall_outline() {
    translate([-wt, -wt]) square([al + wt, ga + 2 * wt]);
    translate([-wt, -wt]) square([gb + 2 * wt, al + wt]);
}

// Footprint of the top plate: the wall footprint plus fillet_radius on
// every outboard face. That overhang is the ledge the wall-root fillets
// stand on — see wall_fillets().
module plate_outline() {
    fr = fillet_radius;
    translate([-wt - fr, -wt - fr]) square([al + wt + fr, ga + 2 * (wt + fr)]);
    translate([-wt - fr, -wt - fr]) square([gb + 2 * (wt + fr), al + wt + fr]);
}

// ============================================================
// MODULES
// ============================================================

// The wall band, before the groove is cut out of it.
module wall_blank() {
    translate([0, 0, -groove_depth])
        linear_extrude(height = groove_depth)
            wall_outline();
}

// The top plate.
module plate() {
    linear_extrude(height = pt) plate_outline();
}

// The L-shaped groove, plus a 45 degree flare at its mouth so the
// jig drops onto rough-sawn timber without fighting.
module groove() {
    translate([0, 0, -groove_depth - 1])
        linear_extrude(height = groove_depth + 1 + eps)
            cavity_outline();

    // Flared mouth — one hull per arm, since the L is not convex.
    hull() {
        translate([0, 0, -groove_depth + lead_in])
            linear_extrude(height = eps) cavity_a();
        translate([0, 0, -groove_depth - 1])
            linear_extrude(height = eps) offset(delta = lead_in + 1) cavity_a();
    }
    hull() {
        translate([0, 0, -groove_depth + lead_in])
            linear_extrude(height = eps) cavity_b();
        translate([0, 0, -groove_depth - 1])
            linear_extrude(height = eps) offset(delta = lead_in + 1) cavity_b();
    }
}

// A fillet prism running along +X, occupying y = 0..r and z = -r..0.
// Fills the concave corner made by a wall face on the XZ plane (wall
// body at y < 0) meeting the plate underside at z = 0.
module fillet_prism(len, r) {
    rotate([0, 90, 0])
        linear_extrude(height = len)
            polygon([[0, 0], [0, r], [r, 0]]);
}

// Fillets at the root of all four wall runs. These carry the bending
// load where the walls meet the plate — the weakest place in a printed
// part, since it is a layer boundary.
//
// They sit on the OUTBOARD face of every wall, never inside a groove.
// A fillet on the groove side would pack out the corner the beam's own
// arris has to occupy, so the beam would ride up on the two slopes
// instead of seating flat against the plate and registering on the wall
// faces. That is why plate_outline() carries fillet_radius of extra
// plate beyond each outboard face — it is the ledge these sit on.
module wall_fillets() {
    r = fillet_radius;

    // Outer wall of the X arm — outboard face at y = -wt.
    translate([al, -wt, 0]) rotate([0, 0, 180])
        fillet_prism(al + wt + r, r);

    // Outer wall of the Y arm — outboard face at x = -wt.
    translate([-wt, -wt - r, 0]) rotate([0, 0, 90])
        fillet_prism(al + wt + r, r);

    // Inner wall of the X arm — outboard face at y = ga + wt.
    translate([gb, ga + wt, 0])
        fillet_prism(al - gb, r);

    // Inner wall of the Y arm — outboard face at x = gb + wt.
    translate([gb + wt, al, 0]) rotate([0, 0, -90])
        fillet_prism(al - ga, r);
}

// Gaps cut through the outer wall — and its root fillet — where a beam
// runs on through the corner. Cut to exactly z = 0, so the plate above
// is left whole.
module t_relief_cuts() {
    fr = fillet_radius;

    // Across the end of the X arm's groove, freeing beam A.
    if (t_relief == "a" || t_relief == "both")
        translate([-wt - fr - 1, 0, -groove_depth - 1])
            cube([wt + fr + 1, ga, groove_depth + 1]);

    // Across the end of the Y arm's groove, freeing beam B.
    if (t_relief == "b" || t_relief == "both")
        translate([0, -wt - fr - 1, -groove_depth - 1])
            cube([gb, wt + fr + 1, groove_depth + 1]);

    // With both grooves freed, the block where the two outer walls used
    // to meet is left touching neither beam and hanging off the plate on
    // its own — a spindly stub that would only snap off. Take it away.
    if (t_relief == "both")
        translate([-wt - fr - 1, -wt - fr - 1, -groove_depth - 1])
            cube([wt + fr + 1, wt + fr + 1, groove_depth + 1]);
}

// A single horizontal hole, axis along +Y, drilled through a wall.
module wall_hole() {
    translate([0, -1, -groove_depth / 2])
        rotate([-90, 0, 0])
            cylinder(h = wt + 2, d = screw_diameter);
}

// Clearance holes so the jig can be screwed to the beams while the
// joint is fixed, then unscrewed and lifted off.
module screw_cuts() {
    // Outer wall of the X arm.
    for (f = [0.35, 0.72])
        translate([al * f, -wt, 0]) wall_hole();

    // Outer wall of the Y arm.
    for (f = [0.35, 0.72])
        translate([-wt, al * f, 0]) rotate([0, 0, -90]) wall_hole();

    // Inner wall of the X arm.
    for (f = [0.4, 0.8])
        translate([gb + (al - gb) * f, ga + wt, 0]) rotate([0, 0, 180]) wall_hole();

    // Inner wall of the Y arm.
    for (f = [0.4, 0.8])
        translate([gb + wt, ga + (al - ga) * f, 0]) rotate([0, 0, 90]) wall_hole();
}

// The finished jig, in the orientation it is used in.
module jig() {
    difference() {
        union() {
            plate();
            difference() {
                wall_blank();
                groove();
            }
            wall_fillets();
        }
        if (screw_holes) screw_cuts();
        t_relief_cuts();
    }
}

// Ghost beams, for checking the fit.
module demo_beams() {
    t = beam_depth;
    o = demo_beam_overrun;

    // A freed groove is drawn with its beam running on through the
    // corner, so the demo shows the joint the current t_relief allows:
    // an L when nothing is freed, a T when something is.
    a_start = t_relief == "b" ? beam_b_width
            : t_relief == "none" ? 0
            : -o;
    b_start = t_relief == "b" ? -o : beam_a_width;

    // Beam A — runs along X.
    translate([a_start, 0, -t])
        cube([al + o - a_start, beam_a_width, t]);

    // Beam B — runs along Y.
    translate([0, b_start, -t])
        cube([beam_b_width, al + o - b_start, t]);
}

// ============================================================
// RENDER
// ============================================================
// This is a one-piece model, so the usual bottom/top/both/exploded
// selector does not apply. "jig" is the print orientation, "demo" shows
// one jig working on a corner, and "pair" shows two of the same printed
// part gripping the beams top and bottom.

if (part == "jig") {
    // Flip so the plate lies on the bed and the walls point up:
    // no supports, and the walls print with their layers stacked
    // across the direction the beams push.
    translate([-(al - wt) / 2, (al - wt) / 2, pt])
        rotate([180, 0, 0])
            jig();

} else if (part == "demo") {
    jig();
    %demo_beams();

} else if (part == "pair") {
    // The lower jig is turned over about the diagonal of its own corner
    // — a real 180 degree rotation, not a mirror — which lands its
    // grooves back on the same two beams. Only works while the two beams
    // are the same width.
    assert(beam_a_width == beam_b_width,
           "a pair needs equal beam widths, otherwise print a mirrored second jig");
    // That rotation swaps the arms, so it swaps which groove is freed.
    if (t_relief == "a" || t_relief == "b")
        echo("NOTE: with t_relief a or b the pair is two DIFFERENT prints — print the other setting for the lower jig, or use t_relief = \"both\" for one part that does either.");
    jig();
    translate([0, 0, -beam_depth]) rotate(a = 180, v = [1, 1, 0]) jig();
    %demo_beams();

} else {
    echo("Unknown part — use \"jig\", \"demo\" or \"pair\"");
}
