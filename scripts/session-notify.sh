#!/usr/bin/env bash
# Check OpenClaw logs for Swiggy session expiry and send a desktop notification.
# Add to crontab to run after the sneak-treat cron job:
#   5 3 * * * /path/to/sneak-treat/scripts/session-notify.sh
#
# macOS only (uses osascript). On Linux, replace osascript with notify-send.

LOG_DIR="$HOME/.openclaw/logs"
TODAY=$(date +%Y-%m-%d)

# Only check today's log entries for session-related errors
if grep "$TODAY" "$LOG_DIR/gateway.log" 2>/dev/null | grep -qi "session expired\|auth.*expired\|unauthorized\|unauthenticated"; then
  if command -v osascript &>/dev/null; then
    osascript -e 'display notification "Swiggy session expired. Re-authenticate in OpenClaw." with title "Sneak Treat" sound name "Basso"'
  elif command -v notify-send &>/dev/null; then
    notify-send "Sneak Treat" "Swiggy session expired. Re-authenticate in OpenClaw."
  else
    echo "[sneak-treat] $(date): Swiggy session expired. Re-authenticate in OpenClaw." >&2
  fi
fi
