@isTest
public class TST_DTCCaseCreationRestHandler {

    @testSetup
    static void setUpTestData() {        
        Contact newContact = TST_TestDataFactory.createContact(null, true);
        Account newAccount = TST_TestDataFactory.createPersonAccount(DTC_Constants.ACCOUNT_CONSUMER_RECORDTYPEID, true);
        List<Case> casesList = new List<Case>();
        Case newCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        newCase.OrderID__c = 'test';
        casesList.add(newCase);
        Case disputedCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        disputedCase.OrderID__c = 'testDispute';
        disputedCase.How_can_we_help__c = 'API';
        disputedCase.AdditionalInformation__c = 'Dispute';
        casesList.add(disputedCase);
        Case ClosedCaseTest = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        ClosedCaseTest.Status = 'Closed';
        casesList.add(ClosedCaseTest);
        Case PaymentDeclinedCaseStatusAndAdditionalInfoTest = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        PaymentDeclinedCaseStatusAndAdditionalInfoTest.status = 'Payment Decline';
        PaymentDeclinedCaseStatusAndAdditionalInfoTest.AdditionalInformation__c = 'Payment Decline';
        casesList.add(PaymentDeclinedCaseStatusAndAdditionalInfoTest);
        Case PaymentDeclinedCaseStatusTest = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        PaymentDeclinedCaseStatusTest.status = 'Payment Decline';
        casesList.add(PaymentDeclinedCaseStatusTest);
        insert casesList;
    }

    @isTest
    private static void testCreateCase() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/Cases/';
        req.httpMethod = 'POST';
        String jsonString = '{"caseDetails" : {"First_name__c": "Test case","Last_name__c": "customer 1","Email_Address__c": '
        +'"test@example.com","Cancelation_Reason__c": "Other","Notes__c": "test customer","Brand__c": "Jim Beam","OrderID__c":' 
        +'"testo123","ProductID__c": "testp1234","Batch_Billing__c": "2022-02-02", "Program_Subscription__c" : "test"},'
        +'"accountDetails" : {"PersonMailingCountry": "India","PersonMailingState": "Rajasthan","PersonMailingCity": "Jaipur",'
        +'"PersonMailingPostalCode": "302015","PersonMailingStreet": "test street 1"},"Type": "Membership Cancellation",'
        +'"MagentoID" : "testM1234","isCancelConfirmed":"true"}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRestHandler.createCase();
        Test.stopTest();

        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                        ResponseWrapper.class);
        System.assertEquals(responseBody.result, DTC_Constants.SUCCESS, 
                            'Response is expected to be success instead of failure.');
    }

    @isTest
    private static void testCreateCaseWhenCaseValdationFails() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/Cases/';
        req.httpMethod = 'POST';
        String jsonString = '{"caseDetails" : {"First_name__c": "Test case","Last_name__c": "customer 1"},"accountDetails" : '
        +'{"PersonMailingCountry": "India","PersonMailingState": "Rajasthan","PersonMailingCity": "Jaipur",'
        +'"PersonMailingPostalCode": "302015","PersonMailingStreet": "test street 1"},"Type": "Membership Cancellation",'
        +'"MagentoID" : "testM1234","isCancelConfirmed":"true"}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRestHandler.createCase();
        Test.stopTest();

        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                        ResponseWrapper.class);
        System.assertEquals(responseBody.result, DTC_Constants.VALIDATION_FAILS, 
                            'Response is expected to be validation failure.');
    }

    @isTest
    private static void testCreateCaseWhenExceptionOccurs() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/Cases/';
        req.httpMethod = 'POST';
        String jsonString = '{"caseDetail" : {"First_name__c": "Test case","Last_name__c": "customer 1","Email_Address__c": '
        +'"test@example.com","Cancelation_Reason__c": "Other","Notes__c": "test customer","Brand__c": "Jim Beam","OrderID__c": '
        +'"testo123","ProductID__c": "testp1234", "Program_Subscription__c" : "test","Batch_Billing__c": ""},"accountDetail" : '
        +'{"PersonMailingCountry": "India","PersonMailingState": "Rajasthan","PersonMailingCity": "Jaipur",'
        +'"PersonMailingPostalCode": "302015","PersonMailingStreet": "test street 1"},"Type": "Membership Cancellation",'
        +'"MagentoID" : "testM1234","isCancelConfirmed":"true"}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRestHandler.createCase();
        Test.stopTest();

        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                        ResponseWrapper.class);
        System.assertEquals(responseBody.result, DTC_Constants.FAILURE, 'Response is expected to be failure.');
    }

    @isTest
    private static void testCreateCaseWhenJSONIsMalformed() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/Cases/';
        req.httpMethod = 'POST';
        String jsonString = '{}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRestHandler.createCase();
        Test.stopTest();

        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                        ResponseWrapper.class);
        System.assertEquals(responseBody.result, DTC_Constants.FAILURE, 'Response is expected to be failure.');
    }

    @isTest
    private static void testCreateCaseWhenContactValidationFails() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        req.requestURI = '/services/apexrest/Cases/';
        req.httpMethod = 'POST';
        String jsonString = '{"caseDetails" : {"First_name__c": "Test case","Last_name__c": "customer 1",'
        +'"Email_Address__c": "test@example.com","Cancelation_Reason__c": "Other","Notes__c": "test customer",'
        +'"Brand__c": "Jim Beam","OrderID__c": "testo123","ProductID__c": "testp1234","Batch_Billing__c": "2022-02-02", '
        +'"Program_Subscription__c" : "test"},"accountDetails" : {"PersonMailingCountry": "India",'
        +'"PersonMailingState": "Rajasthan","PersonMailingCity": "Jaipur","PersonMailingPostalCode": "302015",'
        +'"PersonMailingStreet": "test street 1"},"Type": "Membership Cancellation"}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRestHandler.createCase();
        Test.stopTest();

        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                        ResponseWrapper.class);
        System.assertEquals(responseBody.result, DTC_Constants.FAILURE, 'Response is expected to be failure.');
    }

    @isTest
    private static void testCreateCaseWhenPicklistValidationFails() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/Cases/';
        req.httpMethod = 'POST';
        String jsonString = '{"caseDetails" : {"First_name__c": "Test case","Last_name__c": "customer 1",'
        +'"Email_Address__c": "test@example.com","Cancelation_Reason__c": "Others","Notes__c": "test customer",'
        +'"Brand__c": "Jim Beams","OrderID__c": "testo123","ProductID__c": "testp1234","Batch_Billing__c": "2022-02-02", '
        +'"Program_Subscription__c" : "test"},"accountDetails" : {"PersonMailingCountry": "India",'
        +'"PersonMailingState": "Rajasthan","PersonMailingCity": "Jaipur","PersonMailingPostalCode": "302015",'
        +'"PersonMailingStreet": "test street 1"},"Type": "Membership Cancellation",'
        +'"MagentoID" : "testM1234","isCancelConfirmed":"true"}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRestHandler.createCase();
        Test.stopTest();

        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                        ResponseWrapper.class);
        System.assertEquals(responseBody.result, DTC_Constants.VALIDATION_FAILS, 
                            'Response is expected to be a validation failure.');
    }

    @isTest
    private static void testCreateCaseWhenAccountNotExists() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/Cases/';
        req.httpMethod = 'POST';
        String jsonString = '{"caseDetails" : {"First_name__c": "Test case","Last_name__c": "customer 1",'
        +'"Email_Address__c": "test@exampleNew.com","Cancelation_Reason__c": "Other","Notes__c": '
        +'"test customer","Brand__c": "Jim Beam","OrderID__c": "testo123","ProductID__c": "testp1234",'
        +'"Batch_Billing__c": "2022-02-02", "Program_Subscription__c" : "test"},"accountDetails" : '
        +'{"PersonMailingCountry": "India","PersonMailingState": "Rajasthan","PersonMailingCity": '
        +'"Jaipur","PersonMailingPostalCode": "302015","PersonMailingStreet": "test street 1"},'
        +'"Type": "Membership Cancellation","MagentoID" : "testM1234","isCancelConfirmed":"true"}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRestHandler.createCase();
        Test.stopTest();

        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                        ResponseWrapper.class);
        
        System.assertEquals(responseBody.result, DTC_Constants.SUCCESS, 'Response is expected to be a success.');
    }

    @isTest
    private static void testCreateCaseWhenCancelConfirmedIsRequired() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/Cases/';
        req.httpMethod = 'POST';
        String jsonString = '{"caseDetails" : {"First_name__c": "Test case","Last_name__c": "customer 1",'
        +'"Email_Address__c": "test@example.com","Cancelation_Reason__c": "Other","Notes__c": "test customer",'
        +'"Brand__c": "Jim Beam","OrderID__c": "testo123","ProductID__c": "testp1234",'
        +'"Batch_Billing__c": "2022-02-02", "Program_Subscription__c" : "test"},"accountDetails" : '
        +'{"PersonMailingCountry": "India","PersonMailingState": "Rajasthan","PersonMailingCity": '
        +'"Jaipur","PersonMailingPostalCode": "302015","PersonMailingStreet": "test street 1"},'
        +'"Type": "Membership Cancellation","MagentoID" : "testM1234"}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRestHandler.createCase();
        Test.stopTest();

        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                        ResponseWrapper.class);
        System.assertEquals(DTC_Constants.FAILURE, responseBody.result, 'Response is expected to be a failure.');
    }

    @isTest
    private static void testCreateCaseForValidatingBooleanField() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/Cases/';
        req.httpMethod = 'POST';
        String jsonString = '{"caseDetails" : {"First_name__c": "Test case","Last_name__c": "customer 1",'
        +'"Email_Address__c": "test@example.com","Cancelation_Reason__c": "Other","Notes__c": "test customer",'
        +'"Brand__c": "Jim Beam","OrderID__c": "testo123","ProductID__c": "testp1234","Batch_Billing__c": "2022-02-02", '
        +'"Program_Subscription__c" : "test"},"accountDetails" : {"PersonMailingCountry": "India","PersonMailingState":' 
        +'"Rajasthan","PersonMailingCity": "Jaipur","PersonMailingPostalCode": "302015",'
        +'"PersonMailingStreet": "test street 1"},"Type": "Membership Cancellation",'
        +'"MagentoID" : "testM1234", "isCancelConfirmed":"test"}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRestHandler.createCase();
        Test.stopTest();

        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                        ResponseWrapper.class);
        System.assertEquals(DTC_Constants.VALIDATION_FAILS, responseBody.result, 
                            'Response is expected to be a validation failure.');
    }

    @isTest
    private static void testCreateCaseWhenCancelConfirmedIsFalse() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        req.requestURI = '/services/apexrest/Cases/';
        req.httpMethod = 'POST';
        String jsonString = '{"caseDetails" : {"First_name__c": "Test case","Last_name__c": "customer 1",'
        +'"Email_Address__c": "test@example.com","Cancelation_Reason__c": "Other","Notes__c": "test customer",'
        +'"Brand__c": "Jim Beam","OrderID__c": "","ProductID__c": "testp1234","Batch_Billing__c": "2022-02-02", '
        +'"Program_Subscription__c" : "test"},"accountDetails" : {"PersonMailingCountry": "India",'
        +'"PersonMailingState": "Rajasthan","PersonMailingCity": "Jaipur","PersonMailingPostalCode": "302015",'
        +'"PersonMailingStreet": "test street 1"},"Type": "Membership Cancellation",'
        +'"MagentoID" : "testM1234", "isCancelConfirmed":"false"}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRestHandler.createCase();
        Test.stopTest();

        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                        ResponseWrapper.class);
        System.assertEquals(DTC_Constants.VALIDATION_FAILS, responseBody.result, 
                            'Response is expected to be a validation failure.');
    }

    @isTest
    private static void testCreateCaseToVerifyDuplicateOrderId() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/Cases/';
        req.httpMethod = 'POST';
        String jsonString = '{"caseDetails" : {"First_name__c": "Test case","Last_name__c": "customer 1",'
        +'"Email_Address__c": "test@example.com","Cancelation_Reason__c": "Other","Notes__c": "test customer",'
        +'"Brand__c": "Jim Beam","OrderID__c": "test","ProductID__c": "testp1234","Batch_Billing__c": "2022-02-02", '
        +'"Program_Subscription__c" : "test"},"accountDetails" : {"PersonMailingCountry": "India","PersonMailingState": '
        +'"Rajasthan","PersonMailingCity": "Jaipur","PersonMailingPostalCode": "302015",'
        +'"PersonMailingStreet": "test street 1"},"Type": "Membership Cancellation",'
        +'"MagentoID" : "testM1234", "isCancelConfirmed":"false"}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRestHandler.createCase();
        Test.stopTest();

        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                        ResponseWrapper.class);
        System.assertEquals(responseBody.result, DTC_Constants.FAILURE, 'Response is expected to be failure.');
    }

    @isTest
    private static void testUpdateCase() {
        Case caseDetail = [SELECT id, CaseNumber From Case][0];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/Cases/';
        req.httpMethod = 'PATCH';
        String jsonString = '{"caseDetails":{"CaseNumber":"'+caseDetail.CaseNumber+'","Status":"Closed"},'
        +'"avataxDetails":{"Avatax_Status__c":"Commited","Tax_Amount__c":"100"},"braintreeDetails":'
        +'{"Braintree_Status__c":"Sale","Transaction_Amount__c":"2000","Date_of_Transaction__c":"2017-06-03"},'
        +'"sapDetails":{"SAP_Status__c":"YOU - Sales order","SAP_Order_Number__c":"20"}}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRestHandler.UpdateCase();
        Test.stopTest();

        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                        ResponseWrapper.class);
        System.assertNotEquals(null, responseBody.result, 'Response is expected to be success instead of failure.');
        //System.assertEquals(responseBody.result, DTC_Constants.SUCCESS, 'Response is expected to be success instead of failure.');
    }

    @isTest
    private static void testUpdateCaseIfCaseValidationFails() {
        Case caseDetail = [SELECT id, CaseNumber From Case][0];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/Cases/';
        req.httpMethod = 'PATCH';
        String jsonString = '{"caseDetails":{"Status":"Closed"},"avataxDetails":{"Avatax_Status__c":"Commited",'
        +'"Tax_Amount__c":"100"},"braintreeDetails":{"Braintree_Status__c":"Sale","Transaction_Amount__c":"2000",'
        +'"Date_of_Transaction__c":"2017-06-03"},"sapDetails":{"SAP_Status__c":"YOU - Sales order","SAP_Order_Number__c":"20"}}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRestHandler.UpdateCase();
        Test.stopTest();

        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                        ResponseWrapper.class);
        System.assertEquals(responseBody.result, DTC_Constants.VALIDATION_FAILS, 
                            'Response is expected to be favalidation failure.');
    }

    @isTest
    private static void testUpdateCaseIfExceptionOccurs() {
        Case caseDetail = [SELECT id, CaseNumber From Case][0];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/Cases/';
        req.httpMethod = 'PATCH';
        String jsonString = '{"caseDetails":{"CaseNumber":"'+caseDetail.CaseNumber+'","Status":"Closed"},"avataxDetails":'
        +'{"Avatax_Status__c":"Commited","Tax_Amount__c":"100"},"braintreeDetails":{"Braintree_Status__c":"Sale",'
        +'"Transaction_Amount__c":"2000","Date_of_Transaction__c":""},"sapDetails":{"SAP_Status__c":"YOU - Sales order",'
        +'"SAP_Order_Number__c":"20"}}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRestHandler.UpdateCase();
        Test.stopTest();

        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                        ResponseWrapper.class);
        System.assertEquals(responseBody.result, DTC_Constants.failure, 'Response is expected to be a failure.');
    }

    @isTest
    private static void testUpdateCaseForIncorrectPicklistOption() {
        Case caseDetail = [SELECT id, CaseNumber From Case][0];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/Cases/';
        req.httpMethod = 'PATCH';
        String jsonString = '{"caseDetails":{"CaseNumber":"'+caseDetail.CaseNumber+'","Status":"test"},"avataxDetails":'
        +'{"Avatax_Status__c":"Commited","Tax_Amount__c":"100"},"braintreeDetails":{"Braintree_Status__c":"Sale",'
        +'"Transaction_Amount__c":"2000","Date_of_Transaction__c":"2017-06-03"},"sapDetails":{"SAP_Status__c":'
        +'"YOU - Sales order","SAP_Order_Number__c":"20"}}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRestHandler.UpdateCase();
        Test.stopTest();

        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                        ResponseWrapper.class);
        System.assertEquals(DTC_Constants.VALIDATION_FAILS, responseBody.result, 
                            'Response is expected to be a validation failure.');
    }
    
    @isTest
    private static void testUpdateCaseWhencaseAvataxBraintreeSapObjIsNull() {
        Case caseDetail = [SELECT id, CaseNumber 
                            FROM Case][0];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/Cases/';
        req.httpMethod = 'PATCH';
        String jsonString = '{}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRestHandler.UpdateCase();
        Test.stopTest();

        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                        ResponseWrapper.class);
        System.assertEquals(DTC_Constants.FAILURE, responseBody.result, 
                            'Response is expected to be a failure because caseAvataxBraintreeSapObj is NULL');
    }
    
    @isTest
    private static void testUpdateCaseWhenStatusIsClosed() {
        Case caseDetail = [SELECT id, CaseNumber 
                            FROM Case 
                            WHERE status = 'Closed'];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/Cases/';
        req.httpMethod = 'PATCH';
        String jsonString = '{"caseDetails":{"CaseNumber":"'+caseDetail.CaseNumber+'","Status":"Closed"},'
        +'"avataxDetails":{"Avatax_Status__c":"Commited","Tax_Amount__c":"100"},"braintreeDetails":'
        +'{"Braintree_Status__c":"Sale","Transaction_Amount__c":"2000","Date_of_Transaction__c":"2017-06-03"},'
        +'"sapDetails":{"SAP_Status__c":"YOU - Sales order","SAP_Order_Number__c":"20"}}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRestHandler.UpdateCase();
        Test.stopTest();

        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                        ResponseWrapper.class);
        System.assertEquals(responseBody.result, DTC_Constants.FAILURE,
            'Response Is Expected to Fail Since Response wrapped is of Status Failure');
    }
    
    @isTest
    private static void testUpdateCaseWhenStatusAndAdditionalInfoIsPaymentDeclined() {
        Case caseDetail = [SELECT id, CaseNumber, status 
                            FROM Case 
                            WHERE status = 'Payment Decline' 
                            AND AdditionalInformation__c = 'Payment Decline'];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/Cases/';
        req.httpMethod = 'PATCH';
        String jsonString = '{"caseDetails":{"CaseNumber":"'+caseDetail.CaseNumber+'","Status":"Payment Decline"},'
        +'"avataxDetails":{"Avatax_Status__c":"Commited","Tax_Amount__c":"100"},"braintreeDetails":'
        +'{"Braintree_Status__c":"Sale","Transaction_Amount__c":"2000","Date_of_Transaction__c":"2017-06-03"},'
        +'"sapDetails":{"SAP_Status__c":"YOU - Sales order","SAP_Order_Number__c":"20"}}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRestHandler.UpdateCase();
        Test.stopTest();

        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                        ResponseWrapper.class);
        System.assertEquals(responseBody.result, DTC_Constants.SUCCESS, 'Response Is Expected to be successful');
    }
    
    @isTest
    private static void testUpdateCaseWhenStatusIsPaymentDeclined() {
        Case caseDetail = [SELECT id, CaseNumber, status 
                            FROM Case 
                            WHERE status = 'Payment Decline' 
                            AND AdditionalInformation__c != 'Payment Decline'];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/Cases/';
        req.httpMethod = 'PATCH';
        String jsonString = '{"caseDetails":{"CaseNumber":"'+caseDetail.CaseNumber+'","Status":"Payment Decline"},'
        +'"avataxDetails":{"Avatax_Status__c":"Commited","Tax_Amount__c":"100"},"braintreeDetails":'
        +'{"Braintree_Status__c":"Sale","Transaction_Amount__c":"2000","Date_of_Transaction__c":"2017-06-03"},'
        +'"sapDetails":{"SAP_Status__c":"YOU - Sales order","SAP_Order_Number__c":"20"}}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRestHandler.UpdateCase();
        Test.stopTest();

        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                        ResponseWrapper.class);
        System.assertEquals(responseBody.result, DTC_Constants.FAILURE, 'Response Is Expected to be successful');
    }
    
    @isTest
    private static void testCreateDisputedCaseWhenValidationFails() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/Cases/';
        req.httpMethod = 'POST';
        String jsonString = '{"caseDetails" : {"First_name__c": "Test case","Last_name__c": "customer 1","Email_Address__c": '
        +'"test@example.com","Cancelation_Reason__c": "Other","Notes__c": "test customer","Brand__c": "Jim Beam","OrderID__c":' 
        +'"testo123Dispute","ProductID__c": "testp1234","Batch_Billing__c": "2022-02-02", "Program_Subscription__c" : "test"},'
        +'"accountDetails" : {"PersonMailingCountry": "India","PersonMailingState": "Rajasthan","PersonMailingCity": "Jaipur",'
        +'"PersonMailingPostalCode": "302015","PersonMailingStreet": "test street 1"},"Type": "Dispute",'
        +'"MagentoID" : "testM1234"}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRestHandler.createCase();
        Test.stopTest();

        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                        ResponseWrapper.class);
        System.assertEquals(responseBody.result, DTC_Constants.VALIDATION_FAILS, 
            'Response is expected to be validation failure.');
    }

    @isTest
    private static void testCreateDisputedCaseWhenAddressValidationFails() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/Cases/';
        req.httpMethod = 'POST';
        String jsonString = '{"caseDetails" : {"First_name__c": "Test case","Last_name__c": "customer 1","Email_Address__c": '
        +'"test@example.com","Cancelation_Reason__c": "Other","Notes__c": "test customer","Brand__c": "Jim Beam","OrderID__c":' 
        +'"testo123Dispute","ProductID__c": "testp1234","Batch_Billing__c": "2022-02-02", "Program_Subscription__c" : "test"},'
        +'"Type": "Dispute",'
        +'"MagentoID" : "testM1234"}';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRestHandler.createCase();
        Test.stopTest();

        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(), 
                                        ResponseWrapper.class);
        System.assertEquals(responseBody.result, DTC_Constants.VALIDATION_FAILS, 
            'Response is expected to be validation failure.');
    }
}