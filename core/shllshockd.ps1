# ═══════════════════════════════════════════════════════════════
# SHLLSHOCKD — Core Module
# "Shell Shocked? We got you."
#
# Human-readable PowerShell commands for people who build things,
# not people who memorize syntax.
#
# Install: irm https://shllshockd.dev/install.ps1 | iex
# Or:      . "$env:USERPROFILE\.shllshockd\shllshockd.ps1"
# ═══════════════════════════════════════════════════════════════

# ─── FILE OPERATIONS ────────────────────────────────────────────

function find-files {
    <#
    .SYNOPSIS  Find files by name anywhere under a folder.
    .EXAMPLE   find-files "package.json"
    .EXAMPLE   find-files "*.ps1" -in C:\Projects
    #>
    param(
        [Parameter(Mandatory)][string]$Name,
        [Alias("in")][string]$Root = "."
    )
    Get-ChildItem $Root -Recurse -File -Include $Name -ErrorAction SilentlyContinue |
        Select-Object FullName, Length, LastWriteTime
}

function nuke-files {
    <#
    .SYNOPSIS  Find and DELETE files by name. Shows what it'll kill first.
    .EXAMPLE   nuke-files "Submit-PlanToOO.ps1"
    .EXAMPLE   nuke-files "*.log" -in C:\DEV
    #>
    param(
        [Parameter(Mandatory)][string]$Name,
        [Alias("in")][string]$Root = ".",
        [switch]$YesIAmSure
    )
    $targets = Get-ChildItem $Root -Recurse -File -Include $Name -ErrorAction SilentlyContinue
    if ($targets.Count -eq 0) {
        Write-Host "Nothing found matching '$Name'" -ForegroundColor Gray
        return
    }
    Write-Host "`nFound $($targets.Count) file(s):" -ForegroundColor Yellow
    $targets | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }

    if (-not $YesIAmSure) {
        $confirm = Read-Host "`nDelete all $($targets.Count)? (y/n)"
        if ($confirm -ne 'y') { Write-Host "Cancelled." -ForegroundColor Gray; return }
    }
    $targets | Remove-Item -Force
    Write-Host "$($targets.Count) file(s) deleted." -ForegroundColor Green
}

function count-files {
    <#
    .SYNOPSIS  Count files matching a name.
    .EXAMPLE   count-files "*.ts" -in C:\DEV\myapp
    #>
    param(
        [Parameter(Mandatory)][string]$Name,
        [Alias("in")][string]$Root = "."
    )
    $count = (Get-ChildItem $Root -Recurse -File -Include $Name -ErrorAction SilentlyContinue | Measure-Object).Count
    Write-Host "$count file(s) matching '$Name'" -ForegroundColor Cyan
}

function show-big-files {
    <#
    .SYNOPSIS  Find the largest files in a folder.
    .EXAMPLE   show-big-files
    .EXAMPLE   show-big-files -top 20 -in C:\DEV
    #>
    param(
        [int]$Top = 10,
        [Alias("in")][string]$Root = "."
    )
    Get-ChildItem $Root -Recurse -File -ErrorAction SilentlyContinue |
        Sort-Object Length -Descending |
        Select-Object -First $Top @{N='Size(MB)';E={[math]::Round($_.Length/1MB,2)}}, FullName
}

function whats-here {
    <#
    .SYNOPSIS  Show folder contents, clean and simple.
    .EXAMPLE   whats-here
    .EXAMPLE   whats-here C:\DEV
    #>
    param([string]$Path = ".")
    Get-ChildItem $Path | Format-Table Mode, LastWriteTime, @{N='Size';E={
        if ($_.PSIsContainer) { '' } else { '{0:N0} KB' -f ($_.Length/1KB) }
    }}, Name -AutoSize
}

function find-text {
    <#
    .SYNOPSIS  Search inside files for a string.
    .EXAMPLE   find-text "CALLBACK_SIGNING_SECRET" -in C:\DEV\alrtme
    .EXAMPLE   find-text "as any" -in . -type "*.ts"
    #>
    param(
        [Parameter(Mandatory)][string]$Text,
        [Alias("in")][string]$Root = ".",
        [Alias("type")][string]$FileType = "*.*"
    )
    Get-ChildItem $Root -Recurse -File -Include $FileType -ErrorAction SilentlyContinue |
        Select-String -Pattern $Text -SimpleMatch |
        Select-Object Path, LineNumber, Line |
        Format-Table -AutoSize
}

function zip-this {
    <#
    .SYNOPSIS  Zip current folder, skipping node_modules and .git.
    .EXAMPLE   zip-this
    .EXAMPLE   zip-this -name "backup"
    #>
    param(
        [string]$Name = (Split-Path -Leaf (Get-Location)),
        [string]$Path = "."
    )
    $dest = Join-Path (Split-Path $Path) "$Name.zip"
    Get-ChildItem $Path -Recurse -File |
        Where-Object { $_.FullName -notmatch 'node_modules|\.next|\.git\\|dist\\|logs\\' } |
        Compress-Archive -DestinationPath $dest -Force
    Write-Host "Zipped to: $dest" -ForegroundColor Green
}

# ─── GIT OPERATIONS ─────────────────────────────────────────────

function what-changed {
    <#
    .SYNOPSIS  Show uncommitted changes (short version).
    .EXAMPLE   what-changed
    #>
    git status --short
}

function what-branch {
    <#
    .SYNOPSIS  Show current branch name.
    .EXAMPLE   what-branch
    #>
    git branch --show-current
}

function undo-last-commit {
    <#
    .SYNOPSIS  Undo last commit but keep the files.
    .EXAMPLE   undo-last-commit
    #>
    Write-Host "Undoing last commit (files are safe)..." -ForegroundColor Yellow
    git reset --soft HEAD~1
    Write-Host "Done. Your changes are still staged." -ForegroundColor Green
}

function push-it {
    <#
    .SYNOPSIS  Add, commit, push in one shot.
    .EXAMPLE   push-it "fixed the login bug"
    #>
    param([Parameter(Mandatory)][string]$Message)
    git add -A
    git commit -m $Message
    git push
}

function recent-commits {
    <#
    .SYNOPSIS  Show last N commits, clean format.
    .EXAMPLE   recent-commits
    .EXAMPLE   recent-commits -count 20
    #>
    param([int]$Count = 10)
    git log --oneline -n $Count
}

function stash-it {
    <#
    .SYNOPSIS  Save current work without committing.
    .EXAMPLE   stash-it "halfway through auth fix"
    #>
    param([string]$Message = "WIP")
    git stash push -m $Message
    Write-Host "Stashed: $Message" -ForegroundColor Green
}

function unstash {
    <#
    .SYNOPSIS  Restore last stashed work.
    .EXAMPLE   unstash
    #>
    git stash pop
}

# ─── SYSTEM / DEV OPS ───────────────────────────────────────────

function kill-port {
    <#
    .SYNOPSIS  Kill whatever is running on a port.
    .EXAMPLE   kill-port 3000
    .EXAMPLE   kill-port 4021
    #>
    param([Parameter(Mandatory)][int]$Port)
    $proc = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty OwningProcess
    if ($proc) {
        $name = (Get-Process -Id $proc).ProcessName
        Stop-Process -Id $proc -Force
        Write-Host "Killed $name (PID $proc) on port $Port" -ForegroundColor Green
    } else {
        Write-Host "Nothing running on port $Port" -ForegroundColor Gray
    }
}

function whats-on-port {
    <#
    .SYNOPSIS  Show what's using a port.
    .EXAMPLE   whats-on-port 3000
    #>
    param([Parameter(Mandatory)][int]$Port)
    $connections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    if ($connections) {
        $connections | ForEach-Object {
            $proc = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
            [PSCustomObject]@{ Port = $Port; PID = $_.OwningProcess; Process = $proc.ProcessName; State = $_.State }
        } | Format-Table -AutoSize
    } else {
        Write-Host "Port $Port is free" -ForegroundColor Gray
    }
}

function free-space {
    <#
    .SYNOPSIS  Show disk space on all drives.
    .EXAMPLE   free-space
    #>
    Get-PSDrive -PSProvider FileSystem |
        Select-Object Name,
            @{N='Used(GB)';E={[math]::Round($_.Used/1GB,1)}},
            @{N='Free(GB)';E={[math]::Round($_.Free/1GB,1)}},
            @{N='Total(GB)';E={[math]::Round(($_.Used+$_.Free)/1GB,1)}} |
        Format-Table -AutoSize
}

function whats-running {
    <#
    .SYNOPSIS  Show top processes by memory usage.
    .EXAMPLE   whats-running
    .EXAMPLE   whats-running -top 20
    #>
    param([int]$Top = 10)
    Get-Process | Sort-Object WorkingSet64 -Descending |
        Select-Object -First $Top Name, Id,
            @{N='Memory(MB)';E={[math]::Round($_.WorkingSet64/1MB,1)}},
            CPU |
        Format-Table -AutoSize
}

function env-check {
    <#
    .SYNOPSIS  Show an environment variable's value.
    .EXAMPLE   env-check "GITHUB_TOKEN"
    .EXAMPLE   env-check "PATH"
    #>
    param([Parameter(Mandatory)][string]$Name)
    $val = [Environment]::GetEnvironmentVariable($Name)
    if ($val) {
        Write-Host "$Name = $val" -ForegroundColor Green
    } else {
        Write-Host "$Name is not set" -ForegroundColor Yellow
    }
}

# ─── CLEANUP ─────────────────────────────────────────────────────

function nuke-node-modules {
    <#
    .SYNOPSIS  Delete node_modules from current folder (or all under a root).
    .EXAMPLE   nuke-node-modules
    .EXAMPLE   nuke-node-modules -all -in C:\DEV
    #>
    param(
        [switch]$All,
        [Alias("in")][string]$Root = "."
    )
    if ($All) {
        $dirs = Get-ChildItem $Root -Recurse -Directory -Filter "node_modules" -ErrorAction SilentlyContinue
        Write-Host "Found $($dirs.Count) node_modules folders" -ForegroundColor Yellow
        $size = ($dirs | Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        Write-Host "Total size: $([math]::Round($size/1GB,2)) GB" -ForegroundColor Yellow
        $confirm = Read-Host "Delete all? (y/n)"
        if ($confirm -eq 'y') {
            $dirs | Remove-Item -Recurse -Force
            Write-Host "Done." -ForegroundColor Green
        }
    } else {
        $nm = Join-Path $Root "node_modules"
        if (Test-Path $nm) {
            Remove-Item $nm -Recurse -Force
            Write-Host "Deleted node_modules" -ForegroundColor Green
        } else {
            Write-Host "No node_modules here" -ForegroundColor Gray
        }
    }
}

# ─── HELP ────────────────────────────────────────────────────────

function shllshockd {
    <#
    .SYNOPSIS  Show all SHLLSHOCKD commands.
    #>
    Write-Host ""
    Write-Host "  SHLLSHOCKD — Shell Shocked? We got you." -ForegroundColor Cyan
    Write-Host "  ─────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  FILES" -ForegroundColor Yellow
    Write-Host "    find-files `"name`"        Find files by name"
    Write-Host "    nuke-files `"name`"        Find and delete files"
    Write-Host "    count-files `"name`"       Count matching files"
    Write-Host "    show-big-files           Largest files in folder"
    Write-Host "    whats-here               List folder contents"
    Write-Host "    find-text `"string`"       Search inside files"
    Write-Host "    zip-this                 Zip folder (skip junk)"
    Write-Host ""
    Write-Host "  GIT" -ForegroundColor Yellow
    Write-Host "    what-changed             Uncommitted changes"
    Write-Host "    what-branch              Current branch"
    Write-Host "    undo-last-commit         Undo commit, keep files"
    Write-Host "    push-it `"message`"        Add + commit + push"
    Write-Host "    recent-commits           Last 10 commits"
    Write-Host "    stash-it `"note`"          Save work without commit"
    Write-Host "    unstash                  Restore stashed work"
    Write-Host ""
    Write-Host "  SYSTEM" -ForegroundColor Yellow
    Write-Host "    kill-port 3000           Kill process on port"
    Write-Host "    whats-on-port 3000       Show what's using port"
    Write-Host "    free-space               Disk space on all drives"
    Write-Host "    whats-running            Top processes by memory"
    Write-Host "    env-check `"VAR_NAME`"     Check env variable"
    Write-Host ""
    Write-Host "  CLEANUP" -ForegroundColor Yellow
    Write-Host "    nuke-node-modules        Delete node_modules"
    Write-Host "    nuke-node-modules -all   Delete ALL node_modules"
    Write-Host ""
    Write-Host "  Type 'shllshockd' anytime to see this menu." -ForegroundColor DarkGray
    Write-Host ""
}

# ─── LOAD PACKS ──────────────────────────────────────────────────

$PacksDir = Join-Path $PSScriptRoot "packs"
if (Test-Path $PacksDir) {
    Get-ChildItem $PacksDir -Filter "*.ps1" | ForEach-Object {
        . $_.FullName
    }
}

# ─── WELCOME ─────────────────────────────────────────────────────
Write-Host "SHLLSHOCKD loaded. Type 'shllshockd' for commands." -ForegroundColor DarkCyan
