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