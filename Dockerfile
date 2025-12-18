# ---------- build stage ----------
FROM golang:1.22-alpine AS builder

RUN apk add --no-cache git make nodejs

# Enable Corepack + correct Yarn version
RUN corepack enable && corepack prepare yarn@4.4.0 --activate

WORKDIR /src
RUN git clone https://github.com/OpenMaxIO/openmaxio-object-browser.git .

# build web assets
RUN cd web-app && git checkout v1.7.6 && yarn install && yarn build

# build console binary
RUN make console

# ---------- runtime stage ----------
FROM alpine:3.20
RUN adduser -D -H -s /sbin/nologin console
WORKDIR /app
COPY --from=builder /src/console /app/console
USER console
EXPOSE 9090
ENTRYPOINT ["/app/console","server"]
