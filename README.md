# Sneak Treat

Automatically add a dog treat to your Swiggy Instamart cart every day at 3 AM — using an AI agent that **cannot** accidentally checkout.

## How It Works

An [OpenClaw](https://github.com/openclaw/openclaw) skill uses Swiggy's official [MCP server](https://github.com/Swiggy/swiggy-mcp-server-manifest) to add "Chip Chops Roast Duck Strips" to your Instamart cart via a scheduled cron job.

**Why MCP instead of browser automation?**

| | Browser Agent | MCP Agent (this project) |
|-|--------------|--------------------------|
| Can accidentally checkout | Yes | **No** (not exposed) |
| Prompt injection risk | High (reads page HTML) | **Low** (structured API, no HTML) |
| Clicks wrong button | Possible | **N/A** (no buttons) |
| Cost per run | $0.10–0.50 | **< $0.01** |
| Breaks when UI changes | Yes | **No** (API is stable) |

Swiggy's Instamart MCP endpoint does not expose checkout — the agent physically cannot place an order. See [docs/SECURITY.md](docs/SECURITY.md) for the full threat model.

## Prerequisites

- [Node.js](https://nodejs.org/) >= 22
- [OpenClaw](https://github.com/openclaw/openclaw) installed and gateway running
- A Swiggy account
- A Groq API key (free tier available at [console.groq.com](https://console.groq.com))

## Quick Start

```bash
git clone https://github.com/Ankitmandal/sneak-treat.git
cd sneak-treat
chmod +x scripts/*.sh config/*.sh
./scripts/install.sh
```

The installer will:
1. Verify prerequisites
2. Copy the skill to `~/.openclaw/skills/sneak-treat/`
3. Guide you through Swiggy MCP server config
4. Help you authenticate with Swiggy (OTP-based)
5. Optionally register the 3 AM daily cron job

## Manual Setup

### 1. Install the skill

```bash
mkdir -p ~/.openclaw/skills/sneak-treat
cp skill/SKILL.md ~/.openclaw/skills/sneak-treat/
cp skill/config.json ~/.openclaw/skills/sneak-treat/
```

### 2. Add Swiggy MCP server

Merge this into your `~/.openclaw/openclaw.json`:

```json
{
  "mcpServers": {
    "swiggy-instamart": {
      "url": "https://mcp.swiggy.com/im",
      "transport": "streamable-http"
    }
  }
}
```

### 3. Authenticate with Swiggy

```bash
openclaw chat --prompt "Connect to the Swiggy Instamart MCP server and authenticate."
```

This sends an OTP to your registered Swiggy phone number.

### 4. Test

```bash
openclaw chat --prompt "Run the sneak-treat skill."
```

Then check your Swiggy Instamart cart.

### 5. Schedule (optional)

```bash
bash config/cron-setup.sh
```

This registers a daily 3 AM cron job in OpenClaw.

## Customization

### Change the product

Edit `skill/SKILL.md` — replace "Chip Chops Roast Duck Strips" with your desired product. Re-copy to `~/.openclaw/skills/sneak-treat/`.

### Change the schedule

Edit the cron expression in `config/cron-setup.sh`. Examples:
- `0 3 * * *` — daily at 3 AM (default)
- `0 3 * * 1-5` — weekdays only
- `0 8,20 * * *` — twice daily at 8 AM and 8 PM

### Change the LLM

Update the model in your `~/.openclaw/openclaw.json`:
```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "groq/openai/gpt-oss-120b"
      }
    }
  }
}
```

Any model supported by OpenClaw works. We use Groq for speed and low cost.

## Session Expiry

Swiggy MCP sessions expire periodically. When this happens:
1. The skill reports "Swiggy session expired"
2. The `session-notify.sh` script sends a macOS notification (if configured)
3. Re-authenticate: `openclaw chat --prompt "Connect to the Swiggy Instamart MCP server and authenticate."`

To set up notifications (macOS and Linux):
```bash
# Add to your crontab (crontab -e)
5 3 * * * /path/to/sneak-treat/scripts/session-notify.sh
```
Uses `osascript` on macOS, `notify-send` on Linux, or falls back to stderr.

## Security

No secrets are stored in this repository. All API keys and tokens live in `~/.openclaw/.env` (chmod 600) and are referenced via `${VAR_NAME}` in config files. See [config/.env.example](config/.env.example) for the expected format.

See [docs/SECURITY.md](docs/SECURITY.md) for the full security model, threat analysis, and defense layers.

## Known Limitations

- **Session expiry** — Swiggy sessions expire; manual re-authentication needed
- **MCP server stability** — Swiggy's MCP is relatively new and may have occasional issues
- **Product availability** — If the item is out of stock, the agent can't add it
- **Machine must be awake** — The cron job runs via OpenClaw's gateway, which requires the machine to be on

## Docs

- [Security Model](docs/SECURITY.md) — Threat analysis and defense layers
- [Architecture](docs/ARCHITECTURE.md) — Why MCP, design decisions, LLM choice
- [Troubleshooting](docs/TROUBLESHOOTING.md) — Common issues and fixes

## License

[MIT](LICENSE)
