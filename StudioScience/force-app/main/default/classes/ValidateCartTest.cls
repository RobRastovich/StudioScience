@isTest
public class ValidateCartTest {


// test setup
    // create two users
// create two BuyerGroups, one for each region
    // TODO: create a cart for each user, and add two items to it

    // create Order Sumary, test for Segovia buyer group + sprecial products?
    // TODO: test for Segovia buyer group

    @IsTest(SeeAllData=true)
    static void testMadridCart01() {

        setupTestData();
        String output  = '';

        Test.startTest();
        Product2 makers = [SELECT Id, Name, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit = 'MAKERS' LIMIT 1];
        Product2 makers46 = [SELECT Id, Name, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit = 'MAKERS46' LIMIT 1];
        Product2 makersCA = [SELECT Id, Name, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit = 'MAKERS_CA' LIMIT 1];
        Product2 makersPS = [SELECT Id, Name, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit = 'MAKERS_PS' LIMIT 1];
        Product2 makers18 = [SELECT Id, Name, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit = 'MAKERS_18YR' LIMIT 1];

        WebCart webCart = [SELECT Id, OwnerId FROM WebCart WHERE Name = 'Jackson Cart' LIMIT 1];
        CartDeliveryGroup cartDeliveryGroup = [SELECT Id FROM CartDeliveryGroup WHERE Name = 'Jackson Default Delivery' LIMIT 1];

        addCartItem(webCart.Id, cartDeliveryGroup.Id,  makers, 23.99, 2.0);
        // addCartItem(webCart.Id, cartDeliveryGroup.Id,  makers46, 32.99, 3.0);
        // addCartItem(webCart.Id, cartDeliveryGroup.Id,  makersPS, 74.99, 1.0);
        // addCartItem(webCart.Id, cartDeliveryGroup.Id,  makersCA, 259.99, 1.0);

        OrderSummary orderSummary = [SELECT OrderedDate FROM OrderSummary WHERE OwnerId = :webCart.OwnerId ORDER BY OrderedDate DESC LIMIT 1];
        output = validateCart.validateCart(webCart.Id);
        System.assert(output.length() > 0, 'There is validation error: ' + output);

        Datetime orderedDate = orderSummary.OrderedDate;
        orderSummary.OrderedDate = orderedDate.addDays(-8);
        update orderSummary;

        output = validateCart.validateCart(webCart.Id);
        System.assertEquals(0, output.length(), 'There is no validation error: ' + output);

        // more than six items
        deleteCartItems(webCart.Id);
        addCartItem(webCart.Id, cartDeliveryGroup.Id,  makers46, 32.99, 5.0);
        addCartItem(webCart.Id, cartDeliveryGroup.Id,  makers, 23.99, 3.0);
        output = validateCart.validateCart(webCart.Id);

        System.assertEquals(output, 'You may only purchase six items per cart', 'More than six items in cart');

        // Product limits
        deleteCartItems(webCart.Id);
        addCartItem(webCart.Id, cartDeliveryGroup.Id,  makers, 23.99, 3.0);
        addCartItem(webCart.Id, cartDeliveryGroup.Id,  makersCA, 259.99, 2.0);
        output = validateCart.validateCart(webCart.Id);
        System.assertEquals(output, 'You can only purchase one Maker’s Mark Cellar Aged Bourbon per order.', 'Maker’s Mark Cellar Aged Limit 1');


        Datetime newOrderDateTime = Date.today().toStartOfMonth();
        orderSummary.OrderedDate = newOrderDateTime;
        update orderSummary;

        // 4 Validate Cart Special Products
        deleteCartItems(webCart.Id);
        addCartItem(webCart.Id, cartDeliveryGroup.Id,  makersPS, 74.99, 1.0);
        output = validateCart.validateCart(webCart.Id);
        System.assert(output.length() > 0, 'There is validation error: ' + output);

        newOrderDateTime = Date.today().toStartOfMonth().addDays(-15);
        orderSummary.OrderedDate = newOrderDateTime;
        update orderSummary;

        deleteCartItems(webCart.Id);
        addCartItem(webCart.Id, cartDeliveryGroup.Id,  makersPS, 74.99, 1.0);
        output = validateCart.validateCart(webCart.Id);
        System.assert(output.length() == 0, 'There are no validation errors. The special product Maker’s Mark Private Selection was purchased last month: ' + output);

/*
        // move OrderedDate three days into the month
        newOrderDateTime = Date.today().toStartOfMonth().addDays(3);
        orderSummary.OrderedDate = newOrderDateTime;
        update orderSummary;
        deleteCartItems(webCart.Id);
        addCartItem(webCart.Id, cartDeliveryGroup.Id,  makersPS, 74.99, 1.0);
        output = validateCart.validateCart(webCart.Id);
        System.assert(output.length() > 0, 'There is validation error: ' + output);

        // Error System.AssertException: Assertion Failed: There are no validation errors:
        // You can only order once seven days startOfWeekDateTime 2025-03-30 00:00:00 OrderedDate 2025-04-04 00:00:00
*/

        deleteCartItems(webCart.Id);
        addCartItem(webCart.Id, cartDeliveryGroup.Id,  makers18, 259.99, 1.0);
        output = validateCart.validateCart(webCart.Id);
        System.assert(output.length() == 0, 'There are no validation errors: ' + output);

        // Makers 18 special product
        deleteCartItems(webCart.Id);
        addCartItem(webCart.Id, cartDeliveryGroup.Id,  makers18, 259.99, 2.0);
        output = validateCart.validateCart(webCart.Id);
        System.assert(output.length() > 0, 'There is validation error: ' + output);

        Test.stopTest();

    }


    @IsTest(SeeAllData=true)
    static void testSegoviaCart01() {
        String output  = '';

        setupTestData();

        Test.startTest();

        Product2 makers = [SELECT Id, Name, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit = 'MAKERS' LIMIT 1];

        WebCart webCart = [SELECT Id, OwnerId FROM WebCart WHERE Name = 'George Cart' LIMIT 1];
        CartDeliveryGroup cartDeliveryGroup = [SELECT Id FROM CartDeliveryGroup WHERE Name = 'George Default Delivery' LIMIT 1];

        OrderSummary orderSummary = [SELECT OrderedDate FROM OrderSummary WHERE OwnerId = :webCart.OwnerId ORDER BY OrderedDate DESC LIMIT 1];
        output = validateCart.validateCart(webCart.Id);



        // OrderedDate before the 20th of last month
        date lastMonth20Date = Date.today();
        Datetime newOrderDateTime = date.newInstance(lastMonth20Date.year(), lastMonth20Date.month() - 1, 10);
        orderSummary.OrderedDate = newOrderDateTime;
        update orderSummary;

        addCartItem(webCart.Id, cartDeliveryGroup.Id,  makers, 23.99, 1.0);
        output = validateCart.validateCart(webCart.Id);
        System.assert(output.length() == 0, 'There are no validation errors: ' + output);

        // OrderedDate after the 20th of last month
        newOrderDateTime = date.newInstance(lastMonth20Date.year(), lastMonth20Date.month() - 1, 25);
        orderSummary.OrderedDate = newOrderDateTime;
        update orderSummary;

        output = validateCart.validateCart(webCart.Id);
        System.assert(output.length() > 0, 'There is validation error: ' + output);



        Test.stopTest();

    }






    static void addCartItem(String cartId, String cartDeliveryGroupId, Product2 product, Decimal salesPrice, Decimal quantity) {
        CartItem cartItem = new CartItem(
            CartId = cartId, CartDeliveryGroupId = cartDeliveryGroupId, Type = 'Product',
            Name = product.Name,  Product2Id = product.Id, Sku = product.StockKeepingUnit,
            SalesPrice = salesPrice, Quantity = quantity,  TotalPrice = salesPrice * quantity
            );
        insert cartItem;
    }

    static void deleteCartItems(String cartId) {
        List<CartItem> cartItems = [SELECT Id FROM CartItem WHERE CartId = :cartId ];
        delete cartItems;
    }

    static void deleteCartDeliveryGroupMethods(String cartId) {
        List<CartDeliveryGroupMethod> cartDeliveryGroupMethods = [SELECT Id FROM CartDeliveryGroupMethod WHERE WebCartId = :cartId ];
        delete cartDeliveryGroupMethods;
    }


    // see https://developer.salesforce.com/forums/ForumsMain?id=906F0000000BYaZIAW
    public static User createTestUser(Id roleId, Id profID, String fName, String lName) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;
        User user = new User(firstname = fName, lastName = lName,
                email = fName + '.' + lName + '-' + uniqueName + '@test' + orgId + '.com',
                Username = fName + '.' + lName + '-' + uniqueName + '@test' + orgId + '.com', Alias = uniqueName.substring(18, 23),
                EmailEncodingKey = 'ISO-8859-1',  TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US',
                ProfileId = profId, UserRoleId = roleId);
        return user;
    }



    static void setupTestData() {
        User thisUser = [ SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        UserRole userRole = new UserRole(Name = 'Finance Approver');
        System.runAs(thisUser) { insert userRole;}

        User jacksonBrowne = createTestUser(userRole.Id, profile.Id, 'Jackson', 'Browne');
        System.runAs (thisUser) { insert jacksonBrowne;}

        User georgeStrait = createTestUser(userRole.Id, profile.Id, 'George', 'Strait');
        System.runAs (thisUser) { insert georgeStrait;}

        Account jacksonAccount = new Account(Name='Jackson Account');
        insert jacksonAccount;

        Account georgeAccount = new Account(Name='George Account');
        insert georgeAccount;


        // Enable Account as buyer account
        BuyerAccount jacksonBA = new BuyerAccount(Name = jacksonAccount.Name, BuyerId = jacksonAccount.Id, BuyerStatus = 'Active', CommerceType = 'Buyer', IsActive = true);
        insert jacksonBA;

        BuyerAccount georgeBA = new BuyerAccount(Name = georgeAccount.Name, BuyerId = georgeAccount.Id, BuyerStatus = 'Active', CommerceType = 'Buyer', IsActive = true);
        insert georgeBA;

        BuyerGroup madridBG = new BuyerGroup(Name = 'Madrid Buyer Group', Role = 'AccountBased');
        insert madridBG;
        BuyerGroup segoviaBG = new BuyerGroup(Name = 'Segovia Buyer Group', Role = 'AccountBased');
        insert segoviaBG;

        BuyerGroupMember madridBGM1 = new BuyerGroupMember(BuyerId = jacksonAccount.Id, BuyerGroupId = madridBG.Id);
        insert madridBGM1;
        BuyerGroupMember segoviaBGMember1 = new BuyerGroupMember(BuyerId = georgeAccount.Id, BuyerGroupId = segoviaBG.Id);
        insert segoviaBGMember1;


        WebStore webStore = new WebStore(Name = 'TestWebStore', DefaultLanguage='en_GB', Type = 'B2C');
        insert webStore;

        WebCart jacksonCart = new WebCart(Name = 'Jackson Cart', WebStoreId = webStore.Id, AccountId = jacksonAccount.Id);
        System.runas(jacksonBrowne) { insert jacksonCart;}

        WebCart georgeCart = new WebCart(Name='George Cart', WebStoreId = webStore.Id, AccountId = georgeAccount.Id);
        System.runas(georgeStrait) { insert georgeCart;}

        CartDeliveryGroup jacksonCartDeliveryGroup = new CartDeliveryGroup(CartId=jacksonCart.Id, Name = 'Jackson Default Delivery');
        insert jacksonCartDeliveryGroup;

        CartDeliveryGroup georgeCartDeliveryGroup = new CartDeliveryGroup(CartId = georgeCart.Id, Name = 'George Default Delivery');
        insert georgeCartDeliveryGroup;

        Product2 makers = new Product2(Name = 'Maker’s Mark Kentucky Straight Bourbon', StockKeepingUnit = 'MAKERS');
        insert makers;
        Product2 makers46 = new Product2(Name = 'Maker’s Mark 46 French Oak Bourbon', StockKeepingUnit = 'MAKERS46');
        insert makers46;

        Product2 makersCA = new Product2(Name = 'Maker’s Mark Cellar Aged Bourbon', StockKeepingUnit = 'MAKERS_CA');
        insert makersCA;

        Product2 makersPS = new Product2(Name = 'Maker’s Mark Private Selection', StockKeepingUnit = 'MAKERS_PS');
        insert makersPS;
        Product2 makers18 = new Product2(Name = 'Maker’s Mark 18 Year', StockKeepingUnit = 'MAKERS_18YR');
        insert makers18;


        CartQuantityRule__c CQR1 = new CartQuantityRule__c (Name = 'Cart Item Limit 6.', Type__c = 'Cart', WebStoreId__c = webStore.Id
            , Value__c = 6, ErrorMessage__c = 'You may only purchase six items per cart');
        insert CQR1;

        CartQuantityRule__c CQR2 = new CartQuantityRule__c (Name = 'Maker’s Mark Cellar Aged Limit 1', Type__c = 'Product', WebStoreId__c = webStore.Id
            , ProductId__c = makersCA.Id, Value__c = 1, ErrorMessage__c = 'You can only purchase one Maker’s Mark Cellar Aged Bourbon per order.');
        insert CQR2;

        CartQuantityRule__c CQR3 = new CartQuantityRule__c (Name = 'Maker’s Mark Private Selection', Type__c = 'Special Product', WebStoreId__c = webStore.Id
            , ProductId__c = makersPS.Id, Value__c = 1, ErrorMessage__c = 'You can only purchase the special product Maker’s Mark Private Selection, once per month..');
        insert CQR3;

        CartQuantityRule__c CQR4 = new CartQuantityRule__c (Name = 'Maker’s Mark 18 Year', Type__c = 'Special Product', WebStoreId__c = webStore.Id
            , ProductId__c = makers18.Id, Value__c = 1, ErrorMessage__c = 'You can only purchase the special product Maker’s Mark 18 Year, once per month..');
        insert CQR4;

        CartQuantityRule__c CQR5 = new CartQuantityRule__c (Name = 'One Order Per Week', Type__c = 'Order', WebStoreId__c = webStore.Id
            , Value__c = 1, ErrorMessage__c = 'You can only order once seven days', BuyerGroupId__c = madridBG.Id);
        insert CQR5;

        // Order rule for Segovia
        CartQuantityRule__c CQR6 = new CartQuantityRule__c (Name = 'One Order Per Month', Type__c = 'Order', WebStoreId__c = webStore.Id
            , Value__c = 20, ErrorMessage__c = 'You can only order once per month', BuyerGroupId__c = segoviaBG.Id);
        insert CQR6;


        PricebookEntry makersPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = makers.Id, UnitPrice = 23.99, IsActive = true);
        insert makersPBE;
        PricebookEntry makers46PBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = makers46.Id, UnitPrice = 32.99, IsActive = true);
        insert makers46PBE;
        PricebookEntry makersCAPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = makersCA.Id, UnitPrice = 259.99, IsActive = true);
        insert makersCAPBE;
        PricebookEntry makersPSPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = makersPS.Id, UnitPrice = 74.99, IsActive = true);
        insert makersPSPBE;
        PricebookEntry makers18PBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = makers18.Id, UnitPrice = 374.99, IsActive = true);
        insert makers18PBE;


        Order order1 = new Order( Name = 'Order 1', AccountId = jacksonAccount.Id, Pricebook2Id = Test.getStandardPricebookId()
            , EffectiveDate = Date.today(), OrderedDate = Date.today(), Status = 'Draft');
        System.runas(jacksonBrowne) { insert order1;}

        OrderDeliveryMethod odm1 = new OrderDeliveryMethod(Name = 'Order Delivery Method');
        insert odm1;

        OrderDeliveryGroup orderDeliveryGroup1 =
        new OrderDeliveryGroup( DeliverToName = 'Jackson Brown', DeliverToStreet = '1221 Avenue of the Americas'
            , DeliverToCity = 'New York', DeliverToState = 'NY', DeliverToPostalCode = '10020', DeliverToCountry = 'US'
            , OrderDeliveryMethodId = odm1.Id , OrderId = order1.Id , DesiredDeliveryDate = Date.today());
        insert orderDeliveryGroup1;

        OrderItem orderItem11 = new OrderItem( Product2Id = makersPS.Id, Quantity = 1, ListPrice = makersPSPBE.UnitPrice
            ,UnitPrice = makersPSPBE.UnitPrice, TotalLineAmount = 1 * makersPSPBE.UnitPrice, OrderId = order1.Id, PricebookEntryId = makersPSPBE.Id
            , OrderDeliveryGroupId = orderDeliveryGroup1.Id);
        insert(orderItem11);
        order1.Status = 'Activated';
        update order1;

        ConnectApi.OrderSummaryInputRepresentation osir1 = new ConnectApi.OrderSummaryInputRepresentation();
        osir1.orderId = order1.Id;
        osir1.orderLifeCycleType='UNMANAGED'; // MANAGED = Salesforce OMS Managed orders
        ConnectApi.OrderSummaryOutputRepresentation osor1 = ConnectApi.OrderSummaryCreation.createOrderSummary(osir1);


        // Segovia order
        Order order2 = new Order( Name = 'Order 2', AccountId = georgeAccount.Id, Pricebook2Id = Test.getStandardPricebookId()
            , EffectiveDate = Date.today(), OrderedDate = Date.today(), Status = 'Draft');
        System.runas(georgeStrait) { insert order2;}

        OrderDeliveryMethod odm2 = new OrderDeliveryMethod(Name = 'Order Delivery Method');
        insert odm2;

        OrderDeliveryGroup orderDeliveryGroup2 =
        new OrderDeliveryGroup( DeliverToName = 'George Strait', DeliverToStreet = '300 Alamo Plaza'
            , DeliverToCity = 'San Antonio', DeliverToState = 'TX', DeliverToPostalCode = '78205', DeliverToCountry = 'US'
            , OrderDeliveryMethodId = odm2.Id , OrderId = order2.Id , DesiredDeliveryDate = Date.today());
        insert orderDeliveryGroup2;

        OrderItem orderItem21 = new OrderItem( Product2Id = makers18.Id, Quantity = 1, ListPrice = makers18PBE.UnitPrice
            ,UnitPrice = makers18PBE.UnitPrice, TotalLineAmount = 1 * makers18PBE.UnitPrice, OrderId = order2.Id, PricebookEntryId = makers18PBE.Id
            , OrderDeliveryGroupId = orderDeliveryGroup2.Id);
        insert(orderItem21);

        order2.Status = 'Activated';
        update order2;

        ConnectApi.OrderSummaryInputRepresentation osir2 = new ConnectApi.OrderSummaryInputRepresentation();
        osir2.orderId = order2.Id;
        osir2.orderLifeCycleType='UNMANAGED'; // MANAGED = Salesforce OMS orders
        ConnectApi.OrderSummaryOutputRepresentation osor2 = ConnectApi.OrderSummaryCreation.createOrderSummary(osir2);
    }


}