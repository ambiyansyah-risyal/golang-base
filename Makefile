.PHONY: build run test clean docker-build docker-run docker-stop dev-setup help \
	migrate-create migrate-up migrate-down migrate-status migrate-reset \
	docker-migrate-up docker-migrate-down docker-migrate-status install-goose \
	dev-up dev-down dev-logs load-env dev-check dev install-air

# =============================================================================
# SECURITY NOTICE: Database Credential Management
# =============================================================================
# This Makefile uses environment variables for database credentials to prevent
# hardcoding sensitive information. The following environment variables are used:
#   - DB_HOST: Database host (default: localhost)
#   - DB_PORT: Database port (default: 5432)
#   - DB_USER: Database username (default: user)
#   - DB_PASSWORD: Database password (default: password)
#   - DB_NAME: Database name (default: golang_base)
#   - DB_SSLMODE: SSL mode (default: disable)
#
# For production deployments:
# 1. Set these as environment variables or use a secrets management system
# 2. Never commit real credentials to version control
# 3. Use strong, unique passwords
# 4. Enable SSL/TLS (set DB_SSLMODE=require)
# 5. Rotate credentials regularly
# =============================================================================

# Variables
BINARY_NAME=golang-base
DOCKER_IMAGE=golang-base:latest
DOCKER_CONTAINER=golang-base-app

# Secure Database Configuration - Load from environment variables
# These can be overridden by setting environment variables or loaded from .env file
DB_HOST?=localhost
DB_PORT?=5432
DB_USER?=user
DB_PASSWORD?=password
DB_NAME?=golang_base
DB_SSLMODE?=disable

# Construct database URL from components for security
# Override by exporting DATABASE_URL if you want to use a full connection string
DB_URL?=$(DATABASE_URL)
ifeq ($(strip $(DB_URL)),)
DB_URL:=postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=$(DB_SSLMODE)
endif

# Docker-specific database URL (when using docker-compose services)
DOCKER_DB_URL:=postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=$(DB_SSLMODE)

# Default target
.DEFAULT_GOAL := help

help: ## Display this help message
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the application binary
	@echo "Building application..."
	go build -o bin/$(BINARY_NAME) ./cmd/server
	@echo "Build complete: bin/$(BINARY_NAME)"

run: ## Run the application
	@echo "Starting application..."
	go run ./cmd/server

dev: ## Run the application with auto-reload (requires Air)
	@echo "Starting application with auto-reload..."
	@if ! command -v air >/dev/null 2>&1; then \
		echo "Air not found. Installing..."; \
		$(MAKE) install-air; \
	fi
	@mkdir -p tmp
	air

test: ## Run tests
	@echo "Running tests..."
	go test -v ./...

test-coverage: ## Run tests with coverage
	@echo "Running tests with coverage..."
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

clean: ## Clean build artifacts
	@echo "Cleaning..."
	rm -rf bin/ tmp/
	rm -f coverage.out coverage.html
	@echo "Clean complete"

dev-setup: ## Set up development environment
	@echo "Setting up development environment..."
	cp .env.example .env
	go mod tidy
	go mod download
	@echo "Development setup complete"
	@echo ""
	@echo "SECURITY NOTICE:"
	@echo "Please update the database credentials in .env file before running migrations!"
	@echo "Default credentials should only be used for local development."

load-env: ## Load environment variables from .env file (for secure credential management)
	@echo "Loading environment variables from .env file..."
	@if [ -f .env ]; then \
		export $$(cat .env | grep -v '^#' | xargs); \
		echo "Environment variables loaded successfully"; \
	else \
		echo "ERROR: .env file not found. Run 'make dev-setup' first."; \
		exit 1; \
	fi

dev-check: ## Validate local dev stack (env, postgres, redis, migrations, app health)
	@echo "Running developer environment readiness check..."
	@chmod +x scripts/dev_check.sh
	@./scripts/dev_check.sh

docker-build: ## Build Docker image
	@echo "Building Docker image..."
	docker build -t $(DOCKER_IMAGE) .
	@echo "Docker image built: $(DOCKER_IMAGE)"

docker-run: ## Run application in Docker
	@echo "Starting Docker containers..."
	docker compose up -d
	@echo "Application running at http://localhost:3000"

docker-stop: ## Stop Docker containers
	@echo "Stopping Docker containers..."
	docker compose down
	@echo "Docker containers stopped"

docker-logs: ## View Docker logs
	docker compose logs -f app

docker-clean: ## Clean Docker images and containers
	@echo "Cleaning Docker..."
	docker compose down -v --remove-orphans
	docker rmi $(DOCKER_IMAGE) || true
	@echo "Docker cleanup complete"

dev-up: ## Start only DB dependencies (postgres, redis) and run migrations for local dev
	@echo "Starting DB dependencies for local dev..."
	docker compose up -d postgres redis
	@echo "Running DB migrations (one-shot)..."
	docker compose run --rm migrator
	@echo "DB ready. You can now run 'make dev' for auto-reload development or 'make run' for standard mode."

dev-down: ## Stop DB dependencies for local dev
	@echo "Stopping DB dependencies..."
	docker compose rm -sfv migrator || true
	docker compose down
	@echo "DB dependencies stopped"

dev-logs: ## Tail logs for postgres and redis
	docker compose logs -f postgres redis

migrate-create: ## Create a new migration (usage: make migrate-create NAME=create_users_table)
	@if [ -z "$(NAME)" ]; then echo "NAME is required, e.g., make migrate-create NAME=create_users_table"; exit 1; fi
	@echo "Creating new migration: $(NAME)"
	goose -dir ./migrations create $(NAME) sql

migrate-up: ## Run database migrations up (local env)
	@echo "Running database migrations up..."
	GOOSE_DRIVER=postgres GOOSE_DBSTRING="$(DB_URL)" goose -dir ./migrations up

migrate-down: ## Run database migrations down (local env)
	@echo "Rolling back database migrations..."
	GOOSE_DRIVER=postgres GOOSE_DBSTRING="$(DB_URL)" goose -dir ./migrations down

migrate-status: ## Show migration status (local env)
	GOOSE_DRIVER=postgres GOOSE_DBSTRING="$(DB_URL)" goose -dir ./migrations status

migrate-reset: ## Reset database to initial state (local env)
	GOOSE_DRIVER=postgres GOOSE_DBSTRING="$(DB_URL)" goose -dir ./migrations reset

docker-migrate-up: ## Run migrations against docker postgres
	@echo "Running migrations against docker postgres..."
	GOOSE_DRIVER=postgres GOOSE_DBSTRING="$(DOCKER_DB_URL)" goose -dir ./migrations up

docker-migrate-down: ## Rollback migrations against docker postgres
	@echo "Rolling back migrations against docker postgres..."
	GOOSE_DRIVER=postgres GOOSE_DBSTRING="$(DOCKER_DB_URL)" goose -dir ./migrations down

docker-migrate-status: ## Show migration status against docker postgres
	GOOSE_DRIVER=postgres GOOSE_DBSTRING="$(DOCKER_DB_URL)" goose -dir ./migrations status

lint: ## Run linter
	@echo "Running linter..."
	golangci-lint run
	@echo "Linting complete"

format: ## Format code
	@echo "Formatting code..."
	go fmt ./...
	@echo "Formatting complete"

security-check: ## Run security checks
	@echo "Running security checks..."
	gosec ./...
	@echo "Security check complete"

deps-check: ## Check for dependency updates
	@echo "Checking for dependency updates..."
	go list -u -m all
	@echo "Dependency check complete"

install-tools: ## Install development tools
	@echo "Installing development tools..."
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	go install github.com/securecodewarrior/gosec/v2/cmd/gosec@latest
	$(MAKE) install-goose
	$(MAKE) install-air
	@echo "Tools installed"

install-goose: ## Install goose database migration tool
	@echo "Installing goose..."
	go install github.com/pressly/goose/v3/cmd/goose@latest
	@echo "goose installed"

install-air: ## Install Air live-reload tool for development
	@echo "Installing Air..."
	go install github.com/air-verse/air@latest
	@echo "Air installed. You can now use 'make dev' for auto-reload development."

prod-deploy: ## Deploy to production (customize as needed)
	@echo "Deploying to production..."
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
	@echo "Production deployment complete"

backup-db: ## Backup database
	@echo "Creating database backup..."
	docker-compose exec postgres pg_dump -U $(DB_USER) $(DB_NAME) > backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "Database backup created"

restore-db: ## Restore database (usage: make restore-db BACKUP=backup_file.sql)
	@echo "Restoring database from $(BACKUP)..."
	docker-compose exec -T postgres psql -U $(DB_USER) -d $(DB_NAME) < $(BACKUP)
	@echo "Database restored"

generate-password-hash: ## Generate bcrypt hash for password (usage: make generate-password-hash PASSWORD=yourpassword)
	@if [ -z "$(PASSWORD)" ]; then echo "PASSWORD is required, e.g., make generate-password-hash PASSWORD=mypassword123"; exit 1; fi
	@echo "Generating bcrypt hash for password..."
	cd scripts && go run generate_password_hash.go "$(PASSWORD)"