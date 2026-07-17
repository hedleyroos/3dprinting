// ============================================================
// Socket Cover — removable wall-socket housing
//
// Hides an ugly wall socket behind a vented, removable box that slides
// over a single rectangular FRAME screwed flat to the wall. The frame
// nests inside the cover's open back and the cover's inner wall faces
// grip the frame's outer faces - a snug fit holds it by friction; pull
// straight off to remove. The cover sits flush to the wall.
//
//   * Front, left and right faces: solid (the solid sides do the gripping).
//   * Top and bottom faces: a diagonal crosshatch lattice (crossing
//     45 deg bars, diamond openings) for cooling. The 45 deg bars are
//     self-supporting when these panels print as vertical walls.
//   * Bottom face also has a cutout for a South African 3-pin plug to
//     pass through, on the LEFT when facing the mounted cover's front
//     (the +X side).
//   * Back: fully open (slides over the frame).
//   * Wall frame: a rectangular ring, outer size = the cover's open-back
//     cavity minus fit_clear per side, screwed to the wall through 4
//     counterbored corner holes; the socket passes through its open centre.
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
wall_t = 3;   // Wall thickness (mm)
edge_round = 1.5; // Slight rounding on the cover's outer edges (mm)

/* [Ventilation - diagonal lattice on top & bottom] */
lattice_bar_t  = 6;  // Diagonal bar width (mm)
lattice_pitch  = 26; // Centre-to-centre spacing of parallel bars (mm)
lattice_border = 6;  // Solid frame around each panel edge (mm)

/* [Plug Cutout - bottom mesh, left-when-facing-front (+X)] */
plug_hole_d       = 60; // Circular opening diameter (mm) - SA 3-pin plug body
plug_rim_w        = 4;  // Solid rim width around the opening (mm)
plug_cut_margin_x = 15; // Inset of the rim from the (+X) edge (mm)

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
rib_w     = 20;  // Inner seam-rib width, X (mm) - glue land + dowel material
rib_h     = 10;  // Inner seam-rib depth into the interior, Y (mm)
mullion_w = 8;   // Solid strip through the lattice at the seam (mm)

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
frame_ow    = box_w - 2 * wall_t - 2 * fit_clear; // frame outer width
frame_oh    = box_h - 2 * wall_t - 2 * fit_clear; // frame outer height
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

// One set of parallel bars at angle `ang`, big enough to cover a w x d
// window when clipped.
module diagonal_bars(ang, w, d) {
    ext = (w + d) * 1.5;
    n = ceil(ext / lattice_pitch);
    rotate(ang)
        for (i = [-n : n])
            translate([i * lattice_pitch, 0])
                square([lattice_bar_t, 2 * ext], center = true);
}

// A solid-framed panel (w x d) filled with a diagonal crosshatch
// lattice: two sets of crossing 45 deg bars leaving diamond openings.
module lattice_2d(w, d) {
    union() {
        difference() {                                    // solid frame
            square([w, d], center = true);
            square([w - 2 * lattice_border, d - 2 * lattice_border], center = true);
        }
        intersection() {                                  // crossing 45 deg bars
            square([w - 2 * lattice_border, d - 2 * lattice_border], center = true);
            union() { diagonal_bars(45, w, d); diagonal_bars(-45, w, d); }
        }
    }
}

module front_wall() {
    translate([-half_w, box_d - wall_t, 0])
        cube([box_w, wall_t, box_h]);
}

// x_side: -1 = left wall, +1 = right wall.
module side_wall(x_side) {
    x0 = x_side > 0 ? half_w - wall_t : -half_w;
    translate([x0, 0, 0])
        cube([wall_t, box_d, box_h]);
}

module top_panel() {
    translate([0, box_d / 2, box_h - wall_t])
        linear_extrude(height = wall_t)
            lattice_2d(box_w, box_d);
}

module bottom_panel() {
    // Plug opening centre on the +X side (left when facing the front); the
    // solid rim's outer edge sits plug_cut_margin_x in from the edge.
    cx = half_w - plug_cut_margin_x - (plug_hole_d / 2 + plug_rim_w);
    translate([0, box_d / 2, 0])
        linear_extrude(height = wall_t)
            difference() {
                union() {
                    lattice_2d(box_w, box_d);
                    translate([cx, 0]) circle(d = plug_hole_d + 2 * plug_rim_w);
                }
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

// Reinforcement along the vertical seam: a rib on the front-wall interior
// (glue land + pin material) plus a solid mullion closing the lattice where
// the seam crosses the top & bottom panels.
module seam_rib() {
    // rib on the inner face of the front wall, full height
    translate([split_x - rib_w / 2, box_d - wall_t - rib_h, 0])
        cube([rib_w, rib_h, box_h]);
    // mullions through the top & bottom lattice panels
    translate([split_x - mullion_w / 2, 0, box_h - wall_t])
        cube([mullion_w, box_d, wall_t]);
    translate([split_x - mullion_w / 2, 0, 0])
        cube([mullion_w, box_d, wall_t]);
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
    py = box_d - wall_t - rib_h / 2;
    for (i = [1 : cover_dowels_n])
        dowel_hole(py, box_h * i / (cover_dowels_n + 1), dowel_w);
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
// origin (spaced in Y): cover_dowels_n cover dowels plus 2 frame dowels. These
// nest inside the frame ring's open centre so they print on the same plate;
// rotate each 45deg to seat it in the diamond holes.
module dowels() {
    ws    = concat([for (i = [1 : cover_dowels_n]) dowel_w], [frame_dowel_w, frame_dowel_w]);
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
