# Project Ground Rules — 3D Printing OpenSCAD Models

## Standalone files only

Every `.scad` file must be **completely self-contained**.
- No `use <other.scad>` or `include <other.scad>` between project files.
- A `.scad` file defines its own parameters, derived variables, modules, and render logic.
- If a file was previously split (e.g. a "parent" and a "sliced" variant), merge the parent's geometry into the variant and delete the parent.

## File structure

A single `.scad` file contains:
1. **Header comment** — what the model is, coordinate system, units.
2. **Customizer parameters** — grouped under `/* [Category] */` comments.
3. **Derived variables** — computed from the parameters.
4. **Modules** — all geometry modules defined locally.
5. **Render section** — an `if/else` chain on a `part` variable.

## Part selector

The `part` variable controls what renders:

```openscad
part = "both";  // bottom | top | both | exploded
```

- `"bottom"` — lower half only (print orientation).
- `"top"` — upper half only (print orientation).
- `"both"` — assembled, for fit checking.
- `"exploded"` — pieces laid flat on the XY plane, arranged to fit a 270×270 mm bed, with a visible gap between parts.

## Exploded view layout

For two-piece models, the exploded view places both pieces **flat on the print bed**:
- Bottom piece: natural orientation (floor down).
- Top piece: upside-down (brim/flat-top down).
- Flat back walls face each other across a small gap (typically 5 mm).
- Curved fronts point outward to opposite bed edges.
- The layout must fit within a 270 × 270 mm rectangle centred at the origin.

## Design considerations

Consider the stresses a printed item may need to withstand (shear, tensile, compaction etc), and orient the
model accordingly. We must however tr and avoid supports when printing if possible. If the stresses are
such that a single orientation will not suffice, then split the model into components that can be assembled.
