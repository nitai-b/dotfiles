#!/usr/bin/env bash

shopt -s nullglob

for file in *; do
  [ -e "$file" ] || continue

  new_name="${file// /-}"
  new_name="$(printf '%s' "$new_name" | tr '[:upper:]' '[:lower:]')"

  if [ "$file" != "$new_name" ]; then
    mv -i -- "$file" "$new_name"
    echo "Renamed: $file -> $new_name"
  fi
done
