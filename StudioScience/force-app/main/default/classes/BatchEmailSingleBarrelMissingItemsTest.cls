@isTest
private class BatchEmailSingleBarrelMissingItemsTest {
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
        insert testAccount;

        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.Email = 'test@test.test';
        insert con;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test1';
        con1.LastName = 'Contact1';
        con1.Email = 'test1@test.test';
        insert con1;
        
        Contact con2 = new Contact();
        con2.FirstName = 'Test2';
        con2.LastName = 'Contact2';
        con2.Email = 'test2@test.test';
        insert con2;


        Barrel_Order_Group__c bg = new Barrel_Order_Group__c();
        bg.Type__c = 'Trip and Tour';

        Barrel_Order_Group__c bg2 = new Barrel_Order_Group__c();
        bg2.Type__c = 'Trip and Tour';
        
        Barrel_Order_Group__c bg3 = new Barrel_Order_Group__c();
        bg2.Type__c = 'Sample Kit';

        insert new List<Barrel_Order_Group__c> {bg, bg2};


        Case c = new Case();
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Standard').getRecordTypeId();
        c.Type = 'Trip and Tour';
        c.ContactId = con.Id;
        c.Barrel_Order_Group__c = bg.Id;
        c.Brand__c = 'Knob Creek';
        c.Product_Type__c = 'Bourbon';
        c.ccEmail__c = 'test@test.com;beam@test.com';
        c.AccountId = testAccount.Id;

        Case c2 = new Case();
        c2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Proof_Specific').getRecordTypeId();
        c2.Type = 'Trip and Tour';
        c.ContactId = con1.Id;
        c2.Barrel_Order_Group__c = bg2.Id;
        c2.ccEmail__c = 'test@test.com';
        c2.Brand__c = 'Makers Mark';
        c2.AccountId = testAccount.Id;
        
        Case c3 = new Case();
        c3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Standard').getRecordTypeId();
        c3.Type = 'Sample Kit';
        c.ContactId = con2.Id;
        c3.Barrel_Order_Group__c = bg3.Id;
        c3.Brand__c = 'Knob Creek';
        c3.ccEmail__c = '';
        c.Product_Type__c = 'Rye';
        c3.AccountId = testAccount.Id;

        insert new List<Case> {c, c2, c3};


        Barrel__c knobCreek = new Barrel__c();
        knobCreek.Brand__c = 'Knob Creek';
        knobCreek.Case__c = c.Id;
        knobCreek.SKU__c = 'Test Barrel';
        knobCreek.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Knob_Creek_Full_Barrel').getRecordTypeId();
        knobCreek.Product_Type__c = 'Bourbon';

        Barrel__c makersMark = new Barrel__c();
        makersMark.Brand__c = 'Makers Mark';
        makersMark.Ship_Date__c = null;
        makersMark.Case__c = c2.Id;
        makersMark.SKU__c = 'Test Barrel 2';
        makersMark.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Makers_Mark_Full_Barrel').getRecordTypeId();

        insert new List<Barrel__c> {knobCreek, makersMark};

        Barrel_Number__c knobCreekBarrelNumber = new Barrel_Number__c();
        knobCreekBarrelNumber.Brand__c = 'Knob Creek';
        knobCreekBarrelNumber.Product_Type__c = 'Bourbon';
        knobCreekBarrelNumber.Next_Barrel_Number__c = '1';
        insert knobCreekBarrelNumber;
    }

    public static Case getCaseById(Id caseId) {
        return [select id from Case where Id = :caseId limit 1];
    }

    public static Barrel_Number__c getBarrelNumberByBrand(String brand) {
        return [select id, Brand__c, Next_Barrel_Number__c from Barrel_Number__c where Brand__c = :brand limit 1];
    }

    public static Case getCaseByBrand(String brand) {
        return [select id, Barrel_Selected__c, Status from Case where Brand__c = :brand limit 1];
    }

    public static Barrel__c getBarrelBySku(String sku) {
        return [select id, Selection_Date__c, Barrel_Number__c from Barrel__c where SKU__c = :sku limit 1];
    }

    public static List<Case> getCurrentNumberOfCases() {
        return [select Id from Case];
    }

    public static Account getTestAccount() {
        return [select id from Account where Name = 'Test Account'];
    }


    public static testMethod void sendEmailOfMissingItemsTest() {

        Test.startTest();

        Integer emailbefore = Limits.getEmailInvocations();

        BatchEmailSingleBarrelMissingItems batch = new BatchEmailSingleBarrelMissingItems();
        ID batchprocessid = Database.executeBatch(batch, 300);

        Test.stopTest();

        //System.assertEquals(3, Limits.getEmailInvocations(), '3 emails should be sent');
    }
    
    
    public static testMethod void sendEmailOfMissingItemsTestConstructor() {


        String query = 'select Id '
                + ', Purchase_Order_Uploaded__c'
                + ', Bottle_Text_Entered__c'
                + ', POS_Items_Selected__c'
                + ', Barrel_Selected__c'
                + ', ContactId' 
                + ', Missing_PO__c'
                + ', Missing_Items__c'
                + ', Brand__c'
                + ', CcEmail__c'
                + ', Submitter__c'
                + ', Submitter__r.Name'
                + ', Status'
                + ', RecordTypeId FROM Case where Case.RecordTypeId IN :caseRtIds'
                + '  AND Missing_Items__c = true'
                + '  AND IsClosed = false';
        Set<Id> caseRtIds = SBP_Constants.caseSingleBarrelRtIds;
        
        Test.startTest();
        Integer emailbefore = Limits.getEmailInvocations();

        BatchEmailSingleBarrelMissingItems batch = new BatchEmailSingleBarrelMissingItems(query, caseRtIds);
        List<Case> caseList = Database.query(query);
       
        System.debug(caseList);
        System.debug(caseList.size());
       
        ID batchprocessid = Database.executeBatch(batch, 300);
        Test.stopTest();
        

        //System.assertEquals(3, Limits.getEmailInvocations(), '3 emails should be sent');
    }

}