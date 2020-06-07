.PHONY: all
all: \
	subseason-patches \
	sp-resources \
	c-key \
	numguide \
	continue \
	th17perf \

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
	scripts/convert-yaml.py $< -o $@

#================================================

C_KEY_PATCH=$(REPO)/c_key

.PHONY: c-key
c-key: $(C_KEY_PATCH)/$(TH17_VER).js

$(C_KEY_PATCH)/th%.js: $(C_KEY_PATCH)/th%.yaml
	scripts/convert-yaml.py $< -o $@

#================================================

TH17_PERF_PATCH=$(PERSONAL)/th17perf

.PHONY: th17perf
th17perf: \
	$(TH17_PERF_PATCH)/$(TH17_VER).js \

$(TH17_PERF_PATCH)/th%.js: $(TH17_PERF_PATCH)/th%.yaml
	scripts/convert-yaml.py $< -o $@

#================================================

NUMGUIDE_PATCH=$(PERSONAL)/numguide

.PHONY: numguide
numguide: \
	$(NUMGUIDE_PATCH)/$(TH12_VER).js \

$(NUMGUIDE_PATCH)/th%.js: $(NUMGUIDE_PATCH)/th%.yaml
	scripts/convert-yaml.py $< -o $@

#================================================

CONTINUE_PATCH=$(REPO)/continue

.PHONY: continue
continue: \
	$(CONTINUE_PATCH)/$(TH10_VER).js \
	$(CONTINUE_PATCH)/$(TH12_VER).js \

$(CONTINUE_PATCH)/th%.js: $(CONTINUE_PATCH)/th%.yaml
	scripts/convert-yaml.py $< -o $@
