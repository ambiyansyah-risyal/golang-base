.PHONY: build run test clean docker-build docker-run docker-stop dev-setup help

# Variables
BINARY_NAME=golang-base
DOCKER_IMAGE=golang-base:latest
DOCKER_CONTAINER=golang-base-app

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

migrate-up: ## Run database migrations up
	@echo "Running database migrations..."
	# Add your migration command here
	@echo "Migrations complete"

migrate-down: ## Run database migrations down
	@echo "Rolling back database migrations..."
	# Add your migration rollback command here
	@echo "Rollback complete"

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
	@echo "Tools installed"

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