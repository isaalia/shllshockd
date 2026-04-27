# SHLLSHOCKD

**Shell Shocked? We got you.**

Human-readable PowerShell commands for people who build things, not people who memorize syntax.

---

## The Problem

You're a founder, a physician, a designer, a CEO. You use AI to build apps. But every time the AI says *"just run `Get-ChildItem -Recurse -File -Include "*.ps1" -ErrorAction SilentlyContinue | Remove-Item -Force`"* — you freeze.

SHLLSHOCKD translates that to:

```powershell
nuke-files "*.ps1"
```

That's it. Human words. The machine figures out the rest.

---

## Install (one command)

```powershell
irm https://raw.githubusercontent.com/isaalia/shllshockd/main/install/install.ps1 | iex
```

Restart PowerShell. Type `shllshockd`. You're in.

---

## Commands

### Files
| You type | What it does |
|---|---|
| `find-files "*.log"` | Find files by name |
| `nuke-files "old-config.json"` | Find and delete (confirms first) |
| `count-files "*.ts"` | Count matching files |
| `show-big-files` | Largest files in folder |
| `whats-here` | Clean directory listing |
| `find-text "TODO" -type "*.ts"` | Search inside files |
| `zip-this` | Zip folder, skip junk |

### Git
| You type | What it does |
|---|---|
| `what-changed` | Show uncommitted changes |
| `what-branch` | Current branch name |
| `push-it "fixed login"` | Add + commit + push |
| `undo-last-commit` | Undo commit, keep files |
| `recent-commits` | Last 10 commits |
| `stash-it "wip"` | Save work without committing |
| `unstash` | Restore stashed work |

### System
| You type | What it does |
|---|---|
| `kill-port 3000` | Kill process on a port |
| `whats-on-port 3000` | What's using a port |
| `free-space` | Disk space on all drives |
| `whats-running` | Top processes by memory |
| `env-check "GITHUB_TOKEN"` | Check env variable |

### Cleanup
| You type | What it does |
|---|---|
| `nuke-node-modules` | Delete node_modules here |
| `nuke-node-modules -all` | Delete ALL node_modules |

---

## Plugin Packs

SHLLSHOCKD is extensible. Drop a `.ps1` file in the `packs/` folder and it auto-loads.

### Included Packs

**AEGIS Pack** (`packs/aegis.ps1`) — AI governance commands for [Agyeman Enterprises](https://agyemanenterprises.com):

| You type | What it does |
|---|---|
| `stale-clear` | Clear OO state files (this repo) |
| `stale-clear-all` | Clear OO state (all repos) |
| `nuke-daemon-files` | Purge legacy daemon files everywhere |
| `enforcement-off` | Emergency kill switch |
| `enforcement-on` | Re-enable enforcement |
| `aegis-status` | Show AEGIS state for current repo |
| `find-secrets` | Scan for hardcoded secrets |

### Create Your Own Pack

Create `packs/my-pack.ps1`:

```powershell
function deploy-prod {
    Write-Host "Deploying to production..." -ForegroundColor Cyan
    vercel --prod
}

function check-health {
    param([string]$Url)
    $status = (Invoke-WebRequest $Url -Method Head -TimeoutSec 5).StatusCode
    Write-Host "$Url → $status" -ForegroundColor $(if ($status -eq 200) {'Green'} else {'Red'})
}
```

It auto-loads next time you open PowerShell.

---

## How It Works

SHLLSHOCKD is a PowerShell module that loads into your `$PROFILE`. Each "command" is a PowerShell function with a human-readable name wrapping the cryptic syntax you'd otherwise have to memorize.

The `packs/` folder is scanned at load time. Any `.ps1` file in it gets dot-sourced, adding its functions to your session. This means teams can share domain-specific command packs without touching the core.

---

## Requirements

- Windows 10/11 with PowerShell 5.1+ (comes pre-installed)
- Git (for git commands)
- That's it.

---

## Philosophy

> "The terminal is the most powerful tool on your computer. It shouldn't require a CS degree to use it."

SHLLSHOCKD was born from a physician-entrepreneur who built 120+ apps with AI but kept getting stuck on terminal commands. The AI would say "just run this" and paste a wall of syntax that meant nothing to a human.

So we made the syntax mean something.

---

## Contributing

PRs welcome. The rules:

1. **Command names must be plain English.** If your grandma can't guess what it does from the name, rename it.
2. **Every command gets a `.SYNOPSIS` and `.EXAMPLE`.** No undocumented functions.
3. **Dangerous commands confirm first.** Anything that deletes must show what it'll kill and ask for confirmation (unless `-YesIAmSure` is passed).
4. **Packs stay separate.** Domain-specific commands go in `packs/`, not in core.

---

## License

MIT — use it, fork it, share it, sell it. Just don't remove the attribution.

---

**Built by [Agyeman Enterprises](https://agyemanenterprises.com)** — Sovereign infrastructure for the AI age.
