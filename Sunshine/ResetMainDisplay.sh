#!/bin/bash
session_type=$(echo $XDG_SESSION_TYPE)

if [ "$session_type" = "wayland" ]; then
    # Wayland（KDE)
    kscreen-doctor output.eDP-1.mode.800x1280@90
    kscreen-doctor output.eDP-1.rotation.right
else
    # X11（xrandr）
    xrandr --output eDP --mode 800x1280 --rotate right
fi
