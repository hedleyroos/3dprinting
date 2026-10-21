#!/usr/bin/env python3
"""Millimetre measuring helpers for the 1973 Charger tail-light photos.

The original-housing photos were shot with a 30 cm steel rule in frame, so
pixel distances can be converted to millimetres.  This tool crops / zooms
regions, finds the rule ticks to derive px/mm, overlays calibrated grids and
builds the side-by-side comparison sheets used to check the OpenSCAD renders.

Subcommands
-----------
info      image sizes (after EXIF rotation)
autocalib find rule ticks inside a strip and report px/mm candidates
crop      crop (+ rotate, + zoom) a region
tile      cut an image into overlapping tiles for broad inspection
grid      overlay a calibrated millimetre grid
measure   convert two pixel points to a millimetre distance
profile   intensity profile along a row / column, optionally with edge list
sheet     labelled side-by-side contact sheet (render beside photo)

Examples
--------
python tools/photo_measure.py info unnamed.jpg IMG_7441.jpeg
python tools/photo_measure.py autocalib unnamed.jpg --box 100,900,480,5200
python tools/photo_measure.py measure unnamed.jpg --pxmm 2.90 --p1 2600,700 --p2 2600,2500
python tools/photo_measure.py crop IMG_7445.jpeg --box 2000,1500,3600,3100 --zoom 0.5 --out renders/measure/lip.png
python tools/photo_measure.py grid unnamed.jpg --pxmm 2.90 --step 10 --origin 1000,3000 --out renders/measure/front_grid.png
python tools/photo_measure.py sheet renders/compare/front.png renders/front_L.png unnamed.jpg --height 900 --flip 2 --out renders/compare/front_sheet.png
"""

from __future__ import annotations

import argparse
import math
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageOps


# ----------------------------------------------------------------- helpers

def load(path: str) -> Image.Image:
    """Open an image and apply any EXIF rotation."""
    img = Image.open(path)
    transposed = ImageOps.exif_transpose(img)
    return transposed if transposed is not None else img


def img_gray(img: Image.Image) -> np.ndarray:
    return np.asarray(img.convert("L"), dtype=np.float32)


def parse_box(s: str) -> tuple[int, int, int, int]:
    parts = [int(float(v)) for v in s.replace(" ", "").split(",")]
    if len(parts) != 4:
        raise argparse.ArgumentTypeError("box must be x0,y0,x1,y1")
    x0, y0, x1, y1 = parts
    return (min(x0, x1), min(y0, y1), max(x0, x1), max(y0, y1))


def parse_point(s: str) -> tuple[int, int]:
    x, y = (int(float(v)) for v in s.replace(" ", "").split(","))
    return (x, y)


def _font(size: int) -> ImageFont.ImageFont:
    try:
        return ImageFont.load_default(size=size)
    except TypeError:  # older Pillow
        return ImageFont.load_default()


def save_img(img: Image.Image, out: str) -> None:
    p = Path(out)
    p.parent.mkdir(parents=True, exist_ok=True)
    img.save(p)
    print(f"wrote {p}  ({img.width}x{img.height})")


# ------------------------------------------------------------- subcommands

def cmd_info(a: argparse.Namespace) -> None:
    for p in a.images:
        im = load(p)
        print(f"{p}: {im.width} x {im.height} px")


def _marks_1d(sig: np.ndarray, thresh: float, min_gap: float) -> np.ndarray:
    """Centres of dark marks in a 1-D intensity signal."""
    pos = np.clip(-(sig - np.median(sig)), 0, None)          # darkness
    hot = pos > pos.mean() + thresh * pos.std()
    marks: list[float] = []
    i, n = 0, len(hot)
    while i < n:
        if hot[i]:
            j = i
            while j + 1 < n and hot[j + 1]:
                j += 1
            w = pos[i:j + 1]
            marks.append(float((np.arange(i, j + 1) * w).sum() / max(w.sum(), 1e-9)))
            i = j + 1
        else:
            i += 1
    merged: list[float] = []
    for c in marks:
        if merged and c - merged[-1] < min_gap:
            merged[-1] = 0.5 * (merged[-1] + c)
        else:
            merged.append(c)
    return np.asarray(merged)


a_thresh = 1.0  # module-level knob used by find_marks (set from --thresh)


def find_marks(sig: np.ndarray, min_gap: float) -> np.ndarray:
    return _marks_1d(sig, a_thresh, min_gap)


def gap_clusters(gaps: np.ndarray) -> list[tuple[float, int]]:
    """Cluster gap lengths into (approx gap px, count) pairs, most common first."""
    out: list[list[float]] = []
    for g in np.sort(gaps):
        for c in out:
            if abs(g - c[0] / c[1]) < 0.2 * (c[0] / c[1]):
                c[0] += g
                c[1] += 1
                break
        else:
            out.append([float(g), 1.0])
    return [(c[0] / c[1], int(c[1])) for c in sorted(out, key=lambda c: -c[1])]


def regularity(marks: np.ndarray) -> float:
    """How rule-like a set of marks is: many marks, evenly spaced."""
    if len(marks) < 5:
        return 0.0
    gaps = np.diff(marks)
    med = float(np.median(gaps))
    if med <= 1:
        return 0.0
    return len(marks) / (1.0 + 10.0 * float(gaps.std()) / med)


def cmd_findrule(a: argparse.Namespace) -> None:
    img = load(a.image)
    g = img_gray(img)
    x0, y0, x1, y1 = parse_box(a.box)
    results: list[tuple[float, int, np.ndarray]] = []
    if a.axis == "y":                     # rule runs vertically -> scan columns
        for x in range(x0, max(x1 - a.band, x0 + 1), a.step):
            sig = g[y0:y1, x:x + a.band].mean(axis=1)
            results.append((regularity(_marks_1d(sig, a.thresh, a.min_gap)), x,
                            _marks_1d(sig, a.thresh, a.min_gap)))
    else:                                 # rule runs horizontally -> scan rows
        for y in range(y0, max(y1 - a.band, y0 + 1), a.step):
            sig = g[y:y + a.band, x0:x1].mean(axis=0)
            results.append((regularity(_marks_1d(sig, a.thresh, a.min_gap)), y,
                            _marks_1d(sig, a.thresh, a.min_gap)))
    results.sort(key=lambda r: -r[0])
    for score, pos, marks in results[:a.top]:
        if len(marks) < 4:
            continue
        gaps = np.diff(marks)
        cl = ", ".join(f"{gap:.1f}px x{n}" for gap, n in gap_clusters(gaps)[:4])
        print(f"line @ {pos:5d}: score {score:6.1f}  marks {len(marks):3d}  "
              f"median gap {float(np.median(gaps)):6.2f}px  clusters: {cl}")
    best_score, best_pos, best_marks = results[0]
    if len(best_marks) >= 4:
        gaps = np.diff(best_marks)
        med = float(np.median(gaps))
        print(f"\nbest line @ {best_pos}: {len(best_marks)} marks, median gap {med:.2f} px")
        print("  first gaps px: " + " ".join(f"{v:.1f}" for v in gaps[:14]))
        for label, mm in (("1 mm", 1.0), ("5 mm", 5.0), ("10 mm", 10.0)):
            print(f"  if marks are {label:<5s} apart: {med / mm:7.3f} px/mm")
    if a.out:
        if a.axis == "y":
            crop = load(a.image).crop((max(best_pos - 30, 0), y0,
                                       min(best_pos + 130, img.width), y1))
            d = ImageDraw.Draw(crop)
            for m in best_marks:
                d.line([(0, m), (70, m)], fill=(255, 0, 0), width=3)
        else:
            crop = load(a.image).crop((x0, max(best_pos - 30, 0),
                                       x1, min(best_pos + 130, img.height)))
            d = ImageDraw.Draw(crop)
            for m in best_marks:
                d.line([(m, 0), (m, 70)], fill=(255, 0, 0), width=3)
        save_img(crop, a.out)


def cmd_autocalib(a: argparse.Namespace) -> None:
    global a_thresh
    a_thresh = a.thresh
    img = load(a.image)
    g = img_gray(img)
    x0, y0, x1, y1 = parse_box(a.box)
    strip = g[y0:y1, x0:x1]
    if a.axis == "x":
        sig = strip.mean(axis=0)
        off = x0
    else:
        sig = strip.mean(axis=1)
        off = y0
    marks = find_marks(sig, a.min_gap)
    if len(marks) < 4:
        print(f"{a.image}: only {len(marks)} marks found - adjust --box/--thresh")
        return
    gaps = np.diff(marks)
    med = float(np.median(gaps))
    print(f"{a.image}: {len(marks)} dark marks, median gap {med:.2f} px")
    print("  first gaps px: " + " ".join(f"{v:.1f}" for v in gaps[:12]))
    for label, mm in (("1 mm", 1.0), ("5 mm", 5.0), ("10 mm", 10.0)):
        print(f"  if marks are {label:<5s} apart: {med / mm:7.3f} px/mm  ({med * 10 / mm:8.2f} px/cm)")
    print(f"  span first..last mark: {marks[-1] - marks[0]:.1f} px "
          f"(starts at {off + marks[0]:.0f} px along the strip)")


def cmd_crop(a: argparse.Namespace) -> None:
    img = load(a.image)
    if a.box:
        img = img.crop(parse_box(a.box))
    if a.rotate:
        img = img.rotate(a.rotate, expand=True, resample=Image.BICUBIC)
    if a.zoom != 1.0:
        img = img.resize((round(img.width * a.zoom), round(img.height * a.zoom)), Image.LANCZOS)
    out = a.out or f"renders/measure/{Path(a.image).stem}_crop.png"
    save_img(img, out)


def cmd_tile(a: argparse.Namespace) -> None:
    img = load(a.image)
    w, h = img.size
    step = max(a.size - a.overlap, 1)
    k = 0
    for ty, y in enumerate(range(0, max(h - a.overlap, 1), step)):
        for tx, x in enumerate(range(0, max(w - a.overlap, 1), step)):
            t = img.crop((x, y, min(x + a.size, w), min(y + a.size, h)))
            out = Path(a.outdir) / f"{Path(a.image).stem}_t{ty:02d}_{tx:02d}.png"
            out.parent.mkdir(parents=True, exist_ok=True)
            t.save(out)
            k += 1
    print(f"wrote {k} tiles to {a.outdir}")


def cmd_grid(a: argparse.Namespace) -> None:
    img = load(a.image).convert("RGB")
    dr = ImageDraw.Draw(img, "RGBA")
    ox, oy = a.origin
    step_px = a.step * a.pxmm
    font = _font(28)
    w, h = img.size
    for k in range(int(math.ceil((0 - ox) / step_px)), int(math.floor((w - ox) / step_px)) + 1):
        x = ox + k * step_px
        major = (k % 5 == 0)
        dr.line([(x, 0), (x, h)], fill=(255, 0, 0, 150) if major else (255, 0, 0, 60),
                width=3 if major else 1)
        if major:
            dr.text((x + 4, 10), f"{k * a.step}", fill=(255, 0, 0, 255), font=font)
    for k in range(int(math.ceil((0 - oy) / step_px)), int(math.floor((h - oy) / step_px)) + 1):
        y = oy + k * step_px
        major = (k % 5 == 0)
        dr.line([(0, y), (w, y)], fill=(0, 0, 255, 150) if major else (0, 0, 255, 60),
                width=3 if major else 1)
        if major:
            dr.text((10, y + 4), f"{k * a.step}", fill=(0, 0, 255, 255), font=font)
    save_img(img, a.out)


def cmd_mask(a: argparse.Namespace) -> None:
    """Largest low-saturation blob = the metal housing; prints its bbox."""
    img = load(a.image).convert("RGB")
    x0, y0, x1, y1 = parse_box(a.box) if a.box else (0, 0, img.width, img.height)
    arr = np.asarray(img.crop((x0, y0, x1, y1)), dtype=np.float32)
    mx = arr.max(axis=2)
    mn = arr.min(axis=2)
    sat = (mx - mn) / np.maximum(mx, 1.0)
    m = (sat < a.sat) & (mx < 255.0 * a.val)
    K = a.down
    h, w = m.shape
    H, W = h // K, w // K
    mc = m[:H * K, :W * K].reshape(H, K, W, K).mean(axis=(1, 3)) > 0.5
    for _ in range(a.clean):
        mc = (mc & np.roll(mc, 1, 0) & np.roll(mc, -1, 0) &
              np.roll(mc, 1, 1) & np.roll(mc, -1, 1))
    from collections import deque
    lab = np.full((H, W), -1, dtype=np.int32)
    best_n, best_box, cur = 0, None, 0
    for i in range(H):
        for j in range(W):
            if mc[i, j] and lab[i, j] < 0:
                cur += 1
                q = deque([(i, j)])
                lab[i, j] = cur
                n = 0
                minx = maxx = j
                miny = maxy = i
                while q:
                    y, x = q.popleft()
                    n += 1
                    if x < minx: minx = x
                    if x > maxx: maxx = x
                    if y < miny: miny = y
                    if y > maxy: maxy = y
                    for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        yy, xx = y + dy, x + dx
                        if 0 <= yy < H and 0 <= xx < W and mc[yy, xx] and lab[yy, xx] < 0:
                            lab[yy, xx] = cur
                            q.append((yy, xx))
                if n > best_n:
                    best_n, best_box = n, (minx, miny, maxx, maxy)
    if best_box is None:
        print("no blob found - adjust --sat / --val / --clean")
        return
    bx0 = x0 + best_box[0] * K
    by0 = y0 + best_box[1] * K
    bx1 = x0 + (best_box[2] + 1) * K
    by1 = y0 + (best_box[3] + 1) * K
    print(f"largest blob: {best_n * K * K} px^2 (coarse grid {K}px cells)")
    print(f"  bbox x {bx0}..{bx1}  ({bx1 - bx0} px)    y {by0}..{by1}  ({by1 - by0} px)")
    if a.out:
        mimg = Image.fromarray((mc * 255).astype(np.uint8)).resize((w, h), Image.NEAREST)
        save_img(mimg, a.out)
    if a.overlay:
        arr3 = np.asarray(img).copy()
        mfull = np.asarray(Image.fromarray((mc * 255).astype(np.uint8)).resize((w, h), Image.NEAREST))
        reg = arr3[y0:y1, x0:x1]
        sel = mfull > 0
        reg[sel] = (0.55 * reg[sel] + 0.45 * np.array([255, 0, 0])).astype(np.uint8)
        save_img(Image.fromarray(arr3), a.overlay)


def cmd_ticks(a: argparse.Namespace) -> None:
    """Detect scale ticks in a strip (dark rows/cols) and report their spacing."""
    img = load(a.image).convert("L")
    x0, y0, x1, y1 = parse_box(a.box)
    arr = np.asarray(img, dtype=np.float32)[y0:y1, x0:x1]
    if a.axis == "x":
        arr = arr.T
    dark = arr < a.dark
    rowdark = dark.sum(axis=1)
    rows = np.nonzero(rowdark >= a.minlen)[0]
    groups: list[list[int]] = []
    for r in rows:
        if groups and r - groups[-1][-1] <= a.gap_px:
            groups[-1].append(int(r))
        else:
            groups.append([int(r)])
    centres = [(g[0] + g[-1]) / 2.0 for g in groups]
    lengths = [int(rowdark[g].max()) for g in groups]
    print(f"{len(centres)} marks in box {a.box} (axis {a.axis})")
    print("centres  :", " ".join(f"{c:.0f}" for c in centres[:40]))
    if len(centres) > 1:
        gaps = np.diff(centres)
        print("gaps px  :", " ".join(f"{g:.1f}" for g in gaps[:40]))
        print("clusters :", ", ".join(f"{gap:.1f}px x{n}" for gap, n in gap_clusters(gaps)[:6]))
        print("lengths  :", " ".join(str(v) for v in lengths[:40]))
    if a.pxmm:
        print("mm from start:", " ".join(f"{c / a.pxmm:.1f}" for c in centres[:40]))


def cmd_measure(a: argparse.Namespace) -> None:
    pxmm = a.pxmm or (a.pxcm / 10.0 if a.pxcm else None)
    if not pxmm:
        sys.exit("need --pxmm or --pxcm")
    dx = a.p2[0] - a.p1[0]
    dy = a.p2[1] - a.p1[1]
    dist = math.hypot(dx, dy)
    print(f"pixel distance {dist:.2f} px  ->  {dist / pxmm:.2f} mm")
    print(f"  dx {dx / pxmm:+.2f} mm   dy {dy / pxmm:+.2f} mm")


def cmd_profile(a: argparse.Namespace) -> None:
    img = load(a.image)
    g = img_gray(img)
    x0, y0, x1, y1 = parse_box(a.box) if a.box else (0, 0, img.width, img.height)
    if a.axis == "x":
        sig = g[y0:y1, x0:x1].mean(axis=0)
        base = x0
    else:
        sig = g[y0:y1, x0:x1].mean(axis=1)
        base = y0
    if a.step > 1:
        for i in range(0, len(sig), a.step):
            print(f"  {base + i:6d}  {sig[i]:7.1f}")
    if a.edges:
        grad = np.abs(np.diff(sig))
        thr = grad.mean() + a.k * grad.std()
        idx = np.where(grad > thr)[0]
        merged: list[int] = []
        for i in idx:
            if merged and i - merged[-1] <= a.merge:
                merged[-1] = i
            else:
                merged.append(int(i))
        print("edge positions (sharp changes):")
        for i in merged:
            mm = (base + i - a.origin) / a.pxmm if a.pxmm else float("nan")
            print(f"  px {base + i:6d}   mm {mm:9.2f}   (grad {grad[i]:.1f})")


def cmd_sheet(a: argparse.Namespace) -> None:
    flip = set(a.flip) if a.flip else set()
    cells = []
    for i, p in enumerate(a.images, start=1):
        im = load(p).convert("RGB")
        if i in flip:
            im = ImageOps.mirror(im)
        w = max(1, round(im.width * a.height / im.height))
        cells.append((p, im.resize((w, a.height), Image.LANCZOS)))
    gap = 18
    label_h = 0 if a.no_labels else 36
    W = sum(c.width for _, c in cells) + gap * (len(cells) - 1)
    H = a.height + label_h
    sheet = Image.new("RGB", (W, H), (255, 255, 255))
    dr = ImageDraw.Draw(sheet)
    font = _font(24)
    x = 0
    for p, c in cells:
        sheet.paste(c, (x, label_h))
        if not a.no_labels:
            dr.text((x + 10, 6), p, fill=(0, 0, 0), font=font)
        x += c.width + gap
    save_img(sheet, a.out)


# --------------------------------------------------------------------- CLI

def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("info", help="image sizes")
    p.add_argument("images", nargs="+")
    p.set_defaults(fn=cmd_info)

    p = sub.add_parser("autocalib", help="find rule ticks, derive px/mm")
    p.add_argument("image")
    p.add_argument("--box", required=True, help="strip containing the rule, x0,y0,x1,y1")
    p.add_argument("--axis", choices=("x", "y"), default="y",
                   help="axis ALONG the rule (default y)")
    p.add_argument("--min-gap", type=float, default=6.0, help="merge marks closer than this (px)")
    p.add_argument("--thresh", type=float, default=1.0, help="darkness threshold in sigma")
    p.set_defaults(fn=cmd_autocalib)

    p = sub.add_parser("crop", help="crop/rotate/zoom")
    p.add_argument("image")
    p.add_argument("--box", help="x0,y0,x1,y1")
    p.add_argument("--rotate", type=float, default=0, help="degrees CCW")
    p.add_argument("--zoom", type=float, default=1.0)
    p.add_argument("--out")
    p.set_defaults(fn=cmd_crop)

    p = sub.add_parser("tile", help="overlapping tiles of an image")
    p.add_argument("image")
    p.add_argument("--outdir", required=True)
    p.add_argument("--size", type=int, default=1600)
    p.add_argument("--overlap", type=int, default=200)
    p.set_defaults(fn=cmd_tile)

    p = sub.add_parser("grid", help="overlay calibrated mm grid")
    p.add_argument("image")
    p.add_argument("--pxmm", type=float, required=True)
    p.add_argument("--origin", type=parse_point, default=(0, 0), help="pixel of mm 0,0")
    p.add_argument("--step", type=float, default=10.0, help="mm between lines")
    p.add_argument("--out", required=True)
    p.set_defaults(fn=cmd_grid)

    p = sub.add_parser("measure", help="pixel points -> mm")
    p.add_argument("image")
    p.add_argument("--p1", type=parse_point, required=True)
    p.add_argument("--p2", type=parse_point, required=True)
    p.add_argument("--pxmm", type=float)
    p.add_argument("--pxcm", type=float)
    p.set_defaults(fn=cmd_measure)

    p = sub.add_parser("profile", help="intensity profile / edge finder")
    p.add_argument("image")
    p.add_argument("--box")
    p.add_argument("--axis", choices=("x", "y"), default="y")
    p.add_argument("--step", type=int, default=64, help="print every N px (0 = no dump)")
    p.add_argument("--edges", action="store_true")
    p.add_argument("--k", type=float, default=2.0, help="edge threshold in sigma")
    p.add_argument("--merge", type=int, default=6)
    p.add_argument("--pxmm", type=float, help="needed to print mm positions")
    p.add_argument("--origin", type=float, default=0, help="px position of mm 0")
    p.set_defaults(fn=cmd_profile)

    p = sub.add_parser("findrule", help="scan for the scale rule and report tick spacing")
    p.add_argument("image")
    p.add_argument("--box", required=True, help="region to scan, x0,y0,x1,y1")
    p.add_argument("--axis", choices=("x", "y"), default="y", help="axis ALONG the rule")
    p.add_argument("--step", type=int, default=24, help="scan step across the rule (px)")
    p.add_argument("--band", type=int, default=8, help="averaging band width (px)")
    p.add_argument("--min-gap", type=float, default=4.0, help="merge marks closer than this (px)")
    p.add_argument("--thresh", type=float, default=0.8, help="darkness threshold in sigma")
    p.add_argument("--top", type=int, default=5, help="candidate lines to print")
    p.add_argument("--out", help="save a crop showing the best line and detected marks")
    p.set_defaults(fn=cmd_findrule)

    p = sub.add_parser("mask", help="silhouette extraction by saturation threshold")
    p.add_argument("image")
    p.add_argument("--box", help="x0,y0,x1,y1 (default whole image)")
    p.add_argument("--sat", type=float, default=0.22, help="max saturation for 'metal/silver'")
    p.add_argument("--val", type=float, default=0.97, help="max brightness (avoid blown-out floor)")
    p.add_argument("--down", type=int, default=8, help="working downsample factor")
    p.add_argument("--clean", type=int, default=2, help="erosion passes on the coarse mask")
    p.add_argument("--out", help="save binary mask png")
    p.add_argument("--overlay", help="save mask overlay png")
    p.set_defaults(fn=cmd_mask)

    p = sub.add_parser("ticks", help="detect scale ticks in a strip, report spacing")
    p.add_argument("image")
    p.add_argument("--box", required=True, help="x0,y0,x1,y1")
    p.add_argument("--axis", choices=("x", "y"), default="y", help="direction the ticks repeat in")
    p.add_argument("--dark", type=float, default=120.0, help="darkness threshold 0-255")
    p.add_argument("--minlen", type=int, default=2, help="min dark pixels across the tick")
    p.add_argument("--gap-px", type=int, default=2, help="merge tick rows within this many px")
    p.add_argument("--pxmm", type=float, help="also print positions in mm")
    p.set_defaults(fn=cmd_ticks)

    p = sub.add_parser("sheet", help="side-by-side comparison sheet")
    p.add_argument("images", nargs="+")
    p.add_argument("--height", type=int, default=900)
    p.add_argument("--flip", type=lambda s: [int(v) for v in s.split(",")],
                   help="1-based image indices to mirror horizontally")
    p.add_argument("--no-labels", action="store_true")
    p.add_argument("--out", required=True)
    p.set_defaults(fn=cmd_sheet)

    a = ap.parse_args()
    a.fn(a)


if __name__ == "__main__":
    main()
