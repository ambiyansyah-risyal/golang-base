.PHONY: build run test clean docker-build docker-run docker-stop dev-setup help \
	migrate-create migrate-up migrate-down migrate-status migrate-reset \
	docker-migrate-up docker-migrate-down docker-migrate-status install-goose \
	dev-up dev-down dev-logs

# Variables
BINARY_NAME=golang-base
DOCKER_IMAGE=golang-base:latest
DOCKER_CONTAINER=golang-base-app

# Database connection string for migrations (override by exporting DATABASE_URL)
DB_URL?=$(DATABASE_URL)
ifeq ($(strip $(DB_URL)),)
DB_URL:=postgres://user:password@localhost:5432/golang_base?sslmode=disable
endif

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
	rm -rf bin/
	rm -f coverage.out coverage.html
	@echo "Clean complete"

dev-setup: ## Set up development environment
	@echo "Setting up development environment..."
	cp .env.example .env
	go mod tidy
	go mod download
	@echo "Development setup complete"

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
	@echo "DB ready. You can now run 'make run' to start the app locally."

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
	GOOSE_DRIVER=postgres GOOSE_DBSTRING=postgres://user:password@localhost:5432/golang_base?sslmode=disable goose -dir ./migrations up

docker-migrate-down: ## Rollback migrations against docker postgres
	@echo "Rolling back migrations against docker postgres..."
	GOOSE_DRIVER=postgres GOOSE_DBSTRING=postgres://user:password@localhost:5432/golang_base?sslmode=disable goose -dir ./migrations down

docker-migrate-status: ## Show migration status against docker postgres
	GOOSE_DRIVER=postgres GOOSE_DBSTRING=postgres://user:password@localhost:5432/golang_base?sslmode=disable goose -dir ./migrations status

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
	@echo "Tools installed"

install-goose: ## Install goose database migration tool
	@echo "Installing goose..."
	go install github.com/pressly/goose/v3/cmd/goose@latest
	@echo "goose installed"

prod-deploy: ## Deploy to production (customize as needed)
	@echo "Deploying to production..."
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
	@echo "Production deployment complete"

backup-db: ## Backup database
	@echo "Creating database backup..."
	docker-compose exec postgres pg_dump -U user golang_base > backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "Database backup created"

restore-db: ## Restore database (usage: make restore-db BACKUP=backup_file.sql)
	@echo "Restoring database from $(BACKUP)..."
	docker-compose exec -T postgres psql -U user -d golang_base < $(BACKUP)
	@echo "Database restored"