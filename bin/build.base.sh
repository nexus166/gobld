#!/usr/bin/env bash

set -ex

echo "$CONTAINER"

_HOME="$(git rev-parse --show-toplevel)"

_TARGET_GO_VERSIONS=${TARGET_GO_VERSIONS:-$(< $_HOME/ver/TARGET_VERSIONS)}
_LATEST_GO="${LATEST_GO:-$(echo ${_TARGET_GO_VERSIONS} | tr ' ' '\n' | tail -1)}"
TAG_CGO="$([[ ${CGO_ENABLED} -eq 1 ]] && printf '%s' '-cgo' || true)"

for _go_version in ${_TARGET_GO_VERSIONS}; do
	BASE_CONTAINER_TAG="base_go${_go_version}${TAG_CGO}";
	cat "${_HOME}/base.Dockerfile" | \
		docker build \
			--build-arg CGO_ENABLED="${CGO_ENABLED:-0}" \
			--build-arg GO_VERSION="${_go_version}" \
			--build-arg GO_BOOTSTRAP_VERSION="${GO_BOOTSTRAP_VERSION:-${_LATEST_GO}}" \
			--tag "${CONTAINER}:${BASE_CONTAINER_TAG}" \
			-;
	[[ "${_go_version}" == "${_LATEST_GO}" ]] && docker tag "${CONTAINER}:${BASE_CONTAINER_TAG}" "${CONTAINER}:base${TAG_CGO}"
done
