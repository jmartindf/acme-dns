FROM golang:1.22.4-alpine AS builder
LABEL maintainer="joona@kuori.org"

RUN apk add -U --no-cache ca-certificates gcc musl-dev git

WORKDIR /build
COPY . .

RUN CGO_ENABLED=1 go build -ldflags="-extldflags=-static" -tags sqlite_omit_load_extension

FROM scratch

COPY --from=builder /build/acme-dns /
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

EXPOSE 53/udp 53 80 443
ENTRYPOINT ["/acme-dns"]
VOLUME ["/etc/acme-dns", "/var/lib/acme-dns"]
