# Stop Hermes gateway processes started for Assignment 1 profiles.
# This matches processes whose command line contains "hermes" and a profile gateway.

$ErrorActionPreference = "SilentlyContinue"
$killed = 0
Get-CimInstance Win32_Process | Where-Object {
    $_.CommandLine -and
    ($_.CommandLine -match 'hermes.*gateway' -or $_.CommandLine -match 'hermes\.exe.*gateway')
} | ForEach-Object {
    Write-Host "Stopping PID $($_.ProcessId): $($_.CommandLine.Substring(0, [Math]::Min(120, $_.CommandLine.Length)))..."
    Stop-Process -Id $_.ProcessId -Force
    $killed++
}
Write-Host "Stopped $killed process(es)."
