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
//   Pedestal — a rectangular slab with filleted edges and a
//     matching groove in its top face: the same ring, widened by
//     `joint_clearance` on both faces. Printed UPSIDE DOWN (top
//     face on the bed) so the show face gets the glassy bed
//     finish. See the fillet caveat under Printing notes.
//
// The track drops into the groove with 0.2 mm either side and
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
//   part="both"     -> assembled, for fit checking
//   part="exploded" -> both flat on the bed, side by side
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
//   - CAVEAT, the one real cost of a fillet over a chamfer: a
//     45 deg chamfer self-supports at any orientation, a fillet
//     does not. Printed upside down, the TOP edge fillet lands
//     against the bed, and a fillet leaves the bed horizontally.
//     At r = 2 mm and 0.2 mm layers the second layer steps out
//     0.87 mm over the first — far beyond one extrusion width, so
//     those first few layers will droop on the show edge.
//     Fixes, in order of preference:
//       1. Print the pedestal RIGHT SIDE UP. The bottom edge then
//          takes the abuse instead, the top fillet curves inward
//          going up so it prints perfectly, and the groove opens
//          upward and needs no bridging at all. Costs you the bed
//          finish on the top face — iron it instead.
//       2. Keep a chamfer on the bed-facing edge only.
//       3. Drop to r = 0.8 or so, where the first step-out is
//          0.55 mm and much more forgiving.
//
// Export (from /data4/projects/3dprinting):
//   openscad -o ginos_pedestal.stl -D 'part="bottom"' ginos.scad
//   openscad -o ginos_hand.stl     -D 'part="top"'    ginos.scad
// ============================================================

/* [Quality] */
$fa = 1;    // Minimum angle — 1 deg gives max 360 facets per full circle
$fs = 0.4;  // Minimum facet edge length (mm) — matched to a 0.4 mm nozzle

/* [Part to export] */
part = "both";  // bottom | top | both | exploded

/* [Source mesh] */
stl_file  = "italian.stl";
convexity = 10;   // Render hint for the concave mesh — not a geometry change

/* [Model] */
model_scale = 1.00;   // Uniform scale on the hand; the pedestal follows it

/* [Pedestal] */
pedestal_height  = 12;   // Slab thickness
pedestal_width   = 134;  // X, mm
pedestal_depth   = 89;   // Y, mm
pedestal_round   = 2;    // Edge fillet radius (0 = sharp arris)

/* [Hand placement] */
// Where the hand stands on the plate, measured from the plate's
// centre. +X moves it right, +Y moves it back (away from the
// viewer). [0, 0] centres the hand's BOUNDING BOX on the plate,
// which is what reads as centred — the wrist itself is off to one
// side because the fingers cantilever forward.
hand_offset = [0, 0];

// Spin about the wrist, degrees CCW seen from above. The track and
// the groove rotate with it, so the joint stays exact at any angle.
hand_rotation = 90;

/* [Joint] */
recess_depth     = 6;   // Groove depth in the pedestal's top face
joint_clearance  = 0.2; // Gap between track wall and groove wall, per face
tenon_bottom_gap = 0.5; // Track stops this far short of the groove floor
//
// NOTE: the groove is deliberately NOT offered as a through-cut.
// Punching a closed ring through the slab would sever the core
// inside it and drop it out as a loose piece.

/* [Exploded view] */
explode_gap = 5;    // Gap between the two parts on the bed
bed_size    = 270;  // Printable square the exploded layout must fit

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
// the fillet taken off. Negative means the groove breaks out of the
// edge, which would ruin the joint. Order: -X, +X, -Y, +Y.
edge_gap = [ groove_min[0] - (ped_centre[0] - pedestal_size[0] / 2 + pedestal_round),
            (ped_centre[0] + pedestal_size[0] / 2 - pedestal_round) - groove_max[0],
             groove_min[1] - (ped_centre[1] - pedestal_size[1] / 2 + pedestal_round),
            (ped_centre[1] + pedestal_size[1] / 2 - pedestal_round) - groove_max[1]];

// Same four edges, but to the hand's silhouette. Negative here is
// only a styling choice — the fingers overhang the plate.
hand_gap = [pedestal_size[0] / 2 + hand_offset[0] - hand_size[0] / 2,
            pedestal_size[0] / 2 - hand_offset[0] - hand_size[0] / 2,
            pedestal_size[1] / 2 + hand_offset[1] - hand_size[1] / 2,
            pedestal_size[1] / 2 - hand_offset[1] - hand_size[1] / 2];

// How far the track reaches into the groove. Always short of the
// floor, so residual droop can never hold the hand off the top face.
tenon_depth = recess_depth - tenon_bottom_gap;

// Exploded layout: pedestal left, hand right.
explode_span = pedestal_size[0] + explode_gap + hand_size[0];

assert(model_scale > 0, "model_scale must be positive");
assert(min(edge_gap) >= 0,
       str("hand_offset puts the groove off the edge of the plate — clear top face per edge ",
           "[-X,+X,-Y,+Y] = ", edge_gap, " mm. Move the hand back or enlarge the pedestal."));
echo(str("pedestal ", pedestal_size[0], " x ", pedestal_size[1], " x ", pedestal_height,
         " mm | groove edge gaps [-X,+X,-Y,+Y] = ", edge_gap,
         " | hand edge gaps = ", hand_gap));
assert(pedestal_round >= 0 && pedestal_round < pedestal_height / 2,
       "pedestal_round must be >= 0 and less than half pedestal_height");
assert(pedestal_round < min(pedestal_size[0], pedestal_size[1]) / 2,
       "pedestal_round is too large for the pedestal footprint");
assert(recess_depth > tenon_bottom_gap && recess_depth < pedestal_height,
       "recess_depth must be deeper than tenon_bottom_gap and shallower than pedestal_height");

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

// Rectangular slab, Z = -pedestal_height .. 0, with every edge
// filleted at `pedestal_round`. Built as the hull of eight corner
// spheres, which gives a true radius on all twelve edges rather
// than the flat bevel a hull of inset plates would produce.
//
// The vertical corners round too. At the default 2 mm on a
// 134 x 89 plate that is visually negligible — the plate still
// reads hard-edged and rectangular — and it avoids the spike you
// get where a rounded horizontal edge meets a sharp corner.
module pedestal_blank() {
    r = pedestal_round;
    translate([ped_centre[0], ped_centre[1], -pedestal_height])
        if (r <= 0) {
            linear_extrude(pedestal_height)
                square(pedestal_size, center = true);
        } else union() {
            hull()
                for (sx = [-1, 1], sy = [-1, 1], sz = [0, 1])
                    translate([sx * (pedestal_size[0] / 2 - r),
                               sy * (pedestal_size[1] / 2 - r),
                               r + sz * (pedestal_height - 2 * r)])
                        sphere(r);

            // A faceted sphere is INSCRIBED, so the hull alone lands
            // its flat faces r*(1-cos(180/$fn)) shy of nominal — the
            // slab would float off the bed and sit a hair below the
            // wrist. These three interpenetrating boxes pin all six
            // faces exactly; the hull only supplies the rounded edges.
            for (b = [[pedestal_size[0],         pedestal_size[1] - 2 * r, pedestal_height - 2 * r],
                      [pedestal_size[0] - 2 * r, pedestal_size[1],         pedestal_height - 2 * r],
                      [pedestal_size[0] - 2 * r, pedestal_size[1] - 2 * r, pedestal_height]])
                translate([0, 0, pedestal_height / 2]) cube(b, center = true);
        }
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
    }
}

// ---- The two printed parts, in print orientation -------------

// Wrist down, tenon bottom on the bed, centred on its footprint.
module hand_printable() {
    translate([-hand_centre[0], -hand_centre[1], tenon_depth])
        hand_part();
}

// Flipped so the recessed top face lies on the bed, centred.
module pedestal_printable() {
    translate([-ped_centre[0], ped_centre[1], 0])
        rotate([180, 0, 0])
            pedestal_part();
}

// ---- Render -------------------------------------------------

if (part == "bottom") {
    pedestal_printable();

} else if (part == "top") {
    hand_printable();

} else if (part == "both") {
    color("SteelBlue")  hand_part();
    color("Gainsboro")  pedestal_part();

} else if (part == "exploded") {
    assert(explode_span <= bed_size && max(pedestal_size[1], hand_size[1]) <= bed_size,
           "exploded layout does not fit the bed — reduce model_scale or explode_gap");
    translate([-explode_span / 2 + pedestal_size[0] / 2, 0, 0])
        color("Gainsboro") pedestal_printable();
    translate([ explode_span / 2 - hand_size[0] / 2, 0, 0])
        color("SteelBlue") hand_printable();

} else {
    assert(false, str("Unknown part: \"", part,
                      "\" — expected bottom | top | both | exploded"));
}
