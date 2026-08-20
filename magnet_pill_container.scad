// ============================================================
// Magnet Pill Container + Adjustable-Height Stand
//
// A magnet-storage case and the stand it lives on.
//
// THE CASE
//   * 13 mm bore, 80 mm usable depth.
//   * An open vertical slit down one side so the magnet stack
//     is visible from outside.
//   * A screw-on cap that finishes FLUSH with the body: the
//     closed case is one smooth 21 mm cylinder, no shoulder.
//
// THE STAND
//   * A weighted base plate with a hollow fill cavity in its
//     underside, closed by a snap-in cover.  Fill it with sand,
//     coins or shot for stability.  (Prefer sand or coins —
//     STEEL shot will be pulled at by the magnets.)
//   * A solid square tower rising from the centre.  Square so
//     the carrier cannot rotate, and so the case can be turned
//     to any of four faces.
//   * A holder that slides freely up the tower and is locked at
//     any height by a PRINTED thumbscrew — no hardware at all.
//     The case is NOT a separate clip-in part: its tube and the
//     sliding sleeve are one printed body, fused where they
//     overlap, with the viewing slit facing outward.  Nothing to
//     spring, rattle or work loose.  Only the cap comes off, and
//     it unscrews without disturbing the holder.
//
// Standalone — no external dependencies.  All thread geometry
// is generated from scratch (see THREAD GENERATION below); no
// thread library is used.  One generator serves both the cap
// thread and the thumbscrew.
//
// Coordinate system:
//   Z = up, origin at the centre of the base plate's underside
//   (i.e. on the print bed).  The case and the carrier are each
//   modelled in their own local frame with z = 0 at their base,
//   and are translated into place for the assembled view.
//
// Print orientation — every part prints WITHOUT supports:
//   * Base   — upright, tower pointing up.  The fill cavity
//              opens downward; its ceiling bridges over pockets
//              no wider than ~19 mm.  The first layer is a wide
//              square ring, so adhesion is good, but a brim
//              does no harm on a cold bed.
//   * Cover  — flat.
//   * Case   — upright, floor on the bed.  The bore opens
//              upward, the 45 deg thread flanks are self-
//              supporting, and the slit is a vertical slot with
//              a rounded top.
//   * Cap    — closed top DOWN, so the internal thread's 45 deg
//              overhangs print unsupported.
//   * Holder — upright, sleeve and case bottoms both on the bed.
//              Case and sleeve axes are parallel, so one
//              orientation suits both: the bore opens upward and
//              the 45 deg thread flanks stay self-supporting.
//              The thumbscrew's threaded hole is horizontal in
//              this orientation, so it is given extra radial
//              clearance to absorb the droop on its upper wall.
//   * Screw  — head DOWN, shaft up, so its external thread
//              prints in the good direction.
//
// All units: millimeters.
// ============================================================

/* [Part] */
// holder, cap/top, base, cover, thumbscrew, assembly/both, exploded
part = "assembly";  // [holder:Case + carrier (one part), post:Post, foot:Stabiliser foot, cap:Cap, base:Base + socket hub, cover:Base cover, thumbscrew:Thumbscrew, assembly:Assembled upright, horizontal:Laid flat, exploded:Print layout]

/* [Case] */
bore_d          = 13;    // Inner diameter of the tube
inner_depth     = 80;    // Usable depth for the magnet stack (includes the neck)
tube_floor_t    = 2.5;   // Thickness of the case's closed floor
neck_wall       = 1.35;  // Wall thickness of the threaded neck (thinnest section)
cap_wall        = 1.65;  // Side wall thickness of the cap
cap_top_t       = 2.5;   // Thickness of the cap's closed top

/* [Cap thread] */
thread_pitch    = 3;     // Axial rise per turn — coarse, so the cap opens fast
thread_depth    = 0.75;  // Radial depth of the thread (crest minus root)
thread_crest    = 0.75;  // Axial width of the flat crest
thread_root     = 0.75;  // Axial width of the flat root
thread_turns    = 3;     // Turns of engagement — sets the neck height
fit_clear_r     = 0.25;  // Radial clearance between male and female thread
fit_clear_ax    = 0.25;  // Axial (flank) clearance between male and female thread

/* [Slit] */
slit_w          = 3.5;   // Width of the viewing slit
slit_margin_bot = 3;     // Solid ring left between the floor and the slit
slit_margin_top = 3;     // Solid ring left between the slit and the neck
slit_angle      = 0;     // Rotates the slit.  0 = facing outward when mounted.

/* [Grip] */
flute_count     = 18;    // Number of grip scallops around the cap
flute_r         = 1.2;   // Radius of each scallop
flute_depth     = 0.55;  // How deep each scallop bites into the cap wall

/* [Base plate] */
plate_size      = 90;    // Square base plate, across the flats
plate_h         = 14;    // Total plate thickness
plate_ch        = 2.5;   // Chamfer on the plate's top and bottom edges
plate_corner_r  = 6;     // Corner rounding of the plate
cover_inset     = 7;     // Border left outside the cover rebate
cover_t         = 2;     // Thickness of the snap-in cover
cover_fit       = 0.15;  // Per-side clearance of the cover in its rebate
cav_inset       = 10;    // Border left outside the fill cavity
cav_depth       = 8;     // Depth of the fill cavity
cav_rib         = 3;     // Thickness of the cavity's bracing ribs
snap_d          = 0.45;  // Depth of the cover's retaining snap rib

/* [Post] */
post_size       = 20;    // Square post, across the flats
post_len        = 178;   // TOTAL length of the printed post, socketed part included
post_edge_ch    = 0.8;   // Chamfer along the post's four long edges.  Absorbs the
                         // elephant's foot from printing it lying down, and keeps
                         // the corners from binding in the square socket.
post_end_ch     = 1.5;   // Chamfer on BOTH ends — the post is symmetric, so either
                         // end can go into the socket

/* [Socket] */
hub_size        = 30;    // Square socket hub standing on the base plate
hub_h           = 20;    // Hub height above the plate's top face
hub_flare       = 8;     // 45 deg gusset where the hub meets the plate
hub_ch          = 1.5;   // Chamfer at the top of the hub
socket_clear    = 0.3;   // Per-side clearance of the post in the socket
socket_sink     = 8;     // How far the socket reaches down into the plate

/* [Holder] */
screw_side      = 90;    // Which face both clamp screws sit on, degrees about Z.
                         // 0 = the back (opposite the case), 90 = the right side.
                         // Keep this at +/-90 so that when the post is laid flat
                         // with the cases upward, the screws point sideways
                         // instead of down into the bench.
slide_clear     = 0.35;  // Per-side clearance between the sleeve and the tower
sleeve_wall     = 3;     // Wall thickness of the sliding sleeve
carrier_h       = 40;    // Height of the sleeve
case_merge      = 2;     // How deep the case tube sinks into the sleeve's outer
                         // face.  This overlap IS the weld between them, so more
                         // is stronger — but it must stay under sleeve_wall or
                         // the case would break through into the tower bore.

/* [Thumbscrew] */
ts_pitch        = 2.5;   // Thumbscrew thread pitch
ts_major_d      = 10;    // Thumbscrew thread major diameter
ts_depth        = 0.6;   // Radial depth of the thumbscrew thread
ts_crest        = 0.6;   // Axial width of its flat crest
ts_root         = 0.6;   // Axial width of its flat root
ts_len          = 12;    // Threaded shaft length — see ts_clamp_gap
ts_head_d       = 20;    // Knurled head diameter
ts_head_t       = 6;     // Knurled head thickness
ts_head_flutes  = 12;    // Grip scallops around the head
ts_tip_d        = 7;     // Flat dog point that bears on the tower
ts_tip_len      = 2;     // Length of that dog point
ts_clear_r      = 0.35;  // Radial clearance — larger than the cap's, because this
                         // female thread is printed on a horizontal axis
boss_d          = 17;    // Diameter of the thumbscrew boss on the sleeve
boss_len        = 8;     // How far the boss stands off the sleeve

/* [Stabiliser foot] */
foot_span       = 76;    // Total width of the foot across the beam
foot_len        = 40;    // Length of the foot along the beam
foot_pad_t      = 5;     // Thickness of the flat pad at its outer edges
foot_rise       = 16;    // How far the buttress climbs the sleeve's sides
foot_round      = 1.5;   // Corner rounding on the foot's profile
foot_screw_side = 180;   // Which face the foot's clamp screw sits on.  180 puts it
                         // opposite the pad, so it points UP when the beam is laid
                         // flat and the pad is on the bench.

/* [Assembly preview] */
demo_carrier_z  = 60;    // Holder height, used only for the upright view
demo_holder_z   = 30;    // Holder position along the beam, laid-flat view only
demo_foot_z     = 125;   // Foot position along the beam, laid-flat view only

/* [Magnets] */
// Informational only — used for the capacity report echoed at render time.
magnet_d        = 12;    // Diameter of one disc magnet
magnet_t        = 3;     // Thickness of one disc magnet

/* [Quality] */
$fa = 1;    // Minimum angle — 1 deg gives max 360 facets per full circle
$fs = 0.4;  // Minimum facet edge length (mm) — matched to a 0.4 mm nozzle

// ============================================================
// DERIVED
// ============================================================

eps = 0.01;

// --- Case: radial stack-up, working outward from the bore ---
bore_r        = bore_d / 2;
thread_min_r  = bore_r + neck_wall;                 // thread root radius
thread_maj_r  = thread_min_r + thread_depth;        // thread crest radius

// Female thread is the male grown by the clearances.
f_min_r       = thread_min_r + fit_clear_r;
f_maj_r       = thread_maj_r + fit_clear_r;

// A flush cap fixes the body OD: it is the thread crest plus the
// fit clearance plus the cap's own wall, on both sides.
cap_od        = 2 * (f_maj_r + cap_wall);
body_od       = cap_od;
body_r        = body_od / 2;

// --- Case: axial stack-up ------------------------------------
body_h        = tube_floor_t + inner_depth;         // total case height
neck_h        = thread_pitch * thread_turns;        // threaded neck height
neck_z0       = body_h - neck_h;                    // shoulder the cap seats on

thread_runout = thread_pitch / 4;                   // plain relief above the shoulder
male_z0       = neck_z0 + thread_runout;
male_turns    = (neck_h - thread_runout) / thread_pitch;

seat_clear    = 0.4;                                // cap stops on the shoulder, not the neck top
cap_inner_h   = neck_h + seat_clear;
cap_h         = cap_inner_h + cap_top_t;
case_h        = neck_z0 + cap_h;                    // closed height

// Female thread starts one whole pitch below the male's start
// (in cap-local coordinates), which keeps the two helices in
// phase — an integer number of pitches apart.
f_z0          = thread_runout - thread_pitch;
f_turns       = ceil((cap_inner_h - f_z0 + thread_pitch) / thread_pitch);

// --- Thread lobe angles (see THREAD GENERATION) --------------
phi_root      = lobe_angle(thread_pitch - thread_root, thread_pitch);
phi_crest     = lobe_angle(thread_crest, thread_pitch);

// Clearance widens the female lobe by fit_clear_ax/2 axially on
// each flank, i.e. by the same angle at every radius.
phi_clear     = lobe_angle(fit_clear_ax, thread_pitch);
f_phi_root    = phi_root  + phi_clear;
f_phi_crest   = phi_crest + phi_clear;

// --- Slit ----------------------------------------------------
slit_z0       = tube_floor_t + slit_margin_bot + slit_w / 2;
slit_z1       = neck_z0 - slit_margin_top - slit_w / 2;

// --- Chamfers ------------------------------------------------
lead_in       = thread_depth;   // thread lead-in chamfer, can't exceed the thread depth
edge_ch       = 0.6;            // cosmetic chamfer on outer edges

// --- Base plate ----------------------------------------------
cover_size    = plate_size - 2 * cover_inset;       // rebate across the flats
cav_size      = plate_size - 2 * cav_inset;         // fill cavity across the flats
cav_z0        = cover_t;                            // cavity floor (above the cover)
cav_z1        = cav_z0 + cav_depth;                 // cavity ceiling
plate_ceiling = plate_h - cav_z1;                   // solid roof over the cavity

// The post's load runs down a solid column through the plate, so
// the cavity is a ring around a central pad wider than the hub's
// gusset — and deep enough to take the socket.
pad_size      = hub_size + hub_flare + 2;

// --- Post and socket -----------------------------------------
hub_flare_h   = hub_flare / 2;                      // 45 deg gusset
hub_top       = plate_h + hub_h;
socket_size   = post_size + 2 * socket_clear;
socket_depth  = hub_h + socket_sink;                // hub plus the reach into the plate
socket_z0     = plate_h - socket_sink;              // socket floor
post_free     = post_len - socket_depth;            // length left standing proud
post_top      = hub_top + post_free;

// --- Carrier -------------------------------------------------
sleeve_in     = post_size + 2 * slide_clear;
sleeve_out    = sleeve_in + 2 * sleeve_wall;
// Case centre, set so the tube sinks case_merge into the sleeve face.
case_cy       = sleeve_out / 2 + body_r - case_merge;

// The thinnest section in the whole holder: the material left
// between the post bore and the case bore.
web_min       = (case_cy - bore_r) - sleeve_in / 2;

// Half-width of the lens where the case tube overlaps the sleeve's
// outer face — i.e. how wide the weld between them actually is.
weld_half_w   = sqrt(body_r * body_r - pow(case_cy - sleeve_out / 2, 2));

// Above the sleeve the case runs alongside the post with nothing
// between them.  Deeper case_merge is a stronger weld but a tighter
// gap here, so this is the other half of that trade.
post_gap      = case_cy - body_r - post_size / 2;
sleeve_ch     = 1.2;                                // chamfer on both ends of the sleeve bore
boss_z        = carrier_h / 2;
boss_reach    = sleeve_out / 2 + boss_len;          // axis to the boss's outer face
ts_hole_depth = boss_len + sleeve_wall + 1;         // breaks 1 mm into the slide bore

// The hub's boss is shortened so its outer face sits exactly as far
// from the axis as the holder's does.  One thumbscrew design then
// clamps both, with identical reach and identical travel.
hub_wall       = (hub_size - socket_size) / 2;
hub_boss_len   = boss_reach - hub_size / 2;
hub_boss_z     = plate_h + hub_h / 2;
hub_hole_depth = hub_boss_len + hub_wall + 1;

// Carrier travel along the post.  It cannot drop below the hub.
carrier_z_min = hub_top;
carrier_z_max = post_top - carrier_h;
holder_h      = max(carrier_h, body_h);

// --- Stabiliser foot -----------------------------------------
foot_boss_z   = foot_len / 2;
foot_half_w   = foot_span / 2;

// Roughly how far the rig can be tilted, laid flat, before the case
// takes it over: the case axis is the bulk of the mass and sits this
// high above the bench.
com_h         = sleeve_out / 2 + case_cy;
tip_angle     = atan(foot_half_w / com_h);
tip_bare      = atan(sleeve_out / 2 / com_h);   // without the foot

// The foot's clamp boss stands off the SAME side of the beam as the
// case does, so the two cannot be slid on top of one another.  This
// is how far apart along the beam they have to stay: measured base
// to base, with the foot on the case's side of the holder.
foot_min_gap  = case_h - (foot_boss_z - boss_d / 2);

// --- Thumbscrew ----------------------------------------------
ts_maj_r      = ts_major_d / 2;
ts_min_r      = ts_maj_r - ts_depth;
ts_f_min_r    = ts_min_r + ts_clear_r;
ts_f_maj_r    = ts_maj_r + ts_clear_r;
ts_phi_root   = lobe_angle(ts_pitch - ts_root, ts_pitch);
ts_phi_crest  = lobe_angle(ts_crest, ts_pitch);
ts_phi_clear  = lobe_angle(fit_clear_ax, ts_pitch);
ts_f_phi_root = ts_phi_root  + ts_phi_clear;
ts_f_phi_crest= ts_phi_crest + ts_phi_clear;
ts_lead       = 1.2;                                // entry flare on the female thread
ts_total_len  = ts_head_t + ts_len + ts_tip_len;

// How far the shaft reaches past the head, and therefore how far
// the head still stands off the boss when the dog point has
// clamped onto the tower.  The screw must be long enough to cross
// the boss, the sleeve wall and the slide clearance — but short
// enough that the head never bottoms out first.
ts_reach      = ts_len + ts_tip_len;
ts_clamp_gap  = ts_reach - (boss_reach - post_size / 2);

// --- Sanity guards -------------------------------------------
assert(f_phi_root < 175,
       "Cap thread root lobe is too wide — increase thread_pitch or reduce thread_root/clearances.");
assert(ts_f_phi_root < 175,
       "Thumbscrew thread root lobe is too wide — increase ts_pitch or reduce ts_root/clearances.");
assert(thread_crest + thread_root + 2 * thread_depth <= thread_pitch + eps,
       "Cap thread profile does not fit in one pitch — reduce thread_crest/thread_root/thread_depth.");
assert(ts_crest + ts_root + 2 * ts_depth <= ts_pitch + eps,
       "Thumbscrew thread profile does not fit in one pitch — reduce ts_crest/ts_root/ts_depth.");
assert(slit_z1 > slit_z0,
       "Slit margins leave no room for a slit — reduce slit_margin_top/bot or increase inner_depth.");
assert(cap_wall - flute_depth >= 0.8,
       "Grip flutes cut the cap wall too thin — reduce flute_depth or increase cap_wall.");
assert(case_merge < sleeve_wall - 0.3,
       "case_merge is deeper than the sleeve wall — the case would break through into the tower bore.");
assert(case_merge >= 1,
       "case_merge is too shallow to weld the case to the sleeve — raise it.");
assert(web_min >= 2.5,
       "Too little material between the tower bore and the case bore — raise sleeve_wall or lower case_merge.");
assert(post_gap >= 0.8,
       "Case would run too close to the post above the sleeve — lower case_merge or raise sleeve_wall.");
assert(socket_sink <= plate_h - cover_t - 2,
       "Socket reaches too deep into the plate — reduce socket_sink or thicken plate_h.");
assert(hub_boss_len >= 4,
       "Hub boss is too short to hold enough thread — widen boss_len or narrow hub_size.");
assert(hub_wall >= 3,
       "Too little meat around the socket for the clamp thread — widen hub_size.");
assert(post_free > carrier_h + 20,
       "Post barely projects from the hub — lengthen post_len.");
assert(foot_rise > foot_pad_t + 2,
       "Foot buttress must rise clear of its own pad — raise foot_rise.");
assert(foot_rise < sleeve_out,
       "Foot buttress climbs past the top of the sleeve — lower foot_rise.");
assert(foot_span > sleeve_out + 20,
       "Foot is no wider than the sleeve it replaces, so it stabilises nothing.");
assert(tip_angle > 25,
       "Foot is too narrow for how high the case sits — widen foot_span.");
assert(demo_foot_z - demo_holder_z >= foot_min_gap
       || demo_holder_z - demo_foot_z >= foot_len,
       "Preview places the foot's boss inside the case — separate demo_foot_z and demo_holder_z.");
assert(abs(screw_side) == 90 || screw_side == 0,
       "screw_side should be 0, 90 or -90 so the boss lands square on a face.");
assert(plate_ceiling >= 2.5,
       "Fill cavity leaves too thin a roof — reduce cav_depth or increase plate_h.");
assert(cav_size > pad_size + 2 * cav_rib,
       "Fill cavity is too small to clear the hub's central pad — increase plate_size.");
assert(carrier_z_max > carrier_z_min,
       "Post is too short for the holder — increase post_len or reduce carrier_h.");
assert(ts_tip_d / 2 < ts_min_r,
       "Thumbscrew dog point is wider than the thread core — reduce ts_tip_d.");
assert(ts_clamp_gap >= 1,
       "Thumbscrew is too short to reach the tower — increase ts_len or reduce boss_len.");
assert(ts_clamp_gap <= ts_len,
       "Thumbscrew is longer than it can ever be wound in — reduce ts_len.");

// ============================================================
// THREAD GENERATION
// ============================================================
//
// Built with linear_extrude(twist=...) over a polar wedge, not a
// hand-rolled polyhedron (fragile face winding) and not stacked
// rotate_extrude slices (staircased and slow).
//
// Under linear_extrude(height=H, twist=T), the horizontal slice
// at height z is the 2D shape rotated by -T*z/H.  Take
// H = pitch*turns and T = -360*turns, so a slice at z is rotated
// by +360*z/pitch — a helix of exactly one pitch per turn.
//
// Now let the 2D shape be a disc of radius r_min plus a lobe
// whose ANGULAR half-width phi(r) varies with radius.  A point
// at (r, theta, z) is solid iff |theta + 360*z/pitch| <= phi(r),
// i.e. iff z lies in an interval of axial half-height
//
//      phi(r) * pitch / 360
//
// repeating every pitch.  So the AXIAL profile of the thread is
// read straight off the lobe's angular width: wide at the root
// and narrow at the crest gives a trapezoidal thread.  With
// pitch 3, a 0.75 mm crest and a 0.75 mm root that is
// phi = 135 deg at the root tapering to 45 deg at the crest,
// which yields 45 deg flanks — self-supporting when printed.
//
// twist = -360*turns makes it RIGHT-handed: OpenSCAD's positive
// twist rotates clockwise going up, and a right-hand helix
// advances counter-clockwise.  Both halves of a pair come from
// this one module, so their handedness and lead always agree.

// Angular half-width of the lobe that yields a given axial width.
function lobe_angle(axial_width, pitch) = (axial_width / 2) / pitch * 360;

// Boundary of the lobe, as a closed polygon.  Traverses the +phi
// flank outward, the crest arc, then the -phi flank inward; the
// polygon closes on a straight chord across the back, which lies
// inside the r_min disc it is unioned with.
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

// The helical solid: core cylinder of radius r_min with a thread
// wrapped around it, starting at z = 0 and rising `turns` turns.
module thread_solid(r_min, r_maj, p_root, p_crest, turns, pitch = thread_pitch) {
    linear_extrude(height     = pitch * turns,
                   twist      = -360 * turns,
                   slices     = max(24, round(turns * 72)),
                   convexity  = 10)
        thread_profile_2d(r_min, r_maj, p_root, p_crest);
}

// ============================================================
// SHARED HELPERS
// ============================================================

// Ring-shaped cutter that chamfers an outside edge.  Removes
// everything outside a cone running from radius r1 at the bottom
// to r2 at the top, over height h.
module outer_chamfer(h, r1, r2, outer = 200) {
    difference() {
        cylinder(h = h, r = outer);
        translate([0, 0, -eps])
            cylinder(h = h + 2 * eps, r1 = r1, r2 = r2);
    }
}

// Grip scallops, as cutters, evenly spaced around a cylinder of
// diameter d_out.  Subtracted rather than added, so a flush
// outer diameter is preserved.
module flute_ring(d_out, h, count, r, depth) {
    dist = d_out / 2 + r - depth;
    for (i = [0 : count - 1])
        rotate([0, 0, i * 360 / count])
            translate([dist, 0, -eps])
                cylinder(h = h + 2 * eps, r = r);
}

// Square with optionally rounded corners, centred.
module rounded_square(sx, sy, r) {
    if (r > 0.05) offset(r = r) square([sx - 2 * r, sy - 2 * r], center = true);
    else          square([sx, sy], center = true);
}

// Box with chamfered top AND bottom edges and rounded corners.
module chamfered_box(sx, sy, sz, ch, cr = 0) {
    hull() {
        translate([0, 0, ch])
            linear_extrude(sz - 2 * ch) rounded_square(sx, sy, cr);
        linear_extrude(sz)
            rounded_square(sx - 2 * ch, sy - 2 * ch, max(cr - ch, 0));
    }
}

// ============================================================
// CASE — body
// ============================================================

// Vertical viewing slit: a rounded-end slot cut radially through
// one wall.  The rounded top means no horizontal bridge to print
// and no sharp stress riser in a tube that is already open.
module slit_cut() {
    rotate([0, 0, slit_angle])
        rotate([90, 0, 0])
            linear_extrude(height = body_r + 1, convexity = 4)
                hull() {
                    translate([0, slit_z0]) circle(r = slit_w / 2);
                    translate([0, slit_z1]) circle(r = slit_w / 2);
                }
}

module case_body() {
    difference() {
        union() {
            // Main tube, up to the shoulder.
            cylinder(h = neck_z0, r = body_r);

            // Rebated neck: its core sits well inside the body OD,
            // leaving room for the cap wall so the closed case is
            // flush.
            translate([0, 0, neck_z0])
                cylinder(h = neck_h, r = thread_min_r);

            // Male thread, starting a short runout above the
            // shoulder so the cap's rim can reach the shoulder.
            translate([0, 0, male_z0])
                thread_solid(thread_min_r, thread_maj_r,
                             phi_root, phi_crest, male_turns);
        }

        // Bore.
        translate([0, 0, tube_floor_t])
            cylinder(h = body_h - tube_floor_t + 1, r = bore_r);

        // Viewing slit.
        slit_cut();

        // Lead-in chamfer on the top of the neck, so the cap
        // starts onto the thread easily.
        translate([0, 0, body_h - lead_in])
            outer_chamfer(lead_in + eps, thread_maj_r, thread_maj_r - lead_in);

        // Ease the mouth of the bore so magnets drop in.
        translate([0, 0, body_h - 1])
            cylinder(h = 1 + eps, r1 = bore_r, r2 = bore_r + 1);

        // Cosmetic chamfer on the outer base edge.
        translate([0, 0, -eps])
            outer_chamfer(edge_ch + eps, body_r - edge_ch, body_r);
    }
}

// ============================================================
// CASE — cap
// ============================================================
//
// Local frame: z = 0 at the open rim, z = cap_h at the closed
// top.  This is the assembled orientation; the print orientation
// (upside down) is applied in the render section.

// Everything the cap's inside has to clear: the neck core plus
// the male thread, both grown by the fit clearances.  Clipped
// flat at cap_inner_h so the cap's top stays solid.
module cap_bore_negative() {
    intersection() {
        union() {
            translate([0, 0, -10])
                cylinder(h = cap_inner_h + 10, r = f_min_r);

            translate([0, 0, f_z0])
                thread_solid(f_min_r, f_maj_r,
                             f_phi_root, f_phi_crest, f_turns);
        }

        translate([0, 0, -10])
            cylinder(h = 10 + cap_inner_h, r = body_r + 2);
    }
}

module case_cap() {
    difference() {
        cylinder(h = cap_h, r = cap_od / 2);

        // Threaded bore.
        cap_bore_negative();

        // Lead-in flare at the open rim.
        translate([0, 0, -eps])
            cylinder(h = lead_in + eps, r1 = f_maj_r + lead_in, r2 = f_maj_r);

        // Grip.
        flute_ring(cap_od, cap_h, flute_count, flute_r, flute_depth);

        // Cosmetic chamfer on the closed top edge.
        translate([0, 0, cap_h - edge_ch])
            outer_chamfer(edge_ch + eps, cap_od / 2, cap_od / 2 - edge_ch);

        // Cosmetic chamfer on the rim edge.
        translate([0, 0, -eps])
            outer_chamfer(edge_ch + eps, cap_od / 2 - edge_ch, cap_od / 2);
    }
}

// ============================================================
// STAND — base plate and tower
// ============================================================

// Solid square tower, rising from the plate's top face.  Solid
// rather than shelled: the slicer's infill is a far cheaper way
// to hollow a 150 mm column than modelled walls, which would
// slice as 100 % perimeter.  Solid also gives the thumbscrew a
// proper bearing face instead of a thin wall to dent.
// The post: a plain square bar, chamfered along its length and at
// BOTH ends, so either end can drop into the socket.  Modelled with
// z = 0 at one end; the render section lays it on its side, which is
// how it prints.  Lying down puts the bending stress ALONG the
// extrusions rather than across the layer bonds, so it is markedly
// stronger this way than printed standing up — and far less likely
// to fail as a print.
module post_blank() {
    hull() {
        // Full section, held back from both ends by the end chamfer.
        translate([0, 0, post_end_ch])
            linear_extrude(post_len - 2 * post_end_ch)
                rounded_square(post_size, post_size, 0.01);

        // Shrunken sections at the very ends produce the end chamfers,
        // while the long edges stay chamfered by post_edge_ch.
        linear_extrude(post_len)
            square(post_size - 2 * post_end_ch, center = true);
    }
}

// Chamfer cutters for the post's four long edges.
module post_edge_chamfers() {
    for (a = [0, 90, 180, 270])
        rotate([0, 0, a])
            translate([post_size / 2, post_size / 2, -1])
                rotate([0, 0, 45])
                    linear_extrude(post_len + 2)
                        square([post_edge_ch * 1.414, post_edge_ch * 1.414],
                               center = true);
}

module post() {
    difference() {
        post_blank();
        post_edge_chamfers();
    }
}

// The socket hub: a square tower stub on the plate with the post's
// socket bored down through it and on into the plate's solid pad.
module socket_hub() {
    translate([0, 0, plate_h]) {
        // 45 deg gusset where the hub meets the plate.
        linear_extrude(hub_flare_h, scale = hub_size / (hub_size + hub_flare))
            square(hub_size + hub_flare, center = true);

        translate([0, 0, hub_flare_h])
            linear_extrude(hub_h - hub_flare_h - hub_ch)
                square(hub_size, center = true);

        // Top chamfer.
        translate([0, 0, hub_h - hub_ch])
            linear_extrude(hub_ch, scale = (hub_size - 2 * hub_ch) / hub_size)
                square(hub_size, center = true);
    }
}

// Everything the socket has to remove: the bore itself plus a lead-in
// flare at its mouth so the post starts in squarely.
module socket_negative() {
    translate([0, 0, socket_z0])
        linear_extrude(socket_depth + eps)
            square(socket_size, center = true);

    translate([0, 0, hub_top - hub_ch])
        linear_extrude(hub_ch + eps,
                       scale = socket_size / (socket_size + 2 * hub_ch))
            square(socket_size + 2 * hub_ch, center = true);
}

// The fill cavity: a ring of pockets around a solid central pad,
// braced by four ribs.  The pad carries the tower's load straight
// down to the cover, and the ribs keep every bridged span short.
module fill_cavity() {
    // Starts just below the rebate floor rather than exactly on it —
    // coincident faces there survive CGAL but make fragile geometry.
    translate([0, 0, cav_z0 - eps])
        linear_extrude(cav_depth + eps)
            difference() {
                rounded_square(cav_size, cav_size, plate_corner_r / 2);

                // Central load-bearing pad under the tower.
                square(pad_size, center = true);

                // Bracing ribs on both axes.
                square([cav_size + 2, cav_rib], center = true);
                square([cav_rib, cav_size + 2], center = true);
            }
}

module base_plate_solid() {
    union() {
        difference() {
            chamfered_box(plate_size, plate_size, plate_h, plate_ch, plate_corner_r);

            // Cover rebate, open downward.
            translate([0, 0, -eps])
                linear_extrude(cover_t + eps)
                    rounded_square(cover_size, cover_size, plate_corner_r / 2);

            // Snap groove that retains the cover's rib.
            translate([0, 0, cover_t / 2 - 0.45])
                linear_extrude(0.9)
                    difference() {
                        rounded_square(cover_size + 2 * snap_d,
                                       cover_size + 2 * snap_d, plate_corner_r / 2);
                        rounded_square(cover_size - 2, cover_size - 2, 1);
                    }

            // Weight cavity.
            fill_cavity();
        }

        socket_hub();

        // Clamp station that locks the post into the socket.
        clamp_boss(boss_reach, hub_boss_len, hub_boss_z);
    }
}

module base_plate() {
    difference() {
        base_plate_solid();
        socket_negative();
        clamp_hole(boss_reach, hub_boss_z, hub_hole_depth);
    }
}

// Snap-in cover that closes the fill cavity.
module base_cover() {
    cs = cover_size - 2 * cover_fit;
    union() {
        // Plate, with a chamfered leading edge to start it in.
        hull() {
            linear_extrude(0.8)
                rounded_square(cs - 1.2, cs - 1.2, plate_corner_r / 2);
            translate([0, 0, 0.8])
                linear_extrude(cover_t - 0.8)
                    rounded_square(cs, cs, plate_corner_r / 2);
        }

        // Retaining rib, sized to click into the plate's groove.
        translate([0, 0, cover_t / 2 - 0.35])
            linear_extrude(0.7)
                rounded_square(cs + 2 * (snap_d - 0.1),
                               cs + 2 * (snap_d - 0.1), plate_corner_r / 2);
    }
}

// ============================================================
// STAND — holder (case + carrier, one part)
// ============================================================

// A thumbscrew clamp station.  `reach` is the distance from the
// clamped axis out to the boss's outer face, so the holder and the
// socket hub can share one screw by sharing one reach.
module clamp_boss(reach, len, z, side = screw_side) {
    rotate([0, 0, side])
        translate([0, -reach, z])
            rotate([-90, 0, 0])
                cylinder(h = len + 2, d = boss_d);
}

module clamp_hole(reach, z, depth, side = screw_side) {
    rotate([0, 0, side])
        translate([0, -reach, z])
            rotate([-90, 0, 0])
                ts_thread_negative(depth);
}

// Places a thumbscrew where it clamps, for the assembled views.
module clamp_screw(reach, z, side = screw_side) {
    rotate([0, 0, side])
        translate([0, -reach - ts_head_t - ts_clamp_gap, z])
            rotate([-90, 0, 0])
                thumbscrew();
}

// Everything a sliding sleeve of height h has to remove: the square
// bore, chamfered at both ends so it starts onto the post easily and
// does not scrape as it slides.  Shared by the holder and the foot.
module sleeve_bore_negative(h) {
    translate([0, 0, -eps])
        linear_extrude(h + 2 * eps)
            square(sleeve_in, center = true);

    translate([0, 0, -eps])
        linear_extrude(sleeve_ch + eps,
                       scale = sleeve_in / (sleeve_in + 2 * sleeve_ch))
            square(sleeve_in + 2 * sleeve_ch, center = true);

    translate([0, 0, h - sleeve_ch])
        linear_extrude(sleeve_ch + eps,
                       scale = (sleeve_in + 2 * sleeve_ch) / sleeve_in)
            square(sleeve_in, center = true);
}

// Female thread for the thumbscrew, as a cutter along +Z with
// z = 0 at the mouth.
module ts_thread_negative(depth) {
    union() {
        translate([0, 0, -eps])
            cylinder(h = depth + eps, r = ts_f_min_r);

        translate([0, 0, -ts_pitch])
            thread_solid(ts_f_min_r, ts_f_maj_r,
                         ts_f_phi_root, ts_f_phi_crest,
                         (depth + 2 * ts_pitch) / ts_pitch, ts_pitch);

        // Entry flare, so the screw starts square.
        translate([0, 0, -eps])
            cylinder(h = ts_lead + eps, r1 = ts_f_maj_r + ts_lead, r2 = ts_f_maj_r);
    }
}

// Case and sleeve as ONE body.  The two are parallel vertical
// tubes whose walls overlap by case_merge, so the union welds them
// over the full height of the sleeve — no clip, no shelf, no
// sprung arm, and nothing that can rattle or fatigue.  The case is
// turned 180 deg so that slit_angle = 0 faces the slit outward,
// away from the tower.
module holder() {
    difference() {
        union() {
            // Sliding sleeve.
            linear_extrude(carrier_h)
                rounded_square(sleeve_out, sleeve_out, 2);

            // Thumbscrew boss.  screw_side puts it on a SIDE face, so
            // that with the post laid flat and the case upward the
            // screw points sideways rather than into the bench.
            clamp_boss(boss_reach, boss_len, boss_z);

            // The case itself.
            translate([0, case_cy, 0])
                rotate([0, 0, 180])
                    case_body();
        }

        sleeve_bore_negative(carrier_h);

        // Threaded hole for the thumbscrew.
        clamp_hole(boss_reach, boss_z, ts_hole_depth);
    }
}

// ============================================================
// STAND — stabiliser foot
// ============================================================
//
// Laid flat, the rig rests on a strip only as wide as a sleeve, with
// the loaded case sitting well above it — so it rolls over easily.
// This is the same sliding-sleeve-plus-thumbscrew clamp as the
// holder, but instead of a case it carries a buttressed pad that
// spreads sideways.
//
// The pad's underside is deliberately flush with the sleeve's own
// bottom face, which is the same plane the holder's sleeve rests on.
// So the rig sits on two coplanar patches spread along the beam:
// wide across, and supported fore and aft.
//
// Its clamp screw sits opposite the pad, so it points straight UP
// when the beam is laid flat and the pad is on the bench.
//
// Prints exactly like the holder — sleeve axis vertical.  The whole
// body is one constant cross-section extruded along that axis, so
// there is not a single overhang in it.

module foot_profile_2d() {
    hw = foot_span / 2;
    sh = sleeve_out / 2;

    // Shrink-then-grow rounds the convex corners and leaves the flat
    // bottom flat.
    offset(r = foot_round) offset(r = -foot_round)
        polygon([
            [-hw, -sh],
            [ hw, -sh],
            [ hw, -sh + foot_pad_t],
            [ sh, -sh + foot_rise],
            [-sh, -sh + foot_rise],
            [-hw, -sh + foot_pad_t]
        ]);
}

module foot() {
    difference() {
        union() {
            linear_extrude(foot_len)
                rounded_square(sleeve_out, sleeve_out, 2);

            linear_extrude(foot_len)
                foot_profile_2d();

            clamp_boss(boss_reach, boss_len, foot_boss_z, foot_screw_side);
        }

        sleeve_bore_negative(foot_len);

        clamp_hole(boss_reach, foot_boss_z, ts_hole_depth, foot_screw_side);
    }
}

// ============================================================
// STAND — printed thumbscrew
// ============================================================
//
// Prints head DOWN: the external thread then rises in the good
// direction and its 43 deg flanks are self-supporting.

module thumbscrew() {
    union() {
        // Knurled head.
        difference() {
            cylinder(h = ts_head_t, d = ts_head_d);

            flute_ring(ts_head_d, ts_head_t, ts_head_flutes, 1.6, 0.9);

            translate([0, 0, -eps])
                outer_chamfer(edge_ch + eps, ts_head_d / 2 - edge_ch, ts_head_d / 2);
            translate([0, 0, ts_head_t - edge_ch])
                outer_chamfer(edge_ch + eps, ts_head_d / 2, ts_head_d / 2 - edge_ch);
        }

        // Threaded shaft.
        translate([0, 0, ts_head_t])
            thread_solid(ts_min_r, ts_maj_r, ts_phi_root, ts_phi_crest,
                         ts_len / ts_pitch, ts_pitch);

        // Flat dog point that bears on the tower face.
        translate([0, 0, ts_head_t + ts_len - eps])
            cylinder(h = ts_tip_len + eps, d1 = ts_tip_d, d2 = ts_tip_d - 1);
    }
}

// ============================================================
// ASSEMBLY
// ============================================================

module stand_assembled(z = demo_carrier_z) {
    // Clamp to what the tower can actually offer, so the preview
    // cannot show the sleeve buried in the root gusset.
    carrier_z = min(max(z, carrier_z_min), carrier_z_max);

    base_plate();

    base_cover();

    // The post, dropped into its socket.
    translate([0, 0, socket_z0]) post();

    // Thumbscrew locking the post into the hub.
    clamp_screw(boss_reach, hub_boss_z);

    translate([0, 0, carrier_z]) {
        holder();

        // Rotated with the case: turning the case 180 deg shifts its
        // helix phase by half a pitch, so the cap must follow.
        translate([0, case_cy, neck_z0]) rotate([0, 0, 180]) case_cap();

        // Thumbscrew, wound in until its dog point clamps the post.
        clamp_screw(boss_reach, boss_z);
    }
}

// ============================================================
// REPORT
// ============================================================

magnet_count = floor(inner_depth / magnet_t);
visible_span = slit_z1 - slit_z0 + slit_w;
// Cavity is the square ring between cav_size and the central pad,
// less the ribs — which exist only OUTSIDE the pad, hence the
// (cav_size - pad_size) rib span rather than the full cav_size.
cav_volume   = (cav_size * cav_size - pad_size * pad_size
                - 2 * cav_rib * (cav_size - pad_size)) * cav_depth / 1000;

echo(str("CASE   OD ", body_od, " mm, closed height ", case_h,
         " mm, bore ", bore_d, " mm, wall ", (body_od - bore_d) / 2, " mm"));
echo(str("CASE   thread M", thread_maj_r * 2, " x ", thread_pitch,
         " right-hand, ", male_turns, " turns engaged, neck wall ", neck_wall, " mm"));
echo(str("CASE   holds ", magnet_count, " x ", magnet_t,
         " mm magnets; ", visible_span, " mm of the stack visible through the slit"));
echo(str("STAND  base ", plate_size, " x ", plate_size, " x ", plate_h,
         " mm with a ", hub_size, " mm hub ", hub_h, " mm tall"));
echo(str("POST   ", post_size, " mm square x ", post_len,
         " mm printed LYING DOWN; ", socket_depth, " mm sits in the socket, ",
         post_free, " mm stands proud.  Overall height ", post_top, " mm"));
echo(str("POST   removable: one thumbscrew in the hub.  Up to ",
         floor(post_free / carrier_h), " holders fit on the free length"));
echo(str("STAND  fill cavity ", cav_volume,
         " cm3  ~=  ", round(cav_volume * 1.6), " g of sand, ",
         round(cav_volume * 6.5), " g of lead shot"));
echo(str("STAND  holder travel ", carrier_z_min, " to ", carrier_z_max,
         " mm  (", carrier_z_max - carrier_z_min, " mm of adjustment)"));
echo(str("STAND  case floor sits ", carrier_z_min, " to ",
         carrier_z_max, " mm above the bench; case top reaches ",
         carrier_z_max + case_h, " mm"));
echo(str("HOLDER case and sleeve are ONE part, ", holder_h,
         " mm tall; welded over a ", 2 * weld_half_w,
         " mm wide lens, ", carrier_h, " mm of height"));
echo(str("HOLDER thinnest section (post bore to case bore): ", web_min,
         " mm; case clears the post by ", post_gap, " mm above the sleeve"));
echo(str("FOOT   ", foot_span, " x ", foot_len,
         " mm pad, flush with the holder's sleeve so both sit on the bench"));
echo(str("FOOT   laid flat, tips at about ", tip_angle, " deg with the foot vs ",
         tip_bare, " deg on the bare sleeve alone"));
echo(str("SCREW  M", ts_major_d, " x ", ts_pitch, " printed thumbscrew, ",
         ts_len, " mm of thread, ", ts_head_d, " mm knurled head.  PRINT THREE: ",
         "holder, foot, and the post lock in the hub"));
echo(str("SCREW  holder and hub screws sit on face ", screw_side,
         " deg; the foot's on face ", foot_screw_side,
         " deg.  None point into the bench when the beam is laid flat"));
echo(str("FOOT   keep it at least ", foot_min_gap,
         " mm along the beam from the holder's base — its boss shares the",
         " case's side of the beam"));

if (magnet_d > bore_d - 0.4)
    echo(str("WARNING: magnet_d ", magnet_d, " mm is a tight/interference fit in a ",
             bore_d, " mm bore — increase bore_d to at least ", magnet_d + 0.4, " mm."));

if (magnet_d < slit_w + 2)
    echo(str("WARNING: magnet_d ", magnet_d,
             " mm is small relative to the ", slit_w,
             " mm slit — magnets could escape.  Narrow slit_w."));

if (post_len > 250)
    echo(str("NOTE: the post is ", post_len,
             " mm long — check it fits your bed lying down."));

// ============================================================
// RENDER
// ============================================================

if (part == "holder" || part == "case" || part == "carrier" || part == "bottom") {

    holder();

} else if (part == "cap" || part == "top") {

    case_cap();

} else if (part == "post") {

    // Print orientation: lying on one face.
    translate([0, 0, post_size / 2])
        rotate([0, 90, 0])
            post();

} else if (part == "foot") {

    foot();

} else if (part == "base") {

    base_plate();

} else if (part == "cover") {

    base_cover();

} else if (part == "thumbscrew") {

    thumbscrew();

} else if (part == "horizontal") {

    // The other way this gets used: post pulled out of the base and
    // laid on the bench, cases pointing UP and both thumbscrews
    // pointing sideways rather than down into the bench.  The rig
    // rests on the holder's sleeve, which stands proud of the post.
    translate([0, 0, sleeve_out / 2])
        rotate([0, 0, 90]) rotate([90, 0, 0]) {
            post();

            translate([0, 0, demo_holder_z]) {
                holder();
                translate([0, case_cy, neck_z0]) rotate([0, 0, 180]) case_cap();
                clamp_screw(boss_reach, boss_z);
            }

            // Stabiliser further along the beam, so the rig is
            // supported fore and aft as well as spread sideways.
            translate([0, 0, demo_foot_z]) {
                foot();
                clamp_screw(boss_reach, foot_boss_z, foot_screw_side);
            }
        }

} else if (part == "exploded") {

    // Every part in its print orientation, laid out on the bed.
    // Fits comfortably inside 270 x 270 mm.  Two thumbscrews.
    translate([-58, -58, 0])  base_plate();
    translate([ 55, -58, 0])  base_cover();
    translate([-50,  15, 0])  foot();
    translate([ 25,  10, 0])  holder();
    translate([ 70,  10, cap_h]) rotate([180, 0, 0]) case_cap();
    translate([ 70,  35, 0])  thumbscrew();
    translate([ 70,  62, 0])  thumbscrew();
    translate([ 70,  89, 0])  thumbscrew();
    translate([-89, 118, post_size / 2]) rotate([0, 90, 0]) post();

} else {  // "assembly" / "both"

    stand_assembled();

}
