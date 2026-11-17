// ============================================================
// knuckleduster.scad
//
// An ORNAMENTAL knuckleduster whose striking face is a rubber
// stamp: each finger's knuckle pad carries one embossed Roman
// capital, mirrored, so the impression it would leave reads
//
//                         S P Q R
//
// Seen from the front (looking AT the striking face) the pads
// therefore read "ЯQꟼƧ" — mirrored letters in reverse order —
// exactly as a stamp should. Seen from behind, through the
// wearer's eyes, they read SPQR.
//
// Single colour: the letters are fused into the body.
//
// Units: millimetres.
//
// Coordinate system (= the world during a palm-down punch):
//   +Y  the punch direction. The striking face (letter pads) is
//       at +Y, the palm bar at -Y.
//   +Z  up = the BACK OF THE HAND. The fingers enter the rings
//       from +Z (knuckle side) and the letters stand upright
//       with their tops toward +Z.
//   +X  the wearer's right.
//   The duster lies flat in XY; Z = 0 is the print bed.
//
// HOW TO WEAR IT SO IT SPELLS SPQR
//   Hold it so the letters stand upright with their tops toward
//   the back of your hand, and the letter pads face forward.
//   Right hand: index finger in the S ring, pinky in the R ring.
//   Left hand:  pinky in the S ring, index in the R ring.
//   The letters are in the same place either way — `hand` only
//   reverses the ring sizes so each finger gets its own bore.
//
// FIT: each bore has to slide over the finger's MIDDLE joint
// (the widest part it must pass), so measure that joint on each
// finger and add ~1 mm. Defaults suit a medium adult hand.
//
// PRINTING: flat, Z = 0 down, no supports. The bores are
// vertical; the ring hoops and the palm bar lie in the layer
// planes, so they load along the extrusion lines. The letters
// stand off vertical walls, and only the undersides of
// horizontal strokes overhang, by `emboss` (1.2 mm).
//
// Part mapping:
//   part="print"   -> the duster flat on the bed, centred (export)
//   part="fit"     -> the duster plus ghost fingers through each
//                     ring, entering from the knuckle side
//   part="imprint" -> the impression the face leaves, as the
//                     WEARER sees it on the target: the actual
//                     model is cut just in front of the letter
//                     pads and projected along the punch. This
//                     is a real check of the geometry, not a
//                     redraw of the text — it must read SPQR.
// ============================================================

/* [Part] */
part = "print";  // print | fit | imprint

/* [Fit] */
hand      = "right";            // right | left
ring_id   = [23, 24, 23, 21];   // bores: index, middle, ring, pinky
ring_wall = 3.5;                // radial wall around each bore
web       = 3;                  // minimum wall between adjacent bores

/* [Body] */
thickness = 16;    // slab thickness (along the fingers)
edge_r    = 2;     // quarter-round on every edge, bores included
edge_step = 0.1;   // vertical step of the stacked rounding slices
boss_rise = 6.5;   // letter-pad face height above the largest bore
pad_w     = 20;    // width of each letter pad (before rounding)
pad_depth = 3;     // depth of the pad block under the face
boss_r    = 5;     // shoulder rounding of each boss (flat face ~ pad_w - 1.4x this)
bar_R     = 90;    // radius of the palm bar's convex underside
bar_thick = 10;    // palm bar thickness
bar_gap   = 7;     // window height under the rings, at the centre
strut_w   = 6;     // solid strut between the middle and ring bores
valley_r  = 1.5;   // fillet in the valleys between knuckle bosses (fills gaps < 2x)
corner_r  = 4;     // rounding of convex corners of the outline
window_r  = 2.5;   // rounding of the window cut-outs

/* [Letters] */
letters   = ["S", "P", "Q", "R"];  // left to right, wearer's view
font      = "P052:style=Bold";      // Palatino clone: Roman capitals
cap_h     = 9.5;                    // cap height (Q tail drops 0.27x below)
emboss    = 1.2;                    // how far the letters stand proud

/* [Quality] */
$fa = 1;    // max 360 facets per full circle
$fs = 0.4;  // minimum facet edge length, matched to a 0.4 mm nozzle

// ------------------------------------------------------------
// Derived values
// ------------------------------------------------------------

// Cap height ÷ font size for P052 Bold, measured from the "H"
// glyph's bounding box (9.46 mm at size 10). Baked in so no
// experimental textmetrics() is needed.
CAP_RATIO = 0.946;
font_size = cap_h / CAP_RATIO;

eps = 0.01;

// Bores in X order (-X to +X). Right hand: index at -X.
ids = hand == "left" ? [for (i = [3:-1:0]) ring_id[i]] : ring_id;
ros = [for (d = ids) d / 2 + ring_wall];

// Centre spacing keeps exactly `web` between neighbouring bores.
function cum(i) = i == 0 ? 0 : cum(i - 1) + ids[i - 1] / 2 + web + ids[i] / 2;
xs_raw = [for (i = [0:3]) cum(i)];
xs     = [for (x = xs_raw) x - (xs_raw[0] + xs_raw[3]) / 2];

y_face  = max(ids) / 2 + boss_rise;           // shared stamp plane
y_ring_bottom = -max(ros);
bar_R_in = bar_R - bar_thick;
bar_yc   = y_ring_bottom - bar_gap + bar_R_in; // palm-bar arc centre
bar_x    = max(abs(xs[0]), abs(xs[3]));        // bar ends under outer bores
bar_ang  = asin(bar_x / bar_R);
y_bottom = bar_yc - bar_R;

strut_x  = (xs[1] + xs[2]) / 2;

echo(str("knuckleduster: ring centres x = ", xs));
echo(str("knuckleduster: extents x ", xs[0] - ros[0], " .. ", xs[3] + ros[3],
         ", y ", y_bottom, " .. ", y_face + emboss, ", z 0 .. ", thickness));

// ------------------------------------------------------------
// 2D profile
// ------------------------------------------------------------

// Round convex corners (opening) / concave corners (closing).
module round_convex(r)  { offset(r = r)  offset(delta = -r) children(); }
module round_concave(r) { offset(r = -r) offset(delta = r)  children(); }

module ring_outers() {
    for (i = [0:3]) translate([xs[i], 0]) circle(r = ros[i]);
}

// Knuckle boss: the ring's outer disc hulled up to a flat pad
// whose face is the shared stamp plane y_face, shoulders rounded.
module boss(i) {
    round_convex(boss_r) hull() {
        translate([xs[i], 0]) circle(r = ros[i]);
        translate([xs[i] - pad_w / 2, y_face - pad_depth]) square([pad_w, pad_depth]);
    }
}

// Annular segment of the palm bar, convex side down.
module bar_arc() {
    n = 60;
    outer = [for (k = [0:n]) let(a = -bar_ang + 2 * bar_ang * k / n)
             [bar_R * sin(a), bar_yc - bar_R * cos(a)]];
    inner = [for (k = [n:-1:0]) let(a = -bar_ang + 2 * bar_ang * k / n)
             [bar_R_in * sin(a), bar_yc - bar_R_in * cos(a)]];
    polygon(concat(outer, inner));
}

// Lower body: lower half-discs of the rings hulled with the bar.
module lower_body() {
    hull() {
        for (i = [0:3])
            intersection() {
                translate([xs[i], 0]) circle(r = ros[i]);
                translate([xs[i] - ros[i], -ros[i]]) square([2 * ros[i], ros[i]]);
            }
        bar_arc();
    }
}

// The two arched windows between the rings and the palm bar.
module windows() {
    round_convex(window_r) round_concave(window_r)
    difference() {
        intersection() {
            translate([0, bar_yc]) circle(r = bar_R_in);
            offset(delta = -web) lower_body();
            translate([-200, -200]) square([400, 200]);   // y < 0
        }
        ring_outers();
        translate([strut_x - strut_w / 2, -200]) square([strut_w, 400]);
    }
}

module profile_2d() {
    difference() {
        round_convex(corner_r) round_concave(valley_r)
        union() {
            for (i = [0:3]) boss(i);
            lower_body();
        }
        windows();
        for (i = [0:3]) translate([xs[i], 0]) circle(d = ids[i]);
    }
}

// ------------------------------------------------------------
// 3D
// ------------------------------------------------------------

// Extrude the profile with a quarter-round on every edge, built
// from thin stacked slices (stepped like the printed layers).
// Avoids a non-convex minkowski entirely.
function edge_inset(z) = edge_r - sqrt(max(0, edge_r * edge_r - (edge_r - z) * (edge_r - z)));

module rounded_slab() {
    n = ceil(edge_r / edge_step);
    dz = edge_r / n;
    union() {
        for (k = [0:n - 1]) {
            zm = (k + 0.5) * dz;
            // bottom edge slice, and its mirror at the top
            for (z0 = [k * dz, thickness - (k + 1) * dz])
                translate([0, 0, z0]) linear_extrude(dz + eps)
                    offset(r = -edge_inset(zm)) profile_2d();
        }
        translate([0, 0, edge_r]) linear_extrude(thickness - 2 * edge_r)
            profile_2d();
    }
}

// One embossed letter. The 2D text is laid out NORMALLY in the
// XZ plane (text x -> +X, text y -> +Z) and extruded toward +Y,
// so it reads correctly from behind and mirrored from the front
// — a stamp. It roots edge_r deep so the tail of the Q can run
// out over the rounded bottom edge and still be anchored.
module letter(i) {
    y_back = y_face - edge_r - 0.2;
    L = y_face + emboss - y_back;
    intersection() {
        translate([xs[i], y_back, thickness / 2 - cap_h / 2])
            rotate([90, 0, 0]) translate([0, 0, -L]) linear_extrude(L)
                text(letters[i], size = font_size, font = font,
                     halign = "center", valign = "baseline");
        // keep within the pad and 0.4 mm clear of the bed / top face
        translate([xs[i] - pad_w / 2, y_back - 1, 0.4])
            cube([pad_w, L + 2, thickness - 0.8]);
    }
}

module knuckleduster() {
    union() {
        rounded_slab();
        for (i = [0:3]) letter(i);
    }
}

// Ghost fingers through each ring, entering from +Z (knuckles).
module ghost_fingers() {
    names = hand == "left" ? ["pinky", "ring", "middle", "index"]
                           : ["index", "middle", "ring", "pinky"];
    for (i = [0:3]) {
        %translate([xs[i], 0, -35]) cylinder(d = ids[i] - 1.5, h = thickness + 70);
        echo(str("knuckleduster: ", letters[i], " ring <- ", names[i], " finger"));
    }
}

// The impression: everything in front of the pad face, viewed
// from behind along +Y (X -> right, Z -> up).
module imprint() {
    projection()
        rotate([-90, 0, 0])
            intersection() {
                knuckleduster();
                translate([-200, y_face + 0.1, -50]) cube([400, 50, 200]);
            }
}

// ------------------------------------------------------------
// Render
// ------------------------------------------------------------
y_mid = (y_bottom + y_face + emboss) / 2;

if (part == "print") {
    translate([0, -y_mid, 0]) knuckleduster();
} else if (part == "fit") {
    knuckleduster();
    ghost_fingers();
} else if (part == "imprint") {
    imprint();
}
