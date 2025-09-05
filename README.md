# Golang + Fiber + GORM Skeleton

A fresh Golang web skeleton featuring:

- Fiber v2 (fast HTTP framework)
- GORM (ORM) with PostgreSQL driver
- HTML templates via `github.com/gofiber/template/html/v2`
- Built-in Bootstrap 5 layout and example page
- `.env` support via `github.com/joho/godotenv`

## Quickstart

### Prerequisites
- Go 1.21+
- PostgreSQL (for DB operations)

### Setup

```bash
cp .env.example .env
# Update DB_* variables if needed
```

### Run

```bash
go run cmd/server/main.go
```

Visit `http://localhost:3000`.

## Configuration

- `PORT` (default: `3000`)
- `DB_HOST` (default: `localhost`)
- `DB_PORT` (default: `5432`)
- `DB_USER` (default: `postgres`)
- `DB_PASSWORD` (default: `postgres`)
- `DB_NAME` (default: `appdb`)
- `DB_SSLMODE` (default: `disable`)

## Structure

```
cmp/
  server/
    main.go
internal/
  config/
    env.go
  db/
    db.go
  web/
    layouts/
      main.html
    views/
      home.html
    public/
      css/app.css
      js/app.js
```

## Notes
- Templates load from `internal/web` with layouts. The home route renders `views/home` in `layouts/main`.
- Static assets served from `/static/*` mapping to `internal/web/public`.
- Add your models and migrations, then call `db.Connect()` wherever needed.