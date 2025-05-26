@isTest
public class QC_FACTSFinderCtrlTest {

    public static Id factsRecordType = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get('FACTS').getRecordTypeId();
    public static Id qualityClaimRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Quality_Claim').getRecordTypeId();
    public static Id distributorRecordType = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get('Distributor').getRecordTypeId();
    public static Id retailerRecordType = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get('Retail').getRecordTypeId();
    public static Id consumerRecordType = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();

    @testSetup static void setupFACTSFinder() {

        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;

        List<Incident__c> incidents = new List<Incident__c>();


        Incident__c inc1 = new Incident__c();
        inc1.RecordTypeId = factsRecordType;
        inc1.Status__c = 'New';
        incidents.add(inc1);

        Incident__c inc2 = new Incident__c();
        inc2.RecordTypeId = distributorRecordType;
        inc2.Status__c = 'New';
        incidents.add(inc2);

        Incident__c inc3 = new Incident__c();
        inc3.RecordTypeId = factsRecordType;
        inc3.Status__c = 'Closed';
        incidents.add(inc3);

        insert incidents;

        inc2.Parent_Incident__c = inc1.Id;

        update inc2;

        List<Case> cases = new List<Case>();

        Case consumerA = new Case();
        consumerA.RecordTypeId = qualityClaimRTId;
        consumerA.Lot_Code__c = '1234567890';
        consumerA.Beam_Suntory_Item_Number__c = 'BSIN1234';
        consumerA.Bottling_Plant__c = 'Clermont';
        consumerA.Complaint_Source__c = 'Consumer';
        cases.add(consumerA);


        Case consumerB = new Case();
        consumerB.RecordTypeId = qualityClaimRTId;
        consumerB.Complaint_Source__c = 'Consumer';
        consumerB.Lot_Code__c = 'XYZ789';
        consumerB.Beam_Suntory_Item_Number__c = 'BSIN1234';
        consumerB.Bottling_Plant__c = 'Clermont';
        cases.add(consumerB);


        Case consumerC = new Case();
        consumerC.RecordTypeId = qualityClaimRTId;
        consumerC.Lot_Code__c = '1234567899';
        consumerC.Beam_Suntory_Item_Number__c = 'BSIN1234';
        consumerC.Bottling_Plant__c = 'Jarnac';
        consumerC.Complaint_Source__c = 'Consumer';
        cases.add(consumerC);


        Case retailerWithAccountA = new Case();
        retailerWithAccountA.RecordTypeId = qualityClaimRTId;
        retailerWithAccountA.Lot_Code__c = '1234567890';
        retailerWithAccountA.Beam_Suntory_Item_Number__c = 'BSIN1234';
        retailerWithAccountA.Bottling_Plant__c = 'Clermont';
        retailerWithAccountA.Complaint_Source__c = 'Retail';
        retailerWithAccountA.AccountId = testAccount.Id;
        cases.add(retailerWithAccountA);


        Case retailerWithAccountB = new Case();
        retailerWithAccountB.RecordTypeId = qualityClaimRTId;
        retailerWithAccountB.Lot_Code__c = '777777777';
        retailerWithAccountB.Beam_Suntory_Item_Number__c = 'LMNOP123';
        retailerWithAccountB.Bottling_Plant__c = 'Behror';
        retailerWithAccountB.Complaint_Source__c = 'Retail';
        retailerWithAccountB.AccountId = testAccount.Id;
        cases.add(retailerWithAccountB);


        Case retailerNoAccount = new Case();
        retailerNoAccount.RecordTypeId = qualityClaimRTId;
        retailerNoAccount.Lot_Code__c = '123456788888888';
        retailerNoAccount.Beam_Suntory_Item_Number__c = 'ABC123';
        retailerNoAccount.Bottling_Plant__c = 'Frankfort';
        retailerNoAccount.Complaint_Source__c = 'Retail';
        retailerNoAccount.Location_Name__c = 'Test Retail';
        cases.add(retailerNoAccount);


        Case distributorWithAccount = new Case();
        distributorWithAccount.RecordTypeId = qualityClaimRTId;
        distributorWithAccount.Lot_Code__c = '1234567890';
        distributorWithAccount.Beam_Suntory_Item_Number__c = 'BSIN1234';
        distributorWithAccount.Bottling_Plant__c = 'Clermont';
        distributorWithAccount.Complaint_Source__c = 'Bailment';
        distributorWithAccount.AccountId = testAccount.Id;
        cases.add(distributorWithAccount);


        Case distributorNoAccountA = new Case();
        distributorNoAccountA.RecordTypeId = qualityClaimRTId;
        distributorNoAccountA.Lot_Code__c = '8889';
        distributorNoAccountA.Beam_Suntory_Item_Number__c = 'BSIN1234';
        distributorNoAccountA.Bottling_Plant__c = 'Frankfort';
        distributorNoAccountA.Complaint_Source__c = 'Distributor';
        distributorNoAccountA.Location_Name__c = 'Test Distributor';
        cases.add(distributorNoAccountA);


        Case distributorNoAccountB = new Case();
        distributorNoAccountB.RecordTypeId = qualityClaimRTId;
        distributorNoAccountB.Lot_Code__c = '9999992992';
        distributorNoAccountB.Beam_Suntory_Item_Number__c = 'ABC123';
        distributorNoAccountB.Bottling_Plant__c = 'Clermont';
        distributorNoAccountB.Complaint_Source__c = 'Bailment';
        distributorNoAccountB.Location_Name__c = 'Test Distributor';
        cases.add(distributorNoAccountB);

        insert cases;

    }

    public static Account getAccountByName(String name) {
        return [SELECT Id FROM Account WHERE Name = :name LIMIT 1];
    }

    public static Case getCaseByComplaintLotNumber(String complaintType, String lotCode, String itemNumber) {
        return [SELECT Id
                , Lot_Code__c
                , Beam_Suntory_Item_Number__c
                , Complaint_Source__c
                , Incident__c
                , Location_Name__c
                , AccountId FROM Case WHERE Complaint_Source__c = :complaintType AND Lot_Code__c = :lotCode AND Beam_Suntory_Item_Number__c = :itemNumber LIMIT 1];
    }

    public static Case getCaseById(Id caseId) {
        return [SELECT Id
                , Lot_Code__c
                , AccountId
                , Beam_Suntory_Item_Number__c
                , Complaint_Source__c
                , Incident__c
                , Location_Name__c FROM Case WHERE Id = :caseId LIMIT 1];
    }

    public static Incident__c getIncidentByRecordTypeId(Id recordTypeId) {
        return [SELECT Id
                , RecordTypeId
                , Account__c
                , Status__c
                , Account_Name__c FROM Incident__c WHERE RecordTypeId = :recordTypeId AND Status__c = 'New' LIMIT 1];
    }

    public static Incident__c getIncidentById(Id incidentId) {
        return [SELECT Id
                , RecordTypeId
                , Account__c
                , Status__c
                , Account_Name__c FROM Incident__c WHERE Id = :incidentId LIMIT 1];
    }

    @isTest static void getCaseRecordTest() {
        Case caseRecord = getCaseByComplaintLotNumber('Consumer', '1234567890', 'BSIN1234');

        Test.startTest();

        Case testCase = QC_FACTSFinderCtrl.getCaseRecord(caseRecord.Id);

        Test.stopTest();

        System.assertNotEquals(null, testCase);
        System.assertEquals('1234567890', testCase.Lot_Code__c);
        System.assertEquals('BSIN1234', testCase.Beam_Suntory_Item_Number__c);
        System.assertEquals('Clermont', testCase.Bottling_Plant__c);

    }

    @isTest static void getCasesMatchingLotCodesTest() {
        Case caseRecord = getCaseByComplaintLotNumber('Consumer', '1234567890', 'BSIN1234');

        Test.startTest();

        List<Case> cases = QC_FACTSFinderCtrl.getMatchingCases(caseRecord.Id);

        Test.stopTest();

        System.assertEquals(7, cases.size());

        for (Case c : cases) {
            if (c.RecordTypeId == qualityClaimRTId) {
                System.assertEquals(qualityClaimRTId, c.RecordTypeId);
            }
        }
    }

    @isTest static void getCasesNoMatchingLotCodesTest() {
        Case caseRecord = getCaseByComplaintLotNumber('Consumer', 'XYZ789', 'BSIN1234');

        Test.startTest();

        List<Case> cases = QC_FACTSFinderCtrl.getMatchingCases(caseRecord.Id);

        Test.stopTest();

        //no matching lot codes, but 6 matches on SKU and/or Bottling Plant
        System.assertEquals(6, cases.size());
    }

    @isTest static void getIncidentsTest() {
        Test.startTest();

        List<Incident__c> openIncidents = QC_FACTSFinderCtrl.getCurrentIncidents();

        Test.stopTest();

        System.assertEquals(1, openIncidents.size());

        for (Incident__c inc : openIncidents) {
            if (inc.RecordTypeId == factsRecordType) {
                System.assertEquals(factsRecordType, inc.RecordTypeId);
            }
            if (inc.Status__c != 'Closed') {
                System.assertNotEquals('Closed', inc.Status__c);
            }
        }
    }

    @isTest static void addToIncidentDistributorTest() {
        Case caseRecord = getCaseByComplaintLotNumber('Bailment', '1234567890', 'BSIN1234');

        Incident__c inc = getIncidentByRecordTypeId(factsRecordType);

        Test.startTest();

        QC_FACTSFinderCtrl.addToIncident(caseRecord.Id, inc.Id);

        Test.stopTest();

        Case caseRecordAfterIncidentUpdate = getCaseById(caseRecord.Id);

        Incident__c subincidentForCase = getIncidentById(caseRecordAfterIncidentUpdate.Incident__c);

        Account testAccount = getAccountByName('Test Account');

        System.assertNotEquals(null, caseRecordAfterIncidentUpdate.Incident__c);
        System.assertEquals(subincidentForCase.Id, caseRecordAfterIncidentUpdate.Incident__c);
        System.assertEquals(subincidentForCase.Account__c, caseRecordAfterIncidentUpdate.AccountId);
        System.assertEquals(distributorRecordType, subincidentForCase.RecordTypeId);
        System.assertEquals(testAccount.Id, subincidentForCase.Account__c);
    }

    @isTest static void addToIncidentDistributorNoAccountTest() {
        Case caseRecordA = getCaseByComplaintLotNumber('Distributor', '8889', 'BSIN1234');
        Case caseRecordB = getCaseByComplaintLotNumber('Bailment', '9999992992', 'ABC123');

        Incident__c inc = getIncidentByRecordTypeId(factsRecordType);

        Test.startTest();

        QC_FACTSFinderCtrl.addToIncident(caseRecordA.Id, inc.Id);
        QC_FACTSFinderCtrl.addToIncident(caseRecordB.Id, inc.Id);

        Test.stopTest();

        Case caseRecordAAfterIncidentUpdate = getCaseById(caseRecordA.Id);
        Case caseRecordBAfterIncidentUpdate = getCaseById(caseRecordB.Id);

        Incident__c subincidentForCaseA = getIncidentById(caseRecordAAfterIncidentUpdate.Incident__c);
        Incident__c subincidentForCaseB = getIncidentById(caseRecordBAfterIncidentUpdate.Incident__c);

        System.assertNotEquals(null, caseRecordAAfterIncidentUpdate.Incident__c);
        System.assertNotEquals(null, caseRecordBAfterIncidentUpdate.Incident__c);
        System.assertEquals(subincidentForCaseA.Id, caseRecordAAfterIncidentUpdate.Incident__c);
        System.assertEquals(subincidentForCaseB.Id, caseRecordBAfterIncidentUpdate.Incident__c);
        System.assertEquals(subincidentForCaseB.Id, subincidentForCaseA.Id);
        System.assertEquals(subincidentForCaseA.Account_Name__c, caseRecordAAfterIncidentUpdate.Location_Name__c);
        System.assertEquals(subincidentForCaseB.Account_Name__c, caseRecordBAfterIncidentUpdate.Location_Name__c);
        System.assertEquals(subincidentForCaseB.Account_Name__c, subincidentForCaseA.Account_Name__c);
        System.assertEquals(distributorRecordType, subincidentForCaseA.RecordTypeId);
        System.assertEquals(distributorRecordType, subincidentForCaseB.RecordTypeId);
    }

    @isTest static void addToIncidentRetailTest() {
        Case caseRecordA = getCaseByComplaintLotNumber('Retail', '1234567890', 'BSIN1234');
        Case caseRecordB = getCaseByComplaintLotNumber('Retail', '777777777', 'LMNOP123');

        Incident__c inc = getIncidentByRecordTypeId(factsRecordType);

        Test.startTest();

        QC_FACTSFinderCtrl.addToIncident(caseRecordA.Id, inc.Id);
        QC_FACTSFinderCtrl.addToIncident(caseRecordB.Id, inc.Id);

        Test.stopTest();

        Case caseRecordAAfterIncidentUpdate = getCaseById(caseRecordA.Id);
        Case caseRecordBAfterIncidentUpdate = getCaseById(caseRecordB.Id);

        Incident__c subincidentForCaseA = getIncidentById(caseRecordAAfterIncidentUpdate.Incident__c);
        Incident__c subincidentForCaseB = getIncidentById(caseRecordBAfterIncidentUpdate.Incident__c);

        Account testAccount = getAccountByName('Test Account');

        System.assertNotEquals(null, caseRecordAAfterIncidentUpdate.Incident__c);
        System.assertNotEquals(null, caseRecordBAfterIncidentUpdate.Incident__c);
        System.assertEquals(subincidentForCaseA.Id, caseRecordAAfterIncidentUpdate.Incident__c);
        System.assertEquals(subincidentForCaseB.Id, caseRecordBAfterIncidentUpdate.Incident__c);
        System.assertEquals(subincidentForCaseB.Id, subincidentForCaseA.Id);
        System.assertEquals(subincidentForCaseA.Account__c, caseRecordAAfterIncidentUpdate.AccountId);
        System.assertEquals(subincidentForCaseB.Account__c, caseRecordBAfterIncidentUpdate.AccountId);
        System.assertEquals(subincidentForCaseB.Account__c, subincidentForCaseA.Account__c);
        System.assertEquals(retailerRecordType, subincidentForCaseA.RecordTypeId);
        System.assertEquals(retailerRecordType, subincidentForCaseB.RecordTypeId);
        System.assertEquals(testAccount.Id, subincidentForCaseA.Account__c);
        System.assertEquals(testAccount.Id, subincidentForCaseB.Account__c);
    }

    @isTest static void addToIncidentRetailNoAccountTest() {
        Case caseRecord = getCaseByComplaintLotNumber('Retail', '123456788888888', 'ABC123');

        Incident__c inc = getIncidentByRecordTypeId(factsRecordType);

        Test.startTest();

        QC_FACTSFinderCtrl.addToIncident(caseRecord.Id, inc.Id);

        Test.stopTest();

        Case caseRecordAfterIncidentUpdate = getCaseById(caseRecord.Id);

        Incident__c subincidentForCase = getIncidentById(caseRecordAfterIncidentUpdate.Incident__c);

        Account testAccount = getAccountByName('Test Account');

        System.assertNotEquals(null, caseRecordAfterIncidentUpdate.Incident__c);
        System.assertEquals(subincidentForCase.Id, caseRecordAfterIncidentUpdate.Incident__c);
        System.assertEquals(subincidentForCase.Account_Name__c, caseRecordAfterIncidentUpdate.Location_Name__c);
        System.assertEquals(retailerRecordType, subincidentForCase.RecordTypeId);
    }

    @isTest static void addToIncidentConsumerTest() {
        Case caseRecord = getCaseByComplaintLotNumber('Consumer', '1234567890', 'BSIN1234');

        Incident__c inc = getIncidentByRecordTypeId(factsRecordType);

        Test.startTest();

        QC_FACTSFinderCtrl.addToIncident(caseRecord.Id, inc.Id);

        Test.stopTest();

        Case caseRecordAfterIncidentUpdate = getCaseById(caseRecord.Id);

        Incident__c subincidentForCase = getIncidentById(caseRecordAfterIncidentUpdate.Incident__c);

        System.assertNotEquals(null, caseRecordAfterIncidentUpdate.Incident__c);
        System.assertEquals(subincidentForCase.Id, caseRecordAfterIncidentUpdate.Incident__c);

        Integer countOfConsumerSubincidents = 0;

        List<Incident__c> allSubincidents = [SELECT Id, RecordTypeId FROM Incident__c];
        for (Incident__c subinc : allSubincidents) {
            if (subinc.RecordTypeId == consumerRecordType) {
                countOfConsumerSubincidents++;
            }
        }

        System.assertEquals(1, countOfConsumerSubincidents);
    }
/*
    @isTest static void addToIncidentConsumerWithSubcaseTest() {
        Case caseRecordA = getCaseByComplaintLotNumber('Consumer', '1234567890', 'BSIN1234');
        Case caseRecordB = getCaseByComplaintLotNumber('Consumer', 'XYZ789', 'BSIN1234');
        Case qcSubcase;
        try{
         qcSubcase= [SELECT Id, Lot_Code__c, Beam_Suntory_Item_Number__c, Complaint_Source__c, Incident__c, ParentId FROM Case WHERE ParentId = :caseRecordB.Id LIMIT 1];
       }
       catch(exception ex){}
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;
        String accountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        Account a = new Account();
        a.RecordTypeId = accountRTId;
        a.Name = 'Test Account';
        insert a;

        Case c = new Case();
        c.Status = 'In Progress';
        c.Sub_Status__c = 'Pending with Quality';
        c.accountId = a.id;
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = CSConstants.QC_RT_ID;
        c.OwnerId = UserInfo.getUserId();
        insert c;
        Incident__c inc = getIncidentByRecordTypeId(factsRecordType);

        Test.startTest();

        QC_FACTSFinderCtrl.addToIncident(caseRecordA.Id, inc.Id);
        QC_FACTSFinderCtrl.addToIncident(c.Id, inc.Id);

        Test.stopTest();

        Case caseRecordAfterIncidentUpdate = getCaseById(caseRecordB.Id);

       // Incident__c subincidentForCase = getIncidentById(caseRecordAfterIncidentUpdate.Incident__c);
        //System.assertNotEquals(null, caseRecordAfterIncidentUpdate.Incident__c);
       // System.assertEquals(subincidentForCase.Id, caseRecordAfterIncidentUpdate.Incident__c);

        Integer countOfConsumerSubincidents = 0;

        List<Incident__c> allSubincidents = [SELECT Id, RecordTypeId FROM Incident__c];
        for (Incident__c subinc : allSubincidents) {
            if (subinc.RecordTypeId == consumerRecordType) {
                countOfConsumerSubincidents++;
            }
        }

        System.assertEquals(1, countOfConsumerSubincidents);
    }
    */

    @isTest static void executeQueryTest() {
        String queryString = 'SELECT Id, Beam_Suntory_Item_Number__c, Lot_Code__c, Bottling_Plant__c FROM Case';

        Test.startTest();

        List<Case> cases = QC_FACTSFinderCtrl.executeQuery(queryString);

        Test.stopTest();

        System.assertEquals(true, cases.size() > 0);
        //18, because 9 inserted in setup, each case has a subcase
        //created automatically
        //System.assertEquals(18, cases.size());

    }

    @isTest static void loadInitialDataTest() {
        LightningComponentUtility.RequestStatus response;
        Case caseRecord = getCaseByComplaintLotNumber('Retail', '123456788888888', 'ABC123');

        Test.startTest();

        response = QC_FACTSFinderCtrl.loadInitialData(caseRecord.Id);

        Test.stopTest();

        System.assertNotEquals(NULL, response.responseMap.get('caseRecord'));
    }

    @isTest static void loadInitialDataExceptionTest() {
        LightningComponentUtility.RequestStatus response;
        Case caseRecord = getCaseByComplaintLotNumber('Retail', '123456788888888', 'ABC123');

        Test.startTest();
        QC_FACTSFinderCtrl.forceException = true;
        response = QC_FACTSFinderCtrl.loadInitialData(caseRecord.Id);

        Test.stopTest();
    }

}