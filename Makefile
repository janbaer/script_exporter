GO    := go
pkgs   = $(shell $(GO) list ./... | grep -v /vendor/)

PREFIX                  ?= $(shell pwd)
BIN_DIR                 ?= $(shell pwd)
VERSION                 = `cat VERSION`
DOCKER_IMAGE_NAME       ?= janbaer/script-exporter
DOCKER_IMAGE_TAG        ?= $(subst /,-,$(shell git rev-parse --abbrev-ref HEAD))


all: format build test

style:
	@echo ">> checking code style"
	@! gofmt -d $(shell find . -path ./vendor -prune -o -name '*.go' -print) | grep '^'

test:
	@echo ">> running tests"
	@$(GO) test -short $(pkgs)

format:
	@echo ">> formatting code"
	@$(GO) fmt $(pkgs)

vet:
	@echo ">> vetting code"
	@$(GO) vet $(pkgs)

build:
	@echo ">> building binary"
	@GOOS=linux GOARCH=amd64 $(GO) build -o script-exporter script_exporter.go

tarball: build
	@echo ">> building release tarball"
	@tar -czvf "script_exporter-$(VERSION).linux-amd64.tar.gz" script-exporter

docker:
	@echo ">> building docker image"
	@docker build -t "$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)" .
	@docker tag "$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)" "$(DOCKER_IMAGE_NAME):$(VERSION)"

deps:
	$(GO) mod download

.PHONY: all style format build test vet tarball docker deps
