// ============================================================
// Magnet Pill Container + Two-Beam Experiment Bench
//
// A magnet-storage case and the bench it works on.
//
// THE CASE
//   * 15 mm bore, 80 mm usable depth.
//   * An open vertical slit down one side so the magnet stack
//     is visible from outside.  It runs as high as the cap's
//     seat allows, and is cut a second time once the holder's
//     arm is unioned on, so no arm material can fill it (see
//     the holder).
//   * A screw-on cap that finishes FLUSH with the body: the
//     closed case is one smooth cylinder, no shoulder.
//   * A DELIBERATELY THIN floor, so the bottom magnet in the
//     stack sits as close as it can to whatever is underneath.
//
// THE BENCH
//   * A weighted base plate with a hollow fill cavity in its
//     underside, closed by a snap-in cover.  Fill it with sand,
//     coins or shot for stability.  (Prefer sand or coins —
//     STEEL shot will be pulled at by the magnets.)
//   * TWO identical square beams, standing in two identical
//     sockets a fixed pitch apart.  Square so nothing that
//     slides on them can rotate.  One beam carries the magnet
//     case; the other carries the plate clamp.  They face each
//     other across the middle of the base.
//   * A holder that slides freely up its beam and is locked at
//     any height by a PRINTED thumbscrew — no hardware at all.
//     The case is NOT a separate clip-in part: its tube, a
//     cantilever arm and the sliding sleeve are one printed
//     body, with the viewing slit facing outward.  The arm holds
//     the case well clear of the beam so the magnets can be
//     brought down onto a workpiece with nothing in the way.
//     Only the cap comes off, and it unscrews without
//     disturbing the holder.
//   * An EDGE CLAMP on the second beam: a flat slab the metal
//     lies on, and two C-shaped grips that hook over the slab's
//     front edge and take the workpiece by its two side edges.
//     ONE screw per grip presses the metal down, squeezes the
//     slab, and locks the grip's position, all at once.  The
//     metal is worked on where it OVERHANGS the slab, and there
//     both its faces are bare — which is the whole point, since
//     a magnet must reach the metal with no plastic between.
//
// Standalone — no external dependencies.  All thread geometry
// is generated from scratch (see THREAD GENERATION below); no
// thread library is used.  One generator serves both the cap
// thread and the thumbscrew.
//
// Coordinate system:
//   Z = up, origin at the centre of the base plate's underside
//   (i.e. on the print bed).  +Y runs from the clamp beam toward
//   the holder beam, which is the direction the case reaches and
//   the direction the clamp's slab reaches, in opposite senses.
//   The case, the carrier, the clamp and the grips are each
//   modelled in their own local frame with z = 0 at their base,
//   and are translated into place for the assembled view.
//
// Print orientation — every part prints WITHOUT supports:
//   * Base   — upright, both hubs pointing up.  The fill cavity
//              opens downward; its ceiling bridges over pockets
//              no wider than ~19 mm.  The first layer is a wide
//              rectangular ring, so adhesion is good, but a brim
//              does no harm on a cold bed.
//   * Cover  — flat.
//   * Case   — upright, floor on the bed.  The bore opens
//              upward, the 45 deg thread flanks are self-
//              supporting, and the slit is a vertical slot with
//              a rounded top.
//   * Cap    — closed top DOWN, so the internal thread's 45 deg
//              overhangs print unsupported.
//   * Holder — upright, sleeve, arm and case bottoms all on the
//              bed.  Case and sleeve axes are parallel and the
//              arm is one constant section swept along that
//              axis, so a single orientation suits all three:
//              the bore opens upward, the 45 deg thread flanks
//              stay self-supporting, and the arm has no overhang
//              anywhere.  The thumbscrew's threaded hole is
//              horizontal here, so it is given extra radial
//              clearance to absorb the droop on its upper wall.
//   * Clamp  — upright like the holder.  The slab starts on the
//              bed and every wall is vertical, so there is
//              nothing to support.
//   * Grip   — ON ITS BACK, web face down, so the C's throat
//              opens UPWARD.  This is the whole reason the grip
//              is a separate part.  Left upright the throat would
//              have a horizontal roof, which is an unsupported
//              overhang; on its back both jaw faces become
//              vertical walls and the web becomes a floor.  It
//              also turns the screw's reaction, which tries to
//              spread the C, into a load ALONG the layers rather
//              than across the bonds.
//   * Screw  — head DOWN, shaft up, so its external thread
//              prints in the good direction.
//
// ONE PRINT PLATE.  part = "exploded" lays the whole machine out on a single
// 270 x 270 bed — all seventeen objects — so `make magnet_pill_container`
// builds everything, with no second command to forget and no way to end up
// having printed half a machine.
//
// MATERIAL.  Every part is trimmed to the work it actually does, and the
// trims live in the parameters rather than in hidden numbers:
//   * the base plate is as thin as its socket and its cavity roof allow
//     (see [Base plate] and [Socket]), and its hubs are as small as the
//     clamp thread leaves them;
//   * the clamp slab is only as thick as its grips must swallow (slab;
//   * the case's wall is only as thick as the printed thread stack and
//     the cap's skin require (see [Case] and [Cap thread])_t);
//   * the holder's arm carries a window (lighten_arm) where the
//     cantilever has an order of magnitude to spare;
//   * the beams are hollowed by a core down their axes (lighten_post).
// Printed with 0.42 mm extrusion and FIVE wall loops, the beams' 5 mm
// walls come out as solid perimeters — which is what makes the core a
// better hollow than sparse infill in a part that works in bending: the
// sliding sleeves then run on walls that are plastic all the way
// through.  Keep infill low (10-15 % gyroid) wherever the walls carry
// the load; the grips and the printed threads are the only parts that
// want density, because their jaws and threads take the hand-tightening
// forces.  The case's floor is exempt from all of this — it is a
// magnetic gap, not a structural member.
//
// All units: millimeters.
// ============================================================

/* [Part] */
// holder, cap/top, base, cover, thumbscrew, assembly/both, exploded
part = "assembly";  // [holder:Case + carrier (one part), post:Beam, foot:Stabiliser foot, clamp:Edge clamp slab, grip:Edge grip, cap:Cap, base:Base + both sockets, cover:Base cover, thumbscrew:Thumbscrew, vicescrew:Grip screw, assembly:Assembled upright, horizontal:Laid flat, exploded:Print plate — the whole machine]

/* [Case] */
bore_d          = 16;    // Inner diameter of the tube
inner_depth     = 80;    // Usable depth for the magnet stack (includes the neck)
tube_floor_t    = 1.6;   // Thickness of the case's closed floor.  Four layers at
                         // 0.4 mm.  This is the ONLY plastic between the bottom
                         // magnet and the workpiece, and field strength falls off
                         // steeply, so every tenth of a millimetre here is worth
                         // more than it looks.  The stack weighs well under 100 g,
                         // so four layers carry it easily; it is a knock on a hard
                         // edge, not the magnets, that would break a thinner floor.
neck_wall       = 1.2;   // Wall thickness of the threaded neck.  Three 0.42 mm
                         // loops, and it only has to carry the cap's own
                         // screwing force — the thinner it is, the thinner the
                         // case's whole wall stack is.
cap_wall        = 1.35;  // Side wall thickness of the cap — three loops over the
                         // thread, and 0.9 mm left under the grip flutes.
cap_top_t       = 2.5;   // Thickness of the cap's closed top

/* [Cap thread] */
thread_pitch    = 3;     // Axial rise per turn — coarse, so the cap opens fast
thread_depth    = 0.6;   // Radial depth of the thread (crest minus root).  With
                         // the crest and root below it still fills one pitch
                         // exactly, so the flanks stay at 45 deg.
thread_crest    = 0.9;   // Axial width of the flat crest
thread_root     = 0.9;   // Axial width of the flat root
thread_turns    = 3;     // Turns of engagement — sets the neck height
fit_clear_r     = 0.25;  // Radial clearance between male and female thread
fit_clear_ax    = 0.25;  // Axial (flank) clearance between male and female thread

/* [Slit] */
slit_w          = 3.5;   // Width of the viewing slit
slit_margin_bot = 1.5;   // Solid ring left between the floor and the slit — only
                         // just enough to keep the floor's edge intact.
slit_margin_top = 1.2;   // Solid ring left between the slit and the neck: the slot
                         // is run as high as the cap's seat allows, so the stack
                         // is visible almost up to the shoulder.
slit_angle      = 0;     // Rotates the slit.  0 = facing outward when mounted.

/* [Grip] */
flute_count     = 18;    // Number of grip scallops around the cap
flute_r         = 1.2;   // Radius of each scallop
flute_depth     = 0.45;  // How deep each scallop bites into the cap wall — the
                         // cap's skin is thinner now, so the scallops bite less

/* [Base plate] */
// Rectangular, because it now carries TWO beams in line.  The long axis runs
// along Y, between the beams; the short axis is across them.
plate_x         = 90;    // Base plate across the beams
beam_pitch      = 110;   // Centre-to-centre spacing of the two beam sockets.
                         // Sized so the case, reaching in from its own beam,
                         // lands over the middle of the clamped workpiece and
                         // still clears the clamp's sleeve and slab.
plate_h         = 12.5;  // Total plate thickness.  Trimmed from 14: every
                         // millimetre here is paid across the whole footprint,
                         // and the socket only reaches 8 below the top face.
                         // What remains above the cavity is a 2.5 mm skin, and
                         // it sits over the load pads rather than spanning.
plate_ch        = 2.5;   // Chamfer on the plate's top and bottom edges
plate_corner_r  = 6;     // Corner rounding of the plate
cover_inset     = 7;     // Border left outside the cover rebate
cover_t         = 2;     // Thickness of the snap-in cover
cover_fit       = 0.15;  // Per-side clearance of the cover in its rebate
cav_inset       = 8;     // Border left outside the fill cavity.  Trimmed from
                         // 10: still wider than the cover's 7 mm rebate border,
                         // so the cavity stays under the cover, and the border
                         // keeps the snap groove its wall.
cav_depth       = 8;     // Depth of the fill cavity
cav_rib         = 3;     // Thickness of the cavity's bracing ribs
snap_d          = 0.45;  // Depth of the cover's retaining snap rib

/* [Post] */
post_size       = 20;    // Square post, across the flats
post_len        = 186;   // TOTAL length of the printed post, socketed part included.
                         // Sized so the engraved scale numbers run a clean 0..150.
post_edge_ch    = 0.8;   // Chamfer along the post's four long edges.  Absorbs the
                         // elephant's foot from printing it lying down, and keeps
                         // the corners from binding in the square socket.
post_end_ch     = 1.5;   // Chamfer on BOTH ends — the post is symmetric, so either
                         // end can go into the socket
lighten_post    = true;  // Hollow each beam down its axis.  Printed with 5 wall
                         // loops a 5 mm wall is plastic all the way through, so
                         // this is a better hollow than infill in a bending part.
post_core       = 10;    // Size of that core, square across the beam
post_core_r     = 2;     // Corner rounding inside it — no square-corner risers
post_print_roll = 90;    // Roll about its own axis when laid down to print, so that
                         // an UNMARKED face is the one on the bed.  Engraving the
                         // face that meets the PEI sheet would only smear it.

/* [Socket] */
hub_size        = 28;    // Square socket hub standing on the base plate.
                         // Trimmed from 30: hub_wall still clears the guard's
                         // 3 mm around the socket, and a smaller hub shrinks
                         // the load pad it stands on, which grows the cavity.
hub_h           = 20;    // Hub height above the plate's top face
hub_flare       = 8;     // 45 deg gusset where the hub meets the plate
hub_ch          = 1.5;   // Chamfer at the top of the hub
socket_clear    = 0.3;   // Per-side clearance of the post in the socket
socket_sink     = 8;     // How far the socket reaches down into the plate

/* [Ruler] */
// A millimetre scale engraved along the beam, zeroed where the post leaves
// the hub — so a reading IS the height above the hub top, with no arithmetic.
// The buried 28 mm carries no marks, which also shows at a glance which end
// goes into the socket.
scale_on        = true;  // Engrave the scale at all
// Which faces carry the scale, as angles about the beam axis:
//   0   = the case side      (the case partly blocks it)
//   90  = one side face      }  clear in BOTH the upright and the
//   270 = the other side face }  laid-flat orientations
//   180 = the back           (against the bench when laid flat)
// The two side faces are the pair that stays readable either way up.
scale_face_angles = [90, 270];
scale_step      = 1;     // Graduation interval, mm.  1 mm is at the limit of what a
                         // 0.4 mm nozzle resolves — raise to 2 if it prints mushy.
tick_minor      = 2.5;   // Length of a plain graduation, measured across the face
tick_medium     = 4.5;   // Length of every 5th
tick_major      = 7;     // Length of every 10th
tick_w_minor    = 0.5;   // Groove width along the beam
tick_w_major    = 0.9;   // Groove width for the 5s and 10s, so they read at a glance
tick_deep       = 0.5;   // Groove depth
scale_numbers   = true;  // Engrave a number at every 10 mm
num_size        = 4;     // Text height
num_gap         = 1.5;   // Gap between a major tick and its number, across the face
num_lift        = 0.5;   // Gap between a major tick and its number, along the beam.
                         // Numbers sit just ABOVE their tick rather than straddling
                         // it, so the 0 is not half-swallowed by the hub.

/* [Holder] */
screw_side      = 90;    // Which face the holder's and the hubs' clamp screws sit
                         // on, degrees about Z.  0 = the back (opposite the case),
                         // 90 = the right side.  Keep this at +/-90 so that when a
                         // beam is laid flat with the case upward, the screw points
                         // sideways instead of down into the bench.  Both hubs use
                         // it too: they are spaced along the bench rather than
                         // across it, so their two screws end up side by side
                         // rather than pointing at each other.
slide_clear     = 0.35;  // Per-side clearance between a sleeve and its beam
sleeve_wall     = 3;     // Wall thickness of the sliding sleeve
carrier_h       = 40;    // Height of the sleeve
case_gap        = 28;    // Clear air between the sleeve's outer face and the case's
                         // outer surface, bridged by a cantilever arm.  The case used
                         // to OVERLAP the sleeve by 2 mm and be welded to it by that
                         // overlap; 28 mm of gap therefore stands it 30 mm further out
                         // than it used to be.  That reach is what lets a workpiece
                         // pass underneath with the beam out of the way.
arm_w           = 10;    // Arm thickness, measured across the beam
arm_fillet      = 5;     // Radius blended into both ends of the arm.  Filling the
                         // re-entrant corners is what stops the arm root being a
                         // stress riser; the arm itself is nowhere near its limit.
lighten_arm     = true;  // Cut a window through the middle of the arm.  The root
                         // stress is under a tenth of a megapascal, so the two
                         // rails left either side of it carry the case easily.
arm_rim         = 2.5;   // Rail left either side of that window, across the arm
arm_web         = 2;     // Web left at each end of it, clear of both fillets
arm_window_r    = 1.5;   // Corner rounding inside the window

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
ts_tip_d        = 7;     // Flat dog point that bears on the beam
ts_tip_len      = 2;     // Length of that dog point
ts_clear_r      = 0.35;  // Radial clearance — larger than the cap's, because this
                         // female thread is printed on a horizontal axis
boss_d          = 17;    // Diameter of the thumbscrew boss on the sleeve
boss_len        = 8;     // How far the boss stands off the sleeve

/* [Stabiliser foot] */
foot_span       = 110;   // Total width of the foot across the beam.  Widened from 76:
                         // the case now hangs 52 mm off the beam instead of 22, which
                         // puts the rig's mass nearly twice as high when it is laid
                         // flat.  A 76 mm foot would leave only a few degrees of
                         // margin before it rolled over.
foot_len        = 40;    // Length of the foot along the beam
foot_pad_t      = 4;     // Thickness of the flat pad at its outer edges.  Trimmed
                         // from 5: the pad spreads the stance, the buttress does
                         // the stiffening.
foot_rise       = 16;    // How far the buttress climbs the sleeve's sides
foot_round      = 1.5;   // Corner rounding on the foot's profile
foot_screw_side = 180;   // Which face the foot's clamp screw sits on.  180 puts it
                         // opposite the pad, so it points UP when the beam is laid
                         // flat and the pad is on the bench.

/* [Edge clamp] */
// Holds flat metal by its two SIDE EDGES only, and does it with one screw per
// side.  A flat slab reaches forward off a sliding sleeve; the metal lies on
// top of the slab and overhangs its front edge.  Two C-shaped grips hook over
// that edge and can be slid anywhere along it.
//
// Each grip's single screw does three jobs at once: it presses the metal down,
// it squeezes the slab between the metal and the grip's lower leg, and by
// doing so it locks the grip's own position.  There is nothing else to
// tighten, which is why the whole station needs three screws rather than
// seven.  The metal is worked on where it overhangs the slab, and there both
// faces are completely bare.
clamp_h          = 40;   // Sleeve height, matching the holder and the foot
clamp_screw_side = 180;  // Which face the clamp's BEAM screw sits on.  180 puts it
                         // behind the beam, away from the slab.  On face 90 the
                         // screw head swings out to within 5 mm of the slab.
slab_t           = 10;   // Slab thickness.  The grips clamp through it, so it is
                         // part of what their throat has to swallow.  Trimmed
                         // from 14 — the biggest lever on the clamp: the screw's
                         // load runs through the metal into the slab, which is
                         // squeezed between the grip's legs, never bent.
slab_reach       = 36;   // How far the slab's front edge stands from the beam axis.
                         // Everything forward of that edge is bare metal.
slab_half        = 62;   // Half the slab's width.  Sets how far apart the grips go,
                         // and therefore the widest workpiece.
slab_merge       = 2;    // How far the slab sinks into the sleeve's face

grip_max         = 6;    // Thickest metal the grips will take
grip_w           = 18;   // Grip width along the slab's edge
grip_screw_in    = 8;    // Inboard end of the grip to its screw axis.  This is what
                         // stops the two grips meeting, so it sets the narrowest
                         // workpiece — but it cannot go much below 8 or there is no
                         // meat left around the thread.
grip_bite        = 4;    // How far inboard of the metal's edge the screw lands.  The
                         // flat tip is 7 mm across, so 4 keeps it wholly on the metal
                         // with half a millimetre to spare.
grip_engage      = 16;   // How far back over the slab the C reaches
grip_screw_back  = 7;    // Screw setback from the slab's front edge.  This is the
                         // lever the screw's own force acts through on the jaw, so
                         // keeping it short is worth more than thickening the jaw:
                         // it is the ONE dimension that decides how hard the grip
                         // can be tightened before its jaw yields.  It cannot go
                         // to zero — the screw must land on metal the slab is
                         // actually supporting, not out over its edge — and it
                         // must leave a wall between the thread and the throat.
grip_wall        = 8;    // Thickness of the C's two legs and its web
grip_slack       = 2;    // Headroom left above the thickest metal
grip_fit         = 0.3;  // Clearance under the slab, so a loose grip slides
grip_gap         = 1;    // Clear air between the two grips at their closest
grip_boss_len    = 6;    // Screw boss standing off the grip
vs_len           = 22;   // Grip screw thread length — longer than the beam screws,
                         // because it has to cross the whole throat

/* [Assembly preview] */
demo_carrier_z  = 59;    // Holder height, used only for the upright view
demo_holder_z   = 30;    // Holder position along the beam, laid-flat view only
demo_foot_z     = 125;   // Foot position along the beam, laid-flat view only
demo_clamp_z    = 40;    // Edge clamp height, upright view only.  Set with
                         // demo_carrier_z so the preview shows the case brought
                         // down close over the metal, which is the working pose.
// No workpiece is drawn — you bring your own metal.  These two only pose the
// preview: they say what size of metal the grips and their screws are set up
// for, so the assembled view shows the clamp as it would actually be found
// rather than wide open.
demo_metal_w    = 60;    // Width of metal the grips are set to, between the edges
demo_metal_t    = 3;     // Thickness the grip screws are wound down to

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
// Long enough to seat both hubs with their gussets and still leave the
// cavity's border, so the plate's length is a consequence of the beam pitch
// rather than a number picked by hand.
plate_y       = beam_pitch + hub_size + hub_flare + 2 * cav_inset;

hub_y         = [-beam_pitch / 2, beam_pitch / 2];  // the two socket centres

cover_x       = plate_x - 2 * cover_inset;          // rebate across the flats
cover_y       = plate_y - 2 * cover_inset;
cav_x         = plate_x - 2 * cav_inset;            // fill cavity across the flats
cav_y         = plate_y - 2 * cav_inset;
cav_z0        = cover_t;                            // cavity floor (above the cover)
cav_z1        = cav_z0 + cav_depth;                 // cavity ceiling
plate_ceiling = plate_h - cav_z1;                   // solid roof over the cavity

// Each beam's load runs down a solid column through the plate, so
// the cavity is a ring around TWO pads, each wider than its hub's
// gusset — and deep enough to take the socket.
pad_size      = hub_size + hub_flare + 2;

// Bracing ribs.  The cavity's ceiling is printed as a bridge, so no pocket
// may be wider than the printer will span.  A square plate needed only one
// rib per axis; a long one needs the stretch BETWEEN the two pads broken up,
// so the cross ribs are spaced to divide it into equal gaps under the limit.
rib_gap_max   = 19;                                 // widest pocket we will bridge
rib_span      = beam_pitch - pad_size;              // clear run between the pads
rib_gaps_raw  = max(2, ceil(rib_span / rib_gap_max));
rib_gaps      = (rib_gaps_raw % 2 == 0) ? rib_gaps_raw : rib_gaps_raw + 1;
rib_n         = (rib_gaps - 2) / 2;                 // ribs run i = -rib_n .. +rib_n
rib_step      = rib_span / rib_gaps;
rib_gap       = rib_step - cav_rib;                 // the pocket that actually bridges

// --- Post and socket -----------------------------------------
hub_flare_h   = hub_flare / 2;                      // 45 deg gusset
hub_top       = plate_h + hub_h;
post_wall     = (post_size - post_core) / 2;        // wall left by the lightening core
socket_size   = post_size + 2 * socket_clear;
socket_depth  = hub_h + socket_sink;                // hub plus the reach into the plate
socket_z0     = plate_h - socket_sink;              // socket floor
post_free     = post_len - socket_depth;            // length left standing proud
post_top      = hub_top + post_free;

// --- Ruler ---------------------------------------------------
post_flat     = post_size - 2 * post_edge_ch;       // usable width of one face

// Which face ends up against the bed, given the print roll.  Laying the
// post down maps beam-local +X downward; rolling by R turns that into
// the face at (270 - R).
bed_face      = (270 - post_print_roll + 360) % 360;
scale_span    = floor(post_free - post_end_ch);     // last graduation
num_max       = floor((scale_span - num_lift - num_size) / 10) * 10;  // last number that fits


// --- Carrier -------------------------------------------------
sleeve_in     = post_size + 2 * slide_clear;
sleeve_out    = sleeve_in + 2 * sleeve_wall;
// Case centre.  It used to sit hard against the sleeve, welded to it by the
// overlap of the two tubes.  Now it stands case_gap clear and a cantilever
// arm carries it.
case_cy       = sleeve_out / 2 + body_r + case_gap;

// The arm's free span is that gap, by construction.  There is no merge depth
// to tune at either end: the arm's plan profile runs from the sleeve's centre
// to the case's centre, so it is grown into both bodies through their full
// wall thickness rather than lapped onto their surfaces.  The slide bore and
// the magnet bore are then cut back out, which is what leaves the walls
// exactly as thick as they were before the arm arrived.
arm_span      = case_gap;

// The arm is one constant section swept along the sleeve axis, so its
// stiffness is set by its width across the beam and its height along it.
// Bending is dominated by the height, which is the whole sleeve, and that
// makes the arm enormously stiffer than it needs to be: a loaded case puts
// well under a tenth of a megapascal into the root.  The section is chosen
// for printability and for the fillet it can carry, not for strength.
arm_h         = carrier_h;
arm_z_mod     = arm_w * arm_h * arm_h / 6;

// The lightening window: a slot through the arm, clear of both fillets and
// of the tubes at either end.  What is left is two rails and two webs, so
// the arm behaves as a ring rather than a plate.  Its walls are vertical in
// the print, which is why it is a window and not a pocket.
arm_win_y0    = sleeve_out / 2 + arm_fillet + arm_web;
arm_win_y1    = case_cy - body_r - arm_fillet - arm_web;
arm_win_len   = arm_win_y1 - arm_win_y0;
arm_win_w     = arm_w - 2 * arm_rim;

// The case now runs well clear of the beam, so this is simply how much
// daylight there is between them.
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

// The scale runs the length of the post, but only this much of it is
// reachable by a holder — above that the sleeve would overhang the end.
// Defined here rather than with the other ruler values because it
// depends on the travel worked out just above.
scale_usable  = carrier_z_max - hub_top;

// --- Stabiliser foot -----------------------------------------
foot_boss_z   = foot_len / 2;
foot_half_w   = foot_span / 2;

// Roughly how far the rig can be tilted, laid flat, before the case
// takes it over: the case axis is the bulk of the mass and sits this
// high above the bench.
com_h         = sleeve_out / 2 + case_cy;
tip_angle     = atan(foot_half_w / com_h);
tip_bare      = atan(sleeve_out / 2 / com_h);   // without the foot

// The foot's clamp boss stands off the SAME side of the beam as the case
// does, so the two cannot be slid on top of one another.  What it fouls is
// no longer the case — that now stands well beyond the boss's reach — but
// the ARM, which crosses the boss's path over the sleeve's full height.
//
// Two things have to clear when the foot sits ABOVE the holder: the boss
// against the arm, and — the one that actually binds, now that the arm is no
// taller than the sleeve — the two sleeves against each other.  Whichever
// needs more room wins.
foot_arm_gap  = arm_h - (foot_boss_z - boss_d / 2);
foot_min_gap  = max(carrier_h, foot_arm_gap);

// --- Edge clamp ----------------------------------------------
// The slab, in clamp-local coordinates: the sleeve is at the origin, the slab
// reaches in -Y toward the other beam, and its top face is the table the metal
// lies on.
slab_y0       = -slab_reach;                        // free front edge
slab_y1       = -(sleeve_out / 2 - slab_merge);     // buried in the sleeve
slab_depth    = slab_y1 - slab_y0;                  // how far it overhangs

// The grip, modelled with its screw axis at x = 0.  The body is deliberately
// NOT centred on that axis: it runs only grip_screw_in inboard, just enough to
// carry the thread, and the rest hangs outboard where there is nothing to
// collide with.  Centring it would push the two grips apart and cost about
// 6 mm off the narrowest workpiece the clamp can take.
grip_out      = grip_w - grip_screw_in;             // screw to the outboard end

// Vertical stack.  z = 0 is the slab's underside, so the grip's lower leg sits
// just below that and its upper leg clears the slab plus the thickest metal.
grip_z0       = -(grip_fit + grip_wall);            // bottom of the grip
grip_z1       = -grip_fit;                          // top of the lower leg
grip_z2       = slab_t + grip_max + grip_slack;     // underside of the upper leg
grip_z3       = grip_z2 + grip_wall;                // top of the upper leg
grip_boss_top = grip_z3 + grip_boss_len;

// Along the bench: the web hangs down the slab's front face and the two legs
// reach back over and under it.
grip_y0       = slab_y0 - grip_fit - grip_wall;     // outer face of the web
grip_y1       = slab_y0 - grip_fit;                 // inner face of the web
grip_y2       = slab_y0 + grip_engage;              // how far back the legs reach
grip_screw_y  = slab_y0 + grip_screw_back;          // screw over supported metal

// The jaw is a cantilever off the web, and the screw's own force is what bends
// it — a far bigger load than anything the magnets do.  A 20 mm knurled head
// tightened at a comfortable 0.5 N.m develops roughly 270 N down the thread,
// and an enthusiastic 1.0 N.m about 540 N, so this is the number that has to
// clear those rather than the 40 to 70 N a magnet stack pulls with.
grip_leg_arm  = grip_screw_y - grip_y1;
grip_leg_S    = grip_w * grip_wall * grip_wall / 6;
print_yield   = 30;                                 // printed ABS in-plane, MPa
grip_screw_lim = print_yield * grip_leg_S / grip_leg_arm;

// The one screw.  It has to cross the slack above the metal and then the metal
// itself, so its stroke is measured against a bare slab — the worst case.
grip_hole_d   = grip_wall + grip_boss_len;          // depth of thread in the grip
grip_reach    = vs_len + ts_tip_len;
grip_stroke   = grip_reach - grip_hole_d;
grip_close    = grip_z2 - slab_t;                   // tip travel to touch bare slab

// Workpiece range.  A grip's screw lands grip_bite inside the metal's edge, so
// where the grips end up IS the width.  At one end the two grips meet; at the
// other they run out of slab.
mouth_min     = grip_screw_in + grip_gap / 2;
mouth_max     = slab_half - grip_out;
work_w_min    = 2 * (mouth_min + grip_bite);
work_w_max    = 2 * (mouth_max + grip_bite);

// How much of the metal a grip covers on each side, and what that leaves bare
// between them.  This applies only under the grips themselves — everything
// forward of the slab's front edge is bare across the full width.
grip_cover    = grip_screw_in + grip_bite;
function work_bare(w) = w - 2 * grip_cover;

// The metal lies ON the slab, so its underside sits this far ABOVE the clamp's
// base plane.  Matched against the case's floor on the other beam, this is
// what says whether the two can be brought together.
work_rest     = slab_t;

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
// clamped onto the beam.  The screw must be long enough to cross
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
assert(slit_margin_top >= 1 && slit_margin_bot >= 1,
       "Slit ring under the cap's seat, or above the floor, would be too thin to print — raise the margins.");
assert(cap_wall - flute_depth >= 0.8,
       "Grip flutes cut the cap wall too thin — reduce flute_depth or increase cap_wall.");
assert(case_gap > 2,
       "Arm has no span to bridge — raise case_gap, or weld the case to the sleeve as it used to be.");
assert(arm_w >= 4,
       "Arm is too thin to print with sound perimeters — raise arm_w.");
assert(arm_fillet * 2 < arm_span,
       "Arm fillets would meet in the middle — reduce arm_fillet or raise case_gap.");
assert(arm_w + 2 * arm_fillet < sleeve_out,
       "Arm plus its fillets is wider than the sleeve it springs from — reduce arm_w or arm_fillet.");
assert(!lighten_arm || arm_win_w >= 4,
       "Arm lightening window leaves under 4 mm of rail — raise arm_w or reduce arm_rim.");
assert(!lighten_arm || arm_win_len >= 8,
       "Arm lightening window shorter than 8 mm — reduce arm_web or arm_fillet.");
assert(!lighten_arm || (arm_win_y0 > sleeve_out / 2 && arm_win_y1 < case_cy - body_r),
       "Arm lightening window reaches into a tube — check arm_web and arm_fillet.");
assert(post_gap >= 0.8,
       "Case would run too close to the beam above the sleeve — raise case_gap.");
assert(socket_sink <= plate_h - cover_t - 2,
       "Socket reaches too deep into the plate — reduce socket_sink or thicken plate_h.");
assert(hub_boss_len >= 4,
       "Hub boss is too short to hold enough thread — widen boss_len or narrow hub_size.");
assert(hub_wall >= 3,
       "Too little meat around the socket for the clamp thread — widen hub_size.");
assert(post_free > carrier_h + 20,
       "Post barely projects from the hub — lengthen post_len.");
assert(!lighten_post || post_wall >= 4,
       "Beam core leaves under a 4 mm wall — reduce post_core or widen post_size.");
assert(!lighten_post || post_core_r * 2 < post_core,
       "Beam core corner rounding meets itself — reduce post_core_r.");
assert(!scale_on || tick_major < post_flat - 2,
       "Major ticks are wider than the beam's face — shorten tick_major.");
assert(!scale_on || !scale_numbers || num_lift + num_size < 10 * scale_step,
       "Numbers are taller than the gap between the ticks they label — shrink num_size.");
assert(!scale_on || !scale_numbers || tick_major + num_gap + num_size * 2.2 < post_flat,
       "No room left on the face for the numbers — shorten tick_major or num_size.");
assert(!scale_on || tick_w_major < scale_step * 5,
       "Major graduation grooves are wider than their spacing.");
assert(!scale_on || len([for (a = scale_face_angles) if ((a + 360) % 360 == bed_face) 1]) == 0,
       "A marked face is the one that prints against the bed — change post_print_roll or scale_face_angles.");
assert(post_print_roll % 90 == 0,
       "post_print_roll must be a multiple of 90, or the post lands on a corner.");
assert(grip_z2 > slab_t + grip_max,
       "Grip throat cannot swallow the slab and the thickest metal — raise grip_slack.");
assert(grip_stroke >= grip_close,
       "Grip screw runs out of stroke before it reaches a bare slab — lengthen vs_len.");
assert(grip_bite >= ts_tip_d / 2,
       "Screw tip would hang over the metal's edge — raise grip_bite.");
assert(grip_screw_in >= ts_f_maj_r + 1,
       "Too little meat inboard of the grip's thread — raise grip_screw_in.");
assert(grip_engage < slab_depth - 2,
       "Grip reaches back further than the slab overhangs, so it would foul the sleeve — reduce grip_engage or raise slab_reach.");
assert(mouth_max > mouth_min,
       "Slab is too narrow for the grips to move at all — raise slab_half.");
assert(work_w_max >= 90 && work_w_min <= 25,
       "Grips no longer cover the 25 to 90 mm workpieces they are meant to — check slab_half, grip_screw_in and grip_bite.");
assert(work_bare(work_w_min) > 0,
       "At its narrowest the grips would meet over the metal, leaving nothing bare — reduce grip_screw_in or grip_bite.");
assert(slab_y1 < 0,
       "Slab sinks past the beam axis — reduce slab_merge.");
assert(clamp_screw_side == 180 || clamp_screw_side == 0,
       "The clamp's beam screw must sit fore or aft; on a side face its head fouls the slab.");
assert(grip_boss_top <= clamp_h,
       "Grip screw boss stands above the clamp's sleeve — shorten grip_boss_len.");
assert(grip_screw_back >= 3,
       "Screw sits too near the slab's edge — the metal under it would be unsupported.");
assert(grip_screw_back + boss_d / 2 < grip_engage + grip_wall,
       "Screw boss overhangs the back of the grip — reduce grip_screw_back or deepen grip_engage.");
assert(grip_screw_lim > 600,
       "Grip jaw would yield under ordinary hand-tightening — thicken grip_wall or reduce grip_screw_back.");
assert(foot_rise > foot_pad_t + 2,
       "Foot buttress must rise clear of its own pad — raise foot_rise.");
assert(foot_rise < sleeve_out,
       "Foot buttress climbs past the top of the sleeve — lower foot_rise.");
assert(foot_span > sleeve_out + 20,
       "Foot is no wider than the sleeve it replaces, so it stabilises nothing.");
assert(tip_angle > 32,
       "Foot is too narrow for how high the case now sits on its arm — widen foot_span.");
assert(demo_foot_z - demo_holder_z >= foot_min_gap
       || demo_holder_z - demo_foot_z >= foot_len,
       "Preview places the foot's boss inside the case — separate demo_foot_z and demo_holder_z.");
assert(abs(screw_side) == 90 || screw_side == 0,
       "screw_side should be 0, 90 or -90 so the boss lands square on a face.");
assert(plate_ceiling >= 2.5,
       "Fill cavity leaves too thin a roof — reduce cav_depth or increase plate_h.");
assert(cav_x > pad_size + 2 * cav_rib,
       "Fill cavity is too narrow to clear the hubs' load pads — increase plate_x.");
assert(beam_pitch > hub_size + hub_flare + 4,
       "The two hub gussets would run into each other — increase beam_pitch.");
assert(plate_x >= hub_size + hub_flare + 2 * cav_inset,
       "Base plate is too narrow for a hub gusset and its border — increase plate_x.");
assert(carrier_z_max > carrier_z_min,
       "Post is too short for the holder — increase post_len or reduce carrier_h.");
assert(ts_tip_d / 2 < ts_min_r,
       "Thumbscrew dog point is wider than the thread core — reduce ts_tip_d.");
assert(ts_clamp_gap >= 1,
       "Thumbscrew is too short to reach the beam — increase ts_len or reduce boss_len.");
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
// and narrow at9 mm crest and a 0.9 mm root that is
// phi = 126 deg at the root tapering to 54oot that is
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
//
// It is cut into the case here AND cut again in holder(), after the
// arm is unioned on: the arm's plan profile runs right through the
// case wall, so without that second cut it would come back as solid
// plastic over the whole lower half of the slot.
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
// BENCH — base plate and sockets
// ============================================================

// The beams are HOLLOWED by a modelled core (lighten_post) rather than
// left for the slicer's infill: printed with 5 wall loops a 5 mm wall
// is plastic all the way through, so the core puts the material where a
// bending part wants it — in two thick walls — and the clamp screws
// still bear on solid plastic rather than on a skin.
// ============================================================
// POST RULER
// ============================================================
//
// Engraved, not raised: a proud scale would foul the sleeves that
// slide over it, whereas grooves simply add local clearance.
//
// Zero sits at socket_depth from the socketed end, so with the post
// fitted, a reading taken at a sleeve's lower edge IS that sleeve's
// height above the hub top.
//
// Every 5th and 10th graduation is cut wider as well as longer, so
// the eye can index the scale without counting — which matters at
// 1 mm pitch, where a 0.4 mm nozzle leaves only a thin ridge between
// neighbouring grooves.

function tick_len(v) = (round(v) % 10 == 0) ? tick_major
                     : (round(v) %  5 == 0) ? tick_medium
                     :                        tick_minor;

function tick_wid(v) = (round(v) % 5 == 0) ? tick_w_major : tick_w_minor;

// One face's worth of scale, drawn in 2D: the 2D x axis runs across
// the face, the 2D y axis runs along the beam.
module scale_face_2d() {
    for (n = [0 : floor(scale_span / scale_step)])
        let (v = n * scale_step)
            translate([-post_flat / 2, socket_depth + v - tick_wid(v) / 2])
                square([tick_len(v), tick_wid(v)]);

    if (scale_numbers)
        for (v = [0 : 10 : num_max])
            translate([-post_flat / 2 + tick_major + num_gap,
                       socket_depth + v + num_lift])
                text(str(v), size = num_size, halign = "left", valign = "baseline");
}

// Lift that onto the requested faces and sink it into the surface.
//
// The rotation matters: linear_extrude puts a glyph's readable face on
// the side it extrudes TOWARDS, so extruding straight into the post
// would engrave the numbers back to front.  rotate([0,0,180]) after
// rotate([90,0,0]) turns the extrusion outward again, leaving the text
// readable from outside while the solid still occupies the groove.
module scale_cut() {
    for (a = scale_face_angles)
        rotate([0, 0, a])
            translate([0, post_size / 2 - tick_deep, 0])
                rotate([0, 0, 180])
                    rotate([90, 0, 0])
                        linear_extrude(tick_deep + eps)
                            scale_face_2d();
}

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

        // The lightening core, run right through: the ends are symmetric
        // like everything else about the beam, and a clamp screw bearing
        // on one of its walls is bearing on solid plastic.
        if (lighten_post)
            translate([0, 0, -eps])
                linear_extrude(post_len + 2 * eps)
                    rounded_square(post_core, post_core, post_core_r);

        post_edge_chamfers();
        if (scale_on) scale_cut();
    }
}

// The socket hub: a square stub on the plate with the beam's
// socket bored down through it and on into the plate's solid pad.
module socket_hub(hy = 0) {
    translate([0, hy, plate_h]) {
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
module socket_negative(hy = 0) {
    translate([0, hy, socket_z0])
        linear_extrude(socket_depth + eps)
            square(socket_size, center = true);

    translate([0, hy, hub_top - hub_ch])
        linear_extrude(hub_ch + eps,
                       scale = socket_size / (socket_size + 2 * hub_ch))
            square(socket_size + 2 * hub_ch, center = true);
}

// The fill cavity: a ring of pockets around TWO solid load pads, braced by
// ribs.  Each pad carries its beam's load straight down to the cover, and the
// ribs keep every bridged span short.
//
// With the plate now long rather than square, one rib down the centreline is
// not enough: the pockets between the pads would bridge most of the plate's
// length.  So the cross ribs are spread along Y at a spacing that keeps every
// span short, rather than being a single pair on the axes.
module fill_cavity() {
    // Starts just below the rebate floor rather than exactly on it —
    // coincident faces there survive CGAL but make fragile geometry.
    translate([0, 0, cav_z0 - eps])
        linear_extrude(cav_depth + eps)
            difference() {
                rounded_square(cav_x, cav_y, plate_corner_r / 2);

                // Load-bearing pad under each beam.
                for (hy = hub_y) translate([0, hy]) square(pad_size, center = true);

                // Spine down the long axis.
                square([cav_rib, cav_y + 2], center = true);

                // Cross ribs, spread so no pocket bridges more than rib_span.
                for (i = [-rib_n : rib_n])
                    translate([0, i * rib_step])
                        square([cav_x + 2, cav_rib], center = true);
            }
}

module base_plate_solid() {
    union() {
        difference() {
            chamfered_box(plate_x, plate_y, plate_h, plate_ch, plate_corner_r);

            // Cover rebate, open downward.
            translate([0, 0, -eps])
                linear_extrude(cover_t + eps)
                    rounded_square(cover_x, cover_y, plate_corner_r / 2);

            // Snap groove that retains the cover's rib.
            translate([0, 0, cover_t / 2 - 0.45])
                linear_extrude(0.9)
                    difference() {
                        rounded_square(cover_x + 2 * snap_d,
                                       cover_y + 2 * snap_d, plate_corner_r / 2);
                        rounded_square(cover_x - 2, cover_y - 2, 1);
                    }

            // Weight cavity.
            fill_cavity();
        }

        // One socket hub per beam, each with the clamp station that locks
        // its beam down.  Both screws face the same way, side by side.
        for (hy = hub_y) {
            socket_hub(hy);
            translate([0, hy, 0])
                clamp_boss(boss_reach, hub_boss_len, hub_boss_z);
        }
    }
}

module base_plate() {
    difference() {
        base_plate_solid();
        for (hy = hub_y) {
            socket_negative(hy);
            translate([0, hy, 0])
                clamp_hole(boss_reach, hub_boss_z, hub_hole_depth);
        }
    }
}

// Snap-in cover that closes the fill cavity.
module base_cover() {
    cx = cover_x - 2 * cover_fit;
    cy = cover_y - 2 * cover_fit;
    union() {
        // Plate, with a chamfered leading edge to start it in.
        hull() {
            linear_extrude(0.8)
                rounded_square(cx - 1.2, cy - 1.2, plate_corner_r / 2);
            translate([0, 0, 0.8])
                linear_extrude(cover_t - 0.8)
                    rounded_square(cx, cy, plate_corner_r / 2);
        }

        // Retaining rib, sized to click into the plate's groove.
        translate([0, 0, cover_t / 2 - 0.35])
            linear_extrude(0.7)
                rounded_square(cx + 2 * (snap_d - 0.1),
                               cy + 2 * (snap_d - 0.1), plate_corner_r / 2);
    }
}

// ============================================================
// BENCH — holder (case + arm + carrier, one part)
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

// Case, arm and sleeve as ONE body.  The case and the sleeve are parallel
// vertical tubes standing case_gap apart, bridged by a cantilever arm that
// runs from the sleeve's centre right through to the case's — grown into
// both bodies rather than lapped onto their surfaces, so the weld is the
// full wall thickness at each end.  No clip, no shelf, no sprung arm,
// nothing that can rattle or fatigue.  The case is turned 180 deg so that
// slit_angle = 0 faces the slit outward, away from the beam, which also puts
// the arm on the case's blind side.  The arm still crosses the slit inside
// the case wall though, so the slit is cut a second time in holder().
//
// The arm is a single plan profile swept along the sleeve's axis, which is
// what keeps the whole holder printable in one upright orientation: swept
// that way it has no overhanging face anywhere. It is also the stiff way
// round.  Hung on the arm, the loaded case bends it about a section a full
// carrier_h deep, so the root stress is negligible; the fillets are there to
// keep the re-entrant corners from being stress risers, not to add strength.

// Plan profile: sleeve, arm and case tube grown together, then the
// re-entrant corners filled.  Growing before shrinking is what fillets a
// concave corner; the reverse, as the foot uses, rounds convex ones.
module holder_plan_2d() {
    difference() {
        offset(r = -arm_fillet) offset(r = arm_fillet)
            union() {
                rounded_square(sleeve_out, sleeve_out, 2);
                translate([-arm_w / 2, 0]) square([arm_w, case_cy]);
                translate([0, case_cy]) circle(r = body_r);
            }

        // Cut OUTSIDE the fillet offsets, so the blends stay whole.
        if (lighten_arm)
            translate([0, (arm_win_y0 + arm_win_y1) / 2])
                rounded_square(arm_win_w, arm_win_len, arm_window_r);
    }
}

// The arm as a solid.  The bore is cut back out of it above the case floor,
// so the fillet may run right into the tube without swallowing the magazine.
module case_arm() {
    difference() {
        linear_extrude(arm_h) holder_plan_2d();

        translate([0, case_cy, tube_floor_t])
            cylinder(h = arm_h + 1, r = bore_r);
    }
}

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

            // The arm out to the case.
            case_arm();

            // The case itself.
            translate([0, case_cy, 0])
                rotate([0, 0, 180])
                    case_body();
        }

        sleeve_bore_negative(carrier_h);

        // Threaded hole for the thumbscrew.
        clamp_hole(boss_reach, boss_z, ts_hole_depth);

        // The viewing slit, cut again — AFTER the arm, whose plan profile
        // runs right through the case wall.  Cut only in case_body it would
        // come back as solid plastic below the arm's top face, and the stack
        // would be visible over the top half of the slot only.
        translate([0, case_cy, 0])
            rotate([0, 0, 180])
                slit_cut();
    }
}

// ============================================================
// BENCH — stabiliser foot
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
// BENCH — edge clamp
// ============================================================
//
// Holds flat metal by its two SIDE EDGES only.  That constraint is the whole
// design: a magnet has to reach the metal, so nothing may lie across the face
// being worked on.  The clamp this replaced was a parallel-jaw vice whose
// upper arm and moving jaw both covered the work — fine for holding metal,
// useless for doing anything magnetic to it.
//
// THE SLAB is a flat plate reaching off a sliding sleeve.  Nothing more.  Its
// top face is the table the metal lies on, and its free front edge is the rail
// the grips ride on.
//
// THE GRIPS are plain C-clamp heads that hook over that edge.  Each one's
// SINGLE screw does three jobs at once: it presses the metal down onto the
// slab, it squeezes the slab between the metal and the grip's lower leg, and
// in doing so it locks the grip's own position along the edge.  That is why
// there is no separate hold-down and no second pinch screw — three screws
// hold the whole station where an earlier version of this clamp used seven.
//
// The metal is worked on where it OVERHANGS the slab's front edge.  There it
// is bare on both faces across its full width, and the grips are far enough
// behind that they never crowd the case coming down.  Under the grips
// themselves the slab supports the metal, which is what lets one screw a side
// be enough.
//
// WHY THE GRIP IS ITS OWN PART: a C printed upright has a horizontal roof over
// its throat, which is an unsupported overhang.  Printed on its back with the
// throat opening upward, both jaw faces become vertical walls and the web
// becomes a floor, so there is nothing to support.  The same rotation puts the
// screw's reaction, which tries to spread the C, along the layers rather than
// across the bonds.

// The slab: a sleeve on the beam and a flat plate reaching forward from it.
// Every wall is vertical and the plate starts on the bed, so printed upright
// there is nothing anywhere for the slicer to support.
module plate_clamp() {
    difference() {
        union() {
            // Sliding sleeve.
            linear_extrude(clamp_h)
                rounded_square(sleeve_out, sleeve_out, 2);

            // Beam clamp boss.  Behind the beam, clear of the slab.
            clamp_boss(boss_reach, boss_len, clamp_h / 2, clamp_screw_side);

            // The slab, sunk slab_merge into the sleeve's face.
            translate([-slab_half, slab_y0, 0])
                cube([2 * slab_half, slab_depth, slab_t]);
        }

        // Bore that slides on the beam, and the beam clamp thread.
        sleeve_bore_negative(clamp_h);
        clamp_hole(boss_reach, clamp_h / 2, ts_hole_depth, clamp_screw_side);
    }
}

// One grip: a C hooked over the slab's front edge, screw axis at x = 0.
// Modelled in the clamp's own z, so the throat straddles the slab exactly as
// it finds it.
module edge_grip() {
    difference() {
        // Clipped to the grip's footprint along the edge, which keeps the
        // screw boss from bulging past the inboard end and stopping the two
        // grips closing on a narrow workpiece.
        intersection() {
            translate([-grip_screw_in, grip_y0 - 1, grip_z0 - 1])
                cube([grip_w, grip_y2 - grip_y0 + 2, grip_boss_top - grip_z0 + 2]);

            union() {
                // Lower leg, reaching back under the slab.
                translate([-grip_screw_in, grip_y0, grip_z0])
                    cube([grip_w, grip_y2 - grip_y0, grip_z1 - grip_z0]);

                // Web, down the slab's front face.
                translate([-grip_screw_in, grip_y0, grip_z0])
                    cube([grip_w, grip_y1 - grip_y0, grip_z3 - grip_z0]);

                // Upper leg, reaching back over the metal.
                translate([-grip_screw_in, grip_y0, grip_z2])
                    cube([grip_w, grip_y2 - grip_y0, grip_z3 - grip_z2]);

                // Screw boss.
                translate([0, grip_screw_y, grip_z3])
                    cylinder(h = grip_boss_len, d = boss_d);
            }
        }

        // The one threaded hole, breaking through into the throat.
        translate([0, grip_screw_y, grip_boss_top])
            rotate([180, 0, 0])
                ts_thread_negative(grip_hole_d);
    }
}

// Where a grip's screw axis sits for a workpiece of the given width: one bite
// inside the metal's edge, held off the centreline so the pair cannot meet and
// off the slab's corner so they cannot run off it.
function grip_mouth(w) = min(max(w / 2 - grip_bite, mouth_min), mouth_max);

// The pair.  Mirror images, because the body is offset toward the inboard end
// — one module, rendered twice.
module edge_grips(w = 60) {
    m = grip_mouth(w);
    translate([ m, 0, 0]) edge_grip();
    translate([-m, 0, 0]) mirror([1, 0, 0]) edge_grip();
}

// ============================================================
// BENCH — printed thumbscrew
// ============================================================
//
// Prints head DOWN: the external thread then rises in the good
// direction and its 43 deg flanks are self-supporting.

module thumbscrew(len = ts_len) {
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
                         len / ts_pitch, ts_pitch);

        // Flat dog point that bears on the post face, or on the moving jaw.
        translate([0, 0, ts_head_t + len - eps])
            cylinder(h = ts_tip_len + eps, d1 = ts_tip_d, d2 = ts_tip_d - 1);
    }
}

// ============================================================
// ASSEMBLY
// ============================================================

// The bench, standing up and set to work.  Beam A carries the case; beam B,
// facing it across the middle of the base, carries the clamp.  The case
// reaches in from its own beam and comes down over the middle of whatever
// the grips are holding.
module stand_assembled(z = demo_carrier_z) {
    // Clamp to what a beam can actually offer, so the preview cannot show a
    // sleeve buried in the root gusset.
    carrier_z = min(max(z, carrier_z_min), carrier_z_max);
    clamp_z   = min(max(demo_clamp_z, carrier_z_min), carrier_z_max);

    base_plate();

    base_cover();

    // Both beams, dropped into their sockets and locked down.
    for (hy = hub_y)
        translate([0, hy, 0]) {
            translate([0, 0, socket_z0]) post();
            clamp_screw(boss_reach, hub_boss_z);
        }

    // Edge clamp on beam B, with a workpiece in its grips.
    translate([0, beam_pitch / 2, clamp_z]) {
        plate_clamp();
        clamp_screw(boss_reach, clamp_h / 2, clamp_screw_side);

        edge_grips(demo_metal_w);

        // One screw per grip, drawn wound in until its tip is on the metal.
        m = grip_mouth(demo_metal_w);
        for (mir = [1, -1])
            translate([mir * m, grip_screw_y,
                       slab_t + demo_metal_t + ts_head_t + grip_reach])
                rotate([180, 0, 0]) thumbscrew(vs_len);
    }

    // Holder on beam A.
    translate([0, -beam_pitch / 2, carrier_z]) {
        holder();

        // Rotated with the case: turning the case 180 deg shifts its
        // helix phase by half a pitch, so the cap must follow.
        translate([0, case_cy, neck_z0]) rotate([0, 0, 180]) case_cap();

        // Thumbscrew, wound in until its dog point clamps the beam.
        clamp_screw(boss_reach, boss_z);
    }
}

// ============================================================
// REPORT
// ============================================================

magnet_count = floor(inner_depth / magnet_t);
visible_span = slit_z1 - slit_z0 + slit_w;

// Cavity area: the rectangle, less two load pads, less the ribs that do not
// already fall inside a pad.  A pad is clipped where it runs out to the
// cavity's own edge, which is why its depth is measured rather than assumed.
pad_y0       = beam_pitch / 2 - pad_size / 2;
pad_y1       = min(beam_pitch / 2 + pad_size / 2, cav_y / 2);
pad_depth    = pad_y1 - pad_y0;
cav_area     = cav_x * cav_y
             - 2 * pad_size * pad_depth
             - (cav_rib * cav_y - 2 * cav_rib * pad_depth)
             - (2 * rib_n + 1) * (cav_x * cav_rib - cav_rib * cav_rib);
cav_volume   = cav_area * cav_depth / 1000;

// Where the two beams put their working surfaces, and therefore whether they
// can be brought together.  Read at a sleeve's lower edge on the ruler.
case_floor_lo = carrier_z_min;
case_floor_hi = carrier_z_max;
work_top_lo   = carrier_z_min + work_rest;
work_top_hi   = carrier_z_max + work_rest + grip_max;

// How far the case reaches in from its beam, in base coordinates, and how
// much daylight it leaves against the clamp's sleeve and slab.
case_at_y     = -beam_pitch / 2 + case_cy;
clear_sleeve  = (beam_pitch / 2 - sleeve_out / 2) - (case_at_y + body_r);
clear_slab    = (beam_pitch / 2 - slab_reach) - (case_at_y + body_r);
grip_front_y  = beam_pitch / 2 + grip_y0;           // nearest the case
grip_back_y   = beam_pitch / 2 + grip_y2;
case_ahead    = grip_front_y - (case_at_y + body_r);

// The slab's free edge, and how far the metal has to reach past it before the
// case can be brought down on bare metal.
slab_edge_y   = beam_pitch / 2 - slab_reach;
work_overhang = slab_edge_y - (case_at_y - body_r);

echo(str("CASE   OD ", body_od, " mm, closed height ", case_h,
         " mm, bore ", bore_d, " mm, wall ", (body_od - bore_d) / 2, " mm"));
echo(str("CASE   thread M", thread_maj_r * 2, " x ", thread_pitch,
         " right-hand, ", male_turns, " turns engaged, neck wall ", neck_wall, " mm"));
echo(str("CASE   holds ", magnet_count, " x ", magnet_t,
         " mm magnets; ", visible_span, " mm of the stack visible through the slit"));
echo(str("CASE   floor is ", tube_floor_t,
         " mm — the only plastic between the bottom magnet and the workpiece"));
echo(str("BENCH  base ", plate_x, " x ", plate_y, " x ", plate_h,
         " mm carrying TWO ", hub_size, " mm hubs ", hub_h, " mm tall, ",
         beam_pitch, " mm apart"));
echo(str("BEAM   PRINT TWO: ", post_size, " mm square x ", post_len,
         " mm, each printed LYING DOWN; ", socket_depth,
         " mm sits in the socket, ", post_free,
         " mm stands proud.  Overall height ", post_top, " mm"));
echo(str("BEAM   each is removable on one thumbscrew in its hub.  Up to ",
         floor(post_free / carrier_h), " sleeves fit on a free length"));

if (scale_on)
    echo(str("RULER  ", scale_step, " mm graduations, 0 to ", scale_span,
             ", numbered to ", num_max, ", on faces ", scale_face_angles,
             " (the bed face, ", bed_face, ", is left blank).",
             "  Zero is at the hub top: read at a sleeve's lower edge and",
             " the case floor sits that reading + ", hub_top, " mm above the bench"));

if (scale_on)
    echo(str("RULER  a sleeve can reach 0 to ", scale_usable,
             " on the scale; marks above that are for laying out work, not for",
             " the holder, which would overhang the end of the beam"));
echo(str("BENCH  fill cavity ", cav_volume,
         " cm3  ~=  ", round(cav_volume * 1.6), " g of sand, ",
         round(cav_volume * 6.5), " g of lead shot"));
echo(str("BENCH  cavity braced by a spine and ", 2 * rib_n + 1,
         " cross ribs, so the widest bridged pocket is ", rib_gap, " mm"));
echo(str("BENCH  sleeve travel ", carrier_z_min, " to ", carrier_z_max,
         " mm  (", carrier_z_max - carrier_z_min, " mm of adjustment on each beam)"));
echo(str("HOLDER case, arm and sleeve are ONE part, ", holder_h,
         " mm tall.  The case stands ", case_cy,
         " mm off the beam axis — ", case_gap, " mm of clear air spanned by an ",
         arm_w, " x ", arm_h, " mm arm, grown into both bodies rather than",
         " lapped onto them"));
if (lighten_post)
    echo(str("LIGHTENING: each beam hollowed by a ", post_core, " x ", post_core,
             " mm core, leaving ", post_wall, " mm walls — removes ~",
             post_core * post_core * post_len / 1000, " cm3 per beam, ",
             2 * post_core * post_core * post_len / 1000,
             " cm3 the pair, costing ~",
             100 * (1 - (pow(post_size, 4) - pow(post_core, 4)) / pow(post_size, 4)),
             " % of the solid section's bending stiffness"));
if (lighten_arm)
    echo(str("LIGHTENING: arm window ", arm_win_w, " x ", arm_win_len,
             " mm through a ", arm_h, " mm arm removes ~",
             arm_win_w * arm_win_len * arm_h / 1000,
             " cm3 from a section whose root stress is under 0.1 MPa"));
echo(str("LIGHTENING: plate ", plate_h, " mm thick (socket sinks ", socket_sink,
         " below the top face, roof left ", plate_ceiling, " mm); cavity border ",
         cav_inset, " mm; hub wall ", hub_wall, " mm; slab ", slab_t,
         " mm; foot pad ", foot_pad_t, " mm.  The beams carry their own",
         " hollow; keep infill low (10-15 % gyroid), grips and threads denser"));
echo(str("LAYOUT the case lands ", case_at_y,
         " mm from the base's centre, clearing the clamp's sleeve by ",
         clear_sleeve, " mm and its slab by ", clear_slab, " mm"));
echo(str("LAYOUT the grips sit from ", grip_back_y, " to ", grip_front_y,
         " mm, entirely behind the case, which clears the nearest of them by ",
         case_ahead, " mm.  So the grips never crowd it, whatever width they",
         " are set to"));
echo(str("LAYOUT the metal must overhang the slab's front edge by at least ",
         work_overhang, " mm to reach under the case.  Everything forward of",
         " that edge is bare on both faces, full width"));
echo(str("CLAMP  slab ", 2 * slab_half, " mm wide reaching ", slab_reach,
         " mm from the beam.  The metal lies on it and overhangs the front",
         " edge; two C grips hook that edge and take ", work_w_min, " to ",
         work_w_max, " mm of workpiece, 0 to ", grip_max, " mm thick"));
echo(str("CLAMP  ONE screw per grip.  It presses the metal down, squeezes the",
         " slab between the metal and the grip's lower leg, and locks the",
         " grip's own position — so the whole station tightens at TWO places",
         " plus the beam"));
echo(str("CLAMP  the jaw yields at about ", round(grip_screw_lim),
         " N of screw force, acting through a ", grip_leg_arm,
         " mm lever.  Hand-tight on a ", ts_head_d,
         " mm head is roughly 270 N, so it is the SCREW, not the magnets, that",
         " sets how strong this part has to be"));
echo(str("CLAMP  a grip covers ", grip_cover,
         " mm of each edge, so under the grips a ", demo_metal_w,
         " mm workpiece keeps ", work_bare(demo_metal_w),
         " mm bare.  Forward of the slab's edge it is bare full width, both",
         " faces — that overhang is where the work gets done"));
echo(str("CLAMP  the metal rests ", work_rest,
         " mm above the clamp's base, so its top face sweeps ", work_top_lo,
         " to ", work_top_hi, " mm while the case floor sweeps ", case_floor_lo,
         " to ", case_floor_hi, " mm — overlapping over ",
         min(work_top_hi, case_floor_hi) - max(work_top_lo, case_floor_lo),
         " mm, so the magnets can always be brought down onto the metal"));
echo(str("FOOT   ", foot_span, " x ", foot_len,
         " mm pad, flush with the holder's sleeve so both sit on the bench"));
echo(str("FOOT   laid flat, tips at about ", tip_angle, " deg with the foot vs ",
         tip_bare, " deg on the bare sleeve alone"));
echo(str("FOOT   keep it at least ", foot_min_gap,
         " mm along the beam from the holder's base — its boss shares the",
         " arm's side of the beam"));
echo(str("SCREW  M", ts_major_d, " x ", ts_pitch, " printed thumbscrew, ",
         ts_head_d, " mm knurled head.  PRINT SEVEN: five at ", ts_len,
         " mm of thread (two hubs, holder, foot, clamp beam) and two at ",
         vs_len, " mm for the grips"));
echo(str("SCREW  hub, holder and foot screws sit on faces ", screw_side, " and ",
         foot_screw_side, " deg; the clamp's beam screw on face ",
         clamp_screw_side, " deg, behind the beam and clear of the slab.  The",
         " two grip screws point straight down onto the work"));

if (magnet_d > bore_d - 0.4)
    echo(str("WARNING: magnet_d ", magnet_d, " mm is a tight/interference fit in a ",
             bore_d, " mm bore — increase bore_d to at least ", magnet_d + 0.4, " mm."));

if (magnet_d < slit_w + 2)
    echo(str("WARNING: magnet_d ", magnet_d,
             " mm is small relative to the ", slit_w,
             " mm slit — magnets could escape.  Narrow slit_w."));

if (post_len > 250)
    echo(str("NOTE: each of the two beams is ", post_len,
             " mm long — check that two of them fit your bed lying down."));

if (work_top_hi < case_floor_lo || work_top_lo > case_floor_hi)
    echo("WARNING: the case floor and the clamped metal cannot be brought to the same height.");

if (demo_metal_w < work_w_min || demo_metal_w > work_w_max)
    echo(str("WARNING: the preview is posed for ", demo_metal_w,
             " mm of metal, which is outside the ", work_w_min, " to ",
             work_w_max, " mm the grips actually reach."));

// ============================================================
// RENDER
// ============================================================

if (part == "holder" || part == "case" || part == "carrier" || part == "bottom") {

    holder();

} else if (part == "cap" || part == "top") {

    case_cap();

} else if (part == "post" || part == "beam") {

    // Print orientation: lying on one face, rolled so the bed gets an
    // unmarked face.  PRINT TWO — the bench needs a beam per station.
    translate([0, 0, post_size / 2])
        rotate([0, 90, 0])
            rotate([0, 0, post_print_roll])
                post();

} else if (part == "foot") {

    foot();

} else if (part == "clamp") {

    plate_clamp();

} else if (part == "grip") {

    // On its back, web face down, throat opening upward.  See the header:
    // this orientation is the reason the grip is a separate part at all.
    translate([0, 0, -grip_y0]) rotate([90, 0, 0]) edge_grip();

} else if (part == "vicescrew" || part == "pinchscrew") {

    thumbscrew(vs_len);

} else if (part == "base") {

    base_plate();

} else if (part == "cover") {

    base_cover();

} else if (part == "thumbscrew") {

    thumbscrew();

} else if (part == "horizontal") {

    // The other way this gets used: ONE beam pulled out of its socket and
    // laid on the bench, case pointing UP and both thumbscrews pointing
    // sideways rather than down into the bench.  The rig rests on the
    // holder's sleeve, which stands proud of the beam.
    //
    // The case now sits much higher above the bench than it used to, on its
    // arm, so the foot has been widened to suit.  Only one beam is shown:
    // laid flat the second one is simply a spare.
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

} else if (part == "exploded" || part == "plate") {

    // THE WHOLE MACHINE, on one 270 x 270 bed.  Seventeen objects: two beams,
    // the base and its cover, the holder, the cap, the clamp slab, both grips,
    // the foot and seven thumbscrews.  One command builds the lot.
    //
    // The two beams are what make this tight: at 186 mm they are longer than
    // any free stretch left once the base is down.  So they stand ON END up
    // the left edge, out of the way, and everything else stacks down the bed
    // beside them.  The base and its cover lie long-axis-along-X for the same
    // reason.  Laid any other way the set does not fit and has to be split
    // across two plates, which is a good way to print half a machine.

    translate([-122.00,  -93.00, 0])
        translate([0, 0, post_size / 2]) rotate([0, 0, 90]) rotate([0, 90, 0]) rotate([0, 0, post_print_roll]) post();
    translate([ -99.00,  -93.00, 0])
        translate([0, 0, post_size / 2]) rotate([0, 0, 90]) rotate([0, 90, 0]) rotate([0, 0, post_print_roll]) post();
    translate([  -2.00,   87.00, 0])
        rotate([0, 0, 90]) base_plate();
    translate([  -8.80,    1.80, 0])
        rotate([0, 0, 90]) base_cover();
    translate([ -24.00,  -59.80, 0])
        plate_clamp();
    translate([ -31.00, -119.15, 0])
        foot();
    translate([  97.35,   60.35, 0])
        holder();
    translate([  79.00,    4.00, 0])
        translate([0, 0, -grip_y0]) rotate([90, 0, 0]) edge_grip();
    translate([ 102.00,    4.00, 0])
        translate([0, 0, -grip_y0]) rotate([90, 0, 0]) mirror([1, 0, 0]) edge_grip();
    translate([ 121.45,  -21.50, 0])
        translate([0, 0, cap_h]) rotate([180, 0, 0]) case_cap();
    translate([  49.90,  -84.09, 0])
        thumbscrew();
    translate([  72.90,  -84.09, 0])
        thumbscrew();
    translate([  95.90,  -84.09, 0])
        thumbscrew();
    translate([ 118.90,  -84.09, 0])
        thumbscrew();
    translate([  49.90,  -61.09, 0])
        thumbscrew();
    translate([  72.90,  -61.09, 0])
        thumbscrew(vs_len);
    translate([  95.90,  -61.09, 0])
        thumbscrew(vs_len);

} else {  // "assembly" / "both"

    stand_assembled();

}
