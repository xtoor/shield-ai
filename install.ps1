# SHIELD.ai Windows Installer ⚔️🛡️

Write-Host "--- SHIELD.ai Rapid Deployment (Windows) ---" -ForegroundColor Green

# 1. Check for Docker Client & Server
if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker CLI not found. Please visit https://docs.docker.com/get-docker/"
    exit
}

Write-Host "[*] Checking Docker Engine pulse..." -ForegroundColor Gray
$dockerCheck = docker version --format '{{.Server.Version}}' 2>$null
if (!$dockerCheck) {
    Write-Host "[!] CRITICAL: Docker Client is available, but the Engine is not responding." -ForegroundColor Red
    Write-Host "Please ensure Docker Desktop is started and the whale icon is visible in your system tray." -ForegroundColor Yellow
    exit
}
Write-Host "[+] Docker Engine is alive (v$dockerCheck)." -ForegroundColor Green

# 2. Setup Project Directory
if (!(Test-Path "shield-ai")) {
    Write-Host "[*] Creating SHIELD.ai workspace..."
    git clone https://github.com/xtoor/shield-ai.git
    Set-Location shield-ai
} else {
    Set-Location shield-ai
}

# 3. Interactive Config (if .env missing)
if (!(Test-Path ".env")) {
    Write-Host "[*] Generating .env configuration..."
    Copy-Item .env.example .env
    
    $ts_key = Read-Host "Tailscale Auth Key (leave blank to skip)"
    $oai_key = Read-Host "OpenAI API Key"
    $gh_token = Read-Host "GitHub Token"

    (Get-Content .env) -replace "TS_AUTHKEY=tskey-auth-xxxxxx", "TS_AUTHKEY=$ts_key" `
                  -replace "OPENAI_API_KEY=sk-xxxxxx", "OPENAI_API_KEY=$oai_key" `
                  -replace "GITHUB_TOKEN=ghp_xxxxxx", "GITHUB_TOKEN=$gh_token" | Set-Content .env
}

# 4. Ignite
Write-Host "[*] Initializing Docker Build..." -ForegroundColor Cyan
docker-compose up -d --build

Write-Host "--- SUCCESS: SHIELD.ai is Online ---" -ForegroundColor Green
Write-Host "IDE: http://localhost:18791"
Write-Host "HUD: http://localhost:18792"
Write-Host "Agent: http://localhost:18789"
