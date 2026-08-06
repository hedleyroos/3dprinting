// ============================================================
// Wineglass Cage — Dishwasher-safe 4-glass holder
//
// Holds four wineglasses upside down (bowl-down, stem-up) in a
// dishwasher bottom rack.  Each glass sits in its own lattice
// pocket — like a beer carrier — so glasses stay separated and
// cannot tip into each other.
//
// Single-piece 2×2 grid (~241 × 241 × 115 mm) fits a 270 mm bed.
//
// All walls and floors are built from a diagonal lattice (diagrid)
// of thin struts at ±45° — self-supporting when printed upright,
// no supports needed.  Solid rim bands at top and bottom provide
// strength and print adhesion.
//
// Designed for ABS (temperature-tolerant).
//
// Coordinate system:
//   X = width  (left → right,  2 columns)
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

/* [View] */
part = "both";  // print | both

// ============================================================
// DERIVED
// ============================================================

// Cell dimensions
cell_id       = bowl_diameter + 2 * bowl_clearance;  // internal cell opening
cell_spacing  = cell_id + wall_t;                     // centre-to-centre

// Block outer dimensions (cols × rows)
function block_w(cols) = cols * cell_id + (cols + 1) * wall_t;
function block_d(rows) = rows * cell_id + (rows + 1) * wall_t;

// Single 2×2 block
cage_cols = 2;
cage_rows = 2;
cage_w = block_w(cage_cols);  // ~241 mm
cage_d = block_d(cage_rows);  // ~241 mm

// Lattice derived values
node_px  = cell / sin(diag_angle);  // horizontal pitch of diamond nodes
eps      = 0.01;

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
// RENDER
// ============================================================

if (part == "print") {

    // Single 2×2 cage in print orientation (floor down).
    cage_block(cage_cols, cage_rows);

} else {  // "both" — assembled view for fit checking

    cage_block(cage_cols, cage_rows);

}
