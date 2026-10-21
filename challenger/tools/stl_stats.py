#!/usr/bin/env python3
"""Binary STL statistics: bounding box, volume, area, triangle count.

Examples
--------
python tools/stl_stats.py renders/charger73_housing_L.stl
python tools/stl_stats.py renders/charger73_section1.stl renders/charger73_section2.stl
python tools/stl_stats.py --mirror-pair renders/charger73_housing_L.stl renders/charger73_housing_R.stl
"""

from __future__ import annotations

import argparse
import struct
from pathlib import Path

import numpy as np

REC = np.dtype([("n", "<f4", 3), ("v", "<f4", (3, 3)), ("attr", "<u2")])


def read_stl(path: str) -> np.ndarray:
    """Return an (n, 3, 3) float64 vertex array (binary or ASCII STL)."""
    raw = Path(path).read_bytes()
    if len(raw) < 84:
        raise SystemExit(f"{path}: too small to be an STL")
    count = struct.unpack_from("<I", raw, 80)[0]
    if raw[:5] == b"solid" and 84 + count * 50 != len(raw):
        import re
        nums = re.findall(r"vertex\s+(\S+)\s+(\S+)\s+(\S+)", raw.decode("ascii", "ignore"))
        v = np.array(nums, dtype=np.float64)
        if v.ndim != 2 or v.shape[1] != 3:
            raise SystemExit(f"{path}: could not parse as ASCII STL")
        return v.reshape(-1, 3, 3)
    data = np.frombuffer(raw, dtype=REC, count=count, offset=84)
    if len(data) != count:
        raise SystemExit(f"{path}: truncated (expected {count} triangles, got {len(data)})")
    return data["v"].astype(np.float64)


def stats(v: np.ndarray) -> dict:
    v0, v1, v2 = v[:, 0], v[:, 1], v[:, 2]
    flat = v.reshape(-1, 3)
    amin, amax = flat.min(axis=0), flat.max(axis=0)
    cross = np.cross(v1 - v0, v2 - v0)
    area = 0.5 * np.linalg.norm(cross, axis=1)
    vol = float(np.einsum("ij,ij->i", v0, np.cross(v1, v2)).sum() / 6.0)
    return dict(
        n=len(v),
        min=amin,
        max=amax,
        size=amax - amin,
        area=float(area.sum()),
        vol=abs(vol),
        degen=int((area < 1e-9).sum()),
    )


def show(path: str) -> dict:
    s = stats(read_stl(path))
    mn, mx, sz = s["min"], s["max"], s["size"]
    print(f"{path}")
    print(f"  triangles : {s['n']}   (degenerate: {s['degen']})")
    print(f"  bbox min  : {mn[0]:9.2f} {mn[1]:9.2f} {mn[2]:9.2f} mm")
    print(f"  bbox max  : {mx[0]:9.2f} {mx[1]:9.2f} {mx[2]:9.2f} mm")
    print(f"  size      : {sz[0]:9.2f} {sz[1]:9.2f} {sz[2]:9.2f} mm   (x * y * z)")
    print(f"  volume    : {s['vol'] / 1000.0:8.2f} cm3   surface {s['area'] / 100.0:8.2f} cm2")
    return s


def mirror_pair(pa: str, pb: str) -> None:
    a, b = stats(read_stl(pa)), stats(read_stl(pb))
    ok = True

    def chk(name: str, x: float, y: float, tol: float = 0.05) -> None:
        nonlocal ok
        good = abs(x - y) <= tol
        ok = ok and good
        print(f"  {name:20s} {x:10.3f} vs {y:10.3f}   {'OK' if good else 'MISMATCH'}")

    print(f"mirror check: {pa}  vs  {pb}   (expect same size, x reflected)")
    chk("size x", a["size"][0], b["size"][0])
    chk("size y", a["size"][1], b["size"][1])
    chk("size z", a["size"][2], b["size"][2])
    chk("min_x + max_x", a["min"][0] + b["max"][0], 0.0)
    chk("max_x + min_x", a["max"][0] + b["min"][0], 0.0)
    chk("min_y + min_y'", a["min"][1], b["min"][1])
    chk("min_z + min_z'", a["min"][2], b["min"][2])
    chk("triangles", a["n"], b["n"], 0)
    print("  => " + ("PASS" if ok else "FAIL"))


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("stls", nargs="+")
    ap.add_argument("--mirror-pair", action="store_true",
                    help="exactly two files: verify they are x-mirrors")
    a = ap.parse_args()
    if a.mirror_pair:
        if len(a.stls) != 2:
            raise SystemExit("--mirror-pair needs exactly two STL files")
        mirror_pair(a.stls[0], a.stls[1])
    else:
        for p in a.stls:
            show(p)


if __name__ == "__main__":
    main()
