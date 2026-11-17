# OrcaSlicer presets: Qidi Q2, 0.4 nozzle

Cleaned up 2026-11-17 from the `.orca_printer` exports. These presets **only rename and merge** the old
ones. Every setting is unchanged, and re-slicing a test part gives the same grams and time.

## How the presets are organised

Pick each dropdown for its own reason:

| Dropdown | Choose by | Options |
|---|---|---|
| **Printer** | Never changes | `Qidi Q2 0.4 nozzle @Q2 0.4`: the stock `Qidi Q2 0.4 nozzle` plus the printer's network address, and nothing else. Orca keeps the address in the printer preset, and a stock preset can't hold it. Not in this folder, because of that address. |
| **Filament** | The spool that's loaded | `SUNLU PLA+ 2.0 @Q2 0.4`, `Creality ABS @Q2 0.4`, `Generic PLA @Q2 0.4` |
| **Process** | How good it must look | Stock `0.20mm Standard @Qidi Q2` for everyday prints, then `0.20mm Strong @Q2 0.4`, `0.12mm Detail @Q2 0.4` and `0.24mm Vase @Q2 0.4` |

**Naming rule:** every preset of yours ends in `@Q2 0.4`. Anything ending in `@Qidi Q2…` or `@System` is
Orca's stock preset. Process names start with the real layer height.

| Process | What it is | One medicine-tray bin* |
|---|---|---|
| `0.20mm Standard @Qidi Q2` (stock) | Everyday: 2 walls, 15 % grid infill, 200/300 mm/s walls | 3 h 15 min |
| `0.20mm Strong @Q2 0.4` | 5 walls, 30 % gyroid, ironed tops, 120/200 mm/s walls | 4 h 50 min |
| `0.12mm Detail @Q2 0.4` | 0.12 mm layers, 50 mm/s outer wall at 500 mm/s², ironed tops | 11 h 30 min |
| `0.24mm Vase @Q2 0.4` | Spiral vase mode, single wall | n/a |

\* The first, 60 mm-high bin, sliced with `SUNLU PLA+ 2.0 @Q2 0.4`. The current tray is in
`medicine/PLAN.md`.

## Old name to new name

| Old | New |
|---|---|
| `0.20mm Standard @Qidi Q2 - Quality` | `0.12mm Detail @Q2 0.4` (it was always 0.12 mm layers) |
| `0.20mm Standard @Qidi Q2 - Quality + Strength` | `0.20mm Strong @Q2 0.4` |
| `0.20mm Standard @Qidi Q2 - Vase` | `0.24mm Vase @Q2 0.4` |
| `SUNLU PLA+ 2.0 Tuned` | `SUNLU PLA+ 2.0 @Q2 0.4` |
| `Creality ABS - Tuned` | `Creality ABS @Q2 0.4` |
| `Creality ABS 0.4 Slow - Tuned` | merged into `Creality ABS @Q2 0.4` (it was identical) |
| `Generic ABS @Qidi Q2 0.4 nozzle - Copy` | merged into `Creality ABS @Q2 0.4` (same settings, minus the tuned pressure advance) |
| `Generic PLA @Qidi Q2 0.4 nozzle - Copy` | `Generic PLA @Q2 0.4` |
| Printer `Qidi Q2 0.4 nozzle - Copy` | `Qidi Q2 0.4 nozzle @Q2 0.4` (renamed; stock plus the network address) |
| Printer `Qidi Q2 0.4 nozzle - Slower` | merged into `Qidi Q2 0.4 nozzle @Q2 0.4`; see the note on retraction below |

Done on 2026-11-17: the six presets were imported, `- Copy` was renamed, and the old presets were moved to
a backup folder outside the repo.

## Steps, for a fresh Orca install

1. **Import:** in Orca, **File → Import → Import Configs…**, open `orca_q2_presets/` and select all six
   `.json` files.
2. **Printer:** select stock `Qidi Q2 0.4 nozzle`, click the connection (Wi-Fi) icon next to the printer
   dropdown, enter the printer's address, and save the preset as `Qidi Q2 0.4 nozzle @Q2 0.4`.
3. **Check** that the new filament and process presets appear under *User presets*.
4. **Re-export a backup:** **File → Export → Export Preset Bundle**. The bundle's printer preset contains
   the network address, so leave that file out of git.

## Command-line slicing (`orca_check.py`)

Every `make` export is sliced by `../orca_check.py`, which reads the model's `// ORCA:` lines for
its presets (see `.github/copilot_instructions.md`) and prints the time, filament and any Orca
warning. It runs the same OrcaSlicer build as the GUI, and handles the CLI's quirks:

- **The CLI ignores `inherits`**, so it fills every key a preset doesn't set itself with a
  default, and the estimates come out badly wrong. The script merges each preset with its whole
  inherits chain first, from Orca's live config (`~/.config/OrcaSlicer/`), falling back to this
  folder.
- **It rejects a user printer** (`Qidi Q2 0.4 nozzle @Q2 0.4`) because the stock presets only
  list `Qidi Q2 0.4 nozzle` as compatible, so the script lists the printer by name on the
  flattened copies.
- **It writes a log file into the current folder**, so the script runs it in a temporary one.

The CLI's bed type defaults to the cool plate, so the G-code's bed temperature isn't what you'd
print with; time and filament don't depend on it.

## Notes

- **Retraction from `- Slower` was not carried over.** That printer was the only place with longer
  retraction: 1.2 mm at 40 mm/s, retract-before-wipe 70 %, and a 0.6 mm normal z-hop. Your everyday
  `- Copy` used the stock 0.8 mm. If a filament strings, put those values in that filament's
  **Setting Overrides** tab rather than in a printer copy.
- **Thin bottoms in `0.12mm Detail`.** It keeps 3 bottom layers, which is only 0.36 mm at 0.12 mm layers.
  Tops are fine, because Orca enforces a 1 mm minimum top thickness. If bottoms look thin, set the Bottom
  shell thickness to 0.6 mm in that preset.
- **Flow cap.** Every filament here caps flow at 12 mm³/s. That is SUNLU's own value, and the ABS was
  lowered from Orca's 17. The cap only matters on Standard, where it limits the walls to about 143 mm/s.
  Run Orca's max-flow calibration before raising it: 18 mm³/s would cut the 160 mm medicine tray from
  32 h 21 to 27 h 22 (25 h 00 with `0.24mm Draft @Qidi Q2`).
- **Git:** `*.json` is in the repo's `.gitignore`, so these six files were force-added (`git add -f`). Being
  tracked, changes to them now show up in git; a new preset needs `git add -f` too.
