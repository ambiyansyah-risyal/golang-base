# Contributing

## Principles
- **Clean Architecture**: inner layers (`domain`, `usecase`) must not import outer layers.
- **SOLID**: small, single-purpose packages; ports in `internal/interface`; adapters implement ports.

## Workflow
1. Create a feature branch from `main`
2. Follow **Conventional Commits**
3. Write tests (table-driven), run `make fmt lint test`
4. Open PR; CI must pass

## Commit Convention
- `feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:`
- Example: `feat(user): add Register use case`

## Code Style
- `gofumpt` formatting
- `golangci-lint` must pass
- Prefer `context.Context` as first param
- Wrap errors with `%w`

## Testing
- Unit tests in same package: `*_test.go`
- Use table-driven tests; avoid global state
