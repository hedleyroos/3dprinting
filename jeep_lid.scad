// ============================================================
// Jeep Wrangler TJ (1997-2006) Center Console Lid
// Perfected OEM Replica based on photographic evidence
//
// Updates based on photos:
//   - Diamond pattern underneath (diagonal structural ribs)
//   - Lock cylinder recess (bowl) on the top front-right 
//   - Continuous padded top contour (no stepped armrest pad)
//   - Large rounded top edges
//   - Piano-hinge flat mounting area at the rear
//
// All units: millimeters.
// ============================================================

/* [Lid Body — Overall] */
lid_width        = 170;    // Adjusted proportions from photos 
lid_depth        = 290;
lid_thickness    = 5;
corner_radius    = 30;
top_edge_radius  = 12;     // The soft rollover curve on top

/* [Lock Cylinder & Recess (Front Right)] */
lock_hole_enabled = true;
lock_pos_x        = 40;    // Offset to the right
lock_pos_y        = 100;   // Offset to the front 
lock_bowl_dia     = 45;    // Diameter of the finger recess bowl
lock_bowl_depth   = 8;     // How deep the bowl goes into the lid
lock_hole_dia     = 18;    // The actual hole for the key cylinder lock
lock_boss_dia     = 28;    // The plastic housing underneath

/* [Underside Lip & Ribs] */
lip_height       = 18;
lip_wall         = 4;
rib_thickness    = 2;
rib_spacing      = 22;     // Spacing for the diamond pattern

/* [Hinge Mounts — rear underside] */
hinge_flat_depth = 40;     // Flat area at the back for the piano hinge

/* [Quality] */
$fa              = 1;
$fs              = 0.4;

// ============================================================
// HELPERS
// ============================================================
module rounded_rect_2d(w, d, r) {
    r_c = min(r, min(w/2, d/2));
    hull() {
        translate([ w/2 - r_c,  d/2 - r_c]) circle(r = r_c);
        translate([-w/2 + r_c,  d/2 - r_c]) circle(r = r_c);
        translate([ w/2 - r_c, -d/2 + r_c]) circle(r = r_c);
        translate([-w/2 + r_c, -d/2 + r_c]) circle(r = r_c);
    }
}

module rounded_block(w, d, h, r) {
    linear_extrude(height = h) rounded_rect_2d(w, d, r);
}

// Minkowski hull for nice smooth top edges
module smoothed_shell(w, d, h, r, edge_r) {
    steps = 15;
    hull() {
        // Base flat perimeter
        linear_extrude(height = 0.1)
            rounded_rect_2d(w, d, r);
        
        // Curved top
        for (i = [0 : steps]) {
            angle = i * (90 / steps);
            curr_r = edge_r * (1 - cos(angle));
            curr_h = h - edge_r + edge_r * sin(angle);
            
            translate([0, 0, curr_h])
            linear_extrude(height = 0.05)
                rounded_rect_2d(w - 2 * curr_r, d - 2 * curr_r, max(0.1, r - curr_r));
        }
    }
}

// ============================================================
// MAIN LID BODY
// ============================================================
module lid_shell() {
    smoothed_shell(lid_width, lid_depth, lid_thickness + top_edge_radius, corner_radius, top_edge_radius);
}

// ============================================================
// UNDERSIDE LIP & DIAMOND RIBS
// ============================================================
module underside_structure() {
    lip_z = -lip_height;
    
    // Calculate the inner usable area bounds
    inner_w = lid_width - 15;
    inner_d = lid_depth - 15;
    
    intersection() {
        // Diamond grid
        union() {
            // Main bounding lip
            difference() {
                translate([0, 0, lip_z/2])
                    cube([inner_w, inner_d, lip_height], center=true);
                translate([0, 0, lip_z/2])
                    cube([inner_w - 2*lip_wall, inner_d - 2*lip_wall, lip_height+0.1], center=true);
            }
            
            // Lock housing boss attached underneath
            translate([lock_pos_x, -lock_pos_y, lip_z])
                cylinder(h=lip_height, d=lock_boss_dia);

            // Diagonal ribs (Diamond pattern)
            translate([0, 0, lip_z/2])
            rotate([0, 0, 45]) {
                limit = max(inner_w, inner_d) * 1.5;
                for(i = [-limit : rib_spacing : limit]) {
                    translate([i, 0, 0])
                        cube([rib_thickness, limit*2, lip_height], center=true);
                    translate([0, i, 0])
                        cube([limit*2, rib_thickness, lip_height], center=true);
                }
            }
        }
        
        // Shape mask to make everything match the lid contour and clear the hinge area
        union() {
            difference() {
                translate([0, 0, lip_z/2])
                    rounded_block(inner_w, inner_d, lip_height+1, corner_radius - 7);
                
                // Cutout for the flat hinge pad area at the rear (piano hinge area)
                translate([0, lid_depth/2 - hinge_flat_depth/2, lip_z/2])
                    cube([lid_width, hinge_flat_depth, lip_height+2], center=true);
                    
                // Cutout to leave the lock region hollow
                translate([lock_pos_x, -lock_pos_y, lip_z/2])
                    cylinder(h=lip_height+2, d=lock_boss_dia - 2*lip_wall, center=true);
            }
        }
    }
}

// ============================================================
// LOCK RECESS & HOLE
// ============================================================
module lock_cutout() {
    if (lock_hole_enabled) {
        // Recessed bowl on top
        translate([lock_pos_x, -lock_pos_y, lid_thickness + top_edge_radius + 1])
        hull() {
            translate([0, 0, 0])
                cylinder(h=0.1, d=lock_bowl_dia + 10); // Flare out
            translate([0, 0, -lock_bowl_depth - 1])
                cylinder(h=0.1, d=lock_bowl_dia);
        }
        
        // Pass-through hole for cylinder
        translate([lock_pos_x, -lock_pos_y, -lip_height - 10])
            cylinder(h=lip_height + lid_thickness + top_edge_radius + 20, d=lock_hole_dia);
    }
}

// ============================================================
// FINAL ASSEMBLY
// ============================================================
translate([0, 0, lip_height]) // Move up so bottom is at Z=0
difference() {
    union() {
        translate([0,0,-0.05]) lid_shell();
        underside_structure();
    }
    lock_cutout();
}