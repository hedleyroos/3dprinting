#!/usr/bin/env bash
# Render views + export STLs for the front-frame model (charger73_front_frame.scad).
#
#   ./render_frame.sh
#
# Outputs into renders/frame/: PNG views (full renders, so every face gets
# the same shading), the cross-section, the test piece, and the STLs
# frame_L / frame_R / test_piece / wing.
set -euo pipefail
cd "$(dirname "$0")"

OS="${OPENSCAD:-/usr/local/bin/openscad}"
M="charger73_front_frame.scad"
V="renders/frame"
mkdir -p "$V"
png() { "$OS" --backend=manifold --render --colorscheme=Tomorrow "$@" "$M" 2>/dev/null; }

echo "== PNG views =="
png -o "$V/front.png" --imgsize=2400,640 --projection=o --camera=310,0,560,310,0,0
png -o "$V/rear.png" --imgsize=2400,640 --projection=o --camera=310,0,-560,310,0,0
png -o "$V/outboard_rear.png" --imgsize=1600,1100 --camera=1000,-200,-300,560,0,-30
png -o "$V/inboard_rear.png" --imgsize=1600,1100 --camera=-220,-160,-260,30,0,-20
png -o "$V/inboard_front.png" --imgsize=1600,1100 --camera=-250,-200,250,40,0,0
png -o "$V/boss.png" --imgsize=1400,1000 --camera=190,120,-130,249,58,-42
png -D 'part="section"' -o "$V/section.png" --imgsize=1400,900 --projection=o --camera=-20,58,130,-20,58,0
png -D 'part="section"' -D section_x=4 -o "$V/section_root.png" --imgsize=1400,900 --projection=o --camera=-30,0,170,-30,0,0
png -D 'part="test"' -o "$V/test.png" --imgsize=1400,1000 --camera=-90,150,130,0,5,15
png -D 'part="wing"' -o "$V/wing.png" --imgsize=1400,1000 --camera=-30,-40,250,-30,-40,0 --projection=o

echo "== STL exports =="
"$OS" --backend=manifold --export-format=binstl -o "$V/frame_L.stl" "$M"
"$OS" --backend=manifold --export-format=binstl -D 'side="R"' -o "$V/frame_R.stl" "$M"
"$OS" --backend=manifold --export-format=binstl -D 'part="test"' -o "$V/test_piece.stl" "$M"
"$OS" --backend=manifold --export-format=binstl -D 'part="wing"' -o "$V/wing.stl" "$M"
echo "done."
