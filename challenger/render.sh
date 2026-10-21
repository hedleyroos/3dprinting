#!/usr/bin/env bash
# Render PNG views + export STLs for the 1973 Charger tail-light housing model.
#
#   ./render.sh              fast previews + full exports
#   ./render.sh --fast       quick low-poly pass only
#
# Outputs into renders/ (views in renders/views/, STLs in renders/).
set -euo pipefail
cd "$(dirname "$0")"

OS="${OPENSCAD:-/usr/local/bin/openscad}"
MODEL="charger73_taillight_housing.scad"
PY=".venv/bin/python"
QUALITY="final"
[ "${1:-}" = "--fast" ] && QUALITY="fast"

mkdir -p renders renders/views renders/compare
SIDE_L='-D side="L"'
SIDE_R='-D side="R"'

echo "== PNG views =="
# orthographic front (as seen from +z; outboard end on the right)
"$OS" $SIDE_L -o renders/views/front_L.png --imgsize=2000,560 --projection=o \
      --camera=305,0,450,305,0,-40 --autocenter -D quality="\"$QUALITY\"" "$MODEL"
# orthographic rear (looking along +z; outboard end appears on the left)
"$OS" $SIDE_L -o renders/views/rear_L.png --imgsize=2000,560 --projection=o \
      --camera=305,0,-450,305,0,-40 --autocenter -D quality="\"$QUALITY\"" "$MODEL"
# outboard three-quarter view
"$OS" $SIDE_L -o renders/views/threequarter_L.png --imgsize=1800,1200 \
      --camera=-650,450,950,270,0,-45 --viewall --autocenter -D quality="\"$QUALITY\"" "$MODEL"
# top view of the inboard plate curl
"$OS" $SIDE_L -o renders/views/plate_top_L.png --imgsize=1600,560 --projection=o \
      --camera=0,880,-30,0,0,-30 --autocenter -D quality="\"$QUALITY\"" "$MODEL"
# mirrored side
"$OS" $SIDE_R -o renders/views/threequarter_R.png --imgsize=1800,1200 \
      --camera=-650,450,950,270,0,-45 --viewall --autocenter -D quality="\"$QUALITY\"" "$MODEL"

echo "== STL exports =="
"$OS" --backend=manifold --export-format=binstl $SIDE_L -D part='"all"' -o renders/charger73_housing_L.stl -D quality='"final"' "$MODEL"
"$OS" --backend=manifold --export-format=binstl $SIDE_R -D part='"all"' -o renders/charger73_housing_R.stl -D quality='"final"' "$MODEL"
for n in 1 2 3 4; do
  "$OS" --backend=manifold --export-format=binstl $SIDE_L -D part="\"$n\"" -o "renders/charger73_section${n}_L.stl" -D quality='"final"' "$MODEL"
done
"$OS" --backend=manifold --export-format=binstl -D part='"keys"'   -o renders/charger73_keys.stl   -D quality='"final"' "$MODEL"
"$OS" --backend=manifold --export-format=binstl -D part='"splice"' -o renders/charger73_splice.stl -D quality='"final"' "$MODEL"

echo "== STL statistics + mirror check =="
"$PY" tools/stl_stats.py renders/charger73_housing_L.stl renders/charger73_housing_R.stl \
      renders/charger73_section1_L.stl renders/charger73_section2_L.stl \
      renders/charger73_section3_L.stl renders/charger73_section4_L.stl
"$PY" tools/stl_stats.py --mirror-pair renders/charger73_housing_L.stl renders/charger73_housing_R.stl

echo "== comparison sheets (render beside photo) =="
if [ -f unnamed.jpg ]; then
  "$PY" tools/photo_measure.py crop unnamed.jpg --rotate -90 --zoom 0.45 --out renders/compare/photo_front_rot.png
  "$PY" tools/photo_measure.py sheet renders/views/front_L.png renders/compare/photo_front_rot.png \
        --height 950 --out renders/compare/sheet_front.png
fi
if [ -f IMG_7441.jpeg ]; then
  "$PY" tools/photo_measure.py sheet renders/views/rear_L.png IMG_7441.jpeg \
        --height 800 --flip 1 --out renders/compare/sheet_rear.png
fi

echo "done."
