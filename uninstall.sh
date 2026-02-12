#!/bin/bash
# SHIELD.ai Uninstaller ⚔️🛡️

echo "--- SHIELD.ai Decommissioning Engine ---"

# 1. Stop and remove containers
if [ -f "docker-compose.yml" ]; then
    echo "[*] Stopping and removing SHIELD.ai containers..."
    docker-compose down --rmi all --volumes --remove-orphans
else
    echo "[!] docker-compose.yml not found. Manual cleanup required."
fi

# 2. Final cleanup
echo "[*] Purging temporary files..."
cd ..
# Ask for confirmation before deleting the directory
read -p "Do you want to permanently delete the 'shield-ai' directory? (y/n): " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
    rm -rf shield-ai
    echo "[*] SHIELD.ai directory purged."
fi

echo "--- UNINSTALL COMPLETE: SHIELD.ai has been decommissioned ---"
