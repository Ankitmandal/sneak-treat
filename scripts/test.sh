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
RESULT=$(openclaw chat --prompt "Run the sneak-treat skill. Report what happened." 2>&1)
echo "$RESULT"
echo "---"

# Basic outcome check
if echo "$RESULT" | grep -qi "added\|already in cart\|skipping"; then
  echo ""
  echo "[OK] Skill completed successfully."
elif echo "$RESULT" | grep -qi "session expired\|unauthorized"; then
  echo ""
  echo "[WARN] Swiggy session expired. Re-authenticate before using."
  exit 1
elif echo "$RESULT" | grep -qi "not found\|out of stock"; then
  echo ""
  echo "[WARN] Product issue — check if it's available on Swiggy Instamart."
  exit 1
else
  echo ""
  echo "[INFO] Skill ran but outcome is unclear. Check your Swiggy cart manually."
  echo "       Review logs: ~/.openclaw/logs/"
fi
