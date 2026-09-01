// ============================================================
// Saw Guide Jig — 20 mm Aluminium Square Tube  (v2, diamond bore)
//
// A miter-box-style jig for cutting 20x20 aluminium square tube
// dead square, with two guide slots:
//
//   * a JIGSAW slot for a Ryobi jigsaw with a T-shank metal
//     blade (T118A-class). The saw's shoe rides on the flat
//     winged top platform and the blade runs in a kerf slot
//     through the platform and both side walls.
//   * a HACKSAW slot further along, a narrower kerf guided the
//     same way, bottoming 3 mm below the tube so the last stroke
//     cannot dive.
//
// v2 changes:
//   * The tube tunnel is a DIAMOND — the square bore rotated 45
//     degrees, so the tube rides on its corner. Every internal
//     surface is now a 45 degree slope: NO bridges anywhere in
//     the print (v1 had two 20.7 mm flat bridges). The tube
//     self-centres in the V and the bottom-vertex relief groove
//     doubles as the burr/chip channel.
//   * CENTIMETRE REGISTRATION: front face -> jigsaw kerf centre
//     = 60, jigsaw -> hacksaw = 50, hacksaw -> back face = 30 mm.
//     Every reference lands on a whole centimetre. Engraved
//     rulers on both ear tops (cm numerals, 5 mm minors) and
//     tick lines on the wing edges at tube height.
//   * SHOE FENCE: a rail across the platform in front of the
//     jigsaw slot. The side of the shoe rides against it while
//     the saw advances — the slot steers the blade, the fence
//     steers the machine. Its offset MUST be measured off the
//     actual saw (blade to shoe edge).
//   * TUBE LOCK: a printed M10x2.5 thumbscrew (thread numbers
//     proven in magnet_pill_container / headboard clamp) threads
//     down through the wing flare at 45 degrees, normal to the
//     tube's upper face, and presses the tube flat into the
//     opposite V face. It comes from ABOVE-outside on purpose:
//     a screw from below would lift the tube out of its seat.
//     It sits on the back land, clear of the jigsaw shoe.
//
// The tunnel rides HIGH in the block: a metal jigsaw blade hangs
// ~66 mm below the shoe at the bottom of its stroke, so an open
// gabled cavity under the tunnel swallows the whole blade. The
// tip never reaches the bench — the jig sits flat anywhere.
//
// The jigsaw slot severs everything above the base plate at its
// station; the full-width base plate and the ear flanges are the
// tie that keeps the jig one piece there. The ears run the whole
// length, so clamp wherever suits — two F-clamps, one each side
// of the cut, is the intended setup.
//
// USE:
//   1. Clamp the ears flat to the bench.
//   2. Feed the tube in from the BACK mouth (the thumbscrew
//      grips the stock side; the offcut leaves at the front).
//   3. Set the length against the ear rulers (kerf centres sit
//      exactly on the 6 and 11 cm marks; a cut piece keeps half
//      the kerf, so measure to the kerf centre) and snug the
//      thumbscrew — firm, not gorilla: it is plastic on
//      aluminium and only needs to stop axial creep.
//   4. Jigsaw: orbital/pendulum action OFF for aluminium. Rest
//      the blade in the slot on either side of the tube first —
//      the slot is open past both walls, so any blade length
//      hangs free ("garage") — then start the saw with the shoe
//      pressed lightly sideways against the fence and advance.
//      Keep that side pressure on all the way through the cut.
//   5. Hacksaw: drop the blade into the narrow slot, cut until
//      it bottoms out 3 mm below the tube.
//
// MEASURE BEFORE PRINTING (calipers):
//   * jig_blade_t — YOUR blade's body thickness. Teeth are set
//     slightly wider and will shave the slot's leading face on
//     the first cut; that is normal and self-clearing.
//   * fence_offset — blade to the shoe's side edge on YOUR saw,
//     and check fence_h clears the saw body's side profile.
//   * jig_reach — blade tip below the shoe sole, blade fitted,
//     at the BOTTOM of the stroke. Sets the jig height.
//   * tube — the real tube stock (house rule: never model to a
//     recalled dimension).
//
// Material: PETG or ABS preferred over PLA — the slot faces see
// friction heat. Plenty of walls/infill around the slots.
//
// Coordinate system (as printed AND as used — no flip):
//   z = 0 bed/bench, tube axis along +X at y = 0.
//   x = 0 front face; the jigsaw slot is nearer the front.
//   The thumbscrew boss is on the +Y wing, back land.
//
// Standalone — no external dependencies.
//
// All units: millimeters.
//
// Export:
//   openscad -o saw_guide_jig.stl       -D 'part="jig"'   saw_guide_jig.scad
//   openscad -o saw_guide_jig_screw.stl -D 'part="screw"' saw_guide_jig.scad
//   make saw_guide_jig     (printplate: jig + thumbscrew)
// ============================================================

/* [Tube] */
tube        = 20;    // Square tube outer size — MEASURED off the stock
tube_wall   = 1.5;   // Tube wall — ghost geometry only, nothing printed uses it
slide_clear = 0.35;  // Per side — must slide through, house norm (headboard sleeve)
tun_relief  = 1.0;   // Corner relief at all four bore vertices, so the tube's
                     // arris never binds (collar lesson) — the bottom one
                     // doubles as the burr/chip channel

/* [Stations] */
// Kerf CENTRES and overall length, all on whole centimetres so
// the ear rulers, both kerfs and both faces line up on cm marks.
jig_station  = 60;   // Front face to the jigsaw kerf centre
hack_station = 110;  // Front face to the hacksaw kerf centre
jig_len      = 140;  // Front face to back face

/* [Jigsaw] */
jig_blade_t    = 1.0;  // Blade BODY thickness — MEASURE, teeth set is wider
jig_slot_clear = 0.35; // Total kerf clearance over the body. Under ~0.15 the
                       // blade binds and friction-melts the faces; over ~0.5
                       // it can yaw and the cut wanders
jig_reach      = 66;   // Blade tip below the shoe sole at BOTTOM of stroke —
                       // MEASURE with the blade fitted. T118A-class ~66
jig_stroke     = 25;   // Stroke length, worst case for a Ryobi (~19-25)
jig_tip_margin = 6;    // Clearance under the deepest tip travel
shoe_w         = 80;   // Shoe width ACROSS the cut — it spans the slot and
                       // bears on the lands either side
shoe_len       = 150;  // Shoe length ALONG the cut — demo only. Overhang in
                       // this direction cannot tilt the blade out of the
                       // kerf plane, so it needs no support
jig_blade_w    = 7.5;  // Blade depth, tooth face to spine — demo only

/* [Hacksaw] */
hack_blade_t    = 0.65; // Blade thickness — standard 12" hacksaw blade
hack_slot_clear = 0.25; // Total kerf clearance — thinner blade, closer guide
hack_relief     = 3;    // Slot floor below the tube's bottom vertex, so the
                        // severing stroke finishes in air, then bottoms out

/* [Body] */
wall_side  = 6.72;  // Each side wall — 16 x 0.42 mm extrusion lines
platform_t = 6.72;  // Top platform the jigsaw shoe rides on
floor_t    = 6.72;  // V-saddle wall between tunnel and cavity, measured
                    // PERPENDICULAR to the 45 degree faces
base_t     = 6.72;  // Base plate — the tie that crosses the jigsaw slot
top_wing   = 15;    // Extra platform width EACH side, so the shoe has glide
                    // room across the cut. Carried on a 45 degree flare off
                    // the walls — self-supporting, still one print
lead_in    = 1.5;   // 45 degree flare at both tunnel mouths
slot_flare = 0.8;   // 45 degree entry flare where a slot meets the platform
corner_round = 2;   // 2D rounding on convex outer corners

/* [Fence] */
// Raised rail across the platform, parallel to the cut, on the
// FRONT side of the jigsaw slot. The side of the jigsaw's shoe
// rides against its face while the saw advances, so the saw
// cannot yaw or drift — the slot steers the blade, the fence
// steers the machine.
fence        = true;
fence_offset = 40;   // Blade to the shoe's side edge — MEASURE your saw:
                     // perpendicular distance from the blade to the shoe
                     // edge that faces the jig's FRONT while cutting
fence_w      = 8;    // Rail width
fence_h      = 6;    // Rail height above the platform. Check your saw's
                     // side profile first: the body must clear this where
                     // it overhangs the shoe edge

/* [Ears] */
ear_w          = 20;    // Clamp flange width each side, full jig length
ear_haunch     = 4;     // 45 degree haunch tying each ear into its wall
screw_holes    = false; // O5.5 holes through the ears for temporary screws
screw_diameter = 5.5;   // Clearance diameter (5.5 suits a 5 mm screw)

/* [Ruler] */
ruler        = true;  // Engraved cm rulers on the ear tops + wing edge ticks
rule_depth   = 0.6;   // Engraving depth
rule_tick_w  = 0.8;   // Tick line width
rule_text    = 4.2;   // Numeral height (cm digits on the ear tops)

/* [Tube Lock] */
tube_lock    = true;  // Printed thumbscrew pressing the tube into its V seat
tube_screw_x = 125;   // Screw axis station — on the back land, stock side
boss_d       = 17;    // Boss diameter around the female thread
boss_len     = 6;     // Boss height proud of the wing top, along the axis

/* [Thumbscrew] */
// Printed-thread numbers proven in magnet_pill_container.scad and
// headboard_frame_brackets.scad.
ts_pitch       = 2.5;   // Thread pitch — coarse, few turns to clamp
ts_major_d     = 10;    // Thread major diameter
ts_depth       = 0.6;   // Radial depth of the thread (crest minus root)
ts_crest       = 0.6;   // Axial width of the flat crest
ts_root        = 0.6;   // Axial width of the flat root
ts_len         = 26;    // Threaded shaft length — sized so the tip reaches
                        // the tube face with ~2 mm head-to-boss gap left
ts_head_d      = 20;    // Knurled head diameter
ts_head_t      = 6;     // Knurled head thickness
ts_head_flutes = 12;    // Grip scallops around the head
ts_tip_d       = 7;     // Flat dog point that bears on the tube face
ts_tip_len     = 2;     // Length of that dog point
ts_clear_r     = 0.35;  // Radial clearance — the female thread prints on a
                        // 45 degree axis, so its bore sags a little
ts_clear_ax    = 0.25;  // Axial (flank) clearance

/* [Demo] */
demo_tube_overrun = 80; // Tube length beyond each end of the jig, demo only

/* [Quality] */
$fa = 1;   // Minimum angle — 1 degree gives max 360 facets per full circle
$fs = 0.4; // Minimum facet edge length (mm) — matched to a 0.4 mm nozzle

/* [Render] */
part = "printplate";  // [jig, screw, printplate, demo]

// ============================================================
// DERIVED
// ============================================================

s_in      = tube + 2 * slide_clear;    // Bore square, face to face (20.70)
diamond_w = s_in * sqrt(2);            // Bore span, vertex to vertex (29.27)
block_w   = diamond_w + 2 * wall_side; // Tower width across Y (42.71)
total_w   = block_w + 2 * ear_w;       // Overall width with ears (82.71)
ear_t     = base_t;                    // Ears are the base plate, continued
top_w     = block_w + 2 * top_wing;    // Platform width with wings (72.71)
foot_w    = max(total_w, top_w);       // Widest point of the jig

jig_gap  = jig_blade_t + jig_slot_clear;    // Jigsaw kerf slot (1.35)
hack_gap = hack_blade_t + hack_slot_clear;  // Hacksaw kerf slot (0.90)

// Height stack: the platform sits jig_reach above the jigsaw slot
// floor (the base plate top), plus margin, so the deepest tip
// travel stays inside the jig.
top_z    = base_t + jig_reach + jig_tip_margin;  // Platform top (78.72)
tun_top  = top_z - platform_t;                   // Bore TOP vertex (72.00)
tun_cz   = tun_top - diamond_w / 2;              // Bore centre (57.36)
tun_z0   = tun_top - diamond_w;                  // Bore BOTTOM vertex (42.73)
hack_z0  = tun_z0 - hack_relief;                 // Hacksaw slot floor (39.73)
flare_z0 = tun_top - top_wing;                   // Wing flare root (57.00)

// Gabled blade cavity under the V-saddle: its 45 degree roof runs
// floor_t (perpendicular) below the bore's lower faces, so the
// saddle is constant thickness and nothing bridges.
cav_apex_z  = tun_z0 - floor_t * sqrt(2);        // Gable apex (33.22)
cav_shldr_z = cav_apex_z - diamond_w / 2;        // Gable shoulders (18.59)

// Slot stations along X, from the cm-registered kerf centres.
x_jig0  = jig_station - jig_gap / 2;    // 59.325
x_jig1  = jig_station + jig_gap / 2;    // 60.675
x_hack0 = hack_station - hack_gap / 2;  // 109.55
x_hack1 = hack_station + hack_gap / 2;  // 110.45
land_front = x_jig0;                    // 59.325
land_mid   = x_hack0 - x_jig1;          // 48.875
land_back  = jig_len - x_hack1;         // 29.55

tip_min_z = top_z - jig_reach;                    // Deepest tip travel
tip_hi_z  = top_z - (jig_reach - jig_stroke);     // Tip at TOP of stroke

x_fence = jig_station - fence_offset;             // Fence working face (20)

// Thumbscrew geometry. The axis is the outward normal of the
// bore's upper +Y face: direction (0, 1, 1)/sqrt(2), through that
// face's centre. Local frame: z = 0 at the tube face, +z outward;
// the axis breaks out through the flat top exactly at the
// wall/wing junction (45 degree symmetry).
scrw_face_y = diamond_w / 4;                     // Face centre (7.32, ...)
scrw_face_z = tun_cz + diamond_w / 4;            // ... (64.68)
scrw_path   = (top_z - scrw_face_z) * sqrt(2);   // Face to top surface (19.86)
scrw_boss   = scrw_path + boss_len;              // Face to boss face (25.86)

// Male thread first, female = male grown by the clearances
// (radial) and widened flanks (axial).
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
ts_total       = ts_head_t + ts_len + ts_tip_len;
// Screw pressed home: tip on the tube face, head still off the boss.
ts_press_gap   = ts_len + ts_tip_len - scrw_boss;
ts_press_eng   = scrw_boss - ts_tip_len;  // Thread length engaged

eps = 0.01;

// Sanity guards — these would produce a jig that ruins a cut (or a
// blade) rather than an obvious error, so fail loudly instead.
assert(jig_station % 10 == 0 && hack_station % 10 == 0 && jig_len % 10 == 0,
       "stations and length must be whole centimetres — that is the point of the ear rulers");
assert(jig_reach - jig_stroke >= platform_t + diamond_w + 2,
       "blade too short — at the top of the stroke the tip re-enters the tube; fit a longer blade or reduce jig_stroke");
assert(tip_min_z > ear_t + ear_haunch + 1.5,
       "deepest tip travel reaches the ear haunch beside the walls — raise jig_tip_margin");
assert(jig_gap >= jig_blade_t + 0.15 && hack_gap >= hack_blade_t + 0.15,
       "kerf clearance under 0.15 total — the blade will bind and melt the slot faces");
assert(land_front >= shoe_w / 2 + 5 && land_mid >= shoe_w / 2 + 5,
       "shoe overhangs a land by more than half — move jig_station / hack_station apart");
assert(land_back >= 25,
       "land_back too short to clamp behind the hacksaw slot");
assert(wall_side >= 8 * 0.42 && platform_t >= 8 * 0.42,
       "slot guide faces thinner than 8 extrusion lines — they wear, give them material");
assert(floor_t * sqrt(2) - hack_relief >= 1.5,
       "hacksaw relief leaves under 1.5 mm of V-saddle over the cavity gable — reduce hack_relief or thicken floor_t");
assert(cav_shldr_z > base_t + 2,
       "cavity gable shoulders reach the base plate — the jig is too short for the diamond, raise jig_reach");
assert(tun_relief < wall_side / 2,
       "vertex relief eats too far into the side walls");
assert(flare_z0 > ear_t + ear_haunch + 15,
       "platform wings flare down to within 15 mm of the ears — an F-clamp jaw no longer fits over them; reduce top_wing");
assert(ear_w >= (screw_holes ? screw_diameter + 6 : 10),
       "ear too narrow for its job");
assert(!ruler || ear_w >= ear_haunch + 9 + rule_text + 2,
       "ear too narrow for ticks plus numerals — widen ear_w or drop the ruler");
assert(!fence || x_fence - fence_w >= 3,
       "fence hangs off the front of the platform — fence_offset too large for jig_station");
assert(!fence || x_fence <= x_jig0 - slot_flare - 2,
       "fence reaches the jigsaw slot's entry flare — fence_offset too small");
assert(jig_len <= 270 && foot_w <= 270 && top_z + (fence ? fence_h : 0) <= 256,
       "jig exceeds the 270 x 270 x 256 build volume");
// Thumbscrew guards.
assert(!tube_lock || tube_screw_x - boss_d / 2 > x_hack1 + 2,
       "thumbscrew boss overlaps the hacksaw slot — move tube_screw_x back");
assert(!tube_lock || tube_screw_x + boss_d / 2 < jig_len - 2,
       "thumbscrew boss hangs off the back face — move tube_screw_x forward");
assert(!tube_lock || ts_f_phi_root < 175,
       "female thread root lobe nearly a full circle — reduce ts_root or ts_clear_ax");
assert(!tube_lock || ts_tip_d / 2 < ts_min_r,
       "thumbscrew dog point wider than the thread root");
assert(!tube_lock || ts_press_gap >= 1,
       "thumbscrew head bottoms on the boss before the tip reaches the tube — lengthen ts_len");
assert(!tube_lock || ts_press_eng >= 2 * ts_pitch,
       "under two turns of thread engaged when the screw is pressed home");

// Fit report — printed on every render.
echo(str("FIT: diamond bore ", s_in, " mm across the flats (", slide_clear,
         "/side slide fit), ", diamond_w, " vertex to vertex, ", tun_relief,
         " mm relief at all four vertices (bottom one is the burr channel)"));
echo(str("STATIONS: front face 0 | jigsaw kerf centre ", jig_station,
         " | hacksaw kerf centre ", hack_station, " | back face ", jig_len,
         " — all on cm marks. Kerf faces at ", x_jig0, "/", x_jig1,
         " and ", x_hack0, "/", x_hack1));
echo(str("SLOTS: jigsaw ", jig_gap, " mm, hacksaw ", hack_gap, " mm"));
echo(str("BLADE: tip sweeps z ", tip_min_z, " (bottom of stroke) to ",
         tip_hi_z, " (top) — bore bottom vertex is z ", tun_z0,
         ", so the tube is severed at every stroke position and the tip",
         " keeps ", jig_tip_margin, " mm off the base plate"));
echo(str("SHOE: ", shoe_w, " mm shoe spans the slot with ", land_front,
         " / ", land_mid, " mm of bearing; ", top_w,
         " mm of glide width across the cut on the winged platform"));
echo(str("CLAMP: ears run the full ", jig_len,
         " mm — clamp one each side of the slot in use; shoe needs x ",
         jig_station - shoe_w / 2, "-", jig_station + shoe_w / 2, " clear"));
if (fence)
    echo(str("FENCE: working face ", fence_offset,
             " mm in front of the jigsaw kerf centre, ", fence_h,
             " mm tall — MEASURE blade-to-shoe-edge on the actual saw",
             " before printing"));
if (tube_lock)
    echo(str("LOCK: M", ts_major_d, "x", ts_pitch,
             " printed thumbscrew at x ", tube_screw_x,
             ", 45 degrees through the +Y wing; ",
             ts_press_eng / ts_pitch, " turns engaged at the tube, ",
             "head-to-boss gap ", ts_press_gap, " mm pressed home"));
echo(str("WALLS: ", wall_side, " mm = ", wall_side / 0.42,
         " extrusion lines at 0.42 mm"));
echo(str("FOOTPRINT: ", jig_len, " x ", foot_w, " x ", top_z,
         " mm tall (bed 270 x 270 x 256)"));
echo("PRINT: every overhang is 45 degrees — diamond roof, cavity gable, wing flares, ear haunches. NO bridges, no supports.");

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

// ============================================================
// 2D PROFILE  (drawn in the YZ plane: 2D x = Y, 2D y = Z)
// ============================================================

// Round the CONVEX corners of a 2D outline: erode then dilate.
module rounded_outline() {
    offset(r = corner_round) offset(r = -corner_round) children();
}

// The diamond bore, centred on the origin: the tube square rotated
// 45 degrees, with a round relief pocket at each vertex so the
// tube's arris never registers (it must seat on the FACES).
module tunnel_2d() {
    rotate(45) square(s_in, center = true);
    for (a = [0 : 90 : 270])
        rotate(a) translate([diamond_w / 2, 0]) circle(r = tun_relief);
}

// Outer silhouette: the tower flanked by the base-level ears, each
// tied in with a 45 degree haunch, and the winged platform on its
// 45 degree flares.
module outer_profile() {
    translate([-block_w / 2, 0]) square([block_w, top_z]);
    translate([-total_w / 2, 0]) square([total_w, ear_t]);
    for (s = [-1, 1]) scale([s, 1]) {
        // Ear haunch at the base.
        polygon([[block_w / 2, ear_t],
                 [block_w / 2 + ear_haunch, ear_t],
                 [block_w / 2, ear_t + ear_haunch]]);
        // Platform wing: extra shoe glide room across the cut,
        // carried on a 45 degree flare off the wall.
        polygon([[block_w / 2, flare_z0],
                 [block_w / 2 + top_wing, tun_top],
                 [block_w / 2 + top_wing, top_z],
                 [block_w / 2, top_z]]);
    }
}

// The full section: rounded silhouette minus bore and blade
// cavity. The cavity has a 45 degree gabled roof running floor_t
// below the bore's lower faces — a constant-thickness V-saddle,
// and nothing anywhere bridges flat.
module profile_2d() {
    difference() {
        rounded_outline() outer_profile();
        translate([0, tun_cz]) tunnel_2d();
        polygon([[-diamond_w / 2, base_t],
                 [ diamond_w / 2, base_t],
                 [ diamond_w / 2, cav_shldr_z],
                 [ 0,             cav_apex_z],
                 [-diamond_w / 2, cav_shldr_z]]);
    }
}

// ============================================================
// MODULES
// ============================================================

// The extruded body, tunnel axis along +X.
module body() {
    // convexity keeps the OpenCSG preview honest — the profile has
    // holes, and without it the walls vanish in preview.
    rotate([90, 0, 90]) linear_extrude(height = jig_len, convexity = 10) profile_2d();
}

// A thin slab of the bore section (grown by `grow`), for hulling
// the mouth flares. Local frame: slab at x = 0.
module tunnel_slab(grow) {
    rotate([90, 0, 90]) linear_extrude(height = eps)
        offset(delta = grow) translate([0, tun_cz]) tunnel_2d();
}

// 45 degree flare at a tunnel mouth. Local frame: mouth plane at
// x = 0, cavity opening towards +X (same hull trick as the house
// pocket_cut).
module mouth_flare() {
    hull() {
        translate([lead_in, 0, 0]) tunnel_slab(0);
        translate([-1, 0, 0]) tunnel_slab(lead_in + 1);
    }
}

// A kerf slot: full-width vertical cut from z0 up through the top,
// with a 45 degree entry flare at the platform so the blade drops
// in without chipping the mouth. x0 = leading face, gap = kerf.
module slot_cut(x0, gap, z0) {
    translate([x0, -foot_w / 2 - 1, z0])
        cube([gap, foot_w + 2, top_z - z0 + 1]);
    hull() {
        translate([x0 + gap / 2, 0, top_z - slot_flare])
            cube([gap, foot_w + 2, eps], center = true);
        translate([x0 + gap / 2, 0, top_z + 1])
            cube([gap + 2 * (slot_flare + 1), foot_w + 2, eps], center = true);
    }
}

// Vertical clearance holes through the ears, one pair per clamp
// station, so the jig can be screwed down instead of clamped.
module screw_cuts() {
    for (x = [12, jig_len - 15], s = [-1, 1])
        translate([x, s * (block_w / 2 + ear_w / 2), -1])
            cylinder(h = ear_t + 2, d = screw_diameter, $fn = 24);
}

// Engraved rulers. Ear tops: 5 mm minors, 10 mm majors, cm
// numerals — zero at the FRONT face, so the kerf centres land
// exactly on the 6 and 11 marks. Numeral tops point INBOARD, the
// way a ruler lying on a bench reads from its own side. Wing
// edges get tick lines only — sight guides at tube height.
module ruler_cuts() {
    d = rule_depth;
    for (s = [-1, 1]) {
        // Ear top ticks, outboard of the haunch.
        y0 = block_w / 2 + ear_haunch + 1;
        for (x = [5 : 5 : jig_len - 5]) {
            len = (x % 10 == 0) ? 8 : 4;
            translate([x - rule_tick_w / 2, s == 1 ? y0 : -y0 - len, ear_t - d])
                cube([rule_tick_w, len, d + 1]);
        }
        // Ear top numerals, one per cm.
        for (x = [10 : 10 : jig_len - 10])
            translate([x, s * (y0 + 9 + rule_text / 2), ear_t - d])
                rotate([0, 0, s == 1 ? 180 : 0])
                    linear_extrude(height = d + 1)
                        text(str(x / 10), size = rule_text,
                             halign = "center", valign = "center",
                             font = "Liberation Sans:style=Bold");
        // Wing edge ticks, on the outer vertical faces.
        for (x = [5 : 5 : jig_len - 5]) {
            h = (x % 10 == 0) ? platform_t - 2 : (platform_t - 2) / 2;
            translate([x - rule_tick_w / 2, s * (top_w / 2 - d),
                       top_z - 1 - h])
                cube([rule_tick_w, d + 1, h]);
        }
    }
}

// Shoe fence: a rail across the platform on the front side of the
// jigsaw slot. Its back face (towards the slot) is the working
// face — dead flat, full height, spanning the whole winged
// platform so the shoe is guided over the entire traverse. The
// ends are bevelled in plan so the shoe edge cannot catch when
// it is set down against the rail.
module fence_rail() {
    translate([0, 0, top_z - 1]) linear_extrude(height = fence_h + 1)
        polygon([[x_fence,           -top_w / 2],
                 [x_fence,            top_w / 2],
                 [x_fence - fence_w,  top_w / 2 - 3],
                 [x_fence - fence_w, -top_w / 2 + 3]]);
}

// Thumbscrew boss and female thread, in the jig frame. The local
// +Z axis is the outward normal of the bore's upper +Y face:
// rotate([-45, 0, 0]) about the face-centre point.
module lock_boss() {
    translate([tube_screw_x, scrw_face_y, scrw_face_z]) rotate([-45, 0, 0])
        translate([0, 0, 5]) cylinder(h = scrw_boss - 5, d = boss_d);
}
module lock_thread_cut() {
    translate([tube_screw_x, scrw_face_y, scrw_face_z]) rotate([-45, 0, 0])
        translate([0, 0, scrw_boss]) rotate([180, 0, 0])
            ts_thread_negative(scrw_boss + 1);
}

// The finished jig — printed and used in this same orientation.
module jig() {
    difference() {
        union() {
            body();
            if (fence) fence_rail();
            if (tube_lock) lock_boss();
        }
        mouth_flare();                                    // front mouth
        translate([jig_len, 0, 0]) mirror([1, 0, 0]) mouth_flare(); // back mouth
        slot_cut(x_jig0, jig_gap, base_t);    // jigsaw — severs to the base
        slot_cut(x_hack0, hack_gap, hack_z0); // hacksaw — bottoms below the tube
        if (tube_lock) lock_thread_cut();
        if (screw_holes) screw_cuts();
        if (ruler) ruler_cuts();
    }
}

// Printed thumbscrew. Prints head DOWN: the external thread then
// rises in the good direction, 45 deg flanks self-supporting.
module thumbscrew() {
    // Knurled head.
    difference() {
        cylinder(h = ts_head_t, d = ts_head_d);
        flute_ring(ts_head_d, ts_head_t, ts_head_flutes, 1.6, 0.9);
    }
    // Threaded shaft.
    translate([0, 0, ts_head_t])
        thread_solid(ts_min_r, ts_maj_r, ts_phi_root, ts_phi_crest,
                     ts_len / ts_pitch);
    // Flat dog point that bears on the tube face.
    translate([0, 0, ts_head_t + ts_len - eps])
        cylinder(h = ts_tip_len + eps, d1 = ts_tip_d, d2 = ts_tip_d - 1);
}

// Hollow square tube along +Z. Ghost/reference geometry only.
module ghost_tube(len) {
    difference() {
        translate([0, 0, len / 2]) cube([tube, tube, len], center = true);
        translate([0, 0, len / 2])
            cube([tube - 2 * tube_wall, tube - 2 * tube_wall, len + 2 * eps],
                 center = true);
    }
}

// Ghost gear, for checking clearances by eye.
module demo_gear() {
    o = demo_tube_overrun;

    // The tube, on its corner, run through the bore.
    translate([-o, 0, tun_cz])
        rotate([0, 90, 0]) rotate([0, 0, 45]) ghost_tube(jig_len + 2 * o);

    // Jigsaw blade parked in the garage beside the tube, at the
    // bottom of its stroke, spine towards the near wall.
    translate([x_jig0 + (jig_gap - jig_blade_t) / 2,
               -diamond_w / 2 - 1 - jig_blade_w, tip_min_z])
        cube([jig_blade_t, jig_blade_w, jig_reach + 10]);

    // The shoe it hangs from, flat on the platform.
    translate([jig_station, 0, top_z + 1])
        cube([shoe_w, shoe_len, 2], center = true);

    // Hacksaw blade resting on the tube's top vertex in its slot.
    translate([hack_station - hack_blade_t / 2, -150, tun_top + 0.5])
        cube([hack_blade_t, 300, 13]);

    // Thumbscrew pressed home in the boss.
    if (tube_lock)
        translate([tube_screw_x, scrw_face_y, scrw_face_z])
            rotate([-45, 0, 0]) translate([0, 0, ts_total])
                rotate([180, 0, 0]) thumbscrew();
}

// ============================================================
// RENDER
// ============================================================
// "printplate" is the export layout: the jig as used plus the
// thumbscrew head-down beside it, both support-free. "jig" and
// "screw" render one piece alone; "demo" shows the lot working.

if (part == "jig") {
    jig();

} else if (part == "screw") {
    thumbscrew();

} else if (part == "printplate") {
    jig();
    if (tube_lock)
        translate([30, total_w / 2 + 5 + ts_head_d / 2, 0]) thumbscrew();

} else if (part == "demo") {
    jig();
    %demo_gear();

} else {
    echo("Unknown part — use \"jig\", \"screw\", \"printplate\" or \"demo\"");
}
