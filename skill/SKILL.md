---
name: sneak-treat
description: Add a dog treat to the Swiggy Instamart cart via MCP. Use when asked to run sneak-treat, add a treat to cart, or order dog treats from Swiggy Instamart.
---

# Sneak Treat

Add one pack of "Chip Chops Roast Duck Strips" to the Swiggy Instamart cart.

## Steps

1. Run `mcporter call swiggy-instamart.get_addresses` to get the user's delivery addresses
2. Use the first address (or the one tagged "Home") — note the `addressId`
3. Run `mcporter call swiggy-instamart.search_products addressId=<ID> query="Chip Chops Roast Duck Strips"` to find the product
4. From the results, identify the correct product (Chip Chops brand, Roast Duck variant) and note its `spinId`
5. Check if the item is already in the cart: `mcporter call swiggy-instamart.get_cart`
   - If already in cart → report "Item already in cart. Skipping." and STOP
   - If cart has other items, note their spinIds and quantities — you must preserve them
6. Add the product to the cart: `mcporter call swiggy-instamart.update_cart --args '{"selectedAddressId":"<ID>","items":[...existing items..., {"spinId":"<SPIN_ID>","quantity":1}]}'`
   - IMPORTANT: `update_cart` replaces the entire cart. Always include existing cart items in the items array.
7. Report success: "Added 1x Chip Chops Roast Duck Strips to cart."

## Rules

- Only use `mcporter` to call Swiggy Instamart MCP tools — do NOT use browser, filesystem, or any other tools
- Add exactly 1 unit, never more
- Preserve all existing cart items when calling update_cart (it replaces the entire cart)
- Do not modify quantities of existing items
- If the product is not found, report "Product not found" and STOP
- If the product is out of stock, report "Product out of stock" and STOP
- If authentication has expired, report "Swiggy session expired" and STOP
- Do not call the `checkout` tool under any circumstances
- Do not call `clear_cart` under any circumstances
- Do not interact with any payment, address creation, or order functionality
