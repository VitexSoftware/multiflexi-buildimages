#!/usr/bin/env bash
set -euo pipefail

# Publish .deb artifacts to remote reprepro repository
# Usage:
#   publish-to-reprepro.sh <remote_ssh> <remote_repo_dir> <component> <deb1> [deb2 ...]
# Example:
#   publish-to-reprepro.sh repo@repo.multiflexi.eu:/var/repos/multiflexi pool main dist/debian/*.deb
# Notes:
# - Requires SSH access to the remote host with permissions to run reprepro in <remote_repo_dir>.
# - Determines the distribution codename from the .changes or .deb metadata if possible; can be overridden by DEB_DIST=<codename> env.
# - Expects reprepro to be installed and configured remotely.

if [[ $# -lt 4 ]]; then
  echo "Usage: $0 <remote_ssh> <remote_repo_dir> <component> <deb1> [deb2 ...]" >&2
  exit 2
fi

REMOTE_SSH="$1"        # e.g., repo@repo.multiflexi.eu
REMOTE_DIR="$2"        # e.g., /srv/repo
COMPONENT="$3"         # e.g., main or paid
shift 3
ARTIFACTS=("$@")

# Resolve codename: prefer DEB_DIST env; otherwise try to infer from filename (..~<codename>.deb) or control field
resolve_codename() {
  local deb="$1"
  if [[ -n "${DEB_DIST:-}" ]]; then
    echo "$DEB_DIST"
    return 0
  fi
  # Try suffix like ...~bookworm.deb
  if [[ "$deb" =~ ~([a-z0-9]+)\.deb$ ]]; then
    echo "${BASH_REMATCH[1]}"
    return 0
  fi
  # Fallback: use dpkg-deb to read Distribution from control if present
  local dist
  dist=$(dpkg-deb -f "$deb" Distribution 2>/dev/null || true)
  if [[ -n "$dist" && "$dist" != "unknown" ]]; then
    echo "$dist"
    return 0
  fi
  echo "unstable"
}

# Group artifacts per codename for efficient remote commands
declare -A by_dist
for deb in "${ARTIFACTS[@]}"; do
  [[ -f "$deb" ]] || { echo "Skipping missing file: $deb" >&2; continue; }
  dist=$(resolve_codename "$deb")
  by_dist["$dist"]+=" $deb"

done

# Create a temporary staging dir on remote
remote_exec() {
  ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new "$REMOTE_SSH" "$@"
}

remote_mktemp() {
  remote_exec "mktemp -d"
}

for dist in "${!by_dist[@]}"; do
  files=( ${by_dist[$dist]} )
  echo "Publishing ${#files[@]} package(s) to ${dist} (${COMPONENT}) on ${REMOTE_SSH}:${REMOTE_DIR}"
  remote_tmp=$(remote_mktemp)
  # Copy files
  scp -o BatchMode=yes -o StrictHostKeyChecking=accept-new "${files[@]}" "$REMOTE_SSH":"$remote_tmp/"
  # Include into repo
  remote_exec "set -e; cd '$REMOTE_DIR'; for f in '$remote_tmp'/*.deb; do reprepro -Vb . includedeb '$dist' '$f'; done; rm -rf '$remote_tmp'"
  echo "Done for ${dist}"

done

