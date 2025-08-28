# Project settings
APP_NAME := golang-base
BIN_DIR  := bin
BIN      := $(BIN_DIR)/server

# Build settings (override when needed)
BUILD_MODE ?= production
GOOS        ?= linux
GOARCH      ?= amd64
CGO_ENABLED ?= 0
LD_FLAGS    ?= -s -w

# Docker settings
DOCKER_TAG ?= latest

# Migration settings
MIGRATE_NAME ?=

# Default goal
.DEFAULT_GOAL := help

.PHONY: help build clean run install docker-build deps fmt lint test develop \
	migrate-create migrate-up migrate-down migrate-status

help:
	@printf "\nUsage: make <target> [VAR=value]\n\n"
	@printf "Available targets:\n"
	@printf "  %-18s %s\n" build "Build the project (cross-arch via GOOS/GOARCH)"
	@printf "  %-18s %s\n" run "Run the built binary (doesn't force rebuild)"
	@printf "  %-18s %s\n" install "Install binary to \
								GOBIN/GOPATH/bin via 'go install'"
	@printf "  %-18s %s\n" develop "Start local auto-reload (uses 'air' if installed)"
	@printf "  %-18s %s\n" fmt "Run 'go fmt' on the module"
	@printf "  %-18s %s\n" lint "Run linter (requires golangci-lint)"
	@printf "  %-18s %s\n" deps "Download and tidy dependencies"
	@printf "  %-18s %s\n" test "Run unit tests"
	@printf "  %-18s %s\n" clean "Remove build artifacts"
	@printf "  %-18s %s\n" docker-build "Build docker image (use DOCKER_TAG)"
	@printf "\nMigration helpers:\n"
	@printf "  %-18s %s\n" "migrate-create" "Create migration file: NAME=<name>"
	@printf "  %-18s %s\n" "migrate-up" "Apply pending migrations"
	@printf "  %-18s %s\n" "migrate-down" "Revert last migration"
	@printf "  %-18s %s\n" "migrate-status" "Show migration status"
	@printf "\nExamples:\n"
	@printf "  make build\n"
	@printf "  make build GOOS=darwin GOARCH=arm64\n"
	@printf "  make migrate-create NAME=add_users\n\n"

# Build (produces $(BIN))
build:
	@echo "Building $(APP_NAME) [mode=$(BUILD_MODE) GOOS=$(GOOS) GOARCH=$(GOARCH)]"
	@mkdir -p $(BIN_DIR)
	@env CGO_ENABLED=$(CGO_ENABLED) GOOS=$(GOOS) GOARCH=$(GOARCH) \
		go build -ldflags "$(LD_FLAGS)" -o $(BIN) ./cmd/server

# Run without forcing a rebuild
run:
	@if [ -x "$(BIN)" ]; then \
		echo "Running $(BIN)..."; \
		./$(BIN) --config=config.yaml; \
	else \
		echo "Binary not found, use 'make build' or 'go run ./cmd/server'"; exit 1; \
	fi

# Install to $GOBIN (or default GOPATH/bin with Go tooling)
install:
	@echo "Installing $(APP_NAME) to your Go bin"
	@go install ./cmd/server

# Development with auto-reload
develop:
	@echo "Starting development auto-reload (air)"
	@command -v air >/dev/null 2>&1 || { echo "'air' not installed, installing..."; go install github.com/cosmtrek/air@latest; }
	@air

# Formatting, linting, testing, deps
fmt:
	@echo "Formatting code..."
	@gofmt -s -w .

lint:
	@command -v golangci-lint >/dev/null 2>&1 || { echo "golangci-lint not found; see https://golangci-lint.run/usage/install/"; exit 1; }
	@echo "Running linter..."
	@golangci-lint run ./...

deps:
	@echo "Tidying and downloading dependencies..."
	@go mod tidy
	@go mod download

test:
	@echo "Running tests..."
	@go test ./...

clean:
	@echo "Cleaning up..."
	@rm -rf $(BIN_DIR)

# Docker
docker-build:
	@echo "Building docker image $(APP_NAME):$(DOCKER_TAG)"
	docker build -t $(APP_NAME):$(DOCKER_TAG) .

# Migration helpers (use NAME=... to create)
migrate-create:
	@if [ -z "$(NAME)" ]; then \
		echo "Please provide NAME for migration: make migrate-create NAME=add_users"; exit 1; \
	fi
	@go run ./cmd/migrate create $(NAME) sql

migrate-up:
	@echo "Applying migrations..."
	@go run ./cmd/migrate up

migrate-down:
	@echo "Reverting last migration..."
	@go run ./cmd/migrate down

migrate-status:
	@echo "Migration status:"
	@go run ./cmd/migrate status
