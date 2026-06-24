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
LIGHT_PIN="${LIGHT_PIN:-${1:-}}"

if [ -z "${BLYNK_TOKEN:-}" ]; then
  echo "Missing BLYNK_TOKEN in $SCRIPT_DIR/.env" >&2
  exit 1
fi

if [ -z "$LIGHT_PIN" ]; then
  echo "Usage: $0 <light-pin>" >&2
  echo "Or set LIGHT_PIN in $SCRIPT_DIR/.env" >&2
  echo "Example: $0 v11" >&2
  exit 1
fi

CURRENT="$(curl --silent --show-error --fail \
  "${BLYNK_BASE_URL}/get?token=${BLYNK_TOKEN}&${LIGHT_PIN}")"

CURRENT="${CURRENT//$'\n'/}"
CURRENT="${CURRENT//$'\r'/}"
CURRENT="${CURRENT//[$'\t ']/}"
CURRENT="${CURRENT#[}"
CURRENT="${CURRENT%]}"
CURRENT="${CURRENT//\"/}"
CURRENT="${CURRENT,,}"

case "$CURRENT" in
  1)
    NEXT=0
    ;;
  0)
    NEXT=1
    ;;
  true)
    NEXT=false
    ;;
  false)
    NEXT=true
    ;;
  *)
    echo "Unexpected value for ${LIGHT_PIN}: ${CURRENT}" >&2
    exit 1
    ;;
esac

curl --silent --show-error --fail \
  "${BLYNK_BASE_URL}/update?token=${BLYNK_TOKEN}&${LIGHT_PIN}=${NEXT}"
