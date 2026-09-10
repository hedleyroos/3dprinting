// ============================================================
// Drawer Divider — meshed inner cross-walls, no border, no floor
// Split into two halves that simply butt against each other
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
// and the top and bottom edges of every panel stay solid.  The bottom
// band is widened to clear the base braces, so a brace always roots
// into solid wall rather than into the side of a hole.
//
// Struts are still the full wall thickness, so the panel keeps its
// stiffness against the load that matters (sideways push) and only
// loses material where nothing was working.
//
// BRACES
// A grid of bare walls has nothing to stop it racking: push the top of
// one wall sideways and the whole frame leans like a parallelogram,
// because the only thing resisting it is the 2.5 mm root of each wall.
// So every inside corner where two walls cross is braced by a flat
// strip lying on the drawer floor, and each one runs the full diagonal
// of its compartment: from the far end of one bounding wall to the far
// end of the other — the outermost point either wall can offer, and so
// the longest member the compartment can hold.
//
// The one column the split plane runs down is braced differently.  A
// diagonal there would be cut in half and leave each piece with a bent
// V, so instead those compartments run their braces into the T-foot.
// Each member starts at the outer end of a Y-wall — where that wall
// meets the drawer wall, the far corner of the compartment — and runs
// diagonally inward to land on the T bumper.  Assembled the pair reads
// as one shallow V with its apex on the bumper; on each printed half
// it is a single straight member from the outer edge in.
//
// That triangulates the frame in plan, and it costs nothing to print:
// it is horizontal material in the first few millimetres of the job,
// and it widens the bed contact from a few thin wall edges to a set of
// long solid strips.
//
// SPLIT
// The full-width wall is too long for the bed, so the divider is cut
// on a vertical plane at split_x (default: half the width) into a
// LEFT and a RIGHT piece.  There is no interlock of any kind — the
// divider is a snug fit between the drawer sides, and that is what
// holds the two halves in line.
//
// All each half needs is somewhere to bump.  So every full-width wall
// ends at the split plane in a small flat T: a low crossbar sitting
// on the drawer floor, much wider than the 2.5 mm wall, so the halves
// meet face to face rather than edge to edge and cannot slip past one
// another.  The crossbar tapers back into the plain wall as it rises,
// so there is no hard ledge, and a pair of floor gussets flares it
// back along the wall — the same brace as every other corner, so the
// cut end of a half is no floppier than the rest of it.  The split is
// a mesh keep-out, so the wall ends in solid material.
//
// Everything is a vertical prism bar the T-feet, which taper inwards
// as they rise: printed upright (walls along Z) there is not a single
// overhang anywhere in the part.  The one thing the
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

/* [Base braces] */
brace      = true;  // false leaves the base of the grid unbraced
brace_w    = 4;     // Width of the diagonal strip
brace_h    = 8;     // How high the strip stands off the drawer floor
brace_ov   = 0.5;   // How far the ends bury into the wall they land on
foot_flare = 18;    // Reach of the gussets that flare the split foot

/* [Split] */
// -1 puts the split plane exactly half way across the width.  Give an
// explicit X to move it — it must miss the width-dividing walls.
split_x = -1;   // X of the split plane (mm), or -1 for width/2

// The butt foot — the flat T at the end of every full-width wall that
// reaches the split plane.  Purely a bumping face; nothing engages.
foot_w  = 24;   // Crossbar width across the wall (Y)
foot_t  = 5;    // Crossbar thickness along the wall (X), per half
foot_h  = 12;   // Crossbar height — tapers back to wall_t at the top

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

// How far either side of the split plane the mesh is kept out, so the
// wall ends in solid material and no hole ever pierces a foot.
split_kb = foot_t + mesh_strut;

// Perpendicular distance from a braced corner to the diagonal spanning
// legs a and b — the widest strip that corner could possibly take.
function standoff(a, b) = a * b / sqrt(a * a + b * b);

// A corner gusset spans a whole compartment, so its legs are simply the
// compartment itself: every arm of a crossing runs one full cell before
// it meets the next crossing or the drawer wall.

// Which compartment column (0-based) the split plane runs down, and
// which side of a crossing an arm reaches into.
split_col = len([for (i = [1 : 1 : max(nx, 1)]) if (nx > 0 && wall_cx(i) < sx) 1]);
function col_of(i, sgx) = sgx > 0 ? i : i - 1;

// Reach from the split plane out to the Y-wall bounding its column —
// the leg of a brace that runs into the T-foot.
foot_lx_neg = sx - (split_col >= 1 ? wall_cx(split_col) + wall_t / 2 : 0);
foot_lx_pos = (split_col + 1 <= nx ? wall_cx(split_col + 1) - wall_t / 2 : width) - sx;
function foot_lx(sgx) = sgx > 0 ? foot_lx_pos : foot_lx_neg;

brace_max_w = standoff(cell_w, cell_d);

// Arms of a crossing that reach into the split column: their gussets
// give way to the braces that run into the T-foot instead.
split_arms = len([for (i = [1 : 1 : max(nx, 1)], sgx = [-1, 1])
                     if (nx > 0 && col_of(i, sgx) == split_col) 1]);

// Piece extents in X.  Nothing crosses the split plane, so each piece
// is exactly its own side of it.
piece_l_w = sx;
piece_r_w = width - sx;

eps = 0.01;
big = (width + depth + height) * 2;   // half-space cutter size

assert(cell_w > 0,
       "width_cells too high (or wall_t too thick) for the given width");
assert(cell_d > 0,
       "depth_cells too high (or wall_t too thick) for the given depth");

// The feet ride on the full-width walls.  With none of them the two
// halves would come apart into unconnected combs.
assert(ny >= 1,
       "depth_cells must be at least 2 — the halves butt on a full-width wall");

assert(foot_w >= wall_t && foot_t > 0 && foot_h > 0 && foot_h <= height,
       "the butt foot must be wider than the wall and fit inside the height");

assert(!brace || (brace_w > 0 && brace_w < brace_max_w
                  && brace_h > 0 && brace_h < height),
       "brace_w must be positive and narrower than the compartment diagonal's stand-off, and brace_h must fit inside the wall height");

// The split plane has to fall in open compartment space, clear of the
// width-dividing walls and with room for the mesh keep-out either side.
assert(sx - split_kb > 0 && sx + split_kb < width,
       "split_x sits too close to a drawer wall for the butt foot");
for (i = [1 : 1 : max(nx, 1)])
    if (nx > 0)
        assert(abs(sx - wall_cx(i)) > wall_t / 2 + fr + split_kb,
               "split_x lands on (or too near) a width-dividing wall — move it");

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

// Height of the solid band at the foot of every panel.  Normally one
// strut; with braces it rises to clear them, so a brace never roots
// into the side of a hole.
mesh_z0 = brace ? max(mesh_strut, brace_h) : mesh_strut;

// The vertical division is common to every panel — same height, so
// the holes line up right across the divider.  The pattern is laid
// out over the run left above that band, counting the band itself as
// the first strut.
mesh_hz = height - mesh_z0 + mesh_strut;
nz = bay_n(mesh_hz);
hz = bay_hole(mesh_hz);

// A hole is cut a little proud of both faces so the difference leaves
// no coplanar skin.  The split is a keep-out, so overshooting the
// wall thickness can never reach a foot.
cut_t = wall_t + 2;

// Keep-outs.  A crossing is blocked for the wall thickness plus the
// fillet that leans on it; the split is blocked for split_kb either
// side of the plane.
kb       = wall_t / 2 + fr;
split_lo = sx - split_kb;
split_hi = sx + split_kb;

// Blocked runs along X, in ascending order.  wall_cx() is increasing
// and the asserts above put the split in open space between two of
// them, so simply splitting the crossings around sx keeps it sorted.
blocked_x = concat(
    [for (i = [1 : 1 : max(nx, 1)]) if (nx > 0 && wall_cx(i) < sx)
        [wall_cx(i) - kb, wall_cx(i) + kb]],
    [[split_lo, split_hi]],
    [for (i = [1 : 1 : max(nx, 1)]) if (nx > 0 && wall_cx(i) > sx)
        [wall_cx(i) - kb, wall_cx(i) + kb]]);

// Blocked runs along Y — the crossings only; the feet are not on
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

echo(brace
     ? str("Base braces: ", brace_w, " mm strips ", brace_h, " mm tall — ",
           (nx * 2 - split_arms) * ny * 2, " on the full ", cell_w, " × ",
           cell_d, " mm compartment diagonal, ", ny * 4,
           " running from an outer wall end in to the T-foot")
     : "Base braces: off");

echo(str("Butt foot at the split: ", foot_w, " mm across × ", foot_t,
         " mm per half × ", foot_h, " mm tall, on ", ny,
         " full-width wall(s)"));

if (mesh) {
    echo(str("Mesh: ", mesh_strut, " mm struts, ", nz,
             " rows of holes ", hz, " mm tall, first row starting ",
             mesh_z0, " mm up"));
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
                       mesh_z0 + b * (hz + mesh_strut)])
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

// One flat diagonal brace, in a local frame whose origin is the inside
// corner of the compartment, with the two bounding walls running away
// along sgx·X and sgy·Y.  Lx and Ly are the far ends of those walls —
// the next crossing, or the drawer wall — so the strip is the whole
// diagonal of the compartment.
//
// The outer edge is the line x/Lx + y/Ly = 1.  The inner edge is that
// same line pulled brace_w closer to the corner, which is just the
// same line with both intercepts scaled by k; taking the intercepts
// rather than shifting the endpoints keeps the two edges exactly
// parallel.  Both edges are then run brace_ov past the wall faces so
// the strip lands in solid material instead of merely touching it.
module brace_2d(Lx, Ly, sgx, sgy) {
    hh  = standoff(Lx, Ly);   // corner to the diagonal
    k   = (hh - brace_w) / hh;
    Lx2 = k * Lx;
    Ly2 = k * Ly;
    polygon([[ sgx * Lx  * (1 + brace_ov / Ly),  -sgy * brace_ov],
             [-sgx * brace_ov,                    sgy * Ly  * (1 + brace_ov / Lx)],
             [-sgx * brace_ov,                    sgy * Ly2 * (1 + brace_ov / Lx2)],
             [ sgx * Lx2 * (1 + brace_ov / Ly2), -sgy * brace_ov]]);
}

// A brace between two given points — used where the member is not a
// chord across a corner but a straight run from one anchor to another.
// The strip is centred on the line and pushed ov past each end, so it
// buries into whatever it lands on rather than merely touching it.
module strip_2d(p, q, w, ov) {
    u = (q - p) / norm(q - p);   // along the member
    n = [-u[1], u[0]];           // across it
    a = p - u * ov;
    b = q + u * ov;
    polygon([a + n * w / 2, b + n * w / 2, b - n * w / 2, a - n * w / 2]);
}

// Every brace in the divider.
//
// A corner gusset in all four inside corners of every wall crossing —
// one at the base of each compartment that meets that crossing, laid
// on its full diagonal.  Every arm of a crossing runs exactly one cell
// before it meets the next crossing or the drawer wall, so both legs
// are simply cell_w and cell_d.
//
// The column the split runs down is the exception.  A diagonal there
// would be cut at its midpoint and leave each half with a V bent
// around a point floating in open floor, so those four gussets are
// dropped and the compartments are braced off the T-foot instead.
//
// Each of those members runs anchor to anchor: from the outer end of
// the Y-wall bounding the column — the far corner of the compartment,
// where that wall meets the drawer wall — diagonally inward to the
// wall centre line at the split plane, which is inside the T-foot.  So
// it is held at the outer edge of a wall at one end and by the bumper
// at the other, which is the whole point of it.  Both anchors are on a
// wall centre line, so each end is properly buried, not tangent.
//
// The ends overshoot the wall by brace_ov, which at the drawer wall
// would poke outside the part, so the whole set is trimmed back to the
// drawer footprint.
module base_braces() {
    if (brace && nx > 0 && ny > 0)
        intersection() {
            union() {
                for (i = [1 : 1 : nx])
                    for (j = [1 : 1 : ny])
                        for (sgx = [-1, 1])
                            for (sgy = [-1, 1])
                                if (col_of(i, sgx) != split_col)
                                    translate([wall_cx(i) + sgx * wall_t / 2,
                                               wall_cy(j) + sgy * wall_t / 2,
                                               0])
                                        linear_extrude(height = brace_h)
                                            brace_2d(cell_w, cell_d, sgx, sgy);

                for (j = [1 : 1 : ny])
                    for (sgx = [-1, 1])
                        for (sgy = [-1, 1])
                            linear_extrude(height = brace_h)
                                strip_2d([sx + sgx * (foot_lx(sgx) + wall_t / 2),
                                          wall_cy(j) + sgy * (wall_t / 2 + cell_d)],
                                         [sx, wall_cy(j)],
                                         brace_w, brace_ov);
            }
            translate([0, 0, -eps])
                cube([width, depth, brace_h + 2 * eps]);
        }
}

// ============================================================
// GEOMETRY — butt foot at the split
// ============================================================

// The flat T at the end of a wall.  Local frame: the split plane is
// x = 0 and the wall centre line is y = 0.  sg is +1 for the piece
// lying in +X and -1 for the one in -X, so the crossbar always stays
// on its own side of the plane and the two feet meet on it.
//
// It is a wedge rather than a block: foot_w wide where it sits on the
// drawer floor, narrowed back to the plain wall by the time it
// reaches foot_h.  Every layer is smaller than the one beneath it, so
// nothing overhangs, and the wall picks the load up gradually instead
// of over a hard step.
module butt_foot(sg) {
    x0 = sg > 0 ? 0 : -foot_t;
    union() {
        hull() {
            translate([x0, -foot_w / 2, 0])
                cube([foot_t, foot_w, eps]);
            translate([x0, -wall_t / 2, foot_h - eps])
                cube([foot_t, wall_t, eps]);
        }

        // The braces at the split.  The crossbar would otherwise stop
        // dead against a 2.5 mm wall; these two floor gussets carry it
        // back into the wall on the diagonal, exactly as a corner
        // brace does, so the cut end of the half is held square.
        if (brace)
            for (sgy = [-1, 1])
                linear_extrude(height = brace_h)
                    polygon([[sg * foot_t,               sgy * wall_t / 2],
                             [sg * foot_t,               sgy * foot_w / 2],
                             [sg * (foot_t + foot_flare), sgy * wall_t / 2]]);
    }
}

// Place a feature at the split plane on every full-width wall.
module at_joints() {
    for (j = [1 : 1 : ny])
        translate([sx, wall_cy(j), 0])
            children();
}

// ============================================================
// GEOMETRY — pieces
// ============================================================

// The complete divider before it is cut in two: the meshed grid, the
// crossing fillets and the base braces.  Both are added after the
// holes are cut, so they are always solid.  The braces live here
// rather than on the pieces, so a brace that falls across the split
// plane is simply cut by it: each half keeps its own anchored portion,
// and the two stubs butt on the plane and carry the diagonal straight
// through the joint once the halves are together.
module divider_blank() {
    union() {
        difference() {
            divider_walls();
            if (mesh) mesh_holes();
        }
        junction_fillets();
        base_braces();
    }
}

module left_piece() {
    union() {
        intersection() {
            divider_blank();
            translate([-big, -big, -big]) cube([big + sx, 2 * big, 2 * big]);
        }
        at_joints() butt_foot(-1);
    }
}

module right_piece() {
    union() {
        intersection() {
            divider_blank();
            translate([sx, -big, -big]) cube([big, 2 * big, 2 * big]);
        }
        at_joints() butt_foot(+1);
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
