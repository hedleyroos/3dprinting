// ============================================================
// medicine_tray.scad — medicine cupboard tray: ONE tray that
// slides in and out of the shelf, divided into 6 compartments
// (2 across x 3 deep), each with a printed category label tab.
// Standalone, no external dependencies.
//
// Design record: medicine/PLAN.md.
//
// WHAT IT IS
//   The 354 x 560 tray is far bigger than the bed, so it is SIX
//   BINS, one per compartment, that lock together into one tray.
//   No rails: the tray slides on the shelf on its own floor.
//   * Every wall is printed ONCE. A wall between two compartments
//     belongs to one bin, and the neighbour is left open on that
//     side and locks onto it:
//       - the left bins (1, 3, 5) own the centre wall, so the right
//         bins (2, 4, 6) have no left wall;
//       - every bin owns its front wall, so bins 1-4 have no back
//         wall: the bin behind closes them. Bins 5 and 6 own the
//         tray's back wall.
//   * JOINTS, where an open bin meets its neighbour's wall:
//       - each of the open bin's walls that ends there ends in a
//         POST with a dovetail SOCKET; the neighbour's wall carries
//         a matching dovetail RAIL;
//       - the open bin's floor edge has dovetail sockets for KEYS
//         that stick out from the foot of the neighbour's wall.
//     Rails, keys and sockets are all vertical, so a bin goes in by
//     lowering it into place from above. Once in, it can move only
//     straight up again; a drop of CA on each floor key stops that.
//     Rails and posts run only in two BANDS, joint_band high, at the
//     wall foot and under the wall top: small dovetail outlines on
//     every layer cost far more print time than their plastic, and
//     the bands save about 4.5 h on the solid tray over full-height
//     joints (PLAN.md has the sliced numbers).
//     A raised band grows out of its wall on a 42° chamfer. A post's
//     far cheek (across the socket from its wall) has only the post's
//     back to grow from, so it gets a second 42° slope of its own.
//   * Walls are SOLID by default (wall_style = "solid").
//     wall_style = "hex" cuts a hex mesh into every wall instead,
//     leaving solid rails top and bottom, a solid band at each wall
//     end (where the joints are) and solid wall behind the label
//     tab. The wall holes are the floor's own regular hex, turned
//     flats up and down: their sides lean 30° from vertical and each
//     roof is a flat 8 mm bridge, so they print without support (a
//     hex standing on a corner has 30° roofs, which droop). Only
//     whole holes are cut; the rails and end bands take what's left.
//   * The floor is a hex MESH inside a solid border band, widened
//     along an open side to hold the key sockets.
//   * Each bin's front wall carries a LABEL TAB: a ledge flush
//     with the wall top, held up by a 45° gusset, with the
//     category name raised on top. Read from above when the tray
//     is pulled out; the front row reads from the cupboard door.
//   * TALL BIN: bin 5 (back-left, "Braces & Supports") has walls
//     tall_h high instead of wall_h, for bulky things like elbow
//     braces. It owns all four of its walls, so it rises on its own:
//     its neighbours stay wall_h, and the rails on its walls stop at
//     their height. A bin can't be taller than a bin whose wall
//     closes its open side (bin 6 could only be tall with bin 5).
//
// COORDINATES (mm)
//   X across the width; x = 0 is the tray centre (centred in the
//     360 mm door opening).
//   Y depth; y = 0 is the FRONT face of the tray, +Y toward the
//     back wall.
//   Z up; z = 0 is the shelf.
//   Bins are numbered 1..6: front-left, front-right, middle-left,
//   middle-right, back-left, back-right. Every bin is modelled in
//   its place in the tray; part = "bin_N" moves it to the bed centre.
//
// PRINTING — PLA (SUNLU PLA+, Orca "0.20mm Standard @Qidi Q2"),
// no supports
//   Printer: Qidi Q2 (270 x 270 bed, 256 mm Z). One bin per plate,
//   floor down, as modelled. The label text is the only thing above
//   a bin's wall top, so a filament change there (layer 160.2 mm;
//   220.2 mm on the tall bin 5) prints it in a second colour. No
//   brim: the automatic one wraps the floor keys and fills the key
//   sockets, and the floor holds on its own.
// ORCA: printer="Qidi Q2 0.4 nozzle @Q2 0.4" process="0.20mm Standard @Qidi Q2"
// ORCA: filament="SUNLU PLA+ 2.0 @Q2 0.4" brim_type=no_brim
// ORCA: note="two-colour labels: filament change at layer 160.2 mm (tall bin 5: 220.2 mm)"
//
// ASSEMBLY
//   First print part = "joint_test" (two 20 mm pieces): the rail
//   must slide through its socket, and the key drop into its slot,
//   by hand, without slop. If not, change joint_clear and reprint
//   the test before printing any bins.
//   On a flat surface, stand bin 5 in its place. Lower each other
//   bin into its place from above, its sockets over its neighbours'
//   rails and keys; any order works (5, 3, 1, 6, 4, 2 is easy).
//   Dry-fit the whole tray first. To make it permanent, take it
//   apart and rebuild it with a drop of CA (superglue) on each floor
//   key just before lowering the bin over it: a key only enters its
//   socket in the last 2 mm, so no glue is dragged along a rail.
//   Acetone does not weld PLA.
// ============================================================

/* [Part] */
part = "assembly"; // [assembly, assembly_pulled, assembly_exploded, bin_1, bin_2, bin_3, bin_4, bin_5, bin_6, joint_test]
pull_dist    = 250;  // assembly_pulled: how far the tray is slid out
explode_step = 45;   // assembly_exploded: height added per assembly step

/* [Labels] */
label_1 = "Pain & Muscle";      // front left
label_2 = "Cold & Flu";         // front right (allergy too)
label_3 = "First Aid";          // middle left
label_4 = "Skin";               // middle right
label_5 = "Braces & Supports";  // back left, the tall bin
label_6 = "Tummy & Sleep";      // back right

/* [Shelf] */
opening_w  = 360;  // clear slide-out width (door / hinges)
shelf_d    = 565;  // usable depth, from the back wall
shelf_h    = 350;  // usable height
side_clear = 3;    // tray to opening, each side

/* [Printer] */
bed_x      = 270;
bed_y      = 270;
bed_z      = 256;  // Qidi Q2
bed_margin = 5;    // keep each bin this far inside the bed edge (brim, skirt)

/* [Tray] */
tray_d  = 560;     // overall depth, front face to back face (<= shelf_d)
cols    = 2;       // compartments across (fixed design: 2)
rows    = 3;       // compartments front to back (fixed design: 3)
wall_h  = 160;     // overall height, underside to wall top
tall_h  = 220;     // the tall bins' height (braces and supports)
tall_bins = [5];   // bins (1..6) built tall_h high; [] for none
wall_t  = 1.6;     // every wall, outer and dividing; each is printed once
floor_t = 2;

/* [Walls] */
wall_style  = "solid"; // [solid, hex]
wall_hex    = 14;      // hex: hole height, flat to flat (14 = hex_af, the floor's hex)
wall_strut  = 2.5;     // hex: strut between holes (2.5 = hex_strut)
wall_rail_b = 6;       // hex: least solid band at the wall bottom (includes the floor)
wall_rail_t = 6;       // hex: least solid band under the wall top (the grip edge)
wall_post   = 12;      // hex: least solid band at each end of a wall (carries the joints)

/* [Joints] */
joint_band    = 30;   // rails and posts run this high at the wall foot and again
                      // under the wall top; 0 = full height (slower to print)
joint_clear   = 0.25; // fit clearance per side in every socket
rail_neck     = 3;    // wall rail: width where it leaves the wall
rail_head     = 6;    // wall rail: width at its tip
rail_d        = 3;    // wall rail: how far it stands off the wall
rail_lead     = 3;    // wall rail: height of the lead-in taper at its top
rail_taper    = 0.6;  // wall rail: how much narrower the lead-in is at the top
socket_m      = 1.6;  // material each side of a rail socket
key_neck      = 5;    // floor key: width where it leaves the wall
key_head      = 10;   // floor key: width at its tip
key_d         = 5;    // floor key: how far it reaches under the open bin's floor
keys_per_side = 3;    // floor keys along each open side
key_band      = 10;   // solid floor band along an open side (holds the key sockets)
socket_flare  = 0.4;  // sockets widen by this at the bed, 45°, for first-layer squish

/* [Label tab] */
tab_w       = 110;   // ledge length along the front wall
tab_d       = 15;    // ledge depth, inner wall face to free edge
tab_t       = 1.6;   // ledge thickness at its free edge
text_size   = 8;     // text height (≈ ascent); long labels shrink to fit
text_min    = 5;     // refuse labels that would shrink below this
text_h      = 0.6;   // text raised above the ledge top
text_margin = 4;     // clear space at each end of the ledge
font        = "Liberation Sans:style=Bold";

/* [Mesh base] */
hex_af       = 14;   // hex hole size across flats
hex_strut    = 2.5;  // strut between neighbouring holes
floor_border = 4;    // solid floor band inside the walls

/* [Quality] */
$fa = 1;   // Minimum angle
$fs = 0.4; // Minimum facet edge length (mm)

/* [Hidden] */
EPS = 0.01;
// Advance per character as a fraction of text size, for fitting
// labels without the experimental textmetrics(). Liberation Sans Bold
// measures 0.68 on "Cold & Flu"; capitals run wider, hence 0.75.
CHAR_W = 0.75;
// joint_test: piece height, length along the joint, floor strip width,
// gap between the two pieces on the bed
JT_H = 20;
JT_L = 40;
JT_W = 14;
JT_GAP = 12;
// assembly_exploded: bins in assembly order (bins 5, 3, 1, 6, 4, 2)
ASM_ORDER = [4, 2, 0, 5, 3, 1];

// ---------------- derived ----------------
n_bins  = cols * rows;
labels  = [label_1, label_2, label_3, label_4, label_5, label_6];
tray_w  = opening_w - 2 * side_clear;
x_l     = -tray_w / 2;                             // tray's left face
in_w    = (tray_w - (cols + 1) * wall_t) / cols;   // compartment interior
in_d    = (tray_d - (rows + 1) * wall_t) / rows;
p_x     = in_w + wall_t;                           // wall pitch across
p_y     = in_d + wall_t;                           // wall pitch front to back
hex_p   = hex_af + hex_strut;                      // floor hole pitch across flats
ledge_d = wall_t + tab_d;                          // flat top: wall top + ledge

// A bin's height, underside to wall top: tall_h for tall_bins.
function bin_h(i) = len(search(i + 1, tall_bins)) > 0 ? tall_h : wall_h;
bin_hs  = [for (i = [0 : n_bins - 1]) bin_h(i)];
min_h   = min(bin_hs);
tray_h  = max(bin_hs) + text_h;

// Label tab on a wall h high: the gusset's foot on the wall's outer
// plane, and where it leaves the inner face.
function tab_z0(h)  = h - tab_t - ledge_d;
function tab_bot(h) = tab_z0(h) + wall_t;

// Dovetails. A socket is its dovetail grown by joint_clear all round;
// at the tip, the splayed flank adds clear * (tan + sec) of the flank
// angle to its half-width.
// Pulled apart, a dovetail moves joint_clear / sin(flank angle)
// before it catches: the joint's play.
function sock_hw(neck, head, d) =
    let (t = (head - neck) / (2 * d)) head / 2 + joint_clear * (t + sqrt(1 + t * t));
function play(neck, head, d) = joint_clear / sin(atan((head - neck) / (2 * d)));
post_w  = 2 * (sock_hw(rail_neck, rail_head, rail_d) + socket_m);  // along the owner's face
post_d  = rail_d + joint_clear + socket_m;                          // off the owner's face
key_sw  = 2 * sock_hw(key_neck, key_head, key_d);                   // key socket, widest

// Wall hexes: the floor's honeycomb stood up, with the hex turned
// flats top and bottom (corners to the sides). Columns run along the
// wall w_dx apart; each is a stack of holes w_p apart, and every
// other column is dropped by half a hole. The middle column is
// centred on the wall and on the band between the rails, so every
// wall's mesh is mirror-symmetric.
wz0     = wall_rail_b;                             // hole band: bottom, and
function wz1(h) = h - wall_rail_t;                 // top on a wall h high
w_p     = wall_hex + wall_strut;                   // hole pitch up a column
w_dx    = w_p * cos(30);                           // column pitch along the wall
w_hw    = wall_hex / sqrt(3);                      // hole half-width, corner to corner
w_hh    = wall_hex / 2;                            // hole half-height, flat to flat
w_roof  = wall_hex / sqrt(3);                      // flat roof: the bridge over each hole

function col(i) = i % cols;
function row(i) = floor(i / cols);

// A bin's footprint [x0, x1, y0, y1], tray coordinates. Left bins
// include the centre wall, every bin its front wall, the back row
// the tray's back wall.
function bin_box(i) =
    [col(i) == 0 ? x_l : x_l + p_x + wall_t,
     col(i) == 0 ? x_l + p_x + wall_t : tray_w / 2,
     row(i) * p_y,
     row(i) == rows - 1 ? tray_d : (row(i) + 1) * p_y];

function comp_cx(i) = x_l + col(i) * p_x + wall_t + in_w / 2;   // compartment centre

// Walls a bin owns: [x, y, length, along (0 = X, 1 = Y), u of the
// label tab centre along the wall or -1].
function bin_walls(i) =
    let (b = bin_box(i), L = b[1] - b[0], D = b[3] - b[2])
    concat([[b[0], b[2], L, 0, comp_cx(i) - b[0]]],                       // front
           row(i) == rows - 1 ? [[b[0], b[3] - wall_t, L, 0, -1]] : [],   // back
           col(i) == 0 ? [[b[0], b[2], D, 1, -1]] : [],                   // left
           [[b[1] - wall_t, b[2], D, 1, -1]]);                            // right or centre

// Joints, one per open side of a bin:
//   [owner, open bin, normal, face, rails, key positions]
// normal: -90 = the open bin is in front of the owner (-Y), 0 = to
// its right (+X). face: that face's y (normal -90) or x (normal 0).
// Positions run along the face, in tray x (normal -90) or y (0).
// Rails sit where the open bin's walls end, inside its corner posts;
// each is [position, side of the post the open bin's wall is on
// (-1 = lower position, +1 = higher)].
function spread(s0, s1) =
    [for (k = [0 : keys_per_side - 1]) s0 + (s1 - s0) * (k + 0.5) / keys_per_side];
function bin_joints(j) =
    let (b = bin_box(j))
    concat(row(j) < rows - 1
               ? [[j + cols, j, -90, b[3],
                   concat(col(j) == 0 ? [[b[0] + post_w / 2, -1]] : [], [[b[1] - post_w / 2, 1]]),
                   spread(b[0], b[1])]]
               : [],
           col(j) == 1
               ? [[j - 1, j, 0, b[0],
                   concat([[b[2] + post_w / 2, -1]], row(j) == rows - 1 ? [[b[3] - post_w / 2, 1]] : []),
                   spread(b[2], b[3])]]
               : []);

// Heights [z0, z1] where rails and posts run in a joint whose open
// bin is h high. The owner may be taller (a tall bin); its rails
// stop at the open bin's height, where its posts do.
function bands(h) = joint_band <= 0 ? [[0, h]] : [[0, joint_band], [h - joint_band, h]];
function joint_h(J) = bin_h(J[1]);
// Chamfers under raised bands rise 1.1 x their overhang (42° from
// vertical), so they stay inside the 45° rule.
post_cham = 1.1 * (post_w - wall_t);
// The socket splits an upper post. Its far cheek, across the socket
// from the wall, has the socket's void below it and is joined to the
// rest only by the post's back. Chamfered sideways with the rest, it
// would start in mid-air at the socket's mouth, where the socket is
// narrowest. So the sideways chamfer finishes post_cham_x lower, and
// the far cheek grows from the back to the mouth on a 42° slope.
sock_back   = rail_d + joint_clear;                 // owner's face to the back of a socket
post_cham_x = 1.1 * sock_back;
rail_cham = 1.1 * rail_d;
joints = [for (j = [0 : n_bins - 1]) each bin_joints(j)];

// Size on the bed: footprint plus the keys and rails it owns.
function bin_ext(i) =
    let (b = bin_box(i), own = [for (J = joints) if (J[0] == i) J[2]], stick = max(key_d, rail_d))
    [b[1] - b[0] + (len(search(0, own)) > 0 ? stick : 0),
     b[3] - b[2] + (len(search(-90, own)) > 0 ? stick : 0)];

// Hole centres on a wall of length L and height h (u along the wall
// from its start, v = z), symmetric about L/2. Only whole holes: one
// clipped by a rail would get a roof up to twice as wide to bridge.
// Holes stay wall_post clear of each end, and on a front wall clear
// of the label tab and its gusset (centred at tab_u).
function wall_holes(L, tab_u, h) =
    let (kx0 = tab_u - tab_w / 2 - wall_strut, kx1 = tab_u + tab_w / 2 + wall_strut,
         kz0 = tab_bot(h) - wall_strut, z1 = wz1(h),
         K = ceil(L / (2 * w_dx)) + 1, J = ceil((z1 - wz0) / (2 * w_p)) + 1)
    [for (k = [-K : K], j = [-J : J])
        let (u = L / 2 + k * w_dx,
             v = (wz0 + z1) / 2 + (j + (abs(k) % 2) / 2) * w_p)
        if (u - w_hw >= wall_post - EPS && u + w_hw <= L - wall_post + EPS
            && v - w_hh >= wz0 - EPS && v + w_hh <= z1 + EPS
            && !(tab_u >= 0 && u + w_hw > kx0 && u - w_hw < kx1 && v + w_hh > kz0))
            [u, v]];

function label_size(s) =
    min(text_size, (tab_w - 2 * text_margin) / (CHAR_W * max(1, len(s))));

bin_idx = let (m = [for (i = [0 : n_bins - 1]) if (part == str("bin_", i + 1)) i])
          len(m) > 0 ? m[0] : -1;

// ---------------- checks ----------------
assert(cols == 2 && rows == 3, "fixed design: 6 compartments, 2 across x 3 deep");
assert(len(labels) == n_bins, "one label per compartment");
assert(tray_d <= shelf_d, str("tray depth ", tray_d, " > shelf depth ", shelf_d));
assert(tray_h <= shelf_h, "tray taller than the shelf");
assert(tray_h <= bed_z, "bin taller than the printer's Z");
for (t = tall_bins)
    assert(t >= 1 && t <= n_bins && t == floor(t), str("tall_bins: no bin ", t));
// A bin taller than the neighbour whose wall closes its open side
// would be open above that wall.
for (J = joints)
    assert(bin_h(J[1]) <= bin_h(J[0]),
           str("bin ", J[1] + 1, " is taller than bin ", J[0] + 1, ", whose wall closes its side"));
for (i = [0 : n_bins - 1])
    let (e = bin_ext(i))
        assert(e[0] <= bed_x - 2 * bed_margin && e[1] <= bed_y - 2 * bed_margin,
               str("bin ", i + 1, " is ", e[0], " x ", e[1], " with its keys: does not fit the bed with margin"));
assert(tab_w <= in_w - 20, "label tab leaves under 10 mm of wall top each side");
assert(tab_bot(min_h) >= floor_t + 20, "label tab gusset reaches too far down the wall");
assert(text_size * 1.3 <= ledge_d - 2, "text_size too big for the ledge depth");
assert(floor_border >= hex_strut, "floor border thinner than a strut");
assert(hex_af > 0 && hex_strut >= 1.5, "mesh strut too thin");
assert(wall_style == "solid" || wall_style == "hex", "wall_style is solid or hex");
assert(wall_strut >= 1.5, "wall mesh strut too thin");
assert(wall_post >= post_w + 1, str("wall_post must cover a joint post (", post_w, " mm) plus 1 mm"));
assert(wall_rail_b >= floor_t + 2, "bottom wall rail must clear the floor by 2 mm");
assert(wz1(min_h) - wz0 >= 2 * w_p, "rails leave no room for two rows of wall hexes");
assert(w_roof <= 10, str("wall hex roofs bridge ", w_roof, " mm; keep wall_hex under 17"));
assert(rail_head > rail_neck && key_head > key_neck, "a dovetail must be wider at its tip than its neck");
assert(rail_neck >= 2.5 && key_neck >= 4, "dovetail neck too thin");
assert(socket_m >= 1.2, "socket side thinner than three lines");
assert(joint_clear >= 0.1 && joint_clear <= 0.5, "joint_clear outside 0.1 .. 0.5");
assert(rail_lead < min_h / 4 && rail_taper < rail_neck / 2, "rail lead-in too big");
assert(joint_band == 0 || joint_band >= max(15, floor_t + rail_lead + 5), "joint_band too short to hold");
// lowering a bin, its top post (with its chamfer) must pass above the
// owner's foot rails: the bands must not reach each other
assert(joint_band == 0 || min_h - joint_band - max(post_cham + post_cham_x, rail_cham) > joint_band + 5,
       "joint bands overlap; use joint_band = 0 for full-height joints");
assert(key_band >= key_d + joint_clear + 2, "key_band leaves under 2 mm of floor behind a key socket");
assert(post_d <= key_band, "joint post sticks out past the floor's solid band");
assert(min(p_x, p_y) / (2 * keys_per_side) - key_sw / 2 >= post_w + 2,
       "floor keys run into the corner posts; use fewer keys_per_side");
assert(post_d + 10 <= (in_w - tab_w) / 2, "label tab runs into a joint post");
for (s = labels)
    assert(label_size(s) >= text_min,
           str("label \"", s, "\" is too long for the tab (would print at ",
               label_size(s), " mm); shorten it or widen tab_w"));

echo(str("tray ", tray_w, " x ", tray_d, ", bins 1-6 ", bin_hs, " high (+", text_h,
         " text); compartment interior ", in_w, " x ", in_d));
echo(str("door gap each side ", side_clear, "; depth spare ", shelf_d - tray_d,
         "; headroom above walls ", shelf_h - tray_h));
echo(str("bins on the bed incl. keys: ", [for (i = [0 : n_bins - 1]) bin_ext(i)]));
echo(str("joints: ", len(joints), " open sides, rails and posts at z ",
         [for (h = bin_hs) if (len([for (J = joints) if (joint_h(J) == h) 1]) > 0) bands(h)][0],
         [for (J = joints) if (joint_h(J) != wall_h) 1] == [] ? ""
             : str(" (", bands(tall_h), " where a tall bin is the open one)"), ", ",
         len([for (J = joints) each J[4]]), " rails, ",
         len([for (J = joints) each J[5]]), " floor keys; post ", post_w, " x ", post_d,
         "; play pulled apart: rail ", play(rail_neck, rail_head, rail_d), ", key ",
         play(key_neck, key_head, key_d)));
echo(str("label tab ", tab_w, " x ", ledge_d, ", gusset leaves the wall at z = ",
         [for (h = bin_hs) tab_bot(h)],
         "; text sizes ", [for (s = labels) label_size(s)]));
if (wall_style == "hex")
    echo(str("wall hexes ", 2 * w_hw, " x ", wall_hex, " (regular), roofs bridge ", w_roof,
             "; holes per bin: ",
             [for (i = [0 : n_bins - 1]) len([for (w = bin_walls(i)) each wall_holes(w[2], w[4], bin_h(i))])]));

// ---------------- geometry ----------------

// Hex holes on a grid centred in [0,w] x [0,d]. A hole is kept if
// its centre lies inside the rectangle; the caller clips to it.
module hex_holes_2d(w, d) {
    dx = hex_p * cos(30);
    nx = ceil(w / dx / 2) + 1;
    ny = ceil(d / hex_p / 2) + 1;
    for (i = [-nx : nx], j = [-ny : ny]) {
        c = [w / 2 + i * dx, d / 2 + (j + (abs(i) % 2) / 2) * hex_p];
        if (c[0] >= 0 && c[0] <= w && c[1] >= 0 && c[1] <= d)
            translate(c) circle(r = hex_af / sqrt(3), $fn = 6);
    }
}

// Floor: the footprint, meshed inside a solid band. The band is
// floor_border inside a wall, key_band along an open side.
module floor_2d(i) {
    b = bin_box(i);
    m = [col(i) == 0 ? wall_t + floor_border : key_band,          // left
         wall_t + floor_border,                                    // right
         wall_t + floor_border,                                    // front
         row(i) == rows - 1 ? wall_t + floor_border : key_band];   // back
    zw = b[1] - b[0] - m[0] - m[1];
    zd = b[3] - b[2] - m[2] - m[3];
    difference() {
        translate([b[0], b[2]]) square([b[1] - b[0], b[3] - b[2]]);
        translate([b[0] + m[0], b[2] + m[2]])
            intersection() {
                square([zw, zd]);
                hex_holes_2d(zw, zd);
            }
    }
}

module wall_hole_2d() {
    circle(r = w_hw, $fn = 6);   // corners at +-u, flats top and bottom
}

module wall_holes_2d(L, tab_u, h) {
    for (c = wall_holes(L, tab_u, h)) translate(c) wall_hole_2d();
}

// w = [x, y, length, along, tab_u], from bin_walls(); h high
module wall(w, h) {
    difference() {
        translate([w[0], w[1], 0])
            cube(w[3] == 0 ? [w[2], wall_t, h] : [wall_t, w[2], h]);
        if (wall_style == "hex") {
            if (w[3] == 0)
                translate([w[0], w[1] + wall_t + EPS, 0])
                    rotate([90, 0, 0])         // 2D x -> X, 2D y -> Z, extrude -> -Y
                        linear_extrude(wall_t + 2 * EPS) wall_holes_2d(w[2], w[4], h);
            else
                translate([w[0] - EPS, w[1], 0])
                    rotate([90, 0, 90])        // 2D x -> Y, 2D y -> Z, extrude -> X
                        linear_extrude(wall_t + 2 * EPS) wall_holes_2d(w[2], w[4], h);
        }
    }
}

// Ledge profile in the YZ plane, extruded along X. The 45° gusset
// starts on the wall's outer plane, so it is buried in the wall
// until it emerges from the inner face at z = tab_bot.
module label_tab(i) {
    h = bin_h(i);
    translate([comp_cx(i) - tab_w / 2, bin_box(i)[2], 0])
        rotate([90, 0, 90])            // 2D x -> Y, 2D y -> Z, extrude -> X
            linear_extrude(tab_w)
                polygon([[0, tab_z0(h)], [ledge_d, tab_z0(h) + ledge_d],
                         [ledge_d, h], [0, h]]);
}

module label_text(i) {
    s = labels[i];
    translate([comp_cx(i), bin_box(i)[2] + ledge_d / 2, bin_h(i) - EPS])
        linear_extrude(text_h + EPS)
            intersection() {
                // never past the ledge edge: text there would hang in air
                square([tab_w - 1, ledge_d - 1], center = true);
                text(s, size = label_size(s), font = font,
                     halign = "center", valign = "center");
            }
}

// ---- joints ----
// Joint frame: x runs off the owner's face into the open bin, y along
// the face. Dovetail profiles carry on into the owner's wall by
// wall_t/2 so they fuse with it.
module joint_frame(normal, face) {
    if (normal == 0) translate([face, 0, 0]) children();
    else translate([0, face, 0]) rotate([0, 0, normal]) children();
}

module dovetail_2d(neck, head, d) {
    k = wall_t / 2;
    t = (head - neck) / (2 * d);
    polygon([[-k, -(neck / 2 - k * t)], [d, -head / 2], [d, head / 2], [-k, neck / 2 - k * t]]);
}
module rail_2d() dovetail_2d(rail_neck, rail_head, rail_d);
module key_2d()  dovetail_2d(key_neck, key_head, key_d);

// Full-height rail, narrowed at the top so a socket finds it.
module rail(h) {
    linear_extrude(h - rail_lead) rail_2d();
    hull() {
        translate([0, 0, h - rail_lead - EPS]) linear_extrude(EPS) rail_2d();
        translate([0, 0, h - EPS]) linear_extrude(EPS) offset(delta = -rail_taper) rail_2d();
    }
}

// Socket for the dovetail given as child, h tall: joint_clear all
// round, flared at the bed so the first layer's squish can't bind.
module socket_cut(h) {
    translate([0, 0, -EPS]) linear_extrude(h + 2 * EPS) offset(delta = joint_clear) children();
    hull() {
        translate([0, 0, -EPS]) linear_extrude(EPS)
            offset(delta = joint_clear + socket_flare) children();
        translate([0, 0, socket_flare]) linear_extrude(EPS) offset(delta = joint_clear) children();
    }
}

module post(h) {
    translate([0, -post_w / 2, 0]) cube([post_d, post_w, h]);
}

// Bands. A band above the bed grows out of the wall below it on a
// chamfer (post_cham, rail_cham), so it needs no support: a rail out
// of the owner's face, a post sideways out of the open bin's wall end
// (side: which side of the post that wall is on). The hull's slabs
// sit outside [z0 - cham, z0], so the slope is exactly cham high.
module rail_band(z0, z1) {
    translate([0, 0, z0]) rail(z1 - z0);
    if (z0 > 0)
        hull() {
            translate([0, 0, z0 - rail_cham - EPS]) linear_extrude(EPS)
                intersection() {        // the root, inside the owner's wall
                    rail_2d();
                    translate([-wall_t, -rail_head]) square([wall_t, 2 * rail_head]);
                }
            translate([0, 0, z0]) linear_extrude(EPS) rail_2d();
        }
}

module post_band(z0, z1, side) {
    zs = z0 > 0 ? z0 - post_cham_x : 0;     // the sideways chamfer ends here
    translate([0, 0, zs]) post(z1 - zs);
    if (z0 > 0)
        hull() {
            translate([0, side > 0 ? post_w / 2 - wall_t : -post_w / 2, zs - post_cham - EPS])
                cube([post_d, wall_t, EPS]);
            translate([0, -post_w / 2, zs]) cube([post_d, post_w, EPS]);
        }
}

// Cut under an upper post's far cheek (the side away from its wall),
// below a 42° slope rising from the socket's back at z0 - post_cham_x
// to its mouth at z0: the cheek grows out of the post's back instead
// of starting in mid-air. Only post lies in this region.
module post_relief(z0, side) {
    zb = z0 - post_cham_x - post_cham - 1;
    translate([0, side > 0 ? 0 : post_w / 2 + EPS, 0])
        rotate([90, 0, 0])                   // 2D x -> x, 2D y -> z, extrude -> -y
            linear_extrude(post_w / 2 + 2 * EPS)
                polygon([[-EPS, zb], [sock_back, zb], [sock_back, z0 - post_cham_x],
                         [-EPS, z0 + 1.1 * EPS]]);
}

// ---- bins ----
module bin_body(i) {
    for (w = bin_walls(i)) wall(w, bin_h(i));
    linear_extrude(floor_t) floor_2d(i);
    label_tab(i);
    for (J = joints) if (J[0] == i)                // owner: rails and keys
        joint_frame(J[2], J[3]) {
            for (r = J[4], z = bands(joint_h(J))) translate([0, r[0], 0]) rail_band(z[0], z[1]);
            for (s = J[5]) translate([0, s, 0]) linear_extrude(floor_t) key_2d();
        }
    for (J = joints) if (J[1] == i)                // open bin: posts round the sockets
        joint_frame(J[2], J[3])
            for (r = J[4], z = bands(joint_h(J))) translate([0, r[0], 0]) post_band(z[0], z[1], r[1]);
}

module bin(i) {
    color("LightSteelBlue")
        difference() {
            bin_body(i);
            for (J = joints) if (J[1] == i)
                joint_frame(J[2], J[3]) {
                    // full height: it only meets post and floor
                    for (r = J[4]) translate([0, r[0], 0]) {
                        socket_cut(bin_h(i)) rail_2d();
                        for (z = bands(joint_h(J))) if (z[0] > 0) post_relief(z[0], r[1]);
                    }
                    for (s = J[5]) translate([0, s, 0]) socket_cut(floor_t) key_2d();
                }
        }
    color("DarkSlateGray") label_text(i);
}

module tray(dy = 0) {
    for (i = [0 : n_bins - 1])
        translate([0, dy, 0]) bin(i);
}

// Every bin raised by its step in the assembly order, to show each
// one being lowered onto the ones already placed.
module tray_exploded() {
    for (i = [0 : n_bins - 1])
        translate([0, 0, search(i, ASM_ORDER)[0] * explode_step]) bin(i);
}

// Fit test, printed as laid out: the owner's wall with a rail and a
// key (left), and an open bin's wall end with its post, socket and
// key socket (right). Slide the right piece down onto the left one.
module joint_test() {
    ks = JT_L - 4 - key_sw / 2;     // key position along the face
    color("LightSteelBlue") {
        translate([-JT_GAP / 2, 0, 0]) {
            translate([-wall_t, 0, 0]) cube([wall_t, JT_L, JT_H]);
            translate([-JT_W, 0, 0]) cube([JT_W, JT_L, floor_t]);
            translate([0, post_w / 2, 0]) rail(JT_H);
            translate([0, ks, 0]) linear_extrude(floor_t) key_2d();
        }
        translate([JT_GAP / 2, 0, 0])
            difference() {
                union() {
                    cube([JT_W, JT_L, floor_t]);
                    cube([JT_W, wall_t, JT_H]);
                    translate([0, post_w / 2, 0]) post(JT_H);
                }
                translate([0, post_w / 2, 0]) socket_cut(JT_H) rail_2d();
                translate([0, ks, 0]) socket_cut(floor_t) key_2d();
            }
    }
}

// The shelf: door opening width x usable depth x height, back wall at
// y = tray_d (the tray is pushed to the back).
module shelf_ghost() {
    %translate([-opening_w / 2, tray_d - shelf_d, 0])
        cube([opening_w, shelf_d, shelf_h]);
}

// ---------------- render ----------------
if (part == "assembly") {
    tray();
    shelf_ghost();
}
else if (part == "assembly_pulled") {
    tray(-pull_dist);
    shelf_ghost();
}
else if (part == "assembly_exploded")
    tray_exploded();
else if (part == "joint_test")
    translate([0, -JT_L / 2, 0]) joint_test();   // centred on the bed
else if (bin_idx >= 0) {
    b = bin_box(bin_idx);
    translate([-(b[0] + b[1]) / 2, -(b[2] + b[3]) / 2, 0]) bin(bin_idx);   // centred on the bed
}
else
    assert(false, str("unknown part: ", part));
