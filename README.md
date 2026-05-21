<div align="center">
  <h1>🌉 terminal-bridge</h1>
  <p><strong>Let your AI agent look over your shoulder — and fix what it sees.</strong></p>
  
  [![skills.sh](https://skills.sh/b/anubhavaanand/terminal-bridge)](https://skills.sh/anubhavaanand/terminal-bridge)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
</div>

<br />

`terminal-bridge` is a zero-prep agent skill that gives your AI CLI (like Antigravity, Claude Code, or Gemini CLI) native, real-time access to your active terminal sessions. Stop copy-pasting logs and tracebacks. Just ask your agent: *"what went wrong?"*

---

## ✨ Features
- **Zero-prep Tracking:** Natively reads output from `tmux`, `Kitty`, and `WezTerm` without any setup commands.
- **Concurrent Slots:** Watch your backend API server and frontend build simultaneously.
- **Auto-Fallbacks:** Gracefully falls back to `script` logging for SSH, containers, and native terminals.
- **Strict Security:** Hard-blocks destructive commands (`rm`, `sudo`, `kill`) and strips malicious ANSI escapes.

## 🚀 Quick Start

**1. Install the skill into your agent:**
```bash
npx skills add anubhavaanand/terminal-bridge
```

**2. Start working normally.** The agent automatically scans and lists your open terminals on load.

**3. Tell it which pane to track:**
> *"Track window 2 as frontend and window 3 as backend."*

**4. Ask for help when stuck:**
> *"check backend, why did it crash?"*

---

## 🖥️ Supported Terminals

| Terminal | Method | Setup Required |
|:---|:---|:---|
| **tmux** | `capture-pane` | None ✅ |
| **Kitty** | Remote Control API | One-time config line *(agent handles it)* |
| **WezTerm** | CLI API | None ✅ |
| **Konsole / GNOME / Alacritty** | `script` fallback | Run once per session |
| **SSH / Containers** | `script` fallback | Auto-detects & guides you |

<br />

<details>
<summary><b>View Fallback Instructions</b></summary>
<br/>
If your terminal isn't natively supported, the agent will gracefully guide you to run:

```bash
script -f /tmp/rt.log
```
Run this once at the start of your session, and the agent will automatically detect and read from it.
</details>

---

## 🛡️ Control Mode (Optional)

By default, the bridge is **read-only**. You can grant the agent permission to actively fix issues by typing commands for you.

Say **"auto-run mode on"** to enable execution. 

> ⚠️ **Note:** Destructive commands (e.g., `rm`, `sudo`, `kill`) will *always* require your explicit confirmation in the chat, regardless of your trust mode.
