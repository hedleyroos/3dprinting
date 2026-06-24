// ============================================================
// Garage Hook — Underside-Beam J-Hook
//
// A classic J-hook that screws into the underside of a wooden
// beam (e.g. 2×3 nominal, ~40 mm face).  Two pan-head self-
// tapping screws go through the base plate into the wood.
// Lightweight garage items hang on the deep J curve.
//
// Coordinate system:
//   X = along the beam (base plate length direction)
//   Y = across the beam width (hook width direction)
//   Z = down from the beam underside (positive = downward)
//
// All units: millimeters.
// ============================================================

/* [Hook Shape] */
straight_down          = 42;    // Vertical back section length
arc_radius             = 21;    // Centerline radius of the 180° bottom curve
straight_up            = 32;    // Vertical front lip length (tip sits 10 mm below base)
band_thickness         = 10;    // Hook body thickness in profile plane
hook_width             = 16;    // Hook body width along Y (across beam)
arc_steps              = 36;    // Number of segments for the bottom curve

/* [Mounting Plate] */
plate_length           = 50;    // X — along the beam
plate_width            = 40;    // Y — across the beam (matches ~40 mm beam face)
plate_thickness        = 6;     // Z — plate height

/* [Screw Holes] */
screw_diameter         = 5.2;   // Clearance for 5 mm self-tapping screws
screw_spacing          = 30;    // Center-to-center along X
hole_overage           = 0.4;   // Extra drill-through beyond plate thickness

/* [Reinforcement] */
root_fillet_radius     = 5;     // Fillet radius at the hook-back-to-plate junction

/* [View] */
export_mode            = "print"; // assembly, print

/* [Quality] */
$fn                    = 120;
$fa                    = 1;
$fs                    = 0.4;

// ============================================================
// DERIVED
// ============================================================

band_radius            = band_thickness / 2;
half_hook_width        = hook_width / 2;
half_plate_length      = plate_length / 2;
half_plate_width       = plate_width / 2;

// Arc geometry — 180° sweep clockwise from left (180°) through
// bottom (270°) to right (360° ≡ 0°).
arc_center             = [arc_radius, -straight_down];
arc_start_angle        = 180;
arc_end_angle          = 360;

// Key profile points
tip_z                  = -straight_down + straight_up;  // ~ -10
front_x                = 2 * arc_radius;                 // 42 — X of the front lip

// Screw positions on the plate (XZ plane, plate sits at Z=0)
screw_half_spacing     = screw_spacing / 2;

// ============================================================
// HELPERS
// ============================================================

module rounded_rect_2d(w, h, r) {
    corner_r = min(r, w / 2 - 0.01, h / 2 - 0.01);
    hull() {
        translate([ w / 2 - corner_r,  h / 2 - corner_r]) circle(r = corner_r, $fn = 48);
        translate([-w / 2 + corner_r,  h / 2 - corner_r]) circle(r = corner_r, $fn = 48);
        translate([ w / 2 - corner_r, -h / 2 + corner_r]) circle(r = corner_r, $fn = 48);
        translate([-w / 2 + corner_r, -h / 2 + corner_r]) circle(r = corner_r, $fn = 48);
    }
}

module circle_segment_2d(p0, p1, r) {
    hull() {
        translate(p0) circle(r = r, $fn = 48);
        translate(p1) circle(r = r, $fn = 48);
    }
}

function arc_point(angle) = [
    arc_center[0] + arc_radius * cos(angle),
    arc_center[1] + arc_radius * sin(angle)
];

// ============================================================
// 2D HOOK PROFILE
// ============================================================

// The J-hook profile lies in the XZ plane.
// Path: straight back down → 180° bottom arc → straight front up.
module hook_profile_2d() {
    union() {
        // Straight back: (0, 0) down to (0, -straight_down)
        circle_segment_2d([0, 0], [0, -straight_down], band_radius);

        // 180° bottom arc: sweeps clockwise through the bottom
        for (i = [0 : arc_steps - 1]) {
            a0 = arc_start_angle + (arc_end_angle - arc_start_angle) * i / arc_steps;
            a1 = arc_start_angle + (arc_end_angle - arc_start_angle) * (i + 1) / arc_steps;
            circle_segment_2d(arc_point(a0), arc_point(a1), band_radius);
        }

        // Straight front: (front_x, -straight_down) up to (front_x, tip_z)
        circle_segment_2d([front_x, -straight_down], [front_x, tip_z], band_radius);
    }
}

// ============================================================
// 3D GEOMETRY
// ============================================================

// The hook body — 2D profile stood up so the J hangs vertically.
// rotate([-90,0,0]) maps the 2D Y (down-in-profile) → 3D Z (down),
// and the linear_extrude Z → 3D Y (hook width across the beam).
module hook_body_3d() {
    rotate([-90, 0, 0])
        linear_extrude(height = hook_width, center = true, convexity = 10)
            hook_profile_2d();
}

// The base plate — rectangular with rounded corners
module mounting_plate_3d() {
    plate_corner_r = 4;
    translate([0, 0, plate_thickness / 2])
        linear_extrude(height = plate_thickness, center = true)
            rounded_rect_2d(plate_length, plate_width, plate_corner_r);
}

// Screw holes — two straight clearance holes through the plate
module screw_holes_3d() {
    total_depth = plate_thickness + hole_overage;

    for (sx = [-1, 1]) {
        translate([sx * screw_half_spacing, 0, plate_thickness / 2])
            cylinder(h = total_depth, d = screw_diameter, center = true);
    }
}

// ============================================================
// ASSEMBLY
// ============================================================

module garage_hook_assembly() {
    difference() {
        union() {
            // Shift the hook down so it emerges from the bottom face
            // of the plate instead of punching through it.
            translate([0, 0, plate_thickness])
                hook_body_3d();
            rotate([0, 0, 90])
                mounting_plate_3d();
        }
        rotate([0, 0, 90])
            screw_holes_3d();
    }
}

// ============================================================
// EXPORT / VIEW
// ============================================================

module garage_hook_print() {
    // Lay the hook on its side so the J profile is flat on the bed —
    // no supports needed for the curve.
    rotate([0, 90, 0])
        garage_hook_assembly();
}

module garage_hook_assembly_view() {
    // Natural installed orientation: plate on top, hook hanging down.
    // (The model is already in this orientation by default.)
    garage_hook_assembly();
}

if (export_mode == "print") {
    garage_hook_print();
} else {
    garage_hook_assembly_view();
}
