# ═══════════════════════════════════════════════════════════════
# SHLLSHOCKD — AEGIS Pack
# Agyeman Enterprises enforcement commands.
# Auto-loaded when placed in the packs/ folder.
# ═══════════════════════════════════════════════════════════════

function stale-clear {
    <#
    .SYNOPSIS  Clear stale OO/AEGIS state files from current repo.
    .EXAMPLE   stale-clear
    #>
    $claudeDir = Join-Path $PWD '.claude'
    $staleFiles = @(
        'OO_APPROVED.json', 'OO_COMPLETE.json', 'OO_ESCALATION.json',
        'VOUCHSAFE_PREP.json', 'AUDIT_FAILURE.md', 'SCHEMA_READ',
        'VACCINE_CANDIDATE.json', 'OO_ESCALATED.json', 'OO_VIOLATION.json',
        'OO_ROUNDS.json', 'AUDITOR_CHECKPOINT', 'scheduled_tasks.lock'
    )
    $removed = 0
    foreach ($f in $staleFiles) {
        $path = Join-Path $claudeDir $f
        if (Test-Path $path) {
            $item = Get-Item $path
            if ($item.IsReadOnly) { $item.IsReadOnly = $false }
            Remove-Item $path -Force
            Write-Host "  Removed: .claude/$f" -ForegroundColor Gray
            $removed++
        }
    }
    if ($removed -eq 0) {
        Write-Host "Clean slate. No stale files." -ForegroundColor Green
    } else {
        Write-Host "$removed stale file(s) cleared." -ForegroundColor Green
    }
}

function stale-clear-all {
    <#
    .SYNOPSIS  Clear stale OO state files from ALL repos under C:\DEV.
    .EXAMPLE   stale-clear-all
    #>
    param([string]$Root = "C:\DEV")
    $staleNames = @(
        'OO_APPROVED.json', 'OO_COMPLETE.json', 'OO_ESCALATION.json',
        'VOUCHSAFE_PREP.json', 'OO_ESCALATED.json', 'OO_VIOLATION.json',
        'OO_ROUNDS.json', 'AUDITOR_CHECKPOINT'
    )
    $total = 0
    foreach ($name in $staleNames) {
        $found = Get-ChildItem $Root -Recurse -File -Include $name -ErrorAction SilentlyContinue
        foreach ($f in $found) {
            if ($f.IsReadOnly) { $f.IsReadOnly = $false }
            Remove-Item $f.FullName -Force
            $total++
        }
    }
    Write-Host "$total stale file(s) nuked across $Root" -ForegroundColor Green
}

function nuke-daemon-files {
    <#
    .SYNOPSIS  Delete ALL daemon-era OO files from every repo.
    .EXAMPLE   nuke-daemon-files
    .EXAMPLE   nuke-daemon-files -in C:\DEV
    #>
    param([Alias("in")][string]$Root = "C:\DEV")
    $daemonFiles = @(
        'Submit-PlanToOO.ps1', 'Complete-PlanWithOO.ps1',
        'hook-pre-tool-use.ps1', 'hook-prompt-submit.ps1',
        'hook-stop.ps1', 'hook-violation-scanner.ps1'
    )
    $total = 0
    foreach ($name in $daemonFiles) {
        $found = Get-ChildItem $Root -Recurse -File -Include $name -ErrorAction SilentlyContinue
        foreach ($f in $found) {
            Remove-Item $f.FullName -Force
            Write-Host "  Deleted: $($f.FullName)" -ForegroundColor Gray
            $total++
        }
    }
    Write-Host "$total daemon file(s) purged from $Root" -ForegroundColor Green
}

function enforcement-off {
    <#
    .SYNOPSIS  Disable AEGIS enforcement (emergency kill switch).
    .EXAMPLE   enforcement-off
    #>
    $env:AE_ENFORCEMENT_DISABLED = "1"
    Write-Host "AEGIS enforcement DISABLED for this session." -ForegroundColor Yellow
    Write-Host "Re-enable with: enforcement-on" -ForegroundColor Gray
}

function enforcement-on {
    <#
    .SYNOPSIS  Re-enable AEGIS enforcement.
    .EXAMPLE   enforcement-on
    #>
    Remove-Item env:AE_ENFORCEMENT_DISABLED -ErrorAction SilentlyContinue
    Write-Host "AEGIS enforcement ENABLED." -ForegroundColor Green
}

function aegis-status {
    <#
    .SYNOPSIS  Show AEGIS state for current repo.
    .EXAMPLE   aegis-status
    #>
    $claudeDir = Join-Path $PWD '.claude'
    Write-Host "`n  AEGIS Status: $(Split-Path -Leaf $PWD)" -ForegroundColor Cyan
    Write-Host "  ─────────────────────────────────" -ForegroundColor DarkGray

    $files = @(
        @{Name='OO_APPROVED.json';  Label='Plan Approved'},
        @{Name='VOUCHSAFE_PREP.json'; Label='OO Certified'},
        @{Name='OO_ESCALATION.json'; Label='Escalation Active'},
        @{Name='AUDIT_FAILURE.md';  Label='Audit Failures'},
        @{Name='SCHEMA_READ';       Label='Schema Read'}
    )
    foreach ($f in $files) {
        $path = Join-Path $claudeDir $f.Name
        if (Test-Path $path) {
            $age = [math]::Round(((Get-Date) - (Get-Item $path).LastWriteTime).TotalHours, 1)
            $color = if ($f.Name -match 'ESCALATION|FAILURE') { 'Red' } else { 'Green' }
            Write-Host "    $($f.Label): YES (${age}h ago)" -ForegroundColor $color
        } else {
            Write-Host "    $($f.Label): -" -ForegroundColor Gray
        }
    }

    $enforced = -not ($env:AE_ENFORCEMENT_DISABLED -eq "1")
    $eColor = if ($enforced) { 'Green' } else { 'Yellow' }
    Write-Host "    Enforcement: $(if ($enforced) {'ON'} else {'OFF'})" -ForegroundColor $eColor
    Write-Host ""
}

function find-secrets {
    <#
    .SYNOPSIS  Scan for hardcoded secrets in source files.
    .EXAMPLE   find-secrets
    .EXAMPLE   find-secrets -in C:\DEV\myapp
    #>
    param([Alias("in")][string]$Root = ".")
    $patterns = @(
        'ghp_[A-Za-z0-9]{36}',           # GitHub PAT
        'eyJhbGci[A-Za-z0-9+/=]{50,}',   # JWT / Supabase key
        'sk_live_[A-Za-z0-9]{24,}',       # Stripe secret
        'PRIVATE KEY'                      # Ed25519/RSA private key
    )
    $hits = @()
    Get-ChildItem $Root -Recurse -File -Include "*.ts","*.tsx","*.js","*.ps1","*.sh","*.env.local","*.json" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch 'node_modules|\.next|\.git\\|dist\\' } |
        ForEach-Object {
            $file = $_
            $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
            foreach ($p in $patterns) {
                if ($content -match $p) {
                    $hits += [PSCustomObject]@{ File = $file.FullName; Pattern = $p }
                }
            }
        }
    if ($hits.Count -eq 0) {
        Write-Host "No hardcoded secrets found." -ForegroundColor Green
    } else {
        Write-Host "`nFOUND $($hits.Count) potential secret(s):" -ForegroundColor Red
        $hits | Format-Table -AutoSize
    }
}

# ─── AEGIS PACK HELP ─────────────────────────────────────────────

function aegis-help {
    Write-Host ""
    Write-Host "  SHLLSHOCKD — AEGIS Pack" -ForegroundColor Cyan
    Write-Host "  ─────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  CLEANUP" -ForegroundColor Yellow
    Write-Host "    stale-clear              Clear OO state (this repo)"
    Write-Host "    stale-clear-all          Clear OO state (all repos)"
    Write-Host "    nuke-daemon-files        Purge daemon-era files everywhere"
    Write-Host ""
    Write-Host "  ENFORCEMENT" -ForegroundColor Yellow
    Write-Host "    enforcement-off          Emergency kill switch"
    Write-Host "    enforcement-on           Re-enable enforcement"
    Write-Host "    aegis-status             Show AEGIS state for this repo"
    Write-Host ""
    Write-Host "  SECURITY" -ForegroundColor Yellow
    Write-Host "    find-secrets             Scan for hardcoded secrets"
    Write-Host ""
}

Write-Host "  + AEGIS pack loaded. Type 'aegis-help' for commands." -ForegroundColor DarkGray
