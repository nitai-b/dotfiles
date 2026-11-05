#!/usr/bin/env bash
# Runs at GNOME login (via ~/.config/autostart/login-startup.desktop).
#  - Disables the screen idle timeout on every login.
#  - Mutes the speakers on the first login after each boot.

# 1. Disable screen timeout (same as toggle-screen-timeout.sh "disabled")
dconf write /org/gnome/desktop/session/idle-delay "uint32 0"

# 2. Mute default output, only once per boot
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/login-startup"
mkdir -p "$state_dir"
boot_id=$(cat /proc/sys/kernel/random/boot_id)
if [[ "$(cat "$state_dir/last-boot-id" 2>/dev/null)" != "$boot_id" ]]; then
  # PipeWire may still be starting: retry for up to ~15s
  for _ in $(seq 1 30); do
    if wpctl set-mute @DEFAULT_AUDIO_SINK@ 1 2>/dev/null; then
      echo "$boot_id" > "$state_dir/last-boot-id"
      break
    fi
    sleep 0.5
  done
fi
