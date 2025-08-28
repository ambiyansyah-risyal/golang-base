BIN=bin/server

.PHONY: build run docker test

build:
	go build -o $(BIN) ./cmd/server

run: build
	./$(BIN)

docker:
	docker build -t golang-base:latest .

test:
	go test ./... 

lint:
	# requires golangci-lint: https://golangci-lint.run/usage/install/
	golangci-lint run ./...
