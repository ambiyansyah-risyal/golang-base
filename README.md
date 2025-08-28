[![CI](https://github.com/ambiyansyah-risyal/golang-base/actions/workflows/ci.yml/badge.svg)](https://github.com/ambiyansyah-risyal/golang-base/actions/workflows/ci.yml)

go mod tidy
go run ./cmd/server
go test ./...
docker build -t golang-base:latest .
docker run -p 8080:8080 golang-base:latest
# golang-base — Minimal Go REST API scaffold (Fiber, Docker, Goose migrations)

A compact, production-ready Go starter template for building HTTP APIs with Fiber, containerized deployments, and migrations using Goose. This repository is ideal for developers who want a minimal, opinionated foundation for microservices and backend APIs.

Key topics: golang, go, fiber, http api, docker, migration, goose, postgres, mysql, testing, ci

## Highlights

- Lightweight HTTP server using github.com/gofiber/fiber (fast, Express-like API)
- Graceful shutdown and sensible defaults
- Migration tooling with pressly/goose (Postgres & MySQL supported)
- Docker multi-stage build for small production images
- Makefile with common developer tasks (build, test, docker, migrate)

## Quick start

1. Clone the repository and enter the directory:

```bash
git clone https://github.com/ambiyansyah-risyal/golang-base.git
cd golang-base
```

2. Download modules and tidy dependencies:

```bash
go mod tidy
```

3. Run the server locally (default port 8080):

```bash
go run ./cmd/server
# or use the Makefile target
make run
```

Health check: http://localhost:8080/health
Root API example: GET http://localhost:8080/ returns a JSON message

## Configuration

Configuration is read from environment variables. You can create a `.env` file (the project uses `github.com/joho/godotenv` when present).

Required/commonly used variables:

- DB_DRIVER — `postgres` or `mysql` (required for migrations)
- DB_HOST — database host (default in sample config: `localhost`)
- DB_PORT — database port (e.g. `5432`)
- DB_USER — database user
- DB_PASSWORD — database password
- DB_NAME — database name
- DB_SSLMODE — Postgres sslmode (e.g. `disable`)

Example `.env` (development):

```env
DB_DRIVER=postgres
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=golang_base
DB_SSLMODE=disable
```

The project uses environment variables for configuration.

## Database migrations (goose)

The project includes `cmd/migrate` which wraps pressly/goose. Use the Makefile helpers or run directly.

- Create a new SQL migration:

```bash
make migrate-create NAME=add_users
# or
go run ./cmd/migrate create add_users sql
```

- Apply migrations:

```bash
make migrate-up
# or
go run ./cmd/migrate up
```

- Revert last migration:

```bash
make migrate-down
```

Migration files live under `migrations/`.

## Docker

Build and run the production image (multi-stage Dockerfile creates a small runtime image):

```bash
docker build -t golang-base:latest .
docker run -p 8080:8080 golang-base:latest
```

The Docker image exposes port 8080 by default.

## Development commands (Makefile)

- `make deps` — tidy and download modules
- `make fmt` — run gofmt
- `make lint` — run golangci-lint (if installed)
- `make test` — run unit tests
- `make check-coverage` — run tests with coverage gate (script in `scripts/`)
-- `make build` — build a binary into `./bin/server`
-- `make run` — run the built binary (`./bin/server`)

See `Makefile` for more options (migration helpers, docker-build, install-hooks).

## Running tests & coverage

Run the full test suite:

```bash
go test ./...
```

There is a coverage check helper at `scripts/check_coverage.sh` that the Makefile invokes via `make check-coverage`.

## Project structure

- `cmd/server/` — application entrypoint that starts the server and performs graceful shutdown
- `cmd/migrate/` — migration runner using pressly/goose
- `internal/server/` — Fiber app, routes and server lifecycle (Start / Shutdown)
- `internal/config/` — environment loading and DSN generation
- `internal/handler/` — HTTP handlers (minimal)
- `migrations/` — SQL migration files for Goose
-- `Dockerfile`, `Makefile` — ops and tooling

## Module & dependencies

Module path (see `go.mod`): `github.com/ambiyansyah-risyal/golang-base`

Key dependencies:

- github.com/gofiber/fiber/v2 (HTTP framework)
- github.com/pressly/goose/v3 (database migrations)
- github.com/joho/godotenv (optional .env loader)

## Notes & recommended next steps

- Add CI (GitHub Actions) to run `go test ./...`, lint and coverage checks on PRs.
- Expand handlers and wire a service layer for business logic.
- Add structured logging and observability (metrics, traces) for production readiness.
- Harden Docker image and add healthcheck metadata for orchestrators.

## Contributing

Contributions are welcome. Please open an issue or pull request and follow standard GitHub contribution workflows.

## License

This project is licensed under the MIT License — see `LICENSE` for details.
