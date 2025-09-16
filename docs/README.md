# Documentation Hub

Welcome to the GoLang-Base documentation hub. This page centralizes all the important docs so you can get productive fast.

## Quick Start

- One-command setup: `make dev-check`
  - Validates your local environment, starts Postgres/Redis, runs migrations, boots the app, and verifies `/health`.
- Manual setup: see the Quick Start in the root `README.md`.

## Guides

- Getting Started & Project Overview: [Root README](../README.md)
- Security Guidelines: [SECURITY.md](./SECURITY.md)
- Migrations: [migrations/README.md](../migrations/README.md)
- Scripts & Utilities: [docs/scripts/README.md](./scripts/README.md)

## Developer Environment

- Docker Compose loads `.env` via `env_file` and services connect to Postgres via the `postgres` service hostname (not `localhost`).
- Make targets:
  - `make dev-check` — validate environment and stack
  - `make docker-run` — run full stack
  - `make migrate-up` — apply DB migrations
  - `make migrate-create NAME=...` — generate a new migration

## Troubleshooting

- If app health is unhealthy at first, the script falls back to hitting `/health`. Tail logs:
  ```bash
  docker compose logs -f app postgres redis
  ```
- Ensure `.env` exists; the check will copy from `.env.example` if missing.

## Policies

- Do not commit real secrets to version control. Use `.env` for local dev only.
- For production, set env vars via your orchestrator or secret store. See [SECURITY.md](./SECURITY.md).

## Contributing

- Prefer Conventional Commits (feat, fix, chore, docs, etc.)
- Run `make lint` and `make test` before pushing
- Add or update docs if your change affects setup, security, or developer workflow
