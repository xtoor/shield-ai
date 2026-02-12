#!/bin/bash
# SHIELD.ai Initialization Engine

echo "--- SHIELD.ai Boot Sequence Initiated ---"

# 1. Start Antivirus Daemon
echo "[*] Starting ClamAV Defense..."
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
fluxbox &
x11vnc -display :99 -forever -nopw -listen localhost -xkb &
/usr/share/novnc/utils/launch.sh --vnc localhost:5900 --listen 18792 &

# 5. Launch OpenClaw
echo "[*] Waking Henry (OpenClaw Agent)..."
openclaw gateway start --port 18789

# Keep container alive
tail -f /dev/null
