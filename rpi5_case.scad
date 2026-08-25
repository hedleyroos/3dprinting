// ============================================================
// rpi5_case.scad — Raspberry Pi 5 enclosure, sealed-port variant
//
// A two-piece case for a Raspberry Pi 5 fitted with the official
// Active Cooler.  The USB 3.0, USB 2.0, Ethernet and micro-HDMI
// openings are BLANKED OFF by default: those wall sections render
// as plain solid wall, so the board's data and display ports are
// physically inaccessible without opening the case.  Only the
// USB-C power inlet, the microSD slot and the side power button
// stay open.  Each blanked port is an independent flag, so any of
// them can be re-opened later without touching geometry.
//
// The lid carries a two-colour logo made the same way as
// logo_print.scad: a pocket is cut into the lid's top face and a
// plug of EXACTLY the same footprint is emitted as a separate
// object.  Because both come from one 2D profile, they register by
// construction — no alignment work in the slicer.  The logo profile
// comes from an SVG (logo_source="svg") or from native OpenSCAD
// text (logo_source="text", the default so this file renders
// standalone before an SVG exists).
//
// The lid is held down by four M3 countersunk screws that run UP
// through the base floor into bosses in the lid, not down through the
// lid.  That keeps the show face completely unbroken — no screw heads
// competing with the logo, and the whole top plate is available for it
// — and it halves the screw length, since the fastener no longer has
// to span the full lid height.
//
// The lid prints TOP FACE DOWN.  That puts the logo pocket flat on
// the build plate, which is what makes the two-colour face crisp,
// and it means neither piece needs supports.  Nothing is mirrored:
// the model is built readable from +Z and the whole lid (pocket and
// plug together) is rotated for printing, so the physical part comes
// out the right way round.
//
// Cooling: the Active Cooler's fan draws air down through a hex
// intake grille in the lid directly above it, and the heatsink
// exhausts sideways through hex fields in the long walls.  Hex holes
// are used throughout because a regular hexagon has a vertex at both
// top and bottom, so it self-supports in a vertical wall at any size
// AND in either print orientation (same reasoning as
// mesh_box_eco.scad, which matters here because the base prints
// floor-down and the lid prints inverted).
//
// Coordinate system:
//   Origin is the CENTRE of the PCB footprint in XY, and the
//   OUTER BOTTOM FACE of the case in Z.
//   X = board length (85 mm), Y = board width (56 mm), Z = up.
//   Board coordinates (origin at the microSD / USB-C corner, as used
//   by the Raspberry Pi mechanical drawing) are converted by bx()/by()
//   so port parameters can be typed straight off the datasheet.
//
//   Board edges, by face:
//     x = 0   -> microSD end
//     x = 85  -> port face: 2x USB, Ethernet   (blanked by default)
//     y = 0   -> USB-C power, 2x micro-HDMI, power button
//     y = 56  -> 40-pin GPIO header edge
//
// All units: millimetres.
//
// Export:
//   openscad -o rpi5_case_bottom.stl -D 'part="bottom"' rpi5_case.scad
//   openscad -o rpi5_case_top.stl    -D 'part="top"'    rpi5_case.scad
//   openscad -o rpi5_case_logo.stl   -D 'part="logo"'   rpi5_case.scad
//
// Two-colour lid as a single multi-part 3MF (see make_multipart_3mf.py):
//   openscad --enable=lazy-union -o /tmp/raw.3mf -D 'part="printplate"' rpi5_case.scad
//   python3 make_multipart_3mf.py /tmp/raw.3mf rpi5_case.3mf --group=2,3
//   (build items are: 1 base, 2 lid, 3 logo plug; --group=2,3 fuses the
//    lid and its plug into one two-part object so OrcaSlicer offers the
//    plug its own filament, and leaves the base free-standing.)
// ============================================================

/* [View] */
part = "both";  // bottom | top | both | exploded | logo | printplate

/* [Logo] */
// "text" renders native OpenSCAD text so this file works standalone.
// "svg" imports logo_svg — the artwork must be CLOSED PATHS (outlines,
// not strokes); OpenSCAD ignores stroke width entirely, so a
// stroke-only SVG imports as nothing.
logo_source    = "text";              // text | svg
logo_svg       = "logo.svg";          // path, relative to this file
logo_svg_dpi   = 96;                  // SVG user units -> mm scaling basis
logo_scale     = 1.0;                 // uniform scale applied after import
logo_text      = "PI 5";              // used when logo_source="text"
logo_font      = "DejaVu Sans:style=Bold";
logo_text_size = 11;                  // cap height (mm)
logo_pos       = [27, 0];             // XY centre on the lid, world coords
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
open_microsd  = true;   // microSD slot, microSD end
// The reference case cuts NO button opening, and I could not verify the
// button's position against anything, so this defaults off.  Turning it on
// cuts a small hole at button_x — measure that first.
open_button   = false;  // side power button

/* [Port positions — board coords, mm. VERIFY against your board.] */
// USB-C, micro-HDMI, the power button and microSD are the ones that
// actually get cut with the defaults above.  The port-face entries
// only matter if a hide_* flag is turned off; measure before trusting
// them, and note that the Pi 5 swapped the Ethernet and USB positions
// relative to the Pi 4.
usbc_x        = 11.2;          // centre, from x=0 edge
usbc_open     = [12.5, 6.7];   // opening [width, height], measured off a real case
hdmi0_x       = 25.8;
hdmi1_x       = 39.2;
hdmi_open     = [10.3, 6.6];
button_x      = 2.6;           // side power button centre
button_d      = 3.5;           // tool access hole.  Kept small: at 5.5 it
                               // ran into the USB-C opening.
button_z      = 1.2;           // centre height above the PCB top face
port_drop     = 1.5;           // how far below the PCB top face the port
                               // openings start (connector bodies sit slightly
                               // proud of the board's top surface)
microsd_y     = 22.5;          // centre, from y=0 edge
microsd_open  = [15.0, 4.0];
eth_y         = 45.75;         // port face, centre from y=0 edge
eth_open      = [17.0, 15.5];
usb3_y        = 27.0;          // port face, centre of the blue stack
usb2_y        = 9.0;           // port face, centre of the black stack
usb_open      = [16.0, 17.5];

/* [Board — Raspberry Pi 5] */
pcb_w         = 85.0;   // X
pcb_d         = 56.0;   // Y
pcb_t         = 1.4;
pcb_corner_r  = 3.0;
// The mounting holes are NOT centred on the board in X.  They sit
// hole_inset from the microSD end and pcb_w - hole_inset - hole_dx
// (= 23.5 mm) from the port end, so the pattern's centre is 10 mm
// toward the microSD end of the board centre.  Computing them as
// +/- hole_dx/2 puts both standoffs 10 mm out and drags the whole board
// away from the port cutouts.  Verified against a known-good case STL —
// see the regression asserts at the end of this file.
hole_inset    = 3.5;    // hole centres, from the x=0 end and from both Y edges
hole_dx       = 58.0;   // mounting hole pitch in X
hole_dy       = 49.0;   // mounting hole pitch in Y

/* [Cooling — official Active Cooler] */
cooler_h      = 15.5;          // height above the PCB TOP face (heatsink + fan)
cooler_centre = [30.0, 28.0];  // board coords, over the SoC
cooler_size   = [40.0, 32.0];  // footprint the intake grille must cover
air_gap       = 4.0;           // plenum between cooler top and lid underside
vent_cell     = 4.5;           // hex across-flats (mm)
vent_web      = 1.4;           // ligament between hexes (mm)
// Which walls get exhaust.  NOT the power face: USB-C lives there, and a
// vent field wide enough to be useful merges into the port cutout and
// leaves one ragged slot.  The port face is a fully blanked solid wall
// once the USB / Ethernet / HDMI flags are set, and it faces the
// direction the cooler's fins discharge, so it is the better outlet.
vent_gpio     = true;          // long wall on the GPIO side (y+)
vent_port     = true;          // end wall on the port side (x+)
vent_power    = false;         // long wall carrying USB-C (y-)
side_vent_h   = 12.0;          // height of each side vent field.  Clamped
                               // per half to what the wall can hold; it must
                               // fit at least two WHOLE hex rows to be worth
                               // cutting (see the vent rows echo).
side_vent_f   = 0.60;          // vent field width as a fraction of the cavity

/* [Shell] */
side_gap      = 4.5;    // clearance from PCB edge to cavity wall.  Also what
                        // makes room for the corner screw bosses — see the
                        // "corner boss fit" echo at the bottom of this file.
wall          = 2.4;
floor_t       = 2.0;
lid_t         = 2.4;
cav_r         = 4.0;    // cavity corner radius
split_gap     = 5.5;    // how far the split sits above the PCB top face.
                        // Must clear the tallest port opening, or the split
                        // shaves a useless sliver off the top of it into the
                        // lid — see the port/split echo below.

/* [Fasteners] */
standoff_d    = 7.0;    // board standoff outer diameter.  Sized so the
                        // relief counterbore below still leaves a ~1 mm
                        // annulus for the PCB to seat on.
standoff_h    = 6.0;    // clearance under the PCB.  Deep enough that the
                        // relief counterbore below still leaves real material
                        // for the board screw to thread into.
board_pilot_d = 2.1;    // self-tapping pilot for M2.5 board screws
floor_keep    = 1.0;    // solid floor left under the pilot, so the screw
                        // cannot break out of the case's bottom face
// The Active Cooler's spring push-pins occupy two of the four PCB
// mounting holes, and their barbs expand BELOW the board.  Every
// standoff therefore gets a relief counterbore so the board seats flat
// whichever pair the cooler happens to use; screw down the other two.
pin_relief_d  = 5.0;
pin_relief_h  = 3.0;
// Lid screws: M3 countersunk, entering from UNDERNEATH.  They pass
// through the base's corner columns and thread into the lid's.
lid_screw_d   = 3.4;    // M3 clearance through the base column
lid_head_d    = 6.2;    // countersunk head, flush with the case bottom
lid_pilot_d   = 2.6;    // self-tapping pilot in the lid column
lid_pilot_h   = 12.0;   // pilot depth into the lid
lid_screw_len = 25.0;   // the screw you actually intend to use (reported below)
boss_d        = 6.0;
boss_inset    = 2.6;    // boss centre, pulled in from the cavity corner
lip_t         = 1.2;    // lid spigot thickness
lip_h         = 4.0;    // lid spigot depth into the base
lip_clear     = 0.25;   // spigot-to-cavity clearance per side

/* [Ribs] */
// Board locating ribs.  Positions are board coords along each face and
// are chosen to clear every opening AND the wall vent fields.
rib_w         = 2.4;
rib_clear     = 0.25;   // slop between the rib face and the PCB edge
ribs_y0       = [73.5, 82.5];  // power face — clear of USB-C, HDMI, button, vent
ribs_y1       = [12.0, 73.0];  // GPIO edge — outboard of the vent field
ribs_x0       = [45.0];        // microSD end — clear of the card slot
ribs_x1       = [50.0];        // port face — outboard of that wall's vent

/* [Quality] */
$fa = 1;    // max 360 facets per full circle
$fs = 0.4;  // matched to a 0.4 mm nozzle

eps = 0.01;

// ============================================================
// Derived
// ============================================================

cav_w  = pcb_w + 2 * side_gap;        // cavity inner size
cav_d  = pcb_d + 2 * side_gap;
out_w  = cav_w + 2 * wall;            // case outer footprint
out_d  = cav_d + 2 * wall;
out_r  = cav_r + wall;

pcb_z     = floor_t + standoff_h;             // PCB underside
pcb_top_z = pcb_z + pcb_t;
cav_top_z = pcb_top_z + cooler_h + air_gap;   // lid underside
case_h    = cav_top_z + lid_t;
split_z   = pcb_top_z + split_gap;

// Board coords -> world coords
function bx(x) = x - pcb_w / 2;
function by(y) = y - pcb_d / 2;

// Corner boss centres, pulled in from the cavity corners along both
// axes.  The corner is a tight squeeze between the PCB's corner radius
// and the shell's outer radius; see the fit echo at the end.
boss_pts = [ for (sx = [-1, 1], sy = [-1, 1])
             [sx * (cav_w / 2 - boss_inset), sy * (cav_d / 2 - boss_inset)] ];

// PCB mounting hole centres, world XY.  X is built from the inset, not
// from a centred pitch.  Y genuinely is centred: hole_inset and
// pcb_d - hole_inset are symmetric about the board's mid-line.
hole_pts = [ for (sx = [0, 1], sy = [-1, 1])
             [bx(hole_inset + sx * hole_dx), sy * hole_dy / 2] ];

vent_w   = cav_w * side_vent_f;   // long-wall field width (along X)
vent_w_x = cav_d * side_vent_f;   // end-wall field width  (along Y)

// Board screw: it drops through the PCB and the pin-relief counterbore
// before it meets any thread, so the usable pilot is what is left below.
board_pilot_depth = floor_t + standoff_h - pin_relief_h - floor_keep;
board_screw_len   = pcb_t + pin_relief_h + board_pilot_depth;
lid_screw_grip    = lid_screw_len - split_z;

// Tallest port opening, so the split can be checked against it.
port_top_z = pcb_top_z - port_drop +
             max(open_usbc ? usbc_open[1] : 0, hide_hdmi ? 0 : hdmi_open[1],
                 hide_ethernet ? 0 : eth_open[1],
                 (hide_usb3 && hide_usb2) ? 0 : usb_open[1]);

// Vent fields, clamped to the wall each half actually has, leaving 1 mm
// of solid wall above and below.
base_vent_h = min(side_vent_h, split_z - floor_t - 2);
lid_vent_h  = min(side_vent_h, cav_top_z - split_z - 2);
// How many WHOLE hex rows a field of height h can hold.
function hex_rows(h) =
    let (pitch_y = (vent_cell + vent_web) * sin(60), rc = vent_cell / cos(30) / 2)
    max(floor((h - 2 * rc) / pitch_y) + 1, 0);

// ============================================================
// Primitives
// ============================================================

module rrect(w, d, r) {
    offset(r = r) offset(r = -r) square([w, d], center = true);
}

// Is p inside a rounded rectangle of size w x d with corner radius r,
// both centred on the origin?
function in_rrect(p, w, d, r) =
    let (ax = abs(p[0]), ay = abs(p[1]), cx = w / 2 - r, cy = d / 2 - r)
    ax <= w / 2 && ay <= d / 2 &&
    (ax <= cx || ay <= cy || norm([ax - cx, ay - cy]) <= r);

// Staggered hex grid filling a w x d rounded rectangle.  Cells are kept
// only if they fit WHOLE inside the field — clipping the grid instead
// would leave sliver crescents around the border, which read as ragged
// and print as unsupported hairs.  rot=30 puts a vertex at both 12 and
// 6 o'clock, so a cell self-supports when cut through a vertical wall
// regardless of which way up the piece prints.
module hex_field_2d(w, d, cell, web, rot = 0) {
    pitch_x = cell + web;
    pitch_y = pitch_x * sin(60);
    r_circ  = cell / cos(30) / 2;                 // hex circumradius
    field_r = min(w, d) / 4;                      // field's own corner radius
    nx = ceil(w / pitch_x / 2) + 1;
    ny = ceil(d / pitch_y / 2) + 1;
    for (j = [-ny : ny], i = [-nx : nx]) {
        c = [i * pitch_x + (j % 2 == 0 ? 0 : pitch_x / 2), j * pitch_y];
        if (in_rrect(c, w - 2 * r_circ, d - 2 * r_circ,
                     max(field_r - r_circ, 0.01)))
            translate(c) rotate(rot) circle(d = 2 * r_circ, $fn = 6);
    }
}

// A vent field cut through a wall whose normal is Y.
module vent_wall_y(w, h, t) {
    rotate([90, 0, 0])
        linear_extrude(height = t, center = true)
            hex_field_2d(w, h, vent_cell, vent_web, rot = 30);
}

// The same, through a wall whose normal is X.  w runs along Y, h along Z.
module vent_wall_x(w, h, t) {
    rotate([90, 0, 90])
        linear_extrude(height = t, center = true)
            hex_field_2d(w, h, vent_cell, vent_web, rot = 30);
}

// A rectangular opening through a wall whose normal is Y.
// z0 = the opening's floor.
module port_y(cx, z0, size, t) {
    translate([cx, 0, z0 + size[1] / 2])
        cube([size[0], t, size[1]], center = true);
}

// The same, through a wall whose normal is X.
module port_x(cy, z0, size, t) {
    translate([0, cy, z0 + size[1] / 2])
        cube([t, size[0], size[1]], center = true);
}

// ============================================================
// Logo — one 2D profile drives both the pocket and the plug
// ============================================================

module logo_2d() {
    if (logo_source == "svg")
        scale(logo_scale) import(file = logo_svg, center = true, dpi = logo_svg_dpi);
    else
        scale(logo_scale)
            text(logo_text, size = logo_text_size, font = logo_font,
                 halign = "center", valign = "center");
}

module logo_placed_2d(grow = 0) {
    translate([logo_pos[0], logo_pos[1]]) rotate(logo_rot)
        offset(delta = grow) logo_2d();
}

// Pocket cutter: overshoots above the lid's top face for a clean cut.
module logo_cutter() {
    translate([0, 0, case_h - logo_depth])
        linear_extrude(height = logo_depth + eps) logo_placed_2d();
}

// Plug: exactly the pocket footprint, in the SAME world coordinates.
module logo_plug() {
    translate([0, 0, case_h - logo_depth])
        linear_extrude(height = logo_depth) logo_placed_2d(logo_plug_gap);
}

// ============================================================
// Port openings
// ============================================================
// Cut into BOTH halves.  Each half's own geometry clips the result, so
// an opening that straddles the split (the USB-C inlet does) comes out
// as a matching notch in each piece.

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
            cube([wall + 2 * eps, microsd_open[0], microsd_open[1]], center = true);
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
            // pilot for an M2.5 board screw — blind, stopping floor_keep
            // short of the outer bottom face
            translate([0, 0, floor_keep - floor_t])
                cylinder(d = board_pilot_d, h = board_pilot_depth + eps);
        }
}

// Ribs run from the cavity wall inward, stopping rib_clear short of the
// PCB edge, and rise to the PCB top face.
module board_ribs() {
    h = pcb_top_z - floor_t;
    depth = side_gap - rib_clear;
    for (x = ribs_y0) translate([bx(x), -cav_d / 2, floor_t])
        cube([rib_w, depth, h]);
    for (x = ribs_y1) translate([bx(x), pcb_d / 2 + rib_clear, floor_t])
        cube([rib_w, depth, h]);
    for (y = ribs_x0) translate([-cav_w / 2, by(y), floor_t])
        cube([depth, rib_w, h]);
    for (y = ribs_x1) translate([pcb_w / 2 + rib_clear, by(y), floor_t])
        cube([depth, rib_w, h]);
}

module base_solid() {
    union() {
        difference() {
            linear_extrude(height = split_z) rrect(out_w, out_d, out_r);
            translate([0, 0, floor_t])
                linear_extrude(height = split_z) rrect(cav_w, cav_d, cav_r);
        }
        // corner bosses, full height from the floor to the split face
        for (p = boss_pts) translate([p[0], p[1], floor_t])
            cylinder(d = boss_d, h = split_z - floor_t);
        standoffs();
        board_ribs();
    }
}

module base_vents() {
    if (vent_gpio || vent_port || vent_power) {
        z = (floor_t + split_z) / 2;
        if (vent_gpio)  translate([0,  cav_d / 2 + wall / 2, z])
                            vent_wall_y(vent_w, base_vent_h, wall + 2 * eps);
        if (vent_power) translate([0, -(cav_d / 2 + wall / 2), z])
                            vent_wall_y(vent_w, base_vent_h, wall + 2 * eps);
        if (vent_port)  translate([cav_w / 2 + wall / 2, 0, z])
                            vent_wall_x(vent_w_x, base_vent_h, wall + 2 * eps);
    }
}

module base() {
    difference() {
        base_solid();
        // M3 clearance up through each corner column, countersunk flush
        // with the outer bottom face.  The cone narrows as it rises, so
        // it self-supports printing floor-down.
        for (p = boss_pts) translate([p[0], p[1], 0]) {
            translate([0, 0, -eps]) cylinder(d = lid_screw_d, h = split_z + 2 * eps);
            translate([0, 0, -eps])
                cylinder(d1 = lid_head_d, d2 = lid_screw_d,
                         h = (lid_head_d - lid_screw_d) / 2 + eps);
        }
        port_cuts();
        base_vents();
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
        // clear the base's corner bosses
        for (p = boss_pts) translate([p[0], p[1], split_z - lip_h - eps])
            cylinder(d = boss_d + 2 * lip_clear, h = lip_h + 2 * eps);
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
        // corner columns, landing square on the base's bosses
        for (p = boss_pts) translate([p[0], p[1], split_z])
            cylinder(d = boss_d, h = cav_top_z - split_z);
    }
}

module lid_vents() {
    // intake grille directly over the Active Cooler
    translate([bx(cooler_centre[0]), by(cooler_centre[1]), case_h - lid_t - eps])
        linear_extrude(height = lid_t + 2 * eps)
            hex_field_2d(cooler_size[0], cooler_size[1], vent_cell, vent_web);
    if (vent_gpio || vent_port || vent_power) {
        z = (split_z + cav_top_z) / 2;
        if (vent_gpio)  translate([0,  cav_d / 2 + wall / 2, z])
                            vent_wall_y(vent_w, lid_vent_h, wall + 2 * eps);
        if (vent_power) translate([0, -(cav_d / 2 + wall / 2), z])
                            vent_wall_y(vent_w, lid_vent_h, wall + 2 * eps);
        if (vent_port)  translate([cav_w / 2 + wall / 2, 0, z])
                            vent_wall_x(vent_w_x, lid_vent_h, wall + 2 * eps);
    }
}

module lid_upright() {
    difference() {
        lid_solid();
        lid_vents();
        logo_cutter();
        port_cuts();
        // self-tapping pilot up into each corner column
        for (p = boss_pts) translate([p[0], p[1], split_z - eps])
            cylinder(d = lid_pilot_d, h = lid_pilot_h + eps);
        // the lid owns everything above the split
        translate([0, 0, -case_h]) linear_extrude(height = case_h + split_z)
            square([out_w * 3, out_d * 3], center = true);
    }
}

// Print orientation: top face down on the plate.  The pocket and the
// plug get the SAME transform, so they stay in registration.
module flip_for_print() {
    translate([0, 0, case_h]) rotate([180, 0, 0]) children();
}

module lid_print()      { flip_for_print() lid_upright(); }
module logo_print_part(){ flip_for_print() logo_plug(); }

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
    // Both pieces flat on the bed, back walls facing each other across a
    // 5 mm gap.  Footprint ~99 x 145 mm, well inside 270 x 270.
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
    translate([0,  (out_d + gap) / 2, 0]) logo_print_part();
}

// ============================================================
// Fit report — printed on every render
// ============================================================

// Corner boss fit.  The boss has to live in the gap between the PCB's
// corner radius and the shell's outer corner radius, measured along the
// 45-degree diagonal.  Both numbers below must stay positive.
pcb_arc  = [pcb_w / 2 - pcb_corner_r, pcb_d / 2 - pcb_corner_r];
out_arc  = [out_w / 2 - out_r,        out_d / 2 - out_r];
b        = [cav_w / 2 - boss_inset,   cav_d / 2 - boss_inset];
gap_pcb  = norm([b[0] - pcb_arc[0], b[1] - pcb_arc[1]]) - pcb_corner_r - boss_d / 2;
gap_wall = out_r - norm([b[0] - out_arc[0], b[1] - out_arc[1]]) - boss_d / 2;

// Clear rectangle left on the lid's top face for the logo: outboard of
// the intake grille, and inside a wall-thickness margin at the edges.
// Nothing else breaks the top plate, so this is the whole usable panel.
logo_margin = wall + 2;
logo_x0 = bx(cooler_centre[0]) + cooler_size[0] / 2 + 2;
logo_x1 = out_w / 2 - logo_margin;
logo_y  = out_d / 2 - logo_margin;

echo(str("Case outer  : ", out_w, " x ", out_d, " x ", case_h, " mm"));
echo(str("Base height : ", split_z, " mm    Lid height: ", case_h - split_z, " mm"));
echo(str("Boss->PCB   : ", gap_pcb,  " mm  (must be > 0)"));
echo(str("Boss->shell : ", gap_wall, " mm  (must be > 0)"));
echo(str("Lid screws  : 4x M3 countersunk x ", lid_screw_len, " mm  -> ",
         lid_screw_grip, " mm grip in the lid (pilot is ", lid_pilot_h,
         " mm; grip must be > 4 and < pilot)"));
echo(str("Board screws: 2x M2.5 pan head x ", board_screw_len,
         " mm max  -> ", board_pilot_depth,
         " mm of thread.  The other two holes take the cooler's push-pins."));
echo(str("Port/split  : tallest opening tops out at Z ", port_top_z,
         ", split is at ", split_z,
         split_z >= port_top_z ? "  (clear)"
                               : "  *** SPLIT CUTS THROUGH A PORT ***"));
echo(str("Vent rows   : base ", hex_rows(base_vent_h), " x ",
         hex_rows(lid_vent_h), " lid  (each must be >= 2)"));
echo(str("Logo panel  : X ", logo_x0, " .. ", logo_x1,
         "   Y ", -logo_y, " .. ", logo_y, "  (", logo_x1 - logo_x0,
         " x ", 2 * logo_y, " mm)"));

// ============================================================
// Regression guard
// ============================================================
// These positions were measured off a known-good Raspberry Pi 5 case
// ("RPi 5 case slim ports +6mm.stl"): mounting holes at world X -39.0 and
// +19.0, USB-C centred on world X -31.30, both in a frame whose origin is
// the board centre.  The first assert is the one that matters — an earlier
// revision computed the hole X pattern as centred on the board, which put
// both standoffs 10 mm out and made the port cutouts miss.
assert(abs(bx(hole_inset) + 39.0) < 0.01 &&
       abs(bx(hole_inset + hole_dx) - 19.0) < 0.01,
       "Mounting hole X no longer matches the measured Pi 5 pattern (-39.0 / +19.0)");
assert(abs(hole_dy - 49.0) < 0.01 && abs(pcb_d / 2 - hole_dy / 2 - hole_inset) < 0.01,
       "Mounting hole Y no longer matches the measured Pi 5 pattern (+/-24.5)");
assert(abs(bx(usbc_x) + 31.30) < 0.05,
       "USB-C centre no longer matches the measured Pi 5 position (-31.30)");
