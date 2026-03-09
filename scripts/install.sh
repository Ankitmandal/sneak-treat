#!/usr/bin/env bash
# Interactive setup script for sneak-treat
set -euo pipefail

SKILL_DIR="$HOME/.openclaw/skills/sneak-treat"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Sneak Treat Installer ==="
echo ""

# 1. Check prerequisites
echo "[1/6] Checking prerequisites..."

if ! command -v openclaw &>/dev/null; then
  echo "ERROR: OpenClaw is not installed."
  echo "Install it: npm install -g openclaw@latest"
  exit 1
fi
echo "  OpenClaw: $(openclaw --version)"

if ! command -v node &>/dev/null; then
  echo "ERROR: Node.js is not installed."
  exit 1
fi
NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VERSION" -lt 22 ]; then
  echo "ERROR: Node.js >= 22 required. Found: $(node -v)"
  exit 1
fi
echo "  Node.js: $(node -v)"

# 2. Check gateway
echo ""
echo "[2/6] Checking OpenClaw gateway..."
if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:18789/ 2>/dev/null | grep -q "200"; then
  echo "  Gateway is running."
else
  echo "  WARNING: Gateway is not responding on port 18789."
  echo "  Start it with: openclaw gateway start"
  echo "  Or run: openclaw onboard --install-daemon"
  read -p "  Continue anyway? (y/N) " -n 1 -r
  echo
  [[ $REPLY =~ ^[Yy]$ ]] || exit 1
fi

# 3. Copy skill files
echo ""
echo "[3/6] Installing skill to $SKILL_DIR..."
mkdir -p "$SKILL_DIR"
cp "$SCRIPT_DIR/skill/SKILL.md" "$SKILL_DIR/SKILL.md"
cp "$SCRIPT_DIR/skill/config.json" "$SKILL_DIR/config.json"
echo "  Skill files copied."

# 4. MCP server config
echo ""
echo "[4/6] Swiggy MCP server configuration"
echo ""
echo "  Add this to your ~/.openclaw/openclaw.json (merge into existing config):"
echo ""
echo '  "mcpServers": {'
echo '    "swiggy-instamart": {'
echo '      "url": "https://mcp.swiggy.com/im",'
echo '      "transport": "streamable-http"'
echo '    }'
echo '  }'
echo ""
read -p "  Press Enter when done (or Ctrl-C to abort)..."

# 5. Authenticate with Swiggy
echo ""
echo "[5/6] Swiggy authentication"
echo ""
echo "  You need to authenticate with Swiggy's MCP server."
echo "  This will send an OTP to your registered Swiggy phone number."
echo ""
echo "  Run this in a separate terminal:"
echo '  openclaw chat --prompt "Connect to the Swiggy Instamart MCP server and authenticate."'
echo ""
read -p "  Press Enter after you've authenticated..."

# 6. Register cron job
echo ""
echo "[6/6] Setting up cron job..."
read -p "  Register daily 3 AM cron job? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  bash "$SCRIPT_DIR/config/cron-setup.sh"
else
  echo "  Skipped. Run config/cron-setup.sh later to set it up."
fi

echo ""
echo "=== Setup complete! ==="
echo ""
echo "Test it: openclaw chat --prompt 'Run the sneak-treat skill.'"
echo "Or run:  ./scripts/test.sh"
