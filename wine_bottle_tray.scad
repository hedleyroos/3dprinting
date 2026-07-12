// ============================================================
// Wine Bottle Cradle — Wave Cushion, Lightweight Frame
//
// A smooth wave-shaped cushion that holds 3 wine bottles lying on
// their sides in rounded troughs.  Two parallel rails (front =
// +Y, back = -Y) support the bottles — the centre is open to save
// filament.  Each rail's width is independently controlled
// (rail_front_w, rail_back_w).  Thin end bars at the +X and -X
// ends connect the rails into a rigid rectangular frame.
//
// The wave has rounded troughs AND rounded crests (a 2D opening
// fillet on the cross-section), then that profile is extruded
// along the bottle axis into half-pipe cradles.  External edges
// that may touch hands are slightly rounded.
//
// Print flat on the bed.  Designed for a Qidi Q2
// (270 x 270 mm bed, 256 mm Z).  3 x 90 mm bottles fill the bed
// width, so the bottles sit shoulder-to-shoulder by construction.
//
// Coordinate system:
//   X = across the bottles (3 troughs side by side, the chain axis)
//   Y = along  the bottles (parallel to the bottle axis)
//   Z = up from the bed
//   Origin at the centre of the bottom face.
//
// All units: millimetres.
// ============================================================

/* [Bottles] */
bottle_dia      = 90;    // Nominal bottle diameter (large: Champagne / Burgundy)
bottle_count    = 3;     // Troughs per cushion
bottle_pitch    = 86;    // Centre-to-centre spacing across X (body_w = count * pitch)
cradle_extra_r  = 1.5;   // Radial clearance inside each trough
trough_depth    = 18;    // How deep the bottle sinks into the wave

/* [Cushion] */
cradle_len      = 160;   // Trough length along Y (bottle ends overhang)
base_wall       = 6;     // Solid material under the deepest trough point
crest_fillet    = 3;     // Rounding radius of the wave crests
rail_front_w    = 15;    // Width of the front (+Y) support rail along Y
rail_back_w     = 25;    // Width of the back  (-Y) support rail along Y
hand_round_r    = 2;     // Slight rounding on hand-touch external edges
end_bar_t       = 6;     // Thickness (Z) of the end bars; interlock height tracks this
bar_rail_bite   = 5;     // How far the end bar reaches into each rail (fused overlap)

/* [Back Lip — Bottle Retainer] */
back_lip_h      = -5;    // Height of the retaining lip above the rail crest (top_z)
back_lip_t      = 4;     // Thickness of the retaining lip (Y direction)

/* [Interlock — Puzzle Tabs on the End Bars] */
tab_proj        = 8;     // How far the tab sticks out in X
tab_root_w      = 12;    // Tab width at root in Y (narrow — at the bar face)
tab_tip_w       = 20;    // Tab width at tip in Y (wide — arrowhead locks in slot)
tab_spacing     = 60;    // Centre-to-centre Y spacing of the two tabs
tab_clearance   = 0.3;   // Extra gap in the slot

/* [View] */
part = "cushion";        // "cushion" or "pair" (two copies side by side for a fit preview)

/* [Quality] */
$fn = 64;
$fa = 2;
$fs = 0.5;

eps = 0.02;

// ============================================================
// DERIVED
// ============================================================

cradle_r  = bottle_dia / 2 + cradle_extra_r;   // 46.5
body_w    = bottle_count * bottle_pitch;        // 258
half_w    = body_w / 2;                         // 129
top_z     = base_wall + trough_depth;           // 26
z_c       = base_wall + cradle_r;               // 54.5
half_rail_front = rail_front_w / 2;                // 7.5
half_rail_back  = rail_back_w  / 2;                // 7.5

// Slot = tab + clearance on all faces.
slot_proj   = tab_proj + tab_clearance;
slot_root_w = tab_root_w + 2 * tab_clearance;
slot_tip_w  = tab_tip_w  + 2 * tab_clearance;

// ============================================================
// GEOMETRY
// ============================================================

// Wave cross-section in the X-Z plane, drawn as a 2D shape with
// 2D-x = across the bottles and 2D-y = height.  A filled slab minus
// one circle per trough, then a morphological OPENING rounds the
// convex crests while leaving the concave troughs untouched.
// Bottom corners are kept sharp (90°) by filling the rounded-away
// material with small squares at each bottom corner.
//
// carve_troughs = false skips the bottle cutouts entirely, returning a
// plain solid rectangle instead.  Needed for the back lip: at
// back_lip_h above the crest we are already close to the bottle's
// equator (z_c), where the trough circle is still nearly full width,
// so extending the WAVE shape that high would carve away almost all of
// it — a plain rectangle avoids that failure mode.
module wave_section_2d(h = top_z, carve_troughs = true) {
    if (carve_troughs)
        union() {
            offset(r =  crest_fillet)
            offset(r = -crest_fillet)
                difference() {
                    translate([-half_w, 0]) square([body_w, h]);
                    for (i = [-(bottle_count - 1) / 2 : (bottle_count - 1) / 2])
                        translate([i * bottle_pitch, z_c]) circle(r = cradle_r);
                }
            // Restore sharp 90° bottom corners — the double offset above
            // rounds these inward; a crest_fillet×crest_fillet square at
            // each corner fills the rounded-away material back in.
            translate([-half_w, 0])               square([crest_fillet, crest_fillet]);
            translate([ half_w - crest_fillet, 0]) square([crest_fillet, crest_fillet]);
        }
    else
        translate([-half_w, 0]) square([body_w, h]);
}

// Two thin rails (front + back edges) instead of a full slab.  Each
// rail is a short extrusion of the wave profile, with all outer edges
// rounded for hand comfort.
//   rotate([90,0,0]) maps the extrude axis (Z) onto -Y and the
//   profile height (2D-y) onto +Z, giving a flat base at z = 0.
module wave_body() {
    // Back rail  (-Y)
    translate([0, -(cradle_len / 2 - half_rail_back), 0])
        rounded_rail(rail_back_w);
    // Front rail (+Y)
    translate([0, +(cradle_len / 2 - half_rail_front), 0])
        rounded_rail(rail_front_w);
    // Retaining lip along the back rail's outer edge — stands back_lip_h
    // taller than the crest to stop a bottle sliding/rolling out the back;
    // thin (back_lip_t) so it reads as a low wall, not a third rail.  Flush
    // with the tray's back-most Y edge; fully overlaps the back rail's own
    // footprint, so the union just fuses the two together.  A plain wall
    // (carve_troughs = false) — at this height the bottle-trough cutout
    // would otherwise carve away nearly all of it (see wave_section_2d()).
    translate([0, -(cradle_len / 2 - back_lip_t / 2), 0])
        rounded_rail(back_lip_t, top_z + back_lip_h, carve_troughs = false);
}

// Single rail: wave profile extruded w along Y.  Top, side, and
// vertical-corner edges are rounded by hand_round_r via minkowski for
// hand comfort.  The bottom edge stays sharp (90°) by cutting the
// minkowski shape flat at z = 0 and then unioning a thin sharp-bottom
// filler that restores the correct wall position right at the bed.
//
// The 2D profile is inset by -hand_round_r before the minkowski so
// the final outer envelope matches the original dimensions exactly.
module rounded_rail(w, h = top_z, carve_troughs = true) {

    // Clamped core width (pre-minkowski inset).  w - 2*hand_round_r would be
    // exactly zero for a piece as thin as the back lip (t = 2*hand_round_r),
    // which breaks linear_extrude/offset (zero-size geometry).  Flooring at a
    // tiny epsilon keeps normal rails (w = 15, 35) unaffected while letting
    // thin pieces degenerate gracefully into an almost fully-rounded capsule.
    core_w = max(w - 2 * hand_round_r, 2 * eps);

    // Full-height minkowski-rounded shape — all edges filleted.
    module rail_rounded_shape() {
        minkowski() {
            rotate([90, 0, 0])
                linear_extrude(height = core_w, center = true)
                    offset(r = -hand_round_r)
                        wave_section_2d(h, carve_troughs);
            sphere(r = hand_round_r, $fn = 24);
        }
    }

    // Sharp-bottom filler: restores full wall position and a sharp 90°
    // bottom edge for the band z in [0, hand_round_r], but with the SAME
    // rounded vertical corners as the minkowski shape so the corner
    // rounding is continuous down to the bed.  The rail footprint here is
    // a plain body_w x w slab (the trough scallops start higher, at
    // z = base_wall), so it is just a rounded rectangle.
    module rail_sharp_bottom_shape() {
        linear_extrude(height = hand_round_r)
            offset(r = hand_round_r)
                square([body_w - 2 * hand_round_r,
                        core_w], center = true);
    }

    // Footprint of the minkowski shape (for the bottom-cutting cube).
    x_m = -half_w - hand_round_r;
    y_m = -cradle_len / 2 - hand_round_r;

    union() {
        // Rounded rail with the bottom fillet sliced off at z = 0.
        // Vertical corners stay rounded all the way down; only the
        // horizontal bottom edge is sharpened.
        difference() {
            rail_rounded_shape();
            translate([x_m, y_m, -hand_round_r])
                cube([body_w + 2 * hand_round_r,
                      cradle_len + 2 * hand_round_r,
                      hand_round_r + eps]);
        }
        // Sharp filler restores full wall position at the bed.
        rail_sharp_bottom_shape();
    }
}


// ============================================================
// END BARS
// ============================================================

// Flat bar (like a ruler) at each X end of the tray, laid flat on the
// bed.  end_bar_t thick in Z, width in X matches the wave height.  Each
// end reaches bar_rail_bite past the rail's inner face — a genuine
// fused overlap instead of a coincident, zero-overlap touch.  All edges
// are sharp 90°.
module end_bar(x_sign) {
    bar_t  = end_bar_t;   // thickness in Z (flat on the bed)
    bar_w  = top_z;       // width in X (matches the wave profile height)
    bar_ys = cradle_len - (rail_front_w + rail_back_w - 2 * bar_rail_bite);
    bar_y0 = (rail_back_w - rail_front_w) / 2;

    // +X bar spans [half_w - bar_w, half_w];  -X bar spans [-half_w, -(half_w - bar_w)]
    bar_x0 = x_sign > 0 ? half_w - bar_w : -half_w;

    translate([bar_x0, bar_y0 - bar_ys / 2, 0])
        cube([bar_w, bar_ys, bar_t]);
}

// Two trapezoidal puzzle tabs on the +X end bar, flat in the X-Y
// plane (end_bar_t tall in Z).  Protrude from the +X face; narrow at
// the root, wider at the tip — an arrowhead / dovetail so adjacent
// trays cannot be pulled straight apart along X.
module interlock_tab() {
    bar_t = end_bar_t;
    translate([half_w, 0, 0])
        for (y_sign = [-1, 1])
            translate([0, y_sign * tab_spacing / 2, 0])
                linear_extrude(height = bar_t)
                    polygon([
                        [0,          -tab_root_w / 2],
                        [tab_proj,   -tab_tip_w  / 2],
                        [tab_proj,    tab_tip_w  / 2],
                        [0,           tab_root_w / 2],
                    ]);
}

// Matching trapezoidal slots cut into the -X end bar.  Wider at
// the face opening, narrower at depth — a negative of interlock_tab()
// with clearance on all faces.
module interlock_slot() {
    bar_t = end_bar_t;
    translate([-half_w, 0, -eps])
        for (y_sign = [-1, 1])
            translate([0, y_sign * tab_spacing / 2, 0])
                linear_extrude(height = bar_t + 2 * eps)
                    polygon([
                        [0,           -slot_root_w / 2],
                        [slot_proj,   -slot_tip_w  / 2],
                        [slot_proj,    slot_tip_w  / 2],
                        [0,            slot_root_w / 2],
                    ]);
}

// ============================================================
// ASSEMBLY
// ============================================================

module wine_bottle_cushion() {
    difference() {
        union() {
            wave_body();
            end_bar(-1);  // -X end
            end_bar(+1);  // +X end
            interlock_tab();
        }
        interlock_slot();
    }
}

// ============================================================
// PART SELECTOR
// ============================================================

if (part == "cushion") {
    wine_bottle_cushion();
} else if (part == "pair") {
    // Two copies side by side — the +X tabs of the first fit into
    // the -X slots of the second, showing the puzzle interlock.
    wine_bottle_cushion();
    translate([body_w, 0, 0]) wine_bottle_cushion();
}
