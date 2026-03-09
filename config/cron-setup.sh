#!/usr/bin/env bash
# Register the sneak-treat cron job in OpenClaw
# Runs daily at 3 AM in an isolated session

set -euo pipefail

echo "Registering sneak-treat cron job..."

# Check if the cron job already exists
if openclaw cron list 2>/dev/null | grep -q "sneak-treat-run"; then
  echo "Cron job 'sneak-treat-run' already exists. Skipping."
  echo "To recreate, first delete it: openclaw cron delete sneak-treat-run"
  exit 0
fi

CRON_PROMPT="Add a dog treat to my Swiggy Instamart cart. \
Search for 'Chip Chops' dog treats using mcporter to call swiggy-instamart MCP tools. \
Steps: 1) mcporter call swiggy-instamart.get_addresses to get my address ID. \
2) mcporter call swiggy-instamart.search_products with that addressId and query 'Chip Chops'. \
3) Pick the first in-stock Chip Chops product. \
4) mcporter call swiggy-instamart.get_cart to check existing items. \
5) If the product is already in cart, stop. \
6) mcporter call swiggy-instamart.update_cart with all existing items plus the new one (quantity 1). \
Do NOT call checkout or clear_cart. Report what happened."

openclaw cron create \
  --name "sneak-treat-run" \
  --schedule "0 3 * * *" \
  --prompt "$CRON_PROMPT" \
  --isolated true

echo "Done. Verify with: openclaw cron list"
