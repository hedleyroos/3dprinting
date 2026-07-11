// ============================================================
// Garage Hook — Underside-Beam J-Hook (Split for Printing)
//
// A classic J-hook that screws into the underside of a wooden
// beam (e.g. 2×3 nominal, ~40 mm face).  Two pan-head self-
// tapping screws go through the base plate into the wood.
// Lightweight garage items hang on the deep J curve.
//
// The model is split into two glue-together parts so both
// print support-free:
//   BASE  — plate with a socket pocket; prints flat on the bed.
//   HOOK  — J-curve with a tenon; prints on its side.
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
arc_radius             = 32.5;    // Centerline radius of the 180° bottom curve
straight_up            = 16;    // Vertical front lip length (tip sits 10 mm below base)
band_thickness         = 10;    // Hook body thickness in profile plane
hook_width             = 16;    // Hook body width along Y (across beam)
arc_steps              = 36;    // Number of segments for the bottom curve

/* [Mounting Plate] */
plate_length           = 55;    // X — along the beam
plate_width            = 40;    // Y — across the beam (matches ~40 mm beam face)
plate_thickness        = 6;     // Z — plate height

/* [Screw Holes] */
screw_diameter         = 6.2;   // Clearance for 5 mm self-tapping screws
screw_spacing          = 34;    // Center-to-center along X
hole_overage           = 0.4;   // Extra drill-through beyond plate thickness

/* [Split Joint] */
socket_depth           = 5;     // Depth of the socket pocket in the base plate
socket_clearance       = 0.05;  // Radial clearance for glue (per side)
socket_bottom_gap      = 0.2;   // Extra socket depth so the tenon tip clears
print_spacing          = 10;    // Minimum gap between parts on the print bed

/* [Reinforcement] */
root_fillet_radius     = 5;     // Fillet radius at the hook-back-to-plate junction

/* [View] */
export_mode            = "print"; // assembly | print | base | hook

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

// Socket / tenon derived dimensions (square, no corner rounding)
socket_w               = band_thickness + 2 * socket_clearance;
socket_d               = hook_width     + 2 * socket_clearance;

// Print-layout placement helpers (offsets from the base origin)
// Hook profile X span ≈ band_radius … (front_x + band_radius)  →  −5 … 70
hook_print_x           = half_plate_length + print_spacing + band_radius;
// Hook Y span after rotation ≈ −(socket_depth+socket_bottom_gap) … (straight_down+arc_radius+band_radius)
hook_print_y           = (straight_down + arc_radius + band_radius
                           - socket_depth - socket_bottom_gap) / 2;

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
// SPLIT JOINT — Tenon & Socket
// ============================================================

// Tenon extending from the hook's attachment plane toward the plate.
// In hook-local coordinates the attachment plane is at Z = 0 and the
// tenon points in the −Z direction (upward into the plate socket).
// Square cross-section — no rounding.  Dimensions are swapped vs.
// the natural hook cross-section to match the 90°-rotated socket.
module hook_tenon_3d() {
    tenon_h = socket_depth + socket_bottom_gap;
    translate([0, 0, -tenon_h])
        linear_extrude(height = tenon_h)
            square([hook_width, band_thickness], center = true);
}

// Socket pocket cut into the bottom face of the mounting plate.
// The plate bottom face is at Z = plate_thickness; we carve upward.
// Square pocket — no corner rounding.
module socket_cut() {
    socket_h = socket_depth + socket_bottom_gap + 0.01;
    rotate([0, 0, 90])
        translate([0, 0, plate_thickness - socket_depth])
            linear_extrude(height = socket_h)
                square([socket_w, socket_d], center = true);
}

// ============================================================
// BASE PART — Plate with socket
// ============================================================

module garage_hook_base_assembly() {
    difference() {
        mounting_plate_3d();
        socket_cut();
        screw_holes_3d();
    }
}

module garage_hook_base_print() {
    // Plate already lies flat in assembly orientation:
    // beam-contact face at Z = 0 (on bed), socket facing up.
    garage_hook_base_assembly();
}

// ============================================================
// HOOK PART — J-hook with tenon
// ============================================================

module hook_with_tenon() {
    union() {
        // Hook body truncated flat at the attachment plane (Z = 0)
        // so it presents a clean mating face against the base plate.
        intersection() {
            hook_body_3d();
            translate([0, 0, 50])
                cube([200, 200, 100], center = true);
        }
    }
}

module garage_hook_hook_assembly() {
    // Position the hook below the plate in installed orientation.
    translate([0, 0, plate_thickness])
        hook_with_tenon();
}

module garage_hook_hook_print() {
    // Lay the hook on its side — profile flat on the bed,
    // hook width becomes the vertical height.
    translate([0, 0, hook_width / 2])
        rotate([90, 0, 0])
            hook_with_tenon();
}

// ============================================================
// ASSEMBLY VIEW — Both parts fitted together
// ============================================================

module garage_hook_assembly_view() {
    // Base in installed orientation (plate on top, socket down)
    color([0.93, 0.42, 0.18])
        garage_hook_base_assembly();

    // Hook inserted from below
    color([0.93, 0.42, 0.18])
        garage_hook_hook_assembly();
}

// ============================================================
// PRINT LAYOUT — Both parts on the bed
// ============================================================

module garage_hook_print_layout() {
    // ----- Base -----
    // Base at origin, beam-contact face on bed, socket up.
    garage_hook_base_print();

    // ----- Hook -----
    // Hook laid on its side, offset to the right of the base.
    // hook_print_x / hook_print_y are pre-computed in DERIVED.
    translate([hook_print_x, hook_print_y, 0])
        garage_hook_hook_print();
}

// ============================================================
// EXPORT
// ============================================================

if (export_mode == "base") {
    garage_hook_base_print();
} else if (export_mode == "hook") {
    garage_hook_hook_print();
} else if (export_mode == "print") {
    garage_hook_print_layout();
} else { // "assembly"
    garage_hook_assembly_view();
}
