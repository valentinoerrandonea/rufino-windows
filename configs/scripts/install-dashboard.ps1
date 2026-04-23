# Installs the Rufino dashboard as a Scheduled Task on Windows.
#
# Usage:
#   .\install-dashboard.ps1 -DashboardDir <path> -VaultPath <path> [-Port 3737] [-TaskName "RufinoDashboard"]
#
# Requires: Node.js 20+ on PATH, PowerShell 5+, permission to create user Scheduled Tasks.

param(
    [Parameter(Mandatory = $true)]
    [string]$DashboardDir,

    [Parameter(Mandatory = $true)]
    [string]$VaultPath,

    [int]$Port = 3737,

    [string]$TaskName = "RufinoDashboard"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $DashboardDir)) {
    Write-Error "Dashboard directory not found: $DashboardDir"
    exit 1
}
if (-not (Test-Path $VaultPath)) {
    Write-Error "Vault path not found: $VaultPath"
    exit 1
}

$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
    Write-Error "Node.js not found on PATH. Install Node.js 20+ first (https://nodejs.org)."
    exit 1
}

$versionRaw = (& node -v).TrimStart('v')
$majorVersion = [int]($versionRaw.Split('.')[0])
if ($majorVersion -lt 20) {
    Write-Error "Node.js 20+ required. Found: v$versionRaw"
    exit 1
}

Write-Host "==> Installing dashboard dependencies..."
Push-Location $DashboardDir
try {
    npm install --silent
    Write-Host "==> Building production bundle..."
    npm run build
}
finally {
    Pop-Location
}

Write-Host "==> Registering Scheduled Task: $TaskName"

# Remove existing task with the same name (idempotent reinstall)
Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue | Out-Null

$runner = Join-Path $DashboardDir "scripts\run-daemon.ps1"
if (-not (Test-Path $runner)) {
    Write-Error "Runner script not found: $runner"
    exit 1
}

$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$runner`"" `
    -WorkingDirectory $DashboardDir

$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RestartCount 9999 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -ExecutionTimeLimit (New-TimeSpan -Days 0)

Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Settings $settings `
    -Description "Rufino dashboard daemon on http://localhost:$Port" | Out-Null

# Persist env vars at user scope so the task inherits them
[Environment]::SetEnvironmentVariable("RUFINO_VAULT_PATH", $VaultPath, "User")
[Environment]::SetEnvironmentVariable("RUFINO_DASHBOARD_PORT", "$Port", "User")

Write-Host "==> Starting task..."
Start-ScheduledTask -TaskName $TaskName

Start-Sleep -Seconds 3

Write-Host ""
Write-Host "==> Verifying daemon is up..."
for ($i = 0; $i -lt 5; $i++) {
    try {
        Invoke-WebRequest -UseBasicParsing -Uri "http://localhost:$Port" -TimeoutSec 2 | Out-Null
        Write-Host "✓ Dashboard is live at http://localhost:$Port"
        exit 0
    }
    catch {
        Start-Sleep -Seconds 2
    }
}

Write-Warning "Dashboard did not respond on port $Port within 10s."
Write-Warning "Check logs: $env:USERPROFILE\rufino-dashboard.log"
exit 1
