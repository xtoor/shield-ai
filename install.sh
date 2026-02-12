#!/bin/bash
# SHIELD.ai One-Line Installer ⚔️🛡️

echo "--- SHIELD.ai Rapid Deployment ---"

# 1. Check for Docker
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please visit https://docs.docker.com/get-docker/"
    exit 1
fi

# 2. Setup Project Directory
if [ ! -d "shield-ai" ]; then
    echo "[*] Creating SHIELD.ai workspace..."
    git clone https://github.com/xtoor/shield-ai.git
    cd shield-ai
else
    echo "[*] Updating existing SHIELD.ai workspace..."
    cd shield-ai
    git pull origin main
fi

# 3. Interactive Config (if .env missing)
if [ ! -f ".env" ]; then
    echo "[*] Generating .env configuration..."
    cp .env.example .env
    echo "Please enter your keys (leave blank to skip):"
    read -p "Tailscale Auth Key: " ts_key
    read -p "OpenAI API Key: " oai_key
    read -p "GitHub Token: " gh_token
    
    sed -i "s/TS_AUTHKEY=tskey-auth-xxxxxx/TS_AUTHKEY=$ts_key/" .env
    sed -i "s/OPENAI_API_KEY=sk-xxxxxx/OPENAI_API_KEY=$oai_key/" .env
    sed -i "s/GITHUB_TOKEN=ghp_xxxxxx/GITHUB_TOKEN=$gh_token/" .env
fi

# 4. Ignite
echo "[*] Initializing Docker Build..."
docker-compose up -d --build

echo "--- SUCCESS: SHIELD.ai is Online ---"
echo "IDE: http://localhost:18791"
echo "HUD: http://localhost:18792"
echo "Agent: http://localhost:18789"
