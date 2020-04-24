.PHONY: all
all: \
	subseason-patches \
	sp-resources \
	c-key \

REPO=patches

.PHONY: update
update:
	cd $(REPO) && ./update.sh

#================================================

TH13_VER = th13.v1.00c
TH14_VER = th14.v1.00b
TH16_VER = th16.v1.00a
TH17_VER = th17.v1.00b

#================================================

.PHONY: subseason-patches
season-patches: .make/subseason-patches.stamp

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
