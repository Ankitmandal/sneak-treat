# Sneak Treat

Add one pack of "Chip Chops Roast Duck Strips" to the Swiggy Instamart cart.

## Steps

1. Use the Swiggy Instamart MCP server to search for "Chip Chops Roast Duck Strips"
2. From the results, identify the correct product (Chip Chops brand, Roast Duck Strips variant)
3. Check if the item is already in the cart by viewing current cart contents
   - If already in cart → report "Item already in cart. Skipping." and STOP
4. Add exactly 1 unit of the product to the cart
5. Report success: "Added 1x Chip Chops Roast Duck Strips to cart."

## Rules

- Only use the Swiggy Instamart MCP tools — do NOT use browser, filesystem, or any other tools
- Add exactly 1 unit, never more
- Do not remove any existing cart items
- Do not modify quantities of existing items
- If the product is not found, report "Product not found" and STOP
- If the product is out of stock, report "Product out of stock" and STOP
- If authentication has expired, report "Swiggy session expired" and STOP
- Do not proceed to checkout under any circumstances
- Do not interact with any payment or address functionality
