@isTest
public class EntitlementsServicesTest {

    public static User getTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User u = new User();
        u.Alias = 'beamtu';
        u.Email = 'standarduser@testorg.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LastName = 'Test';
        u.FirstName = 'Test';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = p.Id;
        u.TimeZoneSidKey = 'America/Chicago';
        u.UserName = 'beamsuntorytestuser@test-user-system.com.test-only';
        insert u;

        return u;
    }

    public static Case getTestCase() {
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.BillingState = 'IL';
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();
        insert testAccount;

        Case c = new Case();
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Payroll').getRecordTypeId();
        c.Type = 'Payroll';
        c.AccountId = testAccount.Id;
        insert c;

        return c;
    }

    public static testMethod void testController() {
        EntitlementsServices con = new EntitlementsServices();
    }

    //Need to See Data for Milestones, as Milestones can't be inserted via Apex as of API 41.0
    @isTest (SeeAllData = true)
    public static void testCompleteMilestoneOnCaseClose() {
        caseServices.runTrigger = false;
        CaseComplianceUtilityTest.insertStateMetadataCustomSetting();
        String entitlementName = ComplianceConstants.ENTITLEMENT_QUOTE_REQUEST;
        Case dummyQRCase = CaseComplianceUtilityTest.createQuoteRequestCase('State Contact');
        Id quoteRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ComplianceConstants.RECORDTYPE_QUOTE_REQUEST).getRecordTypeId();

        insert dummyQRCase;

        Quote_Request__c qr1 = CaseComplianceUtilityTest.createQuoteRequest(dummyQRCase.Id);
        Quote_Request__c qr2 = CaseComplianceUtilityTest.createQuoteRequest(dummyQRCase.Id);
        
    	Entitlement ent = CaseComplianceUtilityTest.createQuoteRequestEntitlement(entitlementName);
    	insert ent;

        CaseComplianceUtility.RequestStatus request = SubmitQuoteRequestController.insertNewQuoteRequest(new List<Quote_Request__c> {qr1, qr2}, 'Ohio', 'High', 'State Contact', '');

        Case qrCase;
        try {
            qrCase = (Case) request.responseMap.get('quoteRequestCase');
            qrCase.Status = 'Waiting for Submission';
            qrCase.Approved__c = true;
            qrCase.OwnerId = UserInfo.getUserId();
            update qrCase;
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            System.assert(false, e.getMessage());
            System.assert(false, 'No case was returned from the method "insertNewQuoteRequest".');
        }

        Test.startTest();

        List<CaseMilestone> completedMilestoneList = [SELECT Id, MilestoneType.Name, CaseId FROM CaseMilestone WHERE isCompleted = True AND CaseId = : qrCase.Id];
        System.assertEquals(0, completedMilestoneList.size(), 'There should be no completed milestones at this time.');

        qrCase.Status = 'Closed';
        update qrCase;

        completedMilestoneList = [SELECT Id, MilestoneType.Name, CaseId FROM CaseMilestone WHERE isCompleted = True AND CaseId = : qrCase.Id];
        System.assertEquals(1, completedMilestoneList.size(), 'After the case is closed, there should be 1 completed CaseMilestone.');

        Test.stopTest();

    }

    @isTest (SeeAllData = false)
    public static void updateClonedMilestonesTest() {
        Case c = getTestCase();
        User testUser = getTestUser();
        List<Cloned_Milestone__c> clonedMilestones = [select Id from Cloned_Milestone__c];
        Set<Id> milestoneIds = new Set<Id>();

        System.assertEquals(0, clonedMilestones.size(), 'No cloned milestones should exist');


        List<CaseMilestone> caseMilestones = EntitlementsServices.getCaseMilestoneByCaseId(new Set<Id> {c.Id});
        for (CaseMilestone cm : caseMilestones) {
            milestoneIds.add(cm.Id);
        }
        Test.startTest();

        System.runAs(testUser) {
            EntitlementsServices.updateClonedMilestonesFuture(milestoneIds, null);
        }

        Test.stopTest();

        List<Cloned_Milestone__c> udpatedClonedMilestones = [select Id,Milestone_Name__c from Cloned_Milestone__c];

        System.assertEquals(1, udpatedClonedMilestones.size(), '1 cloned milestone should exist');
        System.assertEquals('Logged', udpatedClonedMilestones[0].Milestone_Name__c, 'Milestone should be named "Logged"');
    }

}