// ============================================================
// Mesh Box — Laptop Bag Insert
//
// Lightweight protective box with circular mesh cutouts on all
// five faces (four walls + floor).  Designed for ABS, printed
// upright with the open top facing +Z.
//
// Construction uses fast 2D booleans: each wall and the floor
// are built as a 2D profile with holes punched out, then
// extruded and assembled.  Four corner cylinders provide
// rounded external vertical edges and reinforce the joints.
//
// Coordinate system:
//   X = width  (260 mm, left→right)
//   Y = depth  (100 mm, front→back)
//   Z = height (300 mm, bed→top, origin at centre of bottom face)
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

// ============================================================
// HELPERS
// ============================================================

// Rounded rectangle matching the box footprint.
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

// 2D profile of a wall panel: rectangle with staggered circular
// holes.  Drawn in the XY plane; the Y axis will become Z after
// rotation.
//
//   w            – panel width  (X)
//   h            – panel height (Y, becomes Z)
//   side_margin  – keep-out from left / right edges (X)
//
module wall_profile_2d(w, h, side_margin) {
    difference() {
        square([w, h], center = true);

        // Staggered hole grid, shrunk so holes stay fully inside
        // the rim and margin keep-out zones.
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

// 2D profile of the floor: rectangle with staggered circular
// holes.  Keeps holes away from the inner wall faces so they
// don't notch the wall-foot junction.
//
//   iw  – interior width  (X, inside the walls)
//   id  – interior depth  (Y, inside the walls)
//
module floor_profile_2d(iw, id) {
    // Keep holes at least hole_r + wall_t from the inner wall
    // face so the subtraction cylinders stay inside the void.
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

// Removes the sharp lower outside corner with a printable bevel.
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

// Removes the sharp upper outside corner with a printable bevel.
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

// Horizontal inward brim at the top opening to stiffen the rim.
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
                    rounded_rect_2d(box_w, box_d, corner_r);
                    rounded_rect_2d(brim_inner_w, brim_inner_d, brim_inner_r);
        }
    }
}

// ============================================================
// GEOMETRY
// ============================================================

// Front / back wall panel.
//   y_center  – Y position of the wall centreline
//   w, h      – panel dimensions
//   margin    – hole keep-out from panel edges
//
module front_back_wall(y_center, w, h, margin) {
    // 2D profile → extrude → rotate 90° around X → position in Y
    translate([0, y_center, h / 2])
        rotate([90, 0, 0])
            linear_extrude(height = wall_t, center = true)
                wall_profile_2d(w, h, margin);
}

// Left / right wall panel.
//   x_center  – X position of the wall centreline
//   w, h      – panel dimensions
//   margin    – hole keep-out from panel edges
//
module side_wall_panel(x_center, w, h, margin) {
    // 2D profile → extrude → rotate X then Z → position in X
    //   rotate([90, 0, 90]) maps:
    //     2D X (width)  → world Y (depth)
    //     2D Y (height) → world Z (vertical)
    //     extrude Z     → world X (thickness)
    translate([x_center, 0, h / 2])
        rotate([90, 0, 90])
            linear_extrude(height = wall_t, center = true)
                wall_profile_2d(w, h, margin);
}

// Four corner cylinders for rounded vertical edges.
module corner_posts() {
    for (x = [-1, 1], y = [-1, 1]) {
        translate([x * (half_w - corner_r),
                   y * (half_d - corner_r),
                   0])
            cylinder(r = corner_r, h = box_h, $fn = corner_fn);
    }
}

// Floor panel with optional holes.
module floor_panel() {
    if (bottom_holes) {
        linear_extrude(height = wall_t, center = true)
            floor_profile_2d(inner_w, inner_d);
    } else {
        cube([inner_w, inner_d, wall_t], center = true);
    }
}

// ----- assembly -----------------------------------------------------------

module mesh_box_body() {
    union() {
        // Corner posts (visible, use corner_fn).
        corner_posts();

        // Front / back walls.
        front_back_wall( half_d - wall_t / 2, front_w, box_h, corner_margin - corner_r);
        front_back_wall(-half_d + wall_t / 2, front_w, box_h, corner_margin - corner_r);

        // Left / right walls.
        side_wall_panel( half_w - wall_t / 2, side_w, box_h, corner_margin - corner_r);
        side_wall_panel(-half_w + wall_t / 2, side_w, box_h, corner_margin - corner_r);

        // Floor.
        translate([0, 0, wall_t / 2])
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
