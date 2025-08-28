# golang-base

A minimal Go web project scaffold using Fiber (high-performance web framework).

This repository is a lightweight starting point for building HTTP services in Go.

Prerequisites
- Go 1.21 or newer
- Docker (optional, for container builds)

Quickstart

1) Initialize module & download deps (if you haven't already):
# golang-base

A minimal Go web project scaffold using Fiber (high-performance web framework).

This repository is a lightweight starting point for building HTTP services in Go.

## Prerequisites

- Go 1.21 or newer
- Docker (optional, for container builds)

## Quickstart

1) Initialize module & download deps (if you haven't already):

```bash
go mod init github.com/ambiyansyah-risyal/golang-base
go mod tidy
```

2) Run the server locally:

```bash
go run ./cmd/server
# or
make run
```

The server listens on :8080 by default. Health check: http://localhost:8080/health

## Testing

Run unit tests:

```bash
go test ./...
```

## Docker

Build and run the container:

```bash
docker build -t golang-base:latest .
docker run -p 8080:8080 golang-base:latest
```

## Project layout

- `cmd/server/main.go` — application entry, graceful shutdown
- `internal/server/server.go` — Fiber app and helpers
- `internal/handler/` — small package (placeholder) for handlers
- `Makefile` — convenience targets: `build`, `run`, `test`, `docker`
- `Dockerfile` — multi-stage container build

## Notes & next steps

- The project uses Fiber for high performance HTTP handling; if you prefer a different framework (Gin, Echo), I can switch it.
- Consider adding CI (GitHub Actions) to run `go test` and static checks on push.
- Add more examples (middleware, metrics, OpenAPI) as needed.

## License

This project is released under the MIT License — see `LICENSE` for details.
