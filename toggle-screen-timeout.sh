#!/bin/bash

CURRENT=$(dconf read /org/gnome/desktop/session/idle-delay)

if [ "$CURRENT" == "uint32 0" ]; then
  dconf write /org/gnome/desktop/session/idle-delay "uint32 300"
  notify-send "Screen timeout enabled (5 minutes)"
else
  dconf write /org/gnome/desktop/session/idle-delay "uint32 0"
  notify-send "Screen timeout disabled"
fi
