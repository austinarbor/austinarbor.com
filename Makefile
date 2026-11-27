# Cut a release: annotated tag -> push -> GitHub release with generated notes. The "Tag and
# Release" workflow runs this (and then deploys the tag); it works from a laptop too.
#
#   make release VERSION=1.0.0
#
# Versions are semver, MAJOR.MINOR.PATCH, without a v.

REMOTE ?= origin

.PHONY: release
release:
	@test -n "$(VERSION)" || { \
	  echo "VERSION is required, e.g. make release VERSION=1.0.0" >&2; exit 1; }
	@echo "$(VERSION)" | grep -Eq '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$$' || { \
	  echo "VERSION must be semver, MAJOR.MINOR.PATCH, e.g. 1.0.0" >&2; exit 1; }
	@if git rev-parse -q --verify "refs/tags/$(VERSION)" >/dev/null; then \
	  echo "tag $(VERSION) already exists locally" >&2; exit 1; fi
	@if [ -n "$$(git ls-remote --tags $(REMOTE) "refs/tags/$(VERSION)")" ]; then \
	  echo "tag $(VERSION) already exists on $(REMOTE)" >&2; exit 1; fi
	git tag -a "$(VERSION)" -m "$(VERSION)"
	git push $(REMOTE) "refs/tags/$(VERSION)"
	gh release create "$(VERSION)" --title "$(VERSION)" --generate-notes --verify-tag

# install the theme's npm dependencies (again whenever the theme version changes)
.PHONY: install
install:
	hugo mod npm pack
	npm install

.PHONY: run
run:
	hugo server
