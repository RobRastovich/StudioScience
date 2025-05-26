@isTest
private class SBP_TripSelectionDateCmpCtrlTest {
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
	}

	public static Case getCaseById(Id caseId) {
		return [select id from Case where Id = :caseId limit 1];
	}

	public static Case getCaseByBrand(String brand) {
		return [select id, Barrel_Selected__c, Status, Remote_Selection_Date__c from Case where Brand__c = :brand limit 1];
	}

	public static List<Case> getCurrentNumberOfCases() {
		return [select Id from Case];
	}

	public static Account getTestAccount() {
		return [select id from Account where Name = 'Test Account'];
	}


	public static testMethod void getRejectedDatesTest() {
		Case c = getCaseByBrand('Makers Mark');

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_TripSelectionDateCmpCtrl.getRejectedDates(String.valueOf(c.Id));

		Test.stopTest();

		System.assertEquals(null, response.responseMap.get('caseHistory'), 'There should be no case history');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}

	public static testMethod void getRejectedDatesErrorTest() {
		Case c = getCaseByBrand('Makers Mark');

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_TripSelectionDateCmpCtrl.getRejectedDates('');

		Test.stopTest();

		System.assertEquals(false, response.success, 'Operation should not return successfully');
	}

	public static testMethod void getCaseTest() {
		Case c = getCaseByBrand('Makers Mark');

		Test.startTest();
		c.Approval_Status__c = 'Rejected';
		update c;

		LightningComponentUtility.RequestStatus response = SBP_TripSelectionDateCmpCtrl.getCase(String.valueOf(c.Id));

		Test.stopTest();

		System.assertEquals(true, response.responseMap.get('showInput'), 'show input should be true');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}

	public static testMethod void getCaseErrorTest() {
		Case c = getCaseByBrand('Makers Mark');

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_TripSelectionDateCmpCtrl.getCase('');

		Test.stopTest();

		System.assertEquals(false, response.success, 'Operation should not return successfully');
	}

	public static testMethod void updateCaseTest() {
		Case c = getCaseByBrand('Makers Mark');

		Test.startTest();
		Date newDate = Date.today();

		LightningComponentUtility.RequestStatus response = SBP_TripSelectionDateCmpCtrl.updateCase( String.valueOf(Date.today()), String.valueOf(c.Id));

		Case updatedCase = getCaseByBrand('Makers Mark');

		Test.stopTest();

		System.assertEquals(newDate, updatedCase.Remote_Selection_Date__c, 'date should be today');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}

	public static testMethod void updateCaseErrorTest() {

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_TripSelectionDateCmpCtrl.updateCase( String.valueOf(Date.today()), '');

		Test.stopTest();

		System.assertEquals(false, response.success, 'Operation should not return successfully');
	}

}