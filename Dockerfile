# ---------- build stage ----------
FROM node:22-alpine AS webbuilder

RUN corepack enable && corepack prepare yarn@4.4.0 --activate

WORKDIR /src
RUN apk add --no-cache git
RUN git clone https://github.com/OpenMaxIO/openmaxio-object-browser.git .

RUN cd web-app && git checkout v1.7.6 && yarn install && yarn build


# ---------- go build stage ----------
FROM golang:1.23-alpine AS gobuilder

RUN apk add --no-cache git make

WORKDIR /src
RUN git clone https://github.com/OpenMaxIO/openmaxio-object-browser.git .
RUN git checkout v1.7.6

# copy built web assets from previous stage
COPY --from=webbuilder /src/web-app/build /src/web-app/build

RUN make console


# ---------- runtime stage ----------
FROM alpine:3.20
RUN adduser -D -H -s /sbin/nologin console
WORKDIR /app
COPY --from=gobuilder /src/console /app/console
USER console
EXPOSE 9090
ENTRYPOINT ["/app/console","server"]
