git_review_diff() {
  local output="codex-review.diff"

  if [ "$#" -eq 0 ]; then
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

    echo "Wrote uncommitted diff to $output"
    return 0
  fi

  if [ "$#" -eq 1 ]; then
    output="$1"

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

    echo "Wrote uncommitted diff to $output"
    return 0
  fi

  if [ "$#" -eq 2 ]; then
    local from_ref="$1"
    local to_ref="$2"

    git diff --no-ext-diff --binary "$from_ref" "$to_ref" > "$output"

    echo "Wrote diff from $from_ref to $to_ref to $output"
    return 0
  fi

  if [ "$#" -eq 3 ]; then
    local from_ref="$1"
    local to_ref="$2"
    output="$3"

    git diff --no-ext-diff --binary "$from_ref" "$to_ref" > "$output"

    echo "Wrote diff from $from_ref to $to_ref to $output"
    return 0
  fi

  echo "Usage:"
  echo "  git_review_diff"
  echo "  git_review_diff output.diff"
  echo "  git_review_diff FROM_REF TO_REF"
  echo "  git_review_diff FROM_REF TO_REF output.diff"
  return 1
}
