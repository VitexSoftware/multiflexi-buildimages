# Top-level Makefile to build Debian/Ubuntu images preconfigured with MultiFlexi APT repo

# Image namespace
NAMESPACE ?= vitexsoftware
# Common repo settings
REPO_URL ?= https://repo.multiflexi.eu
# Provide KEY_URL to enable repository signing (left empty by default to avoid build failures if key URL is unavailable)
KEY_URL ?= https://repo.multiflexi.eu/KEY.gpg

# Supported variants
DEBIAN_VARIANTS := bookworm trixie forky
UBUNTU_VARIANTS := jammy noble
ALL_VARIANTS := $(DEBIAN_VARIANTS) $(UBUNTU_VARIANTS)

# Image tags
define IMAGE_TAG
$(NAMESPACE)/multiflexi-$(1):latest
endef

.PHONY: all
all: $(ALL_VARIANTS)

# Generic single-variant build rules
$(DEBIAN_VARIANTS): %: debian/%/Dockerfile
	docker build \
	  -f $< \
	  --build-arg REPO_URL=$(REPO_URL) \
	  --build-arg KEY_URL=$(KEY_URL) \
	  -t $(call IMAGE_TAG,$@) \
	  .

$(UBUNTU_VARIANTS): %: ubuntu/%/Dockerfile
	docker build \
	  -f $< \
	  --build-arg REPO_URL=$(REPO_URL) \
	  --build-arg KEY_URL=$(KEY_URL) \
	  -t $(call IMAGE_TAG,$@) \
	  .

# Convenience explicit targets
.PHONY: $(ALL_VARIANTS)

# Multi-arch buildx
PLATFORMS ?= linux/amd64,linux/arm64

.PHONY: buildx buildx-%
buildx: $(addprefix buildx-, $(ALL_VARIANTS))

buildx-%: %
	docker buildx build \
	  --platform $(PLATFORMS) \
	  -f $(if $(findstring $*, $(DEBIAN_VARIANTS)),debian/$*/Dockerfile,ubuntu/$*/Dockerfile) \
	  --build-arg REPO_URL=$(REPO_URL) \
	  --build-arg KEY_URL=$(KEY_URL) \
	  -t $(call IMAGE_TAG,$*) \
	  --load \
	  .

# Push and publish
.PHONY: push publish
push:
	for v in $(ALL_VARIANTS); do docker push $(NAMESPACE)/multiflexi-$$v:latest; done

publish: buildx
	for v in $(ALL_VARIANTS); do docker buildx build \
	  --platform $(PLATFORMS) \
	  -f $(if $(findstring $$v, $(DEBIAN_VARIANTS)),debian/$$v/Dockerfile,ubuntu/$$v/Dockerfile) \
	  --build-arg REPO_URL=$(REPO_URL) \
	  --build-arg KEY_URL=$(KEY_URL) \
	  -t $(NAMESPACE)/multiflexi-$$v:latest \
	  --push \
	  .; done

# Clean
.PHONY: clean reset
clean:
	-@for v in $(ALL_VARIANTS); do docker rmi -f $(NAMESPACE)/multiflexi-$$v:latest 2>/dev/null || true; done
	-@docker image prune -f 2>/dev/null || true

reset: clean all

