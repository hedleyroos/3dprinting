// ============================================================
// Wine Bottle Cradle — Wave Cushion, Interlocking
//
// A smooth wave-shaped cushion that holds 3 wine bottles lying on
// their sides in rounded troughs.  Identical copies interlock
// end-to-end (across the bottle row) via a tab on the +X end and a
// matching slot on the -X end, so you can chain as many as you like
// for an "infinite" tray.  No stacking.
//
// The wave has rounded troughs AND rounded crests (a 2D opening
// fillet on the cross-section), then that profile is extruded along
// the bottle axis into half-pipe cradles.
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
cradle_len      = 180;   // Trough length along Y (bottle ends overhang)
base_wall       = 8;     // Solid material under the deepest trough point
crest_fillet    = 3;     // Rounding radius of the wave crests

/* [Interlock — Tab & Slot on the X ends] */
tab_proj        = 8;     // How far the tab sticks out (along X); body_w + tab_proj <= 270
tab_w           = 40;    // Width of the tab (along Y)
tab_h           = 12;    // Height of the tab (Z), bottom-anchored so it prints on the bed
tab_clearance   = 0.3;   // Extra room in the slot for an easy fit

/* [View] */
part = "cushion";        // "cushion" or "pair" (two chained copies for a fit preview)

/* [Quality] */
$fn = 64;
$fa = 2;
$fs = 0.5;

eps = 0.02;

// ============================================================
// DERIVED
// ============================================================

cradle_r  = bottle_dia / 2 + cradle_extra_r;   // 46.5
body_w    = bottle_count * bottle_pitch;        // 258  -> outer troughs sit half a pitch from each end
half_w    = body_w / 2;
top_z     = base_wall + trough_depth;           // 26   top face / crest height
z_c       = base_wall + cradle_r;               // 54.5 trough-cylinder centre height

// Slot = tab + clearance (loose on all cut faces).
slot_proj = tab_proj + tab_clearance;           // depth cut into the -X face
slot_w    = tab_w + 2 * tab_clearance;          // along Y
slot_h    = tab_h + tab_clearance;              // along Z

// ============================================================
// GEOMETRY
// ============================================================

// Wave cross-section in the X-Z plane, drawn as a 2D shape with
// 2D-x = across the bottles and 2D-y = height.  A filled slab minus
// one circle per trough, then a morphological OPENING rounds the
// convex crests (and outer base corners) while leaving the concave
// troughs untouched.
module wave_section_2d() {
    offset(r =  crest_fillet)
    offset(r = -crest_fillet)
        difference() {
            translate([-half_w, 0]) square([body_w, top_z]);
            for (i = [-(bottle_count - 1) / 2 : (bottle_count - 1) / 2])
                translate([i * bottle_pitch, z_c]) circle(r = cradle_r);
        }
}

// Extrude the wave profile along Y into half-pipe cradles.
// rotate([90,0,0]) maps the extrude axis (Z) onto -Y and the
// profile height (2D-y) onto +Z, giving a flat base at z = 0.
module wave_body() {
    rotate([90, 0, 0])
        linear_extrude(height = cradle_len, center = true)
            wave_section_2d();
}

// Protruding tab on the +X end, anchored on the bed (z = 0 .. tab_h).
module tab() {
    translate([half_w + tab_proj / 2, 0, tab_h / 2])
        cube([tab_proj, tab_w, tab_h], center = true);
}

// Matching slot cut into the -X end.  Opens at the face and reaches
// slightly past the tab tip so it never bottoms out.
module slot() {
    translate([-half_w + slot_proj / 2 - eps / 2, 0, slot_h / 2 - eps / 2])
        cube([slot_proj + eps, slot_w, slot_h + eps], center = true);
}

// ============================================================
// ASSEMBLY
// ============================================================

module wine_bottle_cushion() {
    difference() {
        union() {
            wave_body();
            tab();
        }
        slot();
    }
}

// ============================================================
// PART SELECTOR
// ============================================================

if (part == "cushion") {
    wine_bottle_cushion();
} else if (part == "pair") {
    // Two modules chained along X (tab of the first seated in the
    // slot of the second) to preview the seam and interlock fit.
    wine_bottle_cushion();
    translate([body_w + tab_proj, 0, 0]) wine_bottle_cushion();
}
