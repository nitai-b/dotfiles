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

copy-path() {
  if [[ -z "$1" ]]; then
    echo "Usage: copy-path <file-or-folder-path>"
    return 1
  fi

  readlink -f "$1" | wl-copy
  echo "Copied: $(readlink -f "$1")"
}
