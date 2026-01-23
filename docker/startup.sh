#!/usr/bin/env bash
set -e

NETWORK=citizen-net
DB_VOLUME=citizen-db-data
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR"

docker network create $NETWORK || true

docker run -d \
  --name mysql-db \
  --network $NETWORK \
  -v $DB_VOLUME:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=citizens \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=apppass \
  mysql:8.4

docker run -d \
  --name citizen-service \
  --network $NETWORK \
  -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:mysql://mysql-db:3306/citizens \
  -e SPRING_DATASOURCE_USERNAME=appuser \
  -e SPRING_DATASOURCE_PASSWORD=apppass \
  citizen-service:latest

echo "REST API available at http://localhost:8080"
