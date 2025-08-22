# multiflexi-buildimages

Debian/Ubuntu container images preconfigured to use https://repo.multiflexi.eu/.

Variants
- Debian: bookworm, trixie, forky
- Ubuntu: jammy, noble

Prerequisites
- Docker (for local builds). For multi-arch builds, enable Buildx: docker buildx create --use
- Optional: hadolint for linting Dockerfiles (https://github.com/hadolint/hadolint)

Build locally
- Lint Dockerfiles:
  make lint
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
- Docker Hub: vitexsoftware/multiflexi-\u003cvariant\u003e:latest
  Example: vitexsoftware/multiflexi-bookworm:latest
- GitHub Packages (GHCR): ghcr.io/VitexSoftware/multiflexi-\u003cvariant\u003e:latest
  Example: ghcr.io/VitexSoftware/multiflexi-bookworm:latest

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

Jenkins pipelines
- Build pipeline: Jenkinsfile (builds and archives .deb artifacts for Debian/Ubuntu variants)
- Publish pipeline: Jenkinsfile.publish (runs after build, fetches artifacts, and publishes to https://repo.multiflexi.eu)

Publish pipeline setup (Jenkins)
1) Create credentials
   - Kind: SSH Username with private key
   - ID: repo-multiflexi-ssh
   - Username: user with access to the repo server (e.g., repo)
   - Private key: key authorized on repo.multiflexi.eu
2) Create a multibranch or pipeline job pointing to this repo and select Jenkinsfile.publish
3) Configure upstream trigger
   - In Jenkins UI for the publish job, enable "Build when another project is built" and set the upstream job name (the build job using Jenkinsfile)
   - Alternatively, start manually by providing parameters
4) Parameters (defaults can be adjusted in Jenkinsfile.publish)
   - UPSTREAM_JOB: name of the build job to pull artifacts from
   - UPSTREAM_BUILD: lastSuccessfulBuild or a specific build number
   - REMOTE_SSH: repo@repo.multiflexi.eu
   - REMOTE_REPO_DIR: repository path on the server (e.g., /srv/repo)
   - COMPONENT: main or paid
   - DEB_DIST: optional override of distro codename (otherwise inferred from filename like ~bookworm)
5) Remote host requirements
   - reprepro installed and initialized in REMOTE_REPO_DIR
   - SSH access for the configured user, with write permissions to REMOTE_REPO_DIR

Helper scripts
- scripts/publish-to-reprepro.sh: copies .deb artifacts via scp and runs reprepro includedeb per codename on the remote host. It infers distro codenames from filenames (..~<codename>.deb) or control metadata, unless DEB_DIST is provided.
