#!/usr/bin/env bash
# Manual test for sneak-treat skill
set -euo pipefail

echo "=== Sneak Treat Test ==="
echo ""

# Check gateway (no hardcoded port — use openclaw's own status check)
if ! openclaw gateway status 2>/dev/null | grep -q "Runtime: running"; then
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
