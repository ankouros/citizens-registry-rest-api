#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$ROOT_DIR/docker"
TF_DIR="$ROOT_DIR/terraform"

TEMP_DIR="$(mktemp -d)"
TF_STATE_PREPARE="$TEMP_DIR/prepare.tfstate"
TF_STATE_DEPLOY="$TEMP_DIR/deploy.tfstate"
TF_DATA_PREPARE="$TEMP_DIR/tfdata-prepare"
TF_DATA_DEPLOY="$TEMP_DIR/tfdata-deploy"

log() {
  printf '\n[%s] %s\n' "$(date +'%H:%M:%S')" "$*"
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

cleanup() {
  log "Cleanup"
  set +e

  if command -v docker >/dev/null 2>&1; then
    docker compose -f "$DOCKER_DIR/docker-compose.yml" down -v --remove-orphans >/dev/null 2>&1 || true
    docker rm -f citizen-service mysql-db >/dev/null 2>&1 || true
    docker network rm citizen-net >/dev/null 2>&1 || true
    docker volume rm citizen-db-data >/dev/null 2>&1 || true
    docker image rm citizen-service:latest >/dev/null 2>&1 || true
  fi

  if command -v terraform >/dev/null 2>&1; then
    TF_DATA_DIR="$TF_DATA_PREPARE" terraform -chdir="$TF_DIR/prepare" destroy -auto-approve -input=false -state="$TF_STATE_PREPARE" >/dev/null 2>&1 || true
    TF_DATA_DIR="$TF_DATA_DEPLOY" terraform -chdir="$TF_DIR/deploy" destroy -auto-approve -input=false -state="$TF_STATE_DEPLOY" >/dev/null 2>&1 || true
  fi

  find "$ROOT_DIR" -type d -name target -prune -exec rm -rf {} + >/dev/null 2>&1 || true
  find "$TF_DIR" -type d -name .terraform -prune -exec rm -rf {} + >/dev/null 2>&1 || true

  rm -rf "$TEMP_DIR" >/dev/null 2>&1 || true
  set -e
}

trap cleanup EXIT

wait_for_service() {
  local url="$1"
  local retries=60
  local delay=2

  for _ in $(seq 1 "$retries"); do
    if curl -fsS "$url" >/dev/null 2>&1; then
      return 0
    fi
    sleep "$delay"
  done

  echo "Service did not become ready: $url" >&2
  return 1
}

dump_docker_logs() {
  log "Docker logs (citizen-service)"
  docker logs --tail=200 citizen-service || true
  log "Docker logs (mysql-db)"
  docker logs --tail=200 mysql-db || true
}

dump_compose_logs() {
  log "Docker compose logs (citizen-service)"
  docker compose -f "$DOCKER_DIR/docker-compose.yml" logs --tail=200 citizen-service || true
  log "Docker compose logs (db)"
  docker compose -f "$DOCKER_DIR/docker-compose.yml" logs --tail=200 db || true
}

run_http_tests() {
  local base_url="$1"
  local mode="${2:-}"
  local health_url="$base_url/actuator/health"

  log "Health check"
  if ! wait_for_service "$health_url"; then
    if [ "$mode" = "docker" ]; then
      dump_docker_logs
    elif [ "$mode" = "compose" ]; then
      dump_compose_logs
    fi
    return 1
  fi
  curl -fsS "$health_url"

  log "Create citizen"
  local create_payload='{"firstName":"Maria","lastName":"Papadopoulou","afm":"123456789","amka":"01010112345","birthDate":"1990-01-01"}'
  local create_response
  create_response=$(curl -fsS -X POST "$base_url/citizens" \
    -H "Content-Type: application/json" \
    -d "$create_payload")

  local citizen_id
  citizen_id=$(python3 - "$create_response" <<'PY'
import json
import sys

data = json.loads(sys.argv[1])
print(data.get("id", ""))
PY
  )

  if [ -z "$citizen_id" ]; then
    echo "Failed to extract citizen id from response: $create_response" >&2
    return 1
  fi

  log "List citizens"
  curl -fsS "$base_url/citizens"

  log "Get citizen"
  curl -fsS "$base_url/citizens/$citizen_id"

  log "Update citizen"
  local update_payload='{"firstName":"Maria","lastName":"Papadopoulou","afm":"123456789","amka":"01010112345","birthDate":"1991-02-02"}'
  curl -fsS -X PUT "$base_url/citizens/$citizen_id" \
    -H "Content-Type: application/json" \
    -d "$update_payload"

  log "Delete citizen"
  curl -fsS -X DELETE "$base_url/citizens/$citizen_id"
}

require_cmd mvn
require_cmd docker
require_cmd terraform
require_cmd curl
require_cmd python3

log "Java build + test"
(
  cd "$ROOT_DIR"
  mvn -B clean verify
)

log "Java lint"
if command -v rg >/dev/null 2>&1 && rg -q "checkstyle|spotbugs|pmd" "$ROOT_DIR"/pom.xml "$ROOT_DIR"/citizen-*/pom.xml; then
  log "Lint plugins detected but no explicit lint goal configured"
else
  log "No lint plugins configured; skipping lint"
fi

log "Docker build"
"$DOCKER_DIR/build.sh"

log "Docker run"
"$DOCKER_DIR/startup.sh"
run_http_tests "http://localhost:8080" "docker"
"$DOCKER_DIR/shutdown.sh"

docker volume rm citizen-db-data >/dev/null 2>&1 || true

docker image rm citizen-service:latest >/dev/null 2>&1 || true

log "Docker compose run"
docker compose -f "$DOCKER_DIR/docker-compose.yml" up -d --build
run_http_tests "http://localhost:8080" "compose"
docker compose -f "$DOCKER_DIR/docker-compose.yml" down -v --remove-orphans

docker image rm citizen-service:latest >/dev/null 2>&1 || true

docker volume rm citizen-db-data >/dev/null 2>&1 || true

log "Terraform prepare"
TF_DATA_DIR="$TF_DATA_PREPARE" terraform -chdir="$TF_DIR/prepare" init -input=false
TF_DATA_DIR="$TF_DATA_PREPARE" terraform -chdir="$TF_DIR/prepare" apply -auto-approve -input=false -state="$TF_STATE_PREPARE"
REST_AMI_ID=$(TF_DATA_DIR="$TF_DATA_PREPARE" terraform -chdir="$TF_DIR/prepare" output -state="$TF_STATE_PREPARE" -raw rest_ami_id)

log "Terraform deploy"
TF_DATA_DIR="$TF_DATA_DEPLOY" terraform -chdir="$TF_DIR/deploy" init -input=false
TF_DATA_DIR="$TF_DATA_DEPLOY" terraform -chdir="$TF_DIR/deploy" apply -auto-approve -input=false -state="$TF_STATE_DEPLOY" -var-file=terraform.tfvars -var "rest_ami=$REST_AMI_ID"

log "Terraform destroy"
TF_DATA_DIR="$TF_DATA_DEPLOY" terraform -chdir="$TF_DIR/deploy" destroy -auto-approve -input=false -state="$TF_STATE_DEPLOY" -var-file=terraform.tfvars -var "rest_ami=$REST_AMI_ID"

log "Terraform prepare cleanup"
TF_DATA_DIR="$TF_DATA_PREPARE" terraform -chdir="$TF_DIR/prepare" destroy -auto-approve -input=false -state="$TF_STATE_PREPARE"

log "Done"
