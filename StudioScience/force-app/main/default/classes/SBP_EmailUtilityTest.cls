@isTest
private class SBP_EmailUtilityTest {
    @testSetup static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = p.Id,
                          TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser@test-user-system.com.test-only');
        insert u;

        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.BillingState = 'IL';
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();

        Account retailAccount = new Account();
        retailAccount.Name = 'Retail Account';
        retailAccount.BillingState = 'IL';
        retailAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();

        insert new List<Account> {testAccount, retailAccount};


        Barrel_Order_Group__c bg = new Barrel_Order_Group__c();
        bg.Type__c = 'Trip and Tour';

        Barrel_Order_Group__c bg2 = new Barrel_Order_Group__c();
        bg2.Type__c = 'Sample Kit';

        insert new List<Barrel_Order_Group__c> {bg, bg2};


        Case c = new Case();
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Standard').getRecordTypeId();
        c.Type = 'Trip and Tour';
        c.Barrel_Order_Group__c = bg.Id;
        c.Brand__c = 'Knob Creek';
        c.Product_Type__c = 'Bourbon';
        c.ccEmail__c = 'test@test.com';
        c.AccountId = testAccount.Id;

        Case c2 = new Case();
        c2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Proof_Specific').getRecordTypeId();
        c2.Type = 'Trip and Tour';
        c2.Barrel_Order_Group__c = bg2.Id;
        c2.Brand__c = 'Makers Mark';
        c2.AccountId = testAccount.Id;

        insert new List<Case> {c, c2};

        Barrel__c makersMark = new Barrel__c();
        makersMark.Brand__c = 'Makers Mark';
        makersMark.Ship_Date__c = null;
        makersMark.Case__c = c2.Id;
        makersMark.SKU__c = 'Test Barrel 2';
        makersMark.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Makers_Mark_Full_Barrel').getRecordTypeId();

        insert makersMark;
    }

    public static Account getTestAccount() {
        return [select id from Account where Name = 'Test Account'];
    }

    public static Account getAccountByName(String name) {
        return [select id from Account where Name = :name];
    }

    public static Case getCaseByBrand(String brand) {
        return [select id, Barrel_Selected__c, AccountId, Retail_Account__c, Status, Remote_Selection_Date__c from Case where Brand__c = :brand limit 1];
    }

    public static Barrel__c getBarrelByBrand(String brand) {
        return [select Id from Barrel__c where Brand__c = :brand limit 1];
    }

    public static testMethod void sendMissingPurchaseOrderEmailTest() {
        Case c = getCaseByBrand('Knob Creek');



        Test.startTest();
        List<Messaging.SingleEmailMessage> emails = SBP_EmailUtility.sendMissingItemEmail(new Set<Id> {UserInfo.getUserId()}, 'All_Missing_Items');


        Test.stopTest();

        System.assertEquals(1, emails.size());
    }

    public static testMethod void sendMissingItemEmailTest() {

        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        c.email = 'test@test.com';
        insert c;
        
        SBP_EmailUtility emailUtility = new SBP_EmailUtility();
        emailUtility.distributorId = c.Id;
        String ret_str = emailUtility.distributorEmail;
        Map<Id, List<String>> contactToCcemailMap = new Map<Id, List<String>>();
        contactToCcemailMap.put(c.Id, new List<String>());

        Test.startTest();
        List<Messaging.SingleEmailMessage> emails = SBP_EmailUtility.missingPurchaseOrderEmail('Missing_Purchase_Orders', contactToCcemailMap);


        Test.stopTest();

        System.assertEquals(1, emails.size());
    }

    public static testMethod void getSampleKitTest() {

        SBP_EmailUtility emailUtility = new SBP_EmailUtility();

        Barrel_Order_Group__c b = [select id from Barrel_Order_Group__c where Type__c = 'Sample Kit' limit 1];
        Case c = [select id from Case where Barrel_Order_Group__c = :b.Id limit 1];
        Barrel__c objBarrel = new Barrel__c(Case__c = c.Id);
        insert objBarrel;
        Sample_Kit__c sk = new Sample_Kit__c();
        sk.Barrel_Order_Group__c = b.Id;
        insert sk;
        emailUtility.sampleKitId = sk.Id;
        emailUtility.caseId = c.Id;
        emailUtility.barrelId = objBarrel.Id;
        //
        Sample_Kit__c sk2 = emailUtility.sampleKit;
        emailUtility.submitterId = UserInfo.getUserId();
        
        

        Map<Id, List<String>> contactToCcemailMap = new Map<Id, List<String>>();
        contactToCcemailMap.put(c.Id, new List<String>());

        Test.startTest();
        Case cc = emailUtility.sampleKitCase;
        List<Barrel__c> barrelList = emailUtility.completedBarrels;
        String baseUrl = emailUtility.baseUrl;
        List<String> ret_bottle_str = emailUtility.BottleTextEntered;
        String email = emailUtility.submitterEmail;
        Sample_Kit__c ret_sampleKit = emailUtility.sampleKitCancellationEmails;
        List<String> bottletext = emailUtility.BottleTextCityStateEntered;
        Test.stopTest();

        System.assertEquals(c.Id, cc.Id);
    }

}