// ============================================================
// Mesh Box — Sliced for Printing (Overlapping Collar Joint)
//
// Splits mesh_box_rounded.scad horizontally so the 300 mm tall
// box fits on typical 220 mm printers.  Intended as a backpack
// endoskeleton, so the joint must resist BENDING (the pack
// flexing front<->back puts the wall at the split in tension),
// not just racking.
//
// The two halves join with a continuous half-lap COLLAR around
// the full wall perimeter: the top half carries the inner half
// of the wall down past the split, nesting into a matching
// rebate cut into the bottom half.  This gives a large glue/weld
// area + real bending stiffness.  Designed to be acetone-welded
// AND screwed across the lap (screws give tension/peel capacity
// and serviceability; the weld makes it effectively monolithic).
//
// The split height is auto-computed to fall in the solid band
// between mesh-hole rows; the screw row is likewise snapped to a
// solid inter-row gap inside the overlap band.
//
// Coordinate system:  see mesh_box_rounded.scad.
//   X = width,  Y = depth,  Z = height (origin at centre of
//   bottom face).
//
// All units: millimeters.
// ============================================================

/* [Split] */
split_auto              = true;  // Auto-compute split height (recommended)
slice_z_override        = 150;   // Manual split height (only when split_auto=false)

/* [Joint — Overlapping Collar (half-lap)] */
collar_height     = 28;    // How far the collar laps below the split (mm)
collar_t          = 2.0;   // Collar thickness (~half the 4 mm wall) (mm)
collar_clearance  = 0.25;  // Gap on the lap step face for glue / print fit (mm)
collar_bottom_gap = 0.3;   // Extra socket depth so the collar tip clears (mm)

/* [Joint — Screws] */
use_screws            = true;  // Add cross-lap screw provisions
screw_d               = 3.4;   // Clearance hole through the outer wall (M3)
boss_d                = 8.0;   // Boss dia on the collar (room for a heat-set insert)
boss_proj             = 6.0;   // How far the boss projects inward past the collar (mm)
insert_pilot_d        = 4.0;   // Heat-set insert pilot dia (use ~2.8 for self-tap)
screws_back_wall      = 2;     // Screws in the flat back wall
screws_per_side_wall  = 1;     // Screws in EACH side wall (left/right)
// Front wall is curved + already stiff -> no screws there.

/* [View] */
part                    = "both"; // bottom | top | both | exploded

/* [Quality] */
$fn                     = 40;    // Global fallback
$fa                     = 1;
$fs                     = 0.4;

// ============================================================
// INHERITED PARAMETERS — local copies of the parent's variables
// that this file needs directly.  Modules and functions come
// from the parent via `use` (they keep their original scope, so
// mesh_box_body() etc. work with the parent's own parameters).
//
// Keep these in sync with mesh_box_rounded.scad.
// ============================================================

/* [Box Dimensions] */
box_w                   = 260;   // Outer width  (X)
box_d                   = 95;    // Outer depth  (Y)
box_h                   = 300;   // Outer height (Z)

/* [Wall] */
wall_t                  = 4;     // Wall and floor thickness

/* [Mesh Holes] */
hole_d                  = 16;    // Circular hole diameter
hole_spacing            = 22;    // Centre-to-centre hole spacing
rim_top                 = 15;    // Solid band at top (no holes)
rim_bottom              = 10;    // Solid band at bottom (no holes)

// Derived.
hole_r  = hole_d / 2;
hsp     = hole_spacing;

// Modules & functions from the parent (no auto‑render with `use`).
use <mesh_box_rounded.scad>

// ============================================================
// DERIVED — Split Height
// ============================================================

// Recursively find the inter-row solid gap whose midpoint is
// closest to |target|.  Returns that midpoint Z.
function _find_best_split(zs, step, rows, target, i, best_mid, best_dist) =
    i >= rows - 1
        ? best_mid
        : let(
            z_lo = zs + i * step + hole_r,       // top edge of row i  holes
            z_hi = zs + (i + 1) * step - hole_r, // bot edge of row i+1 holes
            mid  = (z_lo + z_hi) / 2,
            dist = abs(mid - target)
          )
          dist < best_dist
              ? _find_best_split(zs, step, rows, target, i + 1, mid, dist)
              : _find_best_split(zs, step, rows, target, i + 1, best_mid, best_dist);

function compute_slice_z() =
    let(
        zs     = rim_bottom + hole_r,
        ze     = box_h - rim_top - hole_r,
        rows   = fitted_line_count(zs, ze, hsp),
        step   = fitted_line_step(zs, ze, hsp),
        target = box_h / 2
    )
    _find_best_split(zs, step, rows, target, 0, box_h / 2, 1e9);

slice_z = split_auto ? compute_slice_z() : slice_z_override;

// Clamp to a sensible range (leave room below the split for the
// full collar lap + tip clearance, and a little wall above).
slice_z_clamped = max(wall_t + collar_height + collar_bottom_gap + 1,
                  min(box_h - wall_t - 1,
                      slice_z));

// Plan-view half-extents (parent's derived vars aren't imported by `use`).
half_w = box_w / 2;
half_d = box_d / 2;

// Collar / rebate band.
collar_z_bottom = slice_z_clamped - collar_height;
rebate_z_bottom = collar_z_bottom - collar_bottom_gap;

// Snap the screw row to the inter-row solid gap nearest the overlap
// centre, so screws never cross a mesh hole.  Reuses the hole-row
// layout helpers from the parent.
function compute_screw_z() =
    let(
        zs     = rim_bottom + hole_r,
        ze     = box_h - rim_top - hole_r,
        rows   = fitted_line_count(zs, ze, hsp),
        step   = fitted_line_step(zs, ze, hsp),
        target = slice_z_clamped - collar_height / 2
    )
    _find_best_split(zs, step, rows, target, 0, target, 1e9);

// Keep the boss fully inside the overlap band.
screw_z = max(collar_z_bottom + boss_d / 2 + 1,
          min(slice_z_clamped - boss_d / 2 - 1,
              compute_screw_z()));

echo(str("===== Sliced Box ====="));
echo(str("Split height:        ", slice_z_clamped, " mm  (raw computed: ", slice_z, ")"));
echo(str("Bottom piece Z:       0 → ", slice_z_clamped, " mm  (", slice_z_clamped, " mm tall)"));
echo(str("Top piece Z:          ", slice_z_clamped, " → ", box_h, " mm  (", box_h - slice_z_clamped, " mm tall)"));
echo(str("Collar:               ", collar_height, " mm tall × ", collar_t, " mm thick (half-lap)"));
echo(str("Collar clearance:     ", collar_clearance, " mm (step), ", collar_bottom_gap, " mm (tip)"));
echo(str("Screw row Z:          ", screw_z, " mm"));
echo(str("Screws:               back=", screws_back_wall, "  each side=", screws_per_side_wall, "  (use_screws=", use_screws, ")"));

// ============================================================
// SPLIT HELPERS — large keep-out cubes for intersection()
// ============================================================

// Everything at or below z.
module keep_below(z) {
    translate([-box_w, -box_d, -1])
        cube([2 * box_w, 2 * box_d, z + 1]);
}

// Everything at or above z.
module keep_above(z) {
    translate([-box_w, -box_d, z])
        cube([2 * box_w, 2 * box_d, box_h - z + 1]);
}

// ============================================================
// COLLAR & REBATE — half-lap joint around the full perimeter
// ============================================================
//
// The wall cross-section (outer edge .. offset -wall_t) is split
// into an OUTER half and an INNER half along offset -collar_t.
// Over the overlap band the bottom half keeps only its outer half
// (the rebate removes the inner half); the top half's collar is the
// inner half, hanging down into that socket.  All profiles come
// from outer_footprint_2d() via offset(), so they follow the flat
// walls, the curved front and the rounded corners automatically.

// 2D ring: the INNER half of the wall, shrunk on the step face by
// collar_clearance so it slides into the socket with a glue gap.
module collar_ring_2d() {
    difference() {
        offset(r = -(wall_t - collar_t + collar_clearance))
            outer_footprint_2d(slice_z_clamped);
        offset(r = -wall_t)
            outer_footprint_2d(slice_z_clamped);
    }
}

// The collar hanging below the split on the top half.  Its top face
// (at slice_z) overlaps the top wall's inner half, so it fuses to
// the top piece; its body nests into the bottom-half socket.
module collar() {
    translate([0, 0, collar_z_bottom])
        linear_extrude(height = collar_height + 0.1)
            collar_ring_2d();
}

// Solid plug that fills everything inside the lap step — subtracted
// from the bottom half to carve the receiving socket (rebate).
module rebate_cut() {
    translate([0, 0, rebate_z_bottom])
        linear_extrude(height = slice_z_clamped - rebate_z_bottom + 0.1)
            offset(r = -(wall_t - collar_t))
                outer_footprint_2d(slice_z_clamped);
}

// ============================================================
// SCREWS — cross-lap fasteners through the overlap band
// ============================================================

// Place children at each screw site, +Z pointing inward along the
// wall normal, origin on the OUTER wall face.
module screw_sites() {
    if (use_screws) {
        // Back wall (-Y face): inward normal +Y.
        bx_span = box_w - 2 * 30;
        for (i = [0 : screws_back_wall - 1]) {
            x = screws_back_wall <= 1 ? 0
                : -bx_span / 2 + i * bx_span / (screws_back_wall - 1);
            translate([x, -half_d, screw_z]) rotate([-90, 0, 0]) children();
        }
        // Side walls: inward normals -X (right) and +X (left).
        sy_span = box_d - 2 * 20;
        for (j = [0 : screws_per_side_wall - 1]) {
            y = screws_per_side_wall <= 1 ? 0
                : -sy_span / 2 + j * sy_span / (screws_per_side_wall - 1);
            translate([ half_w, y, screw_z]) rotate([0, -90, 0]) children();
            translate([-half_w, y, screw_z]) rotate([0,  90, 0]) children();
        }
    }
}

// Clearance hole through the outer wall and across the gap (bottom).
module screw_clearance() {
    translate([0, 0, -1])
        cylinder(d = screw_d, h = wall_t + 12, $fn = 24);
}

// Boss on the collar inner face for a heat-set insert (top).
module screw_boss() {
    translate([0, 0, wall_t - collar_t + collar_clearance])
        cylinder(d = boss_d,
                 h = (collar_t - collar_clearance) + boss_proj, $fn = 32);
}

// Insert pilot drilled through the collar + boss (top).
module screw_pilot() {
    translate([0, 0, -1])
        cylinder(d = insert_pilot_d, h = wall_t + boss_proj + 4, $fn = 24);
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
        // The top brim lives at the very top of the box and is
        // not part of mesh_box_body(), so we add it explicitly.
        top_brim();
    }
}

// ============================================================
// FINAL PIECES
// ============================================================

module mesh_box_sliced_bottom() {
    render() {
    difference() {
        mesh_box_sliced_bottom_raw();

        // Carve the socket that receives the collar (removes the
        // inner half of the wall over the overlap band).
        rebate_cut();

        // Screw clearance holes through the outer wall.
        if (use_screws) screw_sites() screw_clearance();

        // Soften the outer bottom edge (subtractive — must be
        // inside the difference block, same pattern as the
        // original mesh_box()).
        base_edge_cutter();
    }
    }
}

module mesh_box_sliced_top() {
    render() {
    difference() {
        union() {
            mesh_box_sliced_top_raw();

            // Collar lapping down into the bottom-half socket.
            collar();

            // Bosses on the collar for the cross-lap screws.
            if (use_screws) screw_sites() screw_boss();
        }

        // Insert pilots through collar + boss.
        if (use_screws) screw_sites() screw_pilot();

        // Soften the outer top edge (subtractive — must be
        // inside the difference block, same pattern as the
        // original mesh_box()).
        top_edge_cutter();
    }
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

    // Both pieces laid flat on the print bed (XY plane),
    // flat‑back to flat‑back with a 5 mm gap, fitting a
    // 270 × 270 mm bed.
    //
    // Bottom piece: natural orientation, floor on the bed.
    // Top piece:    flipped upside‑down (brim on the bed),
    //               so the tongue prints upward.
    //
    // The flat backs face each other across the gap; the
    // curved fronts point outward to opposite edges of the bed.

    gap       = 5;
    half_gap  = gap / 2;

    // Bottom piece flat back (design Y = -half_d) placed at
    // world Y = +half_gap so the piece extends away from the
    // centre gap toward +Y.
    // Y shift: half_gap - (-half_d) = half_d + half_gap
    bottom_y  = half_d + half_gap;

    // Top piece after rotate([180,0,0]): flat back moves to
    // world Y = +half_d.  We place it at world Y = -half_gap
    // so it extends away from the centre gap toward -Y.
    // Y shift: -half_gap - half_d = -(half_d + half_gap)
    top_y     = -(half_d + half_gap);

    // Bottom piece — floor on the bed.
    translate([0, bottom_y, 0])
        mesh_box_sliced_bottom();

    // Top piece — rotated 180° around X so the brim sits on
    // the bed, then lifted so the brim face is at z = 0.
    translate([0, top_y, box_h])
        rotate([180, 0, 0])
            mesh_box_sliced_top();

} else {  // "both" — assembled view for fit checking

    mesh_box_sliced_bottom();
    mesh_box_sliced_top();

}
