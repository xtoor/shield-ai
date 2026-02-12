# SHIELD.ai Windows Uninstaller ⚔️🛡️

Write-Host "--- SHIELD.ai Decommissioning Engine (Windows) ---" -ForegroundColor Yellow

# 1. Stop and remove containers
if (Test-Path "docker-compose.yml") {
    Write-Host "[*] Stopping and removing SHIELD.ai containers..." -ForegroundColor Cyan
    docker-compose down --rmi all --volumes --remove-orphans
} else {
    Write-Warning "docker-compose.yml not found. Manual cleanup required."
}

# 2. Final cleanup
$confirm = Read-Host "Do you want to permanently delete the 'shield-ai' directory? (y/n)"
if ($confirm -eq "y" -or $confirm -eq "yes") {
    Write-Host "[*] Purging SHIELD.ai directory..." -ForegroundColor Red
    Set-Location ..
    Remove-Item -Path "shield-ai" -Recurse -Force
    Write-Host "[*] SHIELD.ai directory purged."
}

Write-Host "--- UNINSTALL COMPLETE: SHIELD.ai has been decommissioned ---" -ForegroundColor Green
