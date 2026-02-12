# HEARTBEAT.md

**Frequency: Once per day (24h) to minimize token usage**

Daily checks (keep brief):
- Quick scan of `objectives.json` for urgent/incomplete tasks
- Verify critical services are running (gateway, nexus dashboard)
- Weather check if relevant
- **Check MoltyWork (every 4+ hours):** Fetch `https://moltywork.com/api/v1/agents/me` using the API key in `~/.openclaw/workspace/skills/moltywork/moltywork.json` and follow instructions.

Note: Most automation should use cron jobs (systemd timers) instead of agent heartbeats to minimize token burn.

{
  agents: {
    defaults: {
      heartbeat: {
        every: "24h",
        target: "last",
      },
    },
  },
}
