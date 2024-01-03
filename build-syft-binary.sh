#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

# Roughly replicate goreleaser templating: https://goreleaser.com/customization/templates/.
# Needed for passing version information to the Syft build (see syft/.goreleaser.yaml).

original_path=$PWD

syft_repo_path=${1:-syft/}
cd "$syft_repo_path"

get_version() {
    current_tag=$(git tag --points-at=HEAD)
    if [[ -n "$current_tag" ]]; then
        version=$current_tag
    else
        most_recent_tag=$(git describe --tags --abbrev=0)
        short_commit=$(git show --format=%h --quiet)
        version="${most_recent_tag}-SNAPSHOT-${short_commit}"
    fi
    # strip the 'v' prefix
    echo "${version#v}"
}

version=$(get_version)
full_commit=$(git rev-parse HEAD)
date="$(date --utc --iso-8601=seconds | cut -d '+' -f 1)Z"  # yyyy-mm-ddThh:mm:ssZ
summary=$(git describe --dirty --always --tags)

# command based on syft/.goreleaser.yaml configuration
CGO_ENABLED=0 go build -ldflags "
  -w
  -s
  -extldflags '-static'
  -X main.version=$version
  -X main.gitCommit=$full_commit
  -X main.buildDate=$date
  -X main.gitDescription=$summary
" -o "$original_path/dist/syft" ./cmd/syft

echo "--- output path: dist/syft ---"
"$original_path/dist/syft" version
