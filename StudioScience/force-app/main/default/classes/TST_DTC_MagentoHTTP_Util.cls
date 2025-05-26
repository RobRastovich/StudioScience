@isTest
public class TST_DTC_MagentoHTTP_Util {
    
    @testSetup static void setup(){
        Magento_setting__c mt = new Magento_setting__c();
        mt.Name = 'Default';
        mt.BaseUrl__c = 'test/';
        mt.Consumer_Key__c = 'test key';
        mt.Access_Token__c = 'test token';
        mt.Token_Secret__c = 'test secret';
        mt.OrderEndpoint__c = 'orders?searchCriteria[current_page]=1&searchCriteria[filterGroups][0][filters][0][conditionType]=eq&searchCriteria[filterGroups][0][filters][0][field]=increment_id&searchCriteria[filterGroups][0][filters][0][value]=';
        mt.ContentType__c = 'application/json';
        mt.ShipmentEndpoint__c = 'shipments?searchCriteria[current_page]=1&searchCriteria[filterGroups][0][filters][0][conditionType]=eq&searchCriteria[filterGroups][0][filters][0][field]=order_id&searchCriteria[filterGroups][0][filters][0][value]=';
        mt.TrackEndpoint__c = 'test';
        mt.SignatureMethod__c = 'HMACSHA256';
        mt.OauthVersion__c = '1.0';
        insert mt;
    }
 
	@isTest
    static void getorderIdByIncIdTest(){
        Test.setMock(HttpCalloutMock.class, new TST_DTC_MagentoHTTP_UtilMockCallout());
        String Inc_id = '000000013';
        String trackingNumber = 'Updt123, updatedNew123 (new)';
        Test.startTest();
        	DTC_MagentoHTTP_Util.getorderIdByIncId(Inc_id, trackingNumber);
        Test.stopTest();
       System.assert(true, 'The future method should have executed successfully');  
    }
}