# SHIELD.ai - The Infiltrator Build
# Base: Kali Linux Rolling (Headless)
FROM kalilinux/kali-rolling:latest

# Metadata
LABEL maintainer="Henry of Skalitz"
LABEL project="SHIELD.ai"

# 1. System Core & Security Hardening
USER root
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    sudo zsh curl wget git vim gnupg lsb-release \
    clamav clamav-daemon \
    python3 python3-pip python3-venv \
    nodejs npm \
    net-tools iputils-ping \
    && apt-get clean

# Initialize Antivirus
RUN freshclam || true

# 2. Infiltrator Arsenal (Top 10 Kali Tools)
RUN apt-get install -y \
    nmap \
    metasploit-framework \
    sqlmap \
    wireshark-common \
    john \
    hydra \
    exploitdb \
    && apt-get clean

# 3. GUI & Browser "The Sight"
# Install Playwright/Chromium and VNC stack
RUN npm install -g playwright && \
    playwright install chromium --with-deps && \
    apt-get install -y \
    xvfb x11vnc fluxbox novnc \
    && apt-get clean

# 4. Collaborative Forge (code-server)
RUN curl -fsSL https://code-server.dev/install.sh | sh

# 5. Agent Setup
# Create non-root user for the agent
RUN useradd -m -s /usr/bin/zsh agent && \
    echo "agent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set npm global path to avoid root-only directories
ENV NPM_CONFIG_PREFIX=/home/agent/.npm-global
ENV PATH=$PATH:/home/agent/.npm-global/bin

WORKDIR /home/agent
USER agent

# Install OpenClaw Core (Local to user global bin)
RUN mkdir -p /home/agent/.npm-global && \
    npm install -g openclaw

# 5.1 Persona Injection (The Skalitz Protocol)
COPY --chown=agent:agent persona/ /home/agent/.openclaw/workspace/

# 6. Networking & Stealth (Tunnels)
# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Install Cloudflare Warp (Using Debian Bookworm repo for Kali compatibility)
RUN mkdir -p /usr/share/keyrings && \
    curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ bookworm main" | tee /etc/apt/sources.list.d/cloudflare-client.list && \
    apt-get update && apt-get install -y cloudflare-warp && \
    apt-get clean

# 7. Entrypoint & Ports
# Ports: 18791 (IDE), 18792 (noVNC), 18789 (OpenClaw)
EXPOSE 18791 18792 18789

# Copy tactical scripts
COPY --chown=agent:agent entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
