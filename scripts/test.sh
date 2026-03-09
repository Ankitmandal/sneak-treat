#!/usr/bin/env bash
# Manual test for sneak-treat skill
set -euo pipefail

echo "=== Sneak Treat Test ==="
echo ""

# Check gateway
if ! curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:18789/ 2>/dev/null | grep -q "200"; then
  echo "FAIL: OpenClaw gateway is not running."
  echo "Start it: openclaw gateway start"
  exit 1
fi
echo "[OK] Gateway is running"

# Check skill is installed
SKILL_DIR="$HOME/.openclaw/skills/sneak-treat"
if [ ! -f "$SKILL_DIR/SKILL.md" ]; then
  echo "FAIL: Skill not installed at $SKILL_DIR"
  echo "Run: ./scripts/install.sh"
  exit 1
fi
echo "[OK] Skill is installed"

# Run the skill
echo ""
echo "Running sneak-treat skill..."
echo "---"
openclaw chat --prompt "Run the sneak-treat skill. Report what happened."
echo "---"
echo ""
echo "Check your Swiggy Instamart cart to verify the item was added."
