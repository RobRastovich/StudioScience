@isTest
public class TST_SRV_DTC_Case {

    @testSetup
    static void dataSetup() {
        List<Case> casesList = new List<Case>();
        Case caseDetail = TST_TestDataFactory.createCase(null, false);
        caseDetail.OrderID__c = 'T123';
        casesList.add( caseDetail);
        
        Case caseObj = TST_TestDataFactory.createCase(null, false);
        caseObj.Status = 'In Progress';
        caseObj.Sub_Status__c = 'Replacement confirmed';
        caseObj.OrderID__c ='Test99';
        caseObj.How_can_we_help__c = 'Community Console';
        caseObj.AdditionalInformation__c = 'Replacement';
        caseObj.Email_Address__c = 'testReplacement@gmail.com';
        casesList.add( caseObj);

        Case caseDispute = TST_TestDataFactory.createCase(null, false);
        caseDispute.OrderID__c = 'TESTDISPUTE';
        caseDispute.How_can_we_help__c = 'API';
        caseDispute.AdditionalInformation__c = 'Dispute';
        casesList.add(caseDispute);

        Case caseStoreRecord = TST_TestDataFactory.createCase(null, false);
        caseStoreRecord.Status = DTC_Constants.REFUND_STATUS;
        caseStoreRecord.Sub_Status__c = DTC_Constants.INITIATED_SUB_STATUS;
        casesList.add(caseStoreRecord);
        
        Case caseObjUpdate = TST_TestDataFactory.createCase(null, false);
        caseObjUpdate.Status = 'Closed';
        casesList.add(caseObjUpdate);
        
        Case caseObjUpdate1 = TST_TestDataFactory.createCase(null, false);
        caseObjUpdate1.Status = 'Closed';
        caseObjUpdate1.Follow_Up_Count__c = 3;
        casesList.add(caseObjUpdate1);

        insert casesList;
        Account accnt = TST_TestDataFactory.createPersonAccount(DTC_Constants.ACCOUNT_CONSUMER_RECORDTYPEID, true);
    }

    @isTest
    private static void testCaseCreation() {
        Case caseDetail = [SELECT id, First_name__c, Last_name__c, Email_Address__c, Cancelation_Reason__c, Notes__c,
                            Brand__c, OrderID__c, ProductID__c, Batch_Billing__c, How_can_we_help__c, AdditionalInformation__c,
                            ContactId, AccountId, Automated_Notification_Email__c, Program_Subscription__c, Cancel_Confirmed__c,
                            Shipment_Required__c, DisputeID__c, Transaction_Amount__c,
                            TransactionID__c, Received_Date__c, Response_Deadline__c
                            FROM Case][0];
        caseDetail.OrderID__c = 'DTC123';
        Account accnt = [SELECT Id, PersonContactId, PersonEmail, PersonMailingCountry, PersonMailingState,
                            PersonMailingCity, PersonMailingPostalCode, PersonMailingStreet, FirstName, Lastname
                            FROM Account][0];

        Test.startTest();
            Case created = SRV_DTC_Case.caseCreation(caseDetail, DTC_Constants.MEMBERSHIP_CANCELLATION, accnt, null);
        Test.stopTest();

        System.assertNotEquals(null, created.Id , 'No Records created when expected');
    }

    @isTest
    private static void testCaseCreationForMakersMark() {
        Case caseDetail = [SELECT id, First_name__c, Last_name__c, Email_Address__c, Cancelation_Reason__c, Notes__c,
                              Brand__c, OrderID__c, ProductID__c, Batch_Billing__c, How_can_we_help__c, AdditionalInformation__c,
                              ContactId, AccountId, Automated_Notification_Email__c, Program_Subscription__c, Cancel_Confirmed__c,
                              Shipment_Required__c,  DisputeID__c, Transaction_Amount__c,
                              TransactionID__c, Received_Date__c, Response_Deadline__c
                              FROM Case][0];
        caseDetail.OrderID__c = 'DTC123';
        caseDetail.Brand__c = DTC_Constants.BRAND_MAKERS_MARK_APPOS;
        Account accnt = [SELECT Id, PersonContactId, PersonEmail, PersonMailingCountry, PersonMailingState,
                            PersonMailingCity, PersonMailingPostalCode, PersonMailingStreet, FirstName, Lastname
                            FROM Account][0];

        Test.startTest();
            Case created = SRV_DTC_Case.caseCreation(caseDetail, DTC_Constants.MEMBERSHIP_CANCELLATION, accnt, null);
        Test.stopTest();

        System.assertNotEquals(null, created.Id , 'No Records created when expected');
    }

    @isTest
    private static void testDhlCaseCreationForMakersMark() {
        Case caseDetail = [SELECT id, First_name__c, Last_name__c, Email_Address__c, Cancelation_Reason__c, Notes__c,
                           Brand__c, OrderID__c, ProductID__c, Batch_Billing__c, How_can_we_help__c, AdditionalInformation__c,
                           ContactId, AccountId, Automated_Notification_Email__c, Program_Subscription__c, Consumer_Country__c, 
                           Consumer_City__c, Consumer_Postal_Code__c, Consumer_Street__c, UPS_Reason_For_Return__c,
                           DHL_Status__c, OwnerID, Retail_Account__c, Cancel_Confirmed__c, Shipment_Required__c,
                           Customer_Phone_Number__c, UPS_Tracking_Number__c,Consumer_State__c, Damage_Issue__c
                           FROM Case][0];
        caseDetail.OrderID__c = 'DTC1234';
        caseDetail.DHL_Status__c = 'Damage';
        caseDetail.Brand__c = DTC_Constants.BRAND_MAKERS_MARK_APPOS;
        Account accnt = [SELECT Id, PersonContactId, PersonEmail, PersonMailingCountry, PersonMailingState,
                         PersonMailingCity, PersonMailingPostalCode, PersonMailingStreet, FirstName, Lastname
                         FROM Account][0];

        Test.startTest();
            Case created = SRV_DTC_Case.dhlCaseCreation(caseDetail);
        Test.stopTest();

        System.assertNotEquals(null, created.Id , 'No Records created when expected');
    }

    @isTest
    private static void testCaseCreationForShipmentRequiredTrue() {
        Case caseDetail = [SELECT id, First_name__c, Last_name__c, Email_Address__c, Cancelation_Reason__c, Notes__c,
                                Brand__c, OrderID__c, ProductID__c, Batch_Billing__c, How_can_we_help__c, AdditionalInformation__c,
                                ContactId, AccountId, Automated_Notification_Email__c, Program_Subscription__c, Cancel_Confirmed__c,
                                Shipment_Required__c, DisputeID__c, Transaction_Amount__c,
                                TransactionID__c, Received_Date__c, Response_Deadline__c
                                FROM Case][0];
        caseDetail.OrderID__c = 'DTC123';
        caseDetail.Shipment_Required__c = true;
        Account accnt = [SELECT Id, PersonContactId, PersonEmail, PersonMailingCountry, PersonMailingState,
                            PersonMailingCity, PersonMailingPostalCode, PersonMailingStreet, FirstName, Lastname
                            FROM Account][0];

        Test.startTest();
            Case created = SRV_DTC_Case.caseCreation(caseDetail, DTC_Constants.MEMBERSHIP_CANCELLATION, accnt, null);
        Test.stopTest();

        System.assertNotEquals(null, created.Id , 'No Records created when expected');
    }

    @isTest
    private static void testCaseCreationForShipmentRequiredFalse() {
        Case caseDetail = [SELECT id, First_name__c, Last_name__c, Email_Address__c, Cancelation_Reason__c, Notes__c,
                              Brand__c, OrderID__c, ProductID__c, Batch_Billing__c, How_can_we_help__c, AdditionalInformation__c,
                              ContactId, AccountId, Automated_Notification_Email__c, Program_Subscription__c, Cancel_Confirmed__c,
                              Shipment_Required__c, DisputeID__c, Transaction_Amount__c,
                              TransactionID__c, Received_Date__c, Response_Deadline__c
                              FROM Case][0];
        caseDetail.OrderID__c = 'DTC123';
        caseDetail.Shipment_Required__c = false;
        Account accnt = [SELECT Id, PersonContactId, PersonEmail, PersonMailingCountry, PersonMailingState,
                            PersonMailingCity, PersonMailingPostalCode, PersonMailingStreet, FirstName, Lastname
                            FROM Account][0];

        Test.startTest();
            Case created = SRV_DTC_Case.caseCreation(caseDetail, DTC_Constants.MEMBERSHIP_CANCELLATION, accnt, null);
        Test.stopTest();

        System.assertNotEquals(null, created.Id , 'No Records created when expected');
    }
    
    @isTest
    private static void testDhlCaseCreation() {
        Case caseDetail = [SELECT id, First_name__c, Last_name__c, Email_Address__c, Cancelation_Reason__c, Notes__c,
                                Brand__c, OrderID__c, ProductID__c, Batch_Billing__c, How_can_we_help__c, 
                                ContactId, AccountId, Automated_Notification_Email__c, Program_Subscription__c, 
                                Consumer_City__c, Consumer_Postal_Code__c, Consumer_Street__c, UPS_Reason_For_Return__c, 
                                DHL_Status__c, OwnerID, Retail_Account__c, Cancel_Confirmed__c, Shipment_Required__c,
                                Customer_Phone_Number__c, Consumer_Country__c, Consumer_State__c, AdditionalInformation__c,
                                UPS_Tracking_Number__c,Damage_Issue__c
                                FROM Case][0];
        caseDetail.OrderID__c = 'DTC1234';
        caseDetail.DHL_Status__c = 'Damage';
        Account accnt = [SELECT Id, PersonContactId, PersonEmail, PersonMailingCountry, PersonMailingState,
                                PersonMailingCity, PersonMailingPostalCode, PersonMailingStreet, FirstName, Lastname
                                FROM Account][0];

        Test.startTest();
            Case created = SRV_DTC_Case.dhlCaseCreation(caseDetail);
        Test.stopTest();

        System.assertNotEquals(null, created.Id , 'No Records created when expected');
    }
    
    @isTest
    private static void testUpdateCaseAvataxBraintreeSAPStatus() {
        Case avataxDetails = [SELECT id, Status, Sub_Status__c, Avatax_Status__c, Tax_Amount__c, SAP_Status__c,
                                    Braintree_Status__c, Transaction_Amount__c, SAP_Order_Number__c, Date_of_Transaction__c 
                                    FROM Case][0];

        Case caseStoreRecord = [SELECT id, Status, Sub_Status__c, Avatax_Status__c, Tax_Amount__c, SAP_Status__c,
                                    Braintree_Status__c, Transaction_Amount__c, SAP_Order_Number__c, Date_of_Transaction__c,
                                    AdditionalInformation__c
                                    FROM Case 
                                    WHERE Sub_Status__c =:DTC_Constants.INITIATED_SUB_STATUS 
                                    LIMIT 1];
        
        Test.startTest();
            Case updated = SRV_DTC_Case.updateCaseAvataxBraintreeSAPStatus(null, avataxDetails, avataxDetails,
                avataxDetails, caseStoreRecord);
        Test.stopTest();
        
        System.assertEquals('Refund', updated.Status);
    }
    
    @isTest
    private static void testUpdateCaseTrackingNumber() {
        Case caseObjUpdate = [SELECT id, Status, Sub_Status__c,OrderID__c, UPS_Tracking_Number__c, AdditionalInformation__c 
                                    FROM Case][0];
        Map<String, String> mapCaseDetails= 
        new Map<String,String>{'orderId' => 'Test99','trackingNumber' => '12345'};
                
        Test.startTest();
            Case updated = SRV_DTC_Case.updateCaseTrackingNumber(caseObjUpdate, mapCaseDetails);
        Test.stopTest();
        
        System.assertEquals('Closed', updated.Status, 'The Status is not closed.');
    }
    
    @isTest
    private static void testUpdateCaseTrackingNumberReplacement() {
        Case caseObjUpdate = [SELECT id, Status, Sub_Status__c,OrderID__c, UPS_Tracking_Number__c, AdditionalInformation__c 
                                  FROM Case
                                  WHERE AdditionalInformation__c = 'Replacement' LIMIT 1];
        Map<String, String> mapCaseDetails= 
        new Map<String,String>{'orderId' => 'Test99','trackingNumber' => '12345'};
                
        Test.startTest();
            Case updated = SRV_DTC_Case.updateCaseTrackingNumber(caseObjUpdate, mapCaseDetails);
        Test.stopTest();
        
        System.assertEquals('Closed', updated.Status, 'The status is not updated.');
    }
    
    @isTest
    private static void testUpdateCaseStatusToReopen() {
        Case caseObjUpdate = [SELECT id, Status, Sub_Status__c,OrderID__c, UPS_Tracking_Number__c, AdditionalInformation__c 
                                  FROM Case
                                  WHERE Status = 'Closed' LIMIT 1];
        
        Test.startTest();
            Case updated = SRV_DTC_Case.updateCaseStatusToReopen(caseObjUpdate);
        Test.stopTest();
        
        System.assertEquals('Reopen', updated.Status, 'The Status is not reopen.');
    }
    
    @isTest
    private static void testUpdateCaseReminderStep() {
        Case caseObjUpdate = [SELECT id, Status, Sub_Status__c,OrderID__c, UPS_Tracking_Number__c, AdditionalInformation__c,
                                    Follow_Up_Count__c
                                  FROM Case
                                  WHERE Status = 'Closed' 
                                  AND Follow_Up_Count__c = 3 
                                  LIMIT 1];
        
        Test.startTest();
            Case updated = SRV_DTC_Case.updateCaseReminderStep(caseObjUpdate);
        Test.stopTest();
        
        System.assertEquals('Closed', updated.Status, 'The Status is not reopen.');
        System.assertEquals(4, updated.Follow_Up_Count__c, 'The Follow up count is not 4.');
    }
    
    @isTest
    private static void testCaseCreationForShipmentRequiredAndCancelConfirmFalse() {
        Case caseDetail = [SELECT id, First_name__c, Last_name__c, Email_Address__c, Cancelation_Reason__c, Notes__c,
                              Brand__c, OrderID__c, ProductID__c, Batch_Billing__c, How_can_we_help__c, AdditionalInformation__c,
                              ContactId, AccountId, Automated_Notification_Email__c, Program_Subscription__c, Cancel_Confirmed__c,
                              Shipment_Required__c, DisputeID__c, Transaction_Amount__c,
                              TransactionID__c, Received_Date__c, Response_Deadline__c
                              FROM Case][0];
        caseDetail.OrderID__c = 'DTC123';
        caseDetail.Shipment_Required__c = false;
        caseDetail.Cancel_Confirmed__c = false;
        Account accnt = [SELECT Id, PersonContactId, PersonEmail, PersonMailingCountry, PersonMailingState,
                            PersonMailingCity, PersonMailingPostalCode, PersonMailingStreet, FirstName, Lastname
                            FROM Account][0];

        Test.startTest();
            Case created = SRV_DTC_Case.caseCreation(caseDetail, DTC_Constants.MEMBERSHIP_CANCELLATION, accnt, 'false');
        Test.stopTest();

        System.assertNotEquals(null, created.Id , 'No Records created when expected');
    }
    
    @isTest
    private static void testCaseCreationDispute() {
        Case caseDetail = [SELECT id, First_name__c, Last_name__c, Email_Address__c, Cancelation_Reason__c, Notes__c,
                            Brand__c, OrderID__c, ProductID__c, Batch_Billing__c, How_can_we_help__c, AdditionalInformation__c,
                            ContactId, AccountId, Status, Program_Subscription__c, Braintree_Status__c,
                            Cancel_Confirmed__c, Shipment_Required__c, DisputeID__c, Transaction_Amount__c,
                            TransactionID__c, Received_Date__c, Response_Deadline__c
                            FROM Case WHERE AdditionalInformation__c = 'Dispute'][0];
        caseDetail.OrderID__c = 'DTC123DISPUTE';
        Account accnt = [SELECT Id, PersonContactId, PersonEmail, PersonMailingCountry, PersonMailingState,
                            PersonMailingCity, PersonMailingPostalCode, PersonMailingStreet, FirstName, Lastname
                            FROM Account][0];

        Test.startTest();
            Case created = SRV_DTC_Case.caseCreation(caseDetail, DTC_Constants.MEMBERSHIP_CANCELLATION, accnt, null);
        Test.stopTest();

        System.assertNotEquals(null, created.Id , 'No Records created when expected');
    }
}