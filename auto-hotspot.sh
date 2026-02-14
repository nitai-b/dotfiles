#!/bin/bash

# Mobile Hotspot Auto-Connect Script
# Configure these variables for your setup
HOTSPOT_SSID="Pickle9"          # Change this to your actual hotspot SSID
HOTSPOT_PASSWORD="YourPassword" # Change this to your hotspot password
CHECK_INTERVAL=10               # Check every 10 seconds

# Log file
LOG_FILE="/var/log/hotspot_connect.log"

# Function to log messages
log_message() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >>"$LOG_FILE"
}

# Function to check if connected to hotspot
is_connected_to_hotspot() {
  nmcli connection show --active | grep -q "$HOTSPOT_SSID"
  return $?
}

# Function to connect to hotspot
connect_to_hotspot() {
  log_message "Attempting to connect to $HOTSPOT_SSID..."

  # Try to connect using nmcli
  nmcli device wifi connect "$HOTSPOT_SSID" password "$HOTSPOT_PASSWORD" 2>/dev/null

  if [ $? -eq 0 ]; then
    log_message "Successfully connected to $HOTSPOT_SSID"
    return 0
  else
    log_message "Failed to connect to $HOTSPOT_SSID"
    return 1
  fi
}

# Function to check if hotspot is available
is_hotspot_available() {
  nmcli device wifi list | grep -q "$HOTSPOT_SSID"
  return $?
}

# Main loop
log_message "Hotspot monitor started"

while true; do
  if is_hotspot_available; then
    if ! is_connected_to_hotspot; then
      connect_to_hotspot
      sleep 5 # Wait a bit before checking again
    fi
  fi

  sleep "$CHECK_INTERVAL"
done
