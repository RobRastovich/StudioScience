@isTest
public class QC_FACTSIncidentCtrlTest {

    public static Id factsRecordTypeId = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get('FACTS').getRecordTypeId();
    public static Id qcRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Quality_Claim').getRecordTypeId();
    public static Id qcscRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Quality_Claim_Sub_Case').getRecordTypeId();
    public static Id distributorRecordTypeId = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get('Distributor').getRecordTypeId();
    public static Id retailRTId = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get('Retail').getRecordTypeId();
    public static Id consumerRTId = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();

    @testSetup static void setupFACTSIncidentCtrl() {

        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;

        List<Incident__c> incidents = new List<Incident__c>();

        Incident__c inc1 = new Incident__c();
        inc1.RecordTypeId = factsRecordTypeId;
        inc1.Status__c = 'New';
        incidents.add(inc1);

        Incident__c inc2 = new Incident__c();
        inc2.RecordTypeId = distributorRecordTypeId;
        inc2.Status__c = 'New';
        inc2.Account__c = testAccount.Id;
        incidents.add(inc2);

        insert incidents;

        inc2.Parent_Incident__c = inc1.Id;

        update inc2;

        List<Case> cases = new List<Case>();

        Case case1 = new Case();
        case1.RecordTypeId = qcRT;
        case1.Complaint_Source__c = 'Consumer';
        case1.Type = 'Liquid';
        cases.add(case1);

        Case case2 = new Case();
        case2.RecordTypeId = qcRT;
        case2.Complaint_Source__c = 'Distributor';
        case2.Location_Name__c = 'Test Distributor';
        case2.Type = 'Liquid';
        cases.add(case2);

        Case case3 = new Case();
        case3.RecordTypeId = qcRT;
        case3.Complaint_Source__c = 'Distributor';
        case3.AccountId = testAccount.Id;
        case3.Type = 'Liquid';
        cases.add(case3);

        Case case4 = new Case();
        case4.RecordTypeId = qcRT;
        case4.Complaint_Source__c = 'Retail';
        case4.Location_Name__c = 'Test Retailer';
        case4.Type = 'Liquid';
        cases.add(case4);

        Case case5 = new Case();
        case5.RecordTypeId = qcRT;
        case5.Complaint_Source__c = 'Retail';
        case5.AccountId = testAccount.Id;
        case5.Type = 'Liquid';
        cases.add(case5);

        Case testDestroyCase = new Case();
        testDestroyCase.RecordTypeId = qcRT;
        testDestroyCase.Incident__c = inc2.Id;
        testDestroyCase.Type = 'FACT';
        cases.add(testDestroyCase);

        insert cases;

    }

    public static Account getAccountByName(String name) {
        return [SELECT Id FROM Account WHERE Name = :name LIMIT 1];
    }

    public static Id getDefaultCSAccountId() {
        List<Account> accts = [SELECT Id, RecordTypeId, Name
                               FROM Account
                               WHERE Name = :CSConstants.DEFAULT_ACCOUNT_NAME
                               AND RecordTypeId = :CSConstants.DEFAULT_ACCOUNT_RT_ID LIMIT 1];
        if (!accts.isEmpty()) {
            return accts[0].Id;
        } else {
            return null;
        }
    }

    @isTest static void createIncidentWithConsumerTest() {
        List<Case> cases = [SELECT Id, RecordTypeId, Incident__c, Complaint_Source__c, AccountId, Location_Name__c, Type FROM Case WHERE Type != 'FACT'];
        Id defaultCSAccountId = getDefaultCSAccountId();

        String casesString = JSON.serialize(cases);

        Test.startTest();

        QC_FACTSIncidentCtrl.createIncident(casesString);

        Test.stopTest();

        List<Incident__c> consumerIncidents = [SELECT Id, RecordTypeId, Account__c, Account_Name__c, Parent_Incident__c FROM Incident__c WHERE RecordTypeId = :consumerRTId];

        Incident__c parentForThisTest = [SELECT Id FROM Incident__c WHERE Id = :consumerIncidents[0].Parent_Incident__c LIMIT 1];

        List<Incident__c> distributorIncidents = [SELECT Id, RecordTypeId, Account__c, Account_Name__c, Parent_Incident__c FROM Incident__c WHERE RecordTypeId = :distributorRecordTypeId AND Parent_Incident__c = :parentForThisTest.Id];
        List<Incident__c> retailerIncidents = [SELECT Id, RecordTypeId, Account__c, Account_Name__c FROM Incident__c WHERE RecordTypeId = :retailRTId];

        Account testAccount = getAccountByName('Test Account');

        System.assertEquals(2, distributorIncidents.size());
        System.assertEquals(2, retailerIncidents.size());
        System.assertEquals(1, consumerIncidents.size());

        for (Incident__c distributorIncident : distributorIncidents) {
            System.assertEquals(distributorRecordTypeId, distributorIncident.RecordTypeId);
            if (distributorIncident.Account__c != null && distributorIncident.Account__c != defaultCSAccountId) {
                System.assertEquals(testAccount.Id, distributorIncident.Account__c);
            } else if (!String.isBlank(distributorIncident.Account_Name__c)) {
                System.assertEquals('Test Distributor', distributorIncident.Account_Name__c);
            }
        }

        for (Incident__c retailerIncident : retailerIncidents) {
            System.assertEquals(retailRTId, retailerIncident.RecordTypeId);
            if (retailerIncident.Account__c != null && retailerIncident.Account__c != defaultCSAccountId) {
                System.assertEquals(testAccount.Id, retailerIncident.Account__c);
            } else if (!String.isBlank(retailerIncident.Account_Name__c)) {
                System.assertEquals('Test Retailer', retailerIncident.Account_Name__c);
            }
        }

        System.assertEquals(consumerRTId, consumerIncidents[0].RecordTypeId);

        List<Case> casesAfterTest = [SELECT Id, Incident__c, Type FROM Case WHERE Type != 'FACT'];

        for (Case c : casesAfterTest) {
            System.assertNotEquals(null, c.Incident__c);
        }
    }

    @isTest static void createIncidentNoConsumerTest() {
        List<Case> cases = [SELECT Id, RecordTypeId, Incident__c, Complaint_Source__c, AccountId, Location_Name__c, Type FROM Case WHERE Type != 'FACT' AND Complaint_Source__c != 'Consumer'];
        Id defaultCSAccountId = getDefaultCSAccountId();

        String casesString = JSON.serialize(cases);

        Test.startTest();

        QC_FACTSIncidentCtrl.createIncident(casesString);

        Test.stopTest();

        List<Incident__c> retailerIncidents = [SELECT Id, RecordTypeId, Account__c, Account_Name__c, Parent_Incident__c FROM Incident__c WHERE RecordTypeId = :retailRTId];

        Incident__c parentForThisTest = [SELECT Id FROM Incident__c WHERE Id = :retailerIncidents[0].Parent_Incident__c LIMIT 1];

        List<Incident__c> distributorIncidents = [SELECT Id, RecordTypeId, Account__c, Account_Name__c, Parent_Incident__c FROM Incident__c WHERE RecordTypeId = :distributorRecordTypeId AND Parent_Incident__c = :parentForThisTest.Id];
        List<Incident__c> consumerIncidents = [SELECT Id, RecordTypeId, Account__c, Account_Name__c FROM Incident__c WHERE RecordTypeId = :consumerRTId];

        Account testAccount = getAccountByName('Test Account');

        System.assertEquals(2, distributorIncidents.size());
        System.assertEquals(2, retailerIncidents.size());
        System.assertEquals(0, consumerIncidents.size());

        for (Incident__c distributorIncident : distributorIncidents) {
            System.assertEquals(distributorRecordTypeId, distributorIncident.RecordTypeId);
            if (distributorIncident.Account__c != null && distributorIncident.Account__c != defaultCSAccountId) {
                System.assertEquals(testAccount.Id, distributorIncident.Account__c);
            } else if (!String.isBlank(distributorIncident.Account_Name__c)) {
                System.assertEquals('Test Distributor', distributorIncident.Account_Name__c);
            }
        }

        for (Incident__c retailerIncident : retailerIncidents) {
            System.assertEquals(retailRTId, retailerIncident.RecordTypeId);
            if (retailerIncident.Account__c != null && retailerIncident.Account__c != defaultCSAccountId) {
                System.assertEquals(testAccount.Id, retailerIncident.Account__c);
            } else if (!String.isBlank(retailerIncident.Account_Name__c)) {
                System.assertEquals('Test Retailer', retailerIncident.Account_Name__c);
            }
        }

        List<Case> casesAfterTest = [SELECT Id, RecordTypeId, Incident__c, Complaint_Source__c, AccountId, Location_Name__c, Type FROM Case WHERE Type != 'FACT' AND Complaint_Source__c != 'Consumer'];

        for (Case c : casesAfterTest) {
            System.assertNotEquals(null, c.Incident__c, c);
        }
    }

    @isTest static void destroyIncidentTest() {
        Incident__c parentIncident = [SELECT Id, RecordTypeId FROM Incident__c WHERE RecordTypeId = :factsRecordTypeId LIMIT 1];

        //Will be one parent, one subcase
        List<Case> factsCases = [SELECT Id, Type, ParentId, RecordTypeId FROM Case WHERE Type = 'FACT'];
        Case parentFactCase = [SELECT Id, Type, ParentId, RecordTypeId FROM Case WHERE Type = 'FACT' AND ParentId = null LIMIT 1];

        //System.assertEquals(2, factsCases.size());
        for (Case factCase : factsCases) {
            if (factCase.ParentId != null) {
                System.assertEquals(qcscRT, factCase.RecordTypeId);
                System.assertEquals(parentFactCase.Id, factCase.ParentId);
            } else {
                System.assertEquals(qcRT, factCase.RecordTypeId);
            }
        }

        Test.startTest();

        QC_FACTSIncidentCtrl.destroyIncident(parentIncident.Id);

        Test.stopTest();

        List<Incident__c> incidents = [SELECT Id FROM Incident__c];

        List<Case> destroyedCases = [SELECT Id, Type FROM Case WHERE Type = 'FACT'];

        List<Case> remainingCases = [SELECT Id, Type FROM Case WHERE Type != 'FACT'];

        System.assertEquals(0, incidents.size());

        System.assertEquals(0, destroyedCases.size());

        System.assertEquals(true, remainingCases.size() > 0);
    }
}