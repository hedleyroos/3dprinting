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
box_w  = 400; // Overall width (mm) - wider than tall
box_d  = 80;  // Overall depth / wall stand-off (mm)
box_h  = 300; // Overall height (mm)
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
frame_t     = 10;   // Band (ring wall) width (mm)
frame_depth = 50;   // Frame projection from the wall / slide engagement (mm)
fit_clear   = 0.15; // Clearance per side between frame outer & cover inner (mm)
                    //   - THE FRICTION KNOB: smaller = tighter grip
brim_reach  = 22;   // Corner-brim leg length along each inner edge (mm)
brim_t      = 3;    // Corner-brim thickness on the wall side (mm)

/* [Part Selection] */
part = "exploded"; // cover | frame | both | exploded

// ============================================================
// Derived
// ============================================================
half_w      = box_w / 2;
side_in_x   = half_w - wall_t;               // inner face of each side wall
frame_ow    = box_w - 2 * wall_t - 2 * fit_clear; // frame outer width
frame_oh    = box_h - 2 * wall_t - 2 * fit_clear; // frame outer height
frame_iw    = frame_ow - 2 * frame_t;             // frame inner opening width
frame_ih    = frame_oh - 2 * frame_t;             // frame inner opening height

echo(str("Cover envelope: ", box_w, " x ", box_d, " x ", box_h, " mm (w x d x h)"));
echo(str("Cover is wider than tall: ", box_w > box_h));
echo(str("Frame outer: ", frame_ow, " x ", frame_oh, " mm; opening: ", frame_iw, " x ", frame_ih, " mm"));
echo(str("Friction fit clearance per side: ", fit_clear, " mm"));
if (box_w > 270 || box_h > 270)
    echo("NOTE: cover exceeds a ~270 mm bed - print-splitting deferred to a later iteration.");

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

module cover() {
    intersection() {
        union() {
            front_wall();
            side_wall(-1);
            side_wall(1);
            top_panel();
            bottom_panel();
        }
        rounded_box(edge_round);
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
// RENDER
// ============================================================
if (part == "cover") {
    cover();
} else if (part == "frame") {
    wall_frame();
} else if (part == "both") {
    // Assembled: the frame nests inside the cover's open back, a
    // fit_clear gap to each inner wall; the cover slides on over it.
    cover();
    wall_frame();
} else if (part == "exploded") {
    // Print layout: cover flat on its FRONT FACE (smooth face on the
    // bed for a clean surface texture), open back facing up. Frame laid
    // flat beside it, one open end down. The 400 mm cover is still
    // flagged above and awaits the deferred split for a ~270 bed.
    gap = 15;

    translate([0, 0, box_d]) rotate([-90, 0, 0]) cover();

    // Frame: lay it flat beside the cover, WALL-SIDE (brims) down on the bed.
    translate([half_w + gap + frame_ow / 2, 0, 0])
        rotate([90, 0, 0]) wall_frame();
}
