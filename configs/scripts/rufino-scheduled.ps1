$ErrorActionPreference = "Stop"

$logFile = Join-Path $env:USERPROFILE "rufino-cron.log"
$promptFile = Join-Path $env:USERPROFILE ".claude\prompts\rufino-daily.md"

# Find claude CLI
$claudePaths = @(
    (Join-Path $env:USERPROFILE ".local\bin\claude.exe"),
    (Join-Path $env:USERPROFILE ".local\bin\claude"),
    (Join-Path $env:LOCALAPPDATA "Programs\claude\claude.exe"),
    "claude"
)

$claude = $null
foreach ($path in $claudePaths) {
    if (Get-Command $path -ErrorAction SilentlyContinue) {
        $claude = $path
        break
    }
}

if (-not $claude) {
    Add-Content $logFile "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ERROR: Claude CLI not found"
    exit 1
}

Add-Content $logFile "=== Rufino run: $(Get-Date) ==="

if (-not (Test-Path $promptFile)) {
    Add-Content $logFile "ERROR: Prompt file not found at $promptFile"
    exit 1
}

$prompt = Get-Content $promptFile -Raw

& $claude -p $prompt --allowedTools "Read,Write,Edit,Glob,Grep,Bash" --dangerously-skip-permissions --model sonnet 2>&1 | Add-Content $logFile

Add-Content $logFile "=== Rufino done: $(Get-Date) ==="
