// ============================================================
// Paired Reinforcement Bracket on ABS Substrate
//
// Two mirrored copies of the single reinforcement bracket are
// mounted back-to-back on a shared flat substrate. The gap is
// measured as the clear distance between the inner upright faces.
//
// All units: millimeters.
// ============================================================

use <reinforcement_bracket.scad>

/* [Bracket Dimensions] */
// Keep these in sync with reinforcement_bracket.scad.
leg_length              = 30;
face_width              = 40;
material_thickness      = 8;

/* [Pair Layout] */
gap_between_brackets    = 32;    // Clear gap between inner upright faces

/* [Substrate] */
substrate_thickness     = 4;
substrate_end_margin    = 0;
substrate_side_margin   = 0;

/* [Quality] */
$fn                     = 96;
$fa                     = 2;
$fs                     = 0.4;

// ============================================================
// DERIVED
// ============================================================

substrate_length        = gap_between_brackets + 2 * leg_length + 2 * substrate_end_margin;
substrate_width         = face_width + 2 * substrate_side_margin;

// ============================================================
// GEOMETRY
// ============================================================

module substrate_plate() {
    translate([0, 0, substrate_thickness / 2])
        cube([substrate_length, substrate_width, substrate_thickness], center = true);
}

module upright_bracket() {
    rotate([90, 0, 0])
        reinforcement_bracket();
}

module left_bracket() {
    translate([-gap_between_brackets / 2, 0, substrate_thickness])
        mirror([1, 0, 0])
            upright_bracket();
}

module right_bracket() {
    translate([gap_between_brackets / 2, 0, substrate_thickness])
        upright_bracket();
}

module paired_reinforcement_bracket() {
    union() {
        substrate_plate();
        left_bracket();
        right_bracket();
    }
}

color("DarkOrange")
    paired_reinforcement_bracket();