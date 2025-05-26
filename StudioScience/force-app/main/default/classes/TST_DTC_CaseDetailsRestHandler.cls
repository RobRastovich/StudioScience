@isTest
public class TST_DTC_CaseDetailsRestHandler {
	
    @testSetup
    static void setUpTestData() {        
        Case newCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        newCase.Status = 'IN Progress';
        newCase.Sub_Status__c = 'Reshipment initiated';
        newCase.How_can_we_help__c = '';
        newCase.AdditionalInformation__c = '';
        newCase.Email_Address__c='test@gmail.com';
        newCase.Program_Subscription__c='test';
        newCase.Brand__c = 'test';
        insert newCase;
        
    }
    
    @isTest
    private static void testGetCaseDetails() {
        Case caseDetail = [SELECT id, OrderID__c, Email_Address__c,Brand__c, Program_Subscription__c, Status, Sub_Status__c 
                                FROM Case][0];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/retrieveCasedetails/';
        
        req.addParameter('email', caseDetail.Email_Address__c);
        req.addParameter('brand', caseDetail.Program_Subscription__c);
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTC_CaseDetailsRestHandler.getCaseDetails();
        Test.stopTest();
        DTC_CaseDetailsResponseWrapper responseBody = (DTC_CaseDetailsResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                            DTC_CaseDetailsResponseWrapper.class);
        System.assertEquals(responseBody.result, DTC_Constants.SUCCESS, 'Response is expected to be success instead of failure.');
    }
    
    @isTest
    private static void testGetCaseDetailsReturnsNoRecord() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/retrieveCasedetails/';
        req.addParameter('email', 'test@testemail.com');
        req.addParameter('brand', 'test');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTC_CaseDetailsRestHandler.getCaseDetails();
        Test.stopTest();
        
        DTC_CaseDetailsResponseWrapper responseBody = (DTC_CaseDetailsResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                            DTC_CaseDetailsResponseWrapper.class);
        System.assertEquals(DTC_Constants.FAILURE, responseBody.result, 'Response is expected to be failure instead of success.');
    }
    
    @isTest
    private static void testGetCaseDetailsWhenEmailValidationFails() {
        Case caseDetail = [SELECT id, OrderID__c, Email_Address__c,Brand__c, Program_Subscription__c, Status, Sub_Status__c 
                                FROM Case][0];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/retrieveCasedetails/';
        
        req.addParameter('email', 'test');
        req.addParameter('brand', caseDetail.Program_Subscription__c);
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTC_CaseDetailsRestHandler.getCaseDetails();
        Test.stopTest();
        DTC_CaseDetailsResponseWrapper responseBody = (DTC_CaseDetailsResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                            DTC_CaseDetailsResponseWrapper.class);
        System.assertEquals(DTC_Constants.VALIDATION_FAILS, responseBody.result, 'Response is expected to be validation failure.');
    }
    
    @isTest
    private static void testGetCaseDetailsWhenOnlyValueOfEmailInCorrectData() {
        Case caseDetail = [SELECT id, OrderID__c, Email_Address__c,Brand__c, Program_Subscription__c, Status, Sub_Status__c 
                                FROM Case][0];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/retrieveCasedetails/';
        req.addParameter('email', caseDetail.Email_Address__c);
        req.addParameter('brand','');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTC_CaseDetailsRestHandler.getCaseDetails();
        Test.stopTest();
        DTC_CaseDetailsResponseWrapper responseBody = (DTC_CaseDetailsResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                            DTC_CaseDetailsResponseWrapper.class);
       System.assertEquals(DTC_Constants.FAILURE,responseBody.result, 'Response is expected to be failure.');
    }
    
    
    
    @isTest
    private static void testGetCaseDetailsWhenOnlyValueOfBrandInCorrectData() {
        Case caseDetail = [SELECT id, OrderID__c, Email_Address__c,Brand__c, Program_Subscription__c, Status, Sub_Status__c 
                                FROM Case][0];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/retrieveCasedetails/';
        req.addParameter('brand', 'caseDetail.Program_Subscription__c');
        req.addParameter('email','');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTC_CaseDetailsRestHandler.getCaseDetails();
        Test.stopTest();
        DTC_CaseDetailsResponseWrapper responseBody = (DTC_CaseDetailsResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                            DTC_CaseDetailsResponseWrapper.class);
        System.assertEquals(DTC_Constants.FAILURE,responseBody.result, 'Response is expected to be failure.');
    }
    
    @isTest
    private static void testGetCaseDetailsWhenNoValuePassed() {
        Case caseDetail = [SELECT id, OrderID__c, Email_Address__c,Brand__c, Program_Subscription__c, Status, Sub_Status__c 
                                FROM Case][0];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/retrieveCasedetails/';
        
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTC_CaseDetailsRestHandler.getCaseDetails();
        Test.stopTest();
        DTC_CaseDetailsResponseWrapper responseBody = (DTC_CaseDetailsResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                            DTC_CaseDetailsResponseWrapper.class);
       System.assertEquals(DTC_Constants.VALIDATION_FAILS,responseBody.result, 'Response is expected to be validation failure.');
    }
}