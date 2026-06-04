// ============================================================
// Heavy Duty Reinforcement Bracket
// 90-degree ABS-friendly bracket with centered mounting holes
// and outer-edge gussets that keep the center open.
//
// Coordinate system:
//   X = leg A length direction
//   Y = leg B length direction
//   Z = bracket face width
//
// The mounting faces lie on the XZ and YZ planes so the inside
// corner is easy to reason about and the hole positions stay
// centered as the parameters change.
//
// All units: millimeters.
// ============================================================

/* [Bracket Dimensions] */
leg_length              = 30;
face_width              = 40;
material_thickness      = 8;

/* [Mounting Holes] */
hole_diameter           = 5.5;   // M5 clearance default

/* [Bracing] */
gusset_band_width       = 7;
gusset_end_margin       = 4;

/* [View] */
export_mode             = "print"; // assembly, print

/* [Quality] */
$fn                     = 96;
$fa                     = 2;
$fs                     = 0.4;

// ============================================================
// DERIVED
// ============================================================

half_face_width         = face_width / 2;
gusset_band             = min(gusset_band_width, face_width / 2 - 0.2);
gusset_center_offset    = half_face_width - gusset_band / 2;
default_hole_center_from_corner = leg_length / 2;

// ============================================================
// HELPERS
// ============================================================

module flat_rect_2d(w, h) {
    square([w, h], center = true);
}

module horizontal_leg() {
    translate([leg_length / 2, material_thickness / 2, 0])
        rotate([90, 0, 0])
            linear_extrude(height = material_thickness, center = true)
                flat_rect_2d(leg_length, face_width);
}

module vertical_leg() {
    translate([material_thickness / 2, leg_length / 2, 0])
        rotate([0, 90, 0])
            linear_extrude(height = material_thickness, center = true)
                flat_rect_2d(face_width, leg_length);
}

module outer_gusset_profile() {
    polygon(points = [
        [material_thickness, material_thickness],
        [leg_length - gusset_end_margin, material_thickness],
        [material_thickness, leg_length - gusset_end_margin]
    ]);
}

module centered_holes(
    horizontal_hole_center_from_corner = default_hole_center_from_corner,
    vertical_hole_center_from_corner = default_hole_center_from_corner,
    horizontal_hole_diameter = hole_diameter,
    vertical_hole_diameter = hole_diameter
) {
    translate([horizontal_hole_center_from_corner, material_thickness / 2, 0])
        rotate([90, 0, 0])
            cylinder(h = material_thickness + 0.4, d = horizontal_hole_diameter, center = true);

    translate([material_thickness / 2, vertical_hole_center_from_corner, 0])
        rotate([0, 90, 0])
            cylinder(h = material_thickness + 0.4, d = vertical_hole_diameter, center = true);
}

// ============================================================
// GEOMETRY
// ============================================================

module side_gussets() {
    for (side = [-1, 1])
        translate([0, 0, side * gusset_center_offset])
            linear_extrude(height = gusset_band, center = true)
                outer_gusset_profile();
}

module reinforcement_bracket(
    horizontal_hole_center_from_corner = default_hole_center_from_corner,
    vertical_hole_center_from_corner = default_hole_center_from_corner,
    horizontal_hole_diameter = hole_diameter,
    vertical_hole_diameter = hole_diameter
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

module print_preview() {
    translate([-leg_length / 2, -leg_length / 2, half_face_width])
        reinforcement_bracket();
}

// ============================================================
// EXPORT
// ============================================================

if (export_mode == "print") {
    print_preview();
} else {
    reinforcement_bracket();
}