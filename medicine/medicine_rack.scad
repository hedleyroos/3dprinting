// ============================================================
// medicine_rack.scad — medicine cupboard organiser:
// 6 pull-out category LANES (3 across x 2 tiers) in a fully
// printed rack. Standalone, no external dependencies.
//
// Design record: medicine/PLAN.md (decisions there are settled).
//
// WHAT IT IS
//   * 4 PARTITIONS (left outer, 2 inner, right outer) stand on the
//     shelf and run front to back. Each is a 4 mm diamond-lattice web
//     with ledges: the lower lanes ride on the FOOT ledges (z = foot_t),
//     the upper lanes on the TOP ledges (z = z_d, 45° gusset beneath).
//     The web carries on lip_h above the top ledge as a guide lip.
//   * 9 TIES (one per bay at the front and at each partition joint)
//     drop T-heads into T-slots cut down from the partition top. Tie
//     top = ledge top, so the upper lanes slide over the ties and
//     hold them down; tie bottom = ledge-band bottom, so the lower
//     tier loses no headroom.
//   * 3 BACK PANELS (diamond lattice, flat-printed) slide down into
//     grooves in a solid post at each partition's back end: racking
//     stiffness + back stop.
//   * 6 LANES: open-top trays, lattice side walls with a solid bottom
//     rail (rides the ledge, slides past the lip) and a solid top rail
//     with DIVIDER notches. Front wall: finger pull + LABEL pocket.
//
// COORDINATES (mm)
//   X across the width; x = 0 is the rack centre (centred in the
//     360 mm door opening).
//   Y depth; y = 0 is the FRONT face of the rack, +Y toward the
//     back wall.
//   Z up; z = 0 is the shelf surface.
//
// PRINTING — ABS, no supports, joints acetone-welded
//   Printer: Qidi Q2 (270 x 270 bed, 256 mm Z).
//   Partition segments print UPRIGHT, as installed (189.5 mm tall);
//   use a brim. Lane segments print floor-down. Ties print top-face
//   down. Back panels, dividers and labels print flat.
//
// JOINTS — every joint engages by VERTICAL DROP and every joint
// profile is an XY shape extruded in Z, so no joint adds an overhang
// in any print orientation.
//   Partition segments: the front segment carries a tongue through
//     the full height. In the 16 mm foot and top band it flares into
//     a dovetail, which locks X and holds tension along Y. In the 4 mm
//     web it is a butt (inner partitions) or a lap with a 1.35 mm
//     outer skin (outer partitions, which have no outward ledge to
//     hold a second jaw: the skin is that jaw). Nothing leaves the
//     partition's own section, so nothing bulges where lanes run.
//   Lane segments: floor jigsaw (dovetail tabs) + wall dovetails in
//     posts that bulge INWARD only; outer faces and underside flush.
//   Assembly order: partitions front-to-back (drop each segment onto
//     the one in front), back panels down into the post grooves, ties
//     down into the T-slots, then lanes. Weld as you go.
// ============================================================

/* [Part] */
part = "assembly"; // [assembly, assembly_pulled, rack, lane, lane_seg_front, lane_seg_mid, lane_seg_back, partition_inner_seg, partition_outer_seg, tie, back_panel, divider, label, plate_lane_fm, plate_lane_bb, plate_partitions_inner, plate_partitions_outer, plate_panels, plate_small, plate_dividers]
seg         = 0;      // partition_*_seg: 0 = front ... part_segs-1 = back
outer_side  = "left"; // [left, right] which outer partition partition_outer_seg renders
label_index = 0;      // which labels[] entry the "label" part renders
pull_dist   = 300;    // assembly_pulled: how far the two lanes come out

/* [Shelf] */
opening_w  = 360;  // clear slide-out width (door / hinges)
shelf_d    = 565;  // usable depth, from the back wall
shelf_h    = 350;  // usable height, to the underside of whatever is above
side_clear = 3;    // rack to opening, each side
top_clear  = 3;    // tallest item to ceiling / to tie underside

/* [Printer] */
bed_x = 270;
bed_y = 270;
bed_z = 256;       // Qidi Q2

/* [Layout] */
bays  = 3;         // lanes per tier (fixed design: 3)
tiers = 2;         // (fixed design: 2)

/* [Rack] */
web_t   = 4;       // partition web thickness (X)
ledge_w = 6;       // ledge protrusion from the web face into a bay
ledge_t = 3;       // ledge plate thickness; 45° gusset below it, depth = ledge_w
foot_t  = 4;       // foot-ledge height (lower lanes ride on it)
lip_h   = 8;       // web continues above the top ledge as a guide lip
back_t  = 6;       // back shear panel thickness (Y)
rack_d  = 560;     // overall rack depth (<= shelf_d)
part_segs = 3;     // partition segments along Y
part_rail = 10;          // solid web rail above the shelf
part_band_solid = 4;     // solid web below the ledge band before the lattice
part_lat_pitch  = 32;    // web diamond lattice pitch
part_lat_strut  = 3;     // web lattice strut width
part_lat_margin = 6;     // solid web at the front, round joints, before the post
joint_len  = 10;   // partition joint tongue length (Y)
joint_neck = 3;    // dovetail half-width at the joint plane (>= web_t/2)
joint_tip  = 5.5;  // dovetail half-width at the tongue tip
joint_skin = -0.5; // outer partitions: tongue's straight outer side, x from web centre
tie_w        = 10;   // tie bar width (Y)
tie_head_w   = 16;   // tie T-head width (Y)
tie_head_in  = 0.2;  // T-head inner end, x from the web centre
tie_head_out = 5;    // T-head outer end (neck starts), x from the web centre
tie_front_y  = 15;   // Y of the front ties
tie_joint_off = 15;  // joint ties sit this far in front of each partition joint
tie_end_gap  = 0.3;  // deep part of a tie stops this short of the ledge tip
panel_tongue   = 2.5; // back-panel tongue depth into the post groove (X)
panel_tongue_w = 3.4; // back-panel tongue root width (Y)
panel_border   = 8;   // solid border round the back-panel lattice
panel_lat_pitch = 30;
panel_lat_strut = 4;
fit = 0.15;        // clearance per face on every drop-in joint

/* [Lane] */
lane_clear = 1.5;  // lane to web, each side
floor_t = 2.0;
wall_t  = 2.0;
wall_h  = 60;      // overall lane height incl. floor
lane_segs = 3;     // lane segments along Y
lane_wall_style = "diamond"; // [diamond, solid]
lane_rail_b = 10;  // solid bottom rail of the side walls (>= lip_h)
lane_rail_t = 10;  // solid top rail (carries the divider notches)
lane_lat_pitch  = 20;
lane_lat_strut  = 3;
lane_lat_margin = 4;
divider_pitch = 20;  // notch pitch along the wall top
divider_t = 2.0;
notch_depth = 6;
dividers_per_lane = 3;
lane_joint_len = 6;  // lane joint tongue length (Y)
post_t    = 8;       // joint post thickness from the outer face (bulges post_t - wall_t inward)
post_pre  = 5;       // post length in front of the joint plane
post_post = 5;       // post length behind the tongue tip
lw_neck = 3;         // wall dovetail neck width
lw_tip  = 5;         // wall dovetail tip width
tab_n    = 4;        // floor jigsaw tabs per joint
tab_neck = 8;
tab_tip  = 12;
pull_w = 50;         // finger pull width
pull_d = 20;         // finger pull depth
pull_r = 10;         // finger pull corner radius

/* [Label] */
labels = ["COLDS & FLU", "PAIN & FEVER", "TUMMY", "ALLERGY", "FIRST AID", "VITAMINS"];
label_w = 80;
label_h = 18;
label_t = 1.2;        // tag plate
label_text_t = 0.6;   // raised text
label_text_size = 7;
label_font = "Liberation Sans:style=Bold";
pocket_proj    = 2.5; // pocket's forward protrusion from the lane front
pocket_z0      = 18;  // tag bottom, lane-local z
pocket_frame_h = 14;  // frame height (tag stands 4 mm proud to grip)
pocket_side    = 3;   // frame border beside the slot
pocket_lip     = 4;   // lip overlap on the tag face, each side
pocket_lip_b   = 2;   // lip overlap on the tag face, bottom
pocket_bot     = 3;   // frame below the slot

/* [Quality] */
$fa = 1;
$fs = 0.4;

/* [Hidden] */
BIG = 2000;
EPS = 0.01;
plate_gap      = 6;   // between parts on a flat plate
part_plate_gap = 12;  // between upright partition segments (brims)

// ============================================================
// Derived
// ============================================================
rack_w    = opening_w - 2*side_clear;
bay_w     = (rack_w - (bays + 1)*web_t) / bays;
pitch_x   = bay_w + web_t;                  // web centre to web centre
lane_w    = bay_w - 2*lane_clear;
lane_in_w = lane_w - 2*wall_t;
lane_d    = rack_d - back_t - 2;
lane_seg_len  = lane_d / lane_segs;
ledge_overlap = ledge_w - lane_clear;
half_web  = web_t / 2;
half_band = half_web + ledge_w;             // section half-width at foot and band
band_h    = ledge_t + ledge_w;              // ledge plate + 45° gusset
z_d       = (shelf_h + ledge_t + ledge_w + foot_t) / 2;   // equal headroom
z_band    = z_d - band_h;                   // ledge-band bottom
h1        = z_band - top_clear - (foot_t + floor_t);      // lower-tier item headroom
h2        = (shelf_h - top_clear) - (z_d + floor_t);      // upper-tier item headroom
rack_h    = z_d + lip_h;
part_seg_len = rack_d / part_segs;
post_y0   = lane_d + 1;                     // back post: 1 mm behind the lanes
panel_y0  = rack_d - back_t;
lane_z    = [foot_t, z_d];                  // lane underside per tier
upper_wall_top = z_d + wall_h;
tg_y0     = (post_y0 + rack_d)/2 - panel_tongue_w/2;   // panel tongue root, front
tg_y1     = tg_y0 + panel_tongue_w;                     // panel tongue, rear
notch_w   = divider_t + 0.4;
div_w     = lane_in_w - 1;
div_h     = wall_h - floor_t - 2;
ear_x     = lane_w/2 - 0.3;                 // divider ear tip, from lane centre
ear_h     = 3;
pk_slot_w = label_w + 1;
pk_gap    = label_t + 0.3;
n_ties    = bays * part_segs;
n_divs    = (tiers * bays) * dividers_per_lane;

function part_x(i) = -rack_w/2 + half_web + i*pitch_x;   // partition i web centre
function bay_x(j)  = part_x(j) + pitch_x/2;              // bay j centre
function part_j(k) = k * part_seg_len;                   // partition joint k (Y)
function lane_J(k) = k * lane_seg_len;                   // lane joint k (lane-local Y)
function label_i(b, t) = (tiers - 1 - t)*bays + b;       // top tier gets labels 0..2

tie_ys = concat([tie_front_y], [for (k = [1:part_segs-1]) part_j(k) - tie_joint_off]);

part_zones = [for (k = [0:part_segs-1]) [
    (k == 0 ? 0 : part_j(k) + joint_len) + part_lat_margin,
    (k == part_segs-1 ? post_y0 : part_j(k+1)) - part_lat_margin]];

lane_zones = [for (k = [0:lane_segs-1]) [
    (k == 0 ? wall_t : lane_J(k) + lane_joint_len + post_post) + lane_lat_margin,
    (k == lane_segs-1 ? lane_d - wall_t : lane_J(k+1) - post_pre) - lane_lat_margin]];

function in_post_zone(y) = len([for (k = [1:lane_segs-1])
    if (y > lane_J(k) - post_pre - 3 && y < lane_J(k) + lane_joint_len + post_post + 3) 1]) > 0;
notch_ys = [for (m = [1:floor(lane_d/divider_pitch)]) let(y = m*divider_pitch)
    if (y >= wall_t + 6 && y <= lane_d - wall_t - 6 && !in_post_zone(y)) y];
function nearest(v, x) = let(d = [for (y = v) abs(y - x)], m = min(d))
    [for (i = [0:len(v)-1]) if (d[i] == m) v[i]][0];
divider_ys = dividers_per_lane > 0
    ? [for (i = [1:dividers_per_lane]) nearest(notch_ys, lane_d*i/(dividers_per_lane + 1))]
    : [];

tab_span = lane_w/2 - post_t - 4 - tab_tip/2;
tab_xs = tab_n == 1 ? [0] : [for (i = [0:tab_n-1]) -tab_span + i*2*tab_span/(tab_n - 1)];

// ---- print-orientation bounding boxes [x0, x1, y0, y1] ----
function bw(bb) = bb[1] - bb[0];
function bh(bb) = bb[3] - bb[2];
function bb_lane_seg(k) = [-lane_w/2, lane_w/2,
    k == 0 ? -pocket_proj : lane_J(k) + fit,
    k == lane_segs-1 ? lane_d : lane_J(k+1) + lane_joint_len - fit];
function bb_part_seg(k, both, right = false) = let(
    x0 = both ? -half_band : -half_web, x1 = half_band,
    y0 = k == 0 ? 0 : part_j(k) + fit,
    y1 = k == part_segs-1 ? rack_d : part_j(k+1) + joint_len - fit)
    right ? [-x1, -x0, y0, y1] : [x0, x1, y0, y1];
bb_tie   = [-(pitch_x/2 - tie_head_in), pitch_x/2 - tie_head_in, -tie_head_w/2, tie_head_w/2];
bb_panel = let(x = pitch_x/2 - half_band + panel_tongue) [-x, x, -rack_h, 0];
bb_div   = [-ear_x, ear_x, 0, div_h];
bb_label = [-label_w/2, label_w/2, 0, label_h];

// heights in print orientation
ht_lane_seg = wall_h;
ht_part_seg = rack_h;
ht_tie      = band_h;
ht_panel    = back_t;

// ---- print plates ----
// A plate is a list of items [kind, a, b, cx, cy]: the part's print
// bounding box is centred on (cx, cy). The render section emits each
// item as its own top-level object, so lazy-union keeps them separate
// objects in the 3MF.
//   kind "lane_seg": a = segment        kind "part_seg": a = segment, b = [both, right]
//   kind "tie" | "panel" | "div"        kind "label": a = labels[] index
PLATES = ["plate_lane_fm", "plate_lane_bb", "plate_partitions_inner", "plate_partitions_outer",
          "plate_panels", "plate_small", "plate_dividers"];
inner_seq = [for (k = [0:part_segs-1], r = [0:1]) k];
outer_seq = [for (r = [false, true], k = [0:part_segs-1]) [k, r]];
small_gap = 5;
n_lab   = len(labels);
n_lab_a = ceil(n_lab/2);

function item_bb(it) =
    it[0] == "lane_seg" ? bb_lane_seg(it[1]) :
    it[0] == "part_seg" ? bb_part_seg(it[1], it[2][0], it[2][1]) :
    it[0] == "tie"      ? bb_tie :
    it[0] == "panel"    ? bb_panel :
    it[0] == "div"      ? bb_div : bb_label;

function plate_items(p) = let(g = plate_gap)
    p == "plate_lane_fm" ? [
        ["lane_seg", 0, 0, -(lane_w + g)/2, 0],
        ["lane_seg", 1, 0,  (lane_w + g)/2, 0]] :
    p == "plate_lane_bb" ? [for (s = [-1, 1])
        ["lane_seg", lane_segs-1, 0, s*(lane_w + g)/2, 0]] :
    p == "plate_partitions_inner" ? let(n = len(inner_seq)) [for (i = [0:n-1])
        ["part_seg", inner_seq[i], [true, false], (i - (n - 1)/2)*(2*half_band + part_plate_gap), 0]] :
    p == "plate_partitions_outer" ? let(n = len(outer_seq)) [for (i = [0:n-1])
        ["part_seg", outer_seq[i][0], [false, outer_seq[i][1]],
         (i - (n - 1)/2)*(half_band + half_web + part_plate_gap), 0]] :
    p == "plate_panels" ? let(H = bh(bb_panel) + g + bh(bb_div)) concat(
        [for (s = [-1, 1]) ["panel", 0, 0, s*(bw(bb_panel) + g)/2,  H/2 - bh(bb_panel)/2]],
        [for (s = [-1, 1]) ["div",   0, 0, s*(bw(bb_div)   + g)/2, -H/2 + bh(bb_div)/2]]) :
    p == "plate_small" ? let(gs = small_gap,
            W   = bw(bb_panel) + gs + bw(bb_tie),
            H   = max(bh(bb_panel) + gs + n_lab_a*(bh(bb_label) + gs) - gs,
                      n_ties*(bh(bb_tie) + gs) + (n_lab - n_lab_a)*(bh(bb_label) + gs) - gs),
            xa  = -W/2 + bw(bb_panel)/2,          // column A: back panel, then labels
            xb  =  W/2 - bw(bb_tie)/2,            // column B: ties, then labels
            ya  = H/2 - bh(bb_panel) - gs,
            yb  = H/2 - n_ties*(bh(bb_tie) + gs)) concat(
        [["panel", 0, 0, xa, H/2 - bh(bb_panel)/2]],
        [for (i = [0:n_ties-1]) ["tie", 0, 0, xb, H/2 - bh(bb_tie)/2 - i*(bh(bb_tie) + gs)]],
        [for (i = [0:n_lab_a-1]) ["label", i, 0, xa, ya - bh(bb_label)/2 - i*(bh(bb_label) + gs)]],
        [for (i = [0:n_lab-n_lab_a-1]) ["label", n_lab_a + i, 0, xb, yb - bh(bb_label)/2 - i*(bh(bb_label) + gs)]]) :
    p == "plate_dividers" ? [for (c = [0:1], r = [0:3])
        ["div", 0, 0, (c - 0.5)*(bw(bb_div) + g), (r - 1.5)*(bh(bb_div) + g)]] :
    [];

function item_rect(it) = let(b = item_bb(it))
    [it[3] - bw(b)/2, it[3] + bw(b)/2, it[4] - bh(b)/2, it[4] + bh(b)/2];
// [X, Y] of the smallest origin-centred rectangle holding the plate
function plate_extent(p) = let(rs = [for (it = plate_items(p)) item_rect(it)])
    [2*max([for (r = rs) max(-r[0], r[1])]), 2*max([for (r = rs) max(-r[2], r[3])])];
// smallest clear gap between any two parts' bounding boxes
function plate_min_gap(p) = let(rs = [for (it = plate_items(p)) item_rect(it)], n = len(rs))
    min([for (i = [0:n-2], j = [i+1:n-1])
        max(rs[j][0] - rs[i][1], rs[i][0] - rs[j][1], rs[j][2] - rs[i][3], rs[i][2] - rs[j][3])]);
function plate_count(p, kind) = len([for (it = plate_items(p)) if (it[0] == kind) 1]);

// ============================================================
// Checks
// ============================================================
function fits_bed(xy) = xy[0] <= bed_x && xy[1] <= bed_y;
function close(a, b) = abs(a - b) < 1e-6;

assert(bays == 3 && tiers == 2, "fixed design: 3 lanes per tier x 2 tiers");
assert(part_segs >= 2 && lane_segs >= 2, "joint code expects >= 2 segments");
// rack width
assert(rack_w <= opening_w, "rack wider than the opening");
assert(close((bays + 1)*web_t + bays*bay_w, rack_w), "bay_w does not close the width");
// lanes across
assert(close(lane_w + 2*lane_clear, bay_w), "lane_w");
assert(lane_in_w >= 100, str("lane interior ", lane_in_w, " < 100: boxes no longer stand across"));
assert(ledge_overlap >= wall_t + 1, str("ledge overlap ", ledge_overlap, " < wall_t + 1"));
// lanes along
assert(close(lane_d, rack_d - back_t - 2), "lane_d");
assert(close(lane_seg_len*lane_segs, lane_d), "lane_seg_len");
assert(post_y0 > lane_d && panel_y0 >= lane_d + 2, "lanes collide with the back post / panel");
assert(rack_d <= shelf_d, "rack deeper than the shelf");
assert(rack_d + pocket_proj <= shelf_d, "label pocket sticks out past the shelf front");
// heights
assert(close(h1, h2), str("tier headroom unequal: ", h1, " vs ", h2));
assert(min(h1, h2) >= 150, str("headroom ", min(h1, h2), " < 150 (syrup bottles)"));
assert(close(z_d + floor_t + h2, shelf_h - top_clear), "upper items exceed the ceiling");
assert(upper_wall_top <= shelf_h - top_clear, "upper lane walls hit the ceiling");
assert(lane_z[0] + wall_h < z_band, "lower lane walls reach the ledge band");
assert(close(rack_h, z_d + lip_h), "rack_h");
assert(lane_rail_b >= lip_h, "lane bottom rail must cover the guide lip");
// partition joint
assert(joint_neck >= half_web, "joint neck narrower than the web: web split would sliver");
assert(joint_tip > joint_neck && joint_tip <= half_band - 2, "joint dovetail jaws too thin");
assert(joint_skin - fit >= -half_web + 1.2, "outer partition joint skin too thin");
// ties
assert(tie_head_in > 0 && tie_head_out < half_band - 2, "tie head must sit in the band");
assert(tie_front_y - tie_head_w/2 - fit >= 4, "front tie slot too close to the front");
assert(part_seg_len - tie_joint_off + tie_head_w/2 + fit <= part_seg_len - part_lat_margin + EPS,
       "joint tie slot runs into the joint");
// back panel
assert(tg_y0 - fit - post_y0 >= 1.5 && rack_d - tg_y1 - fit >= 1.5, "post groove walls < 1.5 mm");
assert(tg_y0 >= panel_y0 && panel_tongue_w - panel_tongue >= 0.5, "panel tongue shape");
// lane joint posts and notches
assert(post_t > wall_t && post_t/2 + lw_tip/2 <= post_t - 1.3, "lane wall dovetail jaws too thin");
assert(floor_t + div_h - ear_h > wall_h - notch_depth, "divider ears would bottom in the notches");
assert(wall_h - notch_depth >= wall_h - lane_rail_t, "notches deeper than the top rail");
assert(len(notch_ys) >= dividers_per_lane, "not enough divider notches");
assert(pocket_z0 + label_h < wall_h - pull_d, "label tag reaches the finger pull");
// print sizes (single parts)
for (k = [0:lane_segs-1]) let(b = bb_lane_seg(k))
    assert(fits_bed([bw(b), bh(b)]) && ht_lane_seg <= bed_z, str("lane segment ", k, " exceeds the bed"));
for (k = [0:part_segs-1], both = [true, false]) let(b = bb_part_seg(k, both))
    assert(fits_bed([bw(b), bh(b)]) && ht_part_seg <= bed_z, str("partition segment ", k, " exceeds the printer"));
assert(fits_bed([bw(bb_tie), bh(bb_tie)]), "tie exceeds the bed");
assert(fits_bed([bw(bb_panel), bh(bb_panel)]), "back panel exceeds the bed");
assert(fits_bed([bw(bb_div), bh(bb_div)]), "divider exceeds the bed");
assert(fits_bed([bw(bb_label), bh(bb_label)]), "label exceeds the bed");
// print sizes (plates): bed centred at the origin, >= 5 mm between parts
for (p = PLATES) {
    assert(fits_bed(plate_extent(p)), str(p, " ", plate_extent(p), " exceeds the bed"));
    assert(plate_min_gap(p) >= 5, str(p, ": parts only ", plate_min_gap(p), " mm apart"));
}
// one rack's worth: plate_panels x1, plate_small x1, plate_dividers x2
assert(plate_count("plate_panels", "panel") + plate_count("plate_small", "panel") == bays, "back panel count");
assert(plate_count("plate_small", "tie") == n_ties, "tie count");
assert(plate_count("plate_panels", "div") + 2*plate_count("plate_dividers", "div") == n_divs,
       str("dividers on plates != ", n_divs, " (", dividers_per_lane, " per lane): re-plan the print list"));

echo(str("rack_w=", rack_w, " bay_w=", bay_w, " lane_w=", lane_w, " interior=", lane_in_w,
         " lane_d=", lane_d, " (", lane_segs, " x ", lane_seg_len, ")",
         " ledge_overlap=", ledge_overlap));
echo(str("z_d=", z_d, " band ", z_band, "..", z_d, " headroom lower=", h1, " upper=", h2,
         " rack_h=", rack_h, " partition segs=", part_seg_len,
         " (+", joint_len, " tongue)"));
echo(str("plates [X,Y] / min gap: ",
         [for (p = PLATES) str(p, " ", plate_extent(p), " / ", plate_min_gap(p))]));

// ============================================================
// Helpers
// ============================================================
// 2D children in (x, z) extruded along +Y from y0 to y1.
module extrude_y(y0, y1) translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children();

// Diamond (45°-rotated square) holes on a staggered grid, each fully
// inside [a0,a1] x [b0,b1]; strut width between neighbours = s. The 45°
// roofs make the holes self-supporting when the plane stands upright.
module diamond_holes_2d(a0, a1, b0, b1, p, s) {
    h  = (p - s*sqrt(2)) / 2;                 // half-diagonal
    na = floor((a1 - a0 - 2*h) / (p/2)) + 1;
    nb = floor((b1 - b0 - 2*h) / (p/2)) + 1;
    oa = (a0 + a1)/2 - (na - 1)*p/4;
    ob = (b0 + b1)/2 - (nb - 1)*p/4;
    if (h > 0 && na >= 1 && nb >= 1)
        for (i = [0:na-1], k = [0:nb-1])
            if ((i + k) % 2 == 0)
                translate([oa + i*p/2, ob + k*p/2]) rotate(45) square(h*sqrt(2), center = true);
}

// Translate children so bounding box bb is centred on (cx, cy).
module at(bb, cx, cy) translate([cx - (bb[0] + bb[1])/2, cy - (bb[2] + bb[3])/2, 0]) children();

// ============================================================
// Partition
// Local coordinates: x from the web centre, with the bay on the +x
// side for an outer partition (the left one; the right is mirrored).
// both = true: inner partition, ledges on both sides.
// ============================================================
module part_xsec_2d(both) {                   // (x, z) cross-section
    translate([-half_web, 0]) square([web_t, rack_h]);
    for (s = both ? [-1, 1] : [1]) scale([s, 1]) {
        translate([half_web - EPS, 0]) square([ledge_w + EPS, foot_t]);          // foot ledge
        polygon([[half_web - EPS, z_band], [half_band, z_d - ledge_t],            // gusset +
                 [half_band, z_d], [half_web - EPS, z_d]]);                       // top ledge
    }
}

// Back-panel tongue for a panel on the +x side, nominal (no clearance).
// Its front face runs at 45° so the flat-printed panel (front face on
// the bed) needs no support under it.
module panel_tongue_2d()
    polygon([[half_band + 1, tg_y0 - 1], [half_band + 1, tg_y1],
             [half_band - panel_tongue, tg_y1], [half_band - panel_tongue, tg_y0 + panel_tongue]]);

// T-slot for a tie at y = yc, cut down from the top to the ledge-plate
// underside. Inner partitions take a tie from each side; the two heads
// share one cavity.
module tslot(yc, both) {
    zb  = z_d - ledge_t;
    hgt = rack_h - zb + 1;
    x0  = both ? -(tie_head_out + fit) : tie_head_in - fit;
    translate([x0, yc - tie_head_w/2 - fit, zb])
        cube([tie_head_out + fit - x0, tie_head_w + 2*fit, hgt]);
    for (s = both ? [-1, 1] : [1]) scale([s, 1, 1])
        translate([tie_head_out - EPS, yc - tie_w/2 - fit, zb])
            cube([half_band - tie_head_out + 1, tie_w + 2*fit, hgt]);
}

module part_lattice()
    for (zn = part_zones)
        translate([-half_band - 1, 0, 0]) rotate([90, 0, 90])
            linear_extrude(2*half_band + 2)
                diamond_holes_2d(zn[0], zn[1], part_rail, z_band - part_band_solid,
                                 part_lat_pitch, part_lat_strut);

module partition_full(both) {
    px0 = both ? -half_band : -half_web;
    difference() {
        union() {
            extrude_y(0, post_y0 + EPS) part_xsec_2d(both);
            translate([px0, post_y0, 0]) cube([half_band - px0, rack_d - post_y0, rack_h]);  // back post
        }
        part_lattice();
        for (y = tie_ys) tslot(y, both);
        for (s = both ? [-1, 1] : [1]) scale([s, 1, 1])
            translate([0, 0, -1]) linear_extrude(rack_h + 2) offset(delta = fit) panel_tongue_2d();
    }
}

// Region (XY) owned by the segments in front of partition joint k.
module part_A_2d(k, both) {
    if (k >= part_segs) translate([-BIG/2, -BIG/2]) square(BIG);
    else if (k >= 1) {
        j = part_j(k);
        union() {
            translate([-BIG/2, j - BIG]) square(BIG);
            polygon(both
                ? [[-joint_neck, j - EPS], [joint_neck, j - EPS], [joint_tip, j + joint_len], [-joint_tip, j + joint_len]]
                : [[joint_skin, j - EPS], [joint_neck, j - EPS], [joint_tip, j + joint_len], [joint_skin, j + joint_len]]);
        }
    }
}

module partition_seg(k, both) render() intersection() {
    partition_full(both);
    translate([0, 0, -1]) linear_extrude(rack_h + 2) offset(delta = -fit)
        difference() { part_A_2d(k + 1, both); part_A_2d(k, both); }
}

// ============================================================
// Tie — bay-centred, tie line at y = 0, TOP face at z = 0
// (installed at z = z_d).
// ============================================================
module tie_2d() {
    hw = pitch_x/2;
    square([2*(hw - tie_head_out) + 2*EPS, tie_w], center = true);
    for (s = [-1, 1]) translate([s*(hw - (tie_head_in + tie_head_out)/2), 0])
        square([tie_head_out - tie_head_in, tie_head_w], center = true);
}

module tie() {
    dx = pitch_x/2 - half_band - tie_end_gap;
    translate([0, 0, -ledge_t]) linear_extrude(ledge_t) tie_2d();     // ends over the ledges
    translate([-dx, -tie_w/2, -band_h]) cube([2*dx, tie_w, band_h]);   // deep span in the band
}

// ============================================================
// Back panel — bay-centred, installed position.
// ============================================================
module panel_holes() {
    xw = pitch_x/2 - half_band - fit - panel_border;
    translate([0, rack_d + 1, 0]) rotate([90, 0, 0]) linear_extrude(back_t + 2)
        diamond_holes_2d(-xw, xw, panel_border, rack_h - panel_border, panel_lat_pitch, panel_lat_strut);
}

module back_panel() {
    xb = pitch_x/2 - half_band - fit;
    difference() {
        union() {
            translate([-xb, panel_y0, 0]) cube([2*xb, back_t, rack_h]);
            for (s = [-1, 1]) scale([s, 1, 1]) intersection() {
                linear_extrude(rack_h) translate([pitch_x/2, 0]) mirror([1, 0, 0]) panel_tongue_2d();
                translate([0, panel_y0, -1]) cube([pitch_x, back_t, rack_h + 2]);
            }
        }
        panel_holes();
    }
}

// ============================================================
// Lane — lane-local: x centred, y = 0 at the front face, z = 0 at
// the underside.
// ============================================================
module lane_holes()
    for (zn = lane_zones)
        translate([-lane_w/2 - 1, 0, 0]) rotate([90, 0, 90]) linear_extrude(lane_w + 2)
            diamond_holes_2d(zn[0], zn[1], lane_rail_b, wall_h - lane_rail_t,
                             lane_lat_pitch, lane_lat_strut);

module pull_2d() {
    zc = wall_h - pull_d + pull_r;
    hull() for (s = [-1, 1]) translate([s*(pull_w/2 - pull_r), zc]) circle(r = pull_r);
    translate([-pull_w/2, zc]) square([pull_w, wall_h - zc + 1]);
}

module pocket_frame() {
    fw = pk_slot_w/2 + pocket_side;
    z0 = pocket_z0 - pocket_bot;
    z1 = pocket_z0 + pocket_frame_h;
    translate([-fw, 0, 0]) rotate([90, 0, 90]) linear_extrude(2*fw)          // (y, z) profile
        polygon([[0.5, z0 - pocket_proj - 0.5], [0.5, z1], [-pocket_proj, z1], [-pocket_proj, z0]]);
}

module pocket_cut() {
    translate([-pk_slot_w/2, -pk_gap, pocket_z0])                              // tag slot, open top
        cube([pk_slot_w, pk_gap, pocket_frame_h + 1]);
    translate([-(pk_slot_w/2 - pocket_lip), -pocket_proj - 1, pocket_z0 + pocket_lip_b])   // window
        cube([pk_slot_w - 2*pocket_lip, pocket_proj + 1 - pk_gap + EPS, pocket_frame_h]);
}

module lane_full() {
    difference() {
        union() {
            translate([-lane_w/2, 0, 0]) cube([lane_w, lane_d, floor_t]);
            for (s = [-1, 1]) scale([s, 1, 1]) translate([lane_w/2 - wall_t, 0, 0]) cube([wall_t, lane_d, wall_h]);
            translate([-lane_w/2, 0, 0]) cube([lane_w, wall_t, wall_h]);
            translate([-lane_w/2, lane_d - wall_t, 0]) cube([lane_w, wall_t, wall_h]);
            for (k = [1:lane_segs-1], s = [-1, 1]) scale([s, 1, 1])
                translate([lane_w/2 - post_t, lane_J(k) - post_pre, 0])
                    cube([post_t, post_pre + lane_joint_len + post_post, wall_h]);
            pocket_frame();
        }
        if (lane_wall_style == "diamond") lane_holes();
        for (y = notch_ys)
            translate([-lane_w/2 - 1, y - notch_w/2, wall_h - notch_depth]) cube([lane_w + 2, notch_w, notch_depth + 1]);
        translate([0, wall_t + 1, 0]) rotate([90, 0, 0]) linear_extrude(wall_t + pocket_proj + 2) pull_2d();
        pocket_cut();
    }
}

// Region (XY) owned by the segments in front of lane joint k.
module lane_A_2d(k) {
    if (k >= lane_segs) translate([-BIG/2, -BIG/2]) square(BIG);
    else if (k >= 1) {
        J  = lane_J(k);
        L  = lane_joint_len;
        uc = post_t/2;
        union() {
            translate([-BIG/2, J - BIG]) square(BIG);
            for (s = [-1, 1]) scale([s, 1])
                polygon([[lane_w/2 - uc + lw_neck/2, J - EPS], [lane_w/2 - uc - lw_neck/2, J - EPS],
                         [lane_w/2 - uc - lw_tip/2, J + L], [lane_w/2 - uc + lw_tip/2, J + L]]);
            for (x = tab_xs)
                polygon([[x - tab_neck/2, J - EPS], [x + tab_neck/2, J - EPS],
                         [x + tab_tip/2, J + L], [x - tab_tip/2, J + L]]);
        }
    }
}

module lane_seg(k) render() intersection() {
    lane_full();
    translate([0, 0, -1]) linear_extrude(wall_h + 2) offset(delta = -fit)
        difference() { lane_A_2d(k + 1); lane_A_2d(k); }
}

// ============================================================
// Divider and label tag — built in PRINT orientation (flat, XY).
// Installed by rotate([90,0,0]): +Y becomes up, +Z becomes -Y.
// ============================================================
module divider() {
    translate([-div_w/2, 0, 0]) cube([div_w, div_h, divider_t]);
    translate([-ear_x, div_h - ear_h, 0]) cube([2*ear_x, ear_h, divider_t]);   // ears into the notches
}

module label_tag(i) {
    txt = labels[i];
    sz  = min(label_text_size, (pk_slot_w - 2*pocket_lip - 3) / (0.68*len(txt)));
    translate([-label_w/2, 0, 0]) cube([label_w, label_h, label_t]);
    translate([0, (label_h + pocket_lip_b)/2, label_t - EPS])
        linear_extrude(label_text_t + EPS)
            text(txt, size = sz, font = label_font, halign = "center", valign = "center");
}

// ============================================================
// Placement
// ============================================================
c_part  = "SlateGray";
c_tie   = "DarkOrange";
c_panel = "DimGray";
c_lane  = "Ivory";
c_div   = "LightSkyBlue";
c_labels = ["Tomato", "Gold", "MediumSeaGreen", "Orchid", "Crimson", "DeepSkyBlue"];

module partition_at(i) translate([part_x(i), 0, 0]) {
    if (i == 0)         for (k = [0:part_segs-1]) partition_seg(k, false);
    else if (i == bays) mirror([1, 0, 0]) for (k = [0:part_segs-1]) partition_seg(k, false);
    else                for (k = [0:part_segs-1]) partition_seg(k, true);
}
module ties_placed()   for (j = [0:bays-1], y = tie_ys) translate([bay_x(j), y, z_d]) tie();
module panels_placed() for (j = [0:bays-1]) translate([bay_x(j), 0, 0]) back_panel();

module rack() {
    color(c_part)  for (i = [0:bays]) partition_at(i);
    color(c_tie)   ties_placed();
    color(c_panel) panels_placed();
}

module lane_body() for (k = [0:lane_segs-1]) lane_seg(k);

module lane_inserts(i) {
    color(c_div) for (y = divider_ys)
        translate([0, y + divider_t/2, floor_t]) rotate([90, 0, 0]) divider();
    color(c_labels[i % len(c_labels)])
        translate([0, -fit, pocket_z0]) rotate([90, 0, 0]) label_tag(i);
}

module lane_unit(i) { color(c_lane) lane_body(); lane_inserts(i); }

module lane_placed(b, t, dy = 0) translate([bay_x(b), -dy, lane_z[t]]) children();

function pulled_dy(b, t) = ((t == tiers - 1 && b == 0) || (t == 0 && b == bays - 1)) ? pull_dist : 0;

module assembly(pulled) {
    rack();
    for (t = [0:tiers-1], b = [0:bays-1])
        lane_placed(b, t, pulled ? pulled_dy(b, t) : 0) lane_unit(label_i(b, t));
    %translate([-opening_w/2, -(shelf_d - rack_d), 0]) cube([opening_w, shelf_d, shelf_h]);
}

// ============================================================
// Print orientation
// ============================================================
module print_part_seg(k, both, right = false) {
    if (right) mirror([1, 0, 0]) partition_seg(k, both);
    else partition_seg(k, both);
}
module print_tie()   rotate([180, 0, 0]) tie();                                 // top face down
module print_panel() translate([0, 0, -panel_y0]) rotate([90, 0, 0]) back_panel();   // front face down

// One plate item in print orientation, before centring (see plate_items).
module item(it) {
    if      (it[0] == "lane_seg") lane_seg(it[1]);
    else if (it[0] == "part_seg") print_part_seg(it[1], it[2][0], it[2][1]);
    else if (it[0] == "tie")      print_tie();
    else if (it[0] == "panel")    print_panel();
    else if (it[0] == "div")      divider();
    else if (it[0] == "label")    label_tag(it[1]);
}

// ============================================================
// RENDER
// ============================================================
if (part == "assembly")                assembly(false);
else if (part == "assembly_pulled")    assembly(true);
else if (part == "rack")               rack();
else if (part == "lane")               lane_unit(label_index);
else if (part == "lane_seg_front")     at(bb_lane_seg(0), 0, 0) lane_seg(0);
else if (part == "lane_seg_mid")       at(bb_lane_seg(1), 0, 0) lane_seg(1);
else if (part == "lane_seg_back")      at(bb_lane_seg(lane_segs-1), 0, 0) lane_seg(lane_segs-1);
else if (part == "partition_inner_seg") at(bb_part_seg(seg, true), 0, 0) print_part_seg(seg, true);
else if (part == "partition_outer_seg")
    at(bb_part_seg(seg, false, outer_side == "right"), 0, 0) print_part_seg(seg, false, outer_side == "right");
else if (part == "tie")                at(bb_tie, 0, 0) print_tie();
else if (part == "back_panel")         at(bb_panel, 0, 0) print_panel();
else if (part == "divider")            at(bb_div, 0, 0) divider();
else if (part == "label")              at(bb_label, 0, 0) label_tag(label_index);
else if (len([for (p = PLATES) if (p == part) 1]) > 0)
    // a top-level for: every iteration stays its own object in the 3MF
    for (it = plate_items(part)) at(item_bb(it), it[3], it[4]) item(it);
else assert(false, str("unknown part: ", part));
