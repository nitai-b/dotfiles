#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/.env" ]; then
  set -a
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/.env"
  set +a
fi

BLYNK_BASE_URL="${BLYNK_BASE_URL:-https://ny3.blynk.cloud/external/api}"
GATE_PIN="${GATE_PIN:-v10}"

if [ -z "${BLYNK_TOKEN:-}" ]; then
  echo "Missing BLYNK_TOKEN in $SCRIPT_DIR/.env" >&2
  exit 1
fi

curl --silent --show-error --fail \
  "${BLYNK_BASE_URL}/update?token=${BLYNK_TOKEN}&${GATE_PIN}=1"
