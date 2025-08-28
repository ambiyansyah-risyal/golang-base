# golang-base

Minimal Go project boilerplate.

Quickstart

1. Update module path in `go.mod` to your repo (e.g. `github.com/<you>/golang-base`).
2. Build: `go build ./...`
3. Test: `go test ./...`
4. Run: `go run ./cmd/app`

Files of interest:
- `cmd/app/main.go` - small HTTP server
- `internal/handlers` - example handler + tests
- `pkg/version` - version variable (override at build time)

Makefile targets:
- `make build`, `make test`, `make run`, `make docker`
