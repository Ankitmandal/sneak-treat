#!/usr/bin/env bash
# Check OpenClaw logs for Swiggy session expiry and send macOS notification.
# Add to crontab to run after the sneak-treat cron job:
#   5 3 * * * /path/to/sneak-treat/scripts/session-notify.sh

LOG_DIR="$HOME/.openclaw/logs"
TODAY=$(date +%Y-%m-%d)

# Check today's gateway log for session-related errors
if grep -qi "session expired\|auth.*expired\|unauthorized\|unauthenticated" "$LOG_DIR/gateway.log" 2>/dev/null; then
  osascript -e 'display notification "Swiggy session expired. Re-authenticate in OpenClaw." with title "Sneak Treat" sound name "Basso"'
fi
