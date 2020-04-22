.PHONY: all
all: \
	subseason-patches \
	sp-resources \

REPO=patches

.PHONY: update
update:
	cd $(REPO) && ./update.sh

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
sp-resources: $(SP_RESOURCES_PATCH)/th13.v1.00c.js

$(SP_RESOURCES_PATCH)/th%.js: $(SP_RESOURCES_PATCH)/th%.yaml
	scripts/convert-yaml.py $< -o $@
