// ============================================================
// Ceiling-Mounted Curtain Rod Bracket
//
// One-piece ABS-friendly bracket for a 35 mm curtain pole.
// The rod sits in a short question-mark hook under a ceiling
// plate so the support is visually more open than a U cradle.
//
// Coordinate system:
//   X = bracket depth / plate long direction
//   Y = rod axis / hook width direction
//   Z = up/down (installed orientation, downward is negative)
//
// All units: millimeters.
// ============================================================

/* [Rod Fit] */
rod_diameter            = 35;
rod_clearance           = 1.5;
rod_center_drop         = 70;

/* [Ceiling Plate] */
plate_length            = 30;
plate_width             = 70;
plate_thickness         = 8;
plate_corner_radius     = 6;

/* [Mounting Holes] */
hole_diameter           = 5.5;   // M5 clearance
hole_spacing            = 50;
center_hole_enabled     = false;

/* [Hook] */
hook_width              = 30;
hook_body_thickness     = 14;
hook_wrap_angle         = 185;   // Open the mouth further so a 35 mm pipe can slide in more easily
hook_tip_extension      = 8;
hook_tip_backoff_angle  = 30;    // Tips the mouth outward instead of closing it vertically
hook_embed_depth        = 0.3;   // Keeps the hook tied into the plate without reaching the top face

/* [Reinforcement] */
plate_root_extra        = 5;
plate_root_drop         = 16;
transition_join_angle   = 150;
transition_stem_drop    = 10;
transition_handle_drop  = 18;
transition_extra_thickness = 2.5;

/* [View] */
export_mode             = "print"; // assembly, print
show_rod_preview        = true;
rod_preview_length      = 150;

/* [Quality] */
$fn                     = 120;
$fa                     = 1;
$fs                     = 0.4;

// ============================================================
// DERIVED
// ============================================================

rod_radius              = rod_diameter / 2;
seat_radius             = rod_radius + rod_clearance;
hook_bar_radius         = hook_body_thickness / 2;
hook_centerline_radius  = seat_radius + hook_bar_radius;
rod_center_x            = 0;
hook_end_angle          = transition_join_angle + hook_wrap_angle;
stem_x                  = 0;
plate_underside_z       = -plate_thickness;
hook_clip_top_z         = plate_underside_z + hook_embed_depth;
stem_top_z              = plate_underside_z - hook_bar_radius + 0.6;
transition_start_z      = stem_top_z - transition_stem_drop;
transition_join_x       = rod_center_x + hook_centerline_radius * cos(transition_join_angle);
transition_join_z       = -rod_center_drop + hook_centerline_radius * sin(transition_join_angle);
transition_join_tangent_x = -sin(transition_join_angle);
transition_join_tangent_z = cos(transition_join_angle);
transition_handle_len   = hook_centerline_radius * 0.5;
hole_edge_margin        = (plate_width - hole_spacing - hole_diameter) / 2;

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

module rounded_block(w, d, h, r) {
    linear_extrude(height = h, center = true)
        rounded_rect_2d(w, d, r);
}

module circle_segment_2d(p0, p1, r) {
    hull() {
        translate(p0) circle(r = r, $fn = 48);
        translate(p1) circle(r = r, $fn = 48);
    }
}

module tapered_segment_2d(p0, r0, p1, r1) {
    hull() {
        translate(p0) circle(r = r0, $fn = 48);
        translate(p1) circle(r = r1, $fn = 48);
    }
}

function cubic_bezier_2d(p0, p1, p2, p3, t) = [
    pow(1 - t, 3) * p0[0] + 3 * pow(1 - t, 2) * t * p1[0] + 3 * (1 - t) * pow(t, 2) * p2[0] + pow(t, 3) * p3[0],
    pow(1 - t, 3) * p0[1] + 3 * pow(1 - t, 2) * t * p1[1] + 3 * (1 - t) * pow(t, 2) * p2[1] + pow(t, 3) * p3[1]
];

function smoothstep01(t) = t * t * (3 - 2 * t);

// ============================================================
// GEOMETRY
// ============================================================

module ceiling_plate() {
    translate([0, 0, -plate_thickness / 2])
        rounded_block(plate_width, plate_length, plate_thickness, plate_corner_radius);
}

module hook_profile_2d() {
    arc_steps = 32;
    blend_steps = 16;
    root_steps = 10;
    rod_center = [rod_center_x, -rod_center_drop];
    root_top = [stem_x, plate_underside_z - 0.6];
    root_bottom = [stem_x, stem_top_z - plate_root_drop];
    root_points = [for (i = [0 : root_steps])
        let(t = i / root_steps)
            [stem_x, root_top[1] + (root_bottom[1] - root_top[1]) * t]];
    blend_points = [for (i = [0 : blend_steps])
        cubic_bezier_2d(
            [stem_x, transition_start_z],
            [stem_x, transition_start_z - transition_handle_drop],
            [transition_join_x - transition_join_tangent_x * transition_handle_len,
             transition_join_z - transition_join_tangent_z * transition_handle_len],
            [transition_join_x, transition_join_z],
            i / blend_steps
        )];
    arc_points = [for (i = [0 : arc_steps])
        let(angle = transition_join_angle + (hook_end_angle - transition_join_angle) * i / arc_steps)
            [rod_center[0] + hook_centerline_radius * cos(angle),
             rod_center[1] + hook_centerline_radius * sin(angle)]];
    tip_start = arc_points[len(arc_points) - 1];
    tip_dir = hook_end_angle + 90 - hook_tip_backoff_angle;
    tip_end = [tip_start[0] + hook_tip_extension * cos(tip_dir),
               tip_start[1] + hook_tip_extension * sin(tip_dir)];

    union() {
        circle_segment_2d([stem_x, stem_top_z], [stem_x, transition_start_z], hook_bar_radius);

        // Shape the stem root as a curved flare instead of a single straight-sided hull.
        for (i = [0 : len(root_points) - 2])
            let(
                t0 = i / max(1, len(root_points) - 1),
                t1 = (i + 1) / max(1, len(root_points) - 1),
                r0 = hook_bar_radius + 0.4 + plate_root_extra * (1 - smoothstep01(t0)),
                r1 = hook_bar_radius + 0.4 + plate_root_extra * (1 - smoothstep01(t1))
            )
                tapered_segment_2d(root_points[i], r0, root_points[i + 1], r1);

        for (i = [0 : len(blend_points) - 2])
            let(
                t0 = i / max(1, len(blend_points) - 1),
                t1 = (i + 1) / max(1, len(blend_points) - 1),
                r0 = hook_bar_radius + transition_extra_thickness * pow(1 - t0, 1.35),
                r1 = hook_bar_radius + transition_extra_thickness * pow(1 - t1, 1.35)
            )
                tapered_segment_2d(blend_points[i], r0, blend_points[i + 1], r1);

        for (i = [0 : len(arc_points) - 2])
            circle_segment_2d(arc_points[i], arc_points[i + 1], hook_bar_radius);

        circle_segment_2d(tip_start, tip_end, hook_bar_radius);
    }
}

module hook_body() {
    intersection() {
        rotate([90, 0, 0])
            linear_extrude(height = hook_width, center = true, convexity = 10)
                hook_profile_2d();

        translate([-plate_width, -plate_length, -400])
            cube([plate_width * 2, plate_length * 2, hook_clip_top_z + 400], center = false);
    }
}

module mounting_holes() {
    for (side = [-1, 1])
        translate([side * hole_spacing / 2, 0, -plate_thickness / 2])
            cylinder(h = plate_thickness + 0.4, d = hole_diameter, center = true);

    if (center_hole_enabled)
        translate([0, 0, -plate_thickness / 2])
            cylinder(h = plate_thickness + 0.4, d = hole_diameter, center = true);
}

module rod_preview() {
    translate([rod_center_x, 0, -rod_center_drop])
        rotate([90, 0, 0])
            cylinder(h = rod_preview_length, d = rod_diameter, center = true);
}

module ceiling_curtain_rod_bracket() {
    difference() {
        union() {
            ceiling_plate();
            hook_body();
        }
        mounting_holes();
    }
}

module assembly_view() {
    color("DarkOrange")
        ceiling_curtain_rod_bracket();

    if (show_rod_preview)
        color([0.72, 0.72, 0.72, 0.35])
            rod_preview();
}

module print_view() {
    color("DarkOrange")
        rotate([90, 0, 0])
            ceiling_curtain_rod_bracket();
}

// ============================================================
// EXPORT
// ============================================================

if (export_mode == "assembly") {
    assembly_view();
} else {
    print_view();
}