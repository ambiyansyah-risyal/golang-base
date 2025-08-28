# golang-base

A minimal Go web project scaffold using Fiber (high-performance web framework).

This repository is a lightweight starting point for building HTTP services in Go.

## Features

- High-performance HTTP handling with Fiber
- Graceful shutdown support
- Dockerized for easy deployment
- Modular project structure for scalability
- Unit testing setup included

## Prerequisites

- Go 1.21 or newer
- Docker (optional, for container builds)

## Quickstart

1) Clone the repository:

```bash
git clone https://github.com/ambiyansyah-risyal/golang-base.git
cd golang-base
```

2) Initialize module & download dependencies (if you haven't already):

```bash
go mod tidy
```

3) Run the server locally:

```bash
go run ./cmd/server
# or
make run
```

The server listens on :8080 by default. Health check: http://localhost:8080/health

## Configuration

The application can be configured using environment variables:

- `PORT`: The port on which the server listens (default: `8080`)
- `LOG_LEVEL`: The logging level (e.g., `debug`, `info`, `warn`, `error`)

Example:

```bash
export PORT=3000
export LOG_LEVEL=debug
```

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

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Commit your changes and push the branch.
4. Open a pull request with a detailed description of your changes.

## Security

If you discover any security vulnerabilities, please report them responsibly by contacting the repository owner.

## Notes & next steps

- The project uses Fiber for high-performance HTTP handling; if you prefer a different framework (Gin, Echo), I can switch it.
- Consider adding CI (GitHub Actions) to run `go test` and static checks on push.
- Add more examples (middleware, metrics, OpenAPI) as needed.
- Implement logging and monitoring for production readiness.
- Add a deployment guide for cloud platforms (e.g., AWS, GCP, Azure).

## SOLID Principles

This project is designed with the SOLID principles in mind to ensure maintainability, scalability, and robustness:

1. **Single Responsibility Principle (SRP):**
   - Each package and file in the project has a single responsibility. For example, the `internal/handler` package is responsible for handling HTTP requests, while the `internal/server` package is responsible for initializing and configuring the server.

2. **Open/Closed Principle (OCP):**
   - The modular structure allows for extending functionality without modifying existing code. For instance, new routes or middleware can be added without altering the core server logic.

3. **Liskov Substitution Principle (LSP):**
   - Interfaces can be introduced to ensure that components can be replaced with their implementations without affecting the system. For example, a service layer can be added with interfaces for better testability.

4. **Interface Segregation Principle (ISP):**
   - Interfaces, if introduced, will be small and focused, ensuring that components only depend on what they need.

5. **Dependency Inversion Principle (DIP):**
   - High-level modules do not depend on low-level modules; both depend on abstractions. Dependency injection can be used to achieve this.

## Clean Architecture

This project follows the principles of Clean Architecture to ensure separation of concerns and independence of frameworks and tools:

1. **Entities:**
   - Core business logic and rules can be encapsulated in a separate layer. While this project is minimal, entities can be introduced as the application grows.

2. **Use Cases:**
   - Application-specific business rules can be implemented in a use-case layer. This ensures that the core logic is independent of the delivery mechanism (e.g., HTTP).

3. **Interface Adapters:**
   - The `internal/handler` package acts as an adapter between the HTTP framework (Fiber) and the core application logic.

4. **Frameworks and Drivers:**
   - The `internal/server` package sets up the Fiber framework, but the core logic remains decoupled from the framework itself.

5. **Dependency Rule:**
   - Dependencies point inward. The `cmd/server` package depends on the `internal/server` package, which in turn depends on the `internal/handler` package. This ensures that the core logic is not dependent on external frameworks.

By adhering to these principles, the project is structured to be maintainable, testable, and adaptable to future requirements.

## License

This project is released under the MIT License — see `LICENSE` for details.
