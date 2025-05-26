@isTest
public class TST_DTC_CaseUpdateTrackingNuRestHandler {
    @testSetup
    static void setUpTestData() {        
        Case newCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        newCase.Status = 'IN Progress';
        newCase.Sub_Status__c = 'Reshipment initiated';
        newCase.How_can_we_help__c = '';
        newCase.AdditionalInformation__c = '';
        insert newCase;
        Case newCase1 = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        newCase1.Status = 'IN Progress';
        newCase1.Sub_Status__c = 'Reshipment initiated';
        newCase1.OrderID__c = 'test1234';
        insert newCase1;
    }
    
    @isTest
    private static void testUpdateCaseTrackingNumberWhenValueOfBothOrderIdAndTrackingNumberInJSONCorrectData() {
        Case caseDetail = [SELECT id, OrderID__c, UPS_Tracking_Number__c, Status, Sub_Status__c 
                                FROM Case][0];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/casesUpdateTrackingNumber/';
        req.httpMethod = 'PATCH';
        String jsonString = '{"orderId" : "'+caseDetail.OrderID__c+'", "trackingNumber" : "12345"}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTC_CaseUpdateTrackingNumberRestHandler.updateCaseTrackingNumber();
        Test.stopTest();
        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                            ResponseWrapper.class);
        System.assertEquals(responseBody.result, DTC_Constants.SUCCESS, 'Response is expected to be success instead of failure.');
    }
    
    @isTest
    private static void testUpdateCaseTrackingNumberWhenValueOfBothOrderIdAndTrackingNumberInJSONWrongData() {
        Case caseDetail = [SELECT Id, OrderID__c, UPS_Tracking_Number__c, Status, Sub_Status__c 
                                FROM Case][0];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/casesUpdateTrackingNumber/';
        req.httpMethod = 'PATCH';
        String jsonString = '{"orderId" : "111", "trackingNumber" : "12345"}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTC_CaseUpdateTrackingNumberRestHandler.updateCaseTrackingNumber();
        Test.stopTest();
        
        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                            ResponseWrapper.class);
        System.assertEquals(responseBody.result, DTC_Constants.FAILURE, 'Response is expected to be failure.'); 
    }
    
    @isTest
    private static void testUpdateCaseTrackingNumberWhenOnlyValueOfOrderIdInJSON() {
        Case caseDetail = [SELECT id, OrderID__c, CaseNumber From Case][0];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/casesUpdateTrackingNumber/';
        req.httpMethod = 'PATCH';
        String jsonString = '{"orderId" : "'+caseDetail.OrderID__c+'", "trackingNumber" : ""}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTC_CaseUpdateTrackingNumberRestHandler.updateCaseTrackingNumber();
        Test.stopTest();
        
        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                            ResponseWrapper.class);
        System.assertEquals(responseBody.result, DTC_Constants.FAILURE, 'Response is expected to be failure.');
    }
    
    @isTest
    private static void testUpdateCaseTrackingNumberWhenOnlyValueOfTrackingNumberInJSON() {
        Case caseDetail = [SELECT id, OrderID__c, CaseNumber From Case][0];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/casesUpdateTrackingNumber/';
        req.httpMethod = 'PATCH';
        String jsonString = '{"orderId" : "", "trackingNumber" : "12345"}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTC_CaseUpdateTrackingNumberRestHandler.updateCaseTrackingNumber();
        Test.stopTest();
        
        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                            ResponseWrapper.class);
        System.assertEquals(responseBody.result, DTC_Constants.FAILURE, 'Response is expected to be failure.');
    }
    
    @isTest
    private static void testUpdateCaseTrackingNumberWhenRequiredFieldIsMissingInJSON() {
        Case caseDetail = [SELECT id, OrderID__c, CaseNumber From Case][0];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/casesUpdateTrackingNumber/';
        req.httpMethod = 'PATCH';
        String jsonString = '{ "trackingNumber" : "12345"}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTC_CaseUpdateTrackingNumberRestHandler.updateCaseTrackingNumber();
        Test.stopTest();
        
        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                            ResponseWrapper.class);
        System.assertEquals(responseBody.result, DTC_Constants.VALIDATION_FAILS, 'Response is expected to be failure.');
    }
    
    @isTest
    private static void testUpdateCaseTrackingNumberException() {
        Case caseDetail = [SELECT id, OrderID__c, How_can_we_help__c, AdditionalInformation__c, UPS_Tracking_Number__c, 
                                Status, Sub_Status__c 
                                FROM Case 
                                WHERE How_can_we_help__c = 'API' 
                                AND 
                                AdditionalInformation__c = 'Membership Cancellation'][0];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/casesUpdateTrackingNumber/';
        req.httpMethod = 'PATCH';
        String jsonString = '{"orderId" : "'+caseDetail.OrderID__c+'", "trackingNumber" : "123456"}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTC_CaseUpdateTrackingNumberRestHandler.updateCaseTrackingNumber();
        Test.stopTest();
        
        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                            ResponseWrapper.class);
        System.assertNotEquals(null, responseBody.result, 'Response is expected to be failure.');
    }
}