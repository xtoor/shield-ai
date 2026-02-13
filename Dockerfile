# SHIELD.ai - The Infiltrator Build
# Base: Kali Linux Rolling (Headless)
FROM kalilinux/kali-rolling:latest

# Metadata
LABEL maintainer="Henry of Skalitz"
LABEL project="SHIELD.ai"

# 1. System Core & Security Hardening
USER root
ENV DEBIAN_FRONTEND=noninteractive

# Combine updates and installs to reduce layers
RUN apt-get update && apt-get full-upgrade -y && \
    apt-get install -y --no-install-recommends \
    sudo zsh curl wget git vim gnupg lsb-release jq \
    clamav clamav-daemon \
    python3 python3-pip python3-venv \
    nodejs npm \
    net-tools iputils-ping \
    nmap \
    metasploit-framework \
    sqlmap \
    wireshark-common \
    john \
    hydra \
    exploitdb \
    xvfb x11vnc fluxbox novnc chromium feh zenity && \
    # Clean up apt cache to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Initialize Antivirus Database
RUN freshclam || true

# 3. GUI & Browser "The Sight"
# Install Playwright globally for OpenClaw browser tool support
RUN npm install -g playwright && \
    playwright install chromium --with-deps

# Optimize noVNC default entry point (Auto-connect + Local Scaling)
RUN echo "<html><head><meta http-equiv='refresh' content='0; url=vnc.html?autoconnect=true&scale=local'></head></html>" > /usr/share/novnc/index.html

# 4. Collaborative Forge (code-server)
# Install via official script and ensure binary is in PATH
RUN curl -fsSL https://code-server.dev/install.sh | sh && \
    ln -s /usr/lib/code-server/bin/code-server /usr/bin/code-server

# 5. Networking & Stealth (Tunnels) - MUST RUN AS ROOT
RUN mkdir -p /usr/share/keyrings && \
    curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null && \
    curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list && \
    curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ bookworm main" | tee /etc/apt/sources.list.d/cloudflare-client.list && \
    apt-get update && apt-get install -y tailscale cloudflare-warp && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 6. Agent Setup & Permissions
RUN useradd -m -s /usr/bin/zsh agent && \
    echo "agent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Ensure agent owns their home and OpenClaw directories
RUN mkdir -p /home/agent/.openclaw/workspace && \
    chown -R agent:agent /home/agent/.openclaw

# Set up ClamAV permissions for the socket
RUN mkdir -p /var/run/clamav && \
    chown -R clamav:clamav /var/run/clamav && \
    chmod 775 /var/run/clamav

# Configure Fluxbox Menu and PATH (Absolute Paths Enforced)
RUN mkdir -p /home/agent/.fluxbox && \
    echo '[begin] (Kali SHIELD)\n[exec] (Terminal) {/usr/bin/x-terminal-emulator}\n[exec] (Chromium) {/usr/bin/chromium --no-sandbox}\n[submenu] (Kali Tools)\n [exec] (Nmap) {/usr/bin/x-terminal-emulator -e /bin/zsh -c "nmap; read -p \"Press enter to close...\""}\n [exec] (Metasploit) {/usr/bin/x-terminal-emulator -e msfconsole}\n[end]\n[submenu] (OpenClaw)\n [exec] (Henry UI) {/usr/bin/chromium --no-sandbox http://localhost:18789}\n [exec] (IDE) {/usr/bin/chromium --no-sandbox http://localhost:18791}\n[end]\n[submenu] (System)\n [exec] (Set Wallpaper) {/usr/bin/feh --bg-fill $(/usr/bin/zenity --file-selection --title="Select Wallpaper")}\n[end]\n[restart] (Restart)\n[exit] (Exit)\n[end]' > /home/agent/.fluxbox/menu && \
    chown -R agent:agent /home/agent/.fluxbox

# Set npm global path to avoid root-only directories
ENV NPM_CONFIG_PREFIX=/home/agent/.npm-global
ENV PATH=$PATH:/home/agent/.npm-global/bin

WORKDIR /home/agent
USER agent

# Install OpenClaw Core
RUN mkdir -p /home/agent/.npm-global && \
    npm install -g openclaw

# 6.1 Persona Injection (The Skalitz Protocol)
RUN mkdir -p /home/agent/.openclaw/workspace
COPY --chown=agent:agent persona/ /home/agent/.openclaw/workspace/

# 7. Entrypoint & Ports
EXPOSE 18791 18792 18789

# Copy tactical scripts
COPY --chown=agent:agent entrypoint.sh /usr/local/bin/entrypoint.sh

# Fix Windows line endings and set permissions as root
USER root
RUN sed -i 's/\r$//' /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

USER agent
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
