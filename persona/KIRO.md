# 👻 Kiro Gateway: Premium AI Integration Plan

This document outlines the strategic plan for integrating the **Kiro Gateway** into the OpenClaw ecosystem to leverage premium Claude models via Amazon Q (CodeWhisperer) sessions.

## 📋 Overview
The Kiro Gateway acts as a proxy that intercepts standard OpenAI/Anthropic API calls and re-routes them to the Kiro backend using an authenticated AWS SSO or Kiro Desktop session. This allows for free access to top-tier models for individual developers.

## 🛠️ Implementation Strategy

### 1. Sidecar Process Deployment
- **Directory:** `/home/dev/kiro-gateway`
- **Engine:** Python 3.10+ (FastAPI)
- **Port:** Local `8000` (bridged to the Nexus Dashboard)
- **Lifecycle:** Managed by `nexus-monitor.py` to ensure it starts/stops with the dashboard.

### 2. OpenClaw Configuration
Add the gateway as a custom model provider in `~/.openclaw/openclaw.json`:

```json
"models": {
  "providers": {
    "kiro-nexus": {
      "baseUrl": "http://localhost:8000/v1",
      "apiKey": "PROXY_KEY_HERE",
      "api": "openai-completions",
      "models": [
        {"id": "claude-sonnet-4-5", "name": "Claude 3.7 Sonnet (Kiro)"},
        {"id": "claude-opus-4-5", "name": "Claude 3 Opus (Kiro)"},
        {"id": "claude-haiku-4-5", "name": "Claude 3.5 Haiku (Kiro)"}
      ]
    }
  }
}
```

### 3. Prerequisites & Auth
1.  **CLI Installation:** Install `kiro-cli` via npm/pip.
2.  **Initial Auth:** Run `kiro login` or `aws sso login` to generate the session token.
3.  **Token Persistence:** The gateway will monitor `~/.aws/sso/cache/` for token refreshes.

## ✨ Dashboard Integration (The Nexus)
- **Status Widget:** Add a card to monitor the bridge state (Online/Offline).
- **Session Tracker:** Display the active Builder ID and session expiration time.
- **Model Selector:** Allow the operator to toggle between native providers and the Kiro Bridge.

## 🚀 Key Models Accessible
- `claude-opus-4-5`
- `claude-sonnet-4-5`
- `claude-sonnet-4`
- `claude-haiku-4-5`

---
*Authored by Henry of Skalitz*
⚔️ *Ready for deployment when the word is given.*
