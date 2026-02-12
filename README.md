<div align="center">

![SHIELD.ai Logo](shield_logo.jpg)

[![Language - Python](https://img.shields.io/badge/Language-Python-blue?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Language - TypeScript](https://img.shields.io/badge/Language-TypeScript-blue?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Language - Shell](https://img.shields.io/badge/Language-Shell-green?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Requirement - Docker](https://img.shields.io/badge/Requirement-Docker-blue?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Requirement - Compose](https://img.shields.io/badge/Requirement-Compose-blue?style=for-the-badge&logo=docker&logoColor=white)](https://docs.docker.com/compose/)

# SHIELD.ai - The Infiltrator Build ⚔️🛡️💻

A sovereign, high-security AI operations environment. Bundling **OpenClaw** with **Kali Linux**, hardened for professional development and offensive security.

## ⚡ Features
- **OS:** Kali Linux Rolling (Headless)
- **Security:** ClamAV (Active Antivirus), AppArmor profiles, non-root execution.
- **Visual HUD:** Real-time visual desktop via **noVNC** (Port 18792).
- **IDE:** Integrated **VS Code** via `code-server` (Port 18791).
- **Arsenal:** Pre-installed Top 10 Kali tools (Nmap, Metasploit, SQLmap, etc.).
- **Stealth:** Native Tailscale/Twingate support for zero-trust networking.
- **Persona:** Pre-injected with the **Henry of Skalitz** AI persona and the full specialized skill library.

## DISCLAIMER I AM NOT LIABLE IN ANY SHAPE OR FORM FOR MISUSE OF THIS SOFTWARE... IT IS POWERFULL AND CAN BE DANGEROUS TO PEOPLE THAT DON'T KNOW WHAT THEY DOING... USE ETHICALLY USE AT YOUR OWN RISK!

## Current Status:
- Windows: [![Tested - Windows](https://img.shields.io/badge/Tested-Windows-brightgreen?style=for-the-badge&logo=windows)](https://github.com/xtoor/shield-ai)
- MacOS:   [![Untested - MacOS](https://img.shields.io/badge/Untested-MacOS-red?style=for-the-badge&logo=apple)](https://github.com/xtoor/shield-ai)
- Linux:   [![Untested - Linux](https://img.shields.io/badge/Untested-Linux-red?style=for-the-badge&logo=linux)](https://github.com/xtoor/shield-ai)
- Contributors are Welcome

## 🔐 Security: Mandatory Token Update
By default, SHIELD.ai initializes with a generic token. For your safety, you **MUST** generate a unique secure token before exposing the gateway to any network.

### **Generate Token (Linux & macOS)**
```bash
chmod +x gen_token.sh
./gen_token.sh
```

### **Generate Token (Windows)**
```powershell
.\gen_token.ps1
```
*Note: This script updates your `.env` file. You will need to rebuild the container (`docker-compose up -d --build`) to apply the new secret.*

## 🚀 Rapid Deployment (One-Line Start)

### **Linux & macOS (Bash)**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/xtoor/shield-ai/main/install.sh)"
```

### **Windows (PowerShell)**
> **⚠️ Required:** Open **Docker Desktop** and run PowerShell as **Administrator** before running this command.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/xtoor/shield-ai/main/install.ps1'))
```

## 🛠️ Manual Installation

1. **Clone the Forge:**
   ```bash
   git clone https://github.com/xtoor/shield-ai.git
   cd shield-ai
   ```

2. **Prepare your Secrets:**
   Copy `.env.example` to `.env` and fill in your keys.

3. **Ignite the Forge:**
   ```bash
   docker-compose up -d --build
   ```

## 🦇 Operational Access
Once the build is complete, you can access the command center:
- **OpenClaw Gateway:** `http://localhost:18789`
- **Visual HUD (noVNC):** `http://localhost:18792`
- **Collaborative IDE:** `http://localhost:18791`

## 🗑️ Decommissioning (Uninstall)

### **Linux & macOS (Bash)**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/xtoor/shield-ai/main/uninstall.sh)"
```

### **Windows (PowerShell)**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/xtoor/shield-ai/main/uninstall.ps1'))
```

## ⚖️ Directives
SHIELD.ai follows the **Standard of Skalitz**:
- **Rule 1:** Inspect & Preview all products before submission.
- **Rule 2:** Maintain absolute secret isolation.
- **Rule 3:** For any OpenClaw core issues, refer to the [OpenClaw Documentation](https://docs.openclaw.ai).


---
*Forged by the Kingdom of Skalitz* ⚔️🛡️
