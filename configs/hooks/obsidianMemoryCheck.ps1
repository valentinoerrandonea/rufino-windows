$input_data = [Console]::In.ReadToEnd()
$parsed = $input_data | ConvertFrom-Json
$sessionId = $parsed.session_id
$flagFile = Join-Path $env:TEMP "claude-memory-check-$sessionId"

if (Test-Path $flagFile) {
    Remove-Item $flagFile -Force
    exit 0
}

New-Item -ItemType File -Path $flagFile -Force | Out-Null
[Console]::Error.WriteLine("OBSIDIAN MEMORY CHECK: revisa si hay algo para guardar en el vault antes de cerrar.")
exit 2
