@isTest
private class SBP_SplitBarrelCmpCtrlTest {
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

		Case c2 = new Case();
		c2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Proof_Specific').getRecordTypeId();
		c2.Type = 'Trip and Tour';
		c2.Barrel_Order_Group__c = bg2.Id;
		c2.Brand__c = 'Makers Mark';
		c2.AccountId = testAccount.Id;

		insert new List<Case> {c, c2};


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
		return [select id, Barrel_Selected__c, Status, AccountId from Case where Brand__c = :brand limit 1];
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


	public static testMethod void insertSplitBarrelRecordsTest() {
		Case c = getCaseByBrand('Knob Creek');
		Barrel__c barrel = getBarrelBySku('Test Barrel');

		Test.startTest();

		String splitBarrelJson = '[{"State__c":"Arkansas","Number_of_Cases__c":"26","AccountId":"' + c.AccountId + '"}]';

		SBP_SplitBarrelCmpCtrl.insertSplitBarrelRecords(splitBarrelJson, String.valueOf(c.Id));

		List<Case> splitBarrelCases = [select id from Case where RecordTypeId = :SBP_Constants.SINGLE_BARREL_SPLIT_BARREL_RT_ID];

		Test.stopTest();

		System.assertEquals(1, splitBarrelCases.size(), '1 new split barrel should be created ');
	}

	public static testMethod void insertSplitBarrelRecordsErrorTest() {
		Case c = getCaseByBrand('Knob Creek');
		Barrel__c barrel = getBarrelBySku('Test Barrel');

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_SplitBarrelCmpCtrl.insertSplitBarrelRecords('', '');

		Test.stopTest();

		System.assertEquals(false, response.success, 'Operation should have failed');
	}

}