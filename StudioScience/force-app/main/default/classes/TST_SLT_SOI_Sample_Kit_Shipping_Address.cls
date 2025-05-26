@isTest
private class TST_SLT_SOI_Sample_Kit_Shipping_Address {
    @testSetup
    static void testDataSetup() {
        TST_TestDataFactory.createshippingAddress(true);
    }
    
    @isTest
    private static void testGetShipAddressRecords() {
        List<Sample_Kit_Shipping_Address__c> addressList = new List<Sample_Kit_Shipping_Address__c>();
        
        Test.startTest();
            addressList = SLT_SOI_Sample_Kit_Shipping_Address.getShipAddressRecords(SOI_Constants.COUNTRY_USA);
        Test.stopTest();
        
        System.assertEquals(true, addressList.size() > 0, 'Should return Shipping Address records');
        System.assertEquals('Test Shipping Address', addressList[0].Name, 'Name of Record should be Test Shipping Address');
    }
    
    @isTest
    private static void testFilterOfficeValueByStateList() {
        List<Sample_Kit_Shipping_Address__c> addressList = new List<Sample_Kit_Shipping_Address__c>();
        
        Test.startTest();
            addressList = SLT_SOI_Sample_Kit_Shipping_Address.filterOfficeValueByStateList(SOI_Constants.COUNTRY_USA,
                             SOI_Constants.STATE_AR);
        Test.stopTest();
        
        System.assertEquals(true, addressList.size() > 0, 'Should return Shipping Address records');
        System.assertEquals('Test Shipping Address', addressList[0].Name, 'Name of Record should be Test Shipping Address');
    }
}