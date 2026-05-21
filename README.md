# terminal-bridge

[![skills.sh](https://skills.sh/b/anubhavaanand/terminal-bridge)](https://skills.sh/anubhavaanand/terminal-bridge)

Let your AI agent look over your shoulder — and fix what it sees.

## Supported terminals

| Terminal | Method | Setup |
|---|---|---|
| tmux | capture-pane | None |
| Kitty | Remote control API | One-time config line (agent handles it) |
| WezTerm | CLI API | None |
| Konsole | script fallback | Once per session |
| GNOME Terminal | script fallback | Once per session |
| Alacritty | script fallback | Once per session |
| SSH sessions | script fallback | Run on remote machine |
| Containers | script fallback | Auto-detects /tmp permissions |

## Usage

1. Install skill in your agent (Antigravity, Claude Code, Gemini CLI, etc.):
   ```bash
   npx skills add anubhavaanand/terminal-bridge
   ```
2. Agent scans and lists your open terminals on load
3. Tell it which to track — you can name them
4. Work normally. When stuck: *"what went wrong?"*

## Naming terminals

"track 1 as backend, 2 as frontend"
→ "check backend" / "check frontend"

## Control mode (optional)

Read-only by default. Say **"auto-run mode on"** to let the agent send commands.
Destructive commands always require explicit confirmation.

## Fallback

If your terminal isn't natively supported:
```bash
script -f /tmp/rt.log
```
Run once at session start. Agent detects it automatically.
