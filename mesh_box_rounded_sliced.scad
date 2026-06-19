// ============================================================
// Mesh Box — Sliced for Printing (Tongue & Groove Joint)
//
// Splits mesh_box_rounded.scad horizontally so the 300 mm tall
// box fits on typical 220 mm printers.  The two halves join
// with a continuous tongue-and-groove around the full wall
// perimeter — far stronger than corner dowels for lateral loads.
//
// The split height is auto-computed to fall in the solid band
// between mesh-hole rows, keeping the groove clear of holes.
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

/* [Joint] */
groove_width            = 2.0;   // Width of the U-channel (mm)
groove_depth            = 2.0;   // Depth of the groove into bottom half (mm)
tongue_clearance        = 0.3;   // Total diametral clearance (0.15 per side)
tongue_bottom_clearance = 0.2;   // Extra depth so tongue doesn't bottom out

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

// Clamp to a sensible range.
slice_z_clamped = max(wall_t + groove_depth + 1,
                  min(box_h - wall_t - groove_depth - 1,
                      slice_z));

tongue_width  = groove_width - tongue_clearance;
tongue_height = groove_depth - tongue_bottom_clearance;

echo(str("===== Sliced Box ====="));
echo(str("Split height:        ", slice_z_clamped, " mm  (raw computed: ", slice_z, ")"));
echo(str("Bottom piece Z:       0 → ", slice_z_clamped, " mm  (", slice_z_clamped, " mm tall)"));
echo(str("Top piece Z:          ", slice_z_clamped, " → ", box_h, " mm  (", box_h - slice_z_clamped, " mm tall)"));
echo(str("Groove:               ", groove_width, " × ", groove_depth, " mm"));
echo(str("Tongue:               ", tongue_width, " × ", tongue_height, " mm"));
echo(str("Clearance:            ", tongue_clearance, " mm diametral"));
echo(str("Bottom clearance:     ", tongue_bottom_clearance, " mm"));

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
// GROOVE & TONGUE — 2D ring profiles
// ============================================================

// Thin 2D ring centred on the wall midline at the split height.
// The ring follows the full perimeter (flat walls + curved front
// + rounded corners) because it is derived from
// outer_footprint_2d(slice_z) via offset().
//
//   outer_footprint_2d        — outer face of the wall
//   offset(r = -half_wall)    — wall centreline
//   offset(r = -(half_wall ± half_width)) — inner/outer edges of channel
//
module groove_profile_2d() {
    half_gw = groove_width / 2;
    half_w  = wall_t / 2;
    difference() {
        offset(r = -(half_w - half_gw))
            outer_footprint_2d(slice_z_clamped);
        offset(r = -(half_w + half_gw))
            outer_footprint_2d(slice_z_clamped);
    }
}

module tongue_profile_2d() {
    half_tw = tongue_width / 2;
    half_w  = wall_t / 2;
    difference() {
        offset(r = -(half_w - half_tw))
            outer_footprint_2d(slice_z_clamped);
        offset(r = -(half_w + half_tw))
            outer_footprint_2d(slice_z_clamped);
    }
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
    difference() {
        mesh_box_sliced_bottom_raw();

        // U-groove cut into the top face, extending downward.
        translate([0, 0, slice_z_clamped - groove_depth])
            linear_extrude(height = groove_depth + 0.1)
                groove_profile_2d();

        // Soften the outer bottom edge (subtractive — must be
        // inside the difference block, same pattern as the
        // original mesh_box()).
        base_edge_cutter();
    }
}

module mesh_box_sliced_top() {
    difference() {
        union() {
            mesh_box_sliced_top_raw();

            // Tongue extending below the bottom face into the
            // groove of the lower half.
            translate([0, 0, slice_z_clamped - tongue_height])
                linear_extrude(height = tongue_height)
                    tongue_profile_2d();
        }

        // Soften the outer top edge (subtractive — must be
        // inside the difference block, same pattern as the
        // original mesh_box()).
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
    half_d    = box_d / 2;

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
