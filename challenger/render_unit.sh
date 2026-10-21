#!/usr/bin/env bash
# Render views + export STLs for the rear unit (charger73_rear_unit.scad).
#
#   ./render_unit.sh
#
# Outputs into renders/unit/: the unit and piece 1 in print orientation, bell 1
# cutaway and x-z section, the assembled unit from behind and from the front,
# and the STLs piece1..4 and pan_insert.
set -euo pipefail
cd "$(dirname "$0")"

OS="${OPENSCAD:-/usr/local/bin/openscad}"
M="charger73_rear_unit.scad"
V="renders/unit"
mkdir -p "$V"
png() { "$OS" --backend=manifold --render --colorscheme=Tomorrow "$@" "$M" 2>/dev/null; }

echo "== PNG views =="
png -D 'part="unit"' -o "$V/unit_print.png" --imgsize=2400,900 --camera=0,-520,420,0,0,25
png -D 'part="piece1"' -o "$V/piece1_print.png" --imgsize=1400,1000 --camera=60,-300,230,0,0,25
png -D 'part="cutaway"' -o "$V/bell1_cutaway.png" --imgsize=1400,1000 --camera=-40,-300,220,0,0,28
png -D 'part="section"' -o "$V/bell1_section.png" --imgsize=1600,700 --projection=o --camera=0,28,300,0,28,0 --viewall --autocenter
png -D 'part="assembled"' -o "$V/assembled_rear.png" --imgsize=1800,900 --camera=330,-420,-330,330,0,-55
png -D 'part="assembled"' -o "$V/assembled_front.png" --imgsize=2400,640 --projection=o --camera=330,0,400,330,0,-60

echo "== STL exports =="
for p in piece1 piece2 piece3 piece4 pan_insert; do
  "$OS" --backend=manifold --export-format=binstl -D "part=\"$p\"" -o "$V/$p.stl" "$M"
done
echo "done."
