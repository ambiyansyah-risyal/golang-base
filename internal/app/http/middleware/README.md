Cross-cutting HTTP middleware (auth, logging, rate limiting, recovery).

Guidelines:
- Keep state external (db/cache) injected via constructors.
- Compose middleware in the router, not handlers.
