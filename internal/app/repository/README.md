Data access layer (PostgreSQL via GORM). Keep SQL/ORM details here.

Guidelines:
- Interfaces in `internal/app/repository` implemented by concrete adapters.
- No business logic; translate persistence errors.
