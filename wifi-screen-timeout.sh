#!/bin/bash

# Get your home WiFi SSID
HOME_WIFI="Digicel_5G_WiFi_4tMB"

# Get currently connected WiFi SSID
CURRENT_WIFI=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)

if [ "$CURRENT_WIFI" == "$HOME_WIFI" ]; then
  # Connected to home WiFi, disable screen timeout
  dconf write /org/gnome/desktop/session/idle-delay "uint32 0"
  notify-send "Home WiFi detected - Screen timeout disabled"
else
  # Not on home WiFi, enable screen timeout (5 minutes)
  dconf write /org/gnome/desktop/session/idle-delay "uint32 300"
  notify-send "Away from home - Screen timeout enabled (5 minutes)"
fi
