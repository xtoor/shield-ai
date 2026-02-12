# Project Charter: SHIELD-AI-001

## Objective
To build a high-security, portable Docker environment named **SHIELD.ai** that bundles Kali Linux with the OpenClaw agentic framework, pre-installed with a full suite of development and penetration testing tools, and hardened with anti-injection protocols and OS-level antivirus.

## Scope In
- **OS Foundation:** Kali Linux Rolling base image.
- **Security:** ClamAV (Antivirus), AppArmor/Seccomp hardening, non-root agent execution.
- **Anti-Injection:** Implementation of "Shielded Input" protocols to detect and block prompt injection attempts.
- **Tooling:** VS Code (code-server), Headless Chromium (Playwright), and Top 10 Kali Pentest tools.
- **Connectivity:** Tailscale, Twingate, and Cloudflare Warp integration (runtime auth).
- **Documentation:** Multi-platform setup guides (Windows, macOS, Linux) for GitHub.
- **Isolation:** Strict credential management via `.env`.

## Scope Out
- Modifying OpenClaw core (all extensions must be via plugins/skills).
- Hosting public-facing servers directly from the container (must use tunnels).

## Guard-rails
- **Secret Zero:** No hardcoded keys in the image or GitHub repo.
- **Sovereignty:** Explicitly designed for Operator Jay’s control.
- **Quality:** Every build must pass `dom-inspector` (for UI components) and security audit.

## Definitions of Success
- Docker image builds successfully and initializes OpenClaw automatically.
- Antivirus is active on the OS layer.
- VS Code and the Browser are controllable by the agent.
- Documentation is clear enough for a new user to deploy on any OS in under 5 minutes.
