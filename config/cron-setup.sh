#!/usr/bin/env bash
# Register the sneak-treat cron job in OpenClaw
# Runs daily at 3 AM in an isolated session

set -euo pipefail

echo "Registering sneak-treat cron job..."

openclaw cron create \
  --name "sneak-treat-run" \
  --schedule "0 3 * * *" \
  --prompt "Run the sneak-treat skill. If authentication has expired or any error occurs, report the error. Do not attempt to fix it. Do not proceed to checkout." \
  --isolated true

echo "Done. Verify with: openclaw cron list"
