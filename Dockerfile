ARG ARCH=amd64

FROM golang:alpine AS builder-amd64

FROM arm32v6/golang:alpine AS builder-arm32v6

FROM builder-${ARCH} AS builder

WORKDIR ${GOPATH}/src/github.com/mcuadros/ofelia
COPY . ${GOPATH}/src/github.com/mcuadros/ofelia

ENV CGO_ENABLED 0
ENV GOOS linux

RUN apk add --update --no-cache git \
 && go get -v ./... \
 && go build -a -installsuffix cgo -ldflags '-w  -extldflags "-static"' -o /go/bin/ofelia .


FROM alpine:latest

RUN apk add --update --no-cache ca-certificates tzdata

COPY --from=builder /go/bin/ofelia /usr/bin/ofelia

VOLUME /etc/ofelia/
ENTRYPOINT ["/usr/bin/ofelia"]

CMD ["daemon", "--config", "/etc/ofelia/config.ini"]
