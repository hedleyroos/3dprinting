// ============================================================
// Handbag Scroll Hook — portable table hook, scroll form
//
// A flat arm that lies on the tabletop, turns down past the edge and
// rolls into a deep scroll. The bag's strap drops into the scroll and
// rests in the bottom of the loop. Carried in the bag itself, so it is
// smooth all over and has no moving parts, fasteners or assembly.
//
// Unlike a clamp-style hook, this one touches nothing but the tabletop —
// not the edge face, not the underside. That has one large consequence:
// there is no table thickness range to fit and no fitting angle to take
// up. The only thing the thickness sets is how far down the scroll has
// to start so it clears the underside, and that is derived below.
//
// How it holds: the strap rests directly below the arm, so the whole
// thing is a weight on a shelf, not a clamp. Two conditions make it
// stable, and both are asserted rather than trusted:
//
//   * The strap's resting point must lie INBOARD of the table edge and
//     within the footprint of the bumpers. The load line then falls
//     inside the contact patch and the arm simply presses down — there
//     is no tipping moment to resist and no friction required.
//   * Under weight alone it cannot tip at all. The strap hangs far BELOW
//     the table edge, so tipping outboard by an angle a swings the load
//     line inboard by strap_drop * sin(a), and a hanging bag pulls straight
//     down through the strap point however much it swings.
//
// The real limit is a SIDEWAYS push on the bag — a knee, a chair, someone
// squeezing past. That acts at the full strap_drop lever, while all that
// resists it is the bag's own weight at the much shorter strap_offset
// lever, so it takes only strap_offset/strap_drop of the bag's weight to
// lift the arm. Resting on the tabletop alone buys freedom from any
// thickness limit and pays for it here; a hook that catches the underside
// cannot be tipped at all. The echoed figure reports the push it takes.
//
// The other price is that the bag hangs at the table edge rather than clear
// of it — strap_offset is deliberately negative. Pushing it outboard buys
// clearance and spends stability.
//
// Coordinate system (installed):
//   X = outboard, +X away from the table. The table edge face is X = 0
//       and the table occupies X < 0.
//   Y = hook width.
//   Z = up. The tabletop is Z = 0 and its underside is Z = -t.
//
// Print orientation: the profile lies flat on the bed and the part is
// extruded along its width, so every bending stress runs in-plane along
// the extrusion paths and no layer bond is ever loaded in tension. The
// body is a plain prism and needs no support. The only departure is the
// bumper pockets, whose axes end up horizontal — each is a shallow blind
// hole with a short self-supporting lip, which is why the recess is 1 mm.
//
// All units: millimetres.
// ============================================================

/* [Quality] */
$fa = 1;   // Minimum angle — 1 degree gives max 360 facets per full circle
$fs = 0.4; // Minimum facet edge length (mm) — matched to a 0.4 mm nozzle

/* [Table] */
// Sets only how deep the scroll starts, so it clears the underside. The
// hook works on any thickness up to this; thicker simply makes it taller.
table_thickness_max = 50;  // Thickest top the scroll must hang clear of (mm)
curl_clearance      = 2;   // Gap from the scroll's crown to the underside (mm)

/* [Form] */
curl_outer_dia = 60;  // Outside diameter of the scroll (mm)
curl_sweep     = 190; // Arc the scroll turns through (degrees)
                      //   Just past a half turn, so the tail tip finishes a
                      //   little above the centre height: enough to stop the
                      //   strap rolling back out, but leaving the loop wide
                      //   open to drop it into. Below 180 the tip falls under
                      //   the centre and no longer retains anything.
arm_reach      = 40;  // How far the arm lies inboard on the table (mm)
strap_offset   = -8;  // Where the strap rests, relative to the table edge (mm)
                      //   Must be negative — inboard — and inside the bumper
                      //   footprint, or the hook tips. See the asserts.

/* [Ribbon] */
ribbon_thickness = 7;   // Ribbon section thickness (mm)
hook_width       = 30;  // Ribbon section width (mm)
                        //   Set by the bumpers: two 10 mm pockets side by
                        //   side need about 22 mm of flat, and the flat band
                        //   is hook_width - 2 * rim_radius.
rim_radius       = 2;   // Rounding on both side rims (mm)
arm_fillet       = 12;  // Radius of the turn-down off the arm (mm)

/* [Grip] */
// Four round self-adhesive bumpers under the arm: a pair flush with the
// table edge and a pair flush with the far end of the arm, as far apart as
// the arm allows. The outboard pair's edge is the tipping limit, so putting
// it as far outboard as the table allows is what maximises the margin; the
// inboard pair is what stops the hook rocking and yawing.
grip_style            = "pads";  // pads | smooth
grip_bumper_dia       = 10;      // Bumper diameter (mm)
grip_bumper_thickness = 3;       // Bumper thickness (mm)
grip_pad_recess       = 1.0;     // Depth of the pocket (mm)
grip_bumper_clearance = 0.4;     // Pocket oversize on diameter (mm)
grip_bumper_gap       = 3.0;     // Plastic left between neighbouring pockets (mm)

/* [Load] */
// Reported only; does not change the geometry.
working_load = 4;   // Design bag weight (kg)
proof_load   = 12;  // Proof load the section is checked against (kg)

/* [View] */
part                    = "print";  // print | both
preview_table_thickness = 25;       // Table drawn in the "both" view (mm)

// ============================================================
// DERIVED
// ============================================================

eps     = 0.01;
bar_r   = ribbon_thickness / 2;
gravity = 9.81;  // m/s^2, for the reported loads

// How far the bumper pockets are run out past the surface into open air.
// Their mouths would otherwise be exactly coplanar with the face they are
// cut into, which CGAL resolves by shattering the part into slivers.
grip_overcut = 1;

// The bumpers stand this far proud of the plastic, so the arm floats clear
// of the tabletop and only rubber touches the finish.
land_h = grip_bumper_thickness - grip_pad_recess;

// Ribbon centrelines. The arm is flat, with its bumper faces on Z = 0.
arm_z     = bar_r + land_h;
arm_top_z = 2 * bar_r + land_h;

// The scroll is placed by the highest material it carries, which has to
// clear the underside of the top. Where that is depends on the sweep, and
// getting it wrong just hangs the hook lower than it needs to:
//
//   sweep >= 270  the arc reaches 12 o'clock, so the crown is a full
//                 radius above the centre.
//   180 < sweep   the arc stops short of the top and the highest point is
//        < 270    the tail tip itself, at curl_r * -sin(sweep) above centre
//                 — only 0.17 of a radius at 190 degrees.
//
// The angle-0 end of the arc sits at the spine, outboard of the table edge,
// so it never needs clearance and does not enter this.
curl_r     = curl_outer_dia / 2 - bar_r;
curl_rise  = curl_sweep >= 270 ? 1 : (curl_sweep <= 180 ? 0 : -sin(curl_sweep));
curl_crown = curl_r * curl_rise + bar_r;
curl_top_z = -(table_thickness_max + curl_clearance);
curl_c     = [strap_offset, curl_top_z - curl_crown];

// The spine runs down tangent to the scroll, so it meets it at 3 o'clock.
spine_x = curl_c[0] + curl_r;

arm_tip    = [-arm_reach, arm_z];
arm_end    = [spine_x - arm_fillet, arm_z];
fillet_c   = [spine_x - arm_fillet, arm_z - arm_fillet];
spine_top  = [spine_x, arm_z - arm_fillet];
curl_start = [spine_x, curl_c[1]];

curl_steps = max(36, ceil(curl_sweep / 5));

function arc_point(centre, radius, angle) = [
    centre[0] + radius * cos(angle),
    centre[1] + radius * sin(angle)
];

function arc_points(centre, radius, a0, a1, steps) = [
    for (i = [0 : steps])
        arc_point(centre, radius, a0 + (a1 - a0) * i / steps)
];

function curl_points() = arc_points(curl_c, curl_r, 0, -curl_sweep, curl_steps);

curl_tip      = curl_points()[curl_steps];
curl_bottom_z = curl_c[1] - curl_r - bar_r;
total_height  = arm_top_z - curl_bottom_z;

// The strap settles on the inside of the loop at its lowest point, which
// is where the bag load acts.
strap_pt   = [curl_c[0], curl_c[1] - curl_r + bar_r];
strap_drop = -strap_pt[1];

// Clear opening between the tail tip and the inboard face of the spine.
curl_mouth = (spine_x - bar_r) - (curl_tip[0] + bar_r);

// That mouth cannot be used from above. Once the hook is on the table the
// loop is a closed pocket in this plane: the arm roofs the gap between the
// table edge and the spine, and the only other way in is the curl_clearance
// gap over the tail tip, which is 2 mm. Verified by sweeping a cylinder
// down — even a 6 mm handle stops dead against the underside of the arm.
//
// So a strap is threaded in SIDEWAYS, along the hook's width, where the
// loop is an open tunnel. What limits that is not the loop but the table
// cutting into the top of it: the usable passage is the clear height
// between the table's underside and the inside of the loop's bottom.
//
// Note what drops out of this — the table thickness cancels. The whole
// scroll is placed relative to the underside, so it descends with it and
// the passage is the same on a 25 mm top as on a 50 mm one.
handle_clear = curl_clearance + curl_crown + curl_r - bar_r;

// Bumper layout. Both pairs are placed from where the bumper EDGE has to
// land, not from their centres: the outboard pair finishes flush with the
// table edge, and the inboard pair flush with the end of the arm. That
// spreads the feet over the whole arm instead of clustering them near the
// edge, which is what resists the hook yawing or rocking when the bag
// swings. It does not change the tipping force — that is set by where the
// load line sits relative to the outboard edge, i.e. by strap_offset alone.
pocket_dia  = grip_bumper_dia + grip_bumper_clearance;
pocket_y    = (pocket_dia + grip_bumper_gap) / 2;
flat_half_y = hook_width / 2 - rim_radius;

pad_pocket_x = [-grip_bumper_dia / 2, -arm_reach + grip_bumper_dia / 2];

// The contact patch is bounded by the bumpers themselves, not the pockets.
grip_out         = 0;
grip_in          = pad_pocket_x[1] - grip_bumper_dia / 2;
pad_pocket_in    = pad_pocket_x[1] - pocket_dia / 2;
pad_pocket_out   = pad_pocket_x[0] + pocket_dia / 2;
pocket_half_span = pocket_y + pocket_dia / 2;

// Stability. Under pure weight the hook cannot tip: the strap hangs below
// the table edge, so tipping outboard by an angle swings the load line
// further inboard, and a hanging bag pulls straight down through the strap
// point however much it swings. What can tip it is a SIDEWAYS push on the
// bag — a knee, a chair, someone squeezing past — because that acts at the
// full strap_drop lever while the only thing resisting is the bag's weight
// at the much shorter strap_offset lever.
tip_margin = grip_out - strap_offset;
tip_force  = working_load * abs(strap_offset) / strap_drop;

// Peak bending is where the ribbon is furthest from the load line, which is
// the spine and the 3 o'clock of the scroll, both at one scroll radius out.
proof_moment = proof_load * gravity * (spine_x - strap_offset);
proof_stress = 6 * proof_moment
               / (hook_width * ribbon_thickness * ribbon_thickness);

env_x = max(spine_x, curl_c[0] + curl_r) + bar_r - (arm_tip[0] - bar_r);
env_z = total_height;

assert(strap_offset < grip_out,
       str("strap_offset (", strap_offset,
           " mm) must be inboard of the outboard bumper edge at ", grip_out,
           " mm, or the load line falls outside the contact patch and the ",
           "hook tips off the table."));

assert(strap_offset > grip_in,
       str("strap_offset (", strap_offset,
           " mm) is inboard of the last bumper at ", grip_in,
           " mm, so the arm would rock on its inboard edge. Pull the strap ",
           "outboard or lengthen the bumper grid."));

// The turn-down has to start past the table edge, so nothing but bumper
// ever comes near the tabletop.
assert(arm_end[0] > 0,
       str("The arm turns down at x = ", arm_end[0],
           " mm, which is still over the tabletop. Cut arm_fillet, or push ",
           "strap_offset outboard to move the spine out."));

assert(spine_x - bar_r > 0,
       "The spine would foul the table edge — push strap_offset outboard.");

assert(handle_clear > 20,
       str("Only ", handle_clear, " mm of clear passage between the table's ",
           "underside and the inside of the loop — too tight to thread a bag ",
           "handle through. Raise curl_outer_dia or curl_clearance."));

assert(arm_fillet > bar_r,
       str("arm_fillet (", arm_fillet,
           " mm) is a centreline radius and must exceed half the ribbon ",
           "thickness (", bar_r, " mm), or the inside of the turn cusps."));

assert(curl_sweep > 180 && curl_sweep <= 330,
       "curl_sweep below 180 degrees will not retain a strap; above 330 it closes on itself.");

assert(curl_mouth > 12,
       str("Scroll mouth is only ", curl_mouth,
           " mm — too tight to feed a bag strap. Cut curl_sweep or raise ",
           "curl_outer_dia."));

assert(pocket_half_span <= flat_half_y,
       str("The bumper pair spans ", 2 * pocket_half_span,
           " mm across but the flat band between the rims is only ",
           2 * flat_half_y, " mm. Widen hook_width to at least ",
           2 * (pocket_half_span + rim_radius),
           " mm, cut rim_radius, or close grip_bumper_gap."));

// The inboard pocket is allowed to run a little past the end of the arm's
// flat into its rounded cap: the bumper itself stops at the flat, and the
// pocket's extra clearance overhangs a part of the cap that has dropped
// only microns. It may not run off the ribbon altogether.
assert(pad_pocket_in >= -arm_reach - bar_r && pad_pocket_out <= arm_end[0],
       str("The bumpers span x = ", pad_pocket_in, " to ", pad_pocket_out,
           " mm but the arm only runs ", -arm_reach, " to ", arm_end[0],
           " mm. Raise arm_reach."));

assert(pad_pocket_x[0] - pad_pocket_x[1] >= pocket_dia + grip_bumper_gap,
       str("The two bumper pairs are only ",
           pad_pocket_x[0] - pad_pocket_x[1],
           " mm apart and would run into each other. Raise arm_reach."));

assert(grip_pad_recess < grip_bumper_thickness,
       "grip_pad_recess must be below grip_bumper_thickness — the bumper has to stand proud.");

assert(grip_pad_recess < bar_r,
       "grip_pad_recess must be less than half the ribbon thickness.");

assert(rim_radius < hook_width / 2 && rim_radius < bar_r,
       "rim_radius must be smaller than both half the width and half the thickness.");

assert(env_x <= 270 && env_z <= 270,
       str("Footprint ", env_x, " x ", env_z,
           " mm exceeds the 270 x 270 mm bed."));

echo(str("Overall: ", env_x, " x ", total_height, " x ", hook_width,
         " mm, scroll ", curl_outer_dia, " mm outside diameter."));

echo(str("Scroll crown sits ", -curl_top_z, " mm below the tabletop, so it ",
         "hangs clear of any top up to ", table_thickness_max, " mm."));

echo(str("Strap rests at x = ", strap_offset, " mm, ", strap_drop,
         " mm below the tabletop.  Scroll mouth ", curl_mouth, " mm."));

echo(str("Loading: thread the strap in SIDEWAYS, or hang the bag before ",
         "setting the hook down — the arm roofs the mouth, so it cannot be ",
         "dropped in from above. Handles up to ", handle_clear,
         " mm thick pass, whatever the table thickness."));

echo(str("Stability: load line sits ", tip_margin,
         " mm inboard of the tipping edge (bumpers span ", grip_in, " to ",
         grip_out, " mm). Cannot tip under weight alone."));

echo(str("  A sideways push of ", tip_force, " kg at the bag will tip it, ",
         "on a ", working_load, " kg load. Move strap_offset inboard to ",
         "raise that, at the cost of the bag hanging further under the top."));

echo(str("Proof stress at ", proof_load, " kg: ", proof_stress,
         " MPa (PLA yields near 50 MPa)."));

// ============================================================
// HELPERS
// ============================================================

// One ribbon cross-section: a disc of radius rad and thickness w whose two
// rims are rounded off by fr. Built as the hull of coaxial cylinders
// stepping round a quarter circle, trading radius for height. Revolving a
// rounded rectangle would be the obvious way, but that profile has to touch
// the rotation axis to keep the disc solid, and rotate_extrude turns an
// on-axis edge into zero-area facets — enough to leave the part
// non-manifold. Cylinders are closed solids, and a hull of convex coaxial
// bodies stays exact and cheap.
module ribbon_puck(rad, w, fr) {
    steps = max(4, ceil(fr * 90 / ($fs * 57.3)));

    hull() for (i = [0 : steps]) {
        a = 90 * i / steps;
        cylinder(r = rad - fr + fr * cos(a),
                 h = w - 2 * fr + 2 * fr * sin(a), center = true);
    }
}

// A straight run of ribbon between two centreline points. Hulling two pucks
// keeps the rounded rims all the way along, and hull() on convex solids
// stays cheap even with a long chain of them.
module ribbon_seg(p0, p1) {
    hull() for (p = [p0, p1])
        translate([p[0], 0, p[1]]) rotate([90, 0, 0])
            ribbon_puck(bar_r, hook_width, rim_radius);
}

module ribbon_chain(points) {
    for (i = [0 : len(points) - 2])
        ribbon_seg(points[i], points[i + 1]);
}

// ============================================================
// GEOMETRY
// ============================================================

// The arm rolls into the spine through a quarter fillet rather than a
// corner: the turn carries the whole bag load, so a sharp inside corner
// there would be both a stress raiser and unpleasant to hold.
function fillet_points() = arc_points(fillet_c, arm_fillet, 90, 0, 12);

module scroll_body() {
    // Arm, flat on the table, from its tip out to the start of the fillet.
    ribbon_seg(arm_tip, arm_end);

    // Fillet rolling the arm down past the table edge.
    ribbon_chain(fillet_points());

    // Spine dropping to the crown of the scroll, tangent to it.
    ribbon_seg(spine_top, curl_start);

    // The scroll itself.
    ribbon_chain(curl_points());
}

// A 2 x 2 grid of bumper features under the arm. In the print orientation
// the pocket axis lies horizontal, so each pocket is a shallow blind hole
// in a vertical wall and its ceiling overhangs. At grip_pad_recess deep
// that is a short self-supporting lip, not a bridge worth supporting — but
// it is why the recess wants to stay shallow.
module bumper_grid(pocket) {
    r  = (pocket ? pocket_dia : grip_bumper_dia) / 2;
    lo = pocket ? arm_z - bar_r - grip_overcut : arm_z - bar_r - land_h;
    h  = pocket ? grip_pad_recess + grip_overcut : land_h + grip_pad_recess;

    for (cx = pad_pocket_x, sy = [-1, 1])
        translate([cx, sy * pocket_y, lo]) cylinder(h = h, r = r);
}

module handbag_scroll_hook() {
    difference() {
        union() {
            scroll_body();

            // Solid stand-ins for the bumpers, for a hook used bare.
            if (grip_style != "pads")
                bumper_grid(false);
        }

        if (grip_style == "pads")
            bumper_grid(true);
    }
}

module table_preview(t) {
    color("Gainsboro", 0.45)
        translate([-150, -hook_width, -t])
            cube([150, 2 * hook_width, t]);
}

// ============================================================
// RENDER
// ============================================================

if (part == "print") {

    // Print orientation — profile flat on the bed, extruded along the
    // width. No overhangs, no supports; a brim is not needed.
    // rotate([90,0,0]) maps the model's +Y onto +Z, so the part is shifted
    // in Y first to land it on the bed rather than straddling it.
    rotate([90, 0, 0])
        translate([0, hook_width / 2, 0])
            handbag_scroll_hook();

} else if (part == "both") {

    table_preview(preview_table_thickness);

    color("Firebrick")
        handbag_scroll_hook();

} else {

    assert(false, str("Unknown part: \"", part, "\" — expected \"print\" or \"both\"."));

}
