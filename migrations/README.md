# Database Migrations

This folder contains Goose SQL migrations for schema changes.

**⚠️ Never add files manually!** Always use:

```bash
make migrate-create NAME=descriptive_change
make migrate-up
make migrate-status
```

See the main [README.md](../README.md#database-management) for full documentation.
