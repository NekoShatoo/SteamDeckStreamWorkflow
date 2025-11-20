#!/usr/bin/env bash

### 配置区 ↓↓↓

# 桌面登录的用户
USER_NAME="deck"
USER_UID=1000

# DBus：指向桌面会话
DBUS_ADDR="unix:path=/run/user/${USER_UID}/bus"

# Sunshine 日志（你不爽可以改到别的地方）
LOG_FILE="/var/log/sunshine.log"

# bwrap 的路径（按你之前的脚本来）
BWRAP_PATH="./bwrap"

# flatpak 的 Sunshine ID
APP_ID="dev.lizardbyte.app.Sunshine"

### 配置区 ↑↑↑


set -e

# 确保日志文件存在并有权限
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

# bwrap 权限（你之前就是这么干的）
if [ -f "$BWRAP_PATH" ]; then
    chown 0:0 "$BWRAP_PATH"
    chmod u+s "$BWRAP_PATH"
fi

# 给 root 进程准备音频等环境（Sunshine 会用到）
export PULSE_SERVER="unix:/run/user/${USER_UID}/pulse/native"
export FLATPAK_BWRAP="${BWRAP_PATH}"

# 如果 Sunshine 没在 root 身份下跑，就启动一个
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



# 监控日志：只看包含 CLIENT CONNECTED / CLIENT DISCONNECTED 的行
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
