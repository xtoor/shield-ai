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
sudo chown -R agent:agent /home/agent/.openclaw /home/agent/workspace
mkdir -p /home/agent/workspace
mkdir -p /home/agent/sessions

# Use provided token or default
GATEWAY_TOKEN="${OPENCLAW_GATEWAY_TOKEN:-shield-ai-default-token-12345}"

if [ ! -f "/home/agent/.openclaw/openclaw.json" ]; then
    echo "[*] Initializing default OpenClaw configuration..."
    echo "{\"gateway\":{\"mode\":\"local\",\"port\":18789,\"bind\":\"lan\",\"workspace\":\"/home/agent/workspace\",\"controlUi\":{\"enabled\":true,\"allowInsecureAuth\":true},\"auth\":{\"mode\":\"token\",\"token\":\"$GATEWAY_TOKEN\"}},\"sessions\":{\"path\":\"/home/agent/sessions\"},\"browser\":{\"service\":{\"relayPort\":18793}}}" > /home/agent/.openclaw/openclaw.json
else
    echo "[*] Existing configuration detected. Hardening for container environment..."
    if command -v jq &>/dev/null; then
        tmp_cfg=$(mktemp)
        # Force paths to be container-safe. Note: OpenClaw v2026.2.9 doctor rejects 'gateway.workspace' and 'sessions' at root.
        # We will stop injecting the unrecognized keys and just use CLI flags to ensure stability.
        jq '.gateway.bind = "lan" | .gateway.controlUi.enabled = true | .gateway.controlUi.allowInsecureAuth = true | del(.gateway.workspace) | del(.sessions)' /home/agent/.openclaw/openclaw.json > "$tmp_cfg" && mv "$tmp_cfg" /home/agent/.openclaw/openclaw.json
    fi
fi

# Switch to the internal home directory for startup
cd /home/agent
export OPENCLAW_GATEWAY_TOKEN="$GATEWAY_TOKEN"
# We use the internal home as the working directory to ensure agent stability
openclaw gateway run --port 18789 --bind lan --allow-unconfigured --token "$GATEWAY_TOKEN"

# Final Guard: Keep container alive for log inspection if primary process exits
echo "[!] Primary process has terminated. Maintaining tunnel for diagnostics..."
tail -f /dev/null
