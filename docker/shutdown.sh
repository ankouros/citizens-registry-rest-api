#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

docker rm -f citizen-service mysql-db || true
docker network rm citizen-net || true

echo "Backend stopped (data preserved)"
