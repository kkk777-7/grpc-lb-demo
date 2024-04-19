.PHONY: go-install
go-install:
	go install \
    github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway \
    github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2 \
    google.golang.org/protobuf/cmd/protoc-gen-go \
    google.golang.org/grpc/cmd/protoc-gen-go-grpc \
    github.com/envoyproxy/protoc-gen-validate/cmd/protoc-gen-validate-go

.PHONY: buf-generate
buf-generate: go-install
	buf generate --path proto/app/v1

.PHONY: buf-lint
buf-lint:
	buf lint

.PHONY: buf-format
buf-format:
	buf format -w

.PHONY: buf-mod-update
buf-mod-update:
	buf mod update

check: buf-mod-update buf-format buf-generate

GOOS ?= linux
GOARCH ?= amd64
TAG ?= dev
IMG ?= 
LDFLAGS ?= \
	-X github.com/cycloud-io/sdk-go/pkg/version.gitVersion=$(shell git describe --tags --match='v*' --abbrev=0) \
	-X github.com/cycloud-io/sdk-go/pkg/version.gitCommit=$(shell git rev-parse HEAD) \
	-X github.com/cycloud-io/sdk-go/pkg/version.buildDate=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ')

bin:
	mkdir -p $@

.PHONY: bin/app
bin/app: bin
	CGO_ENABLED=0 GOOS=$(GOOS) GOARCH=$(GOARCH) go build -ldflags="$(LDFLAGS)" -o $@ -v ./cmd/server

.PHONY: docker-build
docker-build:
	docker build --platform $(GOOS)/$(GOARCH) -f ./images/appv1/Dockerfile -t kkk777/grpc-lb-demo:$(TAG) .

.PHONY: docker-push
docker-push:
	docker push kkk777/grpc-lb-demo:$(TAG)