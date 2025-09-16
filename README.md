# GoLang-Base

[![Go Version](https://img.shields.io/badge/Go-1.25-00ADD8?style=flat-square&logo=go)](https://golang.org/)
[![Fiber Version](https://img.shields.io/badge/Fiber-v2.52-00ADD8?style=flat-square&logo=fiber)](https://gofiber.io/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=flat-square&logo=docker)](https://www.docker.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Ready-336791?style=flat-square&logo=postgresql)](https://www.postgresql.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)

A modern, fast, and secure fullstack web application built with **Go Fiber**, **GORM**, and **PostgreSQL**. This project serves as both a production-ready application and a comprehensive boilerplate for building scalable web applications.

## Features

**GoLang-Base** combines the speed of Go with modern web development practices to deliver a robust foundation for your next project:

- **🚀 High Performance**: Built with Go Fiber v2, one of the fastest web frameworks
- **🔐 Security First**: JWT authentication, bcrypt hashing, rate limiting, and CORS protection
- **🏗️ Clean Architecture**: Organized codebase following Go best practices with clear separation of concerns
- **📱 Dual Interface**: Serves both JSON APIs (`/api/v1/*`) and server-side rendered HTML pages
- **🗄️ Database Ready**: PostgreSQL with GORM ORM, automatic migrations, and connection pooling
- **🐳 Container Native**: Multi-stage Docker builds with Docker Compose for full-stack development
- **⚡ Developer Experience**: Hot reload in development, comprehensive Makefile commands, and structured logging

## Quick Start

### Prerequisites

- [Go 1.25+](https://golang.org/dl/)
- [Docker & Docker Compose](https://docs.docker.com/get-docker/)
- [PostgreSQL](https://www.postgresql.org/) (if running without Docker)

### One-command Setup (Recommended)

If you just cloned the repository and want to start coding immediately:

```bash
make dev-check
```

This will:
- Ensure `.env` exists (copied from `.env.example` if missing)
- Build images if needed
- Start PostgreSQL and Redis with health checks
- Run database migrations
- Start the app and verify the `/health` endpoint

Then open http://localhost:3000

### Get Started in 3 Steps (Manual)

1. **Clone and setup**
   ```bash
   git clone https://github.com/your-username/golang-base.git
   cd golang-base
   make dev-setup
   ```

2. **Start the full stack**
   ```bash
   make docker-run
   ```

3. **Access your application**
   - **Web Interface**: http://localhost:3000
   - **API Endpoints**: http://localhost:3000/api/v1
   - **Health Check**: http://localhost:3000/health

Your application is now running with a PostgreSQL database, Redis cache, and Nginx reverse proxy!

> Note: Inside Docker Compose, services connect to the database using the service hostname `postgres` (not `localhost`). The stack loads environment variables from `.env` via `env_file` in `docker-compose.yml`.

## Development Workflows

### Essential Commands

```bash
# Initial project setup
make dev-setup          # Copy .env file and install dependencies

# Development
make run                 # Start development server (requires external DB)
make dev-up             # Start PostgreSQL + Redis for local development
make docker-run         # Full stack with all services
make dev-check          # Validate env, DBs, migrations, and app health

# Database
make migrate-up         # Apply database migrations
make migrate-status     # Check migration status
make migrate-create NAME=your_migration  # Create new migration

# Testing & Quality
make test               # Run tests
make test-coverage      # Run tests with HTML coverage report
make lint               # Run code linter
make security-check     # Run security analysis

# Production
make build              # Create production binary
make docker-build       # Build production Docker image
```

## Project Architecture

### Directory Structure

```
golang-base/
├── cmd/server/           # Application entry point
├── internal/             # Private application code
│   ├── config/          # Environment-based configuration
│   ├── database/        # DB connection and setup
│   ├── handlers/        # HTTP request handlers (controllers)
│   ├── middleware/      # Fiber middleware (auth, CORS, etc.)
│   ├── models/          # Data models and DTOs
│   └── routes/          # Route definitions and grouping
├── migrations/          # Database migrations (Goose)
├── pkg/utils/           # Reusable utility functions
├── web/                 # Frontend assets
│   ├── static/         # CSS, JS, images
│   └── templates/      # HTML templates with layouts
└── scripts/            # Helper scripts and tools
```

### Key Design Decisions

- **Dual-Mode Server**: Serves both REST APIs and web pages from a single binary
- **JWT + Cookie Auth**: JWT tokens for API routes, cookie-based auth for web pages  
- **Template Engine**: Server-side rendering with Go Fiber's HTML template engine
- **Database Migrations**: Managed with Goose CLI for version control and rollbacks
- **Clean Separation**: Clear boundaries between handlers, models, and business logic

## Authentication & Security

### Default Users

The application ships with default users for development:

| Role  | Email | Password | Access Level |
|-------|-------|----------|-------------|
| Admin | `admin@example.com` | `admin123` | Full system access |
| User  | `user@example.com` | `admin123` | Standard user access |

> [!CAUTION]
> **Change these passwords immediately in production!** See the [Security Guide](scripts/README.md) for detailed setup instructions.

### Security Features

- **Password Security**: bcrypt hashing with configurable cost (default: 12)
- **JWT Tokens**: HMAC-SHA256 signed tokens with configurable expiration
- **Rate Limiting**: Configurable request limits per IP to prevent abuse
- **CORS Protection**: Configurable allowed origins for cross-origin requests
- **Security Headers**: Helmet middleware for common security headers
- **Input Validation**: Comprehensive validation using go-playground/validator

### API Authentication

```bash
# Register new user
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"newpassword","first_name":"John","last_name":"Doe"}'

# Login
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}'

# Use JWT token in subsequent requests
curl -H "Authorization: Bearer <your-jwt-token>" \
  http://localhost:3000/api/v1/users/profile
```

## API Reference

### Public Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/v1/auth/register` | Register new user |
| `POST` | `/api/v1/auth/login` | User authentication |
| `POST` | `/api/v1/auth/refresh` | Refresh JWT token |
| `GET` | `/health` | Health check endpoint |

### Protected Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/api/v1/users/profile` | Get current user profile | User |
| `PUT` | `/api/v1/users/profile` | Update current user | User |
| `DELETE` | `/api/v1/users/profile` | Delete current user | User |
| `GET` | `/api/v1/admin/users` | List all users | Admin |
| `GET` | `/api/v1/admin/users/:id` | Get user by ID | Admin |
| `PUT` | `/api/v1/admin/users/:id` | Update any user | Admin |
| `DELETE` | `/api/v1/admin/users/:id` | Delete any user | Admin |

### Web Pages

| Route | Page | Auth Required |
|-------|------|---------------|
| `/` | Homepage | No |
| `/login` | Login form | No |
| `/register` | Registration form | No |
| `/dashboard` | User dashboard | Yes |

## Configuration

Configuration is managed through environment variables. Copy `.env.example` to `.env` and customize. Docker Compose loads this file automatically via `env_file`.

```bash
# Application
APP_ENV=development
PORT=3000

# Database
DATABASE_URL=postgres://user:password@localhost:5432/golang_base?sslmode=disable
# Optional granular DB vars (used by Makefile and Compose)
DB_HOST=localhost
DB_PORT=5432
DB_USER=user
DB_PASSWORD=password
DB_NAME=golang_base
DB_SSLMODE=disable

# Security
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
BCRYPT_COST=12
SESSION_TIMEOUT=24h

# Rate Limiting
RATE_LIMIT=100
RATE_LIMIT_WINDOW=1m

# CORS
ALLOWED_ORIGINS=*
```

## Deployment

### Docker Deployment

The application includes production-ready Docker configuration:

```bash
# Build and deploy with Docker Compose
make docker-build
make docker-run

# For production with environment overrides
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

The Docker setup includes:
- **Multi-stage builds** for optimized production images
- **PostgreSQL** database with health checks  
- **Redis** for caching and sessions
- **Nginx** reverse proxy with SSL termination ready
- **Automatic migrations** on startup
 - **env_file support** for secrets via `.env`
 - **Service hostnames**: app and migrator connect to Postgres via `postgres` inside Compose

For security best practices, see `docs/SECURITY.md`.

### Binary Deployment

```bash
# Build production binary
make build

# The binary includes embedded templates and static files
./bin/golang-base
```

## Database Management

### Migrations

Database schema is managed with [Goose](https://github.com/pressly/goose) migrations:

```bash
# Create new migration
make migrate-create NAME=add_user_preferences

# Apply migrations
make migrate-up

# Check status
make migrate-status

# Rollback last migration
make migrate-down
```

### Custom Password Hashes

Generate bcrypt hashes for seeding users:

```bash
# Using the included script
make generate-password-hash PASSWORD="your-secure-password"

# Direct script usage
cd scripts && go run generate_password_hash.go "your-password"
```

## Testing

```bash
# Run all tests
make test

# Run tests with coverage report
make test-coverage
open coverage.html

# Run specific test
go test ./internal/handlers -v
```

## Monitoring & Observability

The application includes structured logging and monitoring endpoints:

- **Health Checks**: `/health` endpoint for load balancer health checks
- **Structured Logging**: JSON-formatted logs in production
- **Request Logging**: HTTP request/response logging with Fiber middleware
- **Error Recovery**: Panic recovery middleware prevents crashes

## Customization

### Adding New Features

1. **Create Model**: Add to `internal/models/` with GORM tags and validation
2. **Create Handler**: Follow the constructor pattern in `internal/handlers/`
3. **Add Routes**: Group logically in `internal/routes/routes.go`
4. **Add Migration**: Use `make migrate-create NAME=your_feature`

### Frontend Customization  

- **Templates**: Located in `web/templates/` with Bootstrap 5 styling
- **Static Assets**: CSS, JS, and images in `web/static/`
- **Layouts**: Shared layout system using `layouts/main.html`

## Troubleshooting

### Common Issues

**Database Connection Errors**
```bash
# Ensure PostgreSQL is running
make dev-up

# Check connection string in .env
DATABASE_URL=postgres://user:password@localhost:5432/golang_base?sslmode=disable
```

**Migration Errors**
```bash
# Check migration status
make migrate-status

# Reset database (⚠️ destructive)
make migrate-reset
```

**Port Already in Use**
```bash
# Change port in .env or kill existing process
lsof -ti:3000 | xargs kill -9
```

## Performance

GoLang-Base is optimized for performance:

- **Fast Startup**: Sub-second startup times
- **Low Memory**: ~10MB base memory usage  
- **High Throughput**: Handles 10k+ requests/second on modern hardware
- **Efficient Queries**: Connection pooling and optimized database queries
- **Static Assets**: Efficient serving with proper caching headers

## Resources

- **Go Fiber Documentation**: https://docs.gofiber.io/
- **GORM Documentation**: https://gorm.io/docs/
- **PostgreSQL Documentation**: https://www.postgresql.org/docs/
- **Docker Documentation**: https://docs.docker.com/
- **Goose Migrations**: https://github.com/pressly/goose

## Next Steps

- [ ] **Add Tests**: Expand test coverage for your use case
- [ ] **Add Features**: User profiles, file uploads, real-time features
- [ ] **Configure CI/CD**: Set up GitHub Actions or similar
- [ ] **Monitor**: Add application monitoring and alerting
- [ ] **Scale**: Configure for horizontal scaling and load balancing

---

**Built with ❤️ using Go, Fiber, and PostgreSQL**