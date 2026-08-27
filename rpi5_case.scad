// ============================================================
// rpi5_case.scad — Raspberry Pi 5 enclosure, sealed-port variant
//
// A two-piece case for a Raspberry Pi 5 fitted with the official
// Active Cooler.  The USB 3.0, USB 2.0, Ethernet, micro-HDMI and
// microSD openings are BLANKED OFF by default: those wall sections
// render as plain solid wall, so the board's data, display and card
// slots are physically inaccessible without opening the case.  Only
// the USB-C power inlet stays open.  Each blanked port is an
// independent flag, so any of them can be re-opened without touching
// geometry.
//
// The lid SNAPS into the base on four sprung posts at the corners —
// no screws, no inserts.  Each post is a Ø3 shaft split by a slot
// into two 10 mm cantilever legs with a barb at the tip; the barb
// squeezes through a neck in the base's corner boss and springs into
// a relief chamber below it.  The legs are long on purpose: at 0.35 mm
// deflection a 10 mm leg sees ~0.5% strain, well inside what PLA and
// PETG tolerate, where a short post would sit at ~2.5% and creep or
// snap off.  Set lid_fixing="screw" to fall back to M3 countersunk
// screws through the base floor instead.
//
// The lid carries a two-colour logo made the same way as
// logo_print.scad: a pocket is cut into the lid's top face and a plug
// of EXACTLY the same footprint is emitted as a separate object.
// Because both come from one 2D profile, they register by
// construction.  The profile comes from an SVG (logo_source="svg") or
// from native OpenSCAD text (logo_source="text", the default so this
// file renders standalone before an SVG exists).
//
// The lid prints TOP FACE DOWN.  That puts the logo pocket flat on the
// build plate, which is what makes the two-colour face crisp, and
// neither piece needs supports.  Nothing is mirrored: the model is
// built readable from +Z and the whole lid (pocket, plug and snap
// posts together) is rotated for printing.
//
// Cooling: a hex grille near the lid's microSD end, and a hex field in
// the floor under the PCB.  Both are laid out as tidy staggered blocks
// with a fixed cell count per row, so the edges come out straight.
// NOTE: the floor vents only breathe if the case is lifted off the
// desk — stick-on rubber feet.  Printed feet are not an option here:
// the base prints floor-down, so feet would leave the whole floor
// bridging in mid-air.
//
// Coordinate system:
//   Origin is the CENTRE of the PCB footprint in XY, and the OUTER
//   BOTTOM FACE of the case in Z.
//   X = board length (85 mm), Y = board width (56 mm), Z = up.
//   Board coordinates (origin at the microSD / USB-C corner, as used by
//   the Raspberry Pi mechanical drawing) are converted by bx()/by() so
//   port parameters can be typed straight off the datasheet.
//
//   Board edges, by face:
//     x = 0   -> microSD end        (blanked; lid grille sits over it)
//     x = 85  -> port face: 2x USB, Ethernet   (blanked)
//     y = 0   -> USB-C power, 2x micro-HDMI, power button
//     y = 56  -> 40-pin GPIO header edge
//
// Board geometry is MEASURED, not recalled — see the regression
// asserts at the end of this file.
//
// All units: millimetres.
//
// Export:
//   openscad -o rpi5_case_bottom.stl -D 'part="bottom"' rpi5_case.scad
//   openscad -o rpi5_case_top.stl    -D 'part="top"'    rpi5_case.scad
//   openscad -o rpi5_case_logo.stl   -D 'part="logo"'   rpi5_case.scad
//
// TWO COLOUR (logo_two_colour=true, the default).  The logo plug is emitted
// as its own object in the SAME coordinate frame as the pocket, so it drops
// in with no alignment work.  BOTH steps are required: --enable=lazy-union
// stops OpenSCAD unioning the three objects into one, and
// make_multipart_3mf.py then fuses the lid and plug into a single object
// with two COMPONENTS, which is what makes OrcaSlicer offer the plug its own
// filament.  Without --group=2,3 all three fuse and the base gets dragged
// into the lid's settings.
//   openscad --enable=lazy-union -o /tmp/raw.3mf -D 'part="printplate"' rpi5_case.scad
//   python3 make_multipart_3mf.py /tmp/raw.3mf rpi5_case.3mf --group=2,3
//   (build items are: 1 base, 2 lid, 3 logo plug)
//
// SINGLE COLOUR (logo_two_colour=false).  No plug; the logo is just a
// debossed pocket, and one step does it:
//   openscad --enable=lazy-union -o rpi5_case.3mf -D 'part="printplate"' -D 'logo_two_colour=false' rpi5_case.scad
// ============================================================

/* [View] */
part = "both";  // bottom | top | both | exploded | logo | printplate

/* [Logo] */
// "text" renders native OpenSCAD text so this file works standalone.
// "svg" imports logo_svg — the artwork must be CLOSED PATHS (outlines,
// not strokes); OpenSCAD ignores stroke width entirely, so a
// stroke-only SVG imports as nothing.
logo_source    = "svg";               // text | svg
// maivo-outlined-bold.svg is your artwork with the six spokes taken from
// stroke-width 10 to 14 and ALL strokes converted to paths.  Both changes
// are necessary: OpenSCAD ignores stroke entirely (a stroked SVG imports as
// nothing), and at 10 units the spokes come out 0.58 mm, below what a
// 0.4 mm nozzle resolves.  maivo-outlined.svg is the same file with the
// original 10-unit spokes if you prefer the lighter look.
logo_svg       = "maivo-outlined-bold.svg";
// Which part of the lockup to use.  "mark" crops to the roundel; "lockup"
// uses the whole thing including the wordmark.  See the stroke-width echo
// below before choosing - the lockup is 3.1:1, so fitting it to the panel
// shrinks it until the spokes stop printing.
logo_part_sel  = "mark";              // mark | lockup
logo_fit       = 55;                  // width in mm of whatever is selected
logo_two_colour = true;               // true = emit the plug as its own object
                                      // for a second filament; false = debossed only
// Artwork metrics in raw SVG units, measured off the file.
logo_view      = [3127, 1009];        // viewBox
logo_mark_x    = [0, 942];            // the roundel's x extent
logo_min_stroke_u = 14;               // thinnest stroke in the artwork (the spokes)
logo_text      = "PI 5";              // used when logo_source="text"
logo_font      = "DejaVu Sans:style=Bold";
logo_text_size = 13;                  // cap height (mm)
logo_pos       = [12, 0];             // XY centre on the lid, world coords
logo_rot       = 0;                   // degrees, about Z
logo_depth     = 0.8;                 // pocket depth = 4 layers @0.2mm, opaque
logo_plug_gap  = 0.0;                 // 2D offset on the plug; 0 = exact (MMU).
                                      // Use -0.15 for a hand-fitted separate print.

/* [Ports — true = BLANKED OFF (solid wall, no opening)] */
hide_usb3     = true;   // 2x USB 3.0 (blue), port face
hide_usb2     = true;   // 2x USB 2.0 (black), port face
hide_ethernet = true;   // Gigabit Ethernet, port face
hide_hdmi     = true;   // both micro-HDMI, power face
open_usbc     = true;   // USB-C power inlet
open_microsd  = false;  // microSD slot — closed by request
// The reference case cuts no button opening and I could not verify the
// button's position against anything, so this defaults off.
open_button   = false;  // side power button

/* [Port positions — board coords, mm] */
// USB-C and the micro-HDMI pair were measured off a known-good Pi 5
// case; see the asserts at the end.  The port-face entries only matter
// if a hide_* flag is turned off; measure before trusting them, and note
// that the Pi 5 swapped Ethernet and USB positions relative to the Pi 4.
usbc_x        = 11.2;          // centre, from x=0 edge
usbc_open     = [12.5, 6.7];   // opening [width, height], measured
hdmi0_x       = 25.8;
hdmi1_x       = 39.2;
hdmi_open     = [10.3, 6.6];
button_x      = 2.6;           // side power button centre — UNVERIFIED
button_d      = 3.5;
button_z      = 1.2;           // centre height above the PCB top face
port_drop     = 1.5;           // how far below the PCB top face openings start
port_r        = 1.5;           // corner radius on rectangular port openings
microsd_y     = 22.5;          // centre, from y=0 edge — UNVERIFIED, and
                               // reported misaligned on the printed part.
                               // Irrelevant while open_microsd = false.
microsd_open  = [15.0, 4.0];
eth_y         = 45.75;         // port face, centre from y=0 edge
eth_open      = [17.0, 15.5];
usb3_y        = 27.0;
usb2_y        = 9.0;
usb_open      = [16.0, 17.5];

/* [Board — Raspberry Pi 5] */
pcb_w         = 85.0;   // X
pcb_d         = 56.0;   // Y
pcb_t         = 1.4;
pcb_corner_r  = 3.0;
// The mounting holes are NOT centred on the board in X.  They sit
// hole_inset from the microSD end and 23.5 mm from the port end, so the
// pattern's centre is 10 mm toward the microSD end of the board centre.
// Computing them as +/- hole_dx/2 puts both standoffs 10 mm out and
// drags the whole board away from the port cutouts.
hole_inset    = 3.5;    // hole centres, from the x=0 end and from both Y edges
hole_dx       = 58.0;   // mounting hole pitch in X
hole_dy       = 49.0;   // mounting hole pitch in Y

/* [Cooling] */
cooler_h      = 15.5;   // height above the PCB TOP face (heatsink + fan)
air_gap       = 4.0;    // plenum between cooler top and lid underside
vent_cell     = 6.0;    // hex across-flats (mm)
vent_web      = 1.4;    // wall between cells (mm).  Thin walls are what make
                        // the field read as honeycomb rather than as a
                        // scattering of separate holes.
// Lid grille: a tidy block of rows near the microSD short edge.  Rows
// stack along X, cells run along Y.
lid_vent      = true;
lid_vent_rows = 3;
lid_vent_cols = 6;
lid_vent_x    = -35;    // band centre, world X
// Floor vents under the PCB.  Centred between the two standoff columns.
floor_vent      = true;
floor_vent_rows = 5;
floor_vent_cols = 7;
floor_vent_pos  = [-10, 0];   // block centre, world XY

/* [Shell] */
// side_gap also makes room for the corner snap bosses, which are a tight
// squeeze between the PCB's corner radius and the shell's outer radius.
// See the "corner boss fit" echo at the bottom of this file.
side_gap      = 7.0;    // clearance from PCB edge to cavity wall
wall          = 2.4;
floor_t       = 2.0;
lid_t         = 2.4;
cav_r         = 4.0;    // cavity corner radius
split_gap     = 5.5;    // minimum split height above the PCB top face
// The split must also leave real material over the tallest port opening.
// The first print had only 0.3 mm there and it was too thin.
port_cap_t    = 3.0;    // material above the tallest port opening

/* [Fasteners] */
lid_fixing    = "snap"; // snap | screw
standoff_d    = 7.0;    // board standoff outer diameter
standoff_h    = 6.5;    // clearance under the PCB
board_pilot_d = 2.1;    // self-tapping pilot for M2.5 board screws
floor_keep    = 1.0;    // solid floor left under the pilot
// The Active Cooler's spring push-pins occupy two of the four PCB
// mounting holes and their barbs expand BELOW the board.  Every standoff
// gets a relief counterbore so the board seats flat whichever pair the
// cooler uses; screw down the other two.
pin_relief_d  = 5.0;
pin_relief_h  = 3.0;
boss_d        = 9.0;    // corner boss — must clear snap_relief_d + 2 walls
boss_inset    = 3.85;   // boss centre, pulled in from the cavity corner

/* [Snap fit] */
// Barb squeezes through the neck, springs into the relief chamber, and
// its flat top shoulder catches on the neck's underside.
// Sized up from the first revision: thicker legs and a deeper barb give
// roughly 2.7x the retention force, and the longer leg keeps the strain
// LOWER than before despite the bigger deflection.  Retention force goes
// as leg_t^3 / leg_len^3, strain as leg_t * deflection / leg_len^2, so
// growing thickness and length together buys force without cost.
snap_neck_d    = 5.2;   // bore the barb squeezes through
snap_neck_h    = 10.4;  // = post length - barb height
snap_relief_d  = 6.6;   // chamber the barb springs into
snap_relief_h  = 2.5;
snap_post_d    = 4.4;   // shaft
snap_barb_d    = 6.0;   // barb outer; protrudes 0.4 mm past the neck
snap_barb_h    = 1.6;
snap_slot_w    = 1.2;   // splits the post into two cantilever legs
snap_lead      = 1.2;   // lead-in chamfer at the mouth of the neck

/* [Screws — only used when lid_fixing="screw"] */
lid_screw_d   = 3.4;
lid_head_d    = 6.2;
lid_pilot_d   = 2.6;
lid_pilot_h   = 12.0;
lid_screw_len = 28.0;

/* [Bumpers] */
// Shallow pockets in the four corners of the underside that locate
// self-adhesive rubber bumpers - the same ones handbag_desk_hook.scad
// uses.  The pocket only has to position the bumper, so it is 1 mm deep;
// the bumper's remaining 2 mm is what lifts the case and lets the floor
// honeycomb breathe.
bumpers          = true;
bumper_dia       = 10.0;  // bumper diameter (mm)
bumper_thickness = 3.0;   // bumper thickness (mm)
bumper_recess    = 1.0;   // pocket depth (mm)
bumper_clearance = 0.4;   // pocket oversize on diameter (mm)

/* [Joint] */
lip_t         = 1.2;    // lid spigot thickness
lip_h         = 4.0;    // lid spigot depth into the base
lip_clear     = 0.25;   // spigot-to-cavity clearance per side

/* [Ribs] */
// Board locating ribs.  Positions are board coords along each face,
// chosen to clear every opening.
rib_w         = 2.4;
rib_clear     = 0.25;   // slop between the rib face and the PCB edge
ribs_y0       = [20.0, 73.5];  // power face — clear of the USB-C opening
ribs_y1       = [12.0, 73.0];  // GPIO edge
ribs_x0       = [45.0];        // microSD end
ribs_x1       = [45.0];        // port face

/* [Quality] */
$fa = 1;    // max 360 facets per full circle
$fs = 0.4;  // matched to a 0.4 mm nozzle

eps = 0.01;

// ============================================================
// Derived
// ============================================================

cav_w  = pcb_w + 2 * side_gap;
cav_d  = pcb_d + 2 * side_gap;
out_w  = cav_w + 2 * wall;
out_d  = cav_d + 2 * wall;
out_r  = cav_r + wall;

pcb_z     = floor_t + standoff_h;             // PCB underside
pcb_top_z = pcb_z + pcb_t;
cav_top_z = pcb_top_z + cooler_h + air_gap;   // lid underside
case_h    = cav_top_z + lid_t;

function bx(x) = x - pcb_w / 2;
function by(y) = y - pcb_d / 2;

// Tallest port opening, and the split placed to clear it.
port_top_z = pcb_top_z - port_drop +
             max(open_usbc ? usbc_open[1] : 0, hide_hdmi ? 0 : hdmi_open[1],
                 hide_ethernet ? 0 : eth_open[1],
                 (hide_usb3 && hide_usb2) ? 0 : usb_open[1]);
split_z    = max(pcb_top_z + split_gap, port_top_z + port_cap_t);

// Corner boss centres, pulled in from the cavity corners along both axes.
boss_pts = [ for (sx = [-1, 1], sy = [-1, 1])
             [sx * (cav_w / 2 - boss_inset), sy * (cav_d / 2 - boss_inset)] ];

// PCB mounting hole centres, world XY.  X is built from the inset, not
// from a centred pitch.  Y genuinely is centred.
hole_pts = [ for (sx = [0, 1], sy = [-1, 1])
             [bx(hole_inset + sx * hole_dx), sy * hole_dy / 2] ];

// Logo sizing.  The import lands centred on its own bbox, so the roundel's
// centre sits logo_mark_cx off the origin in that frame.
logo_sel_w   = (logo_part_sel == "mark") ? logo_mark_x[1] - logo_mark_x[0]
                                         : logo_view[0];
logo_mark_cx = (logo_mark_x[0] + logo_mark_x[1]) / 2 - logo_view[0] / 2;
logo_svg_scale = logo_fit / logo_sel_w;
logo_h_mm      = logo_view[1] * logo_svg_scale;
logo_stroke_mm = logo_min_stroke_u * logo_svg_scale;

board_pilot_depth = floor_t + standoff_h - pin_relief_h - floor_keep;
board_screw_len   = pcb_t + pin_relief_h + board_pilot_depth;
snap_post_len     = snap_neck_h + snap_barb_h;
snap_bore_depth   = snap_neck_h + snap_relief_h;
is_snap           = (lid_fixing == "snap");

// ============================================================
// Primitives
// ============================================================

module rrect(w, d, r) {
    offset(r = r) offset(r = -r) square([w, d], center = true);
}

// A tidy staggered hex block: `rows` rows of cells, odd rows holding
// `cols` cells and even rows cols-1 sitting half a pitch in.  Every edge
// comes out straight, which a grid clipped to an outline does not.
//
// rot=30 is not cosmetic.  This lattice (dx = cell+web, dy = dx*sin60,
// alternate rows offset by dx/2) is the POINTY-TOP hex lattice, so the
// cells only tessellate into a true honeycomb when they are drawn
// pointy-top.  Drawn flat-top on the same lattice they overlap and the
// field reads as scattered holes instead of a comb.  A vertex at both 12
// and 6 o'clock also self-supports in a vertical wall either way up.
module hex_block(cols, rows, cell, web, rot = 30) {
    pitch = cell + web;
    py    = pitch * sin(60);
    rc    = cell / cos(30) / 2;
    for (j = [0 : rows - 1]) {
        n = (j % 2 == 0) ? cols : cols - 1;
        for (i = [0 : n - 1])
            translate([(i - (n - 1) / 2) * pitch, (j - (rows - 1) / 2) * py])
                rotate(rot) circle(d = 2 * rc, $fn = 6);
    }
}

// Gap between a circle of radius r at c and an axis-aligned rect.
function rect_gap(c, ctr, hw, hh, r) =
    let (dx = max(abs(c[0] - ctr[0]) - hw, 0), dy = max(abs(c[1] - ctr[1]) - hh, 0))
    norm([dx, dy]) - r;

// Outer size of that block, so it can be checked against obstacles.
function hex_block_w(cols, cell, web) = (cols - 1) * (cell + web) + cell / cos(30);
function hex_block_h(rows, cell, web) =
    (rows - 1) * (cell + web) * sin(60) + cell / cos(30);

// A rounded rectangular opening through a wall whose normal is Y.
// z0 = the opening's floor.
module port_y(cx, z0, size, t) {
    translate([cx, 0, z0 + size[1] / 2]) rotate([90, 0, 0])
        linear_extrude(height = t, center = true)
            rrect(size[0], size[1], port_r);
}

// The same, through a wall whose normal is X.
module port_x(cy, z0, size, t) {
    translate([0, cy, z0 + size[1] / 2]) rotate([90, 0, 90])
        linear_extrude(height = t, center = true)
            rrect(size[0], size[1], port_r);
}

// ============================================================
// Logo — one 2D profile drives both the pocket and the plug
// ============================================================

// dpi=25.4 makes one SVG user unit exactly 1 mm, so all the artwork
// metrics above can be typed in raw SVG units.  center=true centres on the
// artwork's own bounding box.
module logo_svg_raw() {
    import(file = logo_svg, center = true, dpi = 25.4);
}

// Whole lockup, or the roundel cropped out of it and re-centred.
module logo_svg_sel() {
    if (logo_part_sel == "mark")
        translate([-logo_mark_cx, 0]) intersection() {
            logo_svg_raw();
            translate([logo_mark_cx, 0])
                square([logo_sel_w + 60, logo_view[1] + 60], center = true);
        }
    else
        logo_svg_raw();
}

module logo_2d() {
    if (logo_source == "svg")
        scale(logo_svg_scale) logo_svg_sel();
    else
        text(logo_text, size = logo_text_size, font = logo_font,
             halign = "center", valign = "center");
}

module logo_placed_2d(grow = 0) {
    translate([logo_pos[0], logo_pos[1]]) rotate(logo_rot)
        offset(delta = grow) logo_2d();
}

module logo_cutter() {
    translate([0, 0, case_h - logo_depth])
        linear_extrude(height = logo_depth + eps) logo_placed_2d();
}

module logo_plug() {
    translate([0, 0, case_h - logo_depth])
        linear_extrude(height = logo_depth) logo_placed_2d(logo_plug_gap);
}

// ============================================================
// Port openings
// ============================================================
// Cut into BOTH halves.  Each half's own geometry clips the result.

module port_cuts() {
    // --- power face (y = 0 edge) ---
    translate([0, -(cav_d / 2 + wall / 2), 0]) {
        if (open_usbc)
            port_y(bx(usbc_x), pcb_top_z - port_drop, usbc_open, wall + 2 * eps);
        if (!hide_hdmi) {
            port_y(bx(hdmi0_x), pcb_top_z - port_drop, hdmi_open, wall + 2 * eps);
            port_y(bx(hdmi1_x), pcb_top_z - port_drop, hdmi_open, wall + 2 * eps);
        }
        if (open_button)
            translate([bx(button_x), 0, pcb_top_z + button_z])
                rotate([90, 0, 0])
                    cylinder(d = button_d, h = wall + 2 * eps, center = true);
    }
    // --- port face (x = 85 edge) ---
    translate([cav_w / 2 + wall / 2, 0, 0]) {
        if (!hide_ethernet) port_x(by(eth_y),  pcb_top_z - port_drop, eth_open, wall + 2 * eps);
        if (!hide_usb3)     port_x(by(usb3_y), pcb_top_z - port_drop, usb_open, wall + 2 * eps);
        if (!hide_usb2)     port_x(by(usb2_y), pcb_top_z - port_drop, usb_open, wall + 2 * eps);
    }
    // --- microSD end (x = 0 edge) ---
    // The card leaves from the PCB UNDERSIDE, so this opening straddles
    // the board rather than sitting on top of it.
    if (open_microsd)
        translate([-(cav_w / 2 + wall / 2), by(microsd_y),
                   pcb_z - microsd_open[1] / 2 + 0.4])
            rotate([0, 90, 0]) linear_extrude(height = wall + 2 * eps, center = true)
                rrect(microsd_open[1], microsd_open[0], port_r);
}

// ============================================================
// Base
// ============================================================

module standoffs() {
    for (p = hole_pts) translate([p[0], p[1], floor_t])
        difference() {
            cylinder(d = standoff_d, h = standoff_h);
            // relief for an Active Cooler push-pin barb
            translate([0, 0, standoff_h - pin_relief_h + eps])
                cylinder(d = pin_relief_d, h = pin_relief_h);
            // blind pilot for an M2.5 board screw
            translate([0, 0, floor_keep - floor_t])
                cylinder(d = board_pilot_d, h = board_pilot_depth + eps);
        }
}

module board_ribs() {
    h = pcb_top_z - floor_t;
    depth = side_gap - rib_clear;
    for (x = ribs_y0) translate([bx(x), -cav_d / 2, floor_t]) cube([rib_w, depth, h]);
    for (x = ribs_y1) translate([bx(x), pcb_d / 2 + rib_clear, floor_t]) cube([rib_w, depth, h]);
    for (y = ribs_x0) translate([-cav_w / 2, by(y), floor_t]) cube([depth, rib_w, h]);
    for (y = ribs_x1) translate([pcb_w / 2 + rib_clear, by(y), floor_t]) cube([depth, rib_w, h]);
}

module base_solid() {
    union() {
        difference() {
            linear_extrude(height = split_z) rrect(out_w, out_d, out_r);
            translate([0, 0, floor_t])
                linear_extrude(height = split_z) rrect(cav_w, cav_d, cav_r);
        }
        for (p = boss_pts) translate([p[0], p[1], floor_t])
            cylinder(d = boss_d, h = split_z - floor_t);
        standoffs();
        board_ribs();
    }
}

// Socket for one snap post: a lead-in chamfer, the neck the barb has to
// squeeze through, then the relief chamber it springs into.
module snap_socket() {
    translate([0, 0, split_z - snap_neck_h])
        cylinder(d = snap_neck_d, h = snap_neck_h + eps);
    translate([0, 0, split_z - snap_lead])
        cylinder(d1 = snap_neck_d, d2 = snap_neck_d + 2 * snap_lead,
                 h = snap_lead + eps);
    translate([0, 0, split_z - snap_bore_depth])
        cylinder(d = snap_relief_d, h = snap_relief_h + eps);
}

// Locating pockets for stick-on rubber bumpers, in the four corners of
// the underside.  Shallow enough to leave most of the floor intact.
module bumper_pockets() {
    for (p = boss_pts) translate([p[0], p[1], -eps])
        cylinder(d = bumper_dia + bumper_clearance, h = bumper_recess + eps);
}

module base_vents() {
    if (floor_vent)
        translate([floor_vent_pos[0], floor_vent_pos[1], -eps])
            linear_extrude(height = floor_t + 2 * eps)
                hex_block(floor_vent_cols, floor_vent_rows, vent_cell, vent_web);
}

module base() {
    difference() {
        base_solid();
        for (p = boss_pts) translate([p[0], p[1], 0]) {
            if (is_snap) snap_socket();
            else {
                // M3 clearance up through the column, countersunk flush with
                // the outer bottom face.  The cone narrows as it rises, so it
                // self-supports printing floor-down.
                translate([0, 0, -eps]) cylinder(d = lid_screw_d, h = split_z + 2 * eps);
                translate([0, 0, -eps])
                    cylinder(d1 = lid_head_d, d2 = lid_screw_d,
                             h = (lid_head_d - lid_screw_d) / 2 + eps);
            }
        }
        port_cuts();
        base_vents();
        if (bumpers) bumper_pockets();
    }
}


// ============================================================
// Lid
// ============================================================

module lid_spigot() {
    difference() {
        translate([0, 0, split_z - lip_h])
            linear_extrude(height = lip_h) difference() {
                rrect(cav_w - 2 * lip_clear, cav_d - 2 * lip_clear, cav_r);
                rrect(cav_w - 2 * lip_clear - 2 * lip_t,
                      cav_d - 2 * lip_clear - 2 * lip_t, max(cav_r - lip_t, 0.5));
            }
        for (p = boss_pts) translate([p[0], p[1], split_z - lip_h - eps])
            cylinder(d = boss_d + 2 * lip_clear, h = lip_h + 2 * eps);
    }
}

// One sprung post, hanging below the split face.  Read bottom-up: a
// narrow tip, a cone widening to the barb, then an abrupt step back to
// the shaft.  That step is a flat shoulder facing UP, and it is what
// catches on the underside of the neck once the barb has sprung into the
// relief chamber.  Tapering the cone the other way would give no lead-in
// and no retention at all.
module snap_post() {
    difference() {
        union() {
            translate([0, 0, split_z - snap_post_len])
                cylinder(d = snap_post_d, h = snap_post_len);
            translate([0, 0, split_z - snap_post_len])
                cylinder(d1 = snap_post_d, d2 = snap_barb_d, h = snap_barb_h);
        }
        translate([-snap_slot_w / 2, -(snap_barb_d / 2 + 1),
                   split_z - snap_post_len - eps])
            cube([snap_slot_w, snap_barb_d + 2, snap_post_len + 2]);
    }
}

module lid_solid() {
    union() {
        difference() {
            translate([0, 0, split_z])
                linear_extrude(height = case_h - split_z) rrect(out_w, out_d, out_r);
            translate([0, 0, split_z - eps])
                linear_extrude(height = cav_top_z - split_z + eps)
                    rrect(cav_w, cav_d, cav_r);
        }
        lid_spigot();
        for (p = boss_pts) translate([p[0], p[1], split_z])
            cylinder(d = boss_d, h = cav_top_z - split_z);
        if (is_snap)
            for (p = boss_pts) translate([p[0], p[1], 0]) snap_post();
    }
}

module lid_vents() {
    if (lid_vent)
        translate([lid_vent_x, 0, case_h - lid_t - eps])
            linear_extrude(height = lid_t + 2 * eps)
                rotate(90) hex_block(lid_vent_cols, lid_vent_rows, vent_cell, vent_web);
}

module lid_upright() {
    difference() {
        lid_solid();
        lid_vents();
        logo_cutter();
        port_cuts();
        if (!is_snap)
            for (p = boss_pts) translate([p[0], p[1], split_z - eps])
                cylinder(d = lid_pilot_d, h = lid_pilot_h + eps);
        // the lid owns everything above the split, except its snap posts
        difference() {
            translate([0, 0, -case_h]) linear_extrude(height = case_h + split_z)
                square([out_w * 3, out_d * 3], center = true);
            if (is_snap)
                for (p = boss_pts) translate([p[0], p[1], split_z - snap_post_len - 1])
                    cylinder(d = snap_barb_d + 2, h = snap_post_len + 1 + eps);
        }
    }
}

// Print orientation: top face down on the plate.  The pocket and the
// plug get the SAME transform, so they stay in registration.
module flip_for_print() {
    translate([0, 0, case_h]) rotate([180, 0, 0]) children();
}

module lid_print()       { flip_for_print() lid_upright(); }
module logo_print_part() { flip_for_print() logo_plug(); }

// ============================================================
// Render
// ============================================================

if (part == "bottom") {
    base();

} else if (part == "top") {
    lid_print();

} else if (part == "logo") {
    logo_print_part();

} else if (part == "both") {
    color("DimGray")   base();
    color("Gainsboro") lid_upright();
    color("Firebrick") logo_plug();

} else if (part == "exploded") {
    gap = 5;
    translate([0, -(out_d + gap) / 2, 0]) color("DimGray") base();
    translate([0,  (out_d + gap) / 2, 0]) {
        color("Gainsboro") lid_print();
        color("Firebrick") logo_print_part();
    }

} else if (part == "printplate") {
    // Three top-level objects for --enable=lazy-union, in this order:
    //   1 base, 2 lid, 3 logo plug.
    gap = 5;
    translate([0, -(out_d + gap) / 2, 0]) base();
    translate([0,  (out_d + gap) / 2, 0]) lid_print();
    if (logo_two_colour) translate([0, (out_d + gap) / 2, 0]) logo_print_part();
}

// ============================================================
// Fit report — printed on every render
// ============================================================

pcb_arc  = [pcb_w / 2 - pcb_corner_r, pcb_d / 2 - pcb_corner_r];
out_arc  = [out_w / 2 - out_r,        out_d / 2 - out_r];
b        = [cav_w / 2 - boss_inset,   cav_d / 2 - boss_inset];
gap_pcb  = norm([b[0] - pcb_arc[0], b[1] - pcb_arc[1]]) - pcb_corner_r - boss_d / 2;
gap_wall = out_r - norm([b[0] - out_arc[0], b[1] - out_arc[1]]) - boss_d / 2;
gap_stand = norm([b[0] - abs(hole_pts[0][0]), b[1] - hole_dy / 2])
            - (boss_d + standoff_d) / 2;
boss_wall = (boss_d - snap_relief_d) / 2;

// Snap leg strain: cantilever, eps = 3*t*y / (2*L^2).
leg_t     = (snap_post_d - snap_slot_w) / 2;
leg_defl  = (snap_barb_d - snap_neck_d) / 2;
leg_strain = 3 * leg_t * leg_defl / (2 * pow(snap_post_len, 2)) * 100;

// Vent blocks vs. the things they must not run into.  The floor block sits
// between the two standoff columns, so it is centred on the free region
// (x = -10), not on the case.
fv_hw = hex_block_w(floor_vent_cols, vent_cell, vent_web) / 2;
fv_hh = hex_block_h(floor_vent_rows, vent_cell, vent_web) / 2;
fv_gap = min([ for (h = hole_pts)
               rect_gap(h, floor_vent_pos, fv_hw, fv_hh, standoff_d / 2) ]);
// The lid block is rotated 90 degrees, so its rows run along X.
lv_hw = hex_block_h(lid_vent_rows, vent_cell, vent_web) / 2;
lv_hh = hex_block_w(lid_vent_cols, vent_cell, vent_web) / 2;
lv_gap = min([ for (b2 = boss_pts)
               rect_gap(b2, [lid_vent_x, 0], lv_hw, lv_hh, boss_d / 2) ]);

// Clear rectangle left on the lid's top face for the logo.
logo_margin = wall + 2;
logo_x0 = lid_vent_x + hex_block_h(lid_vent_rows, vent_cell, vent_web) / 2 + 2;
logo_x1 = out_w / 2 - logo_margin;
logo_y  = out_d / 2 - logo_margin;

echo(str("Case outer  : ", out_w, " x ", out_d, " x ", case_h, " mm"));
echo(str("Base height : ", split_z, " mm    Lid height: ", case_h - split_z, " mm"));
echo(str("Port cap    : ", split_z - port_top_z, " mm of material over the USB-C opening"));
echo(str("Boss->PCB   : ", gap_pcb,  " mm   Boss->shell: ", gap_wall,
         " mm   Boss->standoff: ", gap_stand, " mm  (all must be > 0)"));
echo(str("Boss wall   : ", boss_wall, " mm around the snap relief chamber"));
echo(str("Snap legs   : ", leg_t, " mm thick, ", snap_post_len, " mm long, ",
         leg_defl, " mm deflection -> ", leg_strain,
         " % strain  (keep under ~2 %)"));
echo(str("Board screws: 2x M2.5 pan head x ", board_screw_len,
         " mm max  -> ", board_pilot_depth,
         " mm of thread.  The other two holes take the cooler's push-pins."));
echo(str("Lid grille  : ", lid_vent_rows, " rows x ", lid_vent_cols, " cols, spanning X ",
         lid_vent_x - hex_block_h(lid_vent_rows, vent_cell, vent_web) / 2, " .. ",
         lid_vent_x + hex_block_h(lid_vent_rows, vent_cell, vent_web) / 2,
         ", Y +/-", hex_block_w(lid_vent_cols, vent_cell, vent_web) / 2));
echo(str("Floor vents : ", floor_vent_rows, " rows x ", floor_vent_cols, " cols, ",
         2 * fv_hw, " x ", 2 * fv_hh, " mm, clearing the standoffs by ",
         fv_gap, " mm"));
echo(str("Vent gaps   : lid grille clears the corner posts by ", lv_gap, " mm"));
echo(str("Logo        : ", logo_part_sel, " at ", logo_fit, " x ", logo_h_mm,
         " mm; thinnest stroke ", logo_stroke_mm, " mm",
         logo_stroke_mm >= 0.8 ? "  (good)"
       : logo_stroke_mm >= 0.5 ? "  *** thin - will print but weakly ***"
                               : "  *** TOO THIN - this feature will vanish ***"));
echo(str("Logo panel  : X ", logo_x0, " .. ", logo_x1,
         "   Y ", -logo_y, " .. ", logo_y, "  (", logo_x1 - logo_x0,
         " x ", 2 * logo_y, " mm)"));

// ============================================================
// Regression guard
// ============================================================
// Measured off a known-good Raspberry Pi 5 case
// ("RPi 5 case slim ports +6mm.stl"): mounting holes at world X -39.0 and
// +19.0 and Y +/-24.5, USB-C centred on world X -31.30, all in a frame
// whose origin is the board centre.  The first assert is the one that
// matters — an earlier revision computed the hole X pattern as centred on
// the board, which put both standoffs 10 mm out and made the ports miss.
assert(abs(bx(hole_inset) + 39.0) < 0.01 &&
       abs(bx(hole_inset + hole_dx) - 19.0) < 0.01,
       "Mounting hole X no longer matches the measured Pi 5 pattern (-39.0 / +19.0)");
assert(abs(hole_dy - 49.0) < 0.01 && abs(pcb_d / 2 - hole_dy / 2 - hole_inset) < 0.01,
       "Mounting hole Y no longer matches the measured Pi 5 pattern (+/-24.5)");
assert(abs(bx(usbc_x) + 31.30) < 0.05,
       "USB-C centre no longer matches the measured Pi 5 position (-31.30)");
assert(gap_pcb > 0.2 && gap_wall > 0.5 && gap_stand > 0.2,
       "Corner boss collides with the PCB, the shell or a standoff");
assert(boss_wall > 0.8,
       "Corner boss is too thin around the snap relief chamber - raise boss_d");
assert(!is_snap || leg_strain < 2.0,
       "Snap leg strain too high - lengthen the post or reduce the barb");
assert(split_z >= port_top_z + 0.5, "The split cuts through a port opening");
// The snap only works if the three diameters are in the right order:
// shaft slides in the neck, barb overlaps the neck enough to catch, and
// barb still fits inside the relief chamber.
assert(!is_snap || snap_post_d < snap_neck_d - 0.3,
       "Snap shaft binds in the neck - reduce snap_post_d or open snap_neck_d");
assert(!is_snap || snap_barb_d > snap_neck_d + 0.3,
       "Snap barb barely overlaps the neck - it will not retain the lid");
assert(!is_snap || snap_barb_d < snap_relief_d - 0.2,
       "Snap barb cannot fit the relief chamber - raise snap_relief_d");
assert(!is_snap || snap_relief_h > snap_barb_h + 0.5,
       "Relief chamber too shallow for the barb to spring into");
assert(!floor_vent || fv_gap > 1.0,
       "Floor vent block runs into a standoff - move floor_vent_pos or drop a column");
assert(!lid_vent || lv_gap > 1.0,
       "Lid grille runs into a corner post - reduce lid_vent_cols");
assert(!bumpers || bumper_recess < floor_t - 0.6,
       "Bumper pocket leaves too little floor under it");
assert(!bumpers || bumper_dia + bumper_clearance < 2 * (out_r - eps) ,
       "Bumper pocket is wider than the corner it sits in");
// Logo must fit the clear panel.  Only meaningful un-rotated.
assert(logo_source != "svg" || logo_rot != 0 ||
       (logo_pos[0] - logo_fit / 2 >= logo_x0 - 0.01 &&
        logo_pos[0] + logo_fit / 2 <= logo_x1 + 0.01 &&
        abs(logo_pos[1]) + logo_h_mm / 2 <= logo_y + 0.01),
       "Logo overruns the clear panel on the lid");
