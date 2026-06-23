#!/usr/bin/env bash
# send_cmd.sh — Send a command to a tracked terminal
# Usage: send_cmd.sh TYPE ID COMMAND
# Destructive patterns are always hard-blocked at script level.

set -uo pipefail

TYPE="${1:-}"
ID="${2:-}"
CMD="${3:-}"

if [ -z "$TYPE" ] || [ -z "$ID" ] || [ -z "$CMD" ]; then
    echo "Error: Usage: send_cmd.sh TYPE ID COMMAND"; exit 1
fi

# ── ALWAYS-BLOCK DESTRUCTIVE PATTERNS ───────────────────────────────────
# Block even if preceded by shell operators (&&, |, ;)
BLOCKED='(^|[;&|]+)[[:space:]]*(rm[ /]|sudo |kill |dd |mkfs|chmod |chown |curl.*\|.*sh|wget.*\|.*sh|\:\:)'
if echo "$CMD" | grep -qiE "$BLOCKED"; then
    echo "BLOCKED: '$CMD' is destructive. Requires explicit user confirmation in chat."
    exit 2
fi

case "$TYPE" in
  tmux)
    tmux send-keys -t "$ID" "$CMD" Enter 2>/dev/null \
        || echo "Error: tmux pane '$ID' not found"
    ;;
  kitty)
    { kitty @ --to=unix:/tmp/kitty_bridge send-text --match "id:${ID}" "${CMD}"$'\n' 2>/dev/null \
      || kitty @ send-text --match "id:${ID}" "${CMD}"$'\n' 2>/dev/null; } \
        || echo "Error: kitty window '$ID' not found"
    ;;
  wezterm)
    wezterm cli send-text --pane-id "$ID" "${CMD}"$'\n' 2>/dev/null \
        || echo "Error: WezTerm pane '$ID' not found"
    ;;
  script)
    echo "Error: Cannot send commands to a script-log session. Native terminal required."
    exit 1
    ;;
  *)
    echo "Error: Unknown type '$TYPE'"; exit 1
    ;;
esac
