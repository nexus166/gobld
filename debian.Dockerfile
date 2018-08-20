FROM	debian:buster-slim

SHELL	["/bin/bash", "-euvxo", "pipefail", "-c"]

RUN	export DEBIAN_FRONTEND=noninteractive; \
	apt-get update; \
	apt-get dist-upgrade -y; \
	apt-get install -y --no-install-recommends \
		binutils build-essential ca-certificates wget; \
	rm -rf /var/lib/apt/lists/*

ENV     GOPATH="/opt/go"

ARG     GO_VERSION=1.12.6

ARG     GO_BOOTSTRAP_VERSION

ENV     GO_BOOTSTRAP_VERSION=${GO_BOOTSTRAP_VERSION:-${GO_VERSION}}
ENV     GOROOT_BOOTSTRAP="/usr/local/go${GO_BOOTSTRAP_VERSION}"

RUN	case "$(dpkg --print-architecture)" in \
			arm*) GO_DL_ARCH='armv6l';; \
			aarch64) GO_DL_ARCH='arm64';; \
			s390x) GO_DL_ARCH='s390x';; \
			amd64) GO_DL_ARCH='amd64';; \
			i386) GO_DL_ARCH='386';; \
			*) echo >&2 "error: unsupported architecture"; exit 1 ;; \
		esac; \
	mkdir -p "${GOROOT_BOOTSTRAP}"; \
	wget -qO- "https://dl.google.com/go/go${GO_BOOTSTRAP_VERSION}.$(uname -s | tr '[[:upper:]]' '[[:lower:]]')-${GO_DL_ARCH}.tar.gz" | tar fzx - -C "${GOROOT_BOOTSTRAP}" --strip-components=1; \
	export PATH="${GOPATH}/bin:${GOROOT_BOOTSTRAP}/bin:${PATH}"; \
	${GOROOT_BOOTSTRAP}/bin/go version; \
	export \
		GO_LDFLAGS="-s -w" \
		GOROOT_BOOTSTRAP="$(${GOROOT_BOOTSTRAP}/bin/go env GOROOT)" \
		GOOS="$(${GOROOT_BOOTSTRAP}/bin/go env GOOS)" \
		GOARCH="$(${GOROOT_BOOTSTRAP}/bin/go env GOARCH)" \
		GOHOSTOS="$(${GOROOT_BOOTSTRAP}/bin/go env GOHOSTOS)" \
		GOHOSTARCH="$(${GOROOT_BOOTSTRAP}/bin/go env GOHOSTARCH)"; \
	wget -qO- "https://dl.google.com/go/go${GO_VERSION}.src.tar.gz" | tar zxf - -C /usr/local; \
	cd /usr/local/go/src; \
	./make.bash; \
	rm -rf ~/.cache "${GOROOT_BOOTSTRAP}" /usr/local/go/pkg/bootstrap /usr/local/go/pkg/obj /usr/local/go/doc /usr/local/go/test


FROM	debian:buster-slim

SHELL	["/bin/bash", "-xeuo", "pipefail", "-c"]

COPY	--from=0 /usr/local/go /usr/local/go

ARG	GOPATH=/opt/go
ENV	GOPATH="${GOPATH}"
ENV	GOROOT="/usr/local/go"
ENV	PATH="${GOPATH}/bin:/usr/local/go/bin:${PATH}"
ENV	GO_LDFLAGS="-s -w"

RUN	export DEBIAN_FRONTEND=noninteractive; \
	apt-get update; \
	apt-get dist-upgrade -y; \
	apt-get install -y --no-install-recommends \
		binutils ca-certificates git; \
	rm -rf ~/.cache "${GOPATH}/src" /var/lib/apt/lists/*; \
	go get -u -v github.com/mitchellh/gox; \
	go version

WORKDIR ${GOPATH}
