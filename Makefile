.PHONY: all
all: \
	subseason-patches \
	sp-resources \
	c-key \
	numguide \
	continue \
	th17perf \
	ctrl-speedup \
	mouse \
	ssa \
	bullet-cap \
	debug-counters \
	sprite-death-fix \

REPO=patches
PERSONAL=personal

.PHONY: update
update:
	cd $(REPO) && ./update.sh

#================================================

TH06_VER = th06.v1.02h
TH07_VER = th07.v1.00b
TH08_VER = th08.v1.00d
TH09_VER = th09.v1.50a
TH095_VER = th095.v1.02a
TH10_VER = th10.v1.00a
TH11_VER = th11.v1.00a
TH12_VER = th12.v1.00b
TH125_VER = th125.v1.00a
TH128_VER = th128.v1.00a
TH13_VER = th13.v1.00c
TH14_VER = th14.v1.00b
TH143_VER = th143.v1.00a
TH15_VER = th15.v1.00b
TH16_VER = th16.v1.00a
TH165_VER = th165.v1.00a
TH17_VER = th17.v1.00b

#================================================

.PHONY: subseason-patches
subseason-patches: .make/subseason-patches.stamp

SUBSEASON_PATCH_TEMPLATE=$(REPO)/subseason_TEMPLATE

.make/subseason-patches.stamp: scripts/gen-subseason-patches.py $(SUBSEASON_PATCH_TEMPLATE)/*
	python3 $< $(SUBSEASON_PATCH_TEMPLATE) --repo $(REPO)
	touch $@

#================================================

SP_RESOURCES_PATCH=$(REPO)/sp_resources

.PHONY: sp-resources
sp-resources: $(SP_RESOURCES_PATCH)/$(TH13_VER).js

$(SP_RESOURCES_PATCH)/th%.js: $(SP_RESOURCES_PATCH)/th%.yaml
	scripts/convert-yaml.py $< >$@

#================================================

C_KEY_PATCH=$(REPO)/c_key

.PHONY: c-key
c-key: $(C_KEY_PATCH)/$(TH17_VER).js

$(C_KEY_PATCH)/th%.js: $(C_KEY_PATCH)/th%.yaml
	scripts/convert-yaml.py $< >$@

#================================================

TH17_PERF_PATCH=$(PERSONAL)/th17perf

.PHONY: th17perf
th17perf: \
	$(TH17_PERF_PATCH)/$(TH17_VER).js \

$(TH17_PERF_PATCH)/th%.js: $(TH17_PERF_PATCH)/th%.yaml
	scripts/convert-yaml.py $< >$@

#================================================

NUMGUIDE_PATCH=$(PERSONAL)/numguide

.PHONY: numguide
numguide: \
	$(NUMGUIDE_PATCH)/$(TH12_VER).js \

$(NUMGUIDE_PATCH)/th%.js: $(NUMGUIDE_PATCH)/th%.yaml
	scripts/convert-yaml.py $< >$@

#================================================

CONTINUE_PATCH=$(REPO)/continue

.PHONY: continue
continue: \
	$(CONTINUE_PATCH)/$(TH10_VER).js \
	$(CONTINUE_PATCH)/$(TH11_VER).js \
	$(CONTINUE_PATCH)/$(TH12_VER).js \

$(CONTINUE_PATCH)/th%.js: $(CONTINUE_PATCH)/th%.yaml
	scripts/convert-yaml.py $< >$@

#================================================

CTRL_SPEEDUP_PATCH=$(REPO)/ctrl_speedup

.PHONY: ctrl-speedup
ctrl-speedup: \
	$(CTRL_SPEEDUP_PATCH)/$(TH10_VER).js \
	$(CTRL_SPEEDUP_PATCH)/$(TH11_VER).js \
	$(CTRL_SPEEDUP_PATCH)/$(TH12_VER).js \
	$(CTRL_SPEEDUP_PATCH)/$(TH128_VER).js \
	$(CTRL_SPEEDUP_PATCH)/$(TH13_VER).js \
	$(CTRL_SPEEDUP_PATCH)/$(TH14_VER).js \
	$(CTRL_SPEEDUP_PATCH)/$(TH15_VER).js \
	$(CTRL_SPEEDUP_PATCH)/$(TH16_VER).js \
	$(CTRL_SPEEDUP_PATCH)/$(TH17_VER).js \

$(CTRL_SPEEDUP_PATCH)/th%.js: $(CTRL_SPEEDUP_PATCH)/binhacks.yaml
	scripts/convert-yaml.py $< >$@ --cfg $$(echo "$(@F)" | cut -f1 -d.)

#================================================

MOUSE_PATCH=$(PERSONAL)/mouse

.PHONY: mouse
mouse: \
	$(MOUSE_PATCH)/$(TH14_VER).js \
	# $(MOUSE_PATCH)/$(TH10_VER).js \
	# $(MOUSE_PATCH)/$(TH11_VER).js \
	# $(MOUSE_PATCH)/$(TH12_VER).js \
	# $(MOUSE_PATCH)/$(TH128_VER).js \
	# $(MOUSE_PATCH)/$(TH13_VER).js \
	# $(MOUSE_PATCH)/$(TH15_VER).js \
	# $(MOUSE_PATCH)/$(TH16_VER).js \
	# $(MOUSE_PATCH)/$(TH17_VER).js \

$(MOUSE_PATCH)/th%.js: $(MOUSE_PATCH)/th%.yaml
	scripts/convert-yaml.py $< >$@

#================================================

SSA_PATCH=$(PERSONAL)/ssa

.PHONY: ssa
ssa: \
	$(SSA_PATCH)/$(TH11_VER).js \
	$(SSA_PATCH)/$(TH14_VER).js \

$(SSA_PATCH)/common.yaml: $(SSA_PATCH)/common.asm
	echo "# this yaml file is auto-generated" >$@
	echo "codecaves:" >>$@
	echo "  protection: 64" >>$@
	scripts/list-asm $< >>$@

$(SSA_PATCH)/th%.js: $(SSA_PATCH)/th%.yaml $(SSA_PATCH)/common.yaml
	scripts/convert-yaml.py $^ >$@

#================================================

BULLET_CAP_PATCH=$(REPO)/bullet_cap

.PHONY: bullet-cap
bullet-cap: \
	$(BULLET_CAP_PATCH)/global.js \
	$(BULLET_CAP_PATCH)/$(TH10_VER).js \
	$(BULLET_CAP_PATCH)/$(TH11_VER).js \

$(BULLET_CAP_PATCH)/global.yaml: $(BULLET_CAP_PATCH)/global.asm
	echo "# this yaml file is auto-generated" >$@
	echo "codecaves:" >>$@
	scripts/list-asm $< >>$@

$(BULLET_CAP_PATCH)/global.js: $(BULLET_CAP_PATCH)/global.yaml
	scripts/convert-yaml.py $^ >$@

$(BULLET_CAP_PATCH)/th%.js: $(BULLET_CAP_PATCH)/th%.yaml
	scripts/convert-yaml.py $^ >$@

#================================================

DEBUG_COUNTERS_PATCH=$(REPO)/debug_counters

.PHONY: debug-counters
debug-counters: \
	$(DEBUG_COUNTERS_PATCH)/global.js \
	$(DEBUG_COUNTERS_PATCH)/$(TH10_VER).js \
	# $(DEBUG_COUNTERS_PATCH)/$(TH11_VER).js \

$(DEBUG_COUNTERS_PATCH)/global.yaml: $(DEBUG_COUNTERS_PATCH)/global.asm
	echo "# this yaml file is auto-generated" >$@
	echo "codecaves:" >>$@
	scripts/list-asm $< >>$@

$(DEBUG_COUNTERS_PATCH)/global.js: $(DEBUG_COUNTERS_PATCH)/global.yaml
	scripts/convert-yaml.py $^ >$@

$(DEBUG_COUNTERS_PATCH)/th%.js: $(DEBUG_COUNTERS_PATCH)/th%.yaml
	scripts/convert-yaml.py $^ >$@


#================================================

SPRITE_DEATH_PATCH=$(REPO)/sprite_death_fix

.PHONY: sprite-death-fix
sprite-death-fix: \
	$(SPRITE_DEATH_PATCH)/$(TH10_VER).js \
	# $(SPRITE_DEATH_PATCH)/$(TH11_VER).js \

$(SPRITE_DEATH_PATCH)/th%.js: $(SPRITE_DEATH_PATCH)/th%.yaml
	scripts/convert-yaml.py $^ >$@

