#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: gitzip [repo_path] [output_zip]

Create a zip archive of a git repository while excluding ignored files.

Arguments:
  repo_path    Path to the git repository. Defaults to the current directory.
  output_zip   Output archive path. Defaults to <repo-name>.zip in the
               current working directory.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

repo_path="${1:-.}"

if ! repo_root="$(git -C "$repo_path" rev-parse --show-toplevel 2>/dev/null)"; then
  echo "Error: not a git repository: $repo_path" >&2
  exit 1
fi

repo_name="$(basename "$repo_root")"
output_zip="${2:-$repo_name.zip}"

if [[ "$output_zip" != /* ]]; then
  output_zip="$PWD/$output_zip"
fi

rm -f "$output_zip"

tmp_list="$(mktemp)"
trap 'rm -f "$tmp_list"' EXIT

(
  cd "$repo_root"
  git ls-files --cached --others --exclude-standard -z >"$tmp_list"
)

if [[ ! -s "$tmp_list" ]]; then
  echo "Error: no files to archive in $repo_root" >&2
  exit 1
fi

python3 - "$repo_root" "$output_zip" "$tmp_list" <<'PY'
import os
import sys
import zipfile

repo_root, output_zip, list_path = sys.argv[1:]

with open(list_path, "rb") as f:
    raw_entries = [entry for entry in f.read().split(b"\0") if entry]

with zipfile.ZipFile(output_zip, "w", compression=zipfile.ZIP_DEFLATED) as zf:
    for raw_entry in raw_entries:
        rel_path = raw_entry.decode("utf-8")
        abs_path = os.path.join(repo_root, rel_path)

        if os.path.isdir(abs_path):
            continue

        zf.write(abs_path, arcname=rel_path)
PY

echo "Created $output_zip"
