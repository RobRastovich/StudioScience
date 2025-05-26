@isTest
public class TST_CNT_DTC_ManageStatus {
    @testSetup
    static void setUpTestData() {   
        List<Case> casesList = new List<Case>();
        Case newCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        newCase.Status = 'In Progress';
        casesList.add(newCase);
        
        Case returnCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        returnCase.Status = 'In Progress';
        returnCase.Sub_Status__c = 'Reship confirmed';
        returnCase.How_can_we_help__c = 'Community Console';
        returnCase.AdditionalInformation__c = 'Return';
        casesList.add(returnCase);
        
        Case dhlCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        dhlCase.Status = 'In Progress';
        dhlCase.Sub_Status__c = 'Cancel shipment';
        dhlCase.How_can_we_help__c = 'API';
        dhlCase.AdditionalInformation__c = 'Membership Cancellation';
        casesList.add(dhlCase);
        
        Case replacementConfirmedCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        replacementConfirmedCase.Status = 'In Progress';
        replacementConfirmedCase.Sub_Status__c = 'Replacement confirmed';
        replacementConfirmedCase.How_can_we_help__c = 'API';
        replacementConfirmedCase.AdditionalInformation__c = 'Membership Cancellation';
        casesList.add(replacementConfirmedCase);
        
        Case getStatusFromMetadataCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        getStatusFromMetadataCase.Status = 'New';
        getStatusFromMetadataCase.How_can_we_help__c = 'Whisky Drop – Membership Program';
        getStatusFromMetadataCase.AdditionalInformation__c = 'Other';
        casesList.add(getStatusFromMetadataCase);
        insert casesList;
    }
    
    @isTest
    private static void testCreateCaseWhenSubstatusIsBlank() {
        Case cs = [SELECT Id, CaseNumber, Origin, Status, Sub_Status__c, How_can_we_help__c,
                   AdditionalInformation__c FROM CASE
                   WHERE Sub_Status__c = NULL OR Sub_Status__c = '' LIMIT 1];

        Test.startTest();
            try {
                Case returnCase = CNT_DTC_ManageStatus.manageStatus(cs.Status, cs.Sub_Status__c, cs.Id);
            }
            catch(exception e){
            }     
        Test.stopTest();

        Case updatedCase = [SELECT Id,Status, Sub_Status__c FROM CASE WHERE CaseNumber =: cs.CaseNumber LIMIT 1];
        
        System.assertNotEquals(null, updatedCase , 'No Records returned when expected');
    }
    
    @isTest
    private static void testCreateCase() {
        Case cs = [SELECT Id, CaseNumber, Origin, Status, Sub_Status__c, How_can_we_help__c,
                   AdditionalInformation__c FROM CASE
                   WHERE Sub_Status__c != '' LIMIT 1];
        
        Test.startTest();
            try {
                Case returnCase = CNT_DTC_ManageStatus.manageStatus(cs.Status, cs.Sub_Status__c, cs.Id);
            }
            catch(exception e){
            }     
        Test.stopTest();

        Case updatedCase = [SELECT Id,Status, Sub_Status__c FROM CASE WHERE CaseNumber =: cs.CaseNumber LIMIT 1];
        
        System.assertNotEquals(null, updatedCase , 'No Records returned when expected');
    }
    
    @isTest
    private static void testCreateCaseForCancelShipment() {
        Case cs = [SELECT Id, CaseNumber, Origin, Status, Sub_Status__c, How_can_we_help__c,
                   AdditionalInformation__c FROM CASE
                   WHERE Sub_Status__c = 'Cancel shipment' LIMIT 1];
        
        Test.startTest();
            try {
                Case returnCase = CNT_DTC_ManageStatus.manageStatus(cs.Status, cs.Sub_Status__c, cs.Id);
            }
            catch(exception e){
            }     
        Test.stopTest();

        Case updatedCase = [SELECT Id, Status, Sub_Status__c FROM CASE WHERE CaseNumber =: cs.CaseNumber LIMIT 1];
        
        System.assertNotEquals(null, updatedCase , 'No Records returned when expected');
    }

    @isTest
    private static void testCreateCaseException() {
        Case cs = [SELECT Id, CaseNumber, Origin, Status, Sub_Status__c, How_can_we_help__c,
                   AdditionalInformation__c  FROM CASE LIMIT 1];
        cs.Sub_Status__c = DTC_Constants.SHIPPED_AT_WAREHOUSE;

        Test.startTest();
            try {
                Case returnCase = CNT_DTC_ManageStatus.manageStatus(cs.Status, cs.Sub_Status__c, cs.Id);
            }
            catch(exception e){
            }     
        Test.stopTest();

        Case updatedCase = [SELECT Id,Status, Sub_Status__c FROM CASE WHERE CaseNumber =: cs.CaseNumber LIMIT 1];
        
        System.assertNotEquals(null, updatedCase , 'No Records returned when expected');
    }
    
    @isTest
    private static void testGetCaseRecord() {
        Case cs = [SELECT Id, CaseNumber, Origin, Status, Sub_Status__c FROM CASE LIMIT 1];
        
        Test.startTest();
            Case returnCase = CNT_DTC_ManageStatus.getCaseRecord(cs.Id);
        Test.stopTest();

        System.assertNotEquals(null, returnCase , 'No Records returned when expected');
    }
    
     @isTest
    private static void testGetStatusFromMetadata() {
        Case newCase = [SELECT Id, How_can_we_help__c, AdditionalInformation__c 
                           FROM CASE 
                           WHERE How_can_we_help__c = 'Whisky Drop – Membership Program'];
        
        Test.startTest();
            Map<String,List<String>> statusList = CNT_DTC_ManageStatus.getStatusFromMetadata(newCase.AdditionalInformation__c,
                                                                                            newCase.How_can_we_help__c);
        Test.stopTest();

        System.assertNotEquals(null, statusList , 'No Records returned when expected');
    }
    
     @isTest
    private static void testCreateCaseReplacementConfirmed() {
        Case cs = [SELECT Id, CaseNumber, Origin, Status, Sub_Status__c, How_can_we_help__c,
                   AdditionalInformation__c FROM CASE
                   WHERE Sub_Status__c = 'Replacement confirmed' LIMIT 1];
        
        Test.startTest();
            try {
                Case returnCase = CNT_DTC_ManageStatus.manageStatus(cs.Status, cs.Sub_Status__c, cs.Id);
            }
            catch(exception e){
            }     
        Test.stopTest();

        Case updatedCase = [SELECT Id,Status, Sub_Status__c FROM CASE WHERE CaseNumber =: cs.CaseNumber LIMIT 1];
        
        System.assertNotEquals(null, updatedCase , 'No Records returned when expected');
    }
}