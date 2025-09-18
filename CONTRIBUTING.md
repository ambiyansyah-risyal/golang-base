# Contributing to GoLang-Base

Thank you for your interest in contributing! This guide will help you get started.

## Development Setup

1. **Clone and setup**
   ```bash
   git clone https://github.com/your-username/golang-base.git
   cd golang-base
   make dev-setup
   ```

2. **Start development environment**
   ```bash
   make dev-up    # Start PostgreSQL + Redis
   make dev       # Start app with auto-reload
   ```

3. **Verify everything works**
   ```bash
   make dev-check  # Comprehensive environment validation
   ```

## Development Workflow

### Code Changes
- Use `make dev` for auto-reload development
- Run `make lint` before committing
- Run `make test` to ensure tests pass
- Follow Go best practices and project conventions

### Database Changes
- Create migrations: `make migrate-create NAME=your_change`
- Test migrations: `make migrate-up` and `make migrate-down`
- Never edit existing migration files

### Testing
```bash
make test               # Run all tests
make test-coverage     # Generate coverage report
make security-check    # Run security analysis
```

## Code Standards

- **Go Formatting**: Use `make format` (runs `go fmt`)
- **Linting**: Must pass `make lint` (golangci-lint)
- **Security**: Must pass `make security-check` (gosec)
- **Testing**: Maintain or improve test coverage

## Commit Guidelines

Use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New features
- `fix:` Bug fixes  
- `docs:` Documentation changes
- `refactor:` Code refactoring
- `test:` Adding/updating tests
- `chore:` Build process, dependency updates

## Pull Request Process

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes following the guidelines above
4. Run the full test suite: `make test lint security-check`
5. Commit with conventional commit messages
6. Push and create a pull request

## Project Structure

```
cmd/server/         # Application entry point
internal/           # Private application code
├── config/         # Configuration management
├── handlers/       # HTTP handlers (controllers)  
├── middleware/     # Fiber middleware
├── models/         # Data models
└── routes/         # Route definitions
pkg/utils/          # Shared utilities
web/                # Frontend templates and assets
migrations/         # Database migrations
```

## Adding New Features

### 1. Models
- Add to `internal/models/` with GORM tags
- Include validation tags
- Add `ToResponse()` method to exclude sensitive fields

### 2. Handlers  
- Follow the constructor pattern with dependency injection
- Use proper error handling and HTTP status codes
- Validate input data

### 3. Routes
- Group related routes logically
- Apply appropriate middleware (auth, validation)
- Document API endpoints

### 4. Migrations
- Use `make migrate-create NAME=feature_name`
- Include both Up and Down migrations
- Test rollbacks work correctly

## Local Development Tips

- **Database Reset**: `make migrate-reset` (⚠️ destructive)
- **Clean Build**: `make clean && make build`
- **Docker Stack**: `make docker-run` for full environment
- **Logs**: `make dev-logs` for database logs

## Getting Help

- Check existing [Issues](https://github.com/your-username/golang-base/issues)
- Review the main [README.md](README.md) for comprehensive docs
- Look at existing code for patterns and examples

## Security

- Follow secure coding practices (see [SECURITY.md](SECURITY.md))
- Never commit secrets or credentials
- Use parameterized queries for database operations
- Validate and sanitize all user input

Thank you for contributing! 🚀