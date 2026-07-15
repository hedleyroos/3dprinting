// ============================================================
// Socket Cover — removable wall-socket housing
//
// Hides an ugly wall socket behind a vented, removable box that
// hangs on two wall-mounted rails (like a French cleat / coat hook):
// hooks on the inside of the cover drape over each rail's ledge and
// gravity holds it in place. Lift straight up to remove.
//
//   * Front, left and right faces: solid.
//   * Top and bottom faces: diamond-vented for cooling. Diamond
//     holes are self-supporting (45 deg faces) when printed upright.
//   * Bottom face also has a cutout (left side) for a South African
//     3-pin plug to pass through.
//   * Back: fully open (against the wall).
//   * Two identical wall rails, each keyhole-mounted to the wall.
//     The upper rail is load-bearing (the cover's hooks drape over
//     it); the lower rail is a locating/anti-swing standoff only —
//     no hook engages it in this first pass.
//
// FIRST PASS: the 400 mm wide cover exceeds a typical ~270 mm bed.
// Print-splitting is deferred to a later iteration (see part=
// "exploded", which only lays out the two rails).
//
// Coordinate system (mm, origin at the centre of the open back):
//   X = width      (-box_w/2 .. +box_w/2)
//   Y = depth      (0 = wall / open back .. +box_d = front face)
//   Z = height     (0 = floor .. +box_h = top)
// The plug cutout sits on the -X (left) side of the bottom face.
// ============================================================

/* [Quality] */
$fa = 1;   // Minimum angle - 1 deg gives max 360 facets per full circle
$fs = 0.4; // Minimum facet edge length (mm) - matched to a 0.4 mm nozzle

/* [Cover Envelope] */
box_w  = 400; // Overall width (mm) - matches sketch
box_d  = 80;  // Overall depth / wall stand-off (mm)
box_h  = 300; // Overall height (mm) - matches sketch
wall_t = 3;   // Wall thickness (mm)

/* [Ventilation - top & bottom] */
vent_hole_d      = 26; // Diamond hole full diagonal (mm) - self-supporting at 45 deg
vent_spacing     = 34; // Staggered grid pitch (mm)
vent_rim         = 10; // Solid margin at the panel's front/back edges (mm)
vent_side_margin = 14; // Solid margin at the panel's left/right edges (mm)

/* [Plug Cutout - bottom, left] */
plug_cut_w        = 70; // Cutout width, X span (mm) - SA 3-pin plug body
plug_cut_d        = 55; // Cutout depth, Y span (mm)
plug_cut_margin_x = 15; // Inset from the left edge (mm)

/* [Wall Rails] */
rail_len        = 250; // Length of each rail (mm)
rail_web_t      = 5;   // Mounting web thickness, flush to the wall (mm)
rail_web_h      = 50;  // Mounting web height (mm) - holds the keyhole slots
rail_reach      = 14;  // Ledge bar projection from the wall (mm)
rail_h          = 8;   // Ledge bar height (mm) - surface the hooks drape over
rail_upper_drop = 30;  // Upper rail: drop from the cover's inside-top to the ledge top (mm)
rail_lower_z    = 40;  // Lower rail: recommended ledge-top height off the floor (mm) -
                        // locating / anti-swing only, no hook engages it yet.

/* [Keyhole Mounting] */
keyhole_head_d   = 9;   // Screw head clearance (mm) - e.g. M4 pan head
keyhole_shank_d  = 4.5; // Screw shank clearance (mm)
keyhole_slot_len = 14;  // Slide travel of the slot (mm)
keyhole_inset    = 40;  // Distance of each keyhole from the rail's ends (mm)

/* [Hooks] */
hook_w     = 20;  // Hook width, X (mm)
hook_inset = 50;  // Hook centre distance in from each side wall's inner face (mm)
hook_t     = 4;   // Hook material thickness (mm)
hook_clear = 0.6; // Fit clearance around the rail's ledge bar (mm)

/* [Part Selection] */
part = "both"; // cover | rail | both | exploded

// ============================================================
// Derived
// ============================================================
half_w      = box_w / 2;
top_inner_z = box_h - wall_t;        // Underside of the top panel
rail_top_z  = top_inner_z - rail_upper_drop; // Global Z of the upper rail's ledge top
rail_bot_z  = rail_top_z - rail_h;
hook_x      = half_w - wall_t - hook_inset; // +/- X position of the two hooks

echo(str("Cover envelope: ", box_w, " x ", box_d, " x ", box_h, " mm (w x d x h)"));
echo(str("Upper rail ledge-top height off floor: ", rail_top_z, " mm"));
echo(str("Lower rail ledge-top height off floor: ", rail_lower_z, " mm"));
echo(str("Rail keyhole spacing: ", 2 * (rail_len / 2 - keyhole_inset), " mm"));
echo(str("Hook fit clearance around ledge bar: ", hook_clear, " mm"));
if (box_w > 270 || box_h > 270)
    echo("NOTE: cover exceeds a ~270 mm bed - print-splitting deferred to a later iteration.");

// ============================================================
// MODULES - all geometry is defined locally (standalone file)
// ============================================================

// One diamond vent stamp, centred at the origin.  45 deg faces are
// self-supporting when the panel prints with this face upright/flat.
module vent_hole_2d() {
    rotate(45) square(vent_hole_d / sqrt(2), center = true);
}

// Solid panel (w x d) with a staggered diamond vent grid, margins kept
// solid at every edge.
module panel_vent_2d(w, d) {
    difference() {
        square([w, d], center = true);

        xs = -w / 2 + vent_side_margin + vent_hole_d / 2;
        xe =  w / 2 - vent_side_margin - vent_hole_d / 2;
        ys = -d / 2 + vent_rim + vent_hole_d / 2;
        ye =  d / 2 - vent_rim - vent_hole_d / 2;

        rows = floor((ye - ys) / vent_spacing) + 1;
        for (row = [0 : rows - 1]) {
            y = ys + row * vent_spacing;
            stagger = (row % 2 == 0) ? 0 : vent_spacing / 2;
            for (x = [xs + stagger : vent_spacing : xe])
                translate([x, y]) vent_hole_2d();
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
            panel_vent_2d(box_w, box_d);
}

module bottom_panel() {
    translate([0, box_d / 2, 0])
        linear_extrude(height = wall_t)
            difference() {
                panel_vent_2d(box_w, box_d);
                translate([-half_w + plug_cut_margin_x + plug_cut_w / 2, 0])
                    square([plug_cut_w, plug_cut_d], center = true);
            }
}

// A hook that drapes over a rail's ledge bar from above, like a coat
// hook over a rail: a back strut ties it to the underside of the top
// panel, a thin roof sits just above the ledge, and a front stop hangs
// down past the ledge's front-bottom edge to keep the cover from
// swinging away from the wall. Gravity does the rest; lift straight up
// to disengage.
module cover_hook(x_center) {
    y0 = 0;
    y1 = rail_reach + hook_clear;
    z_top_bot   = rail_top_z + hook_clear;
    z_top_top   = z_top_bot + hook_t;
    z_front_bot = rail_bot_z - hook_clear;

    translate([x_center - hook_w / 2, 0, 0]) {
        // Back strut, overlaps slightly into the top panel to fuse cleanly.
        translate([0, y0, z_top_bot])
            cube([hook_w, hook_t, top_inner_z - z_top_bot + 0.02]);
        // Thin roof over the ledge bar.
        translate([0, y0, z_top_bot])
            cube([hook_w, (y1 - y0) + hook_t, hook_t]);
        // Front stop, past the ledge's front-bottom edge.
        translate([0, y1, z_front_bot])
            cube([hook_w, hook_t, z_top_top - z_front_bot]);
    }
}

module cover() {
    union() {
        front_wall();
        side_wall(-1);
        side_wall(1);
        top_panel();
        bottom_panel();
        cover_hook(hook_x);
        cover_hook(-hook_x);
    }
}

// One keyhole slot: a big circle for the screw head to pass through
// during installation, plus a narrower slot the rail slides down onto
// so the head bears on the rail's back face around the slot, clamping
// the rail to the wall. cz = local Z of the big circle's centre.
module keyhole_cut(cz) {
    translate([0, -1, cz])
        rotate([-90, 0, 0])
            cylinder(d = keyhole_head_d, h = rail_reach + 2, $fn = 32);
    translate([-keyhole_shank_d / 2, -1, cz - keyhole_slot_len])
        cube([keyhole_shank_d, rail_reach + 2, keyhole_slot_len]);
}

// A wall rail: a mounting web (flush to the wall, carries the keyhole
// slots) topped by a ledge bar that projects further out - the surface
// the cover's hooks drape over. Local Z = 0 is the top of the ledge
// bar (aligns with rail_top_z / rail_lower_z when placed).
module wall_rail() {
    keyhole_cz = -(rail_h + 10); // centre of the big circle, below the ledge bar

    difference() {
        union() {
            translate([-rail_len / 2, 0, -rail_web_h])
                cube([rail_len, rail_web_t, rail_web_h]);
            translate([-rail_len / 2, 0, -rail_h])
                cube([rail_len, rail_reach, rail_h]);
        }
        for (xk = [-(rail_len / 2 - keyhole_inset), (rail_len / 2 - keyhole_inset)])
            translate([xk, 0, 0])
                keyhole_cut(keyhole_cz);
    }
}

// ============================================================
// RENDER
// ============================================================
if (part == "cover") {
    cover();
} else if (part == "rail") {
    translate([0, 0, rail_web_h]) wall_rail();
} else if (part == "both") {
    cover();
    translate([0, 0, rail_top_z]) wall_rail();
    translate([0, 0, rail_lower_z]) wall_rail();
} else if (part == "exploded") {
    // First pass: only the two rails fit the bed; the 400 mm cover is
    // flagged above and left for the deferred split.
    gap = 15;
    rotate([90, 0, 0]) wall_rail();
    translate([0, rail_web_h + gap, 0]) rotate([90, 0, 0]) wall_rail();
}
