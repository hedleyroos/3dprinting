// ============================================================
// epoxy_spike_stand.scad
//
// A finishing stand for epoxy-coating printed models.
//
// Coating a model with epoxy is a race against pot life: coat the
// bottom, flip, coat everything visible. The flipped model has to
// rest on something that touches it in as few and as small places
// as possible, high enough to keep hands, drips and the bench out
// of the way.
//
// THREE PARTS, all sharing one round plug interface:
//
//   Board — a 200 x 200 mm open grid. Ribs and a perimeter frame,
//     all the same height so the top is one continuous flat plane.
//     At every rib intersection sits a collar with a THROUGH hole.
//     64 sockets on a 25 mm pitch. Unchanged by the move to a
//     lying, obelisk tower: the plug is still round, so the board
//     did not have to be touched.
//
//   Tower — a 150 mm tapered OBELISK that plugs into any socket, so
//     you can put the contact points wherever the model needs them.
//     Square section, 12 mm at the board down to 1.2 mm at the tip.
//     Two tip styles (see `tip_style`).
//
//     It is an obelisk and not a spire because it prints LYING DOWN.
//     A 150 mm spire standing on an 8 mm plug is a 50 mm^2 first
//     layer under a 15:1 aspect ratio — the nozzle knocks it over,
//     and a print pad fixes adhesion without touching the leverage.
//     On its back the same tower has a ~1060 mm^2 contact patch and
//     nothing to topple. A square section is what makes that work:
//     each face of a tapered square prism is PLANAR, so one of them
//     lies flat on the bed along its whole length. A cone laid on its
//     side touches along a line, rolls, and needs support everywhere.
//
//   Foot — four short plugs pushed UP through the corner sockets
//     from below. They lift the board clear of the drip sheet so
//     curing epoxy cannot glue the board down. The foot reuses the
//     socket, so it costs the board nothing.
//
// The sockets are through holes, not pockets, and that is the whole
// point of them. Epoxy running down a tower falls straight through
// and onto the sheet below instead of pooling in the socket and
// cementing the tower in place. The bottom chamfer on each socket
// is there for the same reason — elephant's foot on a pocket mouth
// would catch exactly the debris you are trying to shed.
//
// Standalone — no external dependencies.
//
// Units: millimetres.
//
// Coordinate system:
//   Board — Z = 0 is the underside (the bed / the foot tops),
//     Z = rib_height is the top plane that towers seat on. X/Y
//     origin is the centre of the board.
//   Tower — `tower_part()` is built in ASSEMBLED coordinates:
//     Z = 0 is the board's top face, the plug runs down to
//     Z = -plug_length, and the tip is at Z = +tower_height. The
//     PRINT PLANE — the tower's flat back, and the flat milled off
//     the plug — is the plane x = -flat_offset.
//     `tower_printable()` tips that onto its back: the tower then
//     lies along +X with its back on Z = 0, tip at the origin.
//
// Part mapping (project convention names):
//   part="board"      -> the grid board, print orientation
//   part="tower"      -> one tower, print orientation
//   part="towers"     -> `tower_count` towers laid out for one job
//   part="foot"       -> one foot, print orientation
//   part="feet"       -> four feet laid out for one job
//   part="printplate" -> THE WHOLE STAND on the bed as SEPARATE
//                        objects: board, towers, feet, each already
//                        in print orientation. REQUIRES
//                        --enable=lazy-union
//   part="exploded"   -> the same bed layout, unioned and coloured,
//                        for previewing
//   part="both"       -> assembled, for fit checking
//   part="assembly"   -> feet dropped below and towers lifted off
//                        their sockets, showing how it goes together
//
// Every printable part is already in its print orientation — the
// board flat, the towers ON THEIR BACKS, the feet body down. There
// is nothing to rotate in the slicer. On the combined printplate the
// towers are additionally turned a quarter turn to run along Y,
// because lying down they are longer than the strip beside the board
// is wide.
//
// A note on OBJECTS. With --enable=lazy-union each statement in the
// render section becomes its own 3MF object, and the plate parts
// depend on that: the slicer has to be able to give the towers a
// brim and the board none. That only works if the geometry is
// emitted in the render branch itself. A `for` loop hidden behind a
// module call is a group node, and the whole plate arrives as ONE
// fused object — which looks fine on screen and is useless in the
// slicer. This is why the plate parts inline their loops and share
// layout through functions instead of modules.
//
// No make_multipart_3mf.py step is needed. That script exists to
// FUSE chosen objects into a single multi-material object; here
// every part is its own object in one filament, which is what a
// plain lazy-union export already gives.
//
// Printing notes:
//   - NOTHING needs supports, and that is checked rather than
//     assumed — see the Tower note below.
//   - Board: all vertical walls off a flat first layer. High wall
//     count, 0 % infill — a 2.4 mm rib is solid perimeters anyway.
//     ~91 cm^3 at the defaults. `rib_height` is the knob if that is
//     too much; it scales almost linearly.
//   - Tower: lies on its back, 162 x 12 x 12 mm, no brim and no
//     support. Verified support-free by checking every downward
//     facing facet in the exported mesh: the shallowest is 45.6
//     degrees from horizontal, and that is the strip either side of
//     the plug's flat. See the note on `flat_offset` for why the flat
//     is 1.2 mm deep and not 1.0.
//   - Tower: 5+ walls rather than infill, and slow outer walls. The
//     layers now run ALONG the tower rather than across it, so a
//     side load no longer pulls straight on a layer bond — lying
//     down is stronger in bending as well as easier to print. Print
//     spares anyway; towers are consumables, not heirlooms.
//   - Long thin parts curl at the ends. If the tip lifts, a 3 mm
//     brim on the towers alone fixes it.
//   - The taper is not cosmetic. As a slender column the tower
//     buckles under a tip load, and for a fixed-free column the mode
//     shape's curvature peaks at the BASE — so putting the material
//     there is what buys the margin. Computed by finite-difference
//     eigenvalue (validated to +0.02 % against the closed form for a
//     uniform cantilever), for PLA at 3.5 GPa:
//         12 -> 1.2 mm square, "point"   21.6 N   2.2 kg per tower
//         12 -> 3   mm square, "pad"    101   N  10.3 kg per tower
//         a uniform 1.2 mm square rod     0.5 N  0.05 kg per tower
//     Against ~150 g per tower under a 500 g model that is a 14x
//     margin on the sharp tip and 69x on the pad. The last line is
//     what the taper is buying.
//   - Cured epoxy bonds to PLA and releases from PETG and PP. Print
//     the towers in PETG if you have it, or wipe the tips with
//     paste wax. Either way treat them as sacrificial.
//   - Put foil or baking paper under the board. The feet keep the
//     board 12 mm clear of it.
//   - The drip ledge 25 mm below each tip stands off the shaft on
//     three sides, flush with the print face on the fourth. Standing
//     up its top is horizontal with a sharp outer edge, so epoxy
//     running down the shaft beads there and drops clear instead of
//     carrying on into the socket.
//
// Export (from /data4/projects/3dprinting):
//
//   EVERYTHING, one file, one job — board + towers + feet as
//   separate objects, all print-oriented. This is the one to use if
//   you want a single 3MF:
//     openscad --enable=lazy-union -o epoxy_spike_stand.3mf \
//              -D 'part="printplate"' epoxy_spike_stand.scad
//
//   WITHOUT the lazy-union flag OpenSCAD unions the lot and you get
//   one welded object: no per-part brim, no arranging, and the
//   towers inseparable from the board. Wrong, and quietly so.
//
//   Separate jobs — slower to set up, better prints. The towers
//   want slow outer walls and a high wall count; the board wants
//   neither and would just print slower for nothing:
//     openscad -o epoxy_spike_board.3mf -D 'part="board"' \
//              epoxy_spike_stand.scad
//     openscad --enable=lazy-union -o epoxy_spike_towers.3mf \
//              -D 'part="towers"' epoxy_spike_stand.scad
//     openscad --enable=lazy-union -o epoxy_spike_feet.3mf \
//              -D 'part="feet"' epoxy_spike_stand.scad
//
//   A cheap fit test before committing three hours to the board —
//   a 3 x 3 corner of it, plus one tower:
//     openscad -o /tmp/test_board.3mf -D 'part="board"' \
//              -D board_size=75 epoxy_spike_stand.scad
//     openscad -o /tmp/test_tower.3mf -D 'part="tower"' \
//              epoxy_spike_stand.scad
// ============================================================


/* [Quality] */
$fa = 1;   // Minimum angle — 1 deg gives max 360 facets per full circle
$fs = 0.4; // Minimum facet edge length (mm) — matched to a 0.4 mm nozzle


/* [Part Selection] */
part = "both";  // board | tower | towers | foot | feet | printplate | exploded | both | assembly


/* [Board] */
board_size    = 200;   // Outer size, square (X and Y)
rib_width     = 2.4;   // Internal rib thickness — 6 lines at 0.4 mm
rib_height    = 8;     // Grid thickness. Dominates print volume
frame_width   = 3.2;   // Perimeter frame thickness
corner_r      = 4;     // Outer corner radius


/* [Sockets] */
socket_pitch    = 25;   // Grid pitch. Sets how finely a tip can be placed
joint_dia       = 8.0;  // Plug diameter — the shared board/tower/foot interface
plug_clearance  = 0.4;  // Diametral slop in the socket. Loose on purpose:
                        // a socket with a little cured epoxy in it must
                        // still accept a plug
collar_dia      = 13;   // Outer diameter of the boss around each socket
socket_chamfer  = 0.6;  // Lead-in at BOTH ends of the through hole


/* [Tower] */
tower_height    = 150;  // Board top face to tip
tower_base_size = 12;   // Square cross-section where it meets the board
tower_shaft_top = 3;    // Cross-section where a "pad" tip takes over
plug_length     = 12;   // Plug engagement below the board top face
plug_chamfer    = 1.0;  // 45 deg lead-in on the plug's free end
plug_flat       = 1.2;  // Depth of the flat taken off the plug's print face.
                        // MUST stay under joint_dia / 2, or the flat misses
                        // the plug and the plug end prints in mid-air. And
                        // keep it at or above joint_dia/2*(1-cos45) = 1.17,
                        // which is what puts the flat's edge at 45 degrees —
                        // see the note on flat_offset
drip_collar     = true; // Runoff ledge near the tip
drip_step       = 2.5;  // How far the drip ledge stands off the shaft
drip_h          = 1.5;  // Drip ledge thickness
drip_below_tip  = 25;   // How far below the tip the ledge sits


/* [Tip] */
tip_style    = "point";  // point | pad
tip_size     = 1.2;      // "point": the square flat left at the tip. 3
                         // extrusion widths — smaller prints, but as a wisp
tip_pad_size = 6;        // "pad": flat contact across, for heavier models
tip_pad_len  = 3;        // "pad": length of the pad section


/* [Feet] */
foot_dia    = 20;  // Foot body diameter
foot_height = 12;  // How far the board is lifted off the drip sheet


/* [Bed Layout] */
bed_size      = 270;  // Printer bed, square
tower_count   = 6;    // Towers per plate for part="towers"
tower_spacing = 18;   // Lane pitch on the tower plates. Lying towers are
                      // only tower_base_size wide, so this can be tight
explode_gap   = 25;   // Lift/drop distance in the exploded view


// ============================================================
// DERIVED
// ============================================================

// --- Sockets and the grid -----------------------------------

socket_dia  = joint_dia + plug_clearance;
n_sockets   = floor(board_size / socket_pitch);
grid_span   = (n_sockets - 1) * socket_pitch;
board_top   = rib_height;

// Socket centre coordinate for a 0-based grid index.
function socket_pos(i) = -grid_span / 2 + i * socket_pitch;

frame_inner = board_size / 2 - frame_width;
inner_r     = max(0.5, corner_r - frame_width);

// Overlap forced into joints that would otherwise meet face to face.
// Two solids sharing an EXACTLY equal face is a degenerate union:
// CGAL can leave them as two separate shells with a coincident
// interface, which passes an edge-manifold check but is not one
// solid. Every weld below is hidden inside the larger solid, so it
// costs nothing geometrically.
weld = 0.2;

// How close to a socket centre a rib segment may come. Clear of the
// chamfered mouth by `weld` so the rib lands on solid collar and
// never roofs over the hole. Being clear of it matters as much as
// not intruding: setting this EQUAL to the chamfer radius makes the
// rib tangent to the chamfer circle, which produces a ring of
// zero-area triangles instead of a clean intersection.
socket_reach = socket_dia / 2 + socket_chamfer + weld;

// --- Tower --------------------------------------------------

// THE PRINT FACE, and why the tower is eccentric.
//
// The tower prints LYING DOWN, and for that to need no support its
// whole underside must lie in ONE plane. In assembled coordinates
// that plane is x = -flat_offset: the shaft's back face, and the
// flat taken off the plug, are the same plane.
//
// That forces the shaft off-axis, and it is not a preference. The
// plug's flat can only sit at f < joint_dia/2 from the plug axis, or
// it misses the plug. A shoulder to seat on the collar needs the
// shaft base to be at least as wide as the plug. A shaft symmetric
// about the plug axis would need base/2 = f < joint_dia/2 — a base
// NARROWER than the plug, so no shoulder. The two cannot both hold,
// so the shaft sits `tower_ecc` to one side and the tip lands a
// couple of mm off the socket axis.
//
// Which is no loss: the plug is round and free to rotate, so that
// offset tip swings around a small circle and can be aimed. The
// load eccentricity is ~2.4 mm on ~1.5 N — about 4 N mm, nothing.
// WHY THE FLAT IS 1.2 DEEP AND NOT LESS.
//
// The plug is a cylinder lying on its side, so its flanks between
// the flat's edge and its widest point face downward. On a cylinder
// of radius r whose flat sits f from the axis, the surface at the
// flat's edge slopes acos(f/r) from horizontal — and a slope under
// 45 degrees needs support. So f must be at most r*cos45, i.e. the
// flat at least r*(1-cos45) = 1.17 mm deep. At the default 1.2 the
// edge lands at 45.6 degrees and EVERY downward face on the tower is
// self-supporting. Shave the flat to 1.0 and a narrow strip along
// each side of the plug drops to 41 degrees.
//
// The cost is nothing: the flat widens to 5.7 mm and the arc still
// bearing in the socket only drops from 277 to 270 degrees.
flat_offset = joint_dia / 2 - plug_flat;
tower_ecc   = tower_base_size / 2 - flat_offset;

// The steepest downward slope anywhere on the plug, for the record.
plug_worst_slope = acos(flat_offset / (joint_dia / 2));

// A "pad" tip stops the taper early and finishes with a flat block;
// a "point" tip just runs the taper out to `tip_size`.
shaft_end = tip_style == "pad" ? tower_shaft_top : tip_size;
shaft_len = tower_height - (tip_style == "pad" ? tip_pad_len : 0);

// Assembled coordinates: Z = 0 is the board's top face.
drip_z = tower_height - drip_below_tip;

// Shaft cross-section at a given assembled Z, so the drip ledge can
// meet the taper exactly instead of floating or gapping.
function shaft_size_at(z) =
    tower_base_size + (shaft_end - tower_base_size) * z / shaft_len;

show_drip = drip_collar && drip_z > 5 && drip_z < shaft_len - 5;

// Lying down, the tower is this long on the bed.
tower_lay_len = tower_height + plug_length;

// --- Feet ---------------------------------------------------

// One millimetre short of the board thickness, so a foot plug never
// pokes up through the top plane and into the model's way.
foot_plug_length = rib_height - 1;

// --- Preview and bed layout ---------------------------------

// Four towers on an inset quad, and feet at the four corners.
pv_lo       = floor(n_sockets / 4);
pv_hi       = n_sockets - 1 - pv_lo;
preview_idx = [[pv_lo, pv_lo], [pv_hi, pv_lo], [pv_lo, pv_hi], [pv_hi, pv_hi]];
corner_idx  = [[0, 0], [n_sockets - 1, 0], [0, n_sockets - 1],
               [n_sockets - 1, n_sockets - 1]];

// Lying down, towers are long and thin, so they go in a single row
// side by side rather than a grid — no reason to stack them along
// their length and double the travel.
tow_size = [tower_lay_len,
            (tower_count - 1) * tower_spacing + tower_base_size];

feet_spacing = foot_dia + 10;
feet_size    = [3 * feet_spacing + foot_dia, foot_dia];

function tow_plate_xy(k) =
    [0, (k - (tower_count - 1) / 2) * tower_spacing];

function foot_plate_xy(k) = [(k - 1.5) * feet_spacing, 0];

// --- The combined print plate -------------------------------
//
// Board hard against one edge, everything else in the leftover
// strip: four feet in a 2 x 2 block at the near corner, towers in a
// single column above them. The strip is only as wide as the bed
// minus the board, so the tower count is DERIVED from what fits
// rather than taken from `tower_count` — see `plate_towers`.

plate_margin = 3;   // Bed edge keep-out
plate_gap    = 5;   // Between the board and the strip

plate_board_cx = -(bed_size / 2 - plate_margin - board_size / 2);
plate_strip_x0 = plate_board_cx + board_size / 2 + plate_gap;
plate_strip_x1 = bed_size / 2 - plate_margin;
plate_strip_cx = (plate_strip_x0 + plate_strip_x1) / 2;
plate_strip_w  = plate_strip_x1 - plate_strip_x0;

// In the strip the towers are TURNED A QUARTER TURN to run along Y:
// lying down they are `tower_lay_len` long, which no strip beside a
// 200 mm board could ever take across its width. So the strip's
// width sets how MANY fit, not how long they are.
plate_towers = max(0, floor((plate_strip_w - tower_base_size) / tower_spacing) + 1);
plate_tow_x0 = plate_strip_cx - (plate_towers - 1) * tower_spacing / 2;

// Towers hang from the top of the strip; the feet tuck in below the
// space they leave.
plate_tow_ytop = bed_size / 2 - plate_margin;
plate_tow_yend = plate_tow_ytop - tower_lay_len;

foot_pitch   = foot_dia + 6;
plate_foot_y = plate_tow_yend - plate_gap - foot_dia / 2;

// Towers run along +Y from the far end, so the tower's own origin
// (its tip) goes at the low-Y end of its lane.
function plate_tower_xy(k) = [plate_tow_x0 + k * tower_spacing, plate_tow_yend];
function plate_foot_xy(k)  = [plate_strip_cx + ((k % 2) - 0.5) * foot_pitch,
                              plate_foot_y - floor(k / 2) * foot_pitch];

plate_size = [plate_strip_x1 - (plate_board_cx - board_size / 2),
              plate_tow_ytop - (plate_foot_y - foot_pitch - foot_dia / 2)];


// ============================================================
// SANITY CHECKS
// ============================================================

assert(n_sockets >= 2,
       str("socket_pitch ", socket_pitch, " gives fewer than 2 sockets across a ",
           board_size, " mm board."));

assert(grid_span / 2 + collar_dia / 2 <= frame_inner,
       str("the outer socket collars reach ", grid_span / 2 + collar_dia / 2,
           " mm but the frame's inner face is at ", frame_inner,
           " mm. Reduce collar_dia or socket_pitch, or grow board_size."));

assert(socket_dia + 2 * socket_chamfer < collar_dia,
       str("the chamfered socket mouth is ", socket_dia + 2 * socket_chamfer,
           " mm across but the collar is only ", collar_dia,
           " mm. Grow collar_dia or shrink socket_chamfer."));

// The outermost rib line has to meet a STRAIGHT run of frame. Once
// the corner arc reaches in past that line, the frame's outer edge
// there is no longer at board_size/2 and a rib could break out
// through it.
assert(corner_r <= board_size / 2 - grid_span / 2,
       str("corner_r ", corner_r, " reaches past the outermost rib line at ",
           grid_span / 2, " mm. Keep it under ", board_size / 2 - grid_span / 2,
           " mm, or increase socket_pitch."));

assert(plug_flat > 0 && plug_flat < joint_dia / 2,
       str("plug_flat ", plug_flat, " must be between 0 and ", joint_dia / 2,
           ". At or above that the flat misses the plug entirely and the plug ",
           "end prints unsupported in mid-air."));

assert(tower_base_size >= joint_dia,
       str("tower_base_size ", tower_base_size, " is narrower than the plug (",
           joint_dia, " mm), so there is no shoulder to seat on the collar."));

assert(tower_base_size <= collar_dia,
       str("tower_base_size ", tower_base_size, " is wider than the socket ",
           "collar (", collar_dia, " mm), so the tower would rock on the rib ",
           "tops instead of seating on the collar."));

assert(tip_style == "point" || tip_style == "pad",
       str("Unknown tip_style: \"", tip_style, "\" — expected point | pad. ",
           "The old \"tripod\" is gone: its pins cannot print lying down, and ",
           "\"pad\" resists a model rocking at least as well."));

assert(shaft_end < tower_base_size,
       str("the shaft would not taper: it starts at ", tower_base_size,
           " mm and ends at ", shaft_end, " mm."));

assert(shaft_len > 20,
       str("tower_height ", tower_height, " leaves no shaft once a ",
           tower_height - shaft_len, " mm tip is taken off."));


// ============================================================
// SHARED PROFILES
// ============================================================

module rounded_rect_2d(w, d, r) {
    hull() for (sx = [-1, 1], sy = [-1, 1])
        translate([sx * (w / 2 - r), sy * (d / 2 - r)]) circle(r = r);
}


// ============================================================
// BOARD
// ============================================================

module board_frame() {
    linear_extrude(height = rib_height)
        difference() {
            rounded_rect_2d(board_size, board_size, corner_r);
            rounded_rect_2d(board_size - 2 * frame_width,
                            board_size - 2 * frame_width, inner_r);
        }
}

// Through hole, chamfered at both ends. The bottom chamfer is not
// cosmetic: it keeps elephant's foot out of the hole, and gives
// runoff a clean edge to leave from.
// Both chamfer cones run `weld` PAST the bore's radius rather than
// stopping level with it. Ending a cone exactly where it meets the
// bore leaves the two tangent along a circle, and since they are
// tessellated out of phase that circle comes out as a ring of
// near-degenerate horizontal slivers — measured 4736 of them, 2 mm^2
// all told, on a surface that should be a single sharp edge. Running
// each cone on into a region the bore already removes costs nothing
// and the slivers vanish. The 45 degree slope is preserved: an extra
// `weld` of height drops the radius by exactly `weld`.
module socket_cutter() {
    union() {
        translate([0, 0, -0.01])
            cylinder(h = rib_height + 0.02, d = socket_dia);
        translate([0, 0, rib_height - socket_chamfer - weld])
            cylinder(h = socket_chamfer + weld + 0.01,
                     d1 = socket_dia - 2 * weld,
                     d2 = socket_dia + 2 * socket_chamfer);
        translate([0, 0, -0.01])
            cylinder(h = socket_chamfer + weld + 0.01,
                     d1 = socket_dia + 2 * socket_chamfer,
                     d2 = socket_dia - 2 * weld);
    }
}

// A single pre-drilled collar. Every one of the 64 is geometrically
// identical, so OpenSCAD's geometry cache evaluates this ONCE and
// reuses it — which is the whole reason the board is built this way.
//
// The obvious construction — union the frame, full-length ribs and
// plain collars, then subtract all 64 sockets in one difference() —
// renders correctly but blows past OpenSCAD's CSG normalization
// limit, so F5 preview shows an EMPTY TREE. Drilling each collar in
// isolation and butting plain rib segments up against it keeps the
// normalized tree small, and there is no global difference() at all.
module socket_collar() {
    difference() {
        cylinder(h = rib_height, d = collar_dia);
        socket_cutter();
    }
}

module board_collars() {
    for (i = [0 : n_sockets - 1], j = [0 : n_sockets - 1])
        translate([socket_pos(i), socket_pos(j), 0]) socket_collar();
}

module rib_segment(x0, x1, y) {
    if (x1 - x0 > 0.01)
        translate([(x0 + x1) / 2, y, rib_height / 2])
            cube([x1 - x0, rib_width, rib_height], center = true);
}

// One line of rib segments per socket row: frame to first collar,
// collar to collar, last collar to frame. Segments stop at
// `socket_reach` so they overlap the collar ring without ever
// reaching over the hole, which would fill it back in.
//
// The outer segments die halfway INTO the frame rather than running
// out to the board edge. Running them to the edge makes their end
// faces coplanar with the board's outline, and clipping a coplanar
// face produces zero-area triangles — the same degeneracy as the
// tangent case above, and the reason no outline clip is needed here
// at all.
module board_rib_line(y) {
    frame_mid = frame_inner + frame_width / 2;
    rib_segment(-frame_mid, socket_pos(0) - socket_reach, y);
    rib_segment(socket_pos(n_sockets - 1) + socket_reach, frame_mid, y);
    for (i = [0 : n_sockets - 2])
        rib_segment(socket_pos(i) + socket_reach,
                    socket_pos(i + 1) - socket_reach, y);
}

// The board is square with one pitch, so the Y ribs are the X ribs
// turned a quarter turn.
module board_ribs() {
    for (j = [0 : n_sockets - 1]) board_rib_line(socket_pos(j));
    rotate([0, 0, 90])
        for (j = [0 : n_sockets - 1]) board_rib_line(socket_pos(j));
}

// No outline clip: every rib segment now ends inside the frame, so
// nothing can escape the outline in the first place. The frame is
// the outline. `assert_corner_clear()` keeps that true.
module board_part() {
    union() {
        board_frame();
        board_ribs();
        board_collars();
    }
}


// ============================================================
// TOWER
// ============================================================

// A square slab of side `s`, seated with its back face on the print
// plane and centred across it. Every cross-section of the tower is
// one of these, which is what keeps the back face planar.
module tower_slice(s, h) {
    translate([-flat_offset, -s / 2, 0]) cube([s, s, h]);
}

// The tapered shaft, as the convex hull of its two end sections. A
// hull of two rectangles gives four PLANAR faces: the back stays
// exactly on the print plane, the two sides are near-vertical walls,
// and the front is a gentle upward slope. Nothing faces downward
// except the back, which is on the bed.
module tower_shaft() {
    hull() {
        tower_slice(tower_base_size, 0.01);
        translate([0, 0, shaft_len - 0.01]) tower_slice(shaft_end, 0.01);
    }
}

// Round so it can rotate in the socket, with one flat so it has
// something to lie on. The flat is `plug_flat` deep, leaving ~277
// degrees of arc still bearing in the hole — positionally as good as
// a full cylinder.
//
// NO LEAD-IN CHAMFER HERE, unlike the foot. A cone on this end would
// narrow the plug to r = joint_dia/2 - plug_chamfer, which is less
// than the flat's own offset — so the flat would taper away to a
// KNIFE EDGE at the free end and the cone's underside would become a
// near-horizontal ceiling. Measured: ~83 mm^2 of 3-16 degree
// overhang, all of it here. The socket is already chamfered at both
// ends, so the plug's own lead-in was only ever belt and braces.
// The foot keeps its chamfer because its plug prints pointing UP,
// where a cone costs nothing.
//
// What is left is the band just above the flat, which starts at
// ~41 degrees from horizontal and steepens to vertical. At a 0.2 mm
// layer that band steps ~0.21 mm — a 45 degree effective overhang,
// anchored to the bed at the flat's edge. It self-supports.
module tower_plug() {
    difference() {
        translate([0, 0, -plug_length]) cylinder(h = plug_length, d = joint_dia);
        translate([-flat_offset - joint_dia, -joint_dia, -plug_length - weld])
            cube([joint_dia, 2 * joint_dia, plug_length + 2 * weld]);
    }
}

// A ledge standing off the shaft on three sides, flush with the
// print plane on the fourth. Standing up, its top face is horizontal
// and its outer edge is sharp, so runoff beads there and drops clear
// instead of carrying on down into the socket. Printing, every face
// is either a vertical wall or an upward slope.
module tower_drip_ledge() {
    s = shaft_size_at(drip_z);
    translate([-flat_offset, -(s / 2 + drip_step), drip_z])
        cube([s + drip_step, s + 2 * drip_step, drip_h]);
}

// The pad tip grows the section back out at the very end. Growing
// toward the tip is free: the step faces along the length, which is
// a vertical wall lying down.
module tower_tip_pad() {
    translate([0, 0, shaft_len]) tower_slice(tip_pad_size, tip_pad_len);
}

// Assembled coordinates: Z = 0 is the board's top face, the tip is
// at Z = tower_height, and the plug hangs below Z = 0.
module tower_part() {
    union() {
        tower_plug();
        tower_shaft();
        if (show_drip)              tower_drip_ledge();
        if (tip_style == "pad")     tower_tip_pad();
    }
}

// PRINT ORIENTATION: laid on its back face, tip at the origin,
// running along +X. No print pad and no brim — the back face is a
// ~1000 mm^2 contact patch, so there is nothing left to fall over.
module tower_printable() {
    translate([tower_height, 0, flat_offset])
        rotate([0, -90, 0])
            tower_part();
}


// ============================================================
// FOOT
// ============================================================

// Print orientation and use orientation differ only by where they
// sit: the foot prints body-down, plug up, which is also how it goes
// into the board. The chamfer is on the plug's free end, pointing
// up, so it self-supports.
module foot_part() {
    union() {
        cylinder(h = foot_height, d = foot_dia);
        translate([0, 0, foot_height])
            cylinder(h = foot_plug_length - plug_chamfer, d = joint_dia);
        translate([0, 0, foot_height + foot_plug_length - plug_chamfer])
            cylinder(h = plug_chamfer,
                     d1 = joint_dia, d2 = joint_dia - 2 * plug_chamfer);
    }
}


// ============================================================
// BED LAYOUTS AND ASSEMBLIES
// ============================================================

// Only the layout parts care whether something fits, so this is a
// module rather than a top-level assert — exporting one tower must
// not be blocked by a plate it never uses.
module assert_bed_fits(size, what) {
    assert(size[0] <= bed_size && size[1] <= bed_size,
           str(what, " is ", size[0], " x ", size[1], " mm on a ", bed_size,
               " mm bed. Reduce it, or split it across print jobs."));
}

// LAYOUT MODULES DELIBERATELY DO NOT EXIST for the plate parts.
//
// With --enable=lazy-union, each statement in the render branch
// becomes its own 3MF object — but only if the geometry is emitted
// THERE. Wrapping a `for` loop in a module makes it a group node,
// and the whole plate collapses into a single fused object that the
// slicer cannot arrange or configure per part. Verified: an
// if-wrapped bare `for` yields N objects, the same loop behind a
// module call yields 1.
//
// So the plate parts inline their loops in the render section, and
// the shared layout lives in the `*_xy(k)` functions above, which
// emit no geometry and are safe to share.

module assert_plate_fits() {
    assert_bed_fits(plate_size, "the combined print plate");
    assert(plate_strip_w >= tower_base_size,
           str("the strip beside the board is ", plate_strip_w,
               " mm but a tower lane needs ", tower_base_size,
               " mm. Shrink board_size, or print part=\"towers\" separately."));
    assert(tower_lay_len <= bed_size - 2 * plate_margin,
           str("a tower is ", tower_lay_len, " mm lying down, which will not fit ",
               "along a ", bed_size, " mm bed. Reduce tower_height."));
    assert(plate_strip_w >= foot_pitch + foot_dia,
           str("the strip beside the board is ", plate_strip_w,
               " mm but two columns of feet need ", foot_pitch + foot_dia,
               " mm. Shrink board_size or foot_dia."));
    assert(plate_towers >= 1,
           str("no room for even one tower beside the board. Shrink ",
               "board_size, or print part=\"towers\" separately."));
}

// Board sitting on its feet, towers seated in an inset quad of
// sockets. `lift` and `drop` produce the exploded variant from the
// same placement code.
module stand_assembly(lift = 0, drop = 0) {
    color("Gainsboro")
        translate([0, 0, foot_height]) board_part();

    color("DimGray")
        for (c = corner_idx)
            translate([socket_pos(c[0]), socket_pos(c[1]), -drop]) foot_part();

    color("SteelBlue")
        for (p = preview_idx)
            translate([socket_pos(p[0]), socket_pos(p[1]),
                       foot_height + board_top + lift])
                tower_part();
}


// ============================================================
// RENDER
// ============================================================

if (part == "board") {
    assert_bed_fits([board_size, board_size], "the board");
    board_part();

} else if (part == "tower") {
    tower_printable();

// One job's worth of towers, each its own object. Needs
// --enable=lazy-union; see the note above assert_plate_fits().
} else if (part == "towers") {
    assert_bed_fits(tow_size, "the tower plate");
    for (k = [0 : tower_count - 1])
        translate([tow_plate_xy(k)[0], tow_plate_xy(k)[1], 0]) tower_printable();

} else if (part == "foot") {
    foot_part();

} else if (part == "feet") {
    assert_bed_fits(feet_size, "the foot plate");
    for (k = [0 : 3])
        translate([foot_plate_xy(k)[0], foot_plate_xy(k)[1], 0]) foot_part();

// THE WHOLE STAND IN ONE JOB. Board, `plate_towers` towers and four
// feet, each already in print orientation, each its own object.
// Export with --enable=lazy-union or they fuse into one lump.
//
// The towers are turned a quarter turn here to run along Y — lying
// down they are longer than any strip beside a 200 mm board is wide.
//
// This is a far better single-job prospect than it was when the
// towers stood up: nothing on the plate is taller than
// tower_base_size, so there is no slender column for a travel move
// to catch. Separate jobs are still marginally better — the towers
// want slow outer walls and a high wall count, which the board does
// not — but not by much any more.
} else if (part == "printplate") {
    assert_plate_fits();
    echo(str("printplate: board + ", plate_towers, " towers + 4 feet on a ",
             bed_size, " mm bed. tower_count=", tower_count,
             " is ignored here — the strip beside the board holds ",
             plate_towers, ". Export with --enable=lazy-union."));
    translate([plate_board_cx, 0, 0]) board_part();
    for (k = [0 : plate_towers - 1])
        translate([plate_tower_xy(k)[0], plate_tower_xy(k)[1], 0])
            rotate([0, 0, 90]) tower_printable();
    for (k = [0 : 3])
        translate([plate_foot_xy(k)[0], plate_foot_xy(k)[1], 0]) foot_part();

// The same bed layout, coloured and unioned, for eyeballing the
// arrangement without exporting.
} else if (part == "exploded") {
    assert_plate_fits();
    color("Gainsboro") translate([plate_board_cx, 0, 0]) board_part();
    color("SteelBlue")
        for (k = [0 : plate_towers - 1])
            translate([plate_tower_xy(k)[0], plate_tower_xy(k)[1], 0])
                rotate([0, 0, 90]) tower_printable();
    color("DimGray")
        for (k = [0 : 3])
            translate([plate_foot_xy(k)[0], plate_foot_xy(k)[1], 0]) foot_part();

} else if (part == "both") {
    stand_assembly();

// Feet dropped out below, towers lifted off their sockets — shows
// that the feet go in from UNDERNEATH, which is not obvious from the
// assembled view.
} else if (part == "assembly") {
    stand_assembly(lift = explode_gap, drop = explode_gap);

} else {
    assert(false, str("Unknown part: \"", part,
                      "\" — expected board | tower | towers | foot | feet | ",
                      "printplate | exploded | both | assembly"));
}
