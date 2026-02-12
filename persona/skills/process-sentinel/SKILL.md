---
name: process-sentinel
description: Monitor and terminate running agent processes or exec sessions. Use when an intervention is needed to stop a task or clear stalled runs.
---

# Process Sentinel

This skill provides mechanisms to list and terminate active background tasks within the OpenClaw environment.

## When to use

- When the user issues a "Kill" or "Stop" command for a specific task.
- To clear stalled or long-running background `exec` sessions.
- To provide telemetry on active runs for the Mission Control dashboard.

## Core Commands

### List Active Processes
Use the `process` tool with `action="list"` to see all running background sessions.

### Kill a Process
Use the `process` tool with `action="kill"` and the `sessionId` retrieved from the list.

## Mission Control Integration

The Mission Control dashboard uses these capabilities to provide a physical "Kill Button" for the operator.

### Implementation Pattern

1. **Telemetry:** Polling `process.list()` to update the dashboard UI.
2. **Action:** Sending a `kill` signal via the `process` tool when the UI button is pressed.
