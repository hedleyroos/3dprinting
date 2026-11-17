# ============================================================
# medicine/Makefile — export the medicine tray's six bins.
#
#   make                    # every bin, solid walls -> bin_<n>.3mf
#   make hex                # every bin, hex-mesh walls -> bin_<n>_hex.3mf
#   make bin_3              # one bin (bin_3_hex for the hex version)
#   make joint_test         # joint fit test -> joint_test.3mf (print first)
#   make renders            # assembly + bin PNGs -> renders/
#   make list               # the bins and their labels
#   make clean              # delete the exported 3MFs
#
# Same rules as the root Makefile (which only globs the repo root, so
# it never sees this folder):
#   * every export ALWAYS re-runs — a skipped export means printing
#     yesterday's geometry (or yesterday's label text);
#   * the object is named in the 3MF (make_separate_3mf.py);
#   * 3MFs are gitignored repo-wide. If you saved a slicer project over
#     one of these names, build elsewhere: make OUTDIR=/tmp/bins
#
# One bin per plate, six prints for the tray, plus the joint test.
# Label text comes from label_1 .. label_6 in medicine_tray.scad.
#
# The superseded two-tier rack (medicine_rack.scad) has no targets
# here; export it by hand if ever needed.
# ============================================================

OPENSCAD ?= openscad
EXPORT   := ../make_separate_3mf.py
SCAD     := medicine_tray.scad
OUTDIR   ?= .
RENDERS  := renders

BINS     := bin_1 bin_2 bin_3 bin_4 bin_5 bin_6
HEX_BINS := $(addsuffix _hex,$(BINS))
VIEWS    := assembly assembly_pulled assembly_exploded
PNGS     := $(addprefix $(RENDERS)/,$(addsuffix .png,$(VIEWS) bin_1 bin_2 joint_test \
                assembly_pulled_hex bin_1_hex))

# Camera per render: eye x,y,z,centre x,y,z. Assemblies are previews
# (colours + the % shelf ghost); bins and the joint test are full
# renders. bin_2 is seen from behind-left, its two open sides.
CAM_assembly          := 430,-780,680,0,250,70
CAM_assembly_pulled   := 430,-1020,680,0,20,70
CAM_assembly_exploded := 650,-950,820,0,280,170
CAM_bin_1             := 330,-460,420,0,0,70
CAM_bin_2             := -360,330,360,0,0,70
CAM_joint_test        := 70,-75,65,0,0,6

.PHONY: all hex joint_test renders list clean FORCE $(BINS) $(HEX_BINS)
.DELETE_ON_ERROR:

all: $(addprefix $(OUTDIR)/,$(addsuffix .3mf,$(BINS)))

hex: $(addprefix $(OUTDIR)/,$(addsuffix .3mf,$(HEX_BINS)))

$(BINS) $(HEX_BINS) joint_test: %: $(OUTDIR)/%.3mf
	@:

FORCE:

# (make picks the rule with the shorter stem, so bin_1_hex.3mf uses the
# second rule, with stem bin_1)
$(OUTDIR)/%.3mf: $(SCAD) $(EXPORT) FORCE | $(OUTDIR)
	$(EXPORT) $(SCAD) $@ --openscad $(OPENSCAD) -D part=$* --names "tray $(subst _, ,$*)"

$(OUTDIR)/%_hex.3mf: $(SCAD) $(EXPORT) FORCE | $(OUTDIR)
	$(EXPORT) $(SCAD) $@ --openscad $(OPENSCAD) -D part=$* -D wall_style=hex \
	    --names "tray $(subst _, ,$*) hex"

$(OUTDIR):
	mkdir -p $@

renders: $(PNGS)

# (the folder is made in the recipe: a `renders` dir target would clash
# with the phony `renders` goal above). --render takes an optional
# argument, so it must come before -o, never right before $(SCAD).
$(RENDERS)/%.png: $(SCAD) FORCE
	@mkdir -p $(@D)
	$(OPENSCAD) $(if $(filter bin_% joint_test,$*),--render) -o $@ -D 'part="$*"' \
	    --imgsize=1600,1200 --colorscheme=Tomorrow --camera=$(CAM_$*) $(SCAD)

$(RENDERS)/%_hex.png: $(SCAD) FORCE
	@mkdir -p $(@D)
	$(OPENSCAD) $(if $(filter bin_%,$*),--render) -o $@ -D 'part="$*"' -D 'wall_style="hex"' \
	    --imgsize=1600,1200 --colorscheme=Tomorrow --camera=$(CAM_$*) $(SCAD)

list:
	@grep -E '^label_[1-6] ' $(SCAD) | sed -E 's/^label_([1-6]) *= *("[^"]*");[ /]*(.*)/bin_\1  \2  (\3)/'

clean:
	rm -f $(addprefix $(OUTDIR)/,$(addsuffix .3mf,$(BINS) $(HEX_BINS) joint_test))
