// ============================================================
// Paired Reinforcement Bracket Half-Test Prototype
//
// Keeps one side of the paired bracket so a single flat hole and
// a single upright hole can be test-printed quickly in PLA.
// ============================================================

use <paired_reinforcement_bracket.scad>

/* [Prototype Cut] */
keep_side               = "right"; // right, left
cut_overlap             = 0.02;

/* [Quality] */
$fn                     = 96;
$fa                     = 2;
$fs                     = 0.4;

module cut_half_space(side = "right") {
    if (side == "right")
        translate([250 - cut_overlap / 2, 0, 0])
            cube([500 + cut_overlap, 500, 500], center = true);
    else
        translate([-250 + cut_overlap / 2, 0, 0])
            cube([500 + cut_overlap, 500, 500], center = true);
}

module paired_reinforcement_bracket_half_test() {
    intersection() {
        paired_reinforcement_bracket();
        cut_half_space(keep_side);
    }
}

color("DarkOrange")
    paired_reinforcement_bracket_half_test();