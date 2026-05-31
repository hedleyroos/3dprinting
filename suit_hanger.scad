// ============================================================
// Suit Hanger — Classic Wooden Contour Style
// Full-size, multi-part 3D printable design
//
// Features:
//   - Contoured shoulders: tapered, rounded cross-section swept
//     along a gentle parabolic curve
//   - Separate glue-in hook with a keyed hex socket
//   - Single off-center split for the hanger body
//   - Loose alignment dowels for the body splice
//   - Default exploded layout with visible air gaps between parts
//
// Coordinate system:
//   X = left→right (width),  Y = back→front (depth),  Z = down→up
//   Origin at hanger center, mid-thickness of the shoulder body.
//
// All units: millimeters.
// ============================================================

/* [Hanger Body — Overall] */
hanger_width        = 440;   // Tip-to-tip
shoulder_drop       = 45;    // Vertical drop center → tip
shoulder_depth_c    = 48;    // Front-back depth at centre
shoulder_depth_tip  = 48;    // Front-back depth at tips
shoulder_thick_c    = 16;    // Vertical thickness at centre
shoulder_thick_tip  = 16;    // Vertical thickness at tips
shoulder_fwd_sweep  = 0;     // Top-view forward sweep; keep 0 for parallel sides and flush side-printing

/* [Hook] */
hook_enabled            = true;
hook_stem_h             = 35;    // Straight stem from shoulder to bottom of loop
hook_bend_r             = 24;    // Radius of the ?-loop
hook_dia                = 11;
hook_arc_sweep          = 260;   // Sweep of the curl: 180=open U, 260=easy fit, 330=tight
hook_joint_dia          = hook_dia; // Diameter of the cylindrical tenon
hook_key_dia            = 2.6;   // Diameter of the small alignment nub on the tenon
hook_key_standout       = 0.8;   // How far the alignment nub stands proud of the round tenon
hook_key_depth          = 2.2;   // Axial depth of the alignment nub near the hook base
hook_joint_rotation     = 0;     // 0 keeps the alignment nub on the top side in the side-print hook layout
hook_socket_depth       = 10.5;  // Socket depth into the hanger body
hook_socket_clearance   = 0.35;  // Extra diameter for glue fit in the socket

/* [Pants Bar] */
bar_enabled         = false;
bar_width           = 370;   // Overall bar width
bar_drop            = 45;    // How far below shoulder centre
bar_dia             = 10;
bar_strut_dia       = 8;     // Support-strut diameter

/* [Split for Printing] */
split_enabled       = true;
body_split_x        = 50;    // Off-center split plane, measured from hanger center toward the right tip
split_peg_dia       = 6;
split_peg_len       = 22;    // Total length of a loose dowel
split_peg_clearance = 0.25;  // Extra diameter in receiving holes
split_peg_count     = 3;

/* [View] */
parts_gap           = 14;    // Air gap between separated components
show_exploded_parts = true;  // true = separated parts, false = assembled preview
export_mode         = show_exploded_parts ? "layout" : "assembly"; // layout, assembly, body_main, body_tip, hook, dowels, pants_bar
main_body_print_rotation = -15; // Slight in-plane rotation trims the main body width to fit a 260 mm bed

/* [Quality] */
$fn                 = 120;
$fa                 = 1;
$fs                 = 0.4;

// ============================================================
// DERIVED
// ============================================================
hw                  = hanger_width / 2;
samples             = 40;
split_x             = min(max(body_split_x, 20), hw - 20);
split_t             = split_x / hw;
split_face_y        = sy(split_t);
split_face_z        = sz(split_t);
split_face_depth    = depth(split_t);
split_face_thick    = thick(split_t);
split_half_peg      = split_peg_len / 2;
hook_tenon_depth    = max(7.5, hook_socket_depth - 0.7);
hook_socket_lead_h  = min(1.8, hook_socket_depth * 0.3);
hook_tenon_lead_h   = min(1.6, hook_tenon_depth * 0.3);
body_main_side_lift = shoulder_depth_c / 2;
body_tip_side_lift  = split_face_depth / 2 - split_face_y;
body_row_y_shift    = max(shoulder_thick_c, shoulder_thick_tip) / 2;
body_row_span_y     = shoulder_drop + max(shoulder_thick_c, shoulder_thick_tip);
hook_side_lift      = hook_dia / 2;
hook_print_half_y   = hook_bend_r + hook_dia / 2;
hook_print_span_x   = hook_stem_h + hook_bend_r * 2 + hook_tenon_depth + hook_dia;
dowel_print_radius  = (split_peg_dia - 0.15) / 2;
dowel_print_pitch   = split_peg_len + split_peg_dia + 4;
dowel_row_span_x    = split_peg_len + max(0, split_peg_count - 1) * dowel_print_pitch;
scene_extent        = hanger_width + shoulder_drop + hook_stem_h + hook_bend_r + 120;

// ============================================================
// GENERIC HELPERS
// ============================================================

function split_peg_y_span() = max(0, min(split_face_depth / 2 - split_peg_dia / 2 - 3, split_peg_dia * 1.75));
function split_peg_top_z()  = max(0, min(split_face_thick / 2 - split_peg_dia / 2 - 1.5, split_peg_dia * 0.45));
function split_peg_bot_z()  = -max(0, min(split_face_thick / 2 - split_peg_dia / 2 - 1.75, split_peg_dia * 0.55));
function key_offset(main_dia, key_dia, standout) = main_dia / 2 + standout - key_dia / 2;

function peg_positions() = split_peg_count <= 1
    ? [[0, 0]]
    : split_peg_count == 2
        ? [[-split_peg_y_span() / 1.25, 0], [split_peg_y_span() / 1.25, 0]]
        : split_peg_count == 3
            ? [[-split_peg_y_span(), split_peg_top_z()],
               [ split_peg_y_span(), split_peg_top_z()],
               [0, split_peg_bot_z()]]
            : [for (i = [0 : split_peg_count - 1])
                   [(-1 + 2 * (i / max(1, split_peg_count - 1))) * split_peg_y_span(), 0]];

module xsec(depth, thick, round) {
    r = min(round, depth / 2 - 0.01, thick / 2 - 0.01);
    hull() {
        translate([0,  depth / 2 - r,  thick / 2 - r]) sphere(r = r, $fn = 48);
        translate([0, -depth / 2 + r,  thick / 2 - r]) sphere(r = r, $fn = 48);
        translate([0,  depth / 2 - r, -thick / 2 + r]) sphere(r = r, $fn = 48);
        translate([0, -depth / 2 + r, -thick / 2 + r]) sphere(r = r, $fn = 48);
    }
}

module hook_key_nub(main_dia, key_dia, standout, h) {
    rotate([0, 0, hook_joint_rotation])
        translate([0, key_offset(main_dia, key_dia, standout), 0])
            cylinder(d = key_dia, h = h, $fn = 32);
}

module keep_left_of_split() {
    translate([-scene_extent, -scene_extent, -scene_extent])
        cube([scene_extent + split_x, scene_extent * 2, scene_extent * 2], center = false);
}

module keep_right_of_split() {
    translate([split_x, -scene_extent, -scene_extent])
        cube([scene_extent, scene_extent * 2, scene_extent * 2], center = false);
}

// ============================================================
// SHOULDER PATH & CROSS-SECTION FUNCTIONS
// ============================================================

// t ∈ [0, 1]  —  0 = centre,  1 = tip
function sx(t) = t * hw;
function sy(t) = shoulder_fwd_sweep * t * t;
function sz(t) = -shoulder_drop * t * t;

function depth(t) = shoulder_depth_c + (shoulder_depth_tip - shoulder_depth_c) * t;
function thick(t) = shoulder_thick_c + (shoulder_thick_tip - shoulder_thick_c) * t;
function rounding(t) = thick(t) * 0.45;

// ============================================================
// BODY GEOMETRY
// ============================================================

module shoulder_half() {
    for (i = [0 : samples - 1]) {
        t0 = i / samples;
        t1 = (i + 1) / samples;
        hull() {
            translate([sx(t0), sy(t0), sz(t0)])
                xsec(depth(t0), thick(t0), rounding(t0));
            translate([sx(t1), sy(t1), sz(t1)])
                xsec(depth(t1), thick(t1), rounding(t1));
        }
    }
}

module hook_socket_shape() {
    socket_dia = hook_joint_dia + hook_socket_clearance;
    key_dia = hook_key_dia + hook_socket_clearance;
    key_depth = min(hook_key_depth, max(0.8, hook_socket_depth - hook_socket_lead_h - 0.2));
    shaft_h = max(0.2, hook_socket_depth - hook_socket_lead_h);
    socket_top = shoulder_thick_c / 2 + 0.05;

    translate([0, 0, socket_top - hook_socket_depth]) {
        cylinder(d = socket_dia, h = shaft_h, $fn = 48);
        translate([0, 0, shaft_h - key_depth])
            hook_key_nub(socket_dia, key_dia, hook_key_standout + hook_socket_clearance / 2, key_depth + hook_socket_lead_h);
        translate([0, 0, shaft_h])
            cylinder(d1 = socket_dia, d2 = socket_dia + 1.2, h = hook_socket_lead_h, $fn = 48);
    }
}

module hanger_body_shell() {
    union() {
        translate([-0.1, 0, 0])
            shoulder_half();
        mirror([1, 0, 0])
            translate([-0.1, 0, 0])
                shoulder_half();
    }
}

module hanger_body() {
    difference() {
        hanger_body_shell();
        if (hook_enabled)
            hook_socket_shape();
    }
}

module split_holes_main() {
    hole_len = split_half_peg + split_peg_clearance * 2 + 0.05;
    for (pt = peg_positions())
        translate([split_x - hole_len, split_face_y + pt[0], split_face_z + pt[1]])
            rotate([0, 90, 0])
                cylinder(d = split_peg_dia + split_peg_clearance, h = hole_len, $fn = 32);
}

module split_holes_tip() {
    hole_len = split_half_peg + split_peg_clearance * 2 + 0.05;
    for (pt = peg_positions())
        translate([split_x, split_face_y + pt[0], split_face_z + pt[1]])
            rotate([0, 90, 0])
                cylinder(d = split_peg_dia + split_peg_clearance, h = hole_len, $fn = 32);
}

module body_main_raw() {
    if (split_enabled) {
        intersection() {
            hanger_body();
            keep_left_of_split();
        }
    } else {
        hanger_body();
    }
}

module body_tip_raw() {
    if (split_enabled) {
        intersection() {
            hanger_body();
            keep_right_of_split();
        }
    }
}

module body_main() {
    if (split_enabled) {
        difference() {
            body_main_raw();
            split_holes_main();
        }
    } else {
        hanger_body();
    }
}

module body_tip() {
    if (split_enabled) {
        difference() {
            body_tip_raw();
            split_holes_tip();
        }
    }
}

module alignment_dowels() {
    for (pt = peg_positions())
        translate([split_x, split_face_y + pt[0], split_face_z + pt[1]])
            rotate([0, 90, 0])
                cylinder(d = split_peg_dia - 0.15, h = split_peg_len, center = true, $fn = 32);
}

module compact_dowels_for_print() {
    for (i = [0 : split_peg_count - 1])
        translate([(i - (split_peg_count - 1) / 2) * dowel_print_pitch, 0, dowel_print_radius])
            rotate([0, 90, 0])
                cylinder(d = split_peg_dia - 0.15, h = split_peg_len, center = true, $fn = 32);
}

// ============================================================
// HOOK
// ============================================================

module hook_tenon() {
    tenon_dia = hook_joint_dia;
    lead_dia = max(hook_joint_dia * 0.82, hook_joint_dia - 1.6);
    key_depth = min(hook_key_depth, max(0.8, hook_tenon_depth - hook_tenon_lead_h - 0.2));
    shaft_h = max(0.2, hook_tenon_depth - hook_tenon_lead_h);
    tenon_top = shoulder_thick_c / 2 + 0.05;

    translate([0, 0, tenon_top - hook_tenon_depth]) {
        cylinder(d1 = lead_dia, d2 = tenon_dia, h = hook_tenon_lead_h, $fn = 48);
        translate([0, 0, hook_tenon_lead_h])
            cylinder(d = tenon_dia, h = shaft_h, $fn = 48);
        translate([0, 0, hook_tenon_depth - key_depth])
            hook_key_nub(tenon_dia, hook_key_dia, hook_key_standout, key_depth);
    }
}

module hook() {
    arc_pts = 60;
    stem_base_z = shoulder_thick_c / 2 - 0.05;
    loop_bot = stem_base_z + hook_stem_h;
    arc_cx = 0;
    arc_cz = loop_bot + hook_bend_r;

    union() {
        hook_tenon();

        translate([0, 0, stem_base_z])
            cylinder(d = hook_dia, h = hook_stem_h + 0.1, $fn = $fn);

        for (i = [0 : arc_pts - 1]) {
            a0 = 270 - hook_arc_sweep * (i / arc_pts);
            a1 = 270 - hook_arc_sweep * ((i + 1) / arc_pts);
            hull() {
                translate([arc_cx + hook_bend_r * cos(a0), 0,
                           arc_cz + hook_bend_r * sin(a0)])
                    sphere(d = hook_dia, $fn = 48);
                translate([arc_cx + hook_bend_r * cos(a1), 0,
                           arc_cz + hook_bend_r * sin(a1)])
                    sphere(d = hook_dia, $fn = 48);
            }
        }
    }
}

// ============================================================
// PANTS / TROUSER BAR
// ============================================================

module pants_bar() {
    bar_y = -shoulder_depth_c / 2 - 8;
    bar_z = -bar_drop;
    attach_x = hw * 0.32;
    attach_z = sz(0.32);
    strut_d = bar_strut_dia;

    union() {
        for (mx = [-1, 1]) {
            ax = mx * attach_x;
            bx = mx * bar_width / 2;

            hull() {
                translate([ax, 0, attach_z])
                    sphere(d = strut_d, $fn = 32);
                translate([bx, bar_y, bar_z])
                    sphere(d = strut_d, $fn = 32);
            }
        }

        translate([0, bar_y, bar_z])
            rotate([0, 90, 0])
                cylinder(d = bar_dia, h = bar_width, center = true, $fn = $fn);

        for (mx = [-1, 1])
            translate([mx * bar_width / 2, bar_y, bar_z])
                sphere(d = bar_dia * 1.3, $fn = 48);
    }
}

// ============================================================
// VIEWS
// ============================================================

module suit_hanger_assembly() {
    color("Peru") body_main();

    if (split_enabled)
        color("Peru") body_tip();

    if (hook_enabled)
        color("Sienna") hook();

    if (bar_enabled)
        color("Peru") pants_bar();
}

module side_print_body(z_lift = body_main_side_lift) {
    translate([0, body_row_y_shift, z_lift])
        rotate([90, 0, 0])
            children();
}

module body_main_for_print() {
    rotate([0, 0, main_body_print_rotation])
        side_print_body(body_main_side_lift)
            body_main();
}

module body_tip_for_print() {
    if (split_enabled)
        side_print_body(body_tip_side_lift)
            body_tip();
}

module hook_for_print() {
    if (hook_enabled)
        translate([0, 0, hook_side_lift])
            rotate([90, 0, 90])
                hook();
}

module dowels_for_print() {
    if (split_enabled && split_peg_count > 0)
        compact_dowels_for_print();
}

module pants_bar_for_print() {
    if (bar_enabled)
        translate([0, 0, bar_dia / 2])
            pants_bar();
}

module print_layout() {
    tip_shift_x = -(hw - split_x) - 8;
    tip_shift_y = body_row_span_y + parts_gap + 49; // Extra rear-row clearance for the rotated main body envelope
    hook_shift_x = -hw + parts_gap + hook_print_span_x / 2;
    hook_shift_y = -parts_gap - hook_print_half_y;
    dowel_shift_x = 0;
    dowel_shift_y = hook_shift_y + hook_print_half_y - split_peg_dia;
    bar_shift_y = tip_shift_y + body_row_span_y + parts_gap + bar_dia / 2;

    color("Peru")
        body_main_for_print();

    if (split_enabled)
        translate([tip_shift_x, tip_shift_y, 0])
            color("Peru")
                side_print_body()
                    body_tip();

    if (hook_enabled)
        translate([hook_shift_x, hook_shift_y, hook_side_lift])
            rotate([90, 0, 90])
                color("Sienna") hook();

    if (split_enabled)
        translate([dowel_shift_x, dowel_shift_y, 0])
            color("BurlyWood") compact_dowels_for_print();

    if (bar_enabled)
        translate([0, bar_shift_y, bar_dia / 2])
            color("Peru") pants_bar();
}

// ============================================================
// EXPORT
// ============================================================

module render_export() {
    if (export_mode == "layout") {
        print_layout();
    } else if (export_mode == "assembly") {
        suit_hanger_assembly();
    } else if (export_mode == "body_main") {
        color("Peru") body_main_for_print();
    } else if (export_mode == "body_tip") {
        color("Peru") body_tip_for_print();
    } else if (export_mode == "hook") {
        color("Sienna") hook_for_print();
    } else if (export_mode == "dowels") {
        color("BurlyWood") dowels_for_print();
    } else if (export_mode == "pants_bar") {
        color("Peru") pants_bar_for_print();
    } else {
        echo(str("Unsupported export_mode: ", export_mode));
    }
}

render_export();
