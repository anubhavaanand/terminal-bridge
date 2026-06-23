#!/usr/bin/env bash
# list_terms.sh — Enumerate all trackable terminals, exclude agent's own
# Output format: INDEX|TYPE|ID|LABEL|CURRENT_CMD

set -uo pipefail

MY_KITTY_WIN="${KITTY_WINDOW_ID:-}"
MY_WEZTERM_PANE="${WEZTERM_PANE:-}"
MY_TMUX_PANE=""
[ -n "${TMUX:-}" ] && MY_TMUX_PANE=$(tmux display-message -p "#{pane_id}" 2>/dev/null || true)

INDEX=0

# ── TMUX ────────────────────────────────────────────────────────────────
if command -v tmux >/dev/null 2>&1; then
    while IFS='|' read -r pane_id session win pane cmd; do
        [ "$pane_id" = "$MY_TMUX_PANE" ] && continue
        INDEX=$((INDEX+1))
        echo "${INDEX}|tmux|${pane_id}|${session}:${win}.${pane}|${cmd}"
    done < <(tmux list-panes -a \
        -F "#{pane_id}|#{session_name}|#{window_index}|#{pane_index}|#{pane_current_command}" \
        2>/dev/null || true)
fi

# ── KITTY ────────────────────────────────────────────────────────────────
if command -v kitty >/dev/null 2>&1; then
    kitty_data=$(kitty @ --to=unix:/tmp/kitty_bridge ls 2>/dev/null || kitty @ ls 2>/dev/null || true)
    if [ -n "$kitty_data" ] && command -v python3 >/dev/null 2>&1; then
        while IFS='|' read -r win_id title; do
            [ "$win_id" = "$MY_KITTY_WIN" ] && continue
            INDEX=$((INDEX+1))
            echo "${INDEX}|kitty|${win_id}|kitty:${win_id}|${title}"
        done < <(echo "$kitty_data" | python3 -c "
import json,sys
for osw in json.load(sys.stdin):
    for tab in osw.get('tabs',[]):
        for w in tab.get('windows',[]):
            print(f\"{w['id']}|{w.get('title','kitty')}\")
" 2>/dev/null || true)
    fi
fi

# ── WEZTERM ──────────────────────────────────────────────────────────────
if command -v wezterm >/dev/null 2>&1; then
    while IFS=$'\t' read -r pane_id title; do
        [ "$pane_id" = "$MY_WEZTERM_PANE" ] && continue
        INDEX=$((INDEX+1))
        echo "${INDEX}|wezterm|${pane_id}|wezterm:${pane_id}|${title}"
    done < <(wezterm cli list --format=json 2>/dev/null | python3 -c "
import json,sys
for p in json.load(sys.stdin):
    print(f\"{p['pane_id']}\t{p.get('title','wezterm')}\")
" 2>/dev/null || true)
fi

# ── SCRIPT LOG ───────────────────────────────────────────────────────────
LOG_FILE="/tmp/rt.log"
[ -w /tmp ] || LOG_FILE="/var/tmp/rt.log"
if [ -f "$LOG_FILE" ]; then
    file_time=$(stat -c %Y "$LOG_FILE" 2>/dev/null || stat -f %m "$LOG_FILE" 2>/dev/null || echo 0)
    age=$(( $(date +%s) - file_time ))
    [ $age -gt 3600 ] && status="STALE(${age}s old)" || status="active"
    INDEX=$((INDEX+1))
    echo "${INDEX}|script|${LOG_FILE}|script-session|${status}"
fi

# ── SSH DETECTION ────────────────────────────────────────────────────────
if [ -n "${SSH_CLIENT:-}" ] || [ -n "${SSH_TTY:-}" ]; then
    echo "SSH|ssh|remote|SSH session|Run script -f /tmp/rt.log on remote machine"
fi

# ── CONTAINER DETECTION ──────────────────────────────────────────────────
if [ -f "/.dockerenv" ] || [ "${container:-}" = "docker" ]; then
    echo "CONTAINER|container|local|Container detected|Using /var/tmp if /tmp unwritable"
fi

[ $INDEX -eq 0 ] && echo "NONE|none|none|No native terminals found|Run: script -f /tmp/rt.log in target terminal"
