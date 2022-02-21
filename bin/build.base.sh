#!/usr/bin/env bash

set -ex

echo "$CONTAINER"

_HOME="$(git rev-parse --show-toplevel)"

_TARGET_GO_VERSIONS="1.17.7"
_LATEST_GO="${LATEST_GO:-$(echo ${_TARGET_GO_VERSIONS} | tr ' ' '\n' | tail -1)}"
TAG_CGO="$([[ ${CGO_ENABLED} -eq 1 ]] && printf '%s' '-cgo' || true)"

for _go_version in ${_TARGET_GO_VERSIONS}; do
	BASE_CONTAINER_TAG="base_go${_go_version}${TAG_CGO}"
	docker buildx build \
		-f base.Dockerfile \
		--progress plain \
		--platform ${PLATFORMS:-"linux/amd64"} \
		--build-arg CGO_ENABLED="${CGO_ENABLED:-0}" \
		--build-arg GO_VERSION="${_go_version}" \
		--build-arg GO_BOOTSTRAP_VERSION="${GO_BOOTSTRAP_VERSION:-${_LATEST_GO}}" \
		--push \
		--tag "${CONTAINER}:${BASE_CONTAINER_TAG}" \
		$(mktemp -d)
	if [[ ${_go_version} == "${_LATEST_GO}" ]]; then
		docker buildx build \
			-f base.Dockerfile \
			--progress plain \
			--platform ${PLATFORMS:-"linux/amd64"} \
			--build-arg CGO_ENABLED="${CGO_ENABLED:-0}" \
			--build-arg GO_VERSION="${_go_version}" \
			--build-arg GO_BOOTSTRAP_VERSION="${GO_BOOTSTRAP_VERSION:-${_LATEST_GO}}" \
			--push \
			--tag "${CONTAINER}:base${TAG_CGO}" \
			$(mktemp -d)
	fi
done
