#!/usr/bin/env bash
set -euo pipefail

# Runs `go test` with coverage and enforces minimum coverage (90%)
MIN_COVERAGE=${MIN_COVERAGE:-90}

echo "Running tests with coverage requirement: ${MIN_COVERAGE}%"

# build a list of packages excluding package main and anything under /cmd/
# Use `go list` with a template and filter with awk to avoid xargs warnings
pkgs=$(go list -f '{{.Name}} {{.ImportPath}}' ./... | awk '$1 != "main" && $2 !~ "/cmd/" {print $2}')
pkgs=$(echo "$pkgs" | tr '\n' ' ')
if [ -z "$pkgs" ]; then
  echo "No non-main packages to test"
  exit 2
fi

echo "Testing packages:"
for p in $pkgs; do echo "  $p"; done

go test -covermode=atomic -coverprofile=coverage.out $pkgs
if [ ! -f coverage.out ]; then
  echo "coverage.out not generated"
  exit 2
fi

total=$(go tool cover -func=coverage.out | grep total | awk '{print $3}' | sed 's/%//')
echo "Total coverage: ${total}%"

# compare as numbers
awk -v cov="$total" -v min="$MIN_COVERAGE" 'BEGIN{if(cov+0 < min+0) exit 1}' || {
  echo "Coverage ${total}% is below required ${MIN_COVERAGE}%"
  exit 1
}

echo "Coverage requirement met"
