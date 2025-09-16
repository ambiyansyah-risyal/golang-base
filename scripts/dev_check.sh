#!/usr/bin/env bash
set -Eeuo pipefail

# Dev environment readiness check for golang-base
# - Ensures .env exists
# - Starts postgres and redis
# - Waits for containers to be healthy
# - Runs DB migrations via migrator
# - Starts the app and verifies /health
#
# Goal: Let developers focus on business logic, not environment setup.

# ---------- Helpers ----------
RED="\033[31m"; GREEN="\033[32m"; YELLOW="\033[33m"; BLUE="\033[34m"; BOLD="\033[1m"; NC="\033[0m"
info()    { echo -e "${BLUE}==>${NC} $*"; }
success() { echo -e "${GREEN}✔${NC} $*"; }
warn()    { echo -e "${YELLOW}!${NC} $*"; }
error()   { echo -e "${RED}✖${NC} $*"; }

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    error "Required command '$1' not found. Please install it first."
    exit 1
  fi
}

# Prefer `docker compose`, fallback to `docker-compose`
resolve_compose_cmd() {
  if docker compose version >/dev/null 2>&1; then
    echo "docker compose"
  elif command -v docker-compose >/dev/null 2>&1; then
    echo "docker-compose"
  else
    error "Docker Compose not found. Install Docker Desktop or docker-compose plugin."
    exit 1
  fi
}

wait_for_healthy() {
  local name="$1"; shift
  local timeout="${1:-60}"
  local start ts status
  start=$(date +%s)
  info "Waiting for container '${name}' to be healthy (timeout ${timeout}s)..."
  while true; do
    if ! docker inspect "$name" >/dev/null 2>&1; then
      warn "Container ${name} not found yet. Retrying..."
    else
      status=$(docker inspect -f '{{ if .State.Health }}{{ .State.Health.Status }}{{ else }}unknown{{ end }}' "$name" || echo "unknown")
      if [[ "$status" == "healthy" ]]; then
        success "${name} is healthy"
        return 0
      fi
      if [[ "$status" == "starting" ]]; then
        : # keep waiting
      elif [[ "$status" == "unhealthy" ]]; then
        error "${name} reported unhealthy"
        docker logs --tail=50 "$name" || true
        return 1
      fi
    fi
    ts=$(($(date +%s) - start))
    if (( ts >= timeout )); then
      error "Timeout waiting for ${name} to become healthy."
      docker ps --filter name="$name" --format 'table {{.Names}}\t{{.Status}}' || true
      docker logs --tail=50 "$name" || true
      return 1
    fi
    sleep 2
  done
}

http_ok() {
  local url="$1"; shift
  local timeout="${1:-60}"
  local start rc=1
  start=$(date +%s)
  info "Waiting for HTTP 200 from ${url} (timeout ${timeout}s)..."
  while true; do
    if command -v curl >/dev/null 2>&1; then
      curl -fsS "${url}" >/dev/null 2>&1 && rc=0 || rc=$?
    else
      wget --spider -q "${url}" >/dev/null 2>&1 && rc=0 || rc=$?
    fi
    if [[ $rc -eq 0 ]]; then
      success "HTTP OK from ${url}"
      return 0
    fi
    local ts=$(($(date +%s) - start))
    if (( ts >= timeout )); then
      error "Timeout waiting for ${url} to respond successfully."
      return 1
    fi
    sleep 2
  done
}

# ---------- Checks ----------
main() {
  require_cmd docker
  local COMPOSE
  COMPOSE=$(resolve_compose_cmd)

  # 1) Ensure .env exists
  if [[ ! -f .env ]]; then
    warn ".env not found. Creating from .env.example..."
    if [[ -f .env.example ]]; then
      cp .env.example .env
      success ".env created from .env.example (please review credentials if needed)"
    else
      error ".env.example not found. Cannot continue."
      exit 1
    fi
  else
    success ".env present"
  fi

  # 2) Build images (fast if cached)
  info "Building images (app, migrator) if needed..."
  $COMPOSE build app migrator >/dev/null 2>&1 || $COMPOSE build app migrator

  # 3) Start core services
  info "Starting core services: postgres, redis..."
  $COMPOSE up -d postgres redis

  # 4) Wait for health checks
  wait_for_healthy golang_base_db 90
  wait_for_healthy golang_base_redis 60

  # 5) Run migrations (one-shot)
  info "Running database migrations..."
  if $COMPOSE run --rm migrator; then
    success "Migrations ran successfully"
  else
    error "Migrations failed. See logs above."
    exit 1
  fi

  # 6) Start the app
  info "Starting app service..."
  $COMPOSE up -d app
  wait_for_healthy golang_base_app 120 || {
    warn "App healthcheck pending or disabled. Checking HTTP /health endpoint directly..."
  }

  # 7) Verify HTTP health endpoint
  http_ok "http://localhost:3000/health" 90

  # 8) Summary
  echo
  success "Development stack is READY. You can start coding!"
  echo -e "${BOLD}Tips:${NC}"
  echo "- Tail logs:    $COMPOSE logs -f app postgres redis"
  echo "- Stop stack:   $COMPOSE down"
  echo "- Re-run check: ./scripts/dev_check.sh"
}

main "$@"
