ARG	GOBLD_TAG=base
ARG	OS_TAG=bullseye

FROM	nexus166/gobld:${GOBLD_TAG}
FROM	debian:${OS_TAG}-slim
SHELL	["/bin/bash", "-xeuo", "pipefail", "-c"]

RUN	export DEBIAN_FRONTEND=noninteractive; \
	apt-get update; \
	apt-get dist-upgrade -y; \
	apt-get install -y --no-install-recommends binutils ca-certificates git; \
	rm -rf ~/.cache /var/lib/apt/lists/*

ENV     GOPATH="/opt/go" GOROOT="/usr/local/go" GOPROXY="direct"
ENV     PATH="${GOROOT}/bin:${GOPATH}/bin:${PATH}"

COPY    --from=0 "${GOROOT}" "${GOROOT}"

RUN	go env && env | grep GO && go version
