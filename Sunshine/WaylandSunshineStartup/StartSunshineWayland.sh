#!/usr/bin/env bash

### Configuration ↓↓↓

# The desktop login user
USER_NAME="deck"
USER_UID=1000

# DBus: points to the desktop session
DBUS_ADDR="unix:path=/run/user/${USER_UID}/bus"

# Sunshine log file (change it if you don't like it)
LOG_FILE="/var/log/sunshine.log"

# Path to bwrap (same as your previous script)
BWRAP_PATH="./bwrap"

# Flatpak Sunshine App ID
APP_ID="dev.lizardbyte.app.Sunshine"

### Configuration ↑↑↑


set -e

# Ensure log file exists and has proper permissions
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

# bwrap permissions (same as before)
if [ -f "$BWRAP_PATH" ]; then
    chown 0:0 "$BWRAP_PATH"
    chmod u+s "$BWRAP_PATH"
fi

# Prepare audio and other environment variables for root (Sunshine needs them)
export PULSE_SERVER="unix:/run/user/${USER_UID}/pulse/native"
export FLATPAK_BWRAP="${BWRAP_PATH}"

# If Sunshine is not running as root, start it
if ! pgrep -u root -x sunshine >/dev/null 2>&1; then
    flatpak run --socket=wayland "$APP_ID" >>"$LOG_FILE" 2>&1 &
fi

notify_sunshine() {
    local summary="$1"

    sudo -u "$USER_NAME" env \
        DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" \
        gdbus call --session \
        --dest org.freedesktop.Notifications \
        --object-path /org/freedesktop/Notifications \
        --method org.freedesktop.Notifications.Notify \
        --timeout 1\
        "Sunshine Xwayland" \
        0 \
        "dev.lizardbyte.app.Sunshine" \
        "$summary" \
        "" \
        [] \
        "{'urgency': <byte 0>}" \
        0 >/dev/null
}

# Monitor the log and only process CLIENT CONNECTED / CLIENT DISCONNECTED lines
tail -F -n0 "$LOG_FILE" | \
grep --line-buffered -E 'CLIENT (CONNECTED|DISCONNECTED)' | \
while IFS= read -r line; do
    case "$line" in
        *"CLIENT CONNECTED")
            notify_sunshine "Stream Started"
            ;;
        *"CLIENT DISCONNECTED")
            notify_sunshine "Stream Paused"
            ;;
    esac
done
