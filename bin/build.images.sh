#!/usr/bin/env bash

set -ex

echo "$CONTAINER"

_HOME="$(git rev-parse --show-toplevel)"

TARGET_OS_BASE="${1:-alpine}"
TARGET_TAGS=${2:-"3.10"}
LATEST_TAG="$(echo ${TARGET_TAGS} | tr ' ' '\n' | tail -1)"

_TARGET_GO_VERSIONS=${TARGET_GO_VERSIONS:-$(< $_HOME/ver/TARGET_VERSIONS)}
_LATEST_GO="${LATEST_GO:-$(echo ${_TARGET_GO_VERSIONS} | tr ' ' '\n' | tail -1)}"
TAG_CGO="$([[ ${CGO_ENABLED} -eq 1 ]] && printf '%s' '-cgo' || true)"

for _go_version in ${_TARGET_GO_VERSIONS}; do
	for _target_tag in ${TARGET_TAGS}; do
		BASE_CONTAINER_TAG="base_go${_go_version}${TAG_CGO}";
		CONTAINER_TAG="${TARGET_OS_BASE}-${_target_tag}_go${_go_version}${TAG_CGO}";
		sed "s|_BASE_TAG_|$BASE_CONTAINER_TAG|g;s|_TAG_|$_target_tag|g" "${_HOME}/${TARGET_OS_BASE}.Dockerfile" | \
			docker build \
				--rm \
				--no-cache \
				--tag "${CONTAINER}:${CONTAINER_TAG}" \
				-;
	done
	[[ "${_go_version}" == "${_LATEST_GO}" ]] && [[ "${_target_tag}" == "${LATEST_TAG}" ]] && \
		docker tag "${CONTAINER}:${CONTAINER_TAG}" "${CONTAINER}:${TARGET_OS_BASE}_go${_go_version}${TAG_CGO}";
		docker tag "${CONTAINER}:${CONTAINER_TAG}" "${CONTAINER}:${TARGET_OS_BASE}${TAG_CGO}";
done
