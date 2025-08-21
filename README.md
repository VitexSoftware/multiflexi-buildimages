# multiflexi-buildimages

Debian/Ubuntu container images preconfigured to use https://repo.multiflexi.eu/.

Variants
- Debian: bookworm, trixie, forky
- Ubuntu: jammy, noble

Prerequisites
- Docker (for local builds). For multi-arch builds, enable Buildx: docker buildx create --use

Build locally
- Build all variants:
  make
- Build a single variant (examples):
  make bookworm
  make jammy
- Multi-arch build (loads into local Docker):
  docker buildx create --use
  make buildx
- Push locally built images to Docker Hub (uses your local Docker auth):
  make push
- Build and push multi-arch directly (no local load):
  docker buildx create --use
  make publish

Image naming
- Docker Hub tags: vitexsoftware/multiflexi-<variant>:latest
  Example: vitexsoftware/multiflexi-bookworm:latest

What the images do
- Add the MultiFlexi APT repository entry and (optionally) configure its signing key.
- Provide a minimal base suitable for building Debian/Ubuntu packages against repo.multiflexi.eu.

Repo layout
- scripts/add-multiflexi-apt.sh: shared helper to configure the APT repository during build
- debian/<variant>/Dockerfile, ubuntu/<variant>/Dockerfile: per-variant image definitions
- Makefile: build, buildx, push, publish, clean, reset targets

Configuration knobs
- Override namespace and repo settings at build time:
  NAMESPACE=myorg REPO_URL=https://repo.multiflexi.eu KEY_URL=https://repo.multiflexi.eu/KEY.gpg make bookworm
- KEY_URL defaults to a value in the Makefile; if unreachable or empty, the repo entry is written but commented, and the build still succeeds.

GitHub Actions (CI)
- Workflow: .github/workflows/publish.yml
- On each push, builds multi-arch images for all variants and pushes to Docker Hub (vitexsoftware/*).
- Requires repository secrets:
  - DOCKERHUB_USERNAME
  - DOCKERHUB_TOKEN (Docker Hub access token)

Quick validation
- Verify the APT repo is present inside a built image:
  docker run --rm vitexsoftware/multiflexi-bookworm:latest bash -lc "grep -R 'repo.multiflexi.eu' /etc/apt/sources.list /etc/apt/sources.list.d || (echo 'Repo not found' >&2; exit 1)"
