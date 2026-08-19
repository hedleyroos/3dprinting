// ============================================================
// Magnet Pill Container — screw-cap tube with a viewing slit
//
// A small "pill bottle" for a stack of disc magnets:
//   * 13 mm bore, 80 mm usable depth.
//   * An open vertical slit down one side so the stack is
//     visible from outside — you can see how many are left
//     without opening it.
//   * A screw-on cap that finishes FLUSH with the body: the
//     closed container is one smooth 21 mm cylinder, no
//     shoulder.
//
// Standalone — no external dependencies.  The thread geometry
// is generated from scratch (see THREAD GENERATION below);
// no thread library is used.
//
// Coordinate system:
//   Z = up, origin at the centre of the body's outside floor.
//   The cap is modelled in its own local frame with z = 0 at
//   its open rim, and is translated up to the neck for the
//   assembled view.
//
// Print orientation:
//   * Body — upright, base on the bed.  The bore opens upward,
//     the 45 deg thread flanks are self-supporting, and the
//     slit is a vertical slot with a rounded top.  No supports.
//   * Cap  — closed top DOWN.  The internal thread's 45 deg
//     overhangs then print unsupported.  No supports.
//   Both orientations lay the layer lines perpendicular to the
//   thread's axial load, which is the right way round for the
//   torque of unscrewing.
//
// All units: millimeters.
// ============================================================

/* [Part] */
part = "both";  // [bottom:Body, top:Cap, both:Assembled, exploded:Print layout]

/* [Container] */
bore_d          = 13;    // Inner diameter of the tube
inner_depth     = 80;    // Usable depth for the magnet stack (includes the neck)
base_t          = 2.5;   // Thickness of the closed floor
neck_wall       = 1.35;  // Wall thickness of the threaded neck (thinnest section)
cap_wall        = 1.65;  // Side wall thickness of the cap
cap_top_t       = 2.5;   // Thickness of the cap's closed top

/* [Thread] */
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
slit_angle      = 0;     // Which way the slit faces, degrees about Z

/* [Grip] */
flute_count     = 18;    // Number of grip scallops around the cap
flute_r         = 1.2;   // Radius of each scallop
flute_depth     = 0.55;  // How deep each scallop bites into the cap wall

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

// --- Radial stack-up, working outward from the bore ---------
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

// --- Axial stack-up -----------------------------------------
body_h        = base_t + inner_depth;               // total body height
neck_h        = thread_pitch * thread_turns;        // threaded neck height
neck_z0       = body_h - neck_h;                    // shoulder the cap seats on

thread_runout = thread_pitch / 4;                   // plain relief above the shoulder
male_z0       = neck_z0 + thread_runout;
male_turns    = (neck_h - thread_runout) / thread_pitch;

seat_clear    = 0.4;                                // cap stops on the shoulder, not the neck top
cap_inner_h   = neck_h + seat_clear;
cap_h         = cap_inner_h + cap_top_t;

// Female thread starts one whole pitch below the male's start
// (in cap-local coordinates), which keeps the two helices in
// phase — an integer number of pitches apart.
f_z0          = thread_runout - thread_pitch;
f_turns       = ceil((cap_inner_h - f_z0 + thread_pitch) / thread_pitch);

// --- Thread lobe angles -------------------------------------
// See THREAD GENERATION.  Angular half-width of the 2D lobe at
// the root and at the crest; these map to axial half-heights of
// (thread_pitch - thread_root)/2 and thread_crest/2.
phi_root      = ((thread_pitch - thread_root) / 2) / thread_pitch * 360;
phi_crest     = (thread_crest / 2) / thread_pitch * 360;

// Clearance widens the female lobe by fit_clear_ax/2 axially on
// each flank, i.e. by the same angle at every radius.
phi_clear     = (fit_clear_ax / 2) / thread_pitch * 360;
f_phi_root    = phi_root  + phi_clear;
f_phi_crest   = phi_crest + phi_clear;

// --- Slit ---------------------------------------------------
slit_z0       = base_t + slit_margin_bot + slit_w / 2;
slit_z1       = neck_z0 - slit_margin_top - slit_w / 2;

// --- Chamfers -----------------------------------------------
lead_in       = thread_depth;   // thread lead-in chamfer, can't exceed the thread depth
edge_ch       = 0.6;            // cosmetic chamfer on the outer base and cap top

// --- Sanity guards ------------------------------------------
assert(f_phi_root < 175,
       "Female thread root lobe is too wide — increase thread_pitch or reduce thread_root/clearances.");
assert(thread_crest + thread_root + 2 * thread_depth <= thread_pitch + eps,
       "Thread profile does not fit in one pitch — reduce thread_crest/thread_root/thread_depth.");
assert(slit_z1 > slit_z0,
       "Slit margins leave no room for a slit — reduce slit_margin_top/bot or increase inner_depth.");
assert(cap_wall - flute_depth >= 0.8,
       "Grip flutes cut the cap wall too thin — reduce flute_depth or increase cap_wall.");

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
// advances counter-clockwise.  Both the male and the female
// thread come from this one module, so their handedness, lead
// and phase always agree.

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
module thread_solid(r_min, r_maj, p_root, p_crest, turns) {
    linear_extrude(height     = thread_pitch * turns,
                   twist      = -360 * turns,
                   slices     = max(24, round(turns * 72)),
                   convexity  = 10)
        thread_profile_2d(r_min, r_maj, p_root, p_crest);
}

// ============================================================
// SHARED CUTTERS
// ============================================================

// Ring-shaped cutter that chamfers an outside edge.  Removes
// everything outside a cone running from radius r1 at the bottom
// to r2 at the top, over height h.
module outer_chamfer(h, r1, r2) {
    difference() {
        cylinder(h = h, r = body_r + 2);
        translate([0, 0, -eps])
            cylinder(h = h + 2 * eps, r1 = r1, r2 = r2);
    }
}

// ============================================================
// BODY  (the "bottom" part)
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

module body() {
    difference() {
        union() {
            // Main tube, up to the shoulder.
            cylinder(h = neck_z0, r = body_r);

            // Rebated neck: its core sits well inside the body OD,
            // leaving room for the cap wall so the closed container
            // is flush.
            translate([0, 0, neck_z0])
                cylinder(h = neck_h, r = thread_min_r);

            // Male thread, starting a short runout above the
            // shoulder so the cap's rim can reach the shoulder.
            translate([0, 0, male_z0])
                thread_solid(thread_min_r, thread_maj_r,
                             phi_root, phi_crest, male_turns);
        }

        // Bore.
        translate([0, 0, base_t])
            cylinder(h = body_h - base_t + 1, r = bore_r);

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
// CAP  (the "top" part)
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

// Grip scallops milled INTO the cap's outer surface — subtracted
// rather than added, so the flush outer diameter is preserved.
module cap_flutes() {
    d = cap_od / 2 + flute_r - flute_depth;
    for (i = [0 : flute_count - 1])
        rotate([0, 0, i * 360 / flute_count])
            translate([d, 0, -eps])
                cylinder(h = cap_h + 2 * eps, r = flute_r);
}

module cap() {
    difference() {
        cylinder(h = cap_h, r = cap_od / 2);

        // Threaded bore.
        cap_bore_negative();

        // Lead-in flare at the open rim.
        translate([0, 0, -eps])
            cylinder(h = lead_in + eps, r1 = f_maj_r + lead_in, r2 = f_maj_r);

        // Grip.
        cap_flutes();

        // Cosmetic chamfer on the closed top edge.
        translate([0, 0, cap_h - edge_ch])
            outer_chamfer(edge_ch + eps, cap_od / 2, cap_od / 2 - edge_ch);

        // Cosmetic chamfer on the rim edge.
        translate([0, 0, -eps])
            outer_chamfer(edge_ch + eps, cap_od / 2 - edge_ch, cap_od / 2);
    }
}

// ============================================================
// CAPACITY REPORT
// ============================================================

magnet_count = floor(inner_depth / magnet_t);
visible_span = slit_z1 - slit_z0 + slit_w;

echo(str("Body: OD ", body_od, " mm x ", body_h,
         " mm tall, bore ", bore_d, " mm, wall ", (body_od - bore_d) / 2, " mm"));
echo(str("Closed height: ", neck_z0 + cap_h, " mm  (cap ", cap_h, " mm)"));
echo(str("Thread: M", thread_maj_r * 2, " x ", thread_pitch,
         " right-hand, ", male_turns, " turns of engagement"));
echo(str("Neck wall at the thread root: ", neck_wall, " mm"));
echo(str("Capacity: ", magnet_count, " x ", magnet_t,
         " mm magnets in ", inner_depth, " mm of depth"));
echo(str("Slit: ", slit_w, " mm wide, ", visible_span,
         " mm of the stack visible (z ", slit_z0 - slit_w / 2,
         " to ", slit_z1 + slit_w / 2, ")"));

if (magnet_d > bore_d - 0.4)
    echo(str("WARNING: magnet_d ", magnet_d, " mm is a tight/interference fit in a ",
             bore_d, " mm bore — increase bore_d to at least ", magnet_d + 0.4, " mm."));

if (magnet_d < slit_w + 2)
    echo(str("WARNING: magnet_d ", magnet_d,
             " mm is small relative to the ", slit_w,
             " mm slit — magnets could escape.  Narrow slit_w."));

// ============================================================
// RENDER
// ============================================================

if (part == "bottom") {

    body();

} else if (part == "top") {

    cap();

} else if (part == "exploded") {

    // Both pieces in their print orientations, side by side with
    // a 5 mm gap.  Well inside a 270 x 270 mm bed.
    gap = 5;
    dx  = body_r + gap / 2;

    // Body — upright, floor on the bed.
    translate([-dx, 0, 0])
        body();

    // Cap — flipped closed-top-down so the internal thread prints
    // with its overhangs supported by the layer below.
    translate([dx, 0, cap_h])
        rotate([180, 0, 0])
            cap();

} else {  // "both" — assembled, for fit checking

    body();

    translate([0, 0, neck_z0])
        cap();

}
