#!/usr/bin/env bash
set -euo pipefail

echo "'air' not installed — attempting automatic install..."

if ! command -v go >/dev/null 2>&1; then
  echo "Go toolchain not found. Please install Go and retry (see https://golang.org/dl/)" >&2
  exit 1
fi

INSTALLED_FROM=""

# Try preferred/new module path first, then fall back to older cosmtrek paths/versions
if go install github.com/air-verse/air/cmd/air@latest >/dev/null 2>&1; then
  INSTALLED_FROM="github.com/air-verse/air/cmd/air@latest"
  echo "Installed 'air' from ${INSTALLED_FROM}"
elif go install github.com/cosmtrek/air@latest >/dev/null 2>&1; then
  INSTALLED_FROM="github.com/cosmtrek/air@latest"
  echo "Installed 'air' from ${INSTALLED_FROM}"
elif go install github.com/cosmtrek/air@v1.27.0 >/dev/null 2>&1; then
  INSTALLED_FROM="github.com/cosmtrek/air@v1.27.0"
  echo "Installed 'air' from ${INSTALLED_FROM}"
else
  echo "Automatic installation failed. Please install 'air' manually." >&2
  echo "Example: go install github.com/air-verse/air/cmd/air@latest" >&2
  exit 1
fi

# Try to locate the installed binary and exec it so the script starts air in this process
GOBIN=$(go env GOBIN 2>/dev/null || true)
GOPATH=$(go env GOPATH 2>/dev/null || true)

if [ -n "$GOBIN" ] && [ -x "$GOBIN/air" ]; then
  exec "$GOBIN/air"
fi

if [ -n "$GOPATH" ] && [ -x "$GOPATH/bin/air" ]; then
  exec "$GOPATH/bin/air"
fi

# Fallback to default GOPATH location
DEFAULT_GOBIN="$HOME/go/bin"
if [ -x "$DEFAULT_GOBIN/air" ]; then
  exec "$DEFAULT_GOBIN/air"
fi

echo "Installed 'air' but couldn't find the binary in GOBIN/GOPATH/bin ($GOBIN / $GOPATH)." >&2
echo "You may need to add the install directory to your PATH. Example:" >&2
echo "  export PATH=\"\$(go env GOBIN || \$(go env GOPATH)/bin)\":\"\$$PATH\"" >&2
exit 1
