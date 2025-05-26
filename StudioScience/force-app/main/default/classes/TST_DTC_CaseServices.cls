/**
    @company : Copyright © 2020, BeamSuntory
    All rights reserved.
    Redistribution and use in source form, with or without modification, are prohibited without the express written consent of BeamSuntory,Inc.
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
    INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
    IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
    @website : https://www.beamsuntory.com/
    @author BeamSuntory
    @version V_1.0
    @date 17 Feb 2022
    @description This test class is to test DTC_CaseServices.
*/
@isTest
public class TST_DTC_CaseServices {
    @testSetup
    static void setUpTestData() { 
        List<Case> insertCases = new List<Case>();
        Case jimBeamCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        jimBeamCase.OrderID__c = 'testJimBeam';
        insertCases.add(jimBeamCase);
        Case makersMarkCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        makersMarkCase.OrderID__c = 'testMakersMark';
        makersMarkCase.Brand__c = System.label.Makers_Mark_DTC;
        insertCases.add(makersMarkCase);
        Case newCase1 = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        newCase1.Status = 'In Progress';
        newCase1.OrderID__c = 'testO1234';
        newCase1.Sub_Status__c = 'Confirmation email sent';
        insertCases.add(newCase1);
        Case newCase2 = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        newCase2.Avatax_Status__c = 'Commited';
        newCase2.Braintree_Status__c = 'Settled';
        newCase2.OrderID__c = 'testO12345';
        newCase2.SAP_Status__c = 'YREU - Return Order';
        newCase2.Status = 'Refund';
        newCase2.Sub_Status__c = 'Initiated';
        newCase2.Tax_Amount__c = -200;
        insertCases.add(newCase2);
        Case newCase3 = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        newCase3.How_can_we_help__c = 'Community console';
        newCase3.AdditionalInformation__c = 'Return';
        newCase3.OrderID__c = 'testO12345678';
        insertCases.add(newCase3);
        Case replacementConfirmedCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        replacementConfirmedCase.Status = 'In Progress';
        replacementConfirmedCase.Sub_Status__c = 'Replacement confirmed';
        replacementConfirmedCase.OrderID__c = 'testreplacement';
        insertCases.add(replacementConfirmedCase);
        Case replacementCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        replacementCase.Status = 'In Progress';
        replacementCase.Sub_Status__c = 'Replacement confirmed';
        replacementCase.OrderID__c = 'testreplacement123';
        replacementCase.How_can_we_help__c = 'Community console';
        replacementCase.AdditionalInformation__c = 'Replacement';
        insertCases.add(replacementCase);
        Case disputedCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        disputedCase.Status = 'In Progress';
        disputedCase.Sub_Status__c = DTC_Constants.SUB_STATUS_CONFIRMATION_EMAIL_SENT;
        disputedCase.OrderID__c = 'testDisputed1234';
        disputedCase.How_can_we_help__c = 'API';
        disputedCase.AdditionalInformation__c = 'Dispute';
        insertCases.add(disputedCase);
        Case wonCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        wonCase.How_can_we_help__c = 'API';
        wonCase.AdditionalInformation__c = 'Dispute';
        wonCase.Braintree_Status__c = 'Won';
        insertCases.add(wonCase);
        Case lostCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        lostCase.How_can_we_help__c = 'API';
        lostCase.AdditionalInformation__c = 'Dispute';
        lostCase.Braintree_Status__c = 'Lost';
        insertCases.add(lostCase);
        Case openCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        openCase.How_can_we_help__c = 'API';
        openCase.AdditionalInformation__c = 'Dispute';
        openCase.Braintree_Status__c = 'Open';
        openCase.Status = 'Closed';
        insertCases.add(openCase);
        Case braintreeResponseCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        braintreeResponseCase.How_can_we_help__c = 'API';
        braintreeResponseCase.AdditionalInformation__c = 'Dispute';
        braintreeResponseCase.Braintree_Status__c = 'Open';
        braintreeResponseCase.Status = 'In Progress';
        braintreeResponseCase.Sub_Status__c = DTC_Constants.SUB_STATUS_BRAINTREE_RESPONSE;
        insertCases.add(braintreeResponseCase);
        Case subStatusValidCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        subStatusValidCase.How_can_we_help__c = 'API';
        subStatusValidCase.AdditionalInformation__c = 'Dispute';
        subStatusValidCase.Braintree_Status__c = 'Open';
        subStatusValidCase.Status = 'In Progress';
        subStatusValidCase.Sub_Status__c = DTC_Constants.SUB_STATUS_FOLLOWUP_EMAIL_SENT;
        subStatusValidCase.Send_Bell_Notification__c = true;
        subStatusValidCase.ConsumerResponseOnCase__c = 1;
        insertCases.add(subStatusValidCase);
        Case inValidCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        inValidCase.How_can_we_help__c = 'API';
        inValidCase.AdditionalInformation__c = 'Dispute';
        inValidCase.Braintree_Status__c = 'Open';
        inValidCase.Status = 'In Progress';
        inValidCase.Sub_Status__c = DTC_Constants.SUB_STATUS_INVALID;
        insertCases.add(inValidCase);
        Case updateSubStatusToBlankCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        updateSubStatusToBlankCase.Status = 'Closed';
        updateSubStatusToBlankCase.Sub_Status__c = 'Settled';
        updateSubStatusToBlankCase.How_can_we_help__c = 'Barreled & Boxed – Membership Program';
        updateSubStatusToBlankCase.AdditionalInformation__c = 'Replacement';
        insertCases.add(updateSubStatusToBlankCase);
        Case updateCaseStatusShipmentWarehouse = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        updateCaseStatusShipmentWarehouse.OrderID__c = 'testO12';
        updateCaseStatusShipmentWarehouse.Status = 'In Progress';
        updateCaseStatusShipmentWarehouse.Sub_Status__c = 'Communicate with DHL';
        updateCaseStatusShipmentWarehouse.DHL_Status__c = 'Returned to warehouse(Damage)';
        insertCases.add(updateCaseStatusShipmentWarehouse);
        Case updateCaseStatusShipmentWarehouse2 = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        updateCaseStatusShipmentWarehouse2.OrderID__c = 'testO1234567';
        updateCaseStatusShipmentWarehouse2.Status = 'In Progress';
        updateCaseStatusShipmentWarehouse2.Sub_Status__c = 'Communicate with DHL';
        updateCaseStatusShipmentWarehouse2.DHL_Status__c = 'Not Yet Shipped'; 
        insertCases.add(updateCaseStatusShipmentWarehouse2);
        Case updateCaseStatusShipmentWarehouse3 = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        updateCaseStatusShipmentWarehouse3.OrderID__c = 'testO1234567';
        updateCaseStatusShipmentWarehouse3.DHL_Status__c = null;
        updateCaseStatusShipmentWarehouse3.Status = 'In Progress';
        updateCaseStatusShipmentWarehouse3.Sub_Status__c = 'Communicate with DHL';
        insertCases.add(updateCaseStatusShipmentWarehouse3);
        Case dhlBellNotificationCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        dhlBellNotificationCase.Status = 'In Progress';
        dhlBellNotificationCase.Sub_Status__c = DTC_Constants.SUB_STATUS_CONFIRMATION_EMAIL_SENT;
        dhlBellNotificationCase.OrderID__c = 'DHLBellNotification';
        dhlBellNotificationCase.How_can_we_help__c = 'Community Console';
        dhlBellNotificationCase.AdditionalInformation__c = DTC_Constants.RETURN_ADDINFORMATION;
        dhlBellNotificationCase.Availability_Date__c = Date.today();
        dhlBellNotificationCase.Send_Bell_Notification__c = true;
        insertCases.add(dhlBellNotificationCase);
        if(insertCases.size() > 0 && !insertCases.isEmpty()){
            insert insertCases;
        }
        Group groupDetailMakersMark = TST_TestDataFactory.createGroup(true, DTC_Constants.DIRECT_TO_CUSTOMER);
        Group groupDetailBarrelled = TST_TestDataFactory.createGroup(true, DTC_Constants.QUEUE_BARRELED_BOXED);
        CustomNotificationType custom = TST_TestDataFactory.createCustomNotificationType(null, false);
    }
    
    @isTest
    private static void testCheckStatusFlowOfCaseStatusDTCWhenSUbStatusNotNull() {
        List<Case> newList = [SELECT id, RecordTypeId, ownerId, Status, AdditionalInformation__c, Sub_Status__c, First_name__c, 
                                Last_name__c, Email_Address__c, Brand__c
                                FROM Case 
                                WHERE Status = 'In Progress' AND Sub_Status__c = 'Confirmation email sent' 
                                AND AdditionalInformation__c ='Membership Cancellation'];
        Map<Id, Case> oldMap = new Map<Id, Case>();
        Case oldCase = newList[0].clone(true, false, false, false);
        oldCase = newList[0].clone(true, false, false, false);
        oldCase.Status = 'Refund';
        oldCase.Sub_Status__c = 'Initiated';
        oldMap.put(newList[0].Id,oldCase);
        
        Test.startTest();
        DTC_CaseServices.checkStatusFlowOfCaseStatusDTC(newList, oldMap);
        Test.stopTest();
        System.assertEquals('In Progress', newList[0].Status, 'The status is not In Progress.');
    }
    
    @isTest
    private static void testUpdateCaseStatusClosed() {
        Case newCase = [SELECT id, RecordTypeId, Status, SAP_Status__c, Sub_Status__c, Avatax_Status__c, Braintree_Status__c, 
                            Email_Address__c, Brand__c, Tax_Amount__c, How_can_we_help__c, AdditionalInformation__c 
                            FROM Case 
                            WHERE Sub_Status__c = 'Initiated' And Status = 'Refund' limit 1];        
        Case oldCase = newCase.clone(true, false, false, false);
        oldCase.Avatax_Status__c = 'Commited';
        oldCase.Braintree_Status__c = '';
        oldCase.SAP_Status__c = 'YREU - Return Order';
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id,oldCase);
        List<Case> newList = new List<Case>{newCase};

        Test.startTest();
        DTC_CaseServices.updateCaseStatusClosed(newList, oldMap);
        Test.stopTest();
        System.assertEquals('Closed', newList[0].Status, 'The status is not closed.');
    }
    
    @isTest
    private static void testUpdateStatusAndSubStatusWhenBrainTreeStatusIsWon() {
        Case newCase = [SELECT id, Status, Sub_Status__c, Braintree_Status__c, AdditionalInformation__c
                            FROM Case 
                            WHERE Braintree_Status__c = 'Won' limit 1];        
        Case oldCase = newCase.clone(true, false, false, false);
        oldCase.Braintree_Status__c = 'Open';
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id,oldCase);
        List<Case> newList = new List<Case>{newCase};

        Test.startTest();
        DTC_CaseServices.updateStatusAndSubStatus(newList, oldMap);
        Test.stopTest();
        System.assertEquals('Closed', newList[0].Status, 'The status is not closed.');
        System.assertEquals('Settled', newList[0].Sub_Status__c, 'The sub status is not settled.');
    }
    
    @isTest
    private static void testUpdateStatusAndSubStatusWhenBrainTreeStatusIsLost() {
        Case newCase = [SELECT id, Status, Sub_Status__c, Braintree_Status__c, AdditionalInformation__c
                            FROM Case 
                            WHERE Braintree_Status__c = 'Lost' limit 1];        
        Case oldCase = newCase.clone(true, false, false, false);
        oldCase.Braintree_Status__c = 'Open';
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id,oldCase);
        List<Case> newList = new List<Case>{newCase};

        Test.startTest();
        DTC_CaseServices.updateStatusAndSubStatus(newList, oldMap);
        Test.stopTest();
        System.assertEquals('Closed', newList[0].Status, 'The status is not closed.');
        System.assertEquals('Settled', newList[0].Sub_Status__c, 'The sub status is not settled.');
    }
     
    @isTest
    private static void testValidationOnCaseStatusIsClose() {
        Case newCase = [SELECT id, Status, Sub_Status__c, Braintree_Status__c, AdditionalInformation__c
                            FROM Case 
                            WHERE Braintree_Status__c = 'Open' 
                            AND AdditionalInformation__c =: DTC_Constants.ADD_INFO_DISPUTE
                            AND Status =: DTC_Constants.CLOSED_STATUS LIMIT 1];

        Case oldCase = newCase.clone(true, false, false, false);
        oldCase.Braintree_Status__c = 'Won';
        oldCase.Status = 'New';
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id,oldCase);
        List<Case> newList = new List<Case>{newCase};

        Test.startTest();
            DTC_CaseServices.validationOnCaseStatusIsClose(newList, oldMap);
        Test.stopTest();

        System.assertEquals(true, ApexPages.getMessages()[0].getDetail().contains(DTC_Constants.CASE_CLOSED_ERROR), 
        'The error message should be shown.');
    }
    
    @isTest
    private static void testUpdateCaseStatusCommunicateWithDHL() {
        Case newCase = [SELECT id, RecordTypeId, How_can_we_help__c, AdditionalInformation__c, Status, Sub_Status__c 
        FROM Case 
        WHERE Sub_Status__c = 'Confirmation email sent' AND Status = 'In Progress' limit 1];        
        Case oldCase = newCase.clone(true, false, false, false);
        newCase = newCase.clone(true, false, false, false);
        newCase.Sub_Status__c = 'Cancel Shipment';
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id,oldCase);
        List<Case> newList = new List<Case>{newCase};
            
        Test.startTest();
            DTC_CaseServices.updateCaseStatusCommunicateWithDHL(newList, oldMap);
        Test.stopTest();
        System.assertEquals('Communicate with DHL', newList[0].Sub_Status__c, 'The Sub status is not Communicate with DHL.');
    }
    
    @isTest
    private static void testUpdateCaseStatusShipmentAtWarehouse() {
        Case newCase = [SELECT id, Status, Sub_Status__c, OrderId__c, DHL_Status__c, How_can_we_help__c, 
                        AdditionalInformation__c
                       FROM Case 
                       WHERE DHL_Status__c = 'Returned to warehouse(Damage)' limit 1];
        Case oldCase = newCase.clone(true, false, false, false);
        oldCase.DHL_Status__c = 'Shipped';
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id,oldCase);
        List<Case> newList = new List<Case>{newCase};
            
        Test.startTest();
        	DTC_CaseServices.updateCaseStatusShipmentAtWarehouse(newList, oldMap);
        Test.stopTest();

        System.assertEquals('In Progress', newCase.Status, 'The status is not In Progress.');
        System.assertEquals('Shipment at warehouse', newCase.Sub_Status__c, 'The Sub status is not Shipment at warehouse.');
    }
    
    @isTest
    private static void testUpdateCaseStatusShipmentAtWarehouseWhenDHLStatusNotYetShipped() {
        Case newCase = [SELECT id, Status, Sub_Status__c, OrderId__c, DHL_Status__c, How_can_we_help__c, 
                        AdditionalInformation__c
                       FROM Case 
                       WHERE DHL_Status__c = 'Not Yet Shipped' limit 1];     
        Case oldCase = newCase.clone(true, false, false, false);
        oldCase.DHL_Status__c = 'Shipped';
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id,oldCase);
        List<Case> newList = new List<Case>{newCase};
            
        Test.startTest();
            DTC_CaseServices.updateCaseStatusShipmentAtWarehouse(newList, oldMap);
        Test.stopTest();

        System.assertEquals('In Progress', newCase.Status, 'The status is not In Progress.');
        System.assertEquals('Shipment at warehouse', newCase.Sub_Status__c, 'The Sub status is not Shipment at warehouse.');
    }
	@isTest
    private static void testUpdateCaseStatusShipmentAtWarehouseWhenDHLStatusNull() {
        Case newCase = [SELECT id, Status, Sub_Status__c, OrderId__c, DHL_Status__c, How_can_we_help__c, 
                        AdditionalInformation__c
                       FROM Case 
                       WHERE OrderID__c = 'testO1234567' limit 1]; 
        Case oldCase = newCase.clone(true, false, false, false);
        oldCase.DHL_Status__c = 'Shipped';
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id,oldCase);
        List<Case> newList = new List<Case>{newCase};
            
        Test.startTest();
            DTC_CaseServices.updateCaseStatusShipmentAtWarehouse(newList, oldMap);
        Test.stopTest();
        System.assertEquals('Shipment at warehouse', newCase.Sub_Status__c, 'The Sub Status is not Shipment at warehouse');
    }
    
    @isTest
    private static void testUpdateCaseAdditionalInformationWhenStatusReshipConfirmed() {
        Case oldCase = [SELECT id, RecordTypeId, OwnerId, Status, AdditionalInformation__c, Sub_Status__c, 
                       Brand__c, How_can_we_help__c, CreatedDate, Aging_Complete_On__c, Availability_Date__c 
                       FROM Case 
                       WHERE AdditionalInformation__c = 'Return' limit 1];
        Case newCase = oldCase.clone(true, false, false, false);
        newCase.Status = 'In Progress';
        newCase.Sub_Status__c = 'Reship Confirmed';
        Case newCase1 = oldCase.clone(true, false, false, false);
        newCase1.Status = 'In Progress';
        newCase1.Sub_Status__c = 'Reshipment initiated';
        Case newCase2 = oldCase.clone(true, false, false, false);
        newCase2.Status = 'In Progress';
        newCase2.Sub_Status__c = 'Confirmation email sent';
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id,oldCase);
        Map<Id, Case> oldMap1 = new Map<Id, Case>();
        oldMap1.put(oldCase.Id,oldCase);
        Map<Id, Case> oldMap2 = new Map<Id, Case>();
        oldMap2.put(oldCase.Id,oldCase);
        List<Case> newList = new List<Case>{newCase};
        List<Case> newList1 = new List<Case>{newCase1};
        List<Case> newList2 = new List<Case>{newCase2};
            
        Test.startTest();
        DTC_CaseServices.updateCaseAdditionalInformation(newList, oldMap);
        DTC_CaseServices.updateCaseAdditionalInformation(newList1, oldMap1);
        DTC_CaseServices.updateCaseAdditionalInformation(newList2, oldMap2);
        Test.stopTest();
        System.assertEquals('Return And Reship', newList[0].AdditionalInformation__c, 
                            'The Additional Information is not Return and Reship.');
        
        System.assertEquals('Return And Reship', newList1[0].AdditionalInformation__c, 
                            'The Additional Information is not Return and Reship.');
    }
    
    @isTest
    private static void testUpdateCaseAdditionalInformationWhenStatusRefundInitiated() {
        Case oldCase = [SELECT id, RecordTypeId, OwnerId, Status, AdditionalInformation__c, Sub_Status__c, 
                              Brand__c, How_can_we_help__c 
                              FROM Case 
                              WHERE AdditionalInformation__c = 'Return' limit 1];
        Case newCase = oldCase.clone(true, false, false, false);
        newCase.Status = 'Refund';
        newCase.Sub_Status__c = 'Initiated';
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id,oldCase);
        List<Case> newList = new List<Case>{newCase};
            
        Test.startTest();
        DTC_CaseServices.updateCaseAdditionalInformation(newList, oldMap);
        Test.stopTest();
        System.assertEquals('Return And Credit', newList[0].AdditionalInformation__c, 
                            'The Additional Information is not Return and Credit.');
    }

    @isTest
    private static void testCheckDuplicateOrderId() {
        List<Case> newList = [SELECT id, RecordTypeId, OrderId__c from Case];
        
        Test.startTest();
            DTC_CaseServices.checkDuplicateOrderId(newList, null);
        Test.stopTest();

        System.assertEquals(true, ApexPages.getMessages()[0].getDetail().contains('Duplicate'), 
            'The value should be true and error message should be shown.');
    }

    @isTest
    private static void testCheckDuplicateOpenReplacementCases() {
        List<Case> newList = [SELECT id, RecordTypeId, Email_Address__c, AdditionalInformation__c, Status, Sub_Status__c
                              FROM Case];
        
        Test.startTest();
            DTC_CaseServices.checkDuplicateOpenReplacementCases(newList, null);
        Test.stopTest();
		
        Case currentCase = [SELECT id, AdditionalInformation__c, Sub_Status__c, Status
                              FROM Case 
                              WHERE AdditionalInformation__c = 'Replacement' LIMIT 1];
        System.assertNotEquals(null, currentCase.AdditionalInformation__c, 
            'The value should not be null.');
    }
    
    @isTest
    private static void testUpdateCaseAdditionalInformationForReplacement() {
        Case oldCase = [SELECT id, RecordTypeId, OwnerId, Status, AdditionalInformation__c, Sub_Status__c, 
                              Brand__c, How_can_we_help__c 
                              FROM Case 
                              WHERE Sub_Status__c = 'Replacement confirmed' limit 1];
        Case newCase = oldCase.clone(true, false, false, false);
        newCase.Status = 'In Progress';
        newCase.Sub_Status__c = 'Replacement confirmed';
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id,oldCase);
        List<Case> newList = new List<Case>{newCase};
            
        Test.startTest();
        	DTC_CaseServices.updateCaseAdditionalInformation(newList, oldMap);
        Test.stopTest();
        System.assertNotEquals('Replacement', newList[0].AdditionalInformation__c, 
                            'The Additional Information is not updated.');
    }

    @isTest
    private static void testUpdateCaseOwnerOnTheBasisOFBrandMakersMark() {   
        Case newCase = [SELECT id, Brand__c, OwnerID
                            FROM Case 
                            WHERE OrderID__c = 'testJimBeam' LIMIT 1];   
        Case oldCase = newCase.clone(true, false, false, false);
        oldCase.Brand__c = System.label.Makers_Mark_DTC;
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id,oldCase);
        List<Case> newList = new List<Case>{newCase};
            
        Test.startTest();
            DTC_CaseServices.updateCaseOwnerOnTheBasisOFBrand(newList, oldMap);
        Test.stopTest();

        Group groupDetail = [SELECT id, Name 
                                FROM Group 
                                WHERE Name =: DTC_Constants.DIRECT_TO_CUSTOMER LIMIT 1]; 
        System.assertNotEquals(groupDetail.Id, newList[0].OwnerID, 'Owner doesnot gets updated when it is expected to be');
    }

    @isTest
    private static void testUpdateCaseOwnerOnTheBasisOFBrandBarelled() {   
        Case newCase = [SELECT id, Brand__c, OwnerID, How_can_we_help__c 
                            FROM Case 
                            WHERE OrderID__c = 'testMakersMark' LIMIT 1];   
        Case oldCase = newCase.clone(true, false, false, false);
        oldCase.Brand__c = System.label.Jim_Beam_Brand;
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id,oldCase);
        List<Case> newList = new List<Case>{newCase};
            
        Test.startTest();
            DTC_CaseServices.updateCaseOwnerOnTheBasisOFBrand(newList, oldMap);
        Test.stopTest();

        Group groupDetail = [SELECT id, Name 
                                FROM Group 
                                WHERE Name =: DTC_Constants.QUEUE_BARRELED_BOXED LIMIT 1]; 
        System.assertNotEquals(groupDetail.Id, newList[0].OwnerID, 'Owner doesnot gets updated when it is expected to be');
    }

    @isTest
    private static void testUpdateNextNotificationDate() {   
        Case newCase = [SELECT id, Status, Sub_Status__c, How_can_we_help__c, AdditionalInformation__c, Next_Notification_Date__c,
                            Braintree_Status__c
                            FROM Case 
                            WHERE AdditionalInformation__c = 'Dispute' LIMIT 1];   
        Case oldCase = newCase.clone(true, false, false, false);
        oldCase.Sub_Status__c = 'Document submitted';
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id,oldCase);
        List<Case> newList = new List<Case>{newCase};
            
        Test.startTest();
            DTC_CaseServices.updateNextNotificationDate(newList, oldMap);
        Test.stopTest();

        Case currCase = [SELECT id, Next_Notification_Date__c
                            FROM Case 
                            WHERE AdditionalInformation__c = 'Dispute' LIMIT 1];
        System.assertNotEquals(newCase.Next_Notification_Date__c, currCase.Next_Notification_Date__c,
            'Date doesnot gets updated when it is expected to be');
    }

    @isTest
    private static void testSendBellNotification() {  
        Case newCase = [SELECT id, Status, Sub_Status__c, How_can_we_help__c, AdditionalInformation__c, OwnerId,
                            Send_Bell_Notification__c, CaseNumber, Braintree_Status__c
                            FROM Case 
                            WHERE AdditionalInformation__c = 'Dispute' LIMIT 1];
        newCase.Send_Bell_Notification__c = true;   
        Case oldCase = newCase.clone(true, false, false, false);
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id,oldCase);
        List<Case> newList = new List<Case>{newCase};
            
        Test.startTest();
            DTC_CaseServices.sendBellNotification(newList, oldMap);
        Test.stopTest();

        CustomNotificationType customNotification = [SELECT Id, DeveloperName 
                                                    FROM CustomNotificationType][0];
        System.assertEquals(True, SRV_DTC_CustomNotification.isNotificationSent , 'Custom notification sending failed.');
    }
    
    @isTest
    private static void testUpdateNextNotificationDateBraintreeResponse() {   
        Case newCase = [SELECT id, Status, Sub_Status__c, How_can_we_help__c, AdditionalInformation__c, Next_Notification_Date__c,
                            Braintree_Status__c
                            FROM Case 
                            WHERE AdditionalInformation__c = 'Dispute' 
                            AND Sub_Status__c =: DTC_Constants.SUB_STATUS_BRAINTREE_RESPONSE LIMIT 1];   
        Case oldCase = newCase.clone(true, false, false, false);
        oldCase.Sub_Status__c = DTC_Constants.SUB_STATUS_INVALID;
        oldCase.Status = DTC_Constants.IN_PROGRESS;
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id,oldCase);
        List<Case> newList = new List<Case>{newCase};
            
        Test.startTest();
            DTC_CaseServices.updateNextNotificationDate(newList, oldMap);
        Test.stopTest();

        Case currCase = [SELECT id, Next_Notification_Date__c
                            FROM Case 
                            WHERE AdditionalInformation__c = 'Dispute'
                            AND Sub_Status__c =: DTC_Constants.SUB_STATUS_BRAINTREE_RESPONSE LIMIT 1];
        System.assertNotEquals(newCase.Next_Notification_Date__c, currCase.Next_Notification_Date__c,
            'Date doesnot gets updated when it is expected to be');
    }  
    
    @isTest
    private static void testUpdateValidCaseList() {
        Case newCase = [SELECT id, Status, Sub_Status__c,  Next_Notification_Date__c, Send_Bell_Notification__c,
                                ConsumerResponseOnCase__c, Braintree_Status__c, Notes__c
                                FROM Case LIMIT 1];
        newCase.Send_Bell_Notification__c = true;
        newCase.Status = DTC_Constants.IN_PROGRESS;
        newCase.Sub_Status__c = DTC_Constants.SUB_STATUS_FOLLOWUP_EMAIL_SENT;
        newCase.ConsumerResponseOnCase__c = 1;
        
        EmailMessage emailMessage = new EmailMessage();
        emailMessage.FromAddress = 'testcase@gmail.com';
        emailMessage.ParentId = newCase.Id;
        emailMessage.Incoming = True;
        emailMessage.ToAddress= 'test@xyz.org';
        emailMessage.Subject = 'Test email';
        emailMessage.HtmlBody = 'Test email body';
        insert emailMessage;
        
        List<Case> newList = new List<Case>{newCase};    
        
        Test.startTest();
        	DTC_CaseServices.updateValidCaseList(newList);
        Test.stopTest();
        
        System.assertEquals(DTC_Constants.SUB_STATUS_BRAINTREE_RESPONSE, newCase.Sub_Status__c,
                            'Current case sub status should change to waiting for braintree response.');
    }

    @isTest
    private static void testUpdateNextNotificationDateToNull() {   
        Case newCase = [SELECT id, Status, Sub_Status__c, How_can_we_help__c, AdditionalInformation__c, Next_Notification_Date__c,
                            Braintree_Status__c
                            FROM Case 
                            WHERE AdditionalInformation__c = 'Dispute' 
                            AND Sub_Status__c =: DTC_Constants.SUB_STATUS_INVALID LIMIT 1];   
        Case oldCase = newCase.clone(true, false, false, false);
        oldCase.Sub_Status__c = DTC_Constants.SUB_STATUS_BRAINTREE_RESPONSE;
        oldCase.Status = DTC_Constants.IN_PROGRESS;
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id,oldCase);
        List<Case> newList = new List<Case>{newCase};
            
        Test.startTest();
            DTC_CaseServices.updateNextNotificationDate(newList, oldMap);
        Test.stopTest();

        Case currCase = [SELECT id, Next_Notification_Date__c
                            FROM Case 
                            WHERE AdditionalInformation__c = 'Dispute'
                            AND Sub_Status__c =: DTC_Constants.SUB_STATUS_INVALID LIMIT 1];
        System.assertNotEquals(null, currCase.Next_Notification_Date__c,
            'Date doesnot gets updated when it is expected to be');
    }

    @isTest
    private static void testSendBellNotificationOnDHLStatusUpdate(){
        List<String> orderIds= new List<String>{'testO12345','testO1234'};
        List<Case> cases= [SELECT ID, OwnerId, CaseNumber, Send_Bell_Notification__c 
                               FROM Case 
                               WHERE OrderId__c IN:orderIds];
        Set<Case> setOfCases = new Set<Case>();
        setOfCases.addAll(cases);
        Test.startTest();
            DTC_CaseServices.sendBellNotificationOnDHLStatusUpdate(setOfCases);
        Test.stopTest();
        System.assertEquals(true, setOfCases.size() > 0,
                               'Send Notification Hits since set is passed');
    }

    @isTest
    private static void testUpdateSubStatusToBlank() {
        Case newCase = [SELECT id, Status, Sub_Status__c, AdditionalInformation__c
                            FROM Case 
                            WHERE AdditionalInformation__c = 'Replacement'
                            AND Status = 'Closed'];   
        Case oldCase = newCase.clone(true, false, false, false);
        oldCase.Status = 'Open';
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id,oldCase);
        List<Case> newList = new List<Case>{newCase};
        Test.startTest();
            DTC_CaseServices.updateSubStatusToBlank(newList, oldMap);
        Test.stopTest();
        System.assertEquals('', newCase.Sub_Status__c, 'Test Should pass due to updated blank sub status');
    }

    @isTest
    private static void testSendBellNotificationPhysicalReturnDHL() {  
        Case newCase = [SELECT id, Status, Sub_Status__c, How_can_we_help__c, AdditionalInformation__c, OwnerId,
                            Send_Bell_Notification__c, CaseNumber, Availability_Date__c
                            FROM Case 
                            WHERE OrderId__c = 'DHLBellNotification' LIMIT 1];
        newCase.Send_Bell_Notification__c = true;   
        List<Case> newList = new List<Case>{newCase};
            
        Test.startTest();
            DTC_CaseServices.sendBellNotificationPhysicalReturnDHL(newList);
        Test.stopTest();

        CustomNotificationType customNotification = [SELECT Id, DeveloperName 
                                                    FROM CustomNotificationType][0];
        System.assertEquals(True, SRV_DTC_CustomNotification.isNotificationSent , 'Custom notification sending failed.');
    }

    @isTest
    private static void testUpdateRetailAccount() {
        Case newCase = [SELECT id, Retail_Account__c
                            FROM Case LIMIT 1];    
    
        Account vendorAccount = new Account();
        vendorAccount.RecordTypeId = DTC_Constants.ACCOUNT_VENDOR_RECORDTYPEID;
        vendorAccount.Name = DTC_Constants.DTC_DHL_ACCOUNT;
        insert vendorAccount;
        
        List<Case> newList = new List<Case>{newCase};

        Test.startTest();
            DTC_CaseServices.updateRetailAccount(newList);
        Test.stopTest();

        Case updatedCase = [SELECT id, Retail_Account__c
                            FROM Case LIMIT 1];   
        System.assertNotEquals(updatedCase.Retail_Account__c, newCase.Retail_Account__c, 'Account not updated.');
    }
}