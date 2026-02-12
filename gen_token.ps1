# SHIELD.ai Secure Token Generator ⚔️🛡️

Write-Host "--- SHIELD.ai Armory: Security Token Generator ---" -ForegroundColor Cyan

# 1. Generate a high-entropy hex token (32 bytes / 64 chars)
$randomBytes = New-Object Byte[] 32
(New-Object Security.Cryptography.RNGCryptoServiceProvider).GetBytes($randomBytes)
$newToken = [System.BitConverter]::ToString($randomBytes).Replace("-", "").ToLower()

if (-not $newToken) {
    Write-Host "Error: Could not generate random token." -ForegroundColor Red
    exit 1
}

Write-Host "[*] New secure token generated: $newToken"

# 2. Update .env if it exists
if (Test-Path ".env") {
    Write-Host "[*] Injecting token into .env..."
    $envContent = Get-Content ".env"
    if ($envContent -match "OPENCLAW_GATEWAY_TOKEN=") {
        $envContent = $envContent -replace "OPENCLAW_GATEWAY_TOKEN=.*", "OPENCLAW_GATEWAY_TOKEN=$newToken"
    } else {
        $envContent += "OPENCLAW_GATEWAY_TOKEN=$newToken"
    }
    $envContent | Set-Content ".env"
    Write-Host "[+] .env updated." -ForegroundColor Green
} else {
    Write-Host "[!] .env file not found. Skipping auto-injection." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "--- ACTION REQUIRED ---" -ForegroundColor Red
Write-Host "If the container is already running, you must rebuild or update your config:"
Write-Host "1. Update your openclaw.json manually if you are using a custom config."
Write-Host "2. Run 'docker-compose up -d --build' to apply changes."
Write-Host "-----------------------"
