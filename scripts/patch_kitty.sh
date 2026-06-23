#!/usr/bin/env bash
# patch_kitty.sh — Enable Kitty remote control automatically

set -euo pipefail

KITTY_CONF="${HOME}/.config/kitty/kitty.conf"

mkdir -p "$(dirname "$KITTY_CONF")"

if ! grep -q "^allow_remote_control" "$KITTY_CONF" 2>/dev/null; then
    echo "allow_remote_control yes" >> "$KITTY_CONF"
    echo "Added 'allow_remote_control yes' to $KITTY_CONF"
    
    if pgrep -f "kitty" >/dev/null; then
        kill -SIGUSR1 $(pgrep -f "kitty") 2>/dev/null || true
        echo "Reloaded Kitty configuration."
    fi
else
    echo "Kitty remote control is already enabled."
fi
