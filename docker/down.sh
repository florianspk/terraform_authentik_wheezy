#!/usr/bin/env bash
# Stop the local authentik dev stack.
#   ./down.sh          stop containers, keep the database
#   ./down.sh --purge  also delete volumes and the generated .env (full reset)
set -euo pipefail

cd "$(dirname "$0")"
# shellcheck disable=SC1091
[[ -f .env ]] && { set -a; source .env; set +a; }

if [[ "${1:-}" == "--purge" ]]; then
  docker compose down -v
  rm -f .env
  echo "==> stack removed, volumes wiped, docker/.env deleted"
else
  docker compose down
  echo "==> stack stopped; data kept. Bring it back with ./up.sh"
fi
