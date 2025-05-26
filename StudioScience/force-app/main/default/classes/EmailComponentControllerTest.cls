@isTest
public class EmailComponentControllerTest {

    @testSetup static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = p.Id,
                          TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser@test-user-system.com.test-only');
        //insert u;

        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim).getRecordTypeId();

        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case 2';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        c.Product_Destination_Country__c = 'Sri Lanka';
        c.ccEmail__c = 'test@test.com';
        c.Beam_Suntory_Item_Number__c = '111';
        insert c;

        // create case as another user
        Case c2 = new Case();
        c2.Status = 'New';
        c2.Subject = 'Test Case';
        c2.Submitter__c = UserInfo.getUserId();
        c2.RecordTypeId = recordTypeId;
        c2.ccEmail__c = 'otheruser@test.com';
        c2.Beam_Suntory_Item_Number__c = '222';

        c2.Product_Destination_Country__c = 'Sri Lanka';
        System.runAs(u) {
            insert c2;
        }

        //List<Case> childCases = createChildCaseRecords(System.Label.Order_Claim_Sub_Case, 'New', c.Id, 2, true);
    }

    public static List<Case> createChildCaseRecords(String recordTypeName, String status, Id parentId, Integer numOfChildRecords, Boolean autoCreate) {
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        List<Case> casesToInsert = new List<Case>();
        Case parentCase = new Case();
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.useDefaultRule = true;

        for (Integer i = 0; i < numOfChildRecords; i++) {
            Case c = new Case();
            c.Status = status;
            c.ParentId = parentId;
            c.RecordTypeId = recordTypeId;
            //c.setOptions(dmo);
            casesToInsert.add(c);
        }

        if (autoCreate) {
            insert casesToInsert;
        }

        return casesToInsert;
    }

    public static List<Case> getCasesById(Set<Id> caseIds) {
        return [select id
                , All_Sub_Cases_Closed__c
                , Shipping_Plant__c
                , isReOpened__c
                , Expedited_Claim__c
                , BusinessHoursId
                , BusinessHours.Name
                , Owner.Name
                , OwnerId
                , Beam_Suntory_Item_Number__c
                , Financial_Disposition__c
                , Return_SAP_Number__c
                , ccEmail__c
                , Entitlement.Name from Case where Id IN :caseIds];
    }

    public static List<Case> getCasesByBeamItemNumber(String orderNumber) {
        return [select id
                , All_Sub_Cases_Closed__c
                , Shipping_Plant__c
                , isReOpened__c
                , Expedited_Claim__c
                , BusinessHoursId
                , BusinessHours.Name
                , Owner.Name
                , OwnerId
                , Beam_Suntory_Item_Number__c
                , Financial_Disposition__c
                , Return_SAP_Number__c
                , ccEmail__c
                , Entitlement.Name from Case where Beam_Suntory_Item_Number__c = :orderNumber];
    }

    public static List<Case> getAllCases() {
        return [select id
                , All_Sub_Cases_Closed__c
                , Shipping_Plant__c
                , isReOpened__c
                , Expedited_Claim__c
                , BusinessHoursId
                , BusinessHours.Name
                , Owner.Name
                , OwnerId
                , Subject
                , Beam_Suntory_Item_Number__c
                , Financial_Disposition__c
                , Return_SAP_Number__c
                , ccEmail__c
                , Entitlement.Name from Case];
    }




    public static testMethod void testGetLastCcEmailFromCaseBasedOnUser() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;
        LightningComponentUtility.RequestStatus requestStatus;

        Test.startTest();

        requestStatus = EmailComponentController.getLastCaseEmailFieldByUser(UserInfo.getUserId(), null);

        Test.stopTest();

        System.assertEquals('test@test.com', requestStatus.responseMap.get('allEmails'));
    }

    public static testMethod void testUpdateCcFieldOnCase() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;
        LightningComponentUtility.RequestStatus requestStatus;

        Case caseBefore = getCasesByBeamItemNumber('111')[0];
        System.assertEquals('test@test.com', caseBefore.CcEmail__c);

        Test.startTest();

        requestStatus = EmailComponentController.updateCaseEmailField(caseBefore.Id, 'test@test.com;updatedtest@test.com');

        Test.stopTest();

        Case caseAfter = getCasesByBeamItemNumber('111')[0];


        System.assertEquals('test@test.com;updatedtest@test.com', caseAfter.CcEmail__c);
    }

    public static testMethod void testRemoveCcFieldOnCase() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;
        LightningComponentUtility.RequestStatus requestStatus;

        Case caseBefore = getCasesByBeamItemNumber('111')[0];
        System.assertEquals('test@test.com', caseBefore.CcEmail__c);

        Test.startTest();

        caseBefore.CcEmail__c = 'test@test.com;updatedtest@test.com';
        update caseBefore;

        requestStatus = EmailComponentController.removeEmailFromCase(caseBefore.Id, 'test@test.com');

        Case caseAfter = getCasesByBeamItemNumber('111')[0];

        Test.stopTest();

        System.assertEquals('updatedtest@test.com', caseAfter.CcEmail__c);
    }

    public static testMethod void testsendEmailForOrderClaim() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim).getRecordTypeId();

        Test.startTest();

        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case 2';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        c.Product_Destination_Country__c = 'Sri Lanka';
        c.ccEmail__c = 'test@test.com';
        c.Beam_Suntory_Item_Number__c = '111';
        c.Beam_Suntory_Order_Number__c = '123';
        c.Purchase_Order_Number__c = '123';
        insert c;

        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;

        List<Case> childCases = createChildCaseRecords(System.Label.Order_Claim_Sub_Case, 'New', c.Id, 2, false);

        for (Case cc : childCases) {
            cc.Product_Destination_Country__c = 'US';
            cc.Product_Description__c = 'test';
            cc.Shipping_Plant__c = 'Walkerville';
            cc.Distibutor_Currency__c = 'USD';
            cc.Order_Claim_Amount__c = 1;
            cc.Beam_Suntory_Item_Number__c = '123';
            cc.Beam_Suntory_Order_Number__c = '123';
            cc.Purchase_Order_Number__c = '123';
        }

        insert childCases;

        EmailComponentController.sendEmail('test@tst2.com', c.Id, System.Label.Order_Claim, 'Damage Claim');

        Test.stopTest();

    }

    public static testMethod void testsendEmailForQualityClaim() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Quality_Claim_Label).getRecordTypeId();

        Test.startTest();

        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case 2';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        c.ccEmail__c = 'test@test.com';
        c.Beam_Suntory_Item_Number__c = '111';
        c.Beam_Suntory_Order_Number__c = '123';
        c.Purchase_Order_Number__c = '123';
        insert c;

        EmailComponentController.sendEmail('test@tst2.com', c.Id, System.Label.Quality_Claim_Label, 'Liquid');


        Test.stopTest();
    }

    public static testMethod void testsendEmailForOrdersClaim() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Orders_Label).getRecordTypeId();

        Test.startTest();

        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case 2';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        c.ccEmail__c = 'test@test.com';
        c.Beam_Suntory_Item_Number__c = '111';
        c.Beam_Suntory_Order_Number__c = '123';
        c.Purchase_Order_Number__c = '123';
        insert c;

        EmailComponentController.sendEmail('test@tst2.com', c.Id, System.Label.Orders_Label, 'Bulk');


        Test.stopTest();
    }

    public static testMethod void testsendEmailForChangesClaim() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Changes_Label).getRecordTypeId();

        Test.startTest();


        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case 2';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        c.ccEmail__c = 'test@test.com';
        c.Beam_Suntory_Item_Number__c = '111';
        c.Beam_Suntory_Order_Number__c = '123';
        c.Purchase_Order_Number__c = '123';
        insert c;

        EmailComponentController.sendEmail('test@tst2.com', c.Id, System.Label.Changes_Label, 'Outage');

        Test.stopTest();
    }

    public static testMethod void testsendEmailForEscalatedFormClaim() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Escalated_Form_Label).getRecordTypeId();

        Test.startTest();

        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case 2';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        c.ccEmail__c = 'test@test.com';
        c.Beam_Suntory_Item_Number__c = '111';
        c.Beam_Suntory_Order_Number__c = '123';
        c.Purchase_Order_Number__c = '123';
        insert c;

        EmailComponentController.sendEmail('test@tst2.com', c.Id, System.Label.Escalated_Form_Label, '');

        Test.stopTest();
    }

    public static testMethod void testsendEmailForInquiryClaim() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Inquiry_Label).getRecordTypeId();

        Test.startTest();

        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case 2';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        c.ccEmail__c = 'test@test.com';
        c.Beam_Suntory_Item_Number__c = '111';
        c.Beam_Suntory_Order_Number__c = '123';
        c.Purchase_Order_Number__c = '123';
        insert c;

        EmailComponentController.sendEmail('test@tst2.com', c.Id, System.Label.Inquiry_Label, 'Newsletter');

        Test.stopTest();
    }

    public static testMethod void testRetrieveLabelmap() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;
        LightningComponentUtility.RequestStatus requestStatus;

        Test.startTest();

        requestStatus = EmailComponentController.getEmailLabelMap();

        Test.stopTest();

        System.assertEquals(true, requestStatus.responseMap.containsKey('labelMap'));
    }


}