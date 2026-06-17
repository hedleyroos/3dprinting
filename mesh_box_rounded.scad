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
top_brim_outset         = 8;     // Horizontal overhang into the open top
top_brim_h              = 4;     // Thickness of the top reinforcement brim
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
front_curve_bulge       = 12;    // How far the front wall bows outward at centre (mm)
                                 //   Set to 0 for a flat front wall.
                                 //   Typical: 8–18 mm depending on backpack shape.

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

echo(str("Front curve radius:  ", front_curve_r, " mm"));
echo(str("Front curve axis Y:  ", front_curve_axis_y));
echo(str("Front wall chord:    ", front_w, " mm"));
echo(str("Front wall bulge:    ", front_curve_bulge, " mm"));
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

module floor_profile_2d(iw, id) {
    margin = hole_r + wall_t;

    xs = -iw / 2 + margin;
    xe =  iw / 2 - margin;
    ys = -id / 2 + margin;
    ye =  id / 2 - margin;

    difference() {
        square([iw, id], center = true);

        cols = floor((ye - ys) / hsp) + 1;

        for (col = [0 : cols - 1]) {
            y = ys + col * hsp;
            stagger = (col % 2 == 0) ? 0 : hsp / 2;
            for (x = [xs + stagger : hsp : xe]) {
                translate([x, y])
                    circle(d = hole_d, $fn = hole_fn);
            }
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
                    rounded_rect_2d(box_w, box_d, corner_r);

            hull() {
                rounded_rect_slice(-profile_skin,
                                   box_w - 2 * soften_inset,
                                   box_d - 2 * soften_inset,
                                   corner_r - soften_inset);
                rounded_rect_slice(soften_h - profile_skin,
                                   box_w,
                                   box_d,
                                   corner_r);
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
            translate([0, 0, top_z - profile_skin])
                linear_extrude(height = soften_h + 2 * profile_skin)
                    rounded_rect_2d(box_w, box_d, corner_r);

            hull() {
                rounded_rect_slice(top_z,
                                   box_w,
                                   box_d,
                                   corner_r);
                rounded_rect_slice(box_h - profile_skin,
                                   box_w - 2 * soften_inset,
                                   box_d - 2 * soften_inset,
                                   corner_r - soften_inset);
            }
        }
    }
}

// ============================================================
// CURVED FRONT — replaces the flat +Y wall when bulge > 0
// ============================================================

// Y-coordinate of the outer curved surface at a given X.
function front_outer_y(x) =
    front_curve_bulge <= 0
        ? half_d
        : front_curve_axis_y + sqrt(pow(front_curve_r + wall_t / 2, 2) - pow(x, 2));

// Y-coordinate of the inner curved surface at a given X.
function front_inner_y(x) =
    front_curve_bulge <= 0
        ? half_d - wall_t
        : front_outer_y(x) - wall_t;

// 2D profile: the crescent between flat front and curved outer.
// Used by the brim extension.
module front_crescent_2d() {
    n = ceil(front_w / 2);
    pts = [for (i = [0:n])
        let (x = -front_w / 2 + i * front_w / n)
        [x, front_outer_y(x)] ];
    polygon(concat(
        [[-front_w / 2, half_d]],
        pts,
        [[ front_w / 2, half_d]]
    ));
}

// 2D profile: the front extension of the brim's inner opening.
// This removes the leftover flat strip that would otherwise sit
// behind the curved front wall at the top.
module front_brim_inner_extension_2d(brim_outset) {
    n = ceil(front_w / 2);
    pts = [for (i = [0:n])
        let (x = -front_w / 2 + i * front_w / n)
        [x, front_inner_y(x) - brim_outset] ];
    polygon(concat(
        [[-front_w / 2, inner_d / 2 - brim_outset]],
        pts,
        [[ front_w / 2, inner_d / 2 - brim_outset]]
    ));
}

// 2D profile: the full curved wall from inner to outer surface.
module curved_wall_profile_2d() {
    n = ceil(front_w / 2);
    outer_pts = [for (i = [0:n])
        let (x = -front_w / 2 + i * front_w / n)
        [x, front_outer_y(x)] ];
    inner_pts = [for (i = [0:n])
        let (x =  front_w / 2 - i * front_w / n)
        [x, front_outer_y(x) - wall_t] ];
    polygon(concat(
        [[-front_w / 2, half_d]],
        outer_pts,
        [[ front_w / 2, half_d]],
        [[ front_w / 2, half_d - wall_t]],
        inner_pts,
        [[-front_w / 2, half_d - wall_t]]
    ));
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
            ang = asin(x / front_curve_r);
            // Y position on the wall centreline.
            yc = front_curve_axis_y + front_curve_r * cos(ang);
            translate([x, yc, z])
                rotate([0, 0, -ang])
                    rotate([-90, 0, 0])
                        cylinder(d = hole_d, h = wall_t + 2, center = true,
                                 $fn = hole_fn);
        }
    }
}

// The curved front wall: single extrusion with holes.
module curved_front_wall() {
    difference() {
        linear_extrude(height = box_h)
            curved_wall_profile_2d();
        curved_wall_holes();
    }
}

// ============================================================
// BRIM — original flat-box brim + extension over the curve
// ============================================================

module top_brim() {
    brim_outset = max(0,
                      min(top_brim_outset,
                          inner_w / 2 - 0.5,
                          inner_d / 2 - 0.5));
    brim_h = max(top_brim_h, 0);
    brim_inner_w = inner_w - 2 * brim_outset;
    brim_inner_d = inner_d - 2 * brim_outset;
    brim_inner_r = max(0.01, inner_corner_r - brim_outset);

    if (brim_outset > 0 && brim_h > 0) {
        translate([0, 0, box_h - brim_h])
            linear_extrude(height = brim_h)
                difference() {
                    if (front_curve_bulge > 0) {
                        union() {
                            rounded_rect_2d(box_w, box_d, corner_r);
                            front_crescent_2d();
                        }
                    } else {
                        rounded_rect_2d(box_w, box_d, corner_r);
                    }

                    if (front_curve_bulge > 0) {
                        union() {
                            rounded_rect_2d(brim_inner_w, brim_inner_d, brim_inner_r);
                            front_brim_inner_extension_2d(brim_outset);
                        }
                    } else {
                        rounded_rect_2d(brim_inner_w, brim_inner_d, brim_inner_r);
                    }
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
    // Original floor (flat box interior).
    translate([0, 0, wall_t / 2]) {
        if (bottom_holes) {
            linear_extrude(height = wall_t, center = true)
                floor_profile_2d(inner_w, inner_d);
        } else {
            cube([inner_w, inner_d, wall_t], center = true);
        }
    }

    // Floor extension patch to reach the curved front wall.
    if (front_curve_bulge > 0) {
        n = ceil(front_w / 2);
        floor_pts = [for (i = [0:n])
            let (x = -front_w / 2 + i * front_w / n)
            [x, front_outer_y(x) - wall_t] ];
        translate([0, 0, wall_t / 2])
            linear_extrude(height = wall_t, center = true)
                polygon(concat(
                    [[-front_w / 2, inner_d / 2]],
                    floor_pts,
                    [[ front_w / 2, inner_d / 2]]
                ));
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

        // Bevel cutters only work on the flat-front box.
        // When the front is curved, skip them to avoid
        // non-manifold edges from the flat cutters slicing
        // into the curved wall.
        if (front_curve_bulge <= 0) {
            base_edge_cutter();
            top_edge_cutter();
        }
    }
}

// ============================================================
// RENDER
// ============================================================

mesh_box();
