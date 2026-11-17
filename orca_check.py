#!/usr/bin/env python3
"""
Slice an exported 3MF with OrcaSlicer's command line and report three things:
which presets to print it with, how long it takes and how much filament it
uses, and whether Orca has any complaint about it.

Every Makefile export runs this after writing the 3MF. A model that Orca warns
about ("floating regions", "large overhangs", "empty layers", ...) fails the
export, so a 3MF you can't print as-is is never left looking ready.

Print settings live in the model
--------------------------------
A model declares its print settings in its own .scad, on one or more header
comment lines starting `// ORCA:`. Each holds shell-style key=value words:

    // ORCA: process="0.20mm Standard @Qidi Q2" filament="SUNLU PLA+ 2.0 @Q2 0.4"
    // ORCA: brim_type=no_brim
    // ORCA: note="filament change at 160.2 mm for two-colour labels"

    printer=, process=, filament=   preset names, exactly as in Orca's dropdowns.
                                    Several filaments: filament="A;B".
    note=                           printed with the settings (repeatable).
    accept=                         a slicer warning that is fine for this model,
                                    matched as a substring (repeatable). Say why
                                    in a comment next to it.
    anything else                   an Orca setting overridden on top of the
                                    presets. The sliced G-code is checked to
                                    show that it took, so a misspelt key fails.

Keys left out take the everyday defaults (DEFAULTS below), and the report
says the model has no ORCA line.

Presets are looked up by name in Orca's live config (your user presets, then
the system ones), then in slicer/orca_q2_presets/ for a machine without them.
Orca's CLI ignores `inherits`, silently using defaults for every key a preset
doesn't set itself, so each preset is flattened through its whole inherits
chain first.

Usage
-----
    ./orca_check.py drawer_divider.3mf --scad drawer_divider.scad
    ./orca_check.py thing.3mf --set brim_type=no_brim      # try a setting
    ORCA=/path/to/OrcaSlicer.AppImage ./orca_check.py thing.3mf

Exit status: 0 = sliced with no warnings (or only accepted ones), 1 = Orca
warned or failed, 2 = bad usage or settings. If OrcaSlicer can't be found it
says so and exits 0, so exports still work on a machine without it.
"""

import argparse
import json
import os
import pathlib
import re
import shlex
import shutil
import subprocess
import sys
import tempfile

REPO = pathlib.Path(__file__).resolve().parent
ORCA_CONFIG = pathlib.Path.home() / ".config/OrcaSlicer"
REPO_PRESETS = REPO / "slicer/orca_q2_presets"
ORCA_GUESSES = [
    "/data4/projects/OrcaSlicer/build/OrcaSlicer_Linux_V2.5.0-dev.AppImage",
    "orca-slicer",
    "OrcaSlicer",
]

DEFAULTS = {
    "printer": "Qidi Q2 0.4 nozzle @Q2 0.4",
    "process": "0.20mm Standard @Qidi Q2",
    "filament": "SUNLU PLA+ 2.0 @Q2 0.4",
}
KINDS = {"printer": "machine", "process": "process", "filament": "filament"}
META_KEYS = set(KINDS) | {"note", "accept"}
TIMEOUT_S = 1800


# The report is collected and printed in one block at the end, so several
# checks running under `make -j` don't interleave their lines.
REPORT = []


def say(line):
    REPORT.append(line)


def fail(msg, code=2):
    say(f"orca_check: ERROR: {msg}")
    sys.exit(code)


# ---------------------------------------------------------------- settings

def read_orca_lines(scad):
    """key=value words from the scad's `// ORCA:` lines, in order."""
    words = []
    for line in pathlib.Path(scad).read_text(errors="replace").splitlines():
        m = re.match(r"\s*//\s*ORCA:\s*(.*)$", line)
        if m:
            try:
                words += shlex.split(m.group(1))
            except ValueError as e:
                fail(f"{scad}: can't parse ORCA line ({e}): {line.strip()}")
    return words


def parse_words(words, where):
    presets, overrides, notes, accept = {}, {}, [], []
    for w in words:
        if "=" not in w:
            fail(f"{where}: '{w}' is not key=value")
        k, v = w.split("=", 1)
        if k == "note":
            notes.append(v)
        elif k == "accept":
            accept.append(v)
        elif k in KINDS:
            presets[k] = v
        else:
            overrides[k] = v
    return presets, overrides, notes, accept


# ---------------------------------------------------------------- presets

def index_presets():
    """name -> [(path, data)], live user presets first, then system, then repo."""
    index = {}
    roots = [ORCA_CONFIG / "user", ORCA_CONFIG / "system", REPO_PRESETS]
    for root in roots:
        if not root.is_dir():
            continue
        for p in sorted(root.rglob("*.json")):
            try:
                d = json.loads(p.read_text())
            except (OSError, ValueError):
                continue
            # presets have a type or a parent; vendor index files have neither
            if isinstance(d, dict) and isinstance(d.get("name"), str) \
                    and ("type" in d or "inherits" in d):
                index.setdefault(d["name"], []).append((p, d))
    return index


def vendor_root(path):
    """system/<Vendor>/... -> system/<Vendor>; anything else -> its parent."""
    parts = path.parts
    if "system" in parts:
        i = parts.index("system")
        if i + 1 < len(parts):
            return pathlib.Path(*parts[: i + 2])
    return path.parent


def pick(index, name, near=None, kind=None):
    cands = index.get(name, [])
    if kind:
        cands = [c for c in cands if c[1].get("type", kind) == kind] or cands
    if not cands:
        return None
    if near is not None:
        for c in cands:
            if vendor_root(c[0]) == vendor_root(near):
                return c
    return cands[0]


def flatten(index, name, kind, near=None, seen=()):
    """The preset with its whole inherits chain merged in (child wins)."""
    if name in seen:
        fail(f"preset inherits loop at '{name}'")
    found = pick(index, name, near, kind)
    if found is None:
        return None
    path, data = found
    parent = data.get("inherits")
    merged = {}
    if parent:
        base = flatten(index, parent, kind, path, seen + (name,))
        if base is None:
            fail(f"preset '{name}' inherits '{parent}', which isn't installed")
        merged.update(base)
    merged.update(data)
    merged.pop("inherits", None)
    merged["from"] = "system"
    return merged


def make_compatible(flat):
    """List the printer as compatible with the process and filaments.

    A user printer (stock plus a network address) has its own name, which
    the stock presets don't list. The GUI follows inherits for that; the
    CLI (builds before Orca's is_compatible_with_printer fix) matches the
    name literally and refuses to slice, even when the list is empty.
    """
    name = flat["printer"]["name"]
    for p in (flat["process"], *flat["filament"]):
        p["compatible_printers"] = [name]
        p["compatible_printers_condition"] = ""
        if "compatible_prints" in p:
            p["compatible_prints"] = []
            p["compatible_prints_condition"] = ""


def apply_overrides(presets, overrides):
    """Put each override into the preset that owns the key (process if none)."""
    for k, v in overrides.items():
        owner = next((p for p in (presets["process"], *presets["filament"], presets["printer"])
                      if k in p), presets["process"])
        targets = presets["filament"] if any(owner is f for f in presets["filament"]) else [owner]
        for t in targets:
            t[k] = [v] if isinstance(t.get(k), list) else v


# ---------------------------------------------------------------- slicing

def find_orca(given):
    for cand in [given, os.environ.get("ORCA"), *ORCA_GUESSES]:
        if not cand:
            continue
        p = shutil.which(cand) or (cand if os.access(cand, os.X_OK) else None)
        if p:
            return p
    return None


def hms(text):
    """'6h 16m 21s' / '1d 2h 3m 4s' -> seconds."""
    mult = {"d": 86400, "h": 3600, "m": 60, "s": 1}
    return sum(int(n) * mult[u] for n, u in re.findall(r"(\d+)\s*([dhms])", text))


def fmt_time(s):
    h, m = divmod(round(s / 60), 60)
    return f"{h} h {m:02d} min" if h else f"{m} min"


def gcode_summary(path):
    head, config = {}, {}
    with open(path, errors="replace") as f:
        in_config = False
        for line in f:
            if not line.startswith(";"):
                continue
            if "CONFIG_BLOCK_START" in line:
                in_config = True
                continue
            m = re.match(r";\s*([^=]+?)\s*=\s*(.*)$", line.rstrip("\n"))
            if m:
                (config if in_config else head)[m.group(1)] = m.group(2)
    mm = sum(float(x) for x in head.get("filament used [mm]", "0").split(",") if x.strip())
    return {
        "time": hms(head.get("estimated printing time (normal mode)", "")),
        "grams": float(head.get("total filament used [g]", 0) or 0),
        "metres": mm / 1000,
        "config": config,
    }


def object_sizes(model):
    """[(name, x, y, z)] for each mesh object in a 3MF; [] for anything else."""
    import zipfile
    try:
        xml = zipfile.ZipFile(model).read("3D/3dmodel.model").decode(errors="replace")
    except (zipfile.BadZipFile, KeyError, OSError):
        return []
    sizes = []
    for obj in re.findall(r"<object\b[^>]*>.*?</object>", xml, re.S):
        v = re.findall(r'<vertex x="([^"]+)" y="([^"]+)" z="([^"]+)"', obj)
        if v:
            name = re.search(r'name="([^"]*)"', obj)
            ext = [max(float(t[i]) for t in v) - min(float(t[i]) for t in v) for i in range(3)]
            sizes.append((name.group(1) if name else "object", *ext))
    return sizes


def bed_size(printer):
    """(x, y, z) of the printable volume, from the printer preset."""
    pts = [tuple(map(float, p.split("x"))) for p in printer.get("printable_area", [])]
    if not pts:
        return None
    return (max(p[0] for p in pts) - min(p[0] for p in pts),
            max(p[1] for p in pts) - min(p[1] for p in pts),
            float(printer.get("printable_height", 0) or 0))


def too_big(model, printer):
    """Objects that can't fit the bed even turned 90 degrees."""
    bed = bed_size(printer)
    if not bed:
        return []
    bx, by, bz = bed
    return [(n, x, y, z, bed) for n, x, y, z in object_sizes(model)
            if z > bz or not ((x <= bx and y <= by) or (y <= bx and x <= by))]


def same_value(want, got):
    norm = lambda s: str(s).strip().strip('"').replace(" ", "")
    return norm(want) == norm(got) or norm(got).split(",")[0] == norm(want)


# ---------------------------------------------------------------- main

def main():
    try:
        return run_check()
    finally:
        if REPORT:
            print("\n".join(REPORT), flush=True)


def run_check():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0],
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("model", help="the 3MF (or STL) to slice")
    ap.add_argument("--scad", help="the .scad it came from, for its `// ORCA:` lines")
    ap.add_argument("--set", action="append", default=[], metavar="KEY=VALUE",
                    help="extra setting on top of the scad's (repeatable)")
    ap.add_argument("--orca", help="OrcaSlicer executable (default: $ORCA, then known paths)")
    args = ap.parse_args()

    model = pathlib.Path(args.model)
    if not model.is_file():
        fail(f"{model}: no such file")
    words = read_orca_lines(args.scad) if args.scad else []
    declared = bool(words)
    presets_named, overrides, notes, accept = parse_words(words + args.set,
                                                          args.scad or "--set")
    names = {k: presets_named.get(k, DEFAULTS[k]) for k in KINDS}

    say(f"orca_check: {model}")
    if not declared:
        where = args.scad or "the model"
        say(f"  settings  defaults ({where} has no `// ORCA:` line)")
    say(f"  printer   {names['printer']}")
    say(f"  filament  {names['filament']}")
    say(f"  process   {names['process']}")
    if overrides:
        say("  override  " + " ".join(f"{k}={v}" for k, v in overrides.items()))
    for n in notes:
        say(f"  note      {n}")

    orca = find_orca(args.orca)
    if orca is None:
        say("  slicer    SKIPPED: OrcaSlicer not found (set ORCA=/path/to/OrcaSlicer)")
        return 0

    index = index_presets()
    flat = {}
    for key, kind in KINDS.items():
        if key == "filament":
            fl = [flatten(index, n, kind) for n in names[key].split(";")]
            missing = [n for n, f in zip(names[key].split(";"), fl) if f is None]
        else:
            fl = flatten(index, names[key], kind)
            missing = [names[key]] if fl is None else []
        if missing:
            fail(f"no {kind} preset named '{missing[0]}' in {ORCA_CONFIG} or {REPO_PRESETS}")
        flat[key] = fl
    make_compatible(flat)
    apply_overrides(flat, overrides)

    with tempfile.TemporaryDirectory(prefix="orca_check_") as tmp:
        tmp = pathlib.Path(tmp)
        files = {}
        for key in ("printer", "process"):
            files[key] = tmp / f"{key}.json"
            files[key].write_text(json.dumps(flat[key], indent=1))
        fil_files = []
        for i, f in enumerate(flat["filament"]):
            fil_files.append(tmp / f"filament_{i}.json")
            fil_files[-1].write_text(json.dumps(f, indent=1))
        out = tmp / "out"
        out.mkdir()
        cmd = [orca, "--datadir", str(tmp / "data"),
               "--load-settings", f"{files['printer']};{files['process']}",
               "--load-filaments", ";".join(map(str, fil_files)),
               "--arrange", "1", "--slice", "0", "--outputdir", str(out),
               str(model.resolve())]
        try:
            run = subprocess.run(cmd, cwd=tmp, capture_output=True, text=True,
                                 timeout=TIMEOUT_S)   # cwd: Orca drops a log there
        except subprocess.TimeoutExpired:
            say(f"  slicer    FAILED: no result after {TIMEOUT_S // 60} min")
            return 1

        result = {}
        rj = out / "result.json"
        if rj.is_file():
            try:
                result = json.loads(rj.read_text())
            except ValueError:
                pass
        gcodes = sorted(out.glob("plate_*.gcode"),
                        key=lambda p: int(re.sub(r"\D", "", p.stem) or 0))
        if result.get("return_code", run.returncode) != 0 or not gcodes:
            err = result.get("error_string") or "no G-code produced"
            say(f"  slicer    FAILED: {err}")
            big = too_big(model, flat["printer"])
            for n, x, y, z, (bx, by, bz) in big:
                say(f"            '{n}' is {x:.0f} x {y:.0f} x {z:.0f} mm: it doesn't fit "
                    f"the {bx:.0f} x {by:.0f} x {bz:.0f} mm print volume")
            if not big:
                for line in (run.stdout + run.stderr).strip().splitlines()[-8:]:
                    say(f"            | {line}")
            return 1

        plates = [gcode_summary(g) for g in gcodes]
        warnings = [w.strip() for pl in result.get("sliced_plates", [])
                    for w in str(pl.get("warning_message", "")).split("\n") if w.strip()]

    total_t = sum(p["time"] for p in plates)
    total_g = sum(p["grams"] for p in plates)
    total_m = sum(p["metres"] for p in plates)
    per_plate = ""
    if len(plates) > 1:
        per_plate = "  [" + ", ".join(f"plate {i + 1}: {fmt_time(p['time'])}, {p['grams']:.0f} g"
                                      for i, p in enumerate(plates)) + "]"
    say(f"  estimate  {fmt_time(total_t)}, {total_g:.1f} g ({total_m:.1f} m){per_plate}")

    # Every override must show up in the G-code's config, or it didn't take.
    bad = []
    cfg = plates[0]["config"]
    for k, v in overrides.items():
        if k not in cfg:
            bad.append(f"{k}: not an Orca setting")
        elif not same_value(v, cfg[k]):
            bad.append(f"{k}: asked for {v}, sliced with {cfg[k]}")
    if bad:
        for b in bad:
            say(f"  override  FAILED: {b}")
        return 1

    accepted = [w for w in warnings if any(a in w for a in accept)]
    rejected = [w for w in warnings if w not in accepted]
    for w in accepted:
        say(f"  slicer    accepted warning: {w}")
    for w in rejected:
        say(f"  slicer    WARNING: {w}")
    if rejected:
        hint = f" in {args.scad}" if args.scad else ""
        say(f"            Fix the model, or if this is fine for it, add "
            f"accept=\"...\" to the `// ORCA:` line{hint} with a comment saying why.")
        return 1
    if not accepted:
        say("  slicer    OK, no warnings")
    return 0


if __name__ == "__main__":
    sys.exit(main())
