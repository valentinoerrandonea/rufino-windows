# Dashboard daemon wrapper for Windows. Runs via Task Scheduler / startup entry.
# Reads RUFINO_VAULT_PATH from environment; refuses to start if unset.

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$DashboardDir = Split-Path -Parent $Root

Set-Location $DashboardDir

$env:NODE_ENV = "production"
if (-not $env:RUFINO_DASHBOARD_PORT) {
    $env:PORT = "3737"
} else {
    $env:PORT = $env:RUFINO_DASHBOARD_PORT
}

if (-not $env:RUFINO_VAULT_PATH) {
    Write-Error "RUFINO_VAULT_PATH is not set"
    exit 1
}

$LogFile = Join-Path $env:USERPROFILE "rufino-dashboard.log"
"=== Rufino dashboard starting: $(Get-Date) ===" | Out-File -Append -FilePath $LogFile

npm run start *>> $LogFile
