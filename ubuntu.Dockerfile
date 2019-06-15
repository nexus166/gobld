FROM	nexus166/gobld:_BASE_TAG_

FROM	ubuntu:_TAG_

SHELL	["/bin/bash", "-xeuo", "pipefail", "-c"]

ENV	GOPATH="/opt/go"
ENV	GOROOT="/usr/local/go"

COPY	--from=0 "${GOROOT}" "${GOROOT}"

RUN	export DEBIAN_FRONTEND=noninteractive; \
	apt-get update; \
	apt-get dist-upgrade -y; \
	apt-get install -y --no-install-recommends \
		binutils ca-certificates git; \
	rm -rf ~/.cache /var/lib/apt/lists/*

ENV	PATH="${GOROOT}/bin:${GOPATH}/bin:${PATH}"

RUN	go env && env | grep GO && go version
