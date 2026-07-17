// ============================================================
// Socket Cover (Solid-Wall Variant) — removable wall-socket housing
//
// Hides an ugly wall socket behind a solid-walled, removable box that
// slides over a single rectangular FRAME screwed flat to the wall. The
// frame nests inside the cover's open back and the cover's inner wall
// faces grip the frame's outer faces - a snug fit holds it by friction;
// pull straight off to remove. The cover sits flush to the wall.
//
//   * Faces: the FRONT (big panel) is thin (front_t, ~2 mm), carried by an
//     internal rib grid; LEFT, RIGHT, TOP, BOTTOM are thicker (wall_t,
//     ~3.5 mm) — stiff on their own and thick enough to grip the frame
//     directly (no back rib needed).
//   * Internal ribbing (all self-supporting when printed face-down):
//     a grid on the thin front wall — vertical ribs (centre rectangular
//     for glue/dowels, remainder triangular, plus one at each front↔side
//     junction) crossed by horizontal triangular cross-ribs. The thick
//     side/top/bottom panels carry no extra ribs.
//   * Seam join: a U-shaped reinforcing bar wraps the seam across the
//     three panels it crosses (front + top + bottom), glued and self-
//     registered by square dowels in diamond holes (down the front seam,
//     plus one in each short-edge bar).
//   * Top face: a dense, self-supporting honeycomb ventilation field on
//     the left (+X) side.
//   * Bottom face has a cutout for a South African 3-pin plug to
//     pass through, on the LEFT when facing the mounted cover's front
//     (the +X side).
//   * Back: fully open (slides over the frame).
//   * Wall frame: a rectangular ring, outer size = the cover's open-back
//     cavity minus fit_clear per side, screwed to the wall through 4
//     counterbored corner holes; the socket passes through its open centre.
//
// This is the SOLID-WALL variant — compare with socket_cover.scad (lattice
// top/bottom) for print time vs filament usage.
//
// Printed face-down (front face on the bed) with no supports.
//
// SPLIT: the cover (400 wide) exceeds a 270 mm bed in width, so both the
// cover and the frame are split down a single vertical seam (X = split_x)
// into a LEFT and a RIGHT half. Halves butt-join with glue, self-registered
// by separate square dowels seated in diamond (45deg-rotated square) holes.
// The holes run horizontally across the seam and their diamond section keeps
// a diagonal vertical in the print orientation, so they print with no
// supports; the dowels are printed flat & separately and are rotated 45deg to
// mate the holes. The front seam is a recessed reveal line. box_h = 265 keeps
// the height within the bed (no height split).
//
// The cover is wider (box_w) than it is tall (box_h).
//
// Coordinate system (mm, origin at the centre of the open back):
//   X = width      (-box_w/2 .. +box_w/2)
//   Y = depth      (0 = wall / open back .. +box_d = front face)
//   Z = height     (0 = floor .. +box_h = top)
// Viewer facing the front looks toward -Y, so their LEFT is +X.
// ============================================================

/* [Quality] */
$fa = 1;   // Minimum angle - 1 deg gives max 360 facets per full circle
$fs = 0.4; // Minimum facet edge length (mm) - matched to a 0.4 mm nozzle

/* [Cover Envelope] */
box_w  = 350; // Overall width (mm) - wider than tall
box_d  = 80;  // Overall depth / wall stand-off (mm)
box_h  = 265; // Overall height (mm) - within a 270 mm bed (no height split)
wall_t  = 3.5;  // Side/top/bottom panel thickness (mm) — stiff; grips the frame
front_t = 2.0;  // Front (big) panel thickness (mm) — thin; carried by the rib grid
edge_round = 1.5; // Slight rounding on the cover's outer edges (mm)

/* [Plug Cutout - bottom solid panel, left-when-facing-front (+X)] */
plug_hole_d       = 60; // Circular opening diameter (mm) - SA 3-pin plug body
plug_rim_w        = 4;  // Solid rim width around the opening (mm)
plug_cut_margin_x = 15; // Inset of the rim from the (+X) edge (mm)

/* [Ventilation - honeycomb field on top panel, left (+X) side] */
vent_cell_flat  = 14;  // Hexagon flat-to-flat size of each open cell (mm)
vent_wall       = 1.5; // Wall thickness between adjacent cells (mm)
vent_margin_x   = 18;  // Margin from the +X (left) edge to the vent region (mm)
vent_margin_y   = 12;  // Margin from the front/back edges to the vent region (mm)
vent_seam_clear = 15;  // Clearance from the seam (X=split) to the vent region (mm)
                       //   - keep > rib_w/2 so the field clears the top join bar

/* [Wall Frame - slides inside the cover's open back] */
frame_t     = 8;   // Band (ring wall) width (mm)
frame_depth = 20;   // Frame projection from the wall / slide engagement (mm)
fit_clear   = 0.15; // Clearance per side between frame outer & cover inner (mm)
                    //   - THE FRICTION KNOB: smaller = tighter grip
brim_reach  = 32;   // Corner-brim leg length along each inner edge (mm)
brim_t      = 5;    // Corner-brim thickness on the wall side (mm)

/* [Split & Joints - halve for a 270 mm bed] */
split_x   = 0;   // Vertical seam position, X (mm)
reveal_w  = 3;   // Front reveal-groove width (mm)
reveal_d  = 1.5; // Front reveal-groove depth (mm)
rib_w     = 20;  // U-join bar width, X (mm) — centre/short-edge bars at the seam
rib_h     = 10;  // U-join bar depth into the interior, Y/Z (mm)
front_ribs_n = 5; // Number of vertical ribs on the front-wall interior (odd, centre at seam)
front_cross_n = 2; // Number of horizontal cross-ribs on the front wall (grid)
stiff_rib_w = 6;  // Width of non-joint stiffening ribs (mm)
stiff_rib_h = 8;  // Depth of non-joint stiffening ribs into interior (mm)

/* [Dowels - square dowels in 45deg diamond holes] */
dowel_w        = 5;    // Cover dowel square cross-section (mm)
frame_dowel_w  = 4;    // Frame dowel square (mm) - smaller; 8 mm bands are thin
dowel_embed    = 6;    // Dowel engagement depth into EACH half (mm)
dowel_clear    = 0.2;  // Clearance per side between dowel & hole (mm)
dowel_chamfer  = 0.8;  // Lead-in chamfer at each dowel end (mm)
cover_dowels_n = 3;    // Dowels down the cover front-wall seam

/* [Part Selection] */
part = "exploded"; // exploded | assembled | cover | frame | cover_L | cover_R | frame_L | frame_R
                   //   frame_L also carries all the dowels nested in its open centre.

// ============================================================
// Derived
// ============================================================
half_w      = box_w / 2;
side_in_x   = half_w - wall_t;               // inner face of each side wall
fit_wall    = wall_t;                         // side/top/bottom walls grip the frame directly
frame_ow    = box_w - 2 * fit_wall - 2 * fit_clear; // frame outer width
frame_oh    = box_h - 2 * fit_wall - 2 * fit_clear; // frame outer height
frame_iw    = frame_ow - 2 * frame_t;             // frame inner opening width
frame_ih    = frame_oh - 2 * frame_t;             // frame inner opening height
dowel_len   = 2 * dowel_embed;                    // physical dowel length (spans the seam)

// Printed footprint of one half (face-/wall-down): width x height.
cover_half_w = half_w;               // ~200 mm
frame_half_w = frame_ow / 2;         // ~197 mm

echo(str("Cover envelope: ", box_w, " x ", box_d, " x ", box_h, " mm (w x d x h)"));
echo(str("Cover is wider than tall: ", box_w > box_h));
echo(str("Frame outer: ", frame_ow, " x ", frame_oh, " mm; opening: ", frame_iw, " x ", frame_ih, " mm"));
echo(str("Friction fit clearance per side: ", fit_clear, " mm"));
echo(str("Cover half print footprint: ", cover_half_w, " x ", box_h, " mm"));
echo(str("Frame half print footprint: ", frame_half_w, " x ", frame_oh, " mm"));
if (cover_half_w > 270 || box_h > 270 || frame_half_w > 270 || frame_oh > 270)
    echo("WARNING: a split half still exceeds a ~270 mm bed!");

// ============================================================
// MODULES - all geometry is defined locally (standalone file)
// ============================================================

module front_wall() {
    translate([-half_w, box_d - front_t, 0])
        cube([box_w, front_t, box_h]);
}

// x_side: -1 = left wall, +1 = right wall.
module side_wall(x_side) {
    x0 = x_side > 0 ? half_w - wall_t : -half_w;
    translate([x0, 0, 0])
        cube([wall_t, box_d, box_h]);
}

// Dense honeycomb ventilation field, clipped to a rectangular region on the
// +X (left-when-facing) side of the top panel and clear of the seam bar.
// Cells are POINTY-TOP in the print orientation (a vertex points along +/-Y,
// which maps to vertical when printed face-down), so each hole has a self-
// supporting apex and the cell walls sit ~60° from horizontal — no supports.
// Local 2D coords here: X = model X, Y = model Y - box_d/2 (square is centred).
module honeycomb_2d() {
    size = (vent_cell_flat + vent_wall) / sqrt(3); // lattice pitch circumradius
    R    = vent_cell_flat / sqrt(3);               // open-cell circumradius (flat-to-flat = vent_cell_flat)
    dx   = vent_cell_flat + vent_wall;             // column pitch (X)
    dy   = 1.5 * size;                             // staggered row pitch (Y)
    rx0  = vent_seam_clear;                         // region: inner (seam) edge
    rx1  = half_w - vent_margin_x;                  //         outer (+X) edge
    ry0  = -box_d / 2 + vent_margin_y;              //         back edge
    ry1  =  box_d / 2 - vent_margin_y;              //         front edge
    cx   = (rx0 + rx1) / 2;
    cy   = (ry0 + ry1) / 2;
    nx   = ceil((rx1 - rx0) / dx / 2) + 1;
    ny   = ceil((ry1 - ry0) / dy / 2) + 1;
    intersection() {
        translate([cx, cy]) square([rx1 - rx0, ry1 - ry0], center = true);
        union()
            for (ix = [-nx : nx], iy = [-ny : ny])
                translate([cx + ix * dx + (iy % 2 != 0 ? dx / 2 : 0),
                           cy + iy * dy])
                    rotate(90)                 // vertex on +/-Y → pointy-top in print
                        circle(r = R, $fn = 6);
    }
}

module top_panel() {
    translate([0, box_d / 2, box_h - wall_t])
        linear_extrude(height = wall_t)
            difference() {
                square([box_w, box_d], center = true);
                honeycomb_2d();
            }
}

module bottom_panel() {
    // Plug opening centre on the +X side (left when facing the front).
    cx = half_w - plug_cut_margin_x - (plug_hole_d / 2 + plug_rim_w);
    translate([0, box_d / 2, 0])
        linear_extrude(height = wall_t)
            difference() {
                square([box_w, box_d], center = true);
                translate([cx, 0]) circle(d = plug_hole_d);
            }
}

// A box the size of the cover envelope with all edges/corners rounded to
// radius r (hull of 8 inset corner spheres). Intersecting the cover with
// it rounds the outer edges while leaving flat faces and the inner cavity.
module rounded_box(r) {
    hull()
        for (ix = [-1, 1], iy = [0, 1], iz = [0, 1])
            translate([ix * (half_w - r),
                       iy ? box_d - r : r,
                       iz ? box_h - r : r])
                sphere(r);
}

// Raw cover shell (un-rounded). Rounding is applied in cover() so it also
// clips the seam reinforcement, not just the walls.
module cover_body() {
    union() {
        front_wall();
        side_wall(-1);
        side_wall(1);
        top_panel();
        bottom_panel();
    }
}

// ============================================================
// INTERNAL RIBS — all self-supporting (triangular where possible)
// ============================================================

// Triangular vertical rib on the front-wall interior.
// Printed face-down the apex points up — fully self-supporting.
module front_tri_rib(x, w, h) {
    linear_extrude(height = box_h)
        polygon([
            [x - w/2, box_d - front_t],
            [x + w/2, box_d - front_t],
            [x,       box_d - front_t - h]
        ]);
}

// Horizontal triangular cross-rib on the front-wall interior at height z.
// Runs the full interior width; sloped faces self-supporting.
module front_cross_rib(z, w, h) {
    x0 = -(half_w - wall_t);
    x1 =  (half_w - wall_t);
    polyhedron(
        points = [
            [x0, box_d - front_t,     z - w/2],  // 0: base left-bottom
            [x1, box_d - front_t,     z - w/2],  // 1: base right-bottom
            [x1, box_d - front_t,     z + w/2],  // 2: base right-top
            [x0, box_d - front_t,     z + w/2],  // 3: base left-top
            [x0, box_d - front_t - h, z      ],  // 4: apex left
            [x1, box_d - front_t - h, z      ],  // 5: apex right
        ],
        faces = [
            [0, 1, 2, 3],  // base against wall
            [0, 4, 5, 1],  // bottom sloped face
            [1, 5, 2],     // right triangular end
            [2, 5, 4, 3],  // top sloped face
            [3, 4, 0],     // left triangular end
        ]
    );
}

// Internal rib system:
//   * a GRID on the thin front wall — vertical ribs (centre rectangular for
//     the glue joint, remainder triangular) crossed by horizontal triangular
//     cross-ribs, plus a vertical rib at each front↔side-wall junction;
//   * a U-shaped join bar wrapping the seam across the three panels it crosses
//     (front centre rib + top & bottom bars).
// The thick (wall_t) side/top/bottom panels carry no extra ribs. Everything is
// self-supporting when printed front-face-down (ribs running in Y stand up as
// columns on the bed; triangular front ribs point "up").
module seam_rib() {
    // --- front-wall vertical ribs (skip edge ribs — junction ribs added below) ---
    x_start  = -(half_w - wall_t) + rib_w / 2;
    x_end    =  (half_w - wall_t) - rib_w / 2;
    spacing  = (x_end - x_start) / (front_ribs_n - 1);
    centre_i = (front_ribs_n - 1) / 2;
    for (i = [1 : front_ribs_n - 2]) {  // skip first and last (edge) ribs
        x = x_start + i * spacing;
        if (i == centre_i) {
            // rectangular centre rib — front leg of the U-join (glue + dowels)
            translate([x - rib_w/2, box_d - front_t - rib_h, 0])
                cube([rib_w, rib_h, box_h]);
        } else {
            // triangular stiffening rib
            front_tri_rib(x, stiff_rib_w, stiff_rib_h);
        }
    }
    // --- front-wall horizontal cross-ribs (grid across the large span) ---
    for (j = [1 : front_cross_n])
        front_cross_rib(box_h * j / (front_cross_n + 1), stiff_rib_w, stiff_rib_h);
    // --- vertical ribs at the front↔side junctions ---
    // One right against each side wall, half-buried in it, so every half shows
    // a "half rib" supporting the seam where the front panel meets the side
    // wall. Runs full height; self-supporting (apex into interior).
    front_tri_rib(-(half_w - wall_t), stiff_rib_w, stiff_rib_h);  // left side
    front_tri_rib( (half_w - wall_t), stiff_rib_w, stiff_rib_h);  // right side
    // --- U-join short-edge bars on the top & bottom panels ---
    // Run from just past the frame engagement zone up to the front wall (tying
    // into the front centre bar), protruding rib_h into the interior. Starting
    // at frame_depth + clearance keeps them clear of the nested frame ring's
    // top/bottom bands. In the front-face-down print they stand as self-
    // supporting columns.
    yb0 = frame_depth + 3;               // clear the frame's top/bottom bands
    translate([split_x - rib_w / 2, yb0, box_h - wall_t - rib_h])
        cube([rib_w, box_d - yb0, rib_h]);           // top bar
    translate([split_x - rib_w / 2, yb0, wall_t])
        cube([rib_w, box_d - yb0, rib_h]);           // bottom bar
}

// A V-groove down the front outer face at the seam - the reveal line.
module seam_reveal() {
    translate([0, 0, -1])
        linear_extrude(height = box_h + 2)
            polygon([
                [split_x - reveal_w / 2, box_d + 1],
                [split_x + reveal_w / 2, box_d + 1],
                [split_x,               box_d - reveal_d],
            ]);
}

module cover() {
    difference() {
        intersection() {
            union() {
                cover_body();
                seam_rib();
            }
            rounded_box(edge_round);   // round the whole cover, join included
        }
        seam_reveal();
    }
}

// A triangular brim in an inner corner of the frame (sxs/szs = ±1 pick
// the corner). It lies on the wall side (Y in [0, brim_t]) and fills the
// corner of the opening, giving double-sided tape more area and stiffening
// the ring. Printed wall-side down it lands flat on the bed - no support.
module corner_brim(sxs, szs) {
    xc = sxs * frame_iw / 2;
    zc = box_h / 2 + szs * frame_ih / 2;
    ov = 1;  // small overlap into the band for a solid weld
    rotate([-90, 0, 0])              // extrude(+Z) -> +Y (wall side)
        linear_extrude(height = brim_t)
            polygon([
                [xc + sxs * ov,           -(zc + szs * ov)],
                [xc - sxs * brim_reach,   -(zc + szs * ov)],
                [xc + sxs * ov,           -(zc - szs * brim_reach)],
            ]);
}

// The wall frame: a rectangular ring that nests inside the cover's open
// back with a fit_clear gap. Fixed to the wall with double-sided tape (no
// screws); the cover slides over it. Spans Y = [0, frame_depth] (0 =
// wall), centred in X and about box_h/2 in Z so its outer faces line up
// with the cover cavity. Corner brims sit on the wall side.
module wall_frame() {
    z0 = box_h / 2;
    union() {
        // rectangular ring
        difference() {
            translate([-frame_ow / 2, 0, z0 - frame_oh / 2])
                cube([frame_ow, frame_depth, frame_oh]);
            translate([-frame_iw / 2, -1, z0 - frame_ih / 2])
                cube([frame_iw, frame_depth + 2, frame_ih]);
        }
        // corner brims (wall side)
        for (sxs = [-1, 1], szs = [-1, 1])
            corner_brim(sxs, szs);
    }
}

// ============================================================
// SPLIT INTO HALVES (glue + alignment pins)
// ============================================================

// A big half-space cutter: side +1 keeps X > split_x, -1 keeps X < split_x.
module half_box(side) {
    big = box_w + box_h + 100;
    x0 = (side > 0) ? split_x : split_x - big;
    translate([x0, -big / 2, -big / 2]) cube([big, big, big]);
}

// Diamond hole for a square dowel, axis along X, centred on the seam at
// (py, pz). w = dowel square side; rotate 45deg about X so a diagonal is
// vertical in the print orientation -> self-supporting apex, no supports.
// The cutter is centred on the seam so it carves BOTH halves identically.
module dowel_hole(py, pz, w) {
    s   = w + 2 * dowel_clear;   // hole square side (dowel + clearance per side)
    len = dowel_len + 2;         // ~1 mm slack each end so the halves butt fully
    translate([split_x, py, pz])
        rotate([45, 0, 0])
            cube([len, s, s], center = true);
}

// Cover seam dowel holes live in the front-wall rib, spaced down the height.
module cover_seam_holes() {
    fy = box_d - front_t - rib_h / 2;   // depth of the front centre bar
    ty = box_d / 2;                      // depth of the top/bottom short-edge bars
    // front seam dowels down the height
    for (i = [1 : cover_dowels_n])
        dowel_hole(fy, box_h * i / (cover_dowels_n + 1), dowel_w);
    // short-edge dowels in the top & bottom U-bars
    dowel_hole(ty, box_h - wall_t - rib_h / 2, dowel_w);  // top
    dowel_hole(ty, wall_t + rib_h / 2, dowel_w);          // bottom
}

// Frame seam dowel holes live in the top & bottom bands.
module frame_seam_holes() {
    py = frame_depth / 2;
    z0 = box_h / 2;
    dowel_hole(py, z0 + frame_oh / 2 - frame_t / 2, frame_dowel_w);
    dowel_hole(py, z0 - frame_oh / 2 + frame_t / 2, frame_dowel_w);
}

// A square dowel lying flat on the bed (one face down), axis along X, with a
// small pyramid chamfer at each end as an insertion lead-in. Printed
// separately; rotate it 45deg to seat in the diamond holes.
module dowel(w) {
    ch = dowel_chamfer;
    translate([0, 0, w / 2])
        hull() {
            cube([dowel_len - 2 * ch, w, w], center = true);
            for (e = [-1, 1])                    // chamfered (pyramid) tips
                translate([e * dowel_len / 2, 0, 0])
                    cube([0.01, w - 2 * ch, w - 2 * ch], center = true);
        }
}

// One cover half (side: -1 = L / +1 = R). Both halves get identical diamond
// dowel holes; a separate dowel bridges them and self-registers the join.
module cover_half(side) {
    difference() {
        intersection() { cover(); half_box(side); }
        cover_seam_holes();
    }
}

// One frame half, same dowel-hole convention.
module frame_half(side) {
    difference() {
        intersection() { wall_frame(); half_box(side); }
        frame_seam_holes();
    }
}

// Print orientations: cover half front-face-down, frame half wall-side-down.
module print_cover_half(side) {
    translate([0, 0, box_d]) rotate([-90, 0, 0]) cover_half(side);
}
module print_frame_half(side) {
    rotate([90, 0, 0]) frame_half(side);
}

// Every dowel needed for one full assembly, laid flat in a row centred on the
// origin (spaced in Y): cover_dowels_n front dowels + 2 short-edge (top/bottom)
// dowels + 2 frame dowels. These nest inside the frame ring's open centre so
// they print on the same plate; rotate each 45deg to seat it in the diamond holes.
module dowels() {
    ws    = concat([for (i = [1 : cover_dowels_n]) dowel_w],  // front seam
                   [dowel_w, dowel_w],                        // top & bottom short-edge
                   [frame_dowel_w, frame_dowel_w]);           // frame
    gap   = 8;
    pitch = dowel_w + gap;
    y0    = -(len(ws) - 1) * pitch / 2;   // centre the row on Y = 0
    for (i = [0 : len(ws) - 1])
        translate([0, y0 + i * pitch, 0]) dowel(ws[i]);
}

// One frame half plus every dowel nested flat in the ring's open centre, so the
// whole set prints together on one plate at no extra bed footprint.
module print_frame_half_with_dowels(side) {
    print_frame_half(side);
    translate([-frame_iw / 4, -box_h / 2, 0]) dowels();
}

// ============================================================
// RENDER
// ============================================================
if (part == "assembled") {
    // Full assembly preview: frame nested in the cover, reveal line on front.
    cover();
    wall_frame();
} else if (part == "cover") {
    cover();
} else if (part == "frame") {
    wall_frame();
} else if (part == "cover_L") {
    print_cover_half(-1);
} else if (part == "cover_R") {
    print_cover_half(1);
} else if (part == "frame_L") {
    print_frame_half_with_dowels(-1);
} else if (part == "frame_R") {
    print_frame_half(1);
} else if (part == "exploded") {
    // Print layout: the separate pieces, each flat on the bed in its print
    // orientation with a clear gap between them so it is obvious they print
    // individually (each half fits a 270 mm bed). Cover halves are front-face-
    // down; frame halves are brim-side-down; the dowels nest inside the LEFT
    // frame half's open centre and print on that same plate.
    gap = 50;

    // cover halves (top row), pulled apart at the seam
    translate([-gap / 2, 0, 0]) print_cover_half(-1);
    translate([ gap / 2, 0, 0]) print_cover_half(1);

    // frame halves (below the cover), also pulled apart; dowels ride in the
    // left half's open centre
    translate([0, -gap, 0]) {
        translate([-gap / 2, 0, 0]) print_frame_half_with_dowels(-1);
        translate([ gap / 2, 0, 0]) print_frame_half(1);
    }
}
