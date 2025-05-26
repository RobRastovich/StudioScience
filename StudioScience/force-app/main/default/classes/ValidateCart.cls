public without sharing class ValidateCart {

    @AuraEnabled
    public static String  validateCart(String cartId, String productId, Decimal quantityToAdd) {
        String output = '';

        if (quantityToAdd == null) {
            quantityToAdd = 0;
        }

        if (cartId == null || cartId == '') {
            try {
                String webStoreId = getWebStoreId();
                String effectiveAccountId = getUserEffectiveAccountId();

                ConnectApi.CartSummary cartSummary = ConnectApi.CommerceCart.getOrCreateActiveCartSummary(
                    webStoreId, 
                    effectiveAccountId, 
                    'active'
                );
                cartId = cartSummary.cartId;
            } catch (Exception e) {
                return 'Error getting or generating cart.';
            }
        }

        WebCart cart = [SELECT Id, AccountId, OwnerId, WebStoreId FROM WebCart WHERE Id = :cartId LIMIT 1];

        List<BuyerGroupMember> BGMList = [SELECT BuyerGroupId FROM BuyerGroupMember WHERE BuyerId = :cart.AccountId LIMIT 1];
        if (BGMList.isEmpty()) {
            return 'No BuyerGroupMember found for this Account.';
        }
        BuyerGroupMember BGM = BGMList[0];

        List<CartQuantityRule__c> CQRList = [SELECT Value__c, ErrorMessage__c FROM CartQuantityRule__c
            WHERE Type__c = 'Order' AND WebStoreId__c = :cart.WebStoreId AND BuyerGroupId__c = :BGM.BuyerGroupId LIMIT 1];

        if (CQRList.size () == 1) {
            Datetime criteriaDatetime = null;
            // Madrid
            if (CQRList[0].Value__c == 1) {
                Date startOfWeekDate = Date.today();
                startOfWeekDate = startOfWeekDate.toStartOfWeek();
                Datetime startOfWeekDateTime = Datetime.newInstance(startOfWeekDate, Time.newInstance(0, 0, 0, 0));
                criteriaDatetime = startOfWeekDateTime;
            }

            // Segovia
            if (CQRList[0].Value__c == 20) {
                Date lastMonth20Date = Date.today();
                lastMonth20Date = date.newInstance(lastMonth20Date.year(), lastMonth20Date.month() - 1, 20);
                Datetime lastMonth20DateTime = lastMonth20Date;
                criteriaDatetime = lastMonth20DateTime;
            }

            List<OrderSummary> orderSummaryList = new List<OrderSummary>();
            if (!Test.isRunningTest()) {
                orderSummaryList = [SELECT Id FROM OrderSummary WHERE OwnerId = :cart.OwnerId AND CreatedDate >= :criteriaDatetime ORDER BY CreatedDate DESC LIMIT 1];
            } else {
                orderSummaryList = [SELECT Id, OrderedDate FROM OrderSummary WHERE OwnerId = :cart.OwnerId AND OrderedDate >= :criteriaDatetime ORDER BY OrderedDate DESC LIMIT 1];
            }

            if (orderSummaryList.size () > 0) {
                output = CQRList[0].ErrorMessage__c;
            }
        }

        // 2 validate Cart Total
        Set<String> productIdSet = new Set<String>();
        Map<String, Decimal> productIdQuantiyMap = new Map<String, Decimal>();
        Decimal totalProducts = 0;
        if (output.length() == 0) {
            List<CartItem> cartItemList = [SELECT Id, Product2Id, Quantity FROM CartItem WHERE CartId = :cartId AND Type = 'Product'];
            for (CartItem cartItem : cartItemList) {
                totalProducts = totalProducts + cartItem.Quantity;
                productIdSet.add(cartItem.Product2Id);
                productIdQuantiyMap.put(cartItem.Product2Id, cartItem.Quantity);
            }

            totalProducts = totalProducts + quantityToAdd;

            CQRList = [SELECT Value__c, ErrorMessage__c FROM CartQuantityRule__c
                WHERE Type__c = 'Cart' AND WebStoreId__c = :cart.WebStoreId LIMIT 1];
            if (CQRList.size () == 1) {
                if (totalProducts > CQRList[0].Value__c) {
                    output = CQRList[0].ErrorMessage__c;
                }
            }
        }


        // 3 Validate Cart Products ~ limits per product
        if (output.length() == 0 && productId != null) {
            CQRList = [SELECT Value__c, ErrorMessage__c, ProductId__c FROM CartQuantityRule__c
                WHERE Type__c = 'Product' AND WebStoreId__c = :cart.WebStoreId AND ProductId__c = :productId];
            
            if (!CQRList.isEmpty()) {
                CartQuantityRule__c cqr = CQRList[0];
                Decimal currentQuantity = productIdQuantiyMap.containsKey(productId) ? productIdQuantiyMap.get(productId) : 0;
                Decimal totalQuantity = currentQuantity + quantityToAdd;
                
                if (totalQuantity > cqr.Value__c) {
                    output = cqr.ErrorMessage__c;
                }
            }
        } else if (output.length() == 0) {
            CQRList = [SELECT Value__c, ErrorMessage__c, ProductId__c FROM CartQuantityRule__c
                WHERE Type__c = 'Product' AND WebStoreId__c = :cart.WebStoreId AND ProductId__c IN :productIdQuantiyMap.keySet()];
            for (CartQuantityRule__c cqr : CQRList) {
                if (productIdQuantiyMap.get(cqr.ProductId__c) > cqr.Value__c) {
                    output = cqr.ErrorMessage__c;
                }
            }
            output = output.trim();
        }


        // 4 Validate Cart Special Products
        // get special product IDs, filter by cart items product
        // check if cart contains any, if so check if any purchased in the past month
        if (output.length() == 0) {
            Set<String> specialProductIdSet = new Set<String>();
            Map<String, Decimal> specialprodIdQtyLimitMap = new Map<String, Decimal>();
            Map<String, String> productIdErrorMap = new Map<String, String>();

            Set<String> productsToCheck = new Set<String>(productIdQuantiyMap.keySet());
            if (productId != null && !productsToCheck.contains(productId)) {
                productsToCheck.add(productId);
            }

            CQRList = [SELECT Value__c, ErrorMessage__c, ProductId__c FROM CartQuantityRule__c
                WHERE Type__c = 'Special Product' AND WebStoreId__c = :cart.WebStoreId 
                AND ProductId__c IN :productsToCheck];
            for (CartQuantityRule__c cqr : CQRList) {
                specialProductIdSet.add(cqr.ProductId__c);
                productIdErrorMap.put(cqr.ProductId__c, cqr.ErrorMessage__c);
                specialprodIdQtyLimitMap.put(cqr.ProductId__c, cqr.Value__c);
            }

            // check the current month's orders
            if (specialProductIdSet.size() > 0) {
                Datetime firstDayTimeOfMonth = System.today().toStartOfMonth();

                List<OrderItemSummary> oisList = new List<OrderItemSummary>();

                if (!Test.isRunningTest()) {
                    oisList = [ SELECT Id, Product2Id
                        FROM OrderItemSummary
                        WHERE OrderSummary.OwnerId = :cart.OwnerId AND OrderSummary.CreatedDate >= :firstDayTimeOfMonth
                        AND Product2Id IN :specialProductIdSet];
                } else {
                    oisList = [ SELECT Id, Product2Id
                        FROM OrderItemSummary
                        WHERE OrderSummary.OwnerId = :cart.OwnerId AND OrderSummary.OrderedDate >= :firstDayTimeOfMonth
                        AND Product2Id IN :specialProductIdSet];
                }

                if (oisList.size() > 0) {
                    for (OrderItemSummary ois : oisList) {
                        output = output + productIdErrorMap.get(ois.Product2Id);
                        specialProductIdSet.remove(ois.Product2Id);
                    }
                }
                // review remaining special products that have not been purchased this month
                for (String specialProductId : specialProductIdSet) {
                    Decimal currentQuantity = productIdQuantiyMap.containsKey(specialProductId) ? 
                    productIdQuantiyMap.get(specialProductId) : 0;
                    if (specialProductId == productId) {
                        currentQuantity += quantityToAdd;
                    }
                    if (currentQuantity > specialprodIdQtyLimitMap.get(specialProductId)) {
                        output = output + productIdErrorMap.get(specialProductId);
                    }
                }
            }
            output = output.trim();
        }

        return output;
    }

    /**
     * @return El ID de la tienda web como String
     */
    private static String getWebStoreId() {
        try {
            // Obtener el ID de la tienda web desde el contexto actual
            WebStoreNetwork wsn = [SELECT WebStoreId FROM WebStoreNetwork 
                    WHERE NetworkId = :Network.getNetworkId() LIMIT 1];
            return wsn.WebStoreId;
        } catch (Exception e) {
            throw new AuraHandledException('Error getting WebStoreId: ' + e.getMessage());
        }
    }
    
    /**
     * @return El ID de la cuenta efectiva como String
     */
    private static String getUserEffectiveAccountId() {
        try {
            // Para usuarios de comunidad, devuelve su AccountId
            String userId = UserInfo.getUserId();
            User currentUser = [SELECT AccountId FROM User WHERE Id = :userId LIMIT 1];
            return currentUser.AccountId;
        } catch (Exception e) {
            throw new AuraHandledException('Error getting the ID of effective account: ' + e.getMessage());
        }
    }
}