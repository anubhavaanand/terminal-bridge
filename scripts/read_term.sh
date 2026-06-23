#!/usr/bin/env bash
# read_term.sh — Read and clean terminal output
# Usage: read_term.sh TYPE ID [LINES]
#   TYPE:  tmux | kitty | wezterm | script
#   ID:    pane address, window ID, pane ID, or log file path
#   LINES: number of lines to read (default 50)

set -uo pipefail

TYPE="${1:-}"
ID="${2:-}"
LINES="${3:-50}"

if [ -z "$TYPE" ] || [ -z "$ID" ]; then
    echo "Error: Usage: read_term.sh TYPE ID [LINES]"
    exit 1
fi

# ── CLEAN PIPELINE ───────────────────────────────────────────────────────
clean_output() {
    sed -E 's/\x1b(\[[0-9;?]*[a-zA-Z]|\][^\x07]*\x07|[M78H])//g' \
    | sed -e ':a' -e 's/[^\x08]\x08//g' -e 'ta' \
    | sed -E 's/\r//g' \
    | { command -v col >/dev/null 2>&1 && col -b || cat; } \
    | { [ -n "${FISH_VERSION:-}" ] && grep -v "^__fish\|^\[\?" || cat; }
}

# ── READ BY TYPE ─────────────────────────────────────────────────────────
case "$TYPE" in

  tmux)
    if ! tmux has-session 2>/dev/null; then
        echo "Error: tmux server not running"; exit 1
    fi
    TARGET="$ID"
    [ "$ID" = "!" ] && TARGET="!"
    tmux capture-pane -t "$TARGET" -p -S -"$LINES" 2>/dev/null \
        | tail -n "$LINES" | clean_output \
        || echo "Error: tmux pane '$ID' no longer exists"
    ;;

  kitty)
    command -v kitty >/dev/null 2>&1 || { echo "Error: kitty not found"; exit 1; }
    { kitty @ --to=unix:/tmp/kitty_bridge get-text --match "id:${ID}" --extent=screen 2>/dev/null \
      || kitty @ get-text --match "id:${ID}" --extent=screen 2>/dev/null; } \
        | tail -n "$LINES" | clean_output \
        || echo "Error: kitty window '$ID' not found or allow_remote_control not set"
    ;;

  wezterm)
    command -v wezterm >/dev/null 2>&1 || { echo "Error: wezterm not found"; exit 1; }
    wezterm cli get-text --pane-id "$ID" 2>/dev/null \
        | tail -n "$LINES" | clean_output \
        || echo "Error: WezTerm pane '$ID' no longer exists"
    ;;

  script)
    TARGET_LOG="$ID"
    if [ ! -f "$TARGET_LOG" ]; then
        echo "Error: No log found at '$TARGET_LOG'"
        echo "Run this in your target terminal: script -f ${TARGET_LOG}"
        exit 1
    fi
    # Permission check
    file_owner=$(stat -c '%U' "$TARGET_LOG" 2>/dev/null \
        || stat -f '%Su' "$TARGET_LOG" 2>/dev/null || echo "unknown")
    current_user=$(whoami)
    if [ "$file_owner" != "$current_user" ] && [ "$current_user" != "root" ]; then
        echo "Error: '$TARGET_LOG' owned by '$file_owner', running as '$current_user'"
        exit 1
    fi
    # Stale check — warn but read anyway
    age=$(( $(date +%s) - $(date -r "$TARGET_LOG" +%s 2>/dev/null || echo 0) ))
    [ $age -gt 3600 ] && echo "[WARNING: log is $((age/60))min old — may be stale]"
    tail -n "$LINES" "$TARGET_LOG" | clean_output
    ;;

  *)
    echo "Error: Unknown type '$TYPE'. Valid types: tmux | kitty | wezterm | script"
    exit 1
    ;;
esac
