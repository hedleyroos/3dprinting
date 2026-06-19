// ============================================================
// Mesh Box — Sliced for Printing (flat-wall variant)
//
// Splits the box horizontally so the 300 mm tall box fits on a
// typical ~220 mm printer.  Standalone — no external dependencies.
//
// Joint = the solid INNER BAND (defined in mesh_box.scad) doubling as
// a tongue-lap (the "overlap method" for an acetone weld).  The split
// passes through the band's centre; the full 25 mm band rides on the
// top half and its lower half laps down as a solid 3 mm tongue into a
// matching socket cut into the bottom half's inner wall.  Because the
// band is hole-free and thick, the weld surface is large, continuous,
// and far stronger than a thin meshed collar.  WELD-ONLY by default
// (no screws); set use_screws=true to re-enable the cross-lap
// fastener provisions through the tongue.
//
// The split height is fixed at the band centre (box_h/2 = 150 mm),
// giving two ~150 mm halves that fit a typical ~220 mm printer.
//
// Coordinate system:  see mesh_box.scad.
//   X = width,  Y = depth,  Z = height (origin at centre of
//   bottom face).
//
// All units: millimeters.
// ============================================================

/* [Split] */
split_auto              = true;  // Auto-compute split height (recommended)
slice_z_override        = 161;   // Manual split height (only when split_auto=false)

/* [Joint — Band Tongue Lap] */
// The split passes through the centre of the solid inner band.  The
// full band rides on the TOP half; its lower half laps down as a
// solid 3 mm tongue into a socket cut into the bottom half's inner
// wall.  Large, hole-free weld surface.
collar_clearance  = 0.25;  // Radial gap on the tongue's free face for glue / fit (mm)
collar_bottom_gap = 0.3;   // Extra socket depth so the tongue tip clears (mm)

/* [Joint — Screws (off by default; weld only)] */
use_screws            = false; // Add cross-lap screw provisions
screw_d               = 3.4;   // Clearance hole through the outer wall (M3)
boss_d                = 8.0;   // Boss dia on the collar (room for a heat-set insert)
boss_proj             = 6.0;   // How far the boss projects inward past the collar (mm)
insert_pilot_d        = 4.0;   // Heat-set insert pilot dia (use ~2.8 for self-tap)
screws_long_wall      = 2;     // Screws in EACH long (front/back) wall
screws_per_side_wall  = 1;     // Screws in EACH side wall (left/right)

/* [View] */
part                    = "both"; // bottom | top | both | exploded

/* [Quality] */
$fn                     = 40;    // Global fallback
$fa                     = 1;
$fs                     = 0.4;

// ============================================================
// Parameters — all defined locally (this file is standalone).
// ============================================================

/* [Box Dimensions] */
box_w                   = 260;   // Outer width  (X)
box_d                   = 100;   // Outer depth  (Y)
box_h                   = 300;   // Outer height (Z)

/* [Wall] */
wall_t                  = 5;     // Wall and floor thickness
corner_r                = 8;     // External vertical corner radius
corner_fn               = 60;    // Corner facet count
base_edge_inset         = 3.5;   // Bottom bevel pull-in to soften the base edge
base_edge_h             = 6;     // Height of the softened base band

/* [Top Brim] */
top_brim_outset         = 8;     // Horizontal overhang into the open top
top_brim_h              = 4;     // Thickness of the top reinforcement brim
top_edge_inset          = 3;     // Top bevel pull-in to soften the outer rim
top_edge_h              = 4;     // Height of the softened top band

/* [Mesh Holes] */
hole_d                  = 12;    // Circular hole diameter
hole_spacing            = 16;    // Centre-to-centre hole spacing
hole_fn                 = 30;    // Hole facet count
rim_top                 = 10;    // Solid band at top (no holes)
rim_bottom              = 10;    // Solid band at bottom (no holes)
corner_margin           = 12;    // No-hole keep-out from each vertical edge

/* [Bottom] */
bottom_holes            = true;  // Enable mesh holes in the floor

/* [Inner Band] */                // Keep in sync with mesh_box.scad
band_t                  = 3;     // Inward projection thickness of the inner band
band_h                  = 25;    // Vertical height of the band
band_z                  = box_h / 2; // Vertical centre of the band

// Derived.
half_w  = box_w / 2;
half_d  = box_d / 2;
hole_r  = hole_d / 2;
hsp     = hole_spacing;
inner_w = box_w - 2 * wall_t;
inner_d = box_d - 2 * wall_t;
inner_corner_r = max(0.01, corner_r - wall_t);
band_inner_r   = inner_corner_r; // Rounding on the band's inner edge (corners)
band_bot = band_z - band_h / 2;
band_top = band_z + band_h / 2;
front_w = box_w - 2 * corner_r;
side_w  = box_d - 2 * corner_r;
profile_skin = 0.05;

// ============================================================
// MODULES — all geometry is defined locally (standalone file)
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

        band_zc = band_z - h / 2;

        for (row = [0 : rows - 1]) {
            z = zs + row * hsp;
            if (abs(z - band_zc) >= band_h / 2 + hole_r) {
                stagger = (row % 2 == 0) ? 0 : hsp / 2;
                for (x = [xs + stagger : hsp : xe]) {
                    translate([x, z])
                        circle(d = hole_d, $fn = hole_fn);
                }
            }
        }
    }
}

module floor_profile_2d(iw, id) {
    margin = hole_r + 4;

    xs = -iw / 2 + margin;
    xe =  iw / 2 - margin;
    ys = -id / 2 + margin;
    ye =  id / 2 - margin;

    difference() {
        square([iw, id], center = true);

        cols = floor((ye - ys) / hsp + 1e-6) + 1;
        y0   = -(cols - 1) * hsp / 2;

        for (col = [0 : cols - 1]) {
            y = y0 + col * hsp;
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

module front_back_wall(y_center, w, h, margin) {
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
            linear_extrude(height = box_h)
                scale([x, y])
                    intersection() {
                        difference() {
                            circle(r = corner_r, $fn = corner_fn);
                            circle(r = corner_r - wall_t, $fn = corner_fn);
                        }
                        square([corner_r + profile_skin,
                                corner_r + profile_skin]);
                    }
    }
}

module inner_band() {
    translate([0, 0, band_z - band_h / 2])
        linear_extrude(height = band_h)
            difference() {
                rounded_rect_2d(inner_w, inner_d, inner_corner_r);
                rounded_rect_2d(inner_w - 2 * band_t,
                                inner_d - 2 * band_t, band_inner_r);
            }
}

module floor_panel() {
    if (bottom_holes) {
        linear_extrude(height = wall_t, center = true)
            floor_profile_2d(inner_w, inner_d);
    } else {
        cube([inner_w, inner_d, wall_t], center = true);
    }
}

module mesh_box_body() {
    union() {
        corner_posts();

        front_back_wall( half_d - wall_t / 2, front_w, box_h, corner_margin - corner_r);
        front_back_wall(-half_d + wall_t / 2, front_w, box_h, corner_margin - corner_r);

        side_wall_panel( half_w - wall_t / 2, side_w, box_h, corner_margin - corner_r);
        side_wall_panel(-half_w + wall_t / 2, side_w, box_h, corner_margin - corner_r);

        translate([0, 0, wall_t / 2])
            floor_panel();

        inner_band();
    }
}

// ============================================================
// LOCAL HELPERS
// ============================================================

// Flat outer footprint (no curved front).  z is accepted for
// signature-compatibility with the rounded variant but ignored.
module outer_footprint_2d(z = 0) {
    rounded_rect_2d(box_w, box_d, corner_r);
}

// ============================================================
// DERIVED — Split Height
// ============================================================
//
// The split passes through the centre of the solid inner band, so
// the seam lands in hole-free material and the band reinforces it.

slice_z = split_auto ? band_z : slice_z_override;

// Clamp the seam to stay inside the band so the tongue/socket
// geometry remains valid.
slice_z_clamped = max(band_bot + 1,
                  min(band_top - 1,
                      slice_z));

// Screw row sits mid-lap (through the bottom wall into the tongue).
screw_z = (band_bot + slice_z_clamped) / 2;

echo(str("===== Sliced Box (flat) ====="));
echo(str("Split height:        ", slice_z_clamped, " mm  (band centre ", band_z, ")"));
echo(str("Bottom piece Z:       0 -> ", slice_z_clamped, " mm  (", slice_z_clamped, " mm tall)"));
echo(str("Top piece Z:          ", slice_z_clamped, " -> ", box_h, " mm  (", box_h - slice_z_clamped, " mm tall)"));
echo(str("Band:                 ", band_h, " mm tall x ", band_t, " mm thick; tongue laps ", slice_z_clamped - band_bot, " mm"));
echo(str("Screws:               ", use_screws ? "enabled" : "DISABLED (weld only)"));

// ============================================================
// SPLIT HELPERS — large keep-out cubes for intersection()
// ============================================================

module keep_below(z) {
    translate([-box_w, -box_d, -1])
        cube([2 * box_w, 2 * box_d, z + 1]);
}

module keep_above(z) {
    translate([-box_w, -box_d, z])
        cube([2 * box_w, 2 * box_d, box_h - z + 1]);
}

// ============================================================
// BAND TONGUE LAP — joint formed by the solid inner band
// ============================================================

// 2D footprint of the inner band: a ring of width band_t projecting
// inward from the inner wall face.  Matches inner_band() in the parent.
module band_ring_2d() {
    difference() {
        rounded_rect_2d(inner_w, inner_d, inner_corner_r);
        // Explicit rounded inner edge so the corners stay rounded.
        rounded_rect_2d(inner_w - 2 * band_t,
                        inner_d - 2 * band_t, band_inner_r);
    }
}

// The lower half of the band, carried down by the TOP half as a solid
// tongue that laps into the bottom half's socket.
module band_tongue() {
    translate([0, 0, band_bot])
        linear_extrude(height = slice_z_clamped - band_bot + 0.01)
            band_ring_2d();
}

// Socket cut into the BOTTOM half: removes the band-region material
// (band thickness + clearance, measured inward from the inner wall
// face) so the tongue nests against the wall.  A little extra depth
// (collar_bottom_gap) at the very bottom clears the tongue tip.
module band_socket_cut() {
    translate([0, 0, band_bot - collar_bottom_gap])
        linear_extrude(height = slice_z_clamped - band_bot + collar_bottom_gap + 0.01)
            difference() {
                rounded_rect_2d(inner_w, inner_d, inner_corner_r);
                rounded_rect_2d(inner_w - 2 * (band_t + collar_clearance),
                                inner_d - 2 * (band_t + collar_clearance),
                                band_inner_r);
            }
}

// ============================================================
// SCREWS — cross-lap fasteners (optional; off by default)
// ============================================================

module screw_sites() {
    if (use_screws) {
        bx_span = box_w - 2 * 30;
        for (i = [0 : screws_long_wall - 1]) {
            x = screws_long_wall <= 1 ? 0
                : -bx_span / 2 + i * bx_span / (screws_long_wall - 1);
            translate([x,  half_d, screw_z]) rotate([ 90, 0, 0]) children();  // front +Y
            translate([x, -half_d, screw_z]) rotate([-90, 0, 0]) children();  // back  -Y
        }
        sy_span = box_d - 2 * 20;
        for (j = [0 : screws_per_side_wall - 1]) {
            y = screws_per_side_wall <= 1 ? 0
                : -sy_span / 2 + j * sy_span / (screws_per_side_wall - 1);
            translate([ half_w, y, screw_z]) rotate([0, -90, 0]) children();
            translate([-half_w, y, screw_z]) rotate([0,  90, 0]) children();
        }
    }
}

module screw_clearance() {
    translate([0, 0, -1])
        cylinder(d = screw_d, h = wall_t + 12, $fn = 24);
}

module screw_boss() {
    // Boss on the inner face of the band tongue, projecting further in.
    translate([0, 0, wall_t])
        cylinder(d = boss_d, h = band_t + boss_proj, $fn = 32);
}

module screw_pilot() {
    translate([0, 0, -1])
        cylinder(d = insert_pilot_d, h = wall_t + band_t + boss_proj + 4, $fn = 24);
}

// ============================================================
// RAW HALVES — geometry before joinery features
// ============================================================

module mesh_box_sliced_bottom_raw() {
    intersection() {
        mesh_box_body();
        keep_below(slice_z_clamped);
    }
}

module mesh_box_sliced_top_raw() {
    union() {
        intersection() {
            mesh_box_body();
            keep_above(slice_z_clamped);
        }
        // The top brim sits at the very top and is not part of
        // mesh_box_body(), so add it explicitly.
        top_brim();
    }
}

// ============================================================
// FINAL PIECES
// ============================================================

module mesh_box_sliced_bottom() {
    difference() {
        mesh_box_sliced_bottom_raw();

        // Carve the socket that receives the band tongue.
        band_socket_cut();

        // Optional screw clearance holes through the outer wall.
        if (use_screws) screw_sites() screw_clearance();

        // Soften the outer bottom edge.
        base_edge_cutter();
    }
}

module mesh_box_sliced_top() {
    difference() {
        union() {
            mesh_box_sliced_top_raw();

            // Solid band tongue lapping down into the bottom-half socket.
            band_tongue();

            // Optional bosses on the tongue for cross-lap screws.
            if (use_screws) screw_sites() screw_boss();
        }

        // Optional insert pilots through tongue + boss.
        if (use_screws) screw_sites() screw_pilot();

        // Soften the outer top edge.
        top_edge_cutter();
    }
}

// ============================================================
// RENDER
// ============================================================

if (part == "bottom") {

    mesh_box_sliced_bottom();

} else if (part == "top") {

    mesh_box_sliced_top();

} else if (part == "exploded") {

    // Both pieces laid flat on the bed, flat-back to flat-back with
    // a 5 mm gap.  Bottom piece floor-down; top piece flipped brim-
    // down so its collar prints upward.
    gap       = 5;
    half_gap  = gap / 2;
    bottom_y  = half_d + half_gap;
    top_y     = -(half_d + half_gap);

    translate([0, bottom_y, 0])
        mesh_box_sliced_bottom();

    translate([0, top_y, box_h])
        rotate([180, 0, 0])
            mesh_box_sliced_top();

} else {  // "both" — assembled view for fit checking

    mesh_box_sliced_bottom();
    mesh_box_sliced_top();

}
