# Security Model

## Threat Model

This project uses an AI agent (via OpenClaw) to modify a Swiggy Instamart cart. Here's what could go wrong and how we mitigate it.

### Risk: Accidental Checkout

| Approach | Risk Level | Why |
|----------|-----------|-----|
| Browser automation (Playwright/Puppeteer) | High | Agent can click any button, including "Place Order" |
| Browser automation with LLM (OpenClaw + browser tool) | High | LLM could misinterpret page and click checkout |
| **MCP server (this project)** | **None** | Swiggy's Instamart MCP does not expose checkout |

Swiggy's Instamart MCP endpoint (`https://mcp.swiggy.com/im`) exposes structured API tools for search, add-to-cart, and view-cart. **Checkout is not available** through the Instamart MCP interface. The agent physically cannot place an order.

### Risk: Prompt Injection

Browser-based agents read web page content (DOM, text, ads) and pass it to the LLM. Malicious content on the page could manipulate the agent.

**Our mitigation**: No browser. The MCP server returns structured JSON data, not HTML. There is no webpage content for an attacker to inject into.

### Risk: Unintended Cart Modifications

The agent could theoretically remove items or change quantities.

**Our mitigation**:
- The skill instructions (`SKILL.md`) explicitly forbid removing items or changing quantities
- The skill config (`config.json`) restricts tool access to `mcp:swiggy-instamart` only — no browser, filesystem, or exec tools
- The skill checks if the item is already in cart before adding (idempotent)

### Risk: Secret Leakage

| Secret | Where It Lives | NOT In |
|--------|---------------|--------|
| Groq API key | `~/.openclaw/.env` (chmod 600) | This repo |
| Telegram bot token | `~/.openclaw/.env` (chmod 600) | This repo |
| Gateway auth token | `~/.openclaw/.env` (chmod 600) | This repo |
| Swiggy session tokens | OpenClaw internal state | This repo |

All secrets are stored in environment variables or OpenClaw's `.env` file. The `openclaw.json` config file references them via `${VAR_NAME}` syntax. No secrets exist in this repository.

### Risk: Session Hijacking

Swiggy MCP authentication uses OTP-based login. Session tokens are stored by OpenClaw internally. If the machine is compromised, the attacker could access:
- Your Swiggy cart (add/view items)
- Your Swiggy account info accessible through MCP

**Mitigation**: This is the same risk as being logged into Swiggy on your phone. Machine-level compromise is out of scope.

## Defense Layers

```
Layer 1: MCP-only (no browser)        → No page interaction, no accidental clicks
Layer 2: Tool restriction              → Skill only has access to mcp:swiggy-instamart
Layer 3: No checkout exposed           → Swiggy Instamart MCP doesn't support it
Layer 4: Idempotency                   → Checks cart before adding
Layer 5: Isolated cron sessions        → No context leakage between runs
Layer 6: Session expiry notification   → Alerts when re-auth is needed
```

## Responsible Use

This project is designed for use on **your own Swiggy account**. Using it to modify someone else's cart without their knowledge may violate terms of service and could have legal implications depending on your jurisdiction.
