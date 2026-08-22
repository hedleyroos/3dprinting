// ============================================================
// Avocado Seed Rings — four circles joined in a square, on legs
//
// Four rings of equal diameter, centred on the corners of a
// square and sized so that neighbouring rings just touch.  Like
// the Olympic rings in spirit, but laid out 2 x 2 and NOT
// overlapping: each adjacent pair meets at a single tangent
// point, and that point is filleted so the join is a real,
// printable web rather than a knife edge.
//
// The two diagonal pairs do not touch — the four joins run
// around the square, leaving an open curved-square window in the
// middle.
//
// Four plain cylindrical legs stand the ring frame off the
// ground, one on the outward diagonal of each ring.  Each leg is
// pushed out until its inner face is tangent to that ring's
// bore, so no part of a leg ever intrudes into the circle — the
// opening stays a clean, full 40 mm.  The ring is bulged outward
// with a boss to carry the leg, and the boss blends into the
// ring with the same fillet used on the joins.  Stand it in the
// tub, fill the tub to just under the rings, and each seed hangs
// with its base in the water.
//
// Geometry note:  the join is made with a morphological
// "closing" — grow the four outer discs by fillet_r, then shrink
// them back by the same amount.  Convex boundary comes back
// exactly to the original diameter, while the cusp at each
// tangent point is filled with a fillet_r arc.  The ring holes
// are cut afterwards, so they stay perfectly circular.
//
// Printing — one piece, no supports, no split, but print it
// UPSIDE DOWN: ring frame flat on the bed, legs pointing up.
//   * The legs then rise as plain vertical columns off a large,
//     well-stuck first layer.  Printed the other way up, the
//     entire ring plate would be a 40 mm-high island needing
//     full support.
//   * The legs are plain cylinders meeting the plate square on,
//     which in that orientation is a flat face growing straight
//     off the first layer — nothing overhangs.
//   * The service load is the frame plus four wet seeds pressing
//     straight down the legs — pure compression along the leg
//     axis, which does not care about layer adhesion.  A
//     sideways knock loads the leg layers in shear, which is the
//     weak direction, so keep the legs stout rather than slim.
//   * part="print" is the default and is already flipped into
//     that orientation, ready to slice.  part="frame" shows it
//     the right way up, as it stands in use.
//
// Coordinate system:  X and Y in the plane of the square, Z up.
//   Origin at the centre of the assembly, on the underside of
//   the feet.  Modelled the way it stands in use, legs down.
//
// All units: millimetres.  Standalone — no external dependencies.
// ============================================================

/* [View] */
part        = "print";  // print | frame | plate | single

/* [Quality] */
$fa         = 1;    // Minimum angle — 1 degree gives max 360 facets per full circle
$fs         = 0.4;  // Minimum facet edge length (mm) — matched to a 0.4 mm nozzle

/* [Rings] */
circle_d    = 50;   // OUTER diameter of each circle
ring_w      = 5;    // Radial wall thickness of the ring
ring_h      = 8;    // Thickness in Z

/* [Join] */
fillet_r    = 6;    // Fillet radius where two rings touch
overlap     = 0;    // Pull the centres together by this much.
                    // 0 = tangent (touching, not overlapping).

/* [Legs] */
leg_h       = 30;   // Ground to the underside of the ring frame
leg_d       = 8;    // Leg diameter (plain cylinder, no flare)
leg_boss_w  = 1.5;  // Material around the leg where the ring bulges out
leg_clear   = 0;    // Extra push outward beyond bore-tangent. 0 = the leg's
                    // inner face sits flush with the bore wall.

// ============================================================
// Derived
// ============================================================

eps      = 0.01;
outer_r  = circle_d / 2;
hole_d   = circle_d - 2 * ring_w;   // Clear opening through each ring
hole_r   = hole_d / 2;
spacing  = circle_d - overlap;      // Centre-to-centre, both axes
half_sp  = spacing / 2;

// The four ring centres, at the corners of the square.
centres  = [for (x = [-1, 1], y = [-1, 1]) [x * half_sp, y * half_sp]];

// Leg axes: outward along each ring's diagonal, far enough out
// that the leg is tangent to the bore and never eats into it.
leg_off  = hole_r + leg_d / 2 + leg_clear;
boss_r   = leg_d / 2 + leg_boss_w;
diag     = 1 / sqrt(2);
leg_pos  = [for (c = centres)
                [c[0] + sign(c[0]) * diag * leg_off,
                 c[1] + sign(c[1]) * diag * leg_off]];

echo(str("Ring outer d = ", circle_d, " mm, clear hole d = ", hole_d,
         " mm, plate = ", spacing + circle_d, " mm square, ",
         "overall height = ", leg_h + ring_h, " mm"));

// ============================================================
// Modules
// ============================================================

// Union of the four outer discs plus the four leg bosses, with
// every cusp — ring to ring, and boss to ring — filled by a
// fillet_r arc.
module joined_discs_2d() {
    offset(r = -fillet_r)
        offset(r = fillet_r) {
            for (c = centres)
                translate(c)
                    circle(r = outer_r);
            for (p = leg_pos)
                translate(p)
                    circle(r = boss_r);
        }
}

// The four ring bores.
module holes_2d() {
    for (c = centres)
        translate(c)
            circle(r = hole_r);
}

module plate_2d() {
    difference() {
        joined_discs_2d();
        holes_2d();
    }
}

// The ring frame, sitting on top of the legs.
module plate() {
    translate([0, 0, leg_h])
        linear_extrude(height = ring_h)
            plate_2d();
}

// One leg: a plain cylinder, ground up to the frame underside.
module leg() {
    cylinder(h = leg_h + eps, d = leg_d);
}

module legs() {
    for (p = leg_pos)
        translate([p[0], p[1], 0])
            leg();
}

module frame() {
    union() {
        plate();
        legs();
    }
}

// One ring on its own, for a quick fit test.
module single_ring() {
    linear_extrude(height = ring_h)
        difference() {
            circle(r = outer_r);
            circle(r = hole_r);
        }
}

// ============================================================
// Render
// ============================================================

if (part == "frame") {
    frame();
} else if (part == "print") {
    // Flipped for the bed: ring frame down, legs up.
    translate([0, 0, leg_h + ring_h])
        rotate([180, 0, 0])
            frame();
} else if (part == "plate") {
    translate([0, 0, -leg_h])
        plate();
} else if (part == "single") {
    single_ring();
} else {
    echo("Unknown part; use frame | print | plate | single");
    frame();
}
