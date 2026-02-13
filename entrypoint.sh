#!/bin/bash
# SHIELD.ai Initialization Engine (Hardened Build)

echo "--- SHIELD.ai Boot Sequence Initiated ---"

# 1. Start Antivirus Daemon
echo "[*] Starting ClamAV Defense..."
# Ensure permissions are correct just in case
sudo mkdir -p /var/run/clamav
sudo chown -R clamav:clamav /var/run/clamav
sudo chmod 775 /var/run/clamav
sudo clamd &

# 2. Tailscale Integration (Optional)
if [ -n "$TS_AUTHKEY" ]; then
    echo "[*] Initializing Tailscale Stealth Tunnel..."
    sudo tailscaled --tun=userspace-networking &
    sleep 2
    sudo tailscale up --authkey=$TS_AUTHKEY --hostname=shield-ai --accept-dns=false
fi

# 2.1 Cloudflare Warp (Optional)
if [ -n "$WARP_LICENSE_KEY" ]; then
    echo "[*] Initializing Cloudflare Warp Shield..."
    sudo warp-svc &
    sleep 2
    warp-cli --accept-tos registration register "$WARP_LICENSE_KEY"
    warp-cli --accept-tos mode proxy
    warp-cli --accept-tos connect
fi

# 3. Start code-server (IDE)
echo "[*] Launching Collaborative Forge (IDE)..."
code-server --bind-addr 0.0.0.0:18791 --auth none &

# 3. Start noVNC (Visual HUD) with Resurrection Capability
start_hud() {
    echo "[*] Establishing Visual HUD (noVNC)..."
    Xvfb :99 -screen 0 1920x1080x24 -ac +extension GLX +extension RENDER +extension RANDR > /tmp/xvfb.log 2>&1 &
    export DISPLAY=:99
    export SHELL=/usr/bin/zsh
    export PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/home/agent/.npm-global/bin
    sleep 2
    fluxbox > /tmp/fluxbox.log 2>&1 &
    sleep 1
    x11vnc -display :99 -forever -nopw -listen 0.0.0.0 -xkb -shared > /tmp/x11vnc.log 2>&1 &
    
    # Launch noVNC Proxy if not running
    if ! pgrep -f "novnc_proxy" > /dev/null; then
        if [ -n "$NOVNC_LAUNCHER" ]; then
            $NOVNC_LAUNCHER --vnc localhost:5900 --listen 18792 > /tmp/novnc.log 2>&1 &
        else
             /usr/share/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 18792 > /tmp/novnc.log 2>&1 &
        fi
    fi
}

start_hud

# Monitor Loop (Background Process)
(
    while true; do
        sleep 60
        if ! pgrep -x "Xvfb" > /dev/null; then
            echo "[!] CRITICAL: Visual HUD (Xvfb) died. Initiating Resurrection..."
            start_hud
        fi
    done
) &

# 4. Auto-Clone The Brain (ChatDev-Penetrator)
if [ ! -d "/home/agent/workspace/ChatDev-Penetrator" ]; then
    echo "[*] Cloning ChatDev-Penetrator Logic..."
    git clone https://github.com/xtoor/ChatDev-Penetrator.git /home/agent/workspace/ChatDev-Penetrator
else
    echo "[*] ChatDev-Penetrator already exists. Pulling latest updates..."
    cd /home/agent/workspace/ChatDev-Penetrator && git pull
fi

# 5. Launch OpenClaw
echo "[*] Waking Henry (OpenClaw Agent)..."

# Ensure agent ownership of all relevant directories
sudo chown -R agent:agent /home/agent /tmp/openclaw

# Create internal storage to bypass Windows mount restrictions (colons in filenames)
mkdir -p /home/agent/internal_sessions
mkdir -p /home/agent/internal_workspace

# Setup a valid, doctor-approved configuration
GATEWAY_TOKEN="${OPENCLAW_GATEWAY_TOKEN:-shield-ai-default-token-12345}"

# We write a clean config from scratch to ensure no "illegal" keys are present.
cat <<EOF > /home/agent/.openclaw/openclaw.json
{
  "gateway": {
    "mode": "local",
    "port": 18789,
    "bind": "lan",
    "auth": {
      "mode": "token",
      "token": "$GATEWAY_TOKEN",
      "allowTailscale": true
    },
    "controlUi": {
      "enabled": true,
      "allowInsecureAuth": true
    },
    "trustedProxies": [
      "127.0.0.1",
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
      "100.64.0.0/10"
    ]
  },
  "models": {
    "providers": {
      "openrouter": {
        "baseUrl": "https://openrouter.ai/api/v1",
        "apiKey": "\${OPENROUTER_API_KEY}",
        "api": "openai-completions",
        "models": []
      }
    }
  },
  "agents": {
    "defaults": {
      "workspace": "/home/agent/internal_workspace",
      "model": {
        "primary": "openrouter/z-ai/glm-4.5-air:free",
        "fallbacks": [
          "openrouter/tngtech/tng-r1t-chimera:free",
          "openrouter/stepfun/step-3.5-flash:free",
          "openrouter/qwen/qwen3-next-80b-a3b-instruct:free",
          "openrouter/openai/gpt-oss-120b:free"
        ]
      }
    }
  },
  "session": {
    "store": "/home/agent/internal_sessions/sessions.json"
  }
}
EOF

# Final environment hardening
export OPENCLAW_GATEWAY_TOKEN="$GATEWAY_TOKEN"
export SHELL=/usr/bin/zsh

# Start the Gateway from the native home
# Force bind to 0.0.0.0
# Run in background with logging
# Explicitly set browser relay port to 18793 via ENV (since CLI flag was rejected)
export BROWSER_RELAY_PORT=18793
cd /home/agent

# Ensure environment variables are loaded for the background process
# We wrap the command in a shell block to persist env vars
/bin/bash -c "export OPENROUTER_API_KEY=\"$OPENROUTER_API_KEY\"; /home/agent/.npm-global/bin/openclaw gateway run --port 18789 --bind 0.0.0.0 --allow-unconfigured --token \"$GATEWAY_TOKEN\"" > /tmp/openclaw-gateway.log 2>&1 &

echo "[*] Henry is now listening in the background (Port 18789)."

# Final Guard: Keep container alive for log inspection if primary process exits
echo "[!] Shield Active. Maintaining tunnel for diagnostics..."
tail -f /dev/null /tmp/openclaw-gateway.log
