#!/usr/bin/env bash
set -e

IMAGE=citizen-service:latest
DB_VOLUME=citizen-db-data

docker build -t $IMAGE -f Dockerfile ..
docker volume create $DB_VOLUME || true

echo "✔ citizen-service image built"
