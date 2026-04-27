# ═══════════════════════════════════════════════════════════════
# SHLLSHOCKD — Pack Template
# Copy this file, rename it, and add your commands.
# Save to the packs/ folder and it auto-loads.
# ═══════════════════════════════════════════════════════════════

# ─── YOUR COMMANDS ───────────────────────────────────────────────

function example-command {
    <#
    .SYNOPSIS  Describe what this does in one line.
    .EXAMPLE   example-command "hello"
    .EXAMPLE   example-command "hello" -loud
    #>
    param(
        [Parameter(Mandatory)][string]$Input,
        [switch]$Loud
    )
    if ($Loud) {
        Write-Host $Input.ToUpper() -ForegroundColor Yellow
    } else {
        Write-Host $Input -ForegroundColor Green
    }
}

# ─── HELP ────────────────────────────────────────────────────────

function template-help {
    Write-Host ""
    Write-Host "  SHLLSHOCKD — Template Pack" -ForegroundColor Cyan
    Write-Host "  ─────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "    example-command `"text`"   Does the thing"
    Write-Host ""
}

Write-Host "  + Template pack loaded. Type 'template-help' for commands." -ForegroundColor DarkGray
