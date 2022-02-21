ARG	FROM="debian:bullseye-slim"
FROM    ${FROM}

SHELL   ["/bin/bash", "-evxo", "pipefail", "-c"]

ARG     CGO_ENABLED=0
ENV     CGO_ENABLED="${CGO_ENABLED}"

RUN     export DEBIAN_FRONTEND=noninteractive; \
        apt-get update; \
        apt-get dist-upgrade -y; \
        apt-get install -y --no-install-recommends \
                binutils build-essential ca-certificates wget; \
        [[ "${CGO_ENABLED}" -eq 1 ]] && apt-get install -y --no-install-recommends gccgo; \
        rm -rf /var/lib/apt/lists/*

ENV     GOPATH="/opt/go"

ARG     GO_LDFLAGS="-s -w"
ENV     GO_LDFLAGS="${GO_LDFLAGS}"

ARG     GO_VERSION=1.15.6

ARG     GO_BOOTSTRAP_VERSION

ENV     GO_BOOTSTRAP_VERSION=${GO_BOOTSTRAP_VERSION:-${GO_VERSION}}
ENV     GOROOT_BOOTSTRAP="/usr/local/go${GO_BOOTSTRAP_VERSION}"

RUN     case "$(dpkg --print-architecture)" in \
                        amd64) GO_DL_ARCH='amd64';; \
                        i386) GO_DL_ARCH='386';; \
                        arm64) GO_DL_ARCH='arm64';; \
                        aarch64) GO_DL_ARCH='arm64';; \
                        arm*) GO_DL_ARCH='armv6l';; \
                        s390x) GO_DL_ARCH='s390x';; \
                        *) echo >&2 "error: unsupported architecture"; exit 1 ;; \
                esac; \
        mkdir -vp "${GOROOT_BOOTSTRAP}"; \
        wget -qO- "https://dl.google.com/go/go${GO_BOOTSTRAP_VERSION}.$(uname -s | tr '[[:upper:]]' '[[:lower:]]')-${GO_DL_ARCH}.tar.gz" | tar zxf - -C "${GOROOT_BOOTSTRAP}" --strip-components=1; \
        export \
                PATH="${GOPATH}/bin:${GOROOT_BOOTSTRAP}/bin:${PATH}" \
                GOROOT="${GOROOT_BOOTSTRAP}"; \
        ${GOROOT_BOOTSTRAP}/bin/go version; \
        wget -qO- "https://dl.google.com/go/go${GO_VERSION}.src.tar.gz" | tar zxf - -C /usr/local; \
        export \
                GO_LDFLAGS="${GO_LDFLAGS}" \
                GOROOT_BOOTSTRAP="$(${GOROOT_BOOTSTRAP}/bin/go env GOROOT)" \
                GOOS="$(${GOROOT_BOOTSTRAP}/bin/go env GOOS)" \
                GOARCH="$(${GOROOT_BOOTSTRAP}/bin/go env GOARCH)" \
                GOHOSTOS="$(${GOROOT_BOOTSTRAP}/bin/go env GOHOSTOS)" \
                GOHOSTARCH="$(${GOROOT_BOOTSTRAP}/bin/go env GOHOSTARCH)"; \
        cd /usr/local/go/src; \
        ./make.bash; \
        rm -rf ~/.cache "${GOROOT_BOOTSTRAP}" /usr/local/go/pkg/bootstrap /usr/local/go/pkg/obj /usr/local/go/doc /usr/local/go/test

FROM    ${FROM}

COPY    --from=0        /usr/local/go   /usr/local/go

SHELL   ["/bin/bash", "-euvxo", "pipefail", "-c"]

ENV     GOROOT="/usr/local/go"
ENV     GOPATH="/opt/go"

ENV     PATH="${GOROOT}/bin:${GOPATH}/bin:/usr/local/go/bin:${PATH}"

WORKDIR "${GOPATH}"

ENV     GO_LDFLAGS="-s -w"

RUN     go env && env | grep GO && go version
