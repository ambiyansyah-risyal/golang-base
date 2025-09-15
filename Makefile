APP_NAME=server
BIN_DIR=bin
PKG=./...
CMD=./cmd/server

# Database connection (for Goose)
DB_HOST?=localhost
DB_PORT?=5432
DB_USER?=postgres
DB_PASSWORD?=postgres
DB_NAME?=appdb
DB_SSLMODE?=disable
DB_DSN=postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=$(DB_SSLMODE)

.PHONY: run build test fmt vet tidy clean

run:
	go run $(CMD)

build:
	mkdir -p $(BIN_DIR)
	go build -o $(BIN_DIR)/$(APP_NAME) $(CMD)

test:
	go test $(PKG) -race -cover

fmt:
	go fmt $(PKG)

vet:
	go vet $(PKG)

tidy:
	go mod tidy

clean:
	rm -rf $(BIN_DIR)

# Goose migrations via go run (no global install needed)
.PHONY: migrate-create migrate-up migrate-down migrate-status

migrate-create:
	@if [ -z "$(name)" ]; then echo "Usage: make migrate-create name=add_users"; exit 1; fi
	go run github.com/pressly/goose/v3/cmd/goose -dir ./migrations create $(name) sql

migrate-up:
	GOOSE_DRIVER=postgres GOOSE_DBSTRING=$(DB_DSN) go run github.com/pressly/goose/v3/cmd/goose -dir ./migrations up

migrate-down:
	GOOSE_DRIVER=postgres GOOSE_DBSTRING=$(DB_DSN) go run github.com/pressly/goose/v3/cmd/goose -dir ./migrations down

migrate-status:
	GOOSE_DRIVER=postgres GOOSE_DBSTRING=$(DB_DSN) go run github.com/pressly/goose/v3/cmd/goose -dir ./migrations status

# Docker helpers
.PHONY: docker-build docker-up docker-down

docker-build:
	docker build -t golang-base:dev .

docker-up:
	docker compose up -d

docker-down:
	docker compose down -v

