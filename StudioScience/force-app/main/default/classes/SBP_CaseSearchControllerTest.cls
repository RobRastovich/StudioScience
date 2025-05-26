@isTest(SeeAllData = false)
private class SBP_CaseSearchControllerTest {
    //test data setup
    @testSetup static void setup(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
		User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id,
		                  TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestusercsct@test-user-system.com.test-only');
		insert u;
        }
		Account testAccount = new Account();
		testAccount.Name = 'Test Account';
		testAccount.BillingState = 'IL';
		testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();
		insert testAccount;


		Barrel_Order_Group__c bg = new Barrel_Order_Group__c();
		bg.Type__c = 'Trip and Tour';

		Barrel_Order_Group__c bg2 = new Barrel_Order_Group__c();
		bg2.Type__c = 'Trip and Tour';

		insert new List<Barrel_Order_Group__c> {bg, bg2};


		Case c = new Case();
		c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Standard').getRecordTypeId();
		c.Type = 'Trip and Tour';
		c.Barrel_Order_Group__c = bg.Id;
		c.Brand__c = 'Knob Creek';
		c.Product_Type__c = 'Bourbon';
		c.ccEmail__c = 'test@test.com';
		c.AccountId = testAccount.Id;
        c.Status = 'New';

		Case c2 = new Case();
		c2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Proof_Specific').getRecordTypeId();
		c2.Type = 'Trip and Tour';
		c2.Barrel_Order_Group__c = bg2.Id;
		c2.Brand__c = 'Makers Mark';
		c2.AccountId = testAccount.Id;
        c2.Status = 'New';

		insert new List<Case> {c, c2};

		Barrel__c makersMark = new Barrel__c();
		makersMark.Brand__c = 'Makers Mark';
		makersMark.Ship_Date__c = null;
		makersMark.Case__c = c2.Id;
		makersMark.SKU__c = 'Test Barrel 2';
		makersMark.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Makers_Mark_Full_Barrel').getRecordTypeId();

		insert makersMark;
    }
    
    public static testMethod void fetchCaseRecordsTest1() {
        String searchQuery = 'Test Account';
        String brand = 'Makers Mark';
        Boolean toggle = false;
        List<String> ls = new list<String>();
        test.startTest();
        List<Case> listCaseRecords = SBP_CaseSearchController.fetchCaseRecords(searchQuery,brand,toggle,ls);
        System.debug('List Size 1st:::'+listCaseRecords.size());
        test.stopTest();
        System.assertEquals(listCaseRecords.size(), 1, 'Query should return 1 record');
    }
    
    public static testMethod void fetchCaseRecordsTest2() {
        String searchQuery = 'Test Account';
        String brand = 'Makers Mark';
        Boolean toggle = true;
        List<String> ls = new list<String>();
        test.startTest();
        List<Case> listCaseRecords = SBP_CaseSearchController.fetchCaseRecords(searchQuery,brand,toggle,ls);
        System.debug('List Size 2nd:::'+listCaseRecords.size());
        test.stopTest();
        System.assertEquals(listCaseRecords.size(), 1, 'Query should return 1 record');
    }
    
    public static testMethod void getStatesTest() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing1', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = p.Id,Represented_States__c = 'Alaska;Arizona;Arkansas;Hawaii;',
                          TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser1@test-user-system.com.test-only');
        System.runAs(u) {
        test.startTest();
        List<String> listStates = SBP_CaseSearchController.getStates();
        test.stopTest();
        System.assert(listStates!=null);
        }
    }
}