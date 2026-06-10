#!/usr/bin/env bash

# tmux-opened-paths
# Search current paths from open tmux panes and jump to the matching session/window/pane.

if ! command -v fzf >/dev/null 2>&1; then
  echo "fzf is required"
  exit 1
fi

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux is required"
  exit 1
fi

if ! tmux info >/dev/null 2>&1; then
  echo "No tmux server is running"
  exit 0
fi

selected="$(
  tmux list-panes -a -F \
    "#{pane_current_path}	#{session_name}	#{window_index}	#{pane_id}" |
    awk -F '\t' '
    # Avoid duplicate paths. First pane with that path wins.
    !seen[$1]++ {
      printf "%s\t%s:%s\t%s\n", $1, $2, $3, $4
    }
  ' |
    sort |
    fzf \
      --delimiter='\t' \
      --with-nth=1 \
      --prompt='tmux path > ' \
      --preview='echo "Path:   {1}"; echo "Target: {2}"'
)"

if [[ -z "$selected" ]]; then
  exit 0
fi

target="$(echo "$selected" | cut -f2)"
pane_id="$(echo "$selected" | cut -f3)"

session="${target%%:*}"
window_index="${target#*:}"

tmux select-window -t "${session}:${window_index}"
tmux select-pane -t "${pane_id}"

if [[ -n "$TMUX" ]]; then
  tmux switch-client -t "$session"
else
  tmux attach-session -t "$session"
fi
