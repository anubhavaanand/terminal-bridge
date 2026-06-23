#!/usr/bin/env bash
# patch_kitty.sh — Enable Kitty remote control automatically

set -euo pipefail

KITTY_CONF="${HOME}/.config/kitty/kitty.conf"

mkdir -p "$(dirname "$KITTY_CONF")"

if ! grep -q "^allow_remote_control" "$KITTY_CONF" 2>/dev/null || ! grep -q "^listen_on" "$KITTY_CONF" 2>/dev/null; then
    sed -i '/^allow_remote_control/d' "$KITTY_CONF" 2>/dev/null || true
    sed -i '/^listen_on/d' "$KITTY_CONF" 2>/dev/null || true
    echo "allow_remote_control yes" >> "$KITTY_CONF"
    echo "listen_on unix:/tmp/kitty_bridge" >> "$KITTY_CONF"
    echo "Configured Kitty for headless remote control (socket: /tmp/kitty_bridge)"
    if pgrep -f "kitty" >/dev/null; then
        kill -SIGUSR1 $(pgrep -f "kitty") 2>/dev/null || true
        echo "Reloaded Kitty configuration."
    fi
else
    echo "Kitty remote control is already enabled."
fi
