// ============================================================
// vacuum_crevice_nozzle.scad — a long, narrow, hooked vacuum
// nozzle for clearing the Qidi Q2's lead-screw recesses, with a
// bleed slider. Standalone, no external dependencies.
//
// WHY
//   Loose PLA bits fall into the recesses where the Z lead screws
//   go down through the chamber floor. Left there, a hot-chamber ABS
//   print melts them onto the bottom of the recess for good. This
//   nozzle goes straight down beside the screw, and then the tip hooks
//   sideways to pick them out before they melt.
//
// WHAT IT IS — three parts, each printed in its strong orientation
//   * CUFF: printed standing, with the socket mouth on the bed.
//       - A socket slides over the vacuum wand. Six crush ribs grip it,
//         so the fit holds even if the bore prints a little over or
//         under size. A 45° lead-in chamfer at the mouth and a 45°
//         conical wand stop, so nothing overhangs.
//       - A plenum above the wand tip. A BLEED WINDOW in its wall lets
//         outside air in, so the motor isn't starved when the narrow
//         nose chokes the flow. It is a vertical slot with a 45° pointed
//         top, so it prints without a bridge.
//       - A flat SLIDER PAD with two dovetail rails. Pad and rails grow
//         from the bed and are solid blocks, so they have no thin free
//         wall ends. V-notches in one rail are the detents. The rails
//         are open at the socket end, which is up in use, and closed by
//         a 45° stop at the nose end. Gravity therefore rests the
//         shutter at "closed" (full suction), and it can't fall out.
//       - A reducer (a hull with every slope ≤ 45°) narrows down to a
//         POCKET that the nose pushes into.
//       Standing, the socket and pocket walls are hoop rings, so
//       levering the wand or the nose loads them in-plane. This is the
//       orientation the repo's collar rule asks for.
//   * NOSE: printed flat, with the hook curving in the plane of the bed.
//       A straight base stub (inside the pocket), then the straight
//       REACH, then the HOOK arc, then a short tip. The mouth is
//       bevelled so it faces both sideways and down. The channel has a
//       45° pitched roof (house-shaped), so its ceiling is not a
//       bridge. Printed flat, the bending stress from poking and
//       levering runs along the layers in every direction. It is a
//       push-fit, so print the cuff once and try cheap noses until one
//       reaches. Glue it once you have one that works.
//   * SHUTTER: printed flat, back face down. A 2 mm plate with
//       dovetail edges, thumb ridges on top, and an in-plane spring
//       finger whose side bump clicks into the rail's notches.
//
// COORDINATES (mm)
//   Cuff: Z is the cuff axis, z = 0 is the socket mouth (on the bed)
//     and +Z runs toward the nose. The slider pad faces +X. In use
//     the cuff is upside down: socket up, nose down.
//   Nose (print frame): the bed is XY and z = 0..nose_t. The base end
//     is at the origin and the reach runs +Y ("down" in use). The hook
//     turns toward +X, the same side as the slider pad, so the pad
//     shows which way the tip points.
//   Shutter (print frame): X along its length, x = 0 is the socket
//     end. Y across it, Z through its thickness, back face at z = 0.
//
// PRINTING — PLA+ (SUNLU PLA+), Orca "0.20mm Strong @Q2 0.4", no supports
//   part = "plate" puts all three parts on one plate. Print part =
//   "fit_test" first. The 0.20mm Strong preset's 5 walls make the thin
//   nose walls solid perimeters, which keeps them airtight.
//   Use the nozzle with the chamber COLD: PLA softens at about 60 °C
//   and the Q2 chamber runs at 65 °C. To use it hot, print it in ABS
//   (filament "Creality ABS @Q2 0.4").
// ORCA: printer="Qidi Q2 0.4 nozzle @Q2 0.4" process="0.20mm Strong @Q2 0.4"
// ORCA: filament="SUNLU PLA+ 2.0 @Q2 0.4"
// ORCA: note="PLA+: vacuum with the chamber cold (PLA softens ~60 C, chamber runs 65 C)"
//
// ASSEMBLY AND TUNING
//   1. Print part = "fit_test". It has a socket ring, a nose stub and a
//      pocket ring. The ring should push onto the wand firmly and stay
//      on. Too loose: lower rib_d. Too tight: raise it. The stub should
//      push into the pocket ring snugly by hand. Adjust pocket_clear
//      the same way.
//   2. Measure the recess: the narrowest gap beside the screw, its
//      depth, and how far the tip must turn. Set nose_w, nose_t,
//      reach, hook_r and hook_angle.
//   3. Print the plate. Slide the shutter into the rails from the
//      socket end, with its ridged face out, until it clicks. Push the
//      nose into the pocket.
//   4. Use: shutter at the nose end = closed = full suction. Slide it
//      toward the wand to bleed in outside air. Open it fully if the
//      motor note rises (the nose is choked).
//   Change only the nose parameters and reprint part = "nose" to try
//   another shape. The cuff stays.
// ============================================================

/* [Part] */
part = "plate"; // [plate, cuff, nose, shutter, assembled, fit_test]
slider_open = 0.5; // [0:0.25:1] assembled view: 0 = closed (full suction), 1 = fully open

/* [Vacuum wand] */
wand_d        = 34.4;  // measured wand OD (calipers)
socket_bore_d = 35.0;  // socket bore, between the ribs
rib_d         = 34.2;  // across the crush-rib crests; < wand_d so they grip
rib_count     = 6;
rib_w         = 2.0;   // rib width
socket_depth  = 40;    // how far the wand goes in
cuff_wall     = 3;     // socket wall
mouth_chamfer = 1.0;   // 45° lead-in at the socket mouth
rib_lead      = 4;     // the ribs ramp up over this height, above the chamfer

/* [Nose] */
nose_w       = 12;     // outer width, in the plane of the hook
nose_t       = 12;     // outer thickness, across the hook plane (= print height)
nose_wall    = 1.8;    // 4 lines of 0.45 mm
reach        = 120;    // straight length below the cuff, before the hook
hook_r       = 14;     // centreline radius of the hook
hook_angle   = 90;     // how far the tip turns away from straight down
tip_len      = 10;     // straight after the hook, on the centreline
mouth_bevel  = 30;     // mouth face turned this far toward the bottom (0 = square cut)
edge_chamfer = 1.2;    // bed-side edges, 45° (also clears elephant's foot)
edge_round   = 1.2;    // top-side edges

/* [Nose joint] */
pocket_depth = 20;     // how far the nose goes into the cuff
pocket_clear = 0.15;   // per side
pocket_wall  = 3;
pocket_floor = 2;      // the floor the nose stops against
pocket_lead  = 0.6;    // 45° chamfer at the pocket mouth

/* [Bleed slider] */
window_w     = 14;     // bleed window width
window_h     = 28;     // bleed window height, including the pointed top
plenum_d     = 30;     // bore above the wand stop
shutter_t    = 2;      // shutter plate thickness
shutter_band = 1;      // square back band of the shutter edge; the rest is the 45° dovetail
shutter_side = 4;      // shutter overlap beyond each side of the window
shutter_end  = 4;      // shutter overlap beyond each end of the window when closed
rail_w       = 4;      // rail width beside the shutter
slide_clear  = 0.3;    // shutter-to-rail clearance
detent_count = 5;      // detent positions from closed to open (0 = friction only)
bump_h       = 0.8;    // detent bump on the spring finger
notch_d      = 0.7;    // detent notch depth in the rail
finger_len   = 16;     // spring finger length
finger_w     = 1.6;    // spring finger width (in the shutter plane)
slot_w       = 1.0;    // slot that frees the finger
grip_count   = 4;      // thumb ridges

/* [Printer] */
bed        = 270;      // Qidi Q2 bed, square
bed_margin = 5;
plate_gap  = 8;        // gap between parts on the plate

/* [Fit test] */
fit_ring_h   = 12;     // socket ring height
fit_pocket_h = 12;     // pocket ring height
fit_stub_len = 25;     // nose stub length

/* [Quality] */
$fa = 1;
$fs = 0.4;

// ============================================================
// DERIVED
// ============================================================
eps = 0.01;

// ---- cuff, bottom (socket mouth) to top (nose pocket)
cuff_od    = socket_bore_d + 2 * cuff_wall;
z_p0       = socket_depth + (socket_bore_d - plenum_d) / 2;  // top of the 45° wand stop
win_z0     = z_p0 + 3;                                       // bleed window bottom
win_z1     = win_z0 + window_h;                              // bleed window apex
z_p1       = win_z1 + 2;                                     // top of the plenum
red_h      = plenum_d / 2;                                   // reducer height: slopes ≤ 45°
z_r1       = z_p1 + red_h;                                   // top of the reducer
z_pf       = z_r1 + pocket_floor;                            // pocket floor
z_top      = z_pf + pocket_depth;                            // top of the cuff

// ---- slider
sh_w        = window_w + 2 * shutter_side;   // shutter width
sh_len      = window_h + 2 * shutter_end;    // shutter length
travel      = window_h + shutter_end;        // closed -> fully open
pad_x       = cuff_od / 2 + 0.5;             // pad face, just proud of the cylinder
pad_hw      = sh_w / 2 + slide_clear + rail_w;
z_rail_top  = win_z1 + shutter_end;          // shutter's nose end when closed
z_stop_top  = z_rail_top + shutter_t + 1;
open_bottom = z_rail_top - travel - sh_len;  // shutter's socket end when fully open
dt_in       = shutter_t - shutter_band;      // dovetail inset at the front face
finger_x0   = (sh_len - finger_len - slot_w) / 2;          // finger root, along the shutter
bump_x      = finger_x0 + finger_len - bump_h - 0.5;       // bump, along the shutter
grip_hw     = sh_w / 2 - finger_w - slot_w - 1;            // thumb ridges stay clear of the slot

// ---- nose channel (house-shaped: rectangle + 45° roof)
ch_w      = nose_w - 2 * nose_wall;
ch_rect_h = nose_t - 2 * nose_wall - ch_w / 2;

// ---- nose path (print frame)
L1        = pocket_depth + reach;                 // base stub + reach
arc_c     = [hook_r, L1];                         // hook centre
th_end    = 180 - hook_angle;                     // angle of the hook's end, about arc_c
p_arc_end = arc_c + hook_r * [cos(th_end), sin(th_end)];
tip_dir   = [sin(th_end), -cos(th_end)];
tip_ang   = atan2(tip_dir[1], tip_dir[0]);
p_tip     = p_arc_end + tip_len * tip_dir;
path_pts  = concat([[0, 0], [0, L1]],
                   [for (a = [0 : 5 : hook_angle]) arc_c + hook_r * [cos(180 - a), sin(180 - a)]],
                   [p_arc_end, p_tip, p_tip + nose_w / 2 * tan(mouth_bevel) * tip_dir]);
nose_bb   = [min([for (p = path_pts) p[0]]) - nose_w / 2, max([for (p = path_pts) p[0]]) + nose_w / 2,
             min([for (p = path_pts) p[1]]) - nose_w / 2, max([for (p = path_pts) p[1]]) + nose_w / 2];

// ---- plate: all three parts on the 270 x 270 bed, centred on the
// origin. The nose lies flat on the left; to its right, the cuff stands
// above the shutter, which lies flat.
pl_nose_bw = nose_bb[1] - nose_bb[0];
pl_cuff_x0 = -cuff_od / 2;
pl_cuff_x1 = pad_x + shutter_t;
pl_cuff_hw = max(cuff_od / 2, pad_hw);
pl_col_w   = max(pl_cuff_x1 - pl_cuff_x0, sh_len);
pl_total_w = pl_nose_bw + plate_gap + pl_col_w;
pl_x_left  = -pl_total_w / 2;
pl_col_cx  = pl_x_left + pl_nose_bw + plate_gap + pl_col_w / 2;
pl_nose_at    = [pl_x_left - nose_bb[0], -(nose_bb[2] + nose_bb[3]) / 2, 0];
pl_cuff_at    = [pl_col_cx - (pl_cuff_x0 + pl_cuff_x1) / 2, pl_cuff_hw + plate_gap / 2, 0];
pl_shutter_at = [pl_col_cx - sh_len / 2, -(sh_w / 2 + bump_h + plate_gap / 2), 0];

// ---- reporting
ch_area  = ch_w * ch_rect_h + ch_w * ch_w / 4;
win_area = window_w * (window_h - window_w / 2) + window_w * window_w / 4;

assert(rib_d < wand_d && wand_d < socket_bore_d,
       "rib_d < wand_d < socket_bore_d, or the ribs can't grip");
assert(plenum_d < socket_bore_d, "plenum_d must be smaller than the socket bore (it is the wand stop)");
assert(window_w < plenum_d - 4, "bleed window too wide for the plenum");
assert(ch_w >= 5, str("nose channel only ", ch_w, " mm wide: widen nose_w or thin nose_wall"));
assert(ch_rect_h >= 0, str("nose_t too thin for the channel's 45° roof: need nose_t >= ",
       2 * nose_wall + ch_w / 2));
assert(hook_r - nose_w / 2 >= 2, "hook_r too tight for nose_w: inner radius under 2 mm");
assert(hook_angle > 0 && hook_angle <= 180, "hook_angle must be 1..180");
assert(mouth_bevel >= 0 && mouth_bevel <= 60, "mouth_bevel must be 0..60");
assert(open_bottom >= 0, "shutter would run off the rails when open: shorten window_h or deepen the socket");
assert(nose_bb[1] - nose_bb[0] <= bed - 2 * bed_margin && nose_bb[3] - nose_bb[2] <= bed - 2 * bed_margin,
       "nose does not fit the bed");
assert(finger_x0 > 1, "spring finger longer than the shutter");
assert(pl_total_w <= bed - 2 * bed_margin, "plate too wide for the bed");
assert(2 * pl_cuff_hw + plate_gap + sh_w + 2 * bump_h <= bed - 2 * bed_margin, "plate too deep for the bed");

echo(str("nose channel ", ch_area, " mm², bleed window ", win_area, " mm² (",
         win_area / ch_area, "x); wand bore ", PI * plenum_d * plenum_d / 4, " mm²"));
echo(str("rib grip ", (wand_d - rib_d) / 2, " mm per side; cuff ", z_top, " mm tall; nose ",
         nose_bb[3] - nose_bb[2], " x ", nose_bb[1] - nose_bb[0], " mm"));

// ============================================================
// NOSE
// ============================================================

// Outer section, in (u, v): u across the path in the bed plane,
// v up from the bed. Chamfered at the bed, rounded on top.
module nose_outer_2d() {
    hull() {
        polygon([[-nose_w / 2 + edge_chamfer, 0], [nose_w / 2 - edge_chamfer, 0],
                 [nose_w / 2, edge_chamfer], [nose_w / 2, nose_t - edge_round],
                 [-nose_w / 2, nose_t - edge_round], [-nose_w / 2, edge_chamfer]]);
        for (s = [-1, 1])
            translate([s * (nose_w / 2 - edge_round), nose_t - edge_round]) circle(r = edge_round);
    }
}

// Channel: a rectangle under a 45° roof, so its ceiling prints
// without a bridge.
module nose_channel_2d() {
    polygon([[-ch_w / 2, nose_wall], [ch_w / 2, nose_wall],
             [ch_w / 2, nose_wall + ch_rect_h], [0, nose_wall + ch_rect_h + ch_w / 2],
             [-ch_w / 2, nose_wall + ch_rect_h]]);
}

// Extrude a (u, v) section along +Y from y = 0 to len: u -> X, v -> Z.
module along_y(len) {
    translate([0, len, 0]) rotate([90, 0, 0]) linear_extrude(len) children();
}

// Sweep a section along the nose path: the base straight (extended
// back by base_ext), the hook arc, and the tip straight (extended by
// tip_ext past the tip). The arc mirrors the section so u keeps the
// same side as on the straights.
module nose_path(base_ext = 0, tip_ext = 0) {
    translate([0, -base_ext, 0]) along_y(L1 + base_ext + eps) children();
    translate([arc_c[0], arc_c[1], 0]) rotate([0, 0, th_end])
        rotate_extrude(angle = hook_angle) translate([hook_r, 0]) mirror([1, 0]) children();
    translate([p_arc_end[0], p_arc_end[1], 0]) rotate([0, 0, tip_ang - 90])
        translate([0, -eps, 0]) along_y(tip_len + tip_ext + eps) children();
}

// The nose, in print orientation.
module nose() {
    difference() {
        nose_path(0, nose_w) nose_outer_2d();
        nose_path(1, 2 * nose_w) nose_channel_2d();
        // Mouth bevel: the face turns from the tip direction toward the
        // outside of the bend, which is the bottom in use.
        translate([p_tip[0], p_tip[1], -1]) rotate([0, 0, tip_ang + mouth_bevel])
            translate([0, -2 * nose_w, 0]) cube([2 * nose_w, 4 * nose_w, nose_t + 2]);
    }
}

// ============================================================
// CUFF
// ============================================================

// Place the nose frame on the cuff axis with its base at height z:
// nose +Y -> cuff +Z, nose +X -> cuff +X (the pad side), section
// centred on the axis.
module nose_frame(z) {
    translate([0, nose_t / 2, z]) rotate([90, 0, 0]) children();
}

module pocket_2d()  { offset(delta = pocket_clear) nose_outer_2d(); }
module housing_2d() { offset(r = pocket_wall) pocket_2d(); }

// The shutter's cross-section in the cuff, as (depth out from the pad
// face, lateral): a square back band, then a 45° dovetail to the front
// face. Convex.
module shutter_section_2d() {
    polygon([[0, -sh_w / 2], [shutter_band, -sh_w / 2], [shutter_t, -(sh_w / 2 - dt_in)],
             [shutter_t, sh_w / 2 - dt_in], [shutter_band, sh_w / 2], [0, sh_w / 2]]);
}

// The shutter's bottom (cuff-frame z) at slider position pos, 0..1.
function shutter_z(pos) = z_rail_top - sh_len - pos * travel;

// Two dovetail rails on the pad face, grown from the bed. The channel
// between them is open at the bed end (where the shutter goes in),
// with a flared lead-in against elephant's foot. Detent notches are in
// the -Y rail's square back band, where the shutter's bump runs.
module rails() {
    y_in = sh_w / 2 - dt_in;
    difference() {
        for (s = [-1, 1])
            translate([pad_x, s > 0 ? y_in : -pad_hw, 0]) cube([shutter_t, pad_hw - y_in, z_rail_top]);
        translate([pad_x, 0, -1]) linear_extrude(z_rail_top + 2)
            offset(delta = slide_clear) shutter_section_2d();
        hull() {
            translate([pad_x, 0, -1]) linear_extrude(1 + eps)
                offset(delta = slide_clear + 0.6) shutter_section_2d();
            translate([pad_x, 0, 0.6]) linear_extrude(eps)
                offset(delta = slide_clear) shutter_section_2d();
        }
        if (detent_count > 0)
            for (i = [0 : detent_count - 1]) {
                pos = detent_count == 1 ? 0 : i / (detent_count - 1);
                zb  = shutter_z(pos) + bump_x;
                // 45° V-notch: a diamond centred on the rail face, cut
                // slide_clear past the back band so the bump's top clears
                translate([pad_x - 1, -(sh_w / 2 + slide_clear), zb - notch_d])
                    rotate([45, 0, 0])
                        cube([shutter_band + slide_clear + 1, notch_d * sqrt(2), notch_d * sqrt(2)]);
            }
    }
}

// Stop across the nose end of the rails, with a 45° underside.
module rail_stop() {
    hull() {
        translate([pad_x - eps, -pad_hw, z_rail_top]) cube([eps, 2 * pad_hw, z_stop_top - z_rail_top]);
        translate([pad_x - eps, -pad_hw, z_rail_top + shutter_t])
            cube([shutter_t + eps, 2 * pad_hw, z_stop_top - z_rail_top - shutter_t]);
    }
}

// Wand socket: bore with crush ribs, mouth chamfer, and the ribs
// ramping up above it.
module socket_void() {
    difference() {
        translate([0, 0, -1]) cylinder(d = socket_bore_d, h = socket_depth + 1);
        for (i = [0 : rib_count - 1])
            rotate(30 + i * 360 / rib_count)
                translate([rib_d / 2, -rib_w / 2, -2])
                    cube([(socket_bore_d - rib_d) / 2 + 1, rib_w, socket_depth + 3]);
    }
    translate([0, 0, -eps])
        cylinder(d1 = socket_bore_d + 2 * mouth_chamfer, d2 = socket_bore_d, h = mouth_chamfer + eps);
    translate([0, 0, mouth_chamfer - eps]) cylinder(d1 = socket_bore_d, d2 = rib_d, h = rib_lead);
}

// Bleed window: a vertical slot with a 45° pointed top, through the
// +X wall and the pad.
module window_cut() {
    hull() {
        translate([0, -window_w / 2, win_z0]) cube([pad_x + 1, window_w, window_h - window_w / 2]);
        translate([0, -eps, win_z1 - eps]) cube([pad_x + 1, 2 * eps, eps]);
    }
}

// Pocket the nose pushes into, with a 45° lead-in at its mouth.
module pocket_cut(z0, depth, lead_bottom = false) {
    nose_frame(z0) translate([0, -eps, 0]) along_y(depth + 2 * eps) pocket_2d();
    hull() {
        nose_frame(z0 + depth - pocket_lead) along_y(eps) pocket_2d();
        nose_frame(z0 + depth) along_y(eps) offset(delta = pocket_lead) pocket_2d();
    }
    if (lead_bottom)
        hull() {
            nose_frame(z0 - eps) along_y(eps) offset(delta = pocket_lead) pocket_2d();
            nose_frame(z0 + pocket_lead) along_y(eps) pocket_2d();
        }
}

module cuff() {
    difference() {
        union() {
            cylinder(d = cuff_od, h = z_p1);
            translate([0, -pad_hw, 0]) cube([pad_x, 2 * pad_hw, z_stop_top]);   // slider pad
            rails();
            rail_stop();
            hull() {                                                             // outer reducer
                translate([0, 0, z_p1 - eps]) cylinder(d = cuff_od, h = eps);
                nose_frame(z_r1) along_y(eps) housing_2d();
            }
            nose_frame(z_r1) along_y(z_top - z_r1) housing_2d();                 // pocket housing
        }
        socket_void();
        translate([0, 0, socket_depth - eps])                                    // 45° wand stop
            cylinder(d1 = socket_bore_d, d2 = plenum_d, h = z_p0 - socket_depth + eps);
        translate([0, 0, z_p0 - eps]) cylinder(d = plenum_d, h = z_p1 - z_p0 + 2 * eps);
        hull() {                                                                 // inner reducer
            translate([0, 0, z_p1]) cylinder(d = plenum_d, h = eps);
            nose_frame(z_r1) along_y(eps) nose_channel_2d();
        }
        nose_frame(z_r1 - eps) along_y(pocket_floor + 2 * eps) nose_channel_2d();
        pocket_cut(z_pf, pocket_depth);
        window_cut();
    }
}

// ============================================================
// SHUTTER
// ============================================================

// Print orientation: back face on the bed, length along +X from the
// socket end, the spring finger on the +Y edge.
module shutter() {
    difference() {
        union() {
            // square back band, with the detent bump on the finger
            linear_extrude(shutter_band) {
                translate([0, -sh_w / 2]) square([sh_len, sh_w]);
                if (detent_count > 0)
                    polygon([[bump_x - bump_h - 0.2, sh_w / 2 - eps], [bump_x, sh_w / 2 + bump_h],
                             [bump_x + bump_h + 0.2, sh_w / 2 - eps]]);
            }
            // 45° dovetail band
            hull() {
                translate([0, -sh_w / 2, shutter_band - eps]) cube([sh_len, sh_w, eps]);
                translate([0, -(sh_w / 2 - dt_in), shutter_t - eps]) cube([sh_len, sh_w - 2 * dt_in, eps]);
            }
            // thumb ridges, across the middle
            for (k = [0 : grip_count - 1])
                translate([sh_len * (0.25 + 0.5 * k / max(grip_count - 1, 1)) - 0.6, -grip_hw, shutter_t - eps])
                    cube([1.2, 2 * grip_hw, 1 + eps]);
        }
        if (detent_count > 0) {
            // L-shaped slot freeing a cantilever finger along the +Y edge;
            // its free end (and the bump) is toward the nose end
            translate([finger_x0, sh_w / 2 - finger_w - slot_w, -1])
                cube([finger_len + slot_w, slot_w, shutter_t + 2]);
            translate([finger_x0 + finger_len, sh_w / 2 - finger_w - slot_w, -1])
                cube([slot_w, finger_w + slot_w + 1, shutter_t + 2]);
        }
    }
}

// The shutter in the cuff frame at slider position pos (0 = closed).
// A proper rotation (no mirror): shutter X -> cuff Z, Y -> -Y, Z -> X.
module shutter_placed(pos) {
    multmatrix([[0, 0, 1, pad_x], [0, -1, 0, 0], [1, 0, 0, shutter_z(pos)], [0, 0, 0, 1]])
        shutter();
}

// ============================================================
// LAYOUTS
// ============================================================

// In use: socket up, nose down, the wand as a ghost.
module assembled() {
    rotate([180, 0, 0]) {
        color("SteelBlue") cuff();
        color("Orange") nose_frame(z_pf) nose();
        color("Gold") shutter_placed(slider_open);
        %translate([0, 0, -120]) cylinder(d = wand_d, h = 120 + socket_depth);
    }
}

// Fit test, to tune rib_d and pocket_clear before the full print: the
// cuff's socket (standing), its nose pocket open at both ends
// (standing), and a stub of the nose (flat).
module fit_ring() {
    difference() {
        cylinder(d = cuff_od, h = fit_ring_h);
        socket_void();
    }
}

module fit_pocket() {
    difference() {
        nose_frame(0) along_y(fit_pocket_h) housing_2d();
        pocket_cut(0, fit_pocket_h, lead_bottom = true);
    }
}

module fit_stub() {
    difference() {
        along_y(fit_stub_len) nose_outer_2d();
        translate([0, -1, 0]) along_y(fit_stub_len + 2) nose_channel_2d();
    }
}

// ============================================================
// RENDER
// ============================================================
// The plate's parts are separate top-level nodes, so a lazy-union
// export (make) puts them on the plate as separate objects.
if (part == "plate") {
    translate(pl_nose_at) nose();
    translate(pl_cuff_at) cuff();
    translate(pl_shutter_at) shutter();
}
else if (part == "cuff")
    cuff();
else if (part == "nose")
    nose();
else if (part == "shutter")
    shutter();
else if (part == "assembled")
    assembled();
else if (part == "fit_test") {
    fit_ring();
    translate([cuff_od / 2 + plate_gap + nose_w / 2 + pocket_wall, 0, 0]) fit_pocket();
    translate([cuff_od / 2 + 2 * plate_gap + 1.5 * nose_w + 2 * pocket_wall + nose_w / 2,
               -fit_stub_len / 2, 0]) fit_stub();
}
else
    assert(false, str("unknown part: ", part));
