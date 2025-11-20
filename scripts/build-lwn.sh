#!/usr/bin/env bash
set -euo pipefail

# scripts/build-lwn.sh
# Build the LWN-Simulator using a Go builder container.
# Usage:
#   ./scripts/build-lwn.sh [source-dir]
# If no source-dir is provided, the script will clone the upstream repo into
# ./third_party/LWN-Simulator and build from there.

REPO_URL="https://github.com/UniCT-ARSLab/LWN-Simulator.git"
DEFAULT_DIR="$(pwd)/third_party/LWN-Simulator"

SRC_DIR="${1:-$DEFAULT_DIR}"

echo "LWN Simulator build helper"
echo "Source dir: $SRC_DIR"

if [ ! -d "$SRC_DIR" ]; then
  echo "Source directory not found. Cloning $REPO_URL --> $SRC_DIR"
  mkdir -p "$(dirname "$SRC_DIR")"
  git clone "$REPO_URL" "$SRC_DIR"
elif [ -z "$(ls -A "$SRC_DIR" 2>/dev/null)" ]; then
  echo "Source directory exists but is empty. Cloning $REPO_URL"
  git clone "$REPO_URL" "$SRC_DIR"
fi

echo "Starting build inside a Go builder container..."

docker run --rm \
  -v "$SRC_DIR":/src \
  -w /src \
  golang:1.21-bullseye \
  bash -lc "set -e; export DEBIAN_FRONTEND=noninteractive; export PATH=/usr/local/go/bin:/go/bin:\$PATH; apt-get update >/dev/null; apt-get install -y make git >/dev/null; if [ -f Makefile ]; then echo '[lwn-build] Makefile detected'; make install-dep || echo '[lwn-build] install-dep missing or failed (continuing)'; if make -n build >/dev/null 2>&1; then make build; else echo '[lwn-build] build target missing — running go build'; go test ./... || true; go build ./...; fi; else echo '[lwn-build] No Makefile — running go build'; go test ./... || true; go build ./...; fi; mkdir -p bin; cp -f ./config.json ./bin/config.json || true; echo '[lwn-build] Building Windows executable'; GOOS=windows GOARCH=amd64 go build -o bin/lwnsimulator.exe cmd/main.go"

echo "Build finished. Binaries (if any) are inside: $SRC_DIR/bin"
echo "If you prefer using Docker Compose, run:"
echo "  docker compose --profile builder run --rm lwn-builder"
