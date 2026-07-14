// ============================================================
// Corner Edge Trim  (L-in-plan angle "nosing")
// An aluminium-stair-lip-style angle trim that slips over an
// exposed 90-degree edge (a top flange lying on the surface plus
// a face flange covering the vertical face), but which WRAPS AN
// OUTSIDE CORNER — an "L" when viewed from above. Edge protection
// / cover: the two arms turn the corner and shield both edges.
//
// Coordinate system (as installed):
//   X = run of one arm  (along one top edge)
//   Y = run of the other arm (along the adjacent top edge)
//   Z = height          (Z = 0 is the protected top surface;
//                        the face flanges hang down into -Z)
//
// The protected slab notionally fills the +X, +Y quadrant with its
// top at Z = 0; the outside corner is the Z axis at X = 0, Y = 0.
// The face flanges sit proud of the two vertical faces (X = 0 and
// Y = 0) on their outer, -X / -Y sides.
//
// Cross-section is an L (angle): a top flange (Z in [0, t]) that
// covers the surface, meeting a face flange (proud by t) that
// covers the vertical face. The concave inner corner is filleted.
//
// All exposed OUTER edges are eased so a bare toe can't catch on
// them (top nose, bottom lip, the flange's top-inner floor edge and
// the outside vertical corner). The two arm ENDS are left square so
// they butt flush against a wall.
//
// Standalone — no external dependencies.
// All units: millimeters.
// ============================================================

/* [Trim Geometry] */
arm_length_x     = 60;   // Run of the X arm from the corner (X)
arm_length_y     = 60;   // Run of the Y arm from the corner (Y)
top_flange_width = 25;   // How far the top flange covers the surface
drop_height      = 20;   // How far the face flange drops down the face
thickness        = 2;    // Wall thickness (t)
inner_fillet     = 1.5;  // Radius at the concave inner corner (0 = sharp)
edge_round       = 0.8;  // Rounding on the exposed outer edges (toe safety)

/* [View] */
export_mode      = "print"; // print | assembly

/* [Quality] */
$fa = 1;   // Minimum facet angle
$fs = 0.4; // Minimum facet edge length (mm), matched to a 0.4 mm nozzle

// ============================================================
// DERIVED
// ============================================================

// Each arm's extrude starts thickness past the corner (into the
// far arm's territory) so the outer corner post is fully filled
// when the two arms are unioned.
corner_overlap = thickness;

// Toe-safety rounding. The longitudinal (along-arm) edges are eased
// in the 2-D cross-section, clamped so a full round never eats
// through a flange. The outside vertical corner is eased in plan,
// clamped to stay inside the solid corner post.
edge_r   = min(edge_round, thickness / 2 - 0.05);
corner_r = min(edge_round, thickness - 0.05);

// ============================================================
// GEOMETRY
// ============================================================

// L cross-section, drawn in a local 2-D plane:
//   local X = across the top flange   (maps to world X for the Y arm)
//   local Y = vertical                (maps to world Z)
// The protected slab sits at local X >= 0; the face flange hangs
// on the outer side at local X in [-thickness, 0]. A morphological
// close (dilate then erode) rounds the concave inner corner into a
// fillet; a following open (erode then dilate) eases every convex
// outer edge by edge_r for toe safety. Both leave the straight flat
// faces in place, so the fit over the edge is unchanged.
module angle_profile_2d() {
    offset(r = edge_r) offset(r = -edge_r)              // open  -> round outer edges
    offset(r = -inner_fillet) offset(r = inner_fillet)  // close -> fillet inner corner
        polygon(points = [
            [-thickness,       -drop_height],  // outer-bottom of face flange
            [0,                -drop_height],  // inner-bottom of face flange
            [0,                 0],            // inner concave corner
            [top_flange_width,  0],            // inner end of top flange
            [top_flange_width,  thickness],    // outer end of top flange
            [-thickness,        thickness]     // outer-top, closes the loop
        ]);
}

// One arm, running along +Y, its face flange proud on the -X side.
// Extruded from Y = -corner_overlap through Y = arm_length_y.
module y_arm() {
    mirror([0, 1, 0])
        translate([0, corner_overlap, 0])
            rotate([90, 0, 0])
                linear_extrude(height = arm_length_y + corner_overlap, convexity = 10)
                    angle_profile_2d();
}

// The X arm is the Y arm reflected across the diagonal plane y = x
// (the corner's own symmetry plane): runs along +X, face flange on
// the -Y side.
module x_arm() {
    mirror([1, -1, 0]) y_arm();
}

// Vertical sliver removed at the outside corner (X = -t, Y = -t) to
// round that exposed vertical edge. Kept within the solid corner
// post (corner_r <= thickness) so it never bites into open space.
module outer_corner_sliver() {
    translate([-thickness, -thickness, -drop_height - 1])
        linear_extrude(height = drop_height + thickness + 2)
            difference() {
                square([corner_r, corner_r]);
                translate([corner_r, corner_r]) circle(r = corner_r);
            }
}

// Full corner trim: the two arms unioned (overlapping in the corner
// square to fill the outer corner post and keep the top plate and
// both face flanges continuous around the turn), with the outside
// vertical corner eased.
module corner_trim() {
    difference() {
        union() {
            y_arm();
            x_arm();
        }
        outer_corner_sliver();
    }
}

// ============================================================
// VIEWS
// ============================================================

// As-installed: top flanges up (Z in [0, t]), face flanges hanging
// down the two vertical faces.
module assembly_view() {
    color([0.72, 0.72, 0.74])
        corner_trim();
}

// Support-free print orientation: flipped upside-down so the broad
// L-shaped top flange lies flat on the bed and the two face flanges
// stand up as vertical walls (0-degree overhang, no supports).
module print_view() {
    color([0.72, 0.72, 0.74])
        translate([0, 0, thickness])
            rotate([180, 0, 0])
                corner_trim();
}

// ============================================================
// EXPORT
// ============================================================

if (export_mode == "print")
    print_view();
else
    assembly_view();
