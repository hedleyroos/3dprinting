// ============================================================
// Drawer Divider — meshed inner cross-walls, no border, no floor
// Split into two halves that locate on each other with a tongue
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
// MESH
// A solid wall is mostly wasted filament: a divider only has to stop
// things sliding sideways.  So each panel is pierced with a grid of
// square holes, leaving mesh_strut-wide struts between them.  The
// pattern is fitted per bay — the run of panel between two crossings
// — so every bay gets whole holes and a full-width strut at each end,
// and the top and bottom edges of every panel stay solid.
//
// Struts are still the full wall thickness, so the panel keeps its
// stiffness against the load that matters (sideways push) and only
// loses material where nothing was working.
//
// SPLIT
// The full-width wall is too long for the bed, so the divider is cut
// on a vertical plane at split_x (default: half the width) into a
// LEFT and a RIGHT piece.  Every full-width wall crossing that plane
// carries a tongue and groove:
//
//   - the wall is locally thickened into a small boss, tapered at
//     both ends so there is no abrupt stress riser,
//   - the LEFT piece grows a plain flat tongue out of that boss,
//   - the RIGHT piece has the matching groove milled into its boss.
//
// The joint is for ALIGNMENT ONLY — it keeps the two halves flush
// and in line while they are dropped into the drawer.  It is a slip
// fit with a chamfered lead-in, not a snap: nothing has to flex, and
// the halves push apart again by hand.  Once in place the drawer
// sides hold everything captive.  The boss and its tapers are a mesh
// keep-out, so the joint always sits in solid material.
//
// Everything is a vertical prism: printed upright (walls along Z)
// there is not a single overhang — the groove is a plain vertical
// slot and the tongue a plain vertical plate.  The one thing the
// printer has to bridge is the flat top edge of each square hole,
// which is what mesh_hole spans; keep it inside comfortable bridging
// range (~15 mm) and no supports are needed.  Bed contact is only
// the thin wall edges — use a brim.
//
// Coordinate system:
//   X = width  (left → right),  origin at the drawer's inner left wall
//   Y = depth  (front → back),  origin at the drawer's inner front wall
//   Z = height (up from the bed)
//
// Assembled, the part occupies exactly
// [0, width] × [0, depth] × [0, height] — a press fit against the
// drawer sides.
//
// All units: millimeters.
// ============================================================

/* [Quality] */
$fa = 1;   // Minimum angle — 1° gives max 360 facets per full circle
$fs = 0.4; // Minimum facet edge length (mm) — matched to a 0.4 mm nozzle

/* [Drawer] */
width  = 440;  // Drawer inner width  (X)
depth  = 270;  // Drawer inner depth  (Y)
height = 200;   // Divider wall height (Z)

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

/* [Mesh] */
mesh          = true;  // false prints solid panels
mesh_strut    = 4;     // Width of the struts left between the holes
mesh_hole     = 30;    // Target square hole size — also the bridge span
mesh_hole_min = 6;     // Bays that can only fit a smaller hole stay solid

/* [Alignment joint] */
// -1 puts the split plane exactly half way across the width.  Give an
// explicit X to move it — it must miss the width-dividing walls.
split_x    = -1;    // X of the split plane (mm), or -1 for width/2

joint_len  = 10;    // How far the tongue reaches into the other half
joint_t    = 2.0;   // Tongue thickness (Y)
joint_clr  = 0.25;  // Gap between tongue and groove, per face — slip fit

lead_len   = 1.5;   // Length of the tapered lead-in at the tongue tip
lead_cham  = 0.5;   // How much narrower the very tip is, per side

boss_t     = 6.5;   // Local wall thickness (Y) around the joint
boss_back  = 6;     // Boss reach behind the split plane (left piece)
boss_front = 4;     // Boss material behind the end of the groove
boss_taper = 6;     // Length the boss tapers back down to wall_t

/* [Bed] */
bed_x = 270;  // Printable bed size in X (mm)
bed_y = 270;  // Printable bed size in Y (mm)
gap   = 5;    // Gap between the two halves in the exploded layout

/* [View] */
part = "exploded";  // left | right | both | exploded

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

// Where the model is cut in two.
sx = split_x < 0 ? width / 2 : split_x;

// Piece extents in X.  The left piece carries the protruding tongue,
// so it reaches joint_len past the split plane; the right piece is
// hollowed there, so it starts exactly at the plane.
piece_l_w = sx + joint_len;
piece_r_w = width - sx;

eps = 0.01;
big = (width + depth + height) * 2;   // half-space cutter size

assert(cell_w > 0,
       "width_cells too high (or wall_t too thick) for the given width");
assert(cell_d > 0,
       "depth_cells too high (or wall_t too thick) for the given depth");

// The joint lives on the full-width walls.  With none of them the two
// halves would come apart into unconnected combs.
assert(ny >= 1,
       "depth_cells must be at least 2 — the alignment joint rides on a full-width wall");

// The split plane has to fall in open compartment space, clear of the
// width-dividing walls and with room either side for the boss.
assert(sx - boss_back - boss_taper > 0 && sx + joint_len + boss_front + boss_taper < width,
       "split_x leaves no room for the joint boss inside the drawer");
for (i = [1 : 1 : max(nx, 1)])
    if (nx > 0)
        assert(abs(sx - wall_cx(i)) > wall_t / 2 + boss_taper,
               "split_x lands on (or too near) a width-dividing wall — move it");

// The groove walls are what is left of the boss either side of the
// tongue; keep at least ~1.5 mm, i.e. four extrusions.
assert((boss_t - joint_t - 2 * joint_clr) / 2 >= 1.5,
       "boss_t too thin for joint_t — the groove would have paper-thin walls");
assert(lead_len < joint_len && lead_cham < joint_t / 2,
       "lead-in chamfer does not fit the tongue");

assert(mesh_strut > 0 && mesh_hole > 0,
       "mesh_strut and mesh_hole must be positive");

// ------------------------------------------------------------
// Mesh layout
// ------------------------------------------------------------

// Fit whole holes into a clear run of length L.  Round to the nearest
// count so the actual hole comes out as close to mesh_hole as the bay
// allows; the leftover is absorbed by widening the holes, never the
// struts, so every strut is exactly mesh_strut.
//   L = n * hole + (n + 1) * strut
function bay_n(L) = max(1, round((L - mesh_strut) / (mesh_hole + mesh_strut)));
function bay_hole(L) = (L - (bay_n(L) + 1) * mesh_strut) / bay_n(L);

// The vertical division is common to every panel — same height, so
// the holes line up right across the divider.
nz = bay_n(height);
hz = bay_hole(height);

// A hole is cut a little proud of both faces so the difference leaves
// no coplanar skin.  The bosses are a keep-out, so overshooting the
// wall thickness can never reach them.
cut_t = wall_t + 2;

// Keep-outs.  A crossing is blocked for the wall thickness plus the
// fillet that leans on it; the joint is blocked for the whole boss
// including its tapers.
kb        = wall_t / 2 + fr;
boss_lo   = sx - boss_back - boss_taper;
boss_hi   = sx + joint_len + boss_front + boss_taper;

// Blocked runs along X, in ascending order.  wall_cx() is increasing
// and the asserts above put the boss in open space between two of
// them, so simply splitting the crossings around sx keeps it sorted.
blocked_x = concat(
    [for (i = [1 : 1 : max(nx, 1)]) if (nx > 0 && wall_cx(i) < sx)
        [wall_cx(i) - kb, wall_cx(i) + kb]],
    [[boss_lo, boss_hi]],
    [for (i = [1 : 1 : max(nx, 1)]) if (nx > 0 && wall_cx(i) > sx)
        [wall_cx(i) - kb, wall_cx(i) + kb]]);

// Blocked runs along Y — the crossings only; the joint is not on
// these panels.
blocked_y = [for (j = [1 : 1 : max(ny, 1)]) if (ny > 0)
                [wall_cy(j) - kb, wall_cy(j) + kb]];

// Turn a run [u0, u1] and its blocked intervals into the clear bays
// between them.  Flattening to a list of edges gives
// [u0, b0lo, b0hi, b1lo, ... , u1] — an even-length list whose
// consecutive pairs, taken from index 0, are exactly the clear bays.
function bays(u0, u1, blocked) =
    let (edges = concat([u0], [for (b = blocked) each [b[0], b[1]]], [u1]))
    [for (k = [0 : 2 : len(edges) - 2]) [edges[k], edges[k + 1]]];

bays_x = bays(0, width, blocked_x);
bays_y = bays(0, depth,  blocked_y);

echo(str("Compartments: ", width_cells, " × ", depth_cells,
         " = ", width_cells * depth_cells,
         ", each ", cell_w, " × ", cell_d, " × ", height, " mm"));

echo(str("Split at X = ", sx,
         " — left piece ", piece_l_w, " × ", depth,
         " mm, right piece ", piece_r_w, " × ", depth, " mm"));

echo(str("Alignment tongue: ", joint_t, " × ", joint_len, " × ", height,
         " mm, ", joint_clr, " mm clearance per face, groove walls ",
         (boss_t - joint_t - 2 * joint_clr) / 2, " mm"));

if (mesh) {
    echo(str("Mesh: ", mesh_strut, " mm struts, ", nz,
             " rows of holes ", hz, " mm tall"));
    echo(str("Hole widths per bay — along X: ",
             [for (b = bays_x) let (L = b[1] - b[0])
                 bay_hole(L) >= mesh_hole_min ? bay_hole(L) : "solid"]));
    echo(str("Hole widths per bay — along Y: ",
             [for (b = bays_y) let (L = b[1] - b[0])
                 bay_hole(L) >= mesh_hole_min ? bay_hole(L) : "solid"]));

    max_bridge = max([hz, each [for (b = bays_x) let (L = b[1] - b[0])
                                    bay_hole(L) >= mesh_hole_min ? bay_hole(L) : 0],
                           each [for (b = bays_y) let (L = b[1] - b[0])
                                    bay_hole(L) >= mesh_hole_min ? bay_hole(L) : 0]]);
    echo(max_bridge <= 20
         ? str("Longest bridge over a hole: ", max_bridge, " mm — fine unsupported.")
         : str("WARNING: longest bridge is ", max_bridge,
               " mm — lower mesh_hole or the top of those holes will sag."));
}

// Each half prints on its own; the exploded view puts them side by side.
echo(max(piece_l_w, piece_r_w) <= bed_x && depth <= bed_y
     ? str("Each half fits the ", bed_x, " × ", bed_y, " mm bed.")
     : str("WARNING: a half is ", max(piece_l_w, piece_r_w), " × ", depth,
           " mm and exceeds the ", bed_x, " × ", bed_y,
           " mm bed — raise width_cells or split again."));

echo(piece_l_w + gap + piece_r_w <= bed_x && depth <= bed_y
     ? "Both halves fit the bed together — print in one job."
     : "Note: the two halves do not fit the bed together — print them one at a time.");

// ============================================================
// GEOMETRY — grid
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

// The square holes for one clear bay, in a local frame where the
// panel runs along +X and the cut passes through ±Y.  A bay too short
// for a decent hole is left solid rather than filled with a slot.
module bay_holes(u0, u1) {
    L  = u1 - u0;
    n  = bay_n(L);
    hu = bay_hole(L);

    if (hu >= mesh_hole_min && hz >= mesh_hole_min)
        for (a = [0 : 1 : n - 1], b = [0 : 1 : nz - 1])
            translate([u0 + mesh_strut + a * (hu + mesh_strut),
                       -cut_t / 2,
                       mesh_strut + b * (hz + mesh_strut)])
                cube([hu, cut_t, hz]);
}

// Every hole in the divider.  Panels running along Y are the same
// pattern turned a quarter turn, which also swings the cut direction
// from ±Y round to ∓X — through their thickness.
module mesh_holes() {
    for (j = [1 : 1 : ny])
        translate([0, wall_cy(j), 0])
            for (b = bays_x) bay_holes(b[0], b[1]);

    for (i = [1 : 1 : nx])
        translate([wall_cx(i), 0, 0])
            rotate([0, 0, 90])
                for (b = bays_y) bay_holes(b[0], b[1]);
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
                for (sgx = [-1, 1])
                    for (sgy = [-1, 1])
                        translate([wall_cx(i) + sgx * wall_t / 2,
                                   wall_cy(j) + sgy * wall_t / 2,
                                   0])
                            rotate([0, 0, sgx > 0 ? (sgy > 0 ? 0 : -90)
                                                  : (sgy > 0 ? 90 : 180)])
                                linear_extrude(height = height)
                                    fillet_2d(fr);
}

// ============================================================
// GEOMETRY — alignment joint
// ============================================================

// Plan view of the local thickening around a joint.  X is measured
// from the split plane, Y from the wall centre line; the boss tapers
// back to the plain wall thickness at both ends.
module boss_2d() {
    x0 = -boss_back - boss_taper;
    x1 = -boss_back;
    x2 =  joint_len + boss_front;
    x3 =  joint_len + boss_front + boss_taper;
    polygon([[x0,  wall_t / 2], [x1,  boss_t / 2],
             [x2,  boss_t / 2], [x3,  wall_t / 2],
             [x3, -wall_t / 2], [x2, -boss_t / 2],
             [x1, -boss_t / 2], [x0, -wall_t / 2]]);
}

// Plan view of the tongue: root on the split plane at x = 0, pointing
// into +X.  A plain parallel shank with a short taper at the tip so
// it finds the groove without having to be lined up by eye.
module tongue_2d() {
    polygon([[0,                    joint_t / 2],
             [joint_len - lead_len,  joint_t / 2],
             [joint_len,             joint_t / 2 - lead_cham],
             [joint_len,            -joint_t / 2 + lead_cham],
             [joint_len - lead_len, -joint_t / 2],
             [0,                   -joint_t / 2]]);
}

module tongue() {
    linear_extrude(height = height)
        tongue_2d();
}

// The cavity the tongue drops into: the tongue's own outline grown by
// the clearance.  Cut clean through in Z — printed upright it is just
// a vertical slot.
module groove() {
    translate([0, 0, -eps])
        linear_extrude(height = height + 2 * eps)
            offset(delta = joint_clr)
                tongue_2d();
}

// Place a joint feature on every full-width wall at the split plane.
module at_joints() {
    for (j = [1 : 1 : ny])
        translate([sx, wall_cy(j), 0])
            children();
}

// ============================================================
// GEOMETRY — pieces
// ============================================================

// The complete divider before it is cut in two: the meshed grid, the
// crossing fillets and the thickened bosses that carry the joints.
// Fillets and bosses are added after the holes are cut, so they are
// always solid.
module divider_blank() {
    union() {
        difference() {
            divider_walls();
            if (mesh) mesh_holes();
        }
        junction_fillets();
        at_joints() linear_extrude(height = height) boss_2d();
    }
}

module left_piece() {
    union() {
        intersection() {
            divider_blank();
            translate([-big, -big, -big]) cube([big + sx, 2 * big, 2 * big]);
        }
        at_joints() tongue();
    }
}

module right_piece() {
    difference() {
        intersection() {
            divider_blank();
            translate([sx, -big, -big]) cube([big, 2 * big, 2 * big]);
        }
        at_joints() groove();
    }
}

// ============================================================
// RENDER
// ============================================================

if (part == "left") {

    // Print orientation — walls upright, no supports, add a brim.
    left_piece();

} else if (part == "right") {

    // Same orientation, pulled back to the origin for the bed.
    translate([-sx, 0, 0]) right_piece();

} else if (part == "both") {

    // Assembled, joint engaged — for checking the fit in the drawer.
    left_piece();
    right_piece();

} else {  // "exploded" — both halves flat on the bed, side by side

    total = piece_l_w + gap + piece_r_w;
    x0    = -total / 2;

    translate([x0, -depth / 2, 0])
        left_piece();

    translate([x0 + piece_l_w + gap - sx, -depth / 2, 0])
        right_piece();
}
