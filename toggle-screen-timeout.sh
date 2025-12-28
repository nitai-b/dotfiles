#!/bin/bash

# Check current screen timeout (in seconds)
TIMEOUT=$(gsettings get org.gnome.desktop.session idle-delay)

if [ "$TIMEOUT" == "uint32 0" ]; then
  # Currently set to never turn off, so enable timeout (5 minutes = 300 seconds)
  gsettings set org.gnome.desktop.session idle-delay 480
  notify-send "Screen timeout enabled (5 minutes)"
else
  # Currently has timeout, so disable it
  gsettings set org.gnome.desktop.session idle-delay 0
  notify-send "Screen timeout disabled"
fi
