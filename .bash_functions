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

pushallrepos() {
  local base="${1:-.}"
  local repo top branch behind ahead

  if [[ ! -d "$base" ]]; then
    echo "Usage: pushallrepos [parent-directory]"
    return 2
  fi

  while IFS= read -r -d '' repo; do
    if ! git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      continue
    fi

    top="$(git -C "$repo" rev-parse --show-toplevel 2>/dev/null)" || continue

    # Only process direct repo folders, not nested folders inside a repo
    if [[ "$(realpath "$top")" != "$(realpath "$repo")" ]]; then
      continue
    fi

    branch="$(git -C "$repo" symbolic-ref --quiet --short HEAD)"
    if [[ -z "$branch" ]]; then
      echo "==> $(basename "$repo"): skipped, detached HEAD"
      continue
    fi

    if ! git -C "$repo" remote get-url origin >/dev/null 2>&1; then
      echo "==> $(basename "$repo"): skipped, no origin remote"
      continue
    fi

    echo
    echo "==> $(basename "$repo") [$branch]"

    if ! git -C "$repo" diff --quiet || ! git -C "$repo" diff --cached --quiet; then
      echo "    Warning: repo has uncommitted changes. Only committed changes will be pushed."
    fi

    git -C "$repo" fetch --quiet origin

    if git -C "$repo" rev-parse --verify --quiet "origin/$branch" >/dev/null; then
      read -r behind ahead < <(
        git -C "$repo" rev-list --left-right --count "origin/$branch...HEAD"
      )

      if [[ "$ahead" == "0" ]]; then
        echo "    Nothing to push."
        continue
      fi

      if [[ "$behind" != "0" ]]; then
        echo "    Skipped: origin/$branch has $behind commit(s) not in local $branch."
        echo "    Pull/rebase first, then run again."
        continue
      fi
    fi

    git -C "$repo" push -u origin "$branch"
  done < <(find "$base" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
}
