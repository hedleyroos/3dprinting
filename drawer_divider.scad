// ============================================================
// Drawer Divider — inner cross-walls only, no border, no floor
//
// Drops into an existing drawer of a given inner width × depth and
// splits it into width_cells × depth_cells equal compartments
// (e.g. 3 × 2 = 6).  The drawer supplies the outer walls and the
// floor, so this model is nothing but the inner dividing walls,
// fused into one piece.
//
// The walls span the full width and depth, so every wall crosses
// every perpendicular wall and the whole grid unions into a single
// rigid part.  Each crossing gets four small concave fillets in its
// inside corners — light bracing that stiffens the junction without
// eating into the compartments.
//
// Everything is a vertical prism: printed upright (walls along Z)
// there is not a single overhang, so no supports are needed.  Bed
// contact is only the thin wall edges — use a slicer brim.
//
// Coordinate system:
//   X = width  (left → right),  origin at the drawer's inner left wall
//   Y = depth  (front → back),  origin at the drawer's inner front wall
//   Z = height (up from the bed)
//
// The part occupies exactly [0, width] × [0, depth] × [0, height]
// — a press fit against the drawer sides.
//
// All units: millimeters.
// ============================================================

/* [Quality] */
$fa = 1;   // Minimum angle — 1° gives max 360 facets per full circle
$fs = 0.4; // Minimum facet edge length (mm) — matched to a 0.4 mm nozzle

/* [Drawer] */
width  = 240;  // Drawer inner width  (X)
depth  = 180;  // Drawer inner depth  (Y)
height = 60;   // Divider wall height (Z)

/* [Grid] */
width_cells = 3;  // Number of compartments across the width
depth_cells = 2;  // Number of compartments across the depth

/* [Walls] */
// Keep wall_t just under a whole multiple of the extrusion width so the
// rib fills with perimeters only and leaves no gap-fill strip down its
// middle.  A thin rib uses 2 lines per loop (one per face), so at the
// 0.42 mm Bambu/Orca default: 2 loops = 1.68, 3 = 2.52, 4 = 3.36,
// 5 = 4.20.  2.5 mm gives 3 solid loops — stiff enough in PLA at this
// height without the material cost of a full 5-loop 4.2 mm wall.
// On PrusaSlicer (0.45 mm extrusion width) use 2.7 instead.
wall_t   = 2.5;  // Divider wall thickness — 3 perimeter loops at 0.42 mm
fillet_r = 3;    // Fillet radius in the inside corners at wall junctions

/* [View] */
part = "print";  // print | both

// ============================================================
// DERIVED
// ============================================================

// Number of dividing walls in each direction. N compartments need
// N-1 walls between them; there is no outer wall.
nx = width_cells - 1;   // walls running along Y (they divide the width)
ny = depth_cells - 1;   // walls running along X (they divide the depth)

// Compartment size — the leftover span once the walls are subtracted,
// divided equally.
cell_w = (width - nx * wall_t) / width_cells;
cell_d = (depth - ny * wall_t) / depth_cells;

// Wall centre lines.  Wall i sits after i compartments and i-1
// earlier walls, so its centre is at i*cell + (i - 0.5)*wall_t.
function wall_cx(i) = i * cell_w + (i - 0.5) * wall_t;
function wall_cy(j) = j * cell_d + (j - 0.5) * wall_t;

// Clamp the fillet so two fillets facing each other across the
// narrow dimension of a compartment can never merge into a solid.
fr = min(fillet_r, cell_w / 2, cell_d / 2);

eps = 0.01;

assert(cell_w > 0,
       "width_cells too high (or wall_t too thick) for the given width");
assert(cell_d > 0,
       "depth_cells too high (or wall_t too thick) for the given depth");

echo(str("Compartments: ", width_cells, " × ", depth_cells,
         " = ", width_cells * depth_cells,
         ", each ", cell_w, " × ", cell_d, " × ", height, " mm"));

// The bed is 270 × 270 mm; the divider prints flat in XY.
echo(width <= 270 && depth <= 270
     ? "Footprint fits the 270 × 270 mm bed."
     : str("WARNING: ", width, " × ", depth,
           " mm exceeds the 270 × 270 mm bed — split the divider."));

// ============================================================
// GEOMETRY
// ============================================================

// All dividing walls, each spanning the full drawer.  Because every
// wall is full-span, the union alone produces the joined grid — no
// per-segment stitching is needed.
module divider_walls() {
    // Walls that divide the width: thin in X, full depth in Y.
    for (i = [1 : 1 : nx])
        translate([wall_cx(i) - wall_t / 2, 0, 0])
            cube([wall_t, depth, height]);

    // Walls that divide the depth: full width in X, thin in Y.
    for (j = [1 : 1 : ny])
        translate([0, wall_cy(j) - wall_t / 2, 0])
            cube([width, wall_t, height]);
}

// One concave inside-corner fillet profile, occupying the square
// [0, r] × [0, r] with the arc centred at (r, r).  The corner itself
// sits at the origin, so the caller just translates it to the corner
// and rotates it to face into the compartment.
module fillet_2d(r) {
    difference() {
        square([r, r]);
        translate([r, r]) circle(r = r);
    }
}

// Four fillets in the inside corners of every wall crossing.  Skipped
// when the grid has no crossings (a 1 × N or N × 1 layout).
module junction_fillets() {
    if (nx > 0 && ny > 0 && fr > 0)
        for (i = [1 : 1 : nx])
            for (j = [1 : 1 : ny])
                for (sx = [-1, 1])
                    for (sy = [-1, 1])
                        translate([wall_cx(i) + sx * wall_t / 2,
                                   wall_cy(j) + sy * wall_t / 2,
                                   0])
                            rotate([0, 0, sx > 0 ? (sy > 0 ? 0 : -90)
                                                 : (sy > 0 ? 90 : 180)])
                                linear_extrude(height = height)
                                    fillet_2d(fr);
}

module drawer_divider() {
    union() {
        divider_walls();
        junction_fillets();
    }
}

// ============================================================
// RENDER
// ============================================================

if (part == "print") {

    // Print orientation — walls upright, no supports, add a brim.
    drawer_divider();

} else {  // "both" — single piece, same geometry

    drawer_divider();

}
