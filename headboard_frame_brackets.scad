// ============================================================
// Headboard Frame Brackets
//
// A freestanding frame to carry a bed headboard that cannot be
// fixed to the wall. The structure is 20x20 mm square aluminium
// tube, cut to length; these printed brackets join the tubes by
// FRICTION — each tube slides into an external printed socket.
// Attaching the headboard itself to the frame is a future phase.
//
// One side frame is a large L (print the plate twice for a pair):
//   - a 1500 mm vertical tube,
//   - a 600 mm foot tube along the floor, joined at 90 degrees by
//     the corner bracket,
//   - four short "toe" tubes, perpendicular to the foot and flat
//     on the floor, for lateral stability. Two toe stations: an
//     end-T at the free end of the foot, and a cross bracket that
//     slides along the foot near the corner. At the cross station
//     the foot tube occupies the toe's floor height, so through
//     toes are impossible there — both stations therefore take
//     identical blind toe stubs, giving one toe interface
//     everywhere and a simple cut list.
//
// Cut list per side frame: 1 x 1500, 1 x 600, 4 x toe_len (250).
// (Echoed on every render.)
//
// HEADBOARD CLAMP (part = "clamp" / "screw" / "clampset"): the
// bracket that fixes the headboard to the vertical pole. A sleeve
// slides over the pole (0.35 mm/side, same as the cross bracket)
// and is locked by a PRINTED thumbscrew through a side boss — the
// screw's dog point presses the pole against the opposite bore
// wall. The headboard face is a flat 80 x 20 mm plate with a
// Ø5 screw hole near each end, braced back to the sleeve by
// horizontal gussets. One clamp per pole: print two "clampset"
// plates for the eventual pair of side frames. Thread geometry is
// the proven generator from magnet_pill_container.scad (45 deg
// flanks, self-supporting; female thread gets 0.35 mm radial
// clearance because it prints on a horizontal axis).
//
// Fits: gripping sockets are tube + 0.15 mm per side with crush
// ribs standing 0.2 mm proud — the ribs shave on insertion, so the
// grip survives the size scatter of extruded aluminium where a
// plain fit would be hammer-tight or loose. The cross bracket's
// foot sleeve is a 0.35 mm per side through-slide (it must travel
// along the tube during assembly) locked by a self-tap screw
// through its top wall. Every socket also carries a Ø3.4 backup
// screw hole in case friction proves insufficient.
//
// Every pocket floor sits exactly one wall thickness above the
// bracket underside, so all brackets present a coplanar tube
// datum; tubes float `wall` above the floor between brackets,
// which 20x20 aluminium does not notice over these spans.
// Slip-on end caps finish the four toe ends and the vertical top.
//
// Coordinate system (assembly view):
//   Origin = outer corner of the corner bracket, at floor level.
//   +X = along the foot tube, +Y = along the toes, +Z = up.
//   Floor = z 0. Every horizontal tube axis sits at tube_z.
//
// Print orientation (all parts support-free):
//   corner — lying on a side face: layers run along both legs and
//            the gusset, so the lean-load bending stress is
//            in-plane with the layers. Pockets become horizontal
//            voids with ~20 mm flat bridge ceilings, blind walls
//            vertical, 45 degree mouth flares self-supporting.
//   endt / cross — floor face down: walls vertical, pocket floors
//            (the tube datum) on the bed; only bridges are the
//            ~20 mm pocket ceilings.
//   cap    — mouth up, closed face on the bed.
//   clamp  — standing, as used: bore vertical, plate and gussets
//            rise from the bed. Only the thumbscrew boss is a
//            horizontal cylinder (house precedent accepts its
//            underside; the female thread's sag is absorbed by
//            ts_clear_r).
//   screw  — head down: the external thread's 45 deg flanks rise
//            self-supporting.
//
// Standalone — no external dependencies.
// All units: millimeters.
//
// Export:
//   openscad -o headboard_frame_corner.stl -D 'part="corner"' headboard_frame_brackets.scad
//   openscad -o headboard_frame_endt.stl   -D 'part="endt"'   headboard_frame_brackets.scad
//   openscad -o headboard_frame_cross.stl  -D 'part="cross"'  headboard_frame_brackets.scad
//   openscad -o headboard_frame_cap.stl    -D 'part="cap"'    headboard_frame_brackets.scad
//   openscad -o headboard_frame_clamp.stl  -D 'part="clamp"'  headboard_frame_brackets.scad
//   openscad -o headboard_frame_screw.stl  -D 'part="screw"'  headboard_frame_brackets.scad
//   openscad --enable=lazy-union -o headboard_frame_brackets.3mf -D 'part="printplate"' headboard_frame_brackets.scad
//   openscad --enable=lazy-union -o headboard_frame_clampset.3mf -D 'part="clampset"' headboard_frame_brackets.scad
//   (printplate items: 1 corner, 2 end-T, 3 cross, 4 caps x5.
//    One plate = one side frame; print two plates for the pair.
//    clampset items: 1 clamp, 2 thumbscrew — print one set per pole.)
// ============================================================

/* [Tube] */
tube         = 20;    // Square tube outer size — MEASURED off the stock
tube_wall    = 1.5;   // Tube wall — ghost geometry only, nothing printed uses it
vertical_len = 1500;  // Vertical tube length
foot_len     = 600;   // Foot tube length
toe_len      = 250;   // Each of the 4 toe stubs (~200 mm reach past the socket)

/* [Fit] */
grip_clear   = 0.15;  // Per side, gripping sockets — house friction norm
slide_clear  = 0.35;  // Per side, foot through-sleeve — must slide during assembly
crush_ribs   = true;  // Ribs in grip sockets for tolerance-robust friction
rib_proud    = 0.2;   // Rib crest above the pocket wall (~0.05/side interference)
rib_base     = 1.6;   // Rib triangle base width
lead_in      = 1.5;   // 45 degree flare at every pocket mouth
bottom_gap   = 1.0;   // Extra pocket depth so a burred saw cut never hard-bottoms

/* [Sockets] */
corner_vert_depth = 90;   // Deepest — full lean moment; angular slop ~ 2*clear/depth
corner_foot_depth = 70;   // Same moment reacted over the 600 mm foot — lower stress
endt_foot_depth   = 60;
toe_depth         = 50;   // Toes only see roll loads on a short lever
sleeve_len        = 60;   // Cross-bracket through-sleeve length along the foot
cross_station     = 140;  // Sleeve centre, X from the corner bracket's outer face

/* [Body] */
wall           = 3.36;  // 8 x 0.42 mm extrusions (4 loops) — also web & pocket floor
gusset_leg     = 45;    // Corner-bracket inner-corner gusset, leg length
web_gusset_leg = 30;    // Horizontal gusset legs on the end-T / cross brackets
corner_round   = 2;     // 2D outline rounding on convex outer corners
screw_holes    = true;  // O3.4 self-tap backup/lock hole per socket
screw_d        = 3.4;   // M3-ish self-tapper clearance through printed wall

/* [Headboard Clamp] */
clamp_h          = 40;    // Sleeve height on the pole
clamp_plate_w    = 80;    // Headboard plate width (across the pole)
clamp_plate_h    = 20;    // Headboard plate height
clamp_plate_t    = 6;     // Headboard plate thickness
clamp_hole_d     = 5.0;   // Headboard screw holes, one near each plate end
clamp_hole_inset = 12;    // Hole centre from each plate end
clamp_gusset     = 10;    // Horizontal gussets bracing the plate wings
clamp_screw_z    = 26;    // Thumbscrew axis height — above the plate, below the top
sleeve_ch        = 1.2;   // Entry chamfer on both ends of the sliding bore
clamp_demo_z     = 1100;  // Clamp height on the pole, assembly view only

/* [Thumbscrew] */
// Printed-thread numbers proven in magnet_pill_container.scad.
ts_pitch       = 2.5;   // Thread pitch — coarse, few turns to clamp
ts_major_d     = 10;    // Thread major diameter
ts_depth       = 0.6;   // Radial depth of the thread (crest minus root)
ts_crest       = 0.6;   // Axial width of the flat crest
ts_root        = 0.6;   // Axial width of the flat root
ts_len         = 12;    // Threaded shaft length
ts_head_d      = 20;    // Knurled head diameter
ts_head_t      = 6;     // Knurled head thickness
ts_head_flutes = 12;    // Grip scallops around the head
ts_tip_d       = 7;     // Flat dog point that bears on the pole
ts_tip_len     = 2;     // Length of that dog point
ts_clear_r     = 0.35;  // Radial clearance — the female thread prints on a
                        // horizontal axis, so its bore sags a little
ts_clear_ax    = 0.25;  // Axial (flank) clearance
boss_d         = 17;    // Thumbscrew boss diameter on the sleeve side
boss_len       = 8;     // How far the boss stands off the sleeve

/* [End Caps] */
caps      = true;
cap_depth = 15;    // Engagement over the tube end
cap_wall  = 1.68;  // 2 extrusion loops
cap_face  = 2.5;   // Closed-end thickness
cap_clear = 0.15;  // Per side — same friction norm as the grip sockets

/* [Quality] */
$fa = 1;   // Minimum angle — 1 degree gives max 360 facets per full circle
$fs = 0.4; // Minimum facet edge length (mm) — matched to a 0.4 mm nozzle

/* [Render] */
part = "assembly";  // [corner, endt, cross, cap, clamp, screw, clampset, printplate, assembly]

// ============================================================
// DERIVED
// ============================================================

g_in  = tube + 2 * grip_clear;   // Grip pocket inner square (20.30)
s_in  = tube + 2 * slide_clear;  // Slide sleeve inner square (20.70)
g_out = g_in + 2 * wall;         // Grip socket outer square  (27.02)
s_out = s_in + 2 * wall;         // Slide sleeve outer square (27.42)
h_g   = g_out / 2;
h_s   = s_out / 2;
tube_z = wall + tube / 2;        // Axis height of every horizontal tube

// Corner bracket: foot leg along +X, vertical leg up. The vertical
// pocket's seat web IS the foot pocket's ceiling — one shared wall.
foot_leg_len = wall + corner_foot_depth + bottom_gap;   // 74.36
vert_leg_h   = g_out + corner_vert_depth + bottom_gap;  // 118.02

// End-T / cross: arm reach from the local origin to each pocket mouth.
endt_foot_reach = h_g + endt_foot_depth + bottom_gap;   // 74.51
endt_arm_reach  = h_g + toe_depth + bottom_gap;         // 64.51
cross_arm_reach = h_s + toe_depth + bottom_gap;         // 64.71
cross_half_x    = max(sleeve_len / 2, h_g + web_gusset_leg);  // Gussets outreach the sleeve

// End caps.
cap_in  = tube + 2 * cap_clear;
cap_out = cap_in + 2 * cap_wall;
cap_h   = cap_face + cap_depth;

// Assembly positions. Tubes seat bottom_gap shy of each blind web.
foot_x0 = wall + bottom_gap;          // Foot tube start (inside the corner)
foot_x1 = foot_x0 + foot_len;         // Foot tube tip
endt_x  = foot_x1 + bottom_gap + h_g; // End-T local origin
vert_z0 = g_out + bottom_gap;         // Vertical tube bottom

// Headboard clamp / thumbscrew. Male thread first, female = male
// grown by the clearances (radial) and widened flanks (axial).
ts_maj_r       = ts_major_d / 2;
ts_min_r       = ts_maj_r - ts_depth;
ts_f_min_r     = ts_min_r + ts_clear_r;
ts_f_maj_r     = ts_maj_r + ts_clear_r;
ts_phi_root    = lobe_angle(ts_pitch - ts_root, ts_pitch);
ts_phi_crest   = lobe_angle(ts_crest, ts_pitch);
ts_phi_clear   = lobe_angle(ts_clear_ax, ts_pitch);
ts_f_phi_root  = ts_phi_root + ts_phi_clear;
ts_f_phi_crest = ts_phi_crest + ts_phi_clear;
ts_lead        = 1.2;                     // Entry flare on the female thread
boss_outer     = h_s + boss_len;          // Boss face, from the pole axis
boss_thread    = boss_outer - s_in / 2;   // Female thread length available
// Screw pressed home: tip on the pole face, head still off the boss.
ts_press_gap   = tube / 2 + ts_tip_len + ts_len - boss_outer;
ts_press_eng   = boss_outer - tube / 2 - ts_tip_len;

eps = 0.01;

// Sanity guards — these would produce broken geometry rather than an
// obvious error, so fail loudly instead.
assert(cross_station - cross_half_x > foot_leg_len + 5,
       "cross bracket collides with the corner bracket's foot leg");
assert(cross_station + cross_half_x < endt_x - endt_foot_reach - 5,
       "cross bracket collides with the end-T bracket");
assert(toe_len > toe_depth + bottom_gap + 50,
       "toe stub barely protrudes from its socket — lengthen toe_len");
assert(min(corner_vert_depth, corner_foot_depth, endt_foot_depth, toe_depth)
           > lead_in + 10,
       "socket too shallow for its lead-in flare");
assert(rib_proud < grip_clear + 0.15,
       "crush ribs too proud — the tube cannot be inserted");
assert(wall > 2 * 0.42,
       "socket wall thinner than 2 extrusion loops");
assert(ts_f_phi_root < 175,
       "female thread root lobe nearly a full circle — reduce ts_root or ts_clear_ax");
assert(ts_tip_d / 2 < ts_min_r,
       "thumbscrew dog point wider than the thread root");
assert(ts_press_gap >= 1,
       "thumbscrew head bottoms on the boss before the tip reaches the pole — lengthen ts_len");
assert(ts_press_eng >= 2 * ts_pitch,
       "under two turns of thread engaged when the screw is pressed home");
assert(clamp_screw_z - boss_d / 2 > clamp_plate_h - 5 && clamp_screw_z + boss_d / 2 < clamp_h,
       "thumbscrew boss must sit above the plate and inside the sleeve height");
assert(clamp_plate_w / 2 - clamp_hole_inset - clamp_hole_d / 2 > h_s + clamp_gusset,
       "headboard screw holes overlap the sleeve or gussets — widen clamp_plate_w or shrink clamp_gusset");

// Fit report — printed on every render.
echo(str("FIT: grip pocket ", g_in, " mm (", grip_clear, "/side)",
         crush_ribs ? str(" + crush ribs ", rib_proud,
                          " proud (~", rib_proud - grip_clear,
                          " mm/side interference)") : " (no ribs)"));
echo(str("FIT: slide sleeve ", s_in, " mm (", slide_clear, "/side), lock screw on top"));
echo(str("FIT: engagement — corner vert ", corner_vert_depth,
         ", corner foot ", corner_foot_depth,
         ", end-T foot ", endt_foot_depth,
         ", toes ", toe_depth, " mm"));
echo(str("CUT LIST per side frame: 1 x ", vertical_len,
         ", 1 x ", foot_len, ", 4 x ", toe_len, " mm of ",
         tube, "x", tube, " tube"));
echo(str("ASSEMBLED envelope: ", endt_x + h_g, " (X) x ",
         2 * (h_s + bottom_gap + toe_len), " toe stance (Y) x ",
         vert_z0 + vertical_len + (caps ? cap_face : 0), " (Z) mm"));
echo(str("WALLS: ", wall, " mm = ", wall / 0.42, " extrusion lines at 0.42 mm"));
echo(str("CLAMP: thumbscrew M", ts_major_d, "x", ts_pitch, " printed thread, ",
         ts_press_eng / ts_pitch, " turns engaged at the pole, head-to-boss gap ",
         ts_press_gap, " mm when pressed home"));

// ============================================================
// HELPERS
// ============================================================

// Round the CONVEX corners of a 2D outline: erode then dilate.
module rounded_outline() {
    offset(r = corner_round) offset(r = -corner_round) children();
}

// Hollow square tube along +Z, cross-section centred on the axis.
// Ghost/reference geometry only — never printed.
module ghost_tube(len) {
    difference() {
        translate([0, 0, len / 2]) cube([tube, tube, len], center = true);
        translate([0, 0, len / 2])
            cube([tube - 2 * tube_wall, tube - 2 * tube_wall, len + 2 * eps],
                 center = true);
    }
}

// Square pocket cutter. Mouth at z = 0 opening +Z, cavity down to
// z = -depth, with a 45 degree flare at the mouth so the sawn tube
// end finds its own way in (same hull trick as beam_corner_jig).
module pocket_cut(depth, inner) {
    translate([0, 0, -depth])
        linear_extrude(height = depth + 1)
            square(inner, center = true);
    hull() {
        translate([0, 0, -lead_in])
            linear_extrude(height = eps) square(inner, center = true);
        translate([0, 0, 1])
            linear_extrude(height = eps)
                offset(delta = lead_in + 1) square(inner, center = true);
    }
}

// One crush rib: a triangular prism along +Z, base flat on the
// x = 0 plane, apex standing rib_proud towards -X.
module rib_prism(len) {
    linear_extrude(height = len)
        polygon([[0, -rib_base / 2], [0, rib_base / 2], [-rib_proud, 0]]);
}

// Crush ribs inside a pocket, in the pocket_cut local frame: two
// axial ribs per requested face at 1/4 and 3/4 across it, kept
// clear of the mouth flare and of the blind end. Union these back
// AFTER the pocket has been subtracted.
module pocket_ribs(depth, inner, faces) {
    z0  = -(depth - 1);
    len = depth - lead_in - 2;
    for (f = faces, t = [-inner / 4, inner / 4]) {
        if (f == "+x") translate([ inner / 2, t, z0])                        rib_prism(len);
        if (f == "-x") translate([-inner / 2, t, z0]) rotate([0, 0, 180])    rib_prism(len);
        if (f == "+y") translate([t,  inner / 2, z0]) rotate([0, 0, 90])     rib_prism(len);
        if (f == "-y") translate([t, -inner / 2, z0]) rotate([0, 0, -90])    rib_prism(len);
    }
}

// A Ø screw_d bore along +Y, long enough to pass through a whole
// socket. One self-tapper through a wall into the aluminium locks a
// joint if friction alone proves insufficient.
module screw_bore() {
    rotate([-90, 0, 0]) cylinder(h = g_out + s_out, d = screw_d, $fn = 24);
}

// Placement frame for one toe pocket: mouth at the arm tip, opening
// outward along +/-Y, at grip-pocket height. attach_half is the half
// width of whatever the toe arm grows out of (h_g or h_s).
module toe_frame(side, attach_half) {
    translate([0, side * (attach_half + toe_depth + bottom_gap), h_g])
        rotate([side > 0 ? -90 : 90, 0, 0])
            children();
}

// ============================================================
// CORNER BRACKET
// Joins the vertical tube to the foot tube at 90 degrees. Built
// as a 2D L-profile in the X-Z plane (the plane holding both tube
// axes) extruded across Y, so the whole bracket — legs, shared
// wall and gusset — is one continuous section.
// ============================================================

module corner_profile_2d() {
    square([foot_leg_len, g_out]);
    square([g_out, vert_leg_h]);
    // 45 degree gusset filling the inner corner: carries the lean
    // load from the vertical leg down into the foot leg.
    polygon([[g_out, g_out],
             [g_out + gusset_leg, g_out],
             [g_out, g_out + gusset_leg]]);
}

module corner_bracket() {
    difference() {
        union() {
            difference() {
                translate([0, h_g, 0]) rotate([90, 0, 0])
                    linear_extrude(height = g_out)
                        rounded_outline() corner_profile_2d();
                // Foot pocket: opens +X, blind web at the outer corner.
                translate([foot_leg_len, 0, h_g]) rotate([0, 90, 0])
                    pocket_cut(corner_foot_depth + bottom_gap, g_in);
                // Vertical pocket: opens up; its seat web is the foot
                // pocket's ceiling — one shared wall by construction.
                translate([h_g, 0, vert_leg_h])
                    pocket_cut(corner_vert_depth + bottom_gap, g_in);
            }
            if (crush_ribs) {
                // Foot pocket: ribs on its ceiling only — they press the
                // tube down onto the pocket floor, the tube-height datum.
                // That face is print-vertical with the bracket on its side.
                translate([foot_leg_len, 0, h_g]) rotate([0, 90, 0])
                    pocket_ribs(corner_foot_depth + bottom_gap, g_in, ["-x"]);
                // Vertical pocket: ribs on both X faces (print-vertical);
                // the Y faces are the bed side and the bridge side.
                translate([h_g, 0, vert_leg_h])
                    pocket_ribs(corner_vert_depth + bottom_gap, g_in, ["+x", "-x"]);
            }
        }
        if (screw_holes) {
            // Both bores run across Y — vertical in the on-side print
            // orientation, so they print as clean circles.
            translate([foot_leg_len - 0.55 * corner_foot_depth, -h_g - 1, h_g])
                screw_bore();
            translate([h_g, -h_g - 1, vert_leg_h - 0.55 * corner_vert_depth])
                screw_bore();
        }
    }
}

// ============================================================
// END-T BRACKET
// Terminates the foot tube and holds the two end toe stubs.
// Local origin: centre of the centre block, on the floor.
// Foot arm reaches -X, toe arms reach +/-Y.
// ============================================================

module endt_footprint_2d() {
    square([g_out, g_out], center = true);
    translate([-endt_foot_reach, -h_g]) square([endt_foot_reach, g_out]);
    translate([-h_g, -endt_arm_reach]) square([g_out, 2 * endt_arm_reach]);
    // Horizontal gussets bracing each toe arm against the foot arm.
    for (s = [-1, 1]) scale([1, s])
        polygon([[-h_g, h_g],
                 [-h_g - web_gusset_leg, h_g],
                 [-h_g, h_g + web_gusset_leg]]);
}

module endt_bracket() {
    difference() {
        union() {
            difference() {
                linear_extrude(height = g_out)
                    rounded_outline() endt_footprint_2d();
                // Foot pocket: opens -X, blind end at the centre block.
                translate([-endt_foot_reach, 0, h_g]) rotate([0, -90, 0])
                    pocket_cut(endt_foot_depth + bottom_gap, g_in);
                // Toe pockets: open outward along +/-Y.
                for (s = [-1, 1]) toe_frame(s, h_g)
                    pocket_cut(toe_depth + bottom_gap, g_in);
            }
            if (crush_ribs) {
                // Ribs only on the print-vertical side faces — never the
                // pocket floor (tube datum) or the bridged ceiling.
                translate([-endt_foot_reach, 0, h_g]) rotate([0, -90, 0])
                    pocket_ribs(endt_foot_depth + bottom_gap, g_in, ["+y", "-y"]);
                for (s = [-1, 1]) toe_frame(s, h_g)
                    pocket_ribs(toe_depth + bottom_gap, g_in, ["+x", "-x"]);
            }
        }
        if (screw_holes) {
            translate([-endt_foot_reach + 0.55 * endt_foot_depth, -h_g - 1, h_g])
                screw_bore();
            for (s = [-1, 1])
                translate([-h_g - 1, s * (endt_arm_reach - 0.55 * toe_depth), h_g])
                    rotate([0, 0, -90]) screw_bore();
        }
    }
}

// ============================================================
// CROSS BRACKET
// Slides along the foot tube (through sleeve, 0.35/side) and holds
// the near-corner toe stubs. Locked in place by a self-tapper
// through the sleeve top. Local origin: sleeve centre, on the
// floor. Sleeve runs along X, toe arms reach +/-Y.
// The 0.2 mm/side step where the s_out sleeve meets the g_out arms
// is intentional — every socket keeps exactly `wall` of material.
// ============================================================

module cross_footprint_2d() {
    square([sleeve_len, s_out], center = true);
    translate([-h_g, -cross_arm_reach]) square([g_out, 2 * cross_arm_reach]);
    // Gussets in all four sleeve/arm corners.
    for (sx = [-1, 1], sy = [-1, 1]) scale([sx, sy])
        polygon([[h_g, h_s],
                 [h_g + web_gusset_leg, h_s],
                 [h_g, h_s + web_gusset_leg]]);
}

module cross_bracket() {
    difference() {
        union() {
            difference() {
                union() {
                    linear_extrude(height = g_out)
                        rounded_outline() cross_footprint_2d();
                    // The sleeve is s_out tall — 2*slide_clear more than
                    // the arms, keeping a full wall over the sliding fit.
                    linear_extrude(height = s_out)
                        rounded_outline()
                            square([sleeve_len, s_out], center = true);
                }
                // Through pocket for the foot tube: two opposed cutters,
                // so both mouths get the lead-in flare. No ribs — this
                // joint must slide.
                for (s = [-1, 1])
                    translate([s * sleeve_len / 2, 0, h_s]) rotate([0, s * 90, 0])
                        pocket_cut(sleeve_len / 2 + 1, s_in);
                // Toe pockets: blind ends are the sleeve side walls.
                for (s = [-1, 1]) toe_frame(s, h_s)
                    pocket_cut(toe_depth + bottom_gap, g_in);
            }
            if (crush_ribs)
                for (s = [-1, 1]) toe_frame(s, h_s)
                    pocket_ribs(toe_depth + bottom_gap, g_in, ["+x", "-x"]);
        }
        if (screw_holes) {
            for (s = [-1, 1])
                translate([-h_g - 1, s * (cross_arm_reach - 0.55 * toe_depth), h_g])
                    rotate([0, 0, -90]) screw_bore();
            // Lock screw: vertical, through the sleeve's top wall. Not a
            // backup here — it is what fixes the station on the tube.
            translate([0, 0, h_s])
                cylinder(h = s_out - h_s + 1, d = screw_d, $fn = 24);
        }
    }
}

// ============================================================
// END CAP
// Slip-on finisher for the four toe ends and the vertical top —
// covers the raw sawn aluminium. Modelled (and printed) closed
// face down, mouth up.
// ============================================================

module end_cap() {
    difference() {
        linear_extrude(height = cap_h)
            rounded_outline() square(cap_out, center = true);
        translate([0, 0, cap_h]) pocket_cut(cap_depth, cap_in);
    }
}

// ============================================================
// THREAD GENERATION
// (verbatim from magnet_pill_container.scad, which documents the
// method: linear_extrude(twist) over a disc plus a lobe whose
// angular width sets the axial thread profile — 45 deg flanks,
// self-supporting, right-handed.)
// ============================================================

// Angular half-width of the lobe that yields a given axial width.
function lobe_angle(axial_width, pitch) = (axial_width / 2) / pitch * 360;

// Boundary of the lobe, as a closed polygon.
function thread_lobe_pts(r_min, r_maj, p_root, p_crest,
                         flank_steps = 10, crest_steps = 16) =
    concat(
        [ for (k = [0 : flank_steps])
            let (t = k / flank_steps,
                 r = r_min  + (r_maj  - r_min ) * t,
                 p = p_root + (p_crest - p_root) * t)
            [r * cos(p), r * sin(p)] ],
        [ for (k = [1 : crest_steps - 1])
            let (p = p_crest - 2 * p_crest * k / crest_steps)
            [r_maj * cos(p), r_maj * sin(p)] ],
        [ for (k = [flank_steps : -1 : 0])
            let (t = k / flank_steps,
                 r = r_min  + (r_maj  - r_min ) * t,
                 p = -(p_root + (p_crest - p_root) * t))
            [r * cos(p), r * sin(p)] ]
    );

// 2D cross-section: round core plus the thread lobe.
module thread_profile_2d(r_min, r_maj, p_root, p_crest) {
    union() {
        circle(r = r_min);
        polygon(thread_lobe_pts(r_min, r_maj, p_root, p_crest));
    }
}

// The helical solid: core cylinder with a thread wrapped around
// it, starting at z = 0 and rising `turns` turns.
module thread_solid(r_min, r_maj, p_root, p_crest, turns, pitch = ts_pitch) {
    linear_extrude(height     = pitch * turns,
                   twist      = -360 * turns,
                   slices     = max(24, round(turns * 72)),
                   convexity  = 10)
        thread_profile_2d(r_min, r_maj, p_root, p_crest);
}

// Grip scallops, as cutters, evenly spaced around a cylinder.
module flute_ring(d_out, h, count, r, depth) {
    dist = d_out / 2 + r - depth;
    for (i = [0 : count - 1])
        rotate([0, 0, i * 360 / count])
            translate([dist, 0, -eps])
                cylinder(h = h + 2 * eps, r = r);
}

// ============================================================
// HEADBOARD CLAMP
// Slides over the vertical pole; a printed thumbscrew through the
// +Y boss presses the pole against the opposite bore wall. The
// 80 x 20 headboard plate faces +X — the same side the foot runs,
// so the headboard stands over the foot. Local origin: pole axis,
// bracket underside at z = 0. Prints in this orientation.
// ============================================================

// Female thread for the thumbscrew, as a cutter along +Z with
// z = 0 at the mouth (includes bore, thread and entry flare).
module ts_thread_negative(depth) {
    translate([0, 0, -eps])
        cylinder(h = depth + eps, r = ts_f_min_r);
    translate([0, 0, -ts_pitch])
        thread_solid(ts_f_min_r, ts_f_maj_r,
                     ts_f_phi_root, ts_f_phi_crest,
                     (depth + 2 * ts_pitch) / ts_pitch);
    translate([0, 0, -eps])
        cylinder(h = ts_lead + eps, r1 = ts_f_maj_r + ts_lead, r2 = ts_f_maj_r);
}

// The sliding bore, chamfered at both ends so it starts onto the
// pole squarely and does not scrape as it slides.
module clamp_bore_negative() {
    translate([0, 0, -eps])
        linear_extrude(clamp_h + 2 * eps)
            square(s_in, center = true);
    translate([0, 0, -eps])
        linear_extrude(sleeve_ch + eps,
                       scale = s_in / (s_in + 2 * sleeve_ch))
            square(s_in + 2 * sleeve_ch, center = true);
    translate([0, 0, clamp_h - sleeve_ch])
        linear_extrude(sleeve_ch + eps,
                       scale = (s_in + 2 * sleeve_ch) / s_in)
            square(s_in, center = true);
}

module clamp_bracket() {
    difference() {
        union() {
            // Sleeve.
            linear_extrude(clamp_h)
                rounded_outline() square(s_out, center = true);
            // Headboard plate, gussets and the sleeve footprint as ONE
            // outline. Every piece genuinely OVERLAPS its neighbour —
            // rounded_outline() erodes before dilating, which would
            // disconnect shapes that merely touch along an edge.
            linear_extrude(clamp_plate_h)
                rounded_outline() {
                    square(s_out, center = true);
                    translate([h_s, -clamp_plate_w / 2])
                        square([clamp_plate_t, clamp_plate_w]);
                    translate([h_s - 1, -h_s]) square([2, s_out]);
                    for (s = [-1, 1]) scale([1, s])
                        polygon([[h_s + 1, h_s + clamp_gusset],
                                 [h_s + 1, h_s - 1],
                                 [h_s - clamp_gusset, h_s - 1]]);
                }
            // Thumbscrew boss.
            translate([0, s_in / 2, clamp_screw_z])
                rotate([-90, 0, 0])
                    cylinder(h = boss_outer - s_in / 2, d = boss_d);
        }
        clamp_bore_negative();
        // Female thread, mouth at the boss face, cutting inward.
        translate([0, boss_outer, clamp_screw_z])
            rotate([90, 0, 0])
                ts_thread_negative(boss_thread);
        // Headboard screw holes.
        for (s = [-1, 1])
            translate([h_s - 1, s * (clamp_plate_w / 2 - clamp_hole_inset),
                       clamp_plate_h / 2])
                rotate([0, 90, 0])
                    cylinder(h = clamp_plate_t + 2, d = clamp_hole_d, $fn = 24);
    }
}

// Printed thumbscrew. Prints head DOWN: the external thread then
// rises in the good direction, 45 deg flanks self-supporting.
module clamp_thumbscrew() {
    // Knurled head.
    difference() {
        cylinder(h = ts_head_t, d = ts_head_d);
        flute_ring(ts_head_d, ts_head_t, ts_head_flutes, 1.6, 0.9);
    }
    // Threaded shaft.
    translate([0, 0, ts_head_t])
        thread_solid(ts_min_r, ts_maj_r, ts_phi_root, ts_phi_crest,
                     ts_len / ts_pitch);
    // Flat dog point that bears on the pole face.
    translate([0, 0, ts_head_t + ts_len - eps])
        cylinder(h = ts_tip_len + eps, d1 = ts_tip_d, d2 = ts_tip_d - 1);
}

// ============================================================
// VIEWS
// ============================================================

// The full side frame: printed parts in colour, aluminium as ghosts.
module assembly() {
    color("steelblue") corner_bracket();
    color("mediumseagreen") translate([cross_station, 0, 0]) cross_bracket();
    color("orange") translate([endt_x, 0, 0]) endt_bracket();

    // Aluminium, seated bottom_gap shy of each blind web.
    %translate([foot_x0, 0, tube_z]) rotate([0, 90, 0]) ghost_tube(foot_len);
    %translate([h_g, 0, vert_z0]) ghost_tube(vertical_len);
    for (s = [-1, 1]) {
        %translate([endt_x, s * (h_g + bottom_gap), tube_z])
            rotate([s > 0 ? -90 : 90, 0, 0]) ghost_tube(toe_len);
        %translate([cross_station, s * (h_s + bottom_gap), tube_z])
            rotate([s > 0 ? -90 : 90, 0, 0]) ghost_tube(toe_len);
    }

    // Headboard clamp on the pole, thumbscrew pressed home, and a
    // ghost slab where the headboard itself will stand.
    color("firebrick") translate([h_g, 0, clamp_demo_z]) clamp_bracket();
    color("gold") translate([h_g, tube / 2 + ts_tip_len + ts_len + ts_head_t,
                             clamp_demo_z + clamp_screw_z])
        rotate([90, 0, 0]) clamp_thumbscrew();
    %translate([h_g + h_s + clamp_plate_t, -300, 400])
        cube([20, 600, 1050]);

    if (caps) color("gold") {
        translate([h_g, 0, vert_z0 + vertical_len + cap_face])
            rotate([180, 0, 0]) end_cap();
        for (s = [-1, 1]) {
            translate([endt_x, s * (h_g + bottom_gap + toe_len + cap_face), tube_z])
                rotate([s > 0 ? 90 : -90, 0, 0]) end_cap();
            translate([cross_station, s * (h_s + bottom_gap + toe_len + cap_face), tube_z])
                rotate([s > 0 ? 90 : -90, 0, 0]) end_cap();
        }
    }
}

// Printplate layout — every part flat and support-free, inside the
// 270 x 270 bed centred on the origin. Positions are variables so
// the bed-fit check below stays honest if anything moves.
pp_corner = [-130, -125];  // corner, on its side, foot leg along +X
pp_endt   = [90, -55];     // end-T, floor down
pp_cross  = [-65, 90];     // cross, floor down, rotated 90 (long axis on X)
pp_caps   = [[40, 40], [80, 40], [120, 40], [40, 80], [80, 80]];

pp_min = [min(concat([pp_corner[0], pp_endt[0] - endt_foot_reach,
                      pp_cross[0] - cross_arm_reach],
                     [for (c = pp_caps) c[0] - cap_out / 2])),
          min(concat([pp_corner[1], pp_endt[1] - endt_arm_reach,
                      pp_cross[1] - cross_half_x],
                     [for (c = pp_caps) c[1] - cap_out / 2]))];
pp_max = [max(concat([pp_corner[0] + foot_leg_len, pp_endt[0] + h_g,
                      pp_cross[0] + cross_arm_reach],
                     [for (c = pp_caps) c[0] + cap_out / 2])),
          max(concat([pp_corner[1] + vert_leg_h, pp_endt[1] + endt_arm_reach,
                      pp_cross[1] + cross_half_x],
                     [for (c = pp_caps) c[1] + cap_out / 2]))];

assert(pp_max[0] - pp_min[0] <= 270 && pp_max[1] - pp_min[1] <= 270,
       "printplate layout exceeds the 270 x 270 bed");
echo(str("PRINTPLATE footprint: ", pp_max[0] - pp_min[0], " x ",
         pp_max[1] - pp_min[1], " mm (bed 270 x 270)"));

// ============================================================
// RENDER
// ============================================================
// No "exploded" part: each bracket is a one-piece print, already
// shown individually and in the assembly, so an exploded layout
// would duplicate the printplate.

if (part == "corner") {
    // On its side: layers run along both legs and the gusset.
    translate([-foot_leg_len / 2, -vert_leg_h / 2, h_g])
        rotate([-90, 0, 0]) corner_bracket();

} else if (part == "endt") {
    endt_bracket();

} else if (part == "cross") {
    cross_bracket();

} else if (part == "cap") {
    end_cap();

} else if (part == "clamp") {
    clamp_bracket();

} else if (part == "screw") {
    clamp_thumbscrew();

} else if (part == "clampset") {
    // One clamp + its thumbscrew, lazy-union items 1 and 2.
    // Print one set per pole (two sets for the pair of frames).
    clamp_bracket();
    translate([40, 0, 0]) clamp_thumbscrew();

} else if (part == "printplate") {
    // Each top-level statement is one lazy-union build item:
    // 1 corner, 2 end-T, 3 cross, 4 caps (x5, one object).
    translate([pp_corner[0], pp_corner[1], h_g]) rotate([-90, 0, 0]) corner_bracket();
    translate(pp_endt) endt_bracket();
    translate(pp_cross) rotate([0, 0, 90]) cross_bracket();
    union() { for (c = pp_caps) translate(c) end_cap(); }

} else if (part == "assembly") {
    assembly();

} else {
    echo("Unknown part — corner | endt | cross | cap | clamp | screw | clampset | printplate | assembly");
}
