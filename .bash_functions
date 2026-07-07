git_review_diff() {
  local output="${1:-codex-review.diff}"

  {
    git diff --no-ext-diff --binary
    git diff --no-ext-diff --binary --cached

    git ls-files --others --exclude-standard | while read -r f; do
      echo
      echo "===== UNTRACKED FILE: $f ====="

      if [ -f "$f" ]; then
        git diff --no-index -- /dev/null "$f" || true
      fi
    done
  } > "$output"

  echo "Wrote diff to $output"
}

cpath() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: cpath <file-or-folder-path> [more paths...]"
    echo
    echo "Examples:"
    echo "  cpath ~/Downloads/file.png"
    echo "  cpath ~/Downloads/file1.png ~/Downloads/file2.png ~/Pictures/image.jpg"
    return 1
  fi

  local resolved_paths=()
  local path resolved

  for path in "$@"; do
    if ! resolved="$(readlink -f -- "$path")"; then
      echo "Could not resolve path: $path" >&2
      return 1
    fi

    resolved_paths+=("$resolved")
  done

  printf '%s\n' "${resolved_paths[@]}" | wl-copy

  echo "Copied ${#resolved_paths[@]} path(s):"
  printf '%s\n' "${resolved_paths[@]}"
}
