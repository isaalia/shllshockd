# Contributing to SHLLSHOCKD

Shell Shocked? Us too. That's why we're building this.

---

## The Golden Rule

**If your grandma can't guess what the command does from its name, rename it.**

`find-files` — yes. `Get-ChildItem-Recurse-File-Include` — no.

---

## How to Contribute

### Add a Command to Core

1. Fork the repo
2. Edit `core/shllshockd.ps1`
3. Add your function following this pattern:

```powershell
function your-command {
    <#
    .SYNOPSIS  One line explaining what it does.
    .EXAMPLE   your-command "something"
    .EXAMPLE   your-command "something" -flag
    #>
    param(
        [Parameter(Mandatory)][string]$Name
    )
    # The actual PowerShell magic goes here
}
```

4. Add it to the help menu in the `shllshockd` function at the bottom
5. Submit a PR with the title: `feat: add your-command`

### Create a Pack

Packs are domain-specific command sets. They auto-load from the `packs/` folder.

1. Fork the repo
2. Create `packs/your-pack.ps1`
3. Use this template:

```powershell
# ═══════════════════════════════════════════════════════════════
# SHLLSHOCKD — Your Pack Name
# What this pack is for (one line).
# Auto-loaded when placed in the packs/ folder.
# ═══════════════════════════════════════════════════════════════

function your-command {
    <#
    .SYNOPSIS  What it does.
    .EXAMPLE   your-command "example"
    #>
    param([Parameter(Mandatory)][string]$Input)
    # Do the thing
}

function your-pack-help {
    Write-Host ""
    Write-Host "  SHLLSHOCKD — Your Pack" -ForegroundColor Cyan
    Write-Host "  ─────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "    your-command             What it does" 
    Write-Host ""
}

Write-Host "  + Your Pack loaded. Type 'your-pack-help' for commands." -ForegroundColor DarkGray
```

4. Submit a PR with the title: `pack: add your-pack`

### Pack Ideas We'd Love to See

- **Docker pack** — `start-container`, `stop-all`, `nuke-containers`, `show-logs`
- **Node/npm pack** — `fresh-install`, `outdated`, `audit-fix`, `which-package-manager`
- **Supabase pack** — `db-reset`, `db-push`, `show-tables`, `gen-types`
- **Vercel pack** — `deploy-preview`, `deploy-prod`, `show-deployments`, `rollback`
- **SSH pack** — `connect-to "server"`, `copy-to "server" "file"`, `show-keys`
- **AWS pack** — `show-buckets`, `show-instances`, `tail-logs "function"`
- **Python pack** — `venv-create`, `venv-activate`, `pip-install`, `freeze-deps`
- **Database pack** — `run-sql "query"`, `show-tables`, `dump-db`, `restore-db`

---

## Rules

1. **Plain English names.** `show-logs` not `Get-EventLog-FilterHashtable`.
2. **Every function gets `.SYNOPSIS` and `.EXAMPLE`.** No undocumented commands.
3. **Dangerous commands confirm first.** Anything that deletes shows what it'll kill and asks `(y/n)` unless `-YesIAmSure` is passed.
4. **No dependencies.** Core commands must work with a fresh Windows PowerShell install. Packs can require tools (Docker, Node, etc.) but must check and tell the user if they're missing.
5. **Packs stay separate.** Don't put Docker commands in core. That's what packs are for.
6. **Test on Windows PowerShell 5.1+.** That's what most people have. If it also works on pwsh 7+, great.

---

## PR Checklist

- [ ] Command name is plain English
- [ ] Has `.SYNOPSIS` and at least one `.EXAMPLE`
- [ ] Dangerous operations confirm before executing
- [ ] Added to the help menu function
- [ ] Tested on Windows PowerShell 5.1 or later
- [ ] No external dependencies (core) or dependencies documented (packs)

---

## Updating SHLLSHOCKD

If you already have SHLLSHOCKD installed:

```powershell
cd $env:USERPROFILE\.shllshockd
git pull
```

Then restart PowerShell. Done.

If you installed from zip, just download the latest zip and extract over the old one.

---

## Repo Structure

```
shllshockd/
├── core/
│   └── shllshockd.ps1    ← All core commands live here
├── packs/
│   ├── aegis.ps1          ← Example: AI governance commands
│   └── your-pack.ps1      ← Your pack goes here
├── install/
│   └── install.ps1        ← One-line installer
├── CONTRIBUTING.md         ← You are here
├── README.md
└── LICENSE                 ← MIT
```

---

## Code of Conduct

Be kind. Write clear code. Name things so humans understand them.
That's the whole code of conduct.
