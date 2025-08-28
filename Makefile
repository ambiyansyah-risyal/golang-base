MODULE=github.com/yourusername/golang-base
BINARY=golang-base

.PHONY: build test run docker

build:
	go build -v ./...

test:
	go test ./...

run:
	go run ./cmd/app

docker:
	docker build -t $(BINARY):latest .
