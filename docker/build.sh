#!/usr/bin/env bash
set -e

IMAGE=citizen-service:latest
DB_VOLUME=citizen-db-data
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

docker build -t "$IMAGE" -f "$SCRIPT_DIR/Dockerfile" "$SCRIPT_DIR/.."
docker volume create "$DB_VOLUME" || true

echo "✔ citizen-service image built"
