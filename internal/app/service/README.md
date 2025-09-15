Business logic layer. Services orchestrate repositories, cache, and external APIs.

Guidelines:
- Pure Go, deterministic; avoid HTTP concerns.
- Accept interfaces; return domain models and errors.
