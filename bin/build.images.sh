#!/usr/bin/env bash

set -ex

echo "$CONTAINER"

_HOME="$(git rev-parse --show-toplevel)"

TARGET_OS_BASE="${1:-alpine}"
TARGET_TAGS=${2:-"3.15"}
LATEST_TAG="$(echo ${TARGET_TAGS} | tr ' ' '\n' | tail -1)"

_TARGET_GO_VERSIONS="1.17.7"
_LATEST_GO="${LATEST_GO:-$(echo ${_TARGET_GO_VERSIONS} | tr ' ' '\n' | tail -1)}"
TAG_CGO="$([[ ${CGO_ENABLED} -eq 1 ]] && printf '%s' '-cgo' || true)"

#for PLATFORM in ${PLATFORMS:-linux/amd64}; do
for _go_version in ${_TARGET_GO_VERSIONS}; do
	for _target_tag in ${TARGET_TAGS}; do
		BASE_CONTAINER_TAG="base_go${_go_version}${TAG_CGO}"
		CONTAINER_TAG="${TARGET_OS_BASE}-${_target_tag}_go${_go_version}${TAG_CGO}"
		docker buildx build \
			--build-arg GOBLD_TAG="${BASE_CONTAINER_TAG}" \
			--build-arg OS_TAG="${_target_tag}" \
			--progress plain \
			--push \
			--platform ${PLATFORMS} \
			--tag "${CONTAINER}:${CONTAINER_TAG}" \
			-f ${1}.Dockerfile $(mktemp -d)
	done
	if [[ ${_go_version} == "${_LATEST_GO}" ]] && [[ ${_target_tag} == "${LATEST_TAG}" ]]; then
		docker buildx build \
			--build-arg GOBLD_TAG="${BASE_CONTAINER_TAG}" \
			--build-arg OS_TAG="${_target_tag}" \
			--progress plain \
			--push \
			--platform ${PLATFORMS} \
			--tag "${CONTAINER}:${TARGET_OS_BASE}_go${_go_version}${TAG_CGO}" \
			-f ${1}.Dockerfile $(mktemp -d)
	fi
done
#done
