public class CartItemTriggerHandler {
    public static void handleInsertAndUpdate(List<CartItem> items, Map<Id, CartItem> oldItemsMap) {
        for (CartItem item : items) {
            CartItem oldItem = oldItemsMap.get(item.Id);
            Decimal quantity = item.Quantity-oldItem.Quantity;
            String validationMessage = ValidateCart.validateCart(item.CartId, item.Product2Id, quantity);

            if (!String.isEmpty(validationMessage)) {
                if(oldItemsMap.containsKey(item.Id)) {
                    item.Quantity = oldItem.Quantity;
                    item.TotalPrice = oldItem.TotalPrice;
                }
                saveCartValidationOutputError(validationMessage, item.CartId, item.Id);
            }
        }
    }
    
    private static void saveCartValidationOutputError(String errorMessage, Id cartId, Id cartItem) {
        CartValidationOutput cartValidationError = new CartValidationOutput(
            CartId = cartId,
            Level = 'Error',
            Message = errorMessage,
            Name = (String)cartId,
            RelatedEntityId = cartId,
            Type = 'Inventory'
        );
        insert(cartValidationError);
    }
}