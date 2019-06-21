FROM	nexus166/gobld:_BASE_TAG_

FROM	alpine:_TAG_

SHELL	["/bin/ash", "-xeuo", "pipefail", "-c"]

RUN	mkdir -vp /lib64; \
	ln -vs "/lib/libc.musl-$(uname -m).so.1" "/lib64/ld-linux-$(uname -m | tr '_' '-').so.2" || true; \
	ln -vs "/lib/libc.musl-$(uname -m).so.1" /lib/ld64.so.1 || true
	
RUN	apk update; \
	apk upgrade; \
	apk add --update --upgrade --no-cache \
		binutils ca-certificates git;

ENV     GOPATH="/opt/go" GOROOT="/usr/local/go"
ENV	PATH="${GOROOT}/bin:${GOPATH}/bin:${PATH}"

COPY    --from=0 "${GOROOT}" "${GOROOT}"

RUN	go env && env | grep GO && go version
