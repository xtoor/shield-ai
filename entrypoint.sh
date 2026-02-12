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

# 4. Start noVNC (Visual HUD)
echo "[*] Establishing Visual HUD (noVNC)..."
Xvfb :99 -screen 0 1920x1080x24 &
export DISPLAY=:99
sleep 2
fluxbox &
x11vnc -display :99 -forever -nopw -listen localhost -xkb &
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
fi

# 5. Launch OpenClaw
echo "[*] Waking Henry (OpenClaw Agent)..."
mkdir -p /home/agent/.openclaw/workspace
if [ ! -f "/home/agent/.openclaw/openclaw.json" ]; then
    echo "[*] Initializing default OpenClaw configuration..."
    echo '{"gateway":{"mode":"local","port":18789}}' > /home/agent/.openclaw/openclaw.json
fi
cd /home/agent/.openclaw/workspace
openclaw gateway run --port 18789 --allow-unconfigured

# Final Guard: Keep container alive for log inspection if primary process exits
echo "[!] Primary process has terminated. Maintaining tunnel for diagnostics..."
tail -f /dev/null
