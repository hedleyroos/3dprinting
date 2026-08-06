// ============================================================
// Wineglass Cage — Dishwasher-safe 6-glass holder
//
// Holds six wineglasses upside down (bowl-down, stem-up) in a
// dishwasher bottom rack.  Each glass sits in its own meshed
// pocket — like a 6-pack beer carrier — so glasses stay separated
// and cannot tip into each other.
//
// The 2×3 grid is too wide for a typical 270 mm bed, so the cage
// splits into two interlocking pieces:
//   • Block A — 2×2 grid (4 glasses)  ~241 × 241 mm
//   • Block B — 2×1 grid (2 glasses)  ~122 × 241 mm
//
// A vertical dovetail joint on the mating walls lets the two
// blocks slide together, forming one rigid 6-glass unit that can
// be separated for storage.
//
// All walls and floors are built from a diagonal lattice (diagrid)
// of thin struts at ±45° — self-supporting when printed upright,
// print upright, so holes can be large for maximum water flow.
// Solid rim bands at top and bottom provide strength and print
// adhesion.
//
// Each cell floor is open lattice — glasses rest directly on the
// rim, keeping it slightly elevated for drainage.
//
// Designed for ABS (temperature-tolerant).  No supports needed.
//
// Coordinate system:
//   X = width  (left → right,  3 columns)
//   Y = depth  (front → back,  2 rows)
//   Z = height (bottom → top,  origin at bed)
//
// All units: millimeters.
// ============================================================

/* [Quality] */
$fa = 1;   // Minimum angle — 1° gives max 360 facets per full circle
$fs = 0.4; // Minimum facet edge length (mm) — matched to a 0.4 mm nozzle

/* [Glass] */
bowl_diameter   = 110;  // Widest diameter of the wineglass bowl (mm)
bowl_clearance  = 3;    // Extra radial clearance per side so glasses drop in easily (mm)
bowl_depth      = 110;  // Depth of the bowl from rim to base (mm) — cage must be >= this

/* [Cage] */
wall_t          = 3;    // Wall and floor thickness (mm)
cage_h          = 115;  // Overall cage height — should be >= bowl_depth + a few mm (mm)

/* [Lattice] */
// The walls and floor are built from thin diagonal struts (a diagrid),
// not from solid panels with holes punched in them.  Material is placed
// only on the load paths, so the open fraction is very high (~70 %+).
//
// Triangulated = the only rigid polygon.  Members carry near-pure
// axial load (little bending) — the most material-efficient way to
// resist vertical squash and brace against buckling.
//
// Diagonals run at ±diag_angle from horizontal; keep ≥ 45° so they
// self-support without supports when printed upright.
strut_w         = 2.4;  // Width each lattice strut prints (≥ 2 perimeters, mm)
cell            = 22;   // Perpendicular spacing between parallel diagonals (mm)
diag_angle      = 45;   // Diagonal angle from horizontal (≥45 = self-supporting)
add_verticals   = true; // Add vertical chords for full triangulation + direct columns
rim_top         = 6;    // Solid band at top of walls — no lattice (mm)
rim_bottom      = 10;   // Solid band at bottom of walls — no lattice (mm)
corner_margin   = 12;   // Solid keep-out from each vertical wall edge (mm)

/* [Dovetail Joint] */
// A vertical sliding dovetail connects Block A (2×2) to Block B
// (2×1).  Tapered trapezoid profile provides positive engagement —
// the blocks cannot pull apart horizontally once engaged.
//
// Dovetails are placed ONLY in the solid rim bands (top and
// bottom) where the wall is hole-free.  The meshed mid-section of
// the mating wall carries no dovetail features.
use_dovetail      = true;  // Include the dovetail joint features
dovetail_w_narrow = 12;    // Width at the narrow (outer) face (mm)
dovetail_w_wide   = 18;    // Width at the wide (inner/root) face (mm)
dovetail_depth    = 4;     // How far the dovetail projects into the mating wall (mm)
dovetail_clearance = 0.3;  // Radial gap for sliding fit (mm)

/* [View] */
part = "both";  // block_2x2 | block_2x1 | both | exploded

// ============================================================
// DERIVED
// ============================================================

// Cell dimensions
cell_id       = bowl_diameter + 2 * bowl_clearance;  // internal cell opening
cell_spacing  = cell_id + wall_t;                     // centre-to-centre

// Block outer dimensions (cols × rows)
function block_w(cols) = cols * cell_id + (cols + 1) * wall_t;
function block_d(rows) = rows * cell_id + (rows + 1) * wall_t;

// Specific block dimensions
bA_cols = 2;  bA_rows = 2;
bB_cols = 1;  bB_rows = 2;
bA_w = block_w(bA_cols);  bA_d = block_d(bA_rows);  // 2×2 block: ~241×241
bB_w = block_w(bB_cols);  bB_d = block_d(bB_rows);  // 2×1 block: ~122×241

// Lattice derived values
node_px  = cell / sin(diag_angle);  // horizontal pitch of diamond nodes
eps      = 0.01;

// Dovetail derived — two dovetails, centred in the solid rim bands
dovetail_taper   = (dovetail_w_wide - dovetail_w_narrow) / 2;
dovetail_bot_h   = rim_bottom - 2;   // height of bottom dovetail (leave 1 mm rim)
dovetail_top_h   = rim_top - 1;      // height of top dovetail (leave 0.5 mm rim)
dovetail_bot_z   = rim_bottom / 2;   // vertical centre of bottom dovetail
dovetail_top_z   = cage_h - rim_top / 2; // vertical centre of top dovetail

// ============================================================
// HELPERS — Lattice (diagrid) wall & floor construction
// ============================================================

// Diagonal strut field: parallel strips at ±diag_angle, spaced
// `cell` apart perpendicularly, optionally crossed by vertical
// chords through the diamond nodes.  Centred on the origin;
// sized to over-cover a w × h panel — the caller clips it with
// an intersection.
module diagrid_field_2d(w, h) {
    L  = sqrt(w * w + h * h) + 2 * cell;     // strip length: covers any panel
    np = ceil(L / cell) + 2;                 // parallel strips per direction

    union() {
        for (ang = [diag_angle, -diag_angle])
            for (i = [-np : np])
                rotate(ang)
                    translate([0, i * cell])
                        square([L, strut_w], center = true);

        if (add_verticals) {
            nv = ceil((w / 2) / node_px) + 1;
            for (i = [-nv : nv])
                translate([i * node_px, 0])
                    square([strut_w, h + 2 * cell], center = true);
        }
    }
}

// Solid perimeter/joint frame inside one wall panel: the diagrid
// unions into these so it is tied to the rims and corners.
module solid_borders_2d(w, h, side_margin) {
    sb = max(side_margin, strut_w);   // side strip width (ties to corners)

    translate([0, -h / 2 + rim_bottom / 2]) square([w, rim_bottom], center = true);
    translate([0,  h / 2 - rim_top / 2])    square([w, rim_top],    center = true);
    translate([-w / 2 + sb / 2, 0])         square([sb, h],         center = true);
    translate([ w / 2 - sb / 2, 0])         square([sb, h],         center = true);
}

// 2D rectangular wall panel — diagrid struts clipped to the panel
// boundary, unioned with solid rim/corner borders.
//   w, h         = panel width and height
//   side_margin  = solid keep-out from the horizontal edges
module wall_profile_2d(w, h, side_margin) {
    intersection() {
        square([w, h], center = true);
        union() {
            diagrid_field_2d(w, h);
            solid_borders_2d(w, h, side_margin);
        }
    }
}

// 2D floor panel — diagrid struts with a solid perimeter border
// that ties into the four walls.
//   w, d   = panel width and depth
//   margin = solid border width from each edge
module floor_profile_2d(w, d, margin) {
    border = max(strut_w, 4);
    intersection() {
        square([w, d], center = true);
        union() {
            diagrid_field_2d(w, d);
            difference() {
                square([w, d], center = true);
                square([w - 2 * border, d - 2 * border], center = true);
            }
        }
    }
}

// Place a meshed wall panel that spans the X axis.
//   w, h   = panel dimensions (width along X, height along Z)
//   xc, yc = centre position in XY
// The wall_profile_2d is extruded along Y (wall thickness direction).
module wall_x(w, h, xc, yc) {
    translate([xc, yc, h / 2])
        rotate([90, 0, 0])
            linear_extrude(height = wall_t, center = true)
                wall_profile_2d(w, h, corner_margin);
}

// Place a meshed wall panel that spans the Y axis.
//   w, h   = panel dimensions (width along Y, height along Z)
//   xc, yc = centre position in XY
// The wall_profile_2d is extruded along X (wall thickness direction).
module wall_y(w, h, xc, yc) {
    translate([xc, yc, h / 2])
        rotate([90, 0, 90])
            linear_extrude(height = wall_t, center = true)
                wall_profile_2d(w, h, corner_margin);
}

// ============================================================
// CAGE BLOCK — generic cols × rows grid
// ============================================================

module cage_block(cols, rows) {
    outer_w = block_w(cols);
    outer_d = block_d(rows);
    half_w  = outer_w / 2;
    half_d  = outer_d / 2;

    // Cell centre X positions (1D array along columns)
    function cell_cx(c) = -half_w + wall_t + cell_id / 2 + c * cell_spacing;

    // Cell centre Y positions (1D array along rows)
    function cell_cy(r) = -half_d + wall_t + cell_id / 2 + r * cell_spacing;

    difference() {
        union() {
            // ---- Outer walls ----
            // Front (+Y)
            wall_x(outer_w, cage_h, 0,  half_d - wall_t / 2);
            // Back  (-Y)
            wall_x(outer_w, cage_h, 0, -half_d + wall_t / 2);
            // Right (+X)
            wall_y(outer_d, cage_h,  half_w - wall_t / 2, 0);
            // Left  (-X)
            wall_y(outer_d, cage_h, -half_w + wall_t / 2, 0);

            // ---- Interior vertical dividers (between columns) ----
            // The divider spans the full internal depth.
            if (cols > 1) {
                inner_d = outer_d - 2 * wall_t;
                for (c = [0 : cols - 2]) {
                    div_x = cell_cx(c) + cell_spacing / 2;
                    wall_y(inner_d, cage_h, div_x, 0);
                }
            }

            // ---- Interior horizontal dividers (between rows) ----
            // The divider spans the full internal width.
            if (rows > 1) {
                inner_w = outer_w - 2 * wall_t;
                for (r = [0 : rows - 2]) {
                    div_y = cell_cy(r) + cell_spacing / 2;
                    wall_x(inner_w, cage_h, 0, div_y);
                }
            }

            // ---- Floor panel (lattice) ----
            translate([0, 0, wall_t / 2])
                linear_extrude(height = wall_t, center = true)
                    floor_profile_2d(outer_w - 2 * wall_t,
                                     outer_d - 2 * wall_t,
                                     0);
        }

        // No pocket cuts — the floor spans the full internal area.
        // The lattice struts provide ample drainage.
    }
}

// ============================================================
// DOVETAIL JOINT — sliding connector between the two blocks
// ============================================================

// Single dovetail tongue (male) — trapezoidal prism that
// protrudes from the mating wall face into the socket.
//   z  = vertical centre of this dovetail
//   hh = half-height of the dovetail (total height = 2*hh)
//
// The dovetail cross-section is a trapezoid in the XY plane
// (top-down view) extruded vertically along Z.  Both tongue
// and socket point in the -X direction (from the mating plane
// toward Block A's interior).
//
//   TOP VIEW (XY plane, looking down):
//
//     Block A (origin)          Block B (+X)
//     |              mating      |
//     |  socket ←    plane →    |  tongue
//     |  [113-119]   X=119     |  [115-119]
//     |                         |
//     Block A interior           Block B interior
//     (X < 119)                 (X > 119)
//
// The tongue BASE (wide, at X=0 local) sits at the wall face.
// The tongue TIP  (narrow, at X=-depth) points into Block A.
// The socket OPENING (wide, at X=0 local) is at the wall face.
// The socket BOTTOM (narrow, at X=-depth) is deeper in.
//
module dovetail_tongue(z, hh) {
    hw_narrow = dovetail_w_narrow / 2;
    hw_wide   = dovetail_w_wide   / 2;

    // Trapezoid in XY: base at X=0 (wide, at wall face),
    //                  tip  at X=-depth (narrow, protruding into mate).
    // Extruded along Z centred at z.
    translate([0, 0, z - hh])
        linear_extrude(height = 2 * hh)
            polygon([
                [ 0,              -hw_wide  ],  // base, -Y
                [ 0,               hw_wide  ],  // base, +Y
                [-dovetail_depth,  hw_narrow],  // tip,  +Y
                [-dovetail_depth, -hw_narrow],  // tip,  -Y
            ]);
}

// Single dovetail socket (female) — trapezoidal void cut into
// the mating wall face.  Slightly oversized for sliding clearance.
//   z  = vertical centre of this dovetail
//   hh = half-height of the dovetail
module dovetail_socket(z, hh) {
    hw_narrow = dovetail_w_narrow / 2 + dovetail_clearance;
    hw_wide   = dovetail_w_wide   / 2 + dovetail_clearance;

    // Trapezoid in XY: opening at X=0 (wide, at wall face),
    //                  bottom at X=-depth (narrow, deeper into wall).
    // Extra +2 mm depth ensures the tongue tip clears.
    socket_depth = dovetail_depth + 2;
    translate([0, 0, z - hh])
        linear_extrude(height = 2 * hh)
            polygon([
                [ 0,              -hw_wide  ],  // opening, -Y
                [ 0,               hw_wide  ],  // opening, +Y
                [-socket_depth,    hw_narrow],  // bottom,  +Y
                [-socket_depth,   -hw_narrow],  // bottom,  -Y
            ]);
}

// ============================================================
// NAMED BLOCKS
// ============================================================

// Block A: 2 columns × 2 rows (4 glasses)
module block_2x2() {
    difference() {
        cage_block(bA_cols, bA_rows);

        // Dovetail sockets on the right (+X) outer wall.
        // The socket polygon's opening edge (X=0) sits at the
        // wall's outer face; the socket cuts inward (+X).
        // Two sockets, centred in the solid rim bands.
        if (use_dovetail) {
            // Right wall outer face X position
            socket_x = bA_w / 2 - wall_t / 2;
            translate([socket_x, 0, 0]) {
                dovetail_socket(dovetail_bot_z, dovetail_bot_h / 2);
                dovetail_socket(dovetail_top_z, dovetail_top_h / 2);
            }
        }
    }
}

// Block B: 1 column × 2 rows (2 glasses)
module block_2x1() {
    union() {
        cage_block(bB_cols, bB_rows);

        // Dovetail tongues on the left (-X) outer wall.
        // The tongue polygon's base edge (X=0) sits at the
        // wall's outer face; the tongue protrudes outward (-X).
        // Two tongues, centred in the solid rim bands.
        if (use_dovetail) {
            // Left wall outer face X position
            tongue_x = -bB_w / 2 + wall_t / 2;
            translate([tongue_x, 0, 0]) {
                dovetail_tongue(dovetail_bot_z, dovetail_bot_h / 2);
                dovetail_tongue(dovetail_top_z, dovetail_top_h / 2);
            }
        }
    }
}

// ============================================================
// RENDER
// ============================================================

if (part == "block_2x2") {

    block_2x2();

} else if (part == "block_2x1") {

    block_2x1();

} else if (part == "exploded") {

    // Both blocks laid flat on the print bed, arranged within a
    // 270×270 mm rectangle.
    //
    // Block A (2×2, ~241×241 mm) sits at the origin, floor down.
    // Block B (2×1, ~122×241 mm) sits to the right, floor down.
    // Total footprint ~363×241 mm — exceeds 270 mm in X, so the
    // pieces must be printed separately.  This view is for layout
    // reference only.
    //
    // Print workflow:
    //   1. Set part="block_2x2" → export → print
    //   2. Set part="block_2x1" → export → print

    gap = 10;

    // Block A centred at origin
    block_2x2();

    // Block B to the right
    translate([bA_w / 2 + gap + bB_w / 2, 0, 0])
        block_2x1();

    // Visual bed-boundary marker (270×270)
    %translate([0, 0, -0.5])
        cube([270, 270, 1], center = true);

} else {  // "both" — assembled view for fit checking

    // Block A at origin
    block_2x2();

    // Block B translated so its left wall mates with Block A's
    // right wall (dovetail engaged)
    translate([bA_w / 2 + bB_w / 2 - wall_t, 0, 0])
        block_2x1();

}
