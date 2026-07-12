// ============================================================
// Paired Reinforcement Bracket on ABS Substrate
//
// Two mirrored copies of a reinforcement bracket are mounted
// back-to-back on a shared flat substrate. The gap is measured
// as the clear distance between the inner upright faces.
//
// Standalone — no external dependencies.
//
// All units: millimeters.
// ============================================================

/* [Bracket Dimensions] */
leg_length              = 30;
face_width              = 40;
vertical_wall_thickness = 9;     // Thickness of the upright leg
bottom_thickness        = 5;     // Thickness of the horizontal leg (bottom part with holes)

/* [Bracing] */
gusset_band_width       = 7;
gusset_end_margin       = 4;

/* [Mounting Holes] */
bottom_hole_diameter    = 6.2;
vertical_hole_diameter  = 6.2;
bottom_hole_outboard_offset = 6.6;
vertical_hole_raise     = 2.8;

/* [Pair Layout] */
gap_between_brackets    = 32;    // Clear gap between inner upright faces

/* [Substrate] */
substrate_thickness     = 4;
substrate_end_margin    = 0;
substrate_side_margin   = 0;

/* [Quality] */
$fa                     = 1;
$fs                     = 0.4;

// ============================================================
// DERIVED
// ============================================================

half_face_width         = face_width / 2;
gusset_band             = min(gusset_band_width, face_width / 2 - 0.2);
gusset_center_offset    = half_face_width - gusset_band / 2;
substrate_length        = gap_between_brackets + 2 * leg_length + 2 * substrate_end_margin;
substrate_width         = face_width + 2 * substrate_side_margin;
bottom_hole_center_from_corner = leg_length / 2 + bottom_hole_outboard_offset;
vertical_hole_center_from_corner = leg_length / 2 + vertical_hole_raise;
substrate_hole_center_x = gap_between_brackets / 2 + bottom_hole_center_from_corner;

// ============================================================
// HELPERS
// ============================================================

module flat_rect_2d(w, h) {
    square([w, h], center = true);
}

module outer_gusset_profile() {
    polygon(points = [
        [vertical_wall_thickness, bottom_thickness],
        [leg_length - gusset_end_margin, bottom_thickness],
        [vertical_wall_thickness, leg_length - gusset_end_margin]
    ]);
}

// ============================================================
// SINGLE BRACKET GEOMETRY (standalone, no external dependencies)
// ============================================================

module horizontal_leg() {
    translate([leg_length / 2, bottom_thickness / 2, 0])
        rotate([90, 0, 0])
            linear_extrude(height = bottom_thickness, center = true)
                flat_rect_2d(leg_length, face_width);
}

module vertical_leg() {
    translate([vertical_wall_thickness / 2, leg_length / 2, 0])
        rotate([0, 90, 0])
            linear_extrude(height = vertical_wall_thickness, center = true)
                flat_rect_2d(face_width, leg_length);
}

module side_gussets() {
    for (side = [-1, 1])
        translate([0, 0, side * gusset_center_offset])
            linear_extrude(height = gusset_band, center = true)
                outer_gusset_profile();
}

module centered_holes(
    horizontal_hole_center_from_corner,
    vertical_hole_center_from_corner,
    horizontal_hole_diameter,
    vertical_hole_diameter
) {
    translate([horizontal_hole_center_from_corner, bottom_thickness / 2, 0])
        rotate([90, 0, 0])
            cylinder(h = bottom_thickness + 0.4, d = horizontal_hole_diameter, center = true);

    translate([vertical_wall_thickness / 2, vertical_hole_center_from_corner, 0])
        rotate([0, 90, 0])
            cylinder(h = vertical_wall_thickness + 0.4, d = vertical_hole_diameter, center = true);
}

module single_bracket(
    horizontal_hole_center_from_corner,
    vertical_hole_center_from_corner,
    horizontal_hole_diameter,
    vertical_hole_diameter
) {
    difference() {
        union() {
            horizontal_leg();
            vertical_leg();
            side_gussets();
        }
        centered_holes(
            horizontal_hole_center_from_corner = horizontal_hole_center_from_corner,
            vertical_hole_center_from_corner = vertical_hole_center_from_corner,
            horizontal_hole_diameter = horizontal_hole_diameter,
            vertical_hole_diameter = vertical_hole_diameter
        );
    }
}

// ============================================================
// PAIRED BRACKET GEOMETRY
// ============================================================

module substrate_plate() {
    translate([0, 0, substrate_thickness / 2])
        cube([substrate_length, substrate_width, substrate_thickness], center = true);
}

module upright_bracket() {
    rotate([90, 0, 0])
        single_bracket(
            horizontal_hole_center_from_corner = bottom_hole_center_from_corner,
            vertical_hole_center_from_corner = vertical_hole_center_from_corner,
            horizontal_hole_diameter = bottom_hole_diameter,
            vertical_hole_diameter = vertical_hole_diameter
        );
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

module substrate_mount_holes() {
    for (side = [-1, 1])
        translate([side * substrate_hole_center_x, 0, substrate_thickness / 2])
            cylinder(h = substrate_thickness + 0.4, d = bottom_hole_diameter, center = true);
}

module paired_reinforcement_bracket() {
    difference() {
        union() {
            substrate_plate();
            left_bracket();
            right_bracket();
        }
        substrate_mount_holes();
    }
}

color("DarkOrange")
    paired_reinforcement_bracket();