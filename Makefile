# ============================================================================
# golang-base — Makefile
#
# Purpose : Build, test, lint and utility targets for the golang-base project.
# Maintainer: ambiyansyah-risyal <noreply@github.com>
# License  : MIT (see LICENSE)
# Usage    : make <target> [VAR=value]
# Recommended: GNU Make 4.0+
# Notes    : - Use `make check-coverage` to run tests with coverage enforcement.
#            - Run `make install-hooks` to install the pre-push hook.
# ============================================================================

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
	migrate-create migrate-up migrate-down migrate-status install-hooks check-coverage

help:
	@printf "\n"
	@printf "\033[1;36m============================================================\033[0m\n"
	@printf "\033[1;32m  %s\033[0m  — lightweight Go service scaffold\n" "$(APP_NAME)"
	@printf "  Commit: %s on %s\n" "$(shell git rev-parse --short HEAD 2>/dev/null || echo unknown)" "$(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
	@printf "  Go: %s\n" "$(shell go version 2>/dev/null || echo 'not found')"
	@printf "  Maintainer: ambiyansyah-risyal <noreply@github.com> | License: MIT\n"
	@printf "\033[1;36m============================================================\033[0m\n"
	@printf "\n"
	@if [ -f .git/hooks/pre-push ]; then \
		printf "\033[0;33mGit hooks:\033[0m installed (pre-push enabled)\n"; \
	else \
		printf "\033[0;31mGit hooks:\033[0m not installed — run 'make install-hooks'\n"; \
	fi
	@printf "\n"
	@printf "Tips: Run 'make check-coverage' to run tests with coverage enforcement.\n"
	@printf "      Use 'MIN_COVERAGE=85 make check-coverage' to lower threshold temporarily.\n\n"
	@printf "Usage: make <target> [VAR=value]\n\n"
	@printf "Available targets:\n"
	@printf "  %-18s %s\n" deps "Download and tidy dependencies"
	@printf "  %-18s %s\n" fmt "Run 'go fmt' on the module"
	@printf "  %-18s %s\n" lint "Run linter (requires golangci-lint)"
	@printf "  %-18s %s\n" check-coverage "Run tests with coverage enforcement"
	@printf "  %-18s %s\n" test "Run unit tests"
	@printf "  %-18s %s\n" build "Build the project (cross-arch via GOOS/GOARCH)"
	@printf "  %-18s %s\n" run "Run the built binary (doesn't force rebuild)"
	@printf "  %-18s %s\n" install "Install binary to GOBIN/GOPATH/bin via 'go install'"
	@printf "  %-18s %s\n" develop "Start local auto-reload (uses 'air' if installed)"
	@printf "  %-18s %s\n" docker-build "Build docker image (use DOCKER_TAG)"
	@printf "  %-18s %s\n" clean "Remove build artifacts"
	@printf "\nMigration helpers:\n"
	@printf "  %-18s %s\n" "migrate-create" "Create migration file: NAME=<name>"
	@printf "  %-18s %s\n" "migrate-up" "Apply pending migrations"
	@printf "  %-18s %s\n" "migrate-down" "Revert last migration"
	@printf "  %-18s %s\n" "migrate-status" "Show migration status"
	@printf "\nExamples:\n"
	@printf "  make build\n"
	@printf "  make build GOOS=darwin GOARCH=arm64\n"
	@printf "  make migrate-create NAME=add_users\n\n"

# Formatting, linting, testing, deps (recommended order)
deps:
	@echo "Tidying and downloading dependencies..."
	@go mod tidy
	@go mod download

fmt:
	@echo "Formatting code..."
	@gofmt -s -w .

lint:
	@command -v golangci-lint >/dev/null 2>&1 || { echo "golangci-lint not found; see https://golangci-lint.run/usage/install/"; exit 1; }
	@echo "Running linter..."
	@golangci-lint run ./...

check-coverage:
	@echo "Running coverage check (MIN_COVERAGE=${MIN_COVERAGE:-90})"
	@chmod +x ./scripts/check_coverage.sh || true
	@MIN_COVERAGE=${MIN_COVERAGE:-90} ./scripts/check_coverage.sh

test:
	@echo "Running tests..."
	@go test ./...

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
		./$(BIN); \
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
	@if command -v air >/dev/null 2>&1; then \
		echo "'air' found, starting..."; \
		air; \
	else \
		echo "'air' not installed, running scripts/install_air.sh..."; \
		bash ./scripts/install_air.sh; \
	fi

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

# Install git hooks from .githooks directory into .git/hooks
install-hooks:
	@echo "Installing git hooks from .githooks/ to .git/hooks/"
	@[ -d .git ] || (echo ".git directory not found - run from repository root" && exit 1)
	@mkdir -p .git/hooks
	@cp -r .githooks/* .git/hooks/ || true
	@chmod +x .git/hooks/* || true
	@echo "Hooks installed"

# Clean up build artifacts
clean:
	@echo "Cleaning up..."
	@rm -rf $(BIN_DIR)
