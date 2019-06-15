FROM	nexus166/gobld:_BASE_TAG_

FROM	alpine:_TAG_

SHELL	["/bin/ash", "-xeuo", "pipefail", "-c"]

ENV	GOPATH="/opt/go"
ENV	GOROOT="/usr/local/go"

COPY	--from=0 "${GOROOT}" "${GOROOT}"

RUN	mkdir -vp /lib64; \
	ln -vs "/lib/libc.musl-$(uname -m).so.1" "/lib64/ld-linux-$(uname -m | tr '_' '-').so.2" || true; \
	ln -vs "/lib/libc.musl-$(uname -m).so.1" /lib/ld64.so.1 || true
	
RUN	apk update; \
	apk upgrade; \
	apk add --update --upgrade --no-cache \
		binutils ca-certificates git;

ENV	PATH="${GOROOT}/bin:${GOPATH}/bin:${PATH}"

RUN	go env && env | grep GO && go version
