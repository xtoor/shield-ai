# SHIELD.ai Windows Installer ⚔️🛡️

Write-Host "--- SHIELD.ai Rapid Deployment (Windows) ---" -ForegroundColor Green

# 1. Check for Docker Client & Server
if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker CLI not found. Please visit https://docs.docker.com/get-docker/"
    return
}

Write-Host "[*] Checking Docker Engine pulse..." -ForegroundColor Gray
$dockerCheck = docker version --format '{{.Server.Version}}' 2>$null
if (!$dockerCheck) {
    Write-Host "[!] CRITICAL: Docker Client is available, but the Engine is not responding." -ForegroundColor Red
    Write-Host "Please ensure Docker Desktop is started and the whale icon is visible in your system tray." -ForegroundColor Yellow
    return
}
Write-Host "[+] Docker Engine is alive (v$dockerCheck)." -ForegroundColor Green

# 2. Setup Project Directory
if (!(Test-Path "shield-ai")) {
    Write-Host "[*] Creating SHIELD.ai workspace..."
    git clone https://github.com/xtoor/shield-ai.git
    Set-Location shield-ai
} else {
    Write-Host "[*] Updating existing SHIELD.ai workspace..." -ForegroundColor Gray
    Set-Location shield-ai
    git pull origin main
}

# 3. Interactive Config (if .env missing)
if (!(Test-Path ".env")) {
    Write-Host "[*] Generating .env configuration..." -ForegroundColor Cyan
    Copy-Item .env.example .env
    
    # --- Tailscale Configuration ---
    $ts_key = Read-Host "Tailscale Auth Key (leave blank to skip)"
    
    # --- OpenRouter Configuration (Mandatory Prompt) ---
    Write-Host "`n[!] OpenRouter API Key is REQUIRED for Henry to think." -ForegroundColor Yellow
    Write-Host "    If you don't have one, get a free key here: https://openrouter.ai/keys" -ForegroundColor Gray
    do {
        $or_key = Read-Host "OpenRouter API Key (sk-or-v1-...)"
        if ([string]::IsNullOrWhiteSpace($or_key)) {
            Write-Host "    [!] A key is required. Henry cannot function without a brain." -ForegroundColor Red
        }
    } until (![string]::IsNullOrWhiteSpace($or_key))

    # --- Optional APIs ---
    $gh_token = Read-Host "GitHub Token (optional, for repo access)"

    # --- Generate Secure Gateway Token ---
    Write-Host "`n[*] Forging a secure Gateway Token..." -ForegroundColor Gray
    $randomBytes = New-Object Byte[] 32
    (New-Object Security.Cryptography.RNGCryptoServiceProvider).GetBytes($randomBytes)
    $oc_token = [System.BitConverter]::ToString($randomBytes).Replace("-", "").ToLower()

    # --- Inject into .env ---
    $envContent = Get-Content .env
    
    # Handle Tailscale
    if ([string]::IsNullOrWhiteSpace($ts_key)) {
        $envContent = $envContent -replace "TS_AUTHKEY=tskey-auth-xxxxxx", "#TS_AUTHKEY="
    } else {
        $envContent = $envContent -replace "TS_AUTHKEY=tskey-auth-xxxxxx", "TS_AUTHKEY=$ts_key"
    }

    # Handle OpenRouter (Use placeholder if not found, or append)
    if ($envContent -match "OPENROUTER_API_KEY=") {
        $envContent = $envContent -replace "OPENROUTER_API_KEY=.*", "OPENROUTER_API_KEY=$or_key"
    } else {
        $envContent += "`nOPENROUTER_API_KEY=$or_key"
    }

    # Handle GitHub
    if ([string]::IsNullOrWhiteSpace($gh_token)) {
        $envContent = $envContent -replace "GITHUB_TOKEN=ghp_xxxxxx", "#GITHUB_TOKEN="
    } else {
        $envContent = $envContent -replace "GITHUB_TOKEN=ghp_xxxxxx", "GITHUB_TOKEN=$gh_token"
    }
    
    # Handle Gateway Token
    if ($envContent -match "OPENCLAW_GATEWAY_TOKEN=") {
        $envContent = $envContent -replace "OPENCLAW_GATEWAY_TOKEN=.*", "OPENCLAW_GATEWAY_TOKEN=$oc_token"
    } else {
        $envContent += "`nOPENCLAW_GATEWAY_TOKEN=$oc_token"
    }

    $envContent | Set-Content .env
    Write-Host "[+] Configuration locked in .env" -ForegroundColor Green
}

# 4. Ignite
Write-Host "[*] Initializing Docker Build..." -ForegroundColor Cyan
docker-compose up -d --build

Write-Host "--- SUCCESS: SHIELD.ai is Online ---" -ForegroundColor Green
Write-Host "IDE: http://localhost:18791"
Write-Host "HUD: http://localhost:18792"
Write-Host "Agent: http://localhost:18789"
Write-Host "ChatDev: http://localhost:5173 (Requires Manual Start)"
