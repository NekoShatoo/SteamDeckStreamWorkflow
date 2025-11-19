#!/usr/bin/env bash
########################################
# Script executed when watcher starts
########################################
INIT_SCRIPT="./ResetMainDisplay.sh"
########################################
# Constants (easy to edit)
########################################

# Sunshine notification titles
SUNSHINE_START_STRING="Stream Started"
SUNSHINE_STOP_STRING="Stream Paused"

# Scripts to run on Sunshine start/stop (relative or absolute paths)
START_SCRIPT="./SunshineDisplay.sh"
STOP_SCRIPT="./ResetMainDisplay.sh"

# Scripts to run on system sleep/wakeup
SLEEP_SCRIPT="./ResetMainDisplay.sh"
WAKE_SCRIPT=""

########################################
# Run init script when this watcher starts
########################################
if [ -x "$INIT_SCRIPT" ]; then
    "$INIT_SCRIPT"
fi

########################################
# Function: listen to notification events on session bus
########################################

listen_notifications() {
    dbus-monitor "interface='org.freedesktop.Notifications'" |
    awk -v start_str="$SUNSHINE_START_STRING" \
        -v stop_str="$SUNSHINE_STOP_STRING" \
        -v start_exec="$START_SCRIPT" \
        -v stop_exec="$STOP_SCRIPT" '
    /member=Notify/ {
        in_notif = 1
        str_idx = 0
        summary = ""
    }

    /^ *string "/ && in_notif {
        s = $0
        sub(/^ *string "/, "", s)
        sub(/"$/, "", s)
        str_idx++

        # summary (notification title) is the 3rd string
        if (str_idx == 3) summary = s
    }

    /^ *int32 / && in_notif {
        # End of this notification
        if (summary == start_str) {
            # Execute start script
            system(start_exec)
        }
        else if (summary == stop_str) {
            # Execute stop script
            system(stop_exec)
        }

        in_notif = 0
    }
    '
}

########################################
# Function: listen to sleep/wakeup events on system bus
########################################

listen_sleep_wake() {
    dbus-monitor --system "interface='org.freedesktop.login1.Manager'" |
    while read -r line; do
        # PrepareForSleep(true)  -> going to sleep
        # PrepareForSleep(false) -> waking up
        case "$line" in
            *"PrepareForSleep(true)"*)
                # System is going to sleep
                if [ -x "$SLEEP_SCRIPT" ]; then
                    "$SLEEP_SCRIPT" &
                fi
                ;;
            *"PrepareForSleep(false)"*)
                # System just woke up
                if [ -x "$WAKE_SCRIPT" ]; then
                    "$WAKE_SCRIPT" &
                fi
                ;;
        esac
    done
}

########################################
# Start both listeners and wait
########################################

listen_notifications &
PID_NOTIF=$!

listen_sleep_wake &
PID_SLEEP=$!

# Wait for both background processes (simple way to keep main script alive)
wait "$PID_NOTIF" "$PID_SLEEP"
