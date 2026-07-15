// ============================================================
// Blind Cord Cleat
// Small wall-mounted child-safety cleat. Wind the excess
// window-blind pull cord around the cleat in a figure-8 to keep
// it up out of a child's reach.
//
// Classic anchor / boat-cleat shape: a flat back plate, a short
// central neck that stands a vertical cross-bar off the wall,
// and two horns (the top and bottom ends of the cross-bar). The
// cord loops around the horns and passes behind the bar through
// the open gaps either side of the neck. Adhesive mounting
// (VHB tape / double-sided pads) — no screw holes.
//
// Coordinate system (installed):
//   X = width      (left/right along the wall)
//   Y = protrusion (out from the wall; Y = 0 is the wall)
//   Z = height     (up/down in installed orientation)
//
// The cleat is a 2-D side silhouette (YZ) swept along X, so it
// prints flat on its side as a single prism — no supports.
//
// All units: millimeters.
// ============================================================

/* [Cleat] */
cleat_width         = 14;   // Overall width (X, along the wall)
back_height         = 74;   // Overall height (Z) = cross-bar span
plate_thickness     = 4;    // Back-plate protrusion (Y, from wall)
neck_gap            = 14;    // Open depth behind the bar (Y) — cord passes here
bar_thickness       = 6;    // Cross-bar depth (Y)
neck_height         = 26;   // Central neck / standoff height (Z)
plate_corner_radius = 4;    // Corner rounding on the back plate
fillet_radius       = 3;    // Fillet at the neck junctions
edge_round          = 0.6;  // Slight rounding on all exposed edges (finger comfort)

/* [View] */
export_mode         = "print"; // assembly | print
show_wall_preview   = true;       // translucent wall slab in assembly view

/* [Quality] */
$fa = 1;   // Minimum facet angle
$fs = 0.4; // Minimum facet edge length (mm), matched to a 0.4 mm nozzle

// ============================================================
// DERIVED
// ============================================================

bar_radius    = bar_thickness / 2;
bar_back      = plate_thickness + neck_gap;  // Y where the bar begins
bar_center_y  = bar_back + bar_radius;        // Y of the bar centre-line
horn_half     = back_height / 2;              // half the cross-bar span (Z)

// ============================================================
// HELPERS  (repo standard library)
// ============================================================

module rounded_rect_2d(w, h, r) {
    corner_r = min(r, w / 2 - 0.01, h / 2 - 0.01);
    hull() {
        translate([ w / 2 - corner_r,  h / 2 - corner_r]) circle(r = corner_r);
        translate([-w / 2 + corner_r,  h / 2 - corner_r]) circle(r = corner_r);
        translate([ w / 2 - corner_r, -h / 2 + corner_r]) circle(r = corner_r);
        translate([-w / 2 + corner_r, -h / 2 + corner_r]) circle(r = corner_r);
    }
}

// Capsule between two points.
module circle_segment_2d(p0, p1, r) {
    hull() {
        translate(p0) circle(r = r);
        translate(p1) circle(r = r);
    }
}

// Rectangle with the two FRONT corners (+x side) rounded and a
// square, flat back edge (-x side) that sits flush against the
// wall. Centred on the origin.
module rounded_front_rect_2d(w, h, r) {
    rr = min(r, w / 2 - 0.01, h / 2 - 0.01);
    hull() {
        translate([ w / 2 - rr,  h / 2 - rr]) circle(r = rr);   // front-top
        translate([ w / 2 - rr, -h / 2 + rr]) circle(r = rr);   // front-bottom
        translate([-w / 2, -h / 2]) square([0.01, h]);          // flat wall edge
    }
}

// ============================================================
// GEOMETRY  (2-D silhouette in the YZ plane)
// ============================================================

// Back plate, wall-contact face at Y = 0. The wall side is left
// fully square (flat mounting reference, square at top and bottom);
// only the outward-facing front corners are eased.
module back_plate_2d() {
    translate([plate_thickness / 2, 0])
        rounded_front_rect_2d(plate_thickness, back_height, plate_corner_radius);
}

// Central neck: joins the plate front to the bar centre-line.
module neck_2d() {
    len = bar_center_y - plate_thickness / 2;   // embed into plate & bar
    translate([plate_thickness / 2 + len / 2, 0])
        square([len, neck_height], center = true);
}

// Vertical cross-bar — a rounded capsule; its two ends are the horns.
module bar_2d() {
    circle_segment_2d([bar_center_y, -(horn_half - bar_radius)],
                      [bar_center_y,  (horn_half - bar_radius)], bar_radius);
}

// Full cleat silhouette. A morphological close (dilate then erode)
// rounds the concave neck junctions into fillets; clipped to Y >= 0
// so nothing ever bulges through the flat wall-contact face.
module cleat_profile_2d() {
    intersection() {
        offset(r = -fillet_radius) offset(r = fillet_radius)
            union() {
                back_plate_2d();
                neck_2d();
                bar_2d();
            }
        translate([500, 0]) square([1000, 2000], center = true);
    }
}

// 3-D cleat: sweep the silhouette along X, then break every exposed
// edge with a small sphere (Minkowski) so nothing is sharp to the
// touch. The profile is shrunk by edge_round first so overall
// dimensions and the cord gaps are preserved. The rounding would
// otherwise ease the wall-contact perimeter too, so we slice the
// wall fillet off at the edge_round plane — leaving a perfectly flat
// mounting face with crisp edges — and shift it back to X = 0.
module blind_cord_cleat() {
    rotate([90, 0, 90])
        translate([-edge_round, 0, 0])
            intersection() {
                minkowski() {
                    linear_extrude(height = cleat_width - 2 * edge_round,
                                   center = true, convexity = 10)
                        offset(r = -edge_round) cleat_profile_2d();
                    sphere(r = edge_round);
                }
                // Cut away the rounded wall fillet (X < edge_round).
                translate([1000 + edge_round, 0, 0]) cube(2000, center = true);
            }
}

// ============================================================
// VIEWS
// ============================================================

// As-installed: back plate flat on the wall (Y = 0), bar out front.
module assembly_view() {
    color([0.93, 0.42, 0.18])
        blind_cord_cleat();

    if (show_wall_preview)
        color([0.72, 0.72, 0.72, 0.30])
            translate([0, -1, 0])
                cube([cleat_width * 2.4, 2, back_height * 1.3], center = true);
}

// Lay the cleat flat on one broad side face for support-free
// printing (the whole part is a prism, contact face on the bed).
module print_view() {
    color([0.93, 0.42, 0.18])
        translate([0, 0, cleat_width / 2])
            rotate([0, -90, 0])
                blind_cord_cleat();
}

// ============================================================
// EXPORT
// ============================================================

if (export_mode == "print")
    print_view();
else
    assembly_view();
