#!/bin/bash
# SHIELD.ai Secure Token Generator ⚔️🛡️

echo "--- SHIELD.ai Armory: Security Token Generator ---"

# 1. Generate a high-entropy hex token (32 bytes / 64 chars)
NEW_TOKEN=$(openssl rand -hex 32 2>/dev/null || node -e 'console.log(require("crypto").randomBytes(32).toString("hex"))' 2>/dev/null || LC_ALL=C tr -dc 'a-f0-9' < /dev/urandom | head -c 64)

if [ -z "$NEW_TOKEN" ]; then
    echo "Error: Could not generate random token. Please ensure OpenSSL or Node.js is installed."
    exit 1
fi

echo "[*] New secure token generated: $NEW_TOKEN"

# 2. Update .env if it exists
if [ -f ".env" ]; then
    echo "[*] Injecting token into .env..."
    if grep -q "OPENCLAW_GATEWAY_TOKEN=" .env; then
        sed -i.bak "s/OPENCLAW_GATEWAY_TOKEN=.*/OPENCLAW_GATEWAY_TOKEN=$NEW_TOKEN/" .env
    else
        echo "OPENCLAW_GATEWAY_TOKEN=$NEW_TOKEN" >> .env
    fi
    rm .env.bak 2>/dev/null
    echo "[+] .env updated."
else
    echo "[!] .env file not found. Skipping auto-injection."
fi

echo ""
echo "--- ACTION REQUIRED ---"
echo "If the container is already running, you must rebuild or update your config:"
echo "1. Update your openclaw.json manually if you are using a custom config."
echo "2. Run 'docker-compose up -d --build' to apply changes."
echo "-----------------------"
