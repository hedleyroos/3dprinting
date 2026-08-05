// ============================================================
// ginos.scad
//
// Gino's — the classic Italian "mano a borsa" pinched-fingers
// hand gesture (from italian.stl) standing on a rectangular
// pedestal.
//
// TWO PARTS, glued together by a TRACK-AND-GROOVE joint:
//
//   Hand — italian.stl with its wrist wall continued straight
//     down into a track. The forearm is a hollow shell, so its
//     wrist cut is already a ring; the track is that exact ring
//     extruded downward. The hand's underside stays OPEN.
//
//   Pedestal — a rectangular slab with a small chamfer on its
//     edges, a matching groove in its top face (the same ring,
//     widened by `joint_clearance` on both faces), and two lines
//     of text engraved into the clear plate in front of the hand.
//     Printed UPSIDE DOWN (top face on the bed) so the show face
//     gets the glassy bed finish and the chamfer self-supports.
//
// The track drops into the groove with 0.1 mm either side and
// registers the hand in exactly one position — no alignment jig.
// Because the joint is a ring rather than a solid plug, BOTH
// faces of the wall are glued: ~155 mm of joint line instead of
// 93 mm, so the glue area goes UP even though material goes down.
//
// Units: millimetres.
//
// Coordinate system (assembled):
//   - Z = 0 is the hand's flat wrist cut — the pedestal's top face.
//   - X/Y origin is the centre of that wrist footprint.
//   - The hand occupies Z = 0 .. +90, the pedestal Z = -H .. 0.
//   - `hand_offset` places the hand on the plate. It is measured
//     from the plate's centre to the hand's overall XY BOUNDING BOX
//     centre, not to the wrist — the hand leans, so aligning the
//     wrist would look off-centre and sit tippy. [0,0] therefore
//     means "looks centred", and the wrist lands slightly to one
//     side of the plate's middle, which is correct.
//
// Part mapping (project convention names):
//   part="bottom"   -> pedestal, print orientation (upside down)
//   part="top"      -> hand + tenon, print orientation (wrist down)
//   part="text"     -> the text plug alone, in the pedestal's print
//                      orientation, for a two-filament top face
//   part="printplate" -> the whole job on the bed as SEPARATE
//                      objects: pedestal, text plug, hand. REQUIRES
//                      --enable=lazy-union (see the render section)
//   part="both"     -> assembled, for fit checking
//   part="exploded" -> the same bed layout, unioned, for previewing
//
// The text is OPTIONAL as a separate colour. Print "bottom" on its
// own and you get an engraved plate in one filament. The plug is
// generated from the same glyph module as the pocket and goes
// through the same print-orientation transform, so wherever the two
// meet they are aligned by construction. Never recentre either one.
//
// Note the difference between an OBJECT and a PART, because the two
// are not interchangeable here:
//   - the plug must be a PART of the pedestal, so the slicer can
//     give it its own filament and handle the shared wall properly;
//   - the hand must be its own OBJECT, so it can carry its own
//     ironing, speed and support settings.
// A plain lazy-union export makes everything an object, which is why
// make_multipart_3mf.py exists — it fuses chosen objects into parts
// and leaves the rest alone.
//
// Printing notes:
//   - Neither part needs supports.
//   - The groove is why. A solid pocket would force the pedestal's
//     roof to bridge the whole wrist silhouette, ~25 x 33 mm. As a
//     ring it only has to bridge the WALL WIDTH: 1.8 mm at the
//     thinnest, 8.6 mm at the widest. Every span is a short, clean
//     bridge between two anchored edges.
//   - Printed upside down the pedestal has two islands for the
//     first `recess_depth` mm — the outer slab and the core inside
//     the ring — which merge when the groove roofs over. Both are
//     bed-anchored, so this is fine.
//   - The tenon is still cut `tenon_bottom_gap` shorter than the
//     groove. It seats on the top face, not the groove floor, so
//     residual droop can't hold the hand proud — and the leftover
//     space gives excess glue somewhere to go, which matters in a
//     narrow channel with nowhere else to escape.
//   - The hand's first layer is the ring only, ~364 mm^2. That is
//     the same contact the raw mesh has, but it is a slender
//     footprint for a 90 mm tall part — use a brim.
//   - The text is INSET, not raised, and that is what makes it
//     printable in this orientation. Raised letters would print as
//     a scatter of thin islands laid straight onto the bed — easy
//     to knock loose, and every glyph edged with elephant's foot.
//     As a pocket the letters are voids in the first four layers,
//     bridged shut across a stroke width, and their walls form
//     against the bed. Letter counters (R, D, O, P) become small
//     bed-anchored islands, all several mm across.
//   - The edge treatment is a CHAMFER, not a fillet, and that is
//     what keeps the upside-down orientation viable. 45 deg is the
//     one profile that self-supports off a flat start. A 2 mm
//     fillet in the same place steps out 0.87 mm between the first
//     two 0.2 mm layers — several extrusion widths of unsupported
//     overhang, right on the show edge. If you ever do want a
//     rounded edge, print the pedestal right side up instead.
//
// Export (from /data4/projects/3dprinting):
//
//   The hand — always its own print:
//     openscad -o ginos_hand.stl -D 'part="top"' ginos.scad
//
//   Pedestal in one colour, engraving left as bare recesses:
//     openscad -o ginos_pedestal.3mf -D 'part="bottom"' ginos.scad
//
//   EVERYTHING, one file, one print job. Pedestal + plug as a
//   two-part object, hand as its own object, both laid out on the
//   bed. This is the one to use:
//     openscad --enable=lazy-union -o /tmp/raw.3mf \
//              -D 'part="printplate"' ginos.scad
//     python3 make_multipart_3mf.py /tmp/raw.3mf ginos_plate.3mf \
//              --group=1,2
//   The intermediate is disposable. Build items are ordered
//   1 pedestal, 2 text plug, 3 hand — hence --group=1,2.
//
//   Pedestal in two colours as two loose files, if you would rather
//   assemble by hand with right-click -> Add part -> Load:
//     openscad -o ginos_pedestal.3mf -D 'part="bottom"' ginos.scad
//     openscad -o ginos_text.3mf     -D 'part="text"'   ginos.scad
// ============================================================

/* [Quality] */
$fa = 1;    // Minimum angle — 1 deg gives max 360 facets per full circle
$fs = 0.4;  // Minimum facet edge length (mm) — matched to a 0.4 mm nozzle

/* [Part to export] */
part = "both";  // bottom | top | text | printplate | both | exploded

/* [Source mesh] */
stl_file  = "italian.stl";
convexity = 10;   // Render hint for the concave mesh — not a geometry change

/* [Model] */
model_scale = 1.15;   // Uniform scale on the hand; the pedestal does NOT follow it

/* [Pedestal] */
pedestal_height  = 10;   // Slab thickness
pedestal_width   = 200;  // X, mm
pedestal_depth   = 150;  // Y, mm
pedestal_chamfer = 1;    // 45 deg chamfer on the top and bottom edges (0 = sharp)

/* [Pedestal text] */
// Engraved into the top face, in the clear plate in FRONT of the
// hand. Inset rather than raised: printed upside down, raised text
// would be a scatter of thin glyph islands laid straight onto the
// bed, easy to knock off and prone to elephant's foot. As a pocket
// the letters are voids in the first few layers instead, roofed
// over by a short bridge, and their walls come off the bed crisp.
text_line1     = "RESERVED";
text_line2     = "DIE POESTE";
text_font      = "DejaVu Sans:style=Bold";
text_size      = 17;     // Line 1. Cap height is 1.031x this in DejaVu Bold
text_size2_pc  = 78;     // Line 2 as a percentage of line 1
text_spacing   = 1.12;   // Letter tracking. >1 opens the counters up
text_line_gap  = 9;      // Clear space between the two cap bands, mm
text_depth     = 0.8;    // 4 layers at 0.2 mm — opaque in a second filament
text_offset    = [0, 0]; // Nudge from the auto-centred position

/* [Hand placement] */
// Where the hand stands on the plate, measured from the plate's
// centre. +X moves it right, +Y moves it back (away from the
// viewer). [0, 0] centres the hand's BOUNDING BOX on the plate,
// which is what reads as centred — the wrist itself is off to one
// side because the fingers cantilever forward.
hand_offset = [0, 20];

// Spin about the wrist, degrees CCW seen from above. The track and
// the groove rotate with it, so the joint stays exact at any angle.
hand_rotation = 90;

/* [Joint] */
recess_depth     = 7;   // Groove depth in the pedestal's top face
joint_clearance  = 0.1; // Gap between track wall and groove wall, per face
tenon_bottom_gap = 0.5; // Track stops this far short of the groove floor
//
// NOTE: the groove is deliberately NOT offered as a through-cut.
// Punching a closed ring through the slab would sever the core
// inside it and drop it out as a loose piece.

/* [Bed layout] */
explode_gap  = 5;      // Gap between the two parts on the bed
explode_axis = "auto"; // auto | x | y — which way to lay them out
bed_size     = 270;    // Printable square the layout must fit

/* [Measured constants — from italian.stl, do not edit by hand] */
stl_base_z      = 13.500;              // Z of the flat wrist cut
stl_base_centre = [26.1290, -1.3535];  // XY centre of the wrist footprint
stl_hand_min    = [ 2.500, -23.000];   // Overall XY bounding box of the mesh
stl_hand_max    = [59.107,  25.930];

// The wrist cut is an ANNULUS: the forearm is a hollow shell, open
// at the base and closing inside the palm. Both boundary loops are
// lifted straight off the mesh in raw STL coordinates — these are
// the mesh's own polylines, not approximations, so the joint is
// exact. Outer loop encloses 638.45 mm^2, inner 274.71 mm^2, and
// the ring between them is the 363.74 mm^2 wall the track follows.
stl_base_outline = [   // 72 points, CCW — outside of the wrist wall
    [  15.814,  -9.158], [  16.112,  -9.627], [  16.987, -10.505], [  19.803, -12.586],
    [  20.836, -13.414], [  21.526, -14.014], [  23.212, -15.493], [  24.231, -16.345],
    [  24.815, -16.768], [  25.922, -17.358], [  26.818, -17.622], [  27.656, -17.760],
    [  28.358, -17.794], [  29.626, -17.721], [  30.185, -17.622], [  30.773, -17.464],
    [  31.607, -17.146], [  32.357, -16.753], [  32.884, -16.424], [  34.063, -15.480],
    [  34.650, -14.916], [  35.945, -13.436], [  36.808, -12.067], [  37.018, -11.621],
    [  37.284, -11.020], [  37.757,  -9.518], [  38.196,  -7.334], [  38.387,  -5.688],
    [  38.341,  -3.425], [  38.246,  -2.768], [  37.962,  -1.213], [  37.590,   0.284],
    [  36.937,   2.679], [  36.615,   3.659], [  36.504,   4.023], [  36.444,   4.262],
    [  36.029,   6.399], [  35.867,   7.675], [  35.764,   8.198], [  35.652,   8.724],
    [  35.152,  10.085], [  34.673,  10.771], [  33.657,  11.561], [  32.343,  12.279],
    [  30.755,  13.048], [  27.503,  13.980], [  24.715,  14.685], [  23.821,  14.856],
    [  22.610,  15.021], [  21.491,  15.087], [  20.161,  15.015], [  18.899,  14.733],
    [  17.350,  14.007], [  16.687,  13.489], [  15.957,  12.689], [  15.519,  12.055],
    [  14.868,  10.700], [  14.626,  10.022], [  14.291,   8.806], [  14.158,   8.126],
    [  14.002,   6.694], [  14.014,   5.675], [  14.144,   4.214], [  14.257,   2.377],
    [  14.109,  -0.779], [  14.033,  -2.912], [  13.871,  -4.497], [  13.903,  -4.776],
    [  14.041,  -5.489], [  14.295,  -6.006], [  15.043,  -7.346], [  15.154,  -7.546],
];

stl_base_cavity = [    // 27 points, CCW — inside of the wrist wall
    [  26.069, -12.854], [  27.087, -13.802], [  34.212, -12.463], [  35.235, -10.167],
    [  35.761,  -8.444], [  36.194,  -5.988], [  36.266,  -5.074], [  36.159,  -2.055],
    [  35.762,   0.091], [  35.139,   2.074], [  34.225,   4.052], [  33.186,   5.784],
    [  32.244,   7.026], [  31.240,   8.130], [  30.150,   9.158], [  23.025,   7.820],
    [  22.581,   6.925], [  21.633,   4.383], [  21.281,   2.941], [  20.980,   0.463],
    [  20.985,  -1.459], [  21.168,  -3.217], [  21.594,  -5.188], [  22.403,  -7.448],
    [  23.117,  -8.903], [  23.992, -10.344], [  24.546, -11.110],
];

// ---- Derived ------------------------------------------------

eps = 0.01;   // Overlap to keep booleans manifold

// 2D rotation about the origin, which in assembled coordinates is
// the wrist centre — so the hand spins on its own joint and the
// track stays concentric with the groove whatever the angle.
function rot2(p, a) = [p[0] * cos(a) - p[1] * sin(a),
                       p[0] * sin(a) + p[1] * cos(a)];

// Hand's footprint, rotated. Rotating the four bbox corners is EXACT
// at multiples of 90 deg; at other angles it is a slight over-estimate
// of the true silhouette, which only makes the reported hand gaps a
// little pessimistic. The joint below is exact at every angle.
raw_min  = (stl_hand_min - stl_base_centre) * model_scale;
raw_max  = (stl_hand_max - stl_base_centre) * model_scale;
hand_pts = [for (c = [[raw_min[0], raw_min[1]], [raw_max[0], raw_min[1]],
                      [raw_max[0], raw_max[1]], [raw_min[0], raw_max[1]]])
                rot2(c, hand_rotation)];

hand_min    = [min([for (p = hand_pts) p[0]]), min([for (p = hand_pts) p[1]])];
hand_max    = [max([for (p = hand_pts) p[0]]), max([for (p = hand_pts) p[1]])];
hand_size   = hand_max - hand_min;
hand_centre = (hand_min + hand_max) / 2;

pedestal_size = [pedestal_width, pedestal_depth];

// Everything is modelled about the wrist, so placing the hand means
// moving the PLATE the other way: shifting the plate -1 mm in X puts
// the hand +1 mm from the plate's centre.
ped_centre = hand_centre - hand_offset;

// Groove extent, rotated with the hand. Taken from the outline's own
// points, so this is exact at any angle — and it cannot go stale,
// because it is measured from the same list the groove is cut from.
groove_pts = [for (p = stl_base_outline)
                  rot2((p - stl_base_centre) * model_scale, hand_rotation)];
groove_min = [min([for (p = groove_pts) p[0]]) - joint_clearance,
              min([for (p = groove_pts) p[1]]) - joint_clearance];
groove_max = [max([for (p = groove_pts) p[0]]) + joint_clearance,
              max([for (p = groove_pts) p[1]]) + joint_clearance];

// Clear top face left between the groove and each plate edge, with
// the chamfer taken off. Negative means the groove breaks out of the
// edge, which would ruin the joint. Order: -X, +X, -Y, +Y.
edge_gap = [ groove_min[0] - (ped_centre[0] - pedestal_size[0] / 2 + pedestal_chamfer),
            (ped_centre[0] + pedestal_size[0] / 2 - pedestal_chamfer) - groove_max[0],
             groove_min[1] - (ped_centre[1] - pedestal_size[1] / 2 + pedestal_chamfer),
            (ped_centre[1] + pedestal_size[1] / 2 - pedestal_chamfer) - groove_max[1]];

// Same four edges, but to the hand's silhouette. Negative here is
// only a styling choice — the fingers overhang the plate.
hand_gap = [pedestal_size[0] / 2 + hand_offset[0] - hand_size[0] / 2,
            pedestal_size[0] / 2 - hand_offset[0] - hand_size[0] / 2,
            pedestal_size[1] / 2 + hand_offset[1] - hand_size[1] / 2,
            pedestal_size[1] / 2 - hand_offset[1] - hand_size[1] / 2];

// How far the track reaches into the groove. Always short of the
// floor, so residual droop can never hold the hand off the top face.
tenon_depth = recess_depth - tenon_bottom_gap;

// --- Text block ------------------------------------------------
// Cap height per unit `size`, measured off the rendered glyphs of
// this font. OpenSCAD's `size` is not the cap height, so laying the
// two lines out by eye would leave the block visibly off-centre.
text_cap_ratio = 1.031;

text_size2 = text_size * text_size2_pc / 100;
text_cap1  = text_size  * text_cap_ratio;
text_cap2  = text_size2 * text_cap_ratio;
text_block = text_cap1 + text_line_gap + text_cap2;

// The clear strip in front of the hand, from the plate's front edge
// to the nearest point of the hand's SILHOUETTE — not its footprint.
// Text tucked under the overhanging fingers would be in shadow and
// half hidden, so the fingers set the limit, not the wrist.
text_zone   = [ped_centre[1] - pedestal_depth / 2, hand_min[1]];
text_centre = [ped_centre[0] + text_offset[0],
               (text_zone[0] + text_zone[1]) / 2 + text_offset[1]];

text_front = text_centre[1] - text_block / 2;
text_back  = text_centre[1] + text_block / 2;

// --- Bed layout -------------------------------------------------
// The two parts side by side, laid out along whichever axis leaves
// the most room. Stacking a 200 x 150 plate and the hand along X
// needs 261 mm of a 270 mm bed; along Y the same pair needs 220 mm.
// Picking the axis automatically keeps a brim affordable, and the
// hand wants one.
lay_x = [pedestal_size[0] + explode_gap + hand_size[0],
         max(pedestal_size[1], hand_size[1])];
lay_y = [max(pedestal_size[0], hand_size[0]),
         pedestal_size[1] + explode_gap + hand_size[1]];

lay_axis = explode_axis != "auto" ? explode_axis
         : (max(lay_x[0], lay_x[1]) <= max(lay_y[0], lay_y[1]) ? "x" : "y");

lay_size = lay_axis == "x" ? lay_x : lay_y;

// Offsets applied to each part's own bed-centred print orientation.
lay_ped  = lay_axis == "x" ? [-(lay_size[0] - pedestal_size[0]) / 2, 0]
                           : [0, -(lay_size[1] - pedestal_size[1]) / 2];
lay_hand = lay_axis == "x" ? [ (lay_size[0] - hand_size[0]) / 2, 0]
                           : [0,  (lay_size[1] - hand_size[1]) / 2];

assert(model_scale > 0, "model_scale must be positive");
assert(min(edge_gap) >= 0,
       str("hand_offset puts the groove off the edge of the plate — clear top face per edge ",
           "[-X,+X,-Y,+Y] = ", edge_gap, " mm. Move the hand back or enlarge the pedestal."));
echo(str("pedestal ", pedestal_size[0], " x ", pedestal_size[1], " x ", pedestal_height,
         " mm | groove edge gaps [-X,+X,-Y,+Y] = ", edge_gap,
         " | hand edge gaps = ", hand_gap));
assert(pedestal_chamfer >= 0 && pedestal_chamfer < pedestal_height / 2,
       "pedestal_chamfer must be >= 0 and less than half pedestal_height");
assert(pedestal_chamfer < min(pedestal_size[0], pedestal_size[1]) / 2,
       "pedestal_chamfer is too large for the pedestal footprint");
assert(recess_depth > tenon_bottom_gap && recess_depth < pedestal_height,
       "recess_depth must be deeper than tenon_bottom_gap and shallower than pedestal_height");
assert(text_depth > 0 && text_depth < pedestal_height - recess_depth,
       "text_depth must be positive and shallower than the material under the groove");
assert(text_front >= ped_centre[1] - pedestal_depth / 2 + pedestal_chamfer,
       str("the text block runs off the front of the plate by ",
           (ped_centre[1] - pedestal_depth / 2 + pedestal_chamfer) - text_front,
           " mm — shrink text_size or deepen the pedestal."));
assert(text_back <= groove_min[1],
       str("the text block reaches back into the groove by ", text_back - groove_min[1],
           " mm — shrink text_size or move the hand further back."));
echo(str("text: line1 cap ", text_cap1, " mm, line2 cap ", text_cap2,
         " mm, block ", text_block, " mm tall in a ", text_zone[1] - text_zone[0],
         " mm strip | usable width ", pedestal_width - 2 * pedestal_chamfer, " mm"));

// ---- Modules ------------------------------------------------

// The mesh exactly as it sits in the file, in its own coordinates.
module italian_raw() {
    import(stl_file, convexity = convexity);
}

// Raw STL coordinates -> assembled coordinates.
module normalised() {
    scale(model_scale)
        translate([-stl_base_centre[0], -stl_base_centre[1], -stl_base_z])
            children();
}

module italian_hand() {
    rotate([0, 0, hand_rotation])
        normalised() italian_raw();
}

// Raw-coordinate 2D loops -> assembled coordinates. `grow` pushes
// the boundary outward (negative shrinks it), used for clearance.
module base_loop(loop, grow = 0) {
    rotate(hand_rotation)
        scale(model_scale)
            translate(-stl_base_centre)
                offset(delta = grow / model_scale)
                    polygon(loop);
}

// The wrist wall itself: the ring between the two loops.
module base_ring(outer_grow = 0, inner_grow = 0) {
    difference() {
        base_loop(stl_base_outline, outer_grow);
        base_loop(stl_base_cavity, -inner_grow);
    }
}

// The track under the hand: the wrist wall run straight down. It
// overlaps up into the shell by `eps` so the union stays manifold.
module tenon() {
    translate([0, 0, -tenon_depth])
        linear_extrude(tenon_depth + eps)
            base_ring();
}

// The groove the track drops into — the same ring, widened by
// `joint_clearance` on BOTH faces so the fit is a clearance fit.
module recess() {
    translate([0, 0, -recess_depth])
        linear_extrude(recess_depth + eps)
            base_ring(joint_clearance, joint_clearance);
}

// Rectangular slab, Z = -pedestal_height .. 0, with a 45 deg chamfer
// on the top and bottom edges and sharp vertical corners.
//
// A chamfer rather than a fillet, deliberately: printed upside down
// the top edge lies against the bed, and 45 deg is exactly the angle
// that self-supports off a flat start. A fillet leaves the bed
// horizontally and droops. Kept small so it reads as a broken arris
// rather than a bevel — it also absorbs elephant's foot on the
// bed-facing edge, which a sharp arris would show.
//
// All-square construction, so unlike the sphere hull it needs no
// correction: every face lands exactly on nominal.
module pedestal_blank() {
    c = pedestal_chamfer;
    translate([ped_centre[0], ped_centre[1], -pedestal_height])
        hull() {
            linear_extrude(eps)
                offset(delta = -c) square(pedestal_size, center = true);
            translate([0, 0, c])
                linear_extrude(pedestal_height - 2 * c)
                    square(pedestal_size, center = true);
            translate([0, 0, pedestal_height - eps])
                linear_extrude(eps)
                    offset(delta = -c) square(pedestal_size, center = true);
        }
}

// Both lines, centred on the origin as a block.
//
// Each line is set on its BASELINE and the block is balanced using
// the measured cap heights. valign="center" would centre on the
// font's full em box — descender space included — and since neither
// line has descenders both would ride visibly high.
module text_2d() {
    y2 = -text_block / 2;
    y1 = y2 + text_cap2 + text_line_gap;

    translate([0, y1])
        text(text_line1, size = text_size, font = text_font,
             halign = "center", valign = "baseline", spacing = text_spacing);
    translate([0, y2])
        text(text_line2, size = text_size2, font = text_font,
             halign = "center", valign = "baseline", spacing = text_spacing);
}

// The engraving, as a solid to subtract. Runs `text_depth` down from
// the top face and pokes `eps` above it so the cut is clean.
module text_pocket() {
    translate([text_centre[0], text_centre[1], -text_depth])
        linear_extrude(text_depth + eps)
            text_2d();
}

// The matching plug: the same glyphs, filling the pocket exactly and
// finishing flush with the top face. Built from the same module, so
// the two cannot drift apart.
module text_plug() {
    translate([text_centre[0], text_centre[1], -text_depth])
        linear_extrude(text_depth)
            text_2d();
}

// ---- The two printed parts, in assembled coordinates ---------

module hand_part() {
    union() {
        italian_hand();
        tenon();
    }
}

module pedestal_part() {
    difference() {
        pedestal_blank();
        recess();
        text_pocket();
    }
}

// ---- The two printed parts, in print orientation -------------

// Wrist down, tenon bottom on the bed, centred on its footprint.
module hand_printable() {
    translate([-hand_centre[0], -hand_centre[1], tenon_depth])
        hand_part();
}

// Flipped so the recessed top face lies on the bed, centred. The
// plug goes through the SAME transform, so the two STLs drop into
// the slicer already aligned — never recentre either one.
module to_print_orientation() {
    translate([-ped_centre[0], ped_centre[1], 0])
        rotate([180, 0, 0])
            children();
}

module pedestal_printable() { to_print_orientation() pedestal_part(); }
module text_printable()     { to_print_orientation() text_plug();     }

// Only the bed-layout parts care whether everything fits at once, so
// this is a module rather than a top-level assert — exporting a
// single part must not be blocked by a layout it never uses.
module assert_bed_fits() {
    assert(lay_size[0] <= bed_size && lay_size[1] <= bed_size,
           str("bed layout is ", lay_size[0], " x ", lay_size[1], " mm on a ",
               bed_size, " mm bed. Reduce model_scale, shrink the pedestal, ",
               "or print the two parts in separate jobs."));
}

// ---- Render -------------------------------------------------

if (part == "bottom") {
    pedestal_printable();

} else if (part == "top") {
    hand_printable();

} else if (part == "text") {
    text_printable();

// THE ONE-SHOT PRINT PLATE. Three separate top-level objects, laid
// out on the bed: pedestal, text plug, hand. Export with
//     openscad --enable=lazy-union ...
// then run make_multipart_3mf.py --group 1,2 to fuse the pedestal
// and plug into a single two-part object while the hand stays its
// own object, so it can carry its own ironing / speed settings.
//
// WITHOUT the lazy-union flag OpenSCAD unions the three, and since
// the plug exactly fills the pocket you get a blank slab with the
// engraving filled in and the hand welded to it — wrong, quietly.
} else if (part == "printplate") {
    assert_bed_fits();
    translate(lay_ped)  pedestal_printable();
    translate(lay_ped)  text_printable();
    translate(lay_hand) hand_printable();

} else if (part == "both") {
    color("SteelBlue")  hand_part();
    color("Gainsboro")  pedestal_part();
    color("Firebrick")  text_plug();

} else if (part == "exploded") {
    assert_bed_fits();
    translate(lay_ped)  color("Gainsboro") pedestal_printable();
    translate(lay_ped)  color("Firebrick") text_printable();
    translate(lay_hand) color("SteelBlue") hand_printable();

} else {
    assert(false, str("Unknown part: \"", part,
                      "\" — expected bottom | top | text | printplate | both | exploded"));
}
