# Create Hermes profiles and deploy Assignment 1 agent configs.
# Run:  .\setup_profiles.ps1
# Does NOT write Telegram tokens (you paste those later).

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$AgentsRoot = Join-Path $RepoRoot "agents"
$HermesRoot = if (Test-Path (Join-Path $env:LOCALAPPDATA "hermes\config.yaml")) {
    Join-Path $env:LOCALAPPDATA "hermes"
} else {
    Join-Path $env:USERPROFILE ".hermes"
}

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

if (-not (Get-Command hermes -ErrorAction SilentlyContinue)) {
    throw "hermes not on PATH. Install Hermes first."
}

$profiles = @(
    @{ Name = "coordinator"; Desc = "Orchestrates MDL study requests; @mentions researcher and coder; posts Final answer" },
    @{ Name = "researcher";  Desc = "Searches and summarises papers/docs for the MDL study team" },
    @{ Name = "coder";       Desc = "Writes and runs small PyTorch teaching examples for the MDL study team" }
)

Write-Host "==> Hermes root: $HermesRoot" -ForegroundColor Cyan
Write-Host "==> Repo: $RepoRoot"

$existing = hermes profile list 2>&1 | Out-String

foreach ($p in $profiles) {
    $name = $p.Name
    if ($existing -match "(?m)^\s*$name\b" -or $existing -match "\b$name\b") {
        Write-Host "==> Profile '$name' already exists (skip create)"
    } else {
        Write-Host "==> Creating profile '$name'" -ForegroundColor Yellow
        # Clone config/.env structure from default WITHOUT messaging channels
        hermes profile create $name --clone --description $p.Desc
    }

    $profileHome = Join-Path $HermesRoot "profiles\$name"
    New-Item -ItemType Directory -Force -Path $profileHome | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $profileHome "memories") | Out-Null

    $src = Join-Path $AgentsRoot $name
    Copy-Item -Force (Join-Path $src "SOUL.md") (Join-Path $profileHome "SOUL.md")
    Copy-Item -Force (Join-Path $src "AGENTS.md") (Join-Path $profileHome "AGENTS.md")
    Write-Host "    deployed SOUL.md + AGENTS.md -> $profileHome"

    # Apply model / memory / telegram.require_mention via hermes -p
    $cfg = Join-Path $src "config.yaml"
    $yaml = Get-Content $cfg -Raw
    if ($yaml -match 'default:\s*(\S+)') {
        $model = $Matches[1]
        hermes -p $name config set model.provider openrouter | Out-Null
        hermes -p $name config set model.default $model | Out-Null
        Write-Host "    model.default = $model"
    }
    hermes -p $name config set memory.memory_enabled true | Out-Null
    hermes -p $name config set memory.user_profile_enabled true | Out-Null
    hermes -p $name config set telegram.require_mention true | Out-Null

    # Ensure .env has placeholders for Telegram (do not overwrite existing real values)
    $envPath = Join-Path $profileHome ".env"
    if (-not (Test-Path $envPath)) {
        Copy-Item (Join-Path $RepoRoot ".env.example") $envPath
        Write-Host "    created $envPath from .env.example" -ForegroundColor Yellow
    } else {
        $text = Get-Content $envPath -Raw
        foreach ($key in @("OPENROUTER_API_KEY", "TELEGRAM_BOT_TOKEN", "TELEGRAM_ALLOWED_USERS")) {
            if ($text -notmatch "(?m)^$key=") {
                Add-Content $envPath "`n$key=REPLACE_ME"
            }
        }
        Write-Host "    .env present (left secrets unchanged)"
    }
}

Write-Host ""
Write-Host "DONE. Next:" -ForegroundColor Green
Write-Host "  1. Paste OPENROUTER_API_KEY + each TELEGRAM_BOT_TOKEN into the three profile .env files"
Write-Host "  2. .\start_gateways.ps1"
Write-Host "  3. Add bots to a Telegram group (Group Privacy OFF), then try examples\sample_request.md"
