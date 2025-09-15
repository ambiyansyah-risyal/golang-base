This package contains HTTP handlers grouped by feature (e.g., auth, posts).

Guidelines:
- Keep handlers thin; delegate business logic to services.
- Validate inputs, return domain errors mapped to HTTP responses.
