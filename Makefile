
# Meta flag
.DELETE_ON_ERROR:

# uncomment to debug errors in convert-yaml.py
# .PRECIOUS: %.yaml

.PHONY: all
all: \
	base-exphp \
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
	ultra \
	anm-leak \
	auto-release \
	coop-sa \

REPO=patches
PERSONAL=personal

.PHONY: update
update:
	cd $(REPO) && ./update.sh

#================================================

PYTHON=PYTHONPATH=scripts python3

BINHACK_HELPER_PY=scripts/binhack_helper.py

%.asm.yaml: %.asm
	@echo "# this yaml file is auto-generated" >$@
	@echo "codecaves:" >>$@
	scripts/list-asm $< >>$@

#================================================

glob-th-js-from-yaml = $(patsubst %.yaml,%.js,$(wildcard $(1)/th*.yaml))
glob-th-js-from-asm = $(patsubst %.asm,%.js,$(wildcard $(1)/th*.asm))

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
#TH18_VER = th18.v0.02a
TH18_VER = th18.v1.00a

#================================================

.PHONY: subseason-patches
subseason-patches: .make/subseason-patches.stamp

DIR=$(REPO)/subseason_TEMPLATE

.make/subseason-patches.stamp: scripts/gen-subseason-patches.py $(DIR)/*
	$(PYTHON) $< $(REPO)/subseason_TEMPLATE --repo $(REPO)
	touch $@

#================================================

DIR=$(REPO)/sp_resources

.PHONY: sp-resources
sp-resources: $(DIR)/$(TH13_VER).js

$(DIR)/th%.js: $(DIR)/th%.yaml
	scripts/convert-yaml.py $< >$@

#================================================

DIR=$(REPO)/c_key

.PHONY: c-key
c-key: $(DIR)/$(TH17_VER).js

$(DIR)/th%.js: $(DIR)/th%.yaml
	scripts/convert-yaml.py $< >$@

#================================================

DIR=$(PERSONAL)/th17perf

.PHONY: th17perf
th17perf: \
	$(DIR)/$(TH17_VER).js \

$(DIR)/th%.js: $(DIR)/th%.yaml
	scripts/convert-yaml.py $< >$@

#================================================

DIR=$(PERSONAL)/numguide

.PHONY: numguide
numguide: \
	$(DIR)/$(TH12_VER).js \

$(DIR)/th%.js: $(DIR)/th%.yaml
	scripts/convert-yaml.py $< >$@

#================================================

DIR=$(REPO)/continue

.PHONY: continue
continue: \
	$(call glob-th-js-from-yaml,$(DIR)) \

$(DIR)/th%.js: $(DIR)/th%.yaml
	scripts/convert-yaml.py $< >$@

#================================================

DIR=$(REPO)/ctrl_speedup

.PHONY: ctrl-speedup
ctrl-speedup: \
	$(call glob-th-js-from-yaml,$(DIR)) \

$(DIR)/th%.js: $(DIR)/binhacks.yaml
	scripts/convert-yaml.py $< >$@ --cfg $$(echo "$(@F)" | cut -f1 -d.)

#================================================

DIR=$(PERSONAL)/mouse

.PHONY: mouse
mouse: \
	$(call glob-th-js-from-yaml,$(DIR)) \

$(DIR)/th%.js: $(DIR)/th%.yaml
	scripts/convert-yaml.py $< >$@

#================================================

DIR=$(PERSONAL)/ssa

.PHONY: ssa
ssa: \
	$(call glob-th-js-from-yaml,$(DIR)) \

.INTERMEDIATE: $(DIR)/common.asm.yaml
$(DIR)/th%.js: $(DIR)/th%.yaml $(DIR)/common.asm.yaml
	scripts/convert-yaml.py $^ >$@

#================================================

DIR=$(REPO)/bullet_cap

.PHONY: bullet-cap
bullet-cap: \
	$(DIR)/global.js \
	$(call glob-th-js-from-asm,$(DIR)) \

POINTERIZE_YAMLS= \
	$(DIR)/pointerize.${TH06_VER}.yaml \
	$(DIR)/pointerize.${TH07_VER}.yaml \
	$(DIR)/pointerize.${TH08_VER}.yaml \

.INTERMEDIATE: $(POINTERIZE_YAMLS)
$(POINTERIZE_YAMLS) : $(DIR)/pointerize.th%.yaml: $(DIR)/pointerize.py $(BINHACK_HELPER_PY)
	$(PYTHON) $< --game th$* >$@

$(DIR)/binhacks.th%.yaml: $(DIR)/binhacks.py $(BINHACK_HELPER_PY)
	$(PYTHON) $< --game th$* >$@

TH_ASM_YAMLS=$(patsubst %.asm,%.asm.yaml,$(wildcard $(DIR)/th*.asm))

.INTERMEDIATE: $(TH_ASM_YAMLS)
$(DIR)/global.asm.yaml: $(DIR)/layout-test.asm $(DIR)/common.asm
$(TH_ASM_YAMLS): $(DIR)/common.asm

.INTERMEDIATE: $(DIR)/global.asm.yaml
$(DIR)/global.js: $(DIR)/global.asm.yaml
	scripts/convert-yaml.py $^ >$@

$(DIR)/th%.js: $(DIR)/th%.asm.yaml $(DIR)/options.yaml $(DIR)/binhacks.th%.yaml $(DIR)/pointerize.th%.yaml
	scripts/convert-yaml.py $^ >$@ --cfg $$(echo "$(@F)" | cut -f1 -d.)

$(DIR)/th%.js: $(DIR)/th%.asm.yaml $(DIR)/options.yaml $(DIR)/binhacks.th%.yaml
	scripts/convert-yaml.py $^ >$@ --cfg $$(echo "$(@F)" | cut -f1 -d.)

#================================================

DIR=$(REPO)/debug_counters

.PHONY: debug-counters
debug-counters: \
	$(DIR)/global.js \
	$(DIR)/$(TH06_VER).js \
	$(DIR)/$(TH07_VER).js \
	$(DIR)/$(TH08_VER).js \
	$(DIR)/$(TH09_VER).js \
	$(DIR)/$(TH095_VER).js \
	$(DIR)/$(TH10_VER).js \
	$(DIR)/$(TH11_VER).js \
	$(DIR)/$(TH12_VER).js \
	$(DIR)/$(TH125_VER).js \
	$(DIR)/$(TH128_VER).js \
	$(DIR)/$(TH13_VER).js \
	$(DIR)/$(TH14_VER).js \
	$(DIR)/$(TH143_VER).js \
	$(DIR)/$(TH15_VER).js \
	$(DIR)/$(TH16_VER).js \
	$(DIR)/$(TH165_VER).js \
	$(DIR)/$(TH17_VER).js \

.INTERMEDIATE: $(DIR)/global.asm.yaml
$(DIR)/global.js: $(DIR)/global.asm.yaml
	scripts/convert-yaml.py $^ >$@

$(DIR)/counters.th%.yaml: $(DIR)/counters.py $(BINHACK_HELPER_PY) $(DIR)/common.asm
	$(PYTHON) $< --game th$* >$@

$(DIR)/th%.js: $(DIR)/counters.th%.yaml
	scripts/convert-yaml.py $^ >$@ --cfg $$(echo "$(@F)" | cut -f1 -d.)

#================================================

DIR=$(REPO)/sprite_death_fix

# Note: TH06 doesn't need this.
.PHONY: sprite-death-fix
sprite-death-fix: \
	$(DIR)/$(TH07_VER).js \
	$(DIR)/$(TH08_VER).js \
	$(DIR)/$(TH09_VER).js \
	$(DIR)/$(TH095_VER).js \
	$(DIR)/$(TH10_VER).js \
	$(DIR)/$(TH11_VER).js \
	$(DIR)/$(TH12_VER).js \
	$(DIR)/$(TH125_VER).js \
	$(DIR)/$(TH128_VER).js \
	$(DIR)/$(TH13_VER).js \
	$(DIR)/$(TH14_VER).js \
	$(DIR)/$(TH143_VER).js \
	$(DIR)/$(TH15_VER).js \
	$(DIR)/$(TH16_VER).js \
	$(DIR)/$(TH165_VER).js \
	$(DIR)/$(TH17_VER).js \

$(DIR)/th%.js: $(DIR)/binhacks.yaml
	scripts/convert-yaml.py $^ >$@ --cfg $$(echo "$(@F)" | cut -f1 -d.)

#================================================

DIR=$(PERSONAL)/ultra

.PHONY: ultra
ultra: \
	$(DIR)/$(TH07_VER).js \
	$(DIR)/$(TH08_VER).js \
	$(DIR)/$(TH09_VER).js \
	$(DIR)/$(TH14_VER).js \
	$(DIR)/$(TH15_VER).js \
	$(DIR)/$(TH16_VER).js \
	$(DIR)/$(TH165_VER).js \
	$(DIR)/$(TH17_VER).js \
	$(DIR)/$(TH18_VER).js \

$(DIR)/binhacks.th%.yaml: $(DIR)/binhacks.py $(BINHACK_HELPER_PY)
	$(PYTHON) $< --game th$* >$@

$(DIR)/th%.js: $(DIR)/binhacks.th%.yaml
	scripts/convert-yaml.py $^ >$@ --cfg $$(echo "$(@F)" | cut -f1 -d.)

#================================================

DIR=$(REPO)/base_exphp

.PHONY: base-exphp
base-exphp: \
	$(DIR)/global.js \

.INTERMEDIATE: $(DIR)/global.asm.yaml
$(DIR)/global.js: $(DIR)/global.asm.yaml
	scripts/convert-yaml.py $^ >$@

#================================================

DIR=$(REPO)/anm_leak

.PHONY: anm-leak
anm-leak: \
	$(DIR)/global.js \
	$(DIR)/$(TH15_VER).js \
	$(DIR)/$(TH16_VER).js \
	$(DIR)/$(TH165_VER).js \
	$(DIR)/$(TH17_VER).js \
	$(DIR)/$(TH18_VER).js \

.INTERMEDIATE: $(DIR)/global.asm.yaml
$(DIR)/global.js: $(DIR)/global.asm.yaml
	scripts/convert-yaml.py $^ >$@

$(DIR)/binhacks.th%.yaml: $(DIR)/binhacks.py $(BINHACK_HELPER_PY)
	$(PYTHON) $< --game th$* >$@

$(DIR)/th%.js: $(DIR)/binhacks.th%.yaml
	scripts/convert-yaml.py $^ >$@ --cfg $$(echo "$(@F)" | cut -f1 -d.)

#================================================

DIR=$(PERSONAL)/auto-release

.PHONY: auto-release
auto-release: \
	$(call glob-th-js-from-yaml,$(DIR)) \

$(DIR)/th%.js: $(DIR)/th%.yaml
	scripts/convert-yaml.py $^ >$@

#================================================

DIR=$(PERSONAL)/coop-sa

.PHONY: coop-sa
coop-sa: \
	$(DIR)/global.js \
	$(DIR)/$(TH11_VER).js \

.INTERMEDIATE: $(DIR)/global.asm.yaml
$(DIR)/global.js: $(DIR)/global.asm.yaml $(DIR)/options.yaml $(DIR)/protection.yaml
	scripts/convert-yaml.py $^ >$@

$(DIR)/binhacks.th%.yaml: $(DIR)/binhacks.py $(BINHACK_HELPER_PY)
	$(PYTHON) $< --game th$* >$@

$(DIR)/th%.js: $(DIR)/binhacks.th%.yaml
	scripts/convert-yaml.py $^ >$@ --cfg $$(echo "$(@F)" | cut -f1 -d.)
