`
# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.
``

Project purpose
- Source of Docker images used for Debian/Ubuntu package building. Images are tagged and published under vitexsoftware/* for multiple distro codename variants.
- Debian/Ubuntu container images with https://repo.multiflexi.eu/ preconfigured.

Common commands
- Build all maintained images (default):
  make

- Build a specific image locally (examples):
  make bookworm
  make trixie
  make forky
  make jammy
  make noble

- Multi-arch builds (uses Docker Buildx):
  # Configure buildx once in your environment
  docker buildx create --use
  # Build and push a set of images for common platforms
  make buildx
  # Or per-distro multi-arch builds
  make buildx-bookworm
  make buildx-trixie
  make buildx-forky
  make buildx-jammy
  make buildx-noble

- Publish images (after building locally with make):
  make push
  # Build and push in one go
  make publish

- Cleanup local Docker cache and remove built images:
  make clean
  # Full reset (clean + rebuild all)
  make reset

Common commands
Note: Because there are no Dockerfiles or scripts yet, these commands use placeholders. Replace paths and tags with actual values once Dockerfiles are added.

- Build an image (Docker):
  docker build -f Dockerfile -t multiflexi/image:tag .

- Build an image (Podman):
  podman build -f Dockerfile -t multiflexi/image:tag .

- Lint Dockerfiles (hadolint):
  # Single file
  hadolint Dockerfile
  # All Dockerfiles in repo
  find . -maxdepth 3 -type f -name 'Dockerfile*' -print0 | xargs -0 -r hadolint

- Run a built image:
  docker run --rm -it multiflexi/image:tag bash

- Quick validation inside a running container (verify apt repo is present):
  grep -R "repo.multiflexi.eu" /etc/apt/sources.list /etc/apt/sources.list.d || true

- Example: build and smoke-test in one go (Docker):
  IMG=multiflexi/image:tag
  docker build -f Dockerfile -t "$IMG" . \
    && docker run --rm "$IMG" bash -lc "grep -R 'repo.multiflexi.eu' /etc/apt/sources.list /etc/apt/sources.list.d || (echo 'Repo not found' >&2; exit 1)"

High-level architecture and structure
- Intended big picture: This repository is meant to host build definitions for Debian/Ubuntu base images that come preconfigured to use the MultiFlexi APT repository (repo.multiflexi.eu). Each image variant is typically defined by a Dockerfile (or Podman-compatible Containerfile) and optional helper scripts.
- Expected layout (once populated):
  - One directory per base/variant (e.g., debian/bookworm, ubuntu/jammy), each containing a Dockerfile and any auxiliary scripts.
  - Optional shared scripts or snippets for common steps (e.g., adding the repo key, apt source list entries).
  - Optional CI workflow to build and publish images on push or tag.

Notes for future contributors (actionable, repo-specific)
- When adding Dockerfiles:
  - Ensure the image adds and trusts the repo.multiflexi.eu APT source (key + source list) and performs an apt update to validate availability.
  - Keep the Dockerfiles minimal and rely on build args (e.g., BASE_TAG) where appropriate for versioning.
  - Provide a short comment header in each Dockerfile indicating the target distro and purpose.
- If tests are introduced:
  - Prefer smoke tests that run minimal apt operations to confirm the repository is usable (e.g., apt update; apt-cache policy PACKAGE).
- If CI is introduced:
  - Include matrix builds for supported Debian/Ubuntu versions and push images with clear tags (distro + version).

Cross-repo context
- This repository appears to be part of the MultiFlexi ecosystem and is focused specifically on container image definitions. Any deeper integration (e.g., images consumed by other MultiFlexi components) should be documented in this repo once those files are added.

