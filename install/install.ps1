# ═══════════════════════════════════════════════════════════════
# SHLLSHOCKD Installer
# Run: irm https://raw.githubusercontent.com/Agyeman-Enterprises/shllshockd/main/install/install.ps1 | iex
# ═══════════════════════════════════════════════════════════════

$InstallDir = "$env:USERPROFILE\.shllshockd"
$RepoUrl = "https://github.com/Agyeman-Enterprises/shllshockd/archive/refs/heads/main.zip"
$TempZip = "$env:TEMP\shllshockd.zip"
$TempExtract = "$env:TEMP\shllshockd-main"

Write-Host ""
Write-Host "  Installing SHLLSHOCKD..." -ForegroundColor Cyan
Write-Host ""

# Download
Invoke-WebRequest -Uri $RepoUrl -OutFile $TempZip -UseBasicParsing
Expand-Archive -Path $TempZip -DestinationPath $env:TEMP -Force

# Install
if (Test-Path $InstallDir) { Remove-Item $InstallDir -Recurse -Force }
Move-Item "$TempExtract" $InstallDir

# Clean up
Remove-Item $TempZip -Force -ErrorAction SilentlyContinue

# Add to PowerShell profile
$ProfileDir = Split-Path $PROFILE
if (!(Test-Path $ProfileDir)) { New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null }
if (!(Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force | Out-Null }

$LoadLine = '. "$env:USERPROFILE\.shllshockd\core\shllshockd.ps1"'
$ProfileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue

if ($ProfileContent -notmatch 'shllshockd') {
    Add-Content $PROFILE "`n# SHLLSHOCKD — Shell Shocked? We got you.`n$LoadLine"
    Write-Host "  Added to PowerShell profile." -ForegroundColor Green
} else {
    Write-Host "  Already in profile." -ForegroundColor Gray
}

Write-Host ""
Write-Host "  SHLLSHOCKD installed to: $InstallDir" -ForegroundColor Green
Write-Host "  Restart PowerShell or run:" -ForegroundColor Gray
Write-Host "    $LoadLine" -ForegroundColor White
Write-Host ""
Write-Host "  Then type 'shllshockd' to see all commands." -ForegroundColor Cyan
Write-Host ""
