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

# 3. Start noVNC (Visual HUD)
echo "[*] Establishing Visual HUD (noVNC)..."
Xvfb :99 -screen 0 1920x1080x24 -ac +extension GLX +extension RENDER +extension RANDR &
export DISPLAY=:99
export SHELL=/usr/bin/zsh
export PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/home/agent/.npm-global/bin
sleep 5
fluxbox &
sleep 2
x11vnc -display :99 -forever -nopw -listen 0.0.0.0 -xkb -shared &
sleep 2

# Find noVNC proxy dynamically
echo "[*] Scanning for noVNC launcher..."
NOVNC_LAUNCHER=$(find /usr -name "novnc_proxy" | head -n 1)
if [ -z "$NOVNC_LAUNCHER" ]; then
    NOVNC_LAUNCHER=$(find /usr -name "launch.sh" | grep "novnc" | head -n 1)
fi

if [ -n "$NOVNC_LAUNCHER" ]; then
    echo "[*] Launching noVNC via: $NOVNC_LAUNCHER"
    $NOVNC_LAUNCHER --vnc localhost:5900 --listen 18792 &
    echo "[*] Visual HUD optimized link: http://localhost:18792/"
else
    echo "[!] Warning: noVNC launcher not found. Checking alternate paths..."
    # Try common locations if find failed
    if [ -f "/usr/bin/novnc_proxy" ]; then
        /usr/bin/novnc_proxy --vnc localhost:5900 --listen 18792 &
    elif [ -f "/usr/share/novnc/utils/novnc_proxy" ]; then
        /usr/share/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 18792 &
    else
        echo "[!] Error: noVNC bridge could not be established."
    fi
    echo "[*] Visual HUD optimized link: http://localhost:18792/"
fi

# 5. Launch OpenClaw
echo "[*] Waking Henry (OpenClaw Agent)..."

# Ensure agent ownership
sudo chown -R agent:agent /home/agent

# Setup internal storage for sessions/workspace to bypass Windows host mount restrictions (colons)
mkdir -p /home/agent/internal_sessions
mkdir -p /home/agent/internal_workspace

# Create symlinks in the config directory to redirect storage to container-native filesystem
# This keeps the config file on the host but moves the "troublesome" folders inside.
if [ -d "/home/agent/.openclaw" ]; then
    [ -L "/home/agent/.openclaw/sessions" ] || (rm -rf /home/agent/.openclaw/sessions && ln -s /home/agent/internal_sessions /home/agent/.openclaw/sessions)
    [ -L "/home/agent/.openclaw/workspace" ] || (rm -rf /home/agent/.openclaw/workspace && ln -s /home/agent/internal_workspace /home/agent/.openclaw/workspace)
fi

# Use provided token or default
GATEWAY_TOKEN="${OPENCLAW_GATEWAY_TOKEN:-shield-ai-default-token-12345}"

if [ ! -f "/home/agent/.openclaw/openclaw.json" ]; then
    echo "[*] Initializing default OpenClaw configuration..."
    echo "{\"gateway\":{\"mode\":\"local\",\"port\":18789,\"bind\":\"0.0.0.0\",\"controlUi\":{\"enabled\":true,\"allowInsecureAuth\":true},\"auth\":{\"mode\":\"token\",\"token\":\"$GATEWAY_TOKEN\"}}}" > /home/agent/.openclaw/openclaw.json
else
    echo "[*] Existing configuration detected. Hardening for container environment..."
    if command -v jq &>/dev/null; then
        tmp_cfg=$(mktemp)
        # Force bind and UI, and remove troublesome keys that trigger the doctor
        jq '.gateway.bind = "0.0.0.0" | .gateway.controlUi.enabled = true | .gateway.controlUi.allowInsecureAuth = true | del(.gateway.workspace) | del(.sessions)' /home/agent/.openclaw/openclaw.json > "$tmp_cfg" && mv "$tmp_cfg" /home/agent/.openclaw/openclaw.json
    fi
fi

# Final environment hardening
export OPENCLAW_GATEWAY_TOKEN="$GATEWAY_TOKEN"
export SHELL=/usr/bin/zsh

# Start the Gateway from the native home
cd /home/agent
openclaw gateway run --port 18789 --bind 0.0.0.0 --allow-unconfigured --token "$GATEWAY_TOKEN"

# Final Guard: Keep container alive for log inspection if primary process exits
echo "[!] Primary process has terminated. Maintaining tunnel for diagnostics..."
tail -f /dev/null
