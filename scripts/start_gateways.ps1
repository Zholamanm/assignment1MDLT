# Start three Hermes Telegram gateways (one window/process each).
# Run after tokens are in each profile .env

$ErrorActionPreference = "Stop"
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

if (-not (Get-Command hermes -ErrorAction SilentlyContinue)) {
    throw "hermes not on PATH"
}

$profiles = @("coordinator", "researcher", "coder")
$logDir = Join-Path $env:TEMP "mdl-assignment1-gateways"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

foreach ($name in $profiles) {
    $log = Join-Path $logDir "$name.log"
    Write-Host "==> Starting gateway for profile '$name' (log: $log)" -ForegroundColor Cyan
    Start-Process -FilePath "powershell" -ArgumentList @(
        "-NoExit",
        "-NoProfile",
        "-Command",
        "`$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User'); hermes -p $name gateway 2>&1 | Tee-Object -FilePath '$log'"
    )
    Start-Sleep -Seconds 2
}

Write-Host ""
Write-Host "Three gateway windows launched." -ForegroundColor Green
Write-Host "In Telegram group, @mention the coordinator with a real request."
Write-Host "Logs: $logDir"
