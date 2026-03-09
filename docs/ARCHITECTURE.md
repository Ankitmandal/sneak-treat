# Architecture

## Why MCP Over Browser Automation?

We evaluated three approaches:

### 1. Browser Automation with LLM (OpenClaw + browser tool)

The original idea: give an LLM a browser and let it navigate Swiggy.

**Problems:**
- LLM can click anything — including checkout, payment, address changes
- Web page content can manipulate the LLM (prompt injection via ads/scripts)
- Non-deterministic: the LLM might interpret the UI differently each run
- Expensive: $0.10-0.50 per run for LLM to process page screenshots

### 2. Browser Automation without LLM (Playwright/Puppeteer)

Deterministic scripts with CSS selectors.

**Problems:**
- Breaks when Swiggy changes their frontend (frequent)
- Still has browser access — a bug could navigate to checkout
- Requires maintaining selectors

### 3. Swiggy MCP Server (chosen approach)

Use Swiggy's official Model Context Protocol server.

**Why this wins:**
- **No browser at all** — structured API calls, not page interactions
- **Checkout not exposed** — Instamart MCP doesn't support placing orders
- **Structured data** — no HTML parsing, minimal prompt injection surface (see [SECURITY.md](SECURITY.md) for nuance)
- **Official API** — maintained by Swiggy, follows MCP standard
- **Semantic resilience** — API tools don't break when UI changes

## MCP (Model Context Protocol)

MCP is a standard protocol that lets AI agents call specific tools exposed by a server. Swiggy's MCP server at `https://mcp.swiggy.com/im` exposes tools like:

- Product search
- Add to cart
- View cart contents
- Pricing information

The agent calls these tools with typed parameters and gets structured JSON responses. There's no open-ended browsing.

## Skill Design

### Tool Scoping

The skill config (`config.json`) sets `"tools": ["mcp:swiggy-instamart"]`. This *should* mean the OpenClaw agent running this skill can only access Swiggy Instamart MCP tools — no browser, no filesystem, no shell execution. After installation, verify this by running the skill and checking the audit log (`~/.openclaw/logs/audit.jsonl`) to confirm only `mcp:swiggy-instamart` tool calls appear.

### Idempotency (Best-Effort)

The skill instructs the LLM to check the cart before adding. If the item is already present, it should skip. This is an LLM instruction, not a programmatic guarantee — the agent may occasionally miss the check. In practice, a rare duplicate item is the worst case, not a safety issue.

### Error Handling

The skill is designed to **fail loudly and do nothing** rather than attempt recovery:
- Session expired → report and stop
- Product not found → report and stop
- Product out of stock → report and stop

No retry logic, no fallbacks, no workarounds. If something is wrong, a human should look at it.

## Cron Isolation

Each cron run uses `--isolated true`, which means:
- Fresh agent session (no prior conversation context)
- Dedicated session ID (`cron:sneak-treat-run`)
- No pollution of the main OpenClaw chat history
- Independent failure — a broken run doesn't affect the next one

## LLM Choice

We use `groq/openai/gpt-oss-120b` via Groq:
- 120B parameter MoE model
- ~500 tokens/second on Groq hardware
- 128k context window
- $0.15/M input, $0.75/M output tokens
- Each run costs fractions of a cent
