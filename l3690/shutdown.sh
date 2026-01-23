#!/usr/bin/env bash

docker rm -f citizen-service mysql-db || true
docker network rm citizen-net || true

echo "Backend stopped (data preserved)"
