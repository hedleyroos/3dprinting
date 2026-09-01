# ============================================================
# Export every model to a 3MF, predictably.
#
#   make drawer_divider      # export one model
#   make                     # export every model
#   make list                # show the part each model exports as
#   make clean               # delete the exported 3MFs
#
# Name a model on its own — `make drawer_divider` — or name the file,
# `make drawer_divider.3mf`. Either way the export ALWAYS re-runs: the
# 3MF you get is built from the .scad as it is right now, never a
# leftover from an earlier run. Nothing is ever reported "up to date".
# The whole repo exports in a couple of seconds, so there is nothing
# to gain from skipping work and plenty to lose from printing a stale
# plate.
#
# Every piece the chosen part renders arrives as its own object on the
# plate, so you can arrange and configure them independently. (If you
# instead want several pieces fused into ONE object with per-part
# filament — a two-colour print of a single thing — that is what
# make_multipart_3mf.py is for.)
#
# Each model is exported with make_separate_3mf.py, which runs
# openscad --enable=lazy-union so the top-level objects stay SEPARATE
# objects on the plate instead of being unioned into one mesh.
#
# WHICH PART GETS EXPORTED
# Most models have a `part` variable selecting what renders, and the
# value that means "the print layout" differs from file to file —
# printplate, plate, exploded, print, jig, cushion... The table below
# pins one value per model so an export is reproducible instead of
# depending on whatever the file was last left set to.
#
# A model with no entry is exported with no -D at all, so it uses its
# own default. Add a line here when you want a different one, or
# override for a single run without editing anything:
#
#   make PART_drawer_divider=left drawer_divider.3mf
#
# NOTE: the 3MFs land next to the .scad files, which is where this
# repo already keeps them (they are gitignored). If you have saved a
# SLICER project over one of these names, `make` will overwrite it —
# build somewhere else instead:
#
#   make OUTDIR=/tmp/plates
# ============================================================

OPENSCAD ?= openscad
EXPORT   := ./make_separate_3mf.py
OUTDIR   ?= .

# ------------------------------------------------------------
# Per-model part selection
# ------------------------------------------------------------
PART_avo_seed_rings           := plate
PART_beam_corner_jig          := jig
PART_champagne_bottle_tray    := cushion
PART_drawer_divider           := exploded
PART_epoxy_spike_stand        := printplate
PART_ginos                    := printplate
PART_handbag_scroll_hook      := print
PART_headboard_frame_brackets := printplate
PART_logo_print               := body
PART_logo_test                := body
PART_magnet_pill_container    := exploded
PART_mesh_box                 := exploded
PART_mesh_box_eco             := exploded
PART_mesh_box_lattice         := exploded
PART_mesh_box_rounded_sliced  := exploded
PART_orthotic_insole          := printplate
PART_rpi5_case                := printplate
PART_saw_guide_jig            := printplate
PART_serpentine_egg_dispenser := exploded
PART_single_egg_dispenser     := plate
PART_socket_cover_solid       := exploded
PART_wine_bottle_tray         := cushion
PART_wineglass_cage           := print

# ------------------------------------------------------------
# Rules
# ------------------------------------------------------------
SCAD    := $(wildcard *.scad)
MODELS  := $(basename $(SCAD))
TARGETS := $(addprefix $(OUTDIR)/,$(addsuffix .3mf,$(MODELS)))

# The part for model $(1), empty when the table has no entry.
part = $(PART_$(1))

.PHONY: all list clean FORCE $(MODELS)
.DELETE_ON_ERROR:   # a failed export must not leave a stale 3MF behind

all: $(TARGETS)

# `make drawer_divider` — the bare model name builds that model's 3MF.
$(MODELS): %: $(OUTDIR)/%.3mf
	@:

# FORCE has no recipe and is phony, so it is never satisfied and this
# rule fires every time. That is deliberate: an export is cheap and a
# silently skipped one means printing yesterday's geometry.
FORCE:

$(OUTDIR)/%.3mf: %.scad $(EXPORT) FORCE | $(OUTDIR)
	$(EXPORT) $< $@ --openscad $(OPENSCAD) $(if $(call part,$*),-D part=$(call part,$*))

# Only created when OUTDIR is somewhere other than here.
$(OUTDIR):
	mkdir -p $@

list:
	@$(foreach m,$(MODELS),printf '%-32s %s\n' '$(m)' '$(or $(call part,$(m)),(file default))';)

clean:
	rm -f $(TARGETS)
