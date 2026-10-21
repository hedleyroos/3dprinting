#!/usr/bin/env python3
"""Side-by-side sheet of photos and renders, for checking a model against the part.

    montage.py OUT.png HEIGHT "label=path[@x0,y0,x1,y1]" ... [ "|" "label=path" ... ]

Tiles are scaled to HEIGHT; "|" starts a new row. A crop box after "@" is in the
photo's own pixels (after EXIF rotation). Renders (.png) have their blank margin
trimmed first.
"""
import sys
import numpy as np
from PIL import Image, ImageOps, ImageDraw

out, height = sys.argv[1], int(sys.argv[2])
rows, row = [], []
for spec in sys.argv[3:]:
    if spec == '|':
        rows.append(row); row = []
        continue
    label, path = spec.split('=', 1)
    box = None
    if '@' in path:
        path, b = path.split('@'); box = tuple(int(v) for v in b.split(','))
    im = ImageOps.exif_transpose(Image.open(path)).convert('RGB')
    if box:
        im = im.crop(box)
    elif path.endswith('.png'):
        a = np.asarray(im).astype(int)
        ys, xs = np.nonzero(np.abs(a - a[0, 0]).sum(axis=2) > 30)
        if len(xs):
            im = im.crop((max(xs.min() - 20, 0), max(ys.min() - 20, 0),
                          min(xs.max() + 20, im.width), min(ys.max() + 20, im.height)))
    im = im.resize((max(1, round(im.width * height / im.height)), height))
    row.append((label, im))
rows.append(row)

gap, top = 10, 24
width = max(sum(t.width for _, t in r) + gap * (len(r) + 1) for r in rows)
sheet = Image.new('RGB', (width, len(rows) * (height + top + gap)), 'white')
draw = ImageDraw.Draw(sheet)
y = 0
for r in rows:
    x = gap
    for label, t in r:
        draw.text((x, y + 6), label, fill='black')
        sheet.paste(t, (x, y + top))
        x += t.width + gap
    y += height + top + gap
sheet.save(out)
print(out, sheet.size)
