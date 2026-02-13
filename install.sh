#!/bin/bash
# SHIELD.ai One-Line Installer ⚔️🛡️

echo "--- SHIELD.ai Rapid Deployment (Linux/macOS) ---"

# 1. Check for Docker Client
if ! command -v docker &> /dev/null; then
    echo "Error: Docker CLI not found. Please visit https://docs.docker.com/get-docker/"
    exit 1
fi

# 1.1 Check for Docker Engine
echo "[*] Checking Docker Engine pulse..."
if ! docker info &> /dev/null; then
    echo "Error: Docker Engine is not responding. Please make sure Docker Desktop is running."
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
    echo -e "\033[0;36m[*] Generating .env configuration...\033[0m"
    cp .env.example .env
    
    # --- Tailscale Configuration ---
    read -p "Tailscale Auth Key (leave blank to skip): " ts_key
    
    # --- OpenRouter Configuration (Mandatory Prompt) ---
    echo -e "\n\033[0;33m[!] OpenRouter API Key is REQUIRED for Henry to think.\033[0m"
    echo -e "\033[0;90m    If you don't have one, get a free key here: https://openrouter.ai/keys\033[0m"
    while true; do
        read -p "OpenRouter API Key (sk-or-v1-...): " or_key
        if [ -n "$or_key" ]; then
            break
        else
            echo -e "    \033[0;31m[!] A key is required. Henry cannot function without a brain.\033[0m"
        fi
    done

    # --- Optional APIs ---
    read -p "GitHub Token (optional, for repo access): " gh_token
    
    # --- Generate Secure Gateway Token ---
    echo -e "\n\033[0;90m[*] Forging a secure Gateway Token...\033[0m"
    oc_token=$(openssl rand -hex 32 2>/dev/null || LC_ALL=C tr -dc 'a-f0-9' < /dev/urandom | head -c 64)

    # --- Inject into .env (Using backup extension for cross-platform sed) ---
    
    # Handle Tailscale
    if [ -z "$ts_key" ]; then
        sed -i.bak "s/TS_AUTHKEY=tskey-auth-xxxxxx/#TS_AUTHKEY=/" .env
    else
        sed -i.bak "s/TS_AUTHKEY=tskey-auth-xxxxxx/TS_AUTHKEY=$ts_key/" .env
    fi

    # Handle OpenRouter (Append if not present in example, or replace placeholder)
    if grep -q "OPENROUTER_API_KEY=" .env; then
        sed -i.bak "s/OPENROUTER_API_KEY=.*/OPENROUTER_API_KEY=$or_key/" .env
    else
        echo "OPENROUTER_API_KEY=$or_key" >> .env
    fi

    # Handle GitHub
    if [ -z "$gh_token" ]; then
        sed -i.bak "s/GITHUB_TOKEN=ghp_xxxxxx/#GITHUB_TOKEN=/" .env
    else
        sed -i.bak "s/GITHUB_TOKEN=ghp_xxxxxx/GITHUB_TOKEN=$gh_token/" .env
    fi
    
    # Handle Gateway Token
    if grep -q "OPENCLAW_GATEWAY_TOKEN=" .env; then
        sed -i.bak "s/OPENCLAW_GATEWAY_TOKEN=.*/OPENCLAW_GATEWAY_TOKEN=$oc_token/" .env
    else
        echo "OPENCLAW_GATEWAY_TOKEN=$oc_token" >> .env
    fi

    rm .env.bak
    echo -e "\033[0;32m[+] Configuration locked in .env\033[0m"
fi

# 4. Ignite
echo "[*] Initializing Docker Build..."
docker-compose up -d --build

echo "--- SUCCESS: SHIELD.ai is Online ---"
echo "IDE: http://localhost:18791"
echo "HUD: http://localhost:18792"
echo "Agent: http://localhost:18789"
