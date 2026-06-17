// ============================================================
// Mesh Box — Laptop Bag Insert (Rounded Front Variant)
//
// Lightweight protective box with circular mesh cutouts on all
// five faces (four walls + floor).  Designed for ABS, printed
// upright with the open top facing +Z.
//
// This variant adds a gentle outward curve to the front wall
// (+Y face) so the box fits better against the rounded outer
// shell of a backpack.  The curve is a large-radius cylindrical
// arc — not a full semicircle.
//
// When front_curve_bulge > 0, the flat +Y wall is replaced by
// a single curved extrusion (inner→outer, no seams).  The brim
// and floor are extended forward with matching polygon patches.
//
// Coordinate system:
//   X = width  (260 mm, left→right)
//   Y = depth  (100 mm, front→back)
//   Z = height (300 mm, bed→top, origin at centre of bottom face)
//
//   The +Y face is the "front" — furthest from the wearer's
//   back.  It bows outward in +Y.
//
// All units: millimeters.
// ============================================================

/* [Box Dimensions] */
box_w                   = 260;   // Outer width  (X)
box_d                   = 100;   // Outer depth  (Y)
box_h                   = 300;   // Outer height (Z)

/* [Wall] */
wall_t                  = 4;     // Wall and floor thickness
corner_r                = 8;     // External vertical corner radius
base_edge_inset         = 3.5;   // Bottom bevel pull-in to soften the base edge
base_edge_h             = 6;     // Height of the softened base band

/* [Top Brim] */
top_brim_enabled        = true;  // Enable the inward top brim
top_brim_outset         = 8;     // Horizontal overhang into the open top
top_brim_h              = 4;     // Vertical thickness of the inward top brim
top_edge_inset          = 3;     // Top bevel pull-in to soften the outer rim
top_edge_h              = 4;     // Height of the softened top band

/* [Mesh Holes] */
hole_d                  = 16;    // Circular hole diameter
hole_spacing            = 22;    // Centre-to-centre hole spacing
rim_top                 = 15;    // Solid band at top (no holes)
rim_bottom              = 10;    // Solid band at bottom (no holes)
corner_margin           = 12;    // No-hole keep-out from each vertical edge

/* [Bottom] */
bottom_holes            = true;  // Enable mesh holes in the floor

/* [Front Curve] */
front_curve_bulge       = 36;    // How far the front wall bows outward at centre (mm)
                                 //   Set to 0 for a flat front wall.
                                 //   Typical: 8–18 mm depending on backpack shape.
front_curve_taper_start_z = 140; // Height where the front curve starts tapering inward
front_curve_taper_intensity = 0.95; // 0 = no taper, 1 = maximum mild top flattening

/* [View] */
export_mode             = "print"; // print

/* [Quality] */
$fn                     = 40;    // Global fallback
$fa                     = 1;
$fs                     = 0.4;

// Per-feature facet counts – holes are invisible in the final
// print (bridged over), so they use a lower count for speed.
hole_fn                 = 30;    // Hole circles (16 mm dia)
corner_fn               = 60;    // Corner cylinders (visible edges)

// ============================================================
// DERIVED
// ============================================================

half_w  = box_w / 2;
half_d  = box_d / 2;
hole_r  = hole_d / 2;
hsp     = hole_spacing;
inner_w = box_w - 2 * wall_t;
inner_d = box_d - 2 * wall_t;
inner_corner_r = max(0.01, corner_r - wall_t);
profile_skin = 0.05;

// Wall panel dimensions (flat portions between corner cylinders).
front_w = box_w - 2 * corner_r;   // front / back wall width
side_w  = box_d - 2 * corner_r;   // left / right wall width

// Front curve geometry.
//   R = (L²/4 + b²) / (2b)   where L = chord (front_w), b = bulge.
front_curve_r = front_curve_bulge <= 0
    ? 1e6
    : (pow(front_w, 2) / 4 + pow(front_curve_bulge, 2)) / (2 * front_curve_bulge);

// Y-coordinate of the cylinder axis.
front_curve_axis_y = half_d - wall_t / 2 - front_curve_r + front_curve_bulge;

// How far the outer surface extends at the centre (X=0).
front_curve_outer_y0 = front_curve_axis_y + front_curve_r + wall_t / 2;
front_curve_taper_start_z_clamped = max(0, min(front_curve_taper_start_z, box_h));
front_curve_taper_intensity_clamped = max(0,
    min(front_curve_taper_intensity, 1));
front_curve_taper_max_reduction_ratio = 0.35;
front_curve_taper_top_reduction =
    front_curve_bulge
    * front_curve_taper_max_reduction_ratio
    * front_curve_taper_intensity_clamped;
front_curve_top_bulge = max(0,
    front_curve_bulge - front_curve_taper_top_reduction);
front_curve_has_taper = front_curve_bulge > 0
    && front_curve_taper_top_reduction > 0
    && front_curve_taper_start_z_clamped < box_h;

echo(str("Front curve radius:  ", front_curve_r, " mm"));
echo(str("Front curve axis Y:  ", front_curve_axis_y));
echo(str("Front wall chord:    ", front_w, " mm"));
echo(str("Front wall bulge:    ", front_curve_bulge, " mm"));
echo(str("Front taper intensity: ", front_curve_taper_intensity_clamped));
echo(str("Front top bulge:     ", front_curve_top_bulge, " mm"));
echo(str("Front taper start Z: ", front_curve_taper_start_z_clamped, " mm"));
echo(str("Outer Y at centre:   ", front_curve_outer_y0));

// ============================================================
// HELPERS  (identical to original mesh_box.scad)
// ============================================================

module rounded_rect_2d(w, d, r) {
    hull() {
        for (x = [-1, 1], y = [-1, 1]) {
            translate([x * (w / 2 - r),
                       y * (d / 2 - r)])
                circle(r = r, $fn = corner_fn);
        }
    }
}

module rounded_rect_slice(z0, w, d, r) {
    translate([0, 0, z0])
        linear_extrude(height = profile_skin)
            rounded_rect_2d(w, d, r);
}

module wall_profile_2d(w, h, side_margin) {
    difference() {
        square([w, h], center = true);

        xs = -w / 2 + side_margin + hole_r;
        xe =  w / 2 - side_margin - hole_r;
        zs = -h / 2 + rim_bottom  + hole_r;
        ze =  h / 2 - rim_top     - hole_r;

        rows = floor((ze - zs) / hsp) + 1;

        for (row = [0 : rows - 1]) {
            z = zs + row * hsp;
            stagger = (row % 2 == 0) ? 0 : hsp / 2;
            for (x = [xs + stagger : hsp : xe]) {
                translate([x, z])
                    circle(d = hole_d, $fn = hole_fn);
            }
        }
    }
}

// Floor footprint extension over the curved front, at floor mid-height.
// Its back edge meets the rectangular interior floor; its front edge
// follows the inner surface of the curved front wall.
module front_floor_crescent_2d(z) {
    n = ceil(front_w / 2);
    pts = [for (i = [0:n])
        let (x = -front_w / 2 + i * front_w / n)
        [x, front_inner_y(x, z)] ];
    polygon(concat(
        [[-front_w / 2, inner_d / 2]],
        pts,
        [[ front_w / 2, inner_d / 2]]
    ));
}

// Staggered floor hole grid.  When the front bulges, the grid extends
// forward to fill the bulged floor area; each hole is kept a wall-thickness
// margin back from the curved inner front edge so a solid rim is preserved.
module floor_holes_2d(z) {
    margin = hole_r + wall_t;
    xs = -inner_w / 2 + margin;
    xe =  inner_w / 2 - margin;
    ys = -inner_d / 2 + margin;
    ye = (front_curve_bulge > 0 ? front_inner_y(0, z) : inner_d / 2) - margin;

    cols = floor((ye - ys) / hsp) + 1;
    for (col = [0 : cols - 1]) {
        y = ys + col * hsp;
        stagger = (col % 2 == 0) ? 0 : hsp / 2;
        for (x = [xs + stagger : hsp : xe]) {
            front_lim = (front_curve_bulge > 0 ? front_inner_y(x, z)
                                               : inner_d / 2) - margin;
            if (y <= front_lim)
                translate([x, y])
                    circle(d = hole_d, $fn = hole_fn);
        }
    }
}

module base_edge_cutter() {
    soften_inset = max(0,
                       min(base_edge_inset,
                           min(corner_r - 0.5, wall_t - 0.5)));
    soften_h = max(base_edge_h, profile_skin * 2);

    if (soften_inset > 0) {
        difference() {
            translate([0, 0, -profile_skin])
                linear_extrude(height = soften_h + 2 * profile_skin)
                    outer_footprint_2d();

            hull() {
                translate([0, 0, -profile_skin])
                    linear_extrude(height = profile_skin)
                        outer_footprint_inset_2d(soften_inset);
                translate([0, 0, soften_h - profile_skin])
                    linear_extrude(height = profile_skin)
                        outer_footprint_2d();
            }
        }
    }
}

module top_edge_cutter() {
    soften_inset = max(0,
                       min(top_edge_inset,
                           corner_r - 0.5,
                           box_w / 2 - corner_r - 0.5,
                           box_d / 2 - corner_r - 0.5));
    soften_h = max(top_edge_h, profile_skin * 2);
    top_z = box_h - soften_h;

    if (soften_inset > 0) {
        difference() {
            outer_footprint_sweep_3d(top_z - profile_skin,
                                     box_h + profile_skin);

            hull() {
                translate([0, 0, top_z])
                    linear_extrude(height = profile_skin)
                        outer_footprint_2d(top_z);
                translate([0, 0, box_h - profile_skin])
                    linear_extrude(height = profile_skin)
                        outer_footprint_inset_2d(soften_inset, box_h);
            }
        }
    }
}

// ============================================================
// CURVED FRONT — replaces the flat +Y wall when bulge > 0
// ============================================================

function front_taper_progress(z) =
    !front_curve_has_taper || z <= front_curve_taper_start_z_clamped
        ? 0
        : z >= box_h
            ? 1
            : (z - front_curve_taper_start_z_clamped)
                / max(box_h - front_curve_taper_start_z_clamped, profile_skin);

function front_curve_bulge_at(z) =
    front_curve_bulge <= 0
        ? 0
        : max(0,
              front_curve_bulge
              - front_curve_taper_top_reduction * front_taper_progress(z));

function front_curve_r_at(z) =
    front_curve_bulge_at(z) <= 0
        ? 1e6
        : (pow(front_w, 2) / 4 + pow(front_curve_bulge_at(z), 2))
            / (2 * front_curve_bulge_at(z));

function front_curve_axis_y_at(z) =
    front_curve_bulge_at(z) <= 0
        ? half_d - wall_t / 2 - front_curve_r_at(z)
        : half_d - wall_t / 2 - front_curve_r_at(z) + front_curve_bulge_at(z);

// Y-coordinate of the outer curved surface at a given X.
function front_outer_y(x, z = 0) =
    front_curve_bulge_at(z) <= 0
        ? half_d
        : front_curve_axis_y_at(z)
            + sqrt(pow(front_curve_r_at(z) + wall_t / 2, 2) - pow(x, 2));

// Y-coordinate of the inner curved surface at a given X.
function front_inner_y(x, z = 0) =
    front_curve_bulge_at(z) <= 0
        ? half_d - wall_t
        : front_outer_y(x, z) - wall_t;

// 2D profile: the crescent between flat front and curved outer.
// Used by the brim extension.
module front_crescent_2d(z = 0) {
    n = ceil(front_w / 2);
    pts = [for (i = [0:n])
        let (x = -front_w / 2 + i * front_w / n)
        [x, front_outer_y(x, z)] ];
    polygon(concat(
        [[-front_w / 2, half_d]],
        pts,
        [[ front_w / 2, half_d]]
    ));
}

// 2D outer footprint of the box, including the curved front when
// enabled. Used by the outer-edge softeners so they match the
// actual perimeter instead of the original flat-front outline.
module outer_footprint_2d(z = 0) {
    if (front_curve_bulge_at(z) > 0) {
        union() {
            rounded_rect_2d(box_w, box_d, corner_r);
            front_crescent_2d(z);
        }
    } else {
        rounded_rect_2d(box_w, box_d, corner_r);
    }
}

// Inset version of the outer footprint, preserving rounded corners.
module outer_footprint_inset_2d(inset, z = 0) {
    inset_clamped = max(0, inset);

    if (inset_clamped > 0) {
        offset(r = -inset_clamped)
            outer_footprint_2d(z);
    } else {
        outer_footprint_2d(z);
    }
}

// 2D profile: the front extension of the brim's inner opening.
// This removes the leftover flat strip that would otherwise sit
// behind the curved front wall at the top.
module front_brim_inner_extension_2d(brim_outset, z = box_h) {
    n = ceil(front_w / 2);
    pts = [for (i = [0:n])
        let (x = -front_w / 2 + i * front_w / n)
        [x, front_inner_y(x, z) - brim_outset] ];
    polygon(concat(
        [[-front_w / 2, inner_d / 2 - brim_outset]],
        pts,
        [[ front_w / 2, inner_d / 2 - brim_outset]]
    ));
}

// 2D profile of the open top boundary, inset inward by `inset`.
// This is the profile used to build the true interior brim:
// the brim is the area between inset 0 and inset top_brim_outset.
module top_opening_profile_2d(inset, z = box_h) {
    inset_clamped = max(0, inset);
    opening_w = inner_w - 2 * inset_clamped;
    opening_d = inner_d - 2 * inset_clamped;
    opening_r = max(0.01, inner_corner_r - inset_clamped);

    if (front_curve_bulge_at(z) > 0) {
        union() {
            rounded_rect_2d(opening_w, opening_d, opening_r);
            front_brim_inner_extension_2d(inset_clamped, z);
        }
    } else {
        rounded_rect_2d(opening_w, opening_d, opening_r);
    }
}

// 2D profile: the full curved wall from inner to outer surface.
module curved_wall_profile_2d(z = 0) {
    n = ceil(front_w / 2);
    outer_pts = [for (i = [0:n])
        let (x = -front_w / 2 + i * front_w / n)
        [x, front_outer_y(x, z)] ];
    inner_pts = [for (i = [0:n])
        let (x =  front_w / 2 - i * front_w / n)
        [x, front_inner_y(x, z)] ];
    polygon(concat(
        [[-front_w / 2, half_d]],
        outer_pts,
        [[ front_w / 2, half_d]],
        [[ front_w / 2, half_d - wall_t]],
        inner_pts,
        [[-front_w / 2, half_d - wall_t]]
    ));
}

module outer_footprint_sweep_3d(z0, z1) {
    span = max(0, z1 - z0);
    segs = max(1, ceil(span / 12));

    for (i = [0:segs - 1]) {
        za = z0 + i * span / segs;
        zb = z0 + (i + 1) * span / segs;
        hull() {
            translate([0, 0, za])
                linear_extrude(height = profile_skin)
                    outer_footprint_2d(za);
            translate([0, 0, max(za, zb - profile_skin)])
                linear_extrude(height = profile_skin)
                    outer_footprint_2d(zb);
        }
    }
}

module top_opening_sweep_3d(inset, z0, z1) {
    span = max(0, z1 - z0);
    segs = max(1, ceil(span / 12));

    for (i = [0:segs - 1]) {
        za = z0 + i * span / segs;
        zb = z0 + (i + 1) * span / segs;
        hull() {
            translate([0, 0, za])
                linear_extrude(height = profile_skin)
                    top_opening_profile_2d(inset, za);
            translate([0, 0, max(za, zb - profile_skin)])
                linear_extrude(height = profile_skin)
                    top_opening_profile_2d(inset, zb);
        }
    }
}

// Tapered curved wall as a fine stack of straight extrusions of the thin
// crescent.  linear_extrude() extrudes the exact 2D profile (it does NOT
// hull, so the concave crescent is preserved as a true thin shell — the
// earlier hull-based sweep filled that concavity into a solid lens).  Each
// segment uses the crescent at its mid-height; with small steps the wall
// reads as a smooth taper while previewing and rendering cleanly.
module curved_wall_taper_stack(z0, z1) {
    span = max(0, z1 - z0);
    segs = max(1, ceil(span / 3));   // ~3 mm steps -> ~0.2 mm ledges

    for (i = [0:segs - 1]) {
        za = z0 + i * span / segs;
        zb = z0 + (i + 1) * span / segs;
        zm = (za + zb) / 2;
        translate([0, 0, za])
            linear_extrude(height = zb - za)
                curved_wall_profile_2d(zm);
    }
}

// Hole cylinders through the full curved wall thickness,
// oriented radially (perpendicular to the curve).
module curved_wall_holes() {
    margin = corner_margin - corner_r;
    xs = -front_w / 2 + margin + hole_r;
    xe =  front_w / 2 - margin - hole_r;
    zs = rim_bottom  + hole_r;
    ze = box_h - rim_top - hole_r;

    rows = floor((ze - zs) / hsp) + 1;
    for (row = [0 : rows - 1]) {
        z = zs + row * hsp;
        stagger = (row % 2 == 0) ? 0 : hsp / 2;
        for (x = [xs + stagger : hsp : xe]) {
            // Angle from cylinder axis to this X on the arc.
            radius = front_curve_r_at(z);
            ang = front_curve_bulge_at(z) <= 0 ? 0 : asin(x / radius);
            // Y position on the wall centreline at this height.
            yc = front_outer_y(x, z) - wall_t / 2;
            translate([x, yc, z])
                rotate([0, 0, -ang])
                    rotate([-90, 0, 0])
                        cylinder(d = hole_d, h = wall_t + 2, center = true,
                                 $fn = hole_fn);
        }
    }
}

// The curved front wall.  With no taper it is a single extrusion of the
// thin crescent.  With a taper the lower (constant-bulge) section is a
// single extrusion and the upper section is the fine crescent stack, so
// the result is always a true thin shell.  Holes are punched radially.
module curved_front_wall() {
    difference() {
        if (!front_curve_has_taper) {
            linear_extrude(height = box_h)
                curved_wall_profile_2d(0);
        } else {
            if (front_curve_taper_start_z_clamped > 0) {
                linear_extrude(height = front_curve_taper_start_z_clamped)
                    curved_wall_profile_2d(0);
            }
            curved_wall_taper_stack(front_curve_taper_start_z_clamped, box_h);
        }
        curved_wall_holes();
    }
}

// ============================================================
// BRIM — original flat-box brim + extension over the curve
// ============================================================

module top_brim() {
    brim_enabled = top_brim_enabled;
    brim_outset = max(0,
                      min(top_brim_outset,
                          inner_w / 2 - 0.5,
                          inner_d / 2 - 0.5));
    brim_h = max(top_brim_h, 0);

    if (brim_enabled && brim_outset > 0 && brim_h > 0) {
        translate([0, 0, box_h - brim_h])
            linear_extrude(height = brim_h)
                difference() {
                    top_opening_profile_2d(0, box_h);
                    top_opening_profile_2d(brim_outset, box_h);
                }
    }
}

// ============================================================
// GEOMETRY  (flat walls, corner posts, floor)
// ============================================================

module flat_front_back_wall(y_center, w, h, margin) {
    translate([0, y_center, h / 2])
        rotate([90, 0, 0])
            linear_extrude(height = wall_t, center = true)
                wall_profile_2d(w, h, margin);
}

module side_wall_panel(x_center, w, h, margin) {
    translate([x_center, 0, h / 2])
        rotate([90, 0, 90])
            linear_extrude(height = wall_t, center = true)
                wall_profile_2d(w, h, margin);
}

module corner_posts() {
    for (x = [-1, 1], y = [-1, 1]) {
        translate([x * (half_w - corner_r),
                   y * (half_d - corner_r),
                   0])
            cylinder(r = corner_r, h = box_h, $fn = corner_fn);
    }
}

module floor_panel() {
    floor_z = wall_t / 2;

    // Full floor footprint (rectangular interior + bulged front extension),
    // with the staggered mesh punched through all of it including the bulge.
    translate([0, 0, floor_z])
        linear_extrude(height = wall_t, center = true)
            difference() {
                union() {
                    square([inner_w, inner_d], center = true);
                    if (front_curve_bulge > 0)
                        front_floor_crescent_2d(floor_z);
                }
                if (bottom_holes)
                    floor_holes_2d(floor_z);
            }
}

// ----- assembly -----------------------------------------------------------

module mesh_box_body() {
    union() {
        // Corner posts.
        corner_posts();

        // Front wall (+Y): curved or flat.
        if (front_curve_bulge > 0) {
            curved_front_wall();
        } else {
            flat_front_back_wall( half_d - wall_t / 2, front_w, box_h,
                                  corner_margin - corner_r);
        }

        // Flat back wall (-Y).
        flat_front_back_wall(-half_d + wall_t / 2, front_w, box_h,
                             corner_margin - corner_r);

        // Left / right walls.
        side_wall_panel( half_w - wall_t / 2, side_w, box_h,
                         corner_margin - corner_r);
        side_wall_panel(-half_w + wall_t / 2, side_w, box_h,
                         corner_margin - corner_r);

        // Floor (original + curved extension).
        floor_panel();
    }
}

module mesh_box() {
    difference() {
        union() {
            mesh_box_body();
            top_brim();
        }

        base_edge_cutter();
        top_edge_cutter();
    }
}

// ============================================================
// RENDER
// ============================================================

mesh_box();
