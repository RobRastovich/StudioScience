@isTest
private class SBP_OrderStepTrackerCmpCtrlTest {
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

		Barrel_Order_Group__c bg = new Barrel_Order_Group__c();
		bg.Type__c = 'Trip and Tour';
		insert bg;

		Case c = new Case();
		c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Standard').getRecordTypeId();
		c.Type = 'Trip and Tour';
		c.Barrel_Order_Group__c = bg.Id;
		c.Brand__c = 'Knob Creek';
		c.Product_Type__c = 'Bourbon';
		c.ccEmail__c = 'test@test.com';
		c.AccountId = testAccount.Id;
		insert c;

	}

	public static Case getCaseById(Id caseId) {
		return [select id from Case where Id = :caseId limit 1];
	}

	public static Case getCaseByBrand(String brand) {
		return [select id, Barrel_Selected__c, Status from Case where Brand__c = :brand limit 1];
	}

	public static Account getTestAccount() {
		return [select id from Account where Name = 'Test Account'];
	}


	public static testMethod void getCaseOrderStepsTest() {
		Case c = getCaseByBrand('Knob Creek');

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_OrderStepTrackerCmpCtrl.getOrderSteps(c.Id,'Case');

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('record'), 'case should exist');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}

	public static testMethod void getCaseOrderStepsErrorTest() {
		Case c = getCaseByBrand('Knob Creek');
		Account a = getTestAccount();

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_OrderStepTrackerCmpCtrl.getOrderSteps(a.Id,'Case');

		Test.stopTest();

		System.assertEquals(false, response.success, 'Operation should not return successfully');
	}
}