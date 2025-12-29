#!/bin/bash

# List of networks where screen timeout should be disabled
# To add more, separate the strings by spaces in the brackets like:
# HOME_NETWORKS=("YourHomeWifiName" "SecondNetworkName" "ThirdNetworkName")
TRUSTED_NETWORKS=("Digicel_5G_WiFi_4tMB")

# Get currently connected WiFi SSID
CURRENT_WIFI=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)

# Check if current WiFi is in the list
if [[ " ${TRUSTED_NETWORKS[@]} " =~ " ${CURRENT_WIFI} " ]]; then
  # Connected to a home network, disable screen timeout
  dconf write /org/gnome/desktop/session/idle-delay "uint32 0"
  notify-send "Trusted network detected - Screen timeout disabled"
else
  # Not on a home network, enable screen timeout
  dconf write /org/gnome/desktop/session/idle-delay "uint32 300"
  notify-send "Trusted network not detected - Screen timeout enabled (5 minutes)"
fi
