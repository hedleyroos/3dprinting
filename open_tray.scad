// ============================================================
// Open Tray — 4-walled box, open top, with bottom slit
//
// A simple open-top tray with four closed walls and a floor.
// A rectangular slit passes through the bottom for cable /
// strap routing. Only the outside of the floor is rounded.
//
// Coordinate system:
//   X = width  (short side, 25 mm inner)
//   Y = length (long side,  60 mm inner)
//   Z = height (up from the bed, 6 mm inner)
//
// All units: millimeters.
// ============================================================

/* [Box Dimensions] */
inner_w  = 25;   // Inner width  (X)
inner_l  = 60;   // Inner length (Y)
inner_h  = 6;    // Inner height (Z)

/* [Wall & Floor] */
wall_t   = 4;    // Wall thickness
floor_t  = 2;    // Floor thickness

/* [Floor Round] */
floor_round_r = 1.5;  // Outside roundover radius on the floor perimeter

/* [Bottom Slit] */
slit_w   = 20;   // Slit width  along X (parallel to the 25 mm side)
slit_d   = 5;    // Slit depth  along Y
slit_x   = 0;    // Slit centre X offset from box centre
slit_y   = 26;   // Slit centre Y offset from box centre

/* [Quality] */
$fa      = 1;
$fs      = 0.4;

// ============================================================
// DERIVED
// ============================================================

outer_w = inner_w + 2 * wall_t;
outer_l = inner_l + 2 * wall_t;
outer_h = inner_h + floor_t;

// ============================================================
// GEOMETRY
// ============================================================

module floor_block() {
    // Rounded only on the OUTSIDE of the floor. The top face stays flat
    // so the walls can sit on it cleanly.
    r = min(floor_round_r,
            floor_t - 0.01,
            outer_w / 2 - 0.01,
            outer_l / 2 - 0.01);

    if (r <= 0)
        cube([outer_w, outer_l, floor_t]);
    else
        intersection() {
            minkowski() {
                translate([r, r, r])
                    cube([outer_w - 2 * r,
                          outer_l - 2 * r,
                          floor_t - r]);
                sphere(r = r);
            }

            // Trim the top back to a flat floor surface.
            cube([outer_w, outer_l, floor_t]);
        }
}

module rounded_rect_2d(w, h, r) {
    corner_r = min(r, w / 2 - 0.01, h / 2 - 0.01);
    hull() {
        translate([ corner_r,         corner_r        ]) circle(r = corner_r);
        translate([ w - corner_r,     corner_r        ]) circle(r = corner_r);
        translate([ corner_r,         h - corner_r    ]) circle(r = corner_r);
        translate([ w - corner_r,     h - corner_r    ]) circle(r = corner_r);
    }
}

module wall_ring() {
    outer_corner_r = min(floor_round_r,
                         outer_w / 2 - 0.01,
                         outer_l / 2 - 0.01);

    translate([0, 0, floor_t])
        difference() {
            linear_extrude(height = inner_h)
                rounded_rect_2d(outer_w, outer_l, outer_corner_r);
            translate([wall_t, wall_t, -0.01])
                cube([inner_w, inner_l, inner_h + 0.02]);
        }
}

module open_tray() {
    cx = outer_w / 2;
    cy = outer_l / 2;

    difference() {
        union() {
            floor_block();
            wall_ring();
        }

        // ----- Bottom slit -----
        translate([cx + slit_x, cy + slit_y, floor_t / 2])
            cube([slit_w, slit_d, floor_t + 2], center = true);
    }
}

// ============================================================
// RENDER
// ============================================================

open_tray();
