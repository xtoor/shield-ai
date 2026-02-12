# Direct Directives: OpenClaw Node Pairing ⚔️🛡️

To allow Henry to work "directly" on your machine (control the mouse, view the screen, run local commands), you can run an **OpenClaw Node** on your host laptop and pair it with the SHIELD.ai gateway.

## 1. Install OpenClaw on your Host
If you haven't already, install the OpenClaw CLI on your local machine (Mac, Windows, or Linux):
```bash
npm install -g openclaw
```

## 2. Start the Node
On your laptop (the host), start a node. You can choose which "senses" to share with Henry:
```bash
# Share screen and terminal control
openclaw node run --allow-shell --allow-screen
```
*Note: This will output a **Pairing Code**.*

## 3. Pair with SHIELD.ai
1. Open the SHIELD.ai Control UI in your browser (`http://localhost:18789`).
2. Go to the **Nodes** or **Devices** tab.
3. Click **Pair New Node**.
4. Enter the **Pairing Code** generated on your laptop.

## 4. Work Directly
Once paired, Henry can use the `nodes` tool to:
- **Describe:** See your system specs.
- **Screen:** Take screenshots or view your live screen.
- **Run:** Execute commands directly on your machine's terminal.
- **Notify:** Send desktop notifications to you.

---
*By pairing a node, you are granting the AI controlled access to your machine. Always monitor the logs and revoke access when not in use.* ⚔️
