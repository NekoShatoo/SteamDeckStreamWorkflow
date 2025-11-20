#!/bin/bash
session_type=$(echo $XDG_SESSION_TYPE)

if [ "$session_type" = "wayland" ]; then
    # Wayland（KDE)
    kscreen-doctor output.eDP-1.mode.1600x1200@120
    kscreen-doctor output.eDP-1.rotation.none
else
    # X11（xrandr）
    xrandr --output eDP --mode 1200x1600_120.00
fi
