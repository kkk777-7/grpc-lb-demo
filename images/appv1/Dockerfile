FROM golang:1.21.0-bullseye as builder

WORKDIR /app

COPY go.mod go.mod
COPY go.sum go.sum
COPY . .

RUN make bin/app

FROM debian:buster
COPY --from=builder /app/bin/app .

RUN apt update && \
    apt upgrade -y && \
    apt install -y curl && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["./app"]