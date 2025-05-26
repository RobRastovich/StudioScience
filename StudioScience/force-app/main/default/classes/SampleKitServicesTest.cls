@isTest
private class SampleKitServicesTest {
	@testSetup static void setup() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id,
		                  TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser@test-user-system.com.test-only');
		//insert u;
        List<Barrel_Number__c> lstBarrelNumber= new List<Barrel_Number__c>();
        Barrel_Number__c knobCreekBarrelNumber = new Barrel_Number__c();
        knobCreekBarrelNumber.Brand__c = 'Knob Creek';
        knobCreekBarrelNumber.Product_Type__c = 'Bourbon';
        knobCreekBarrelNumber.Next_Barrel_Number__c = '1';
        lstBarrelNumber.add(knobCreekBarrelNumber);
        
        insert lstBarrelNumber;

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

		Barrel__c knobCreek = new Barrel__c();
		knobCreek.Brand__c = 'Knob Creek';
		knobCreek.Case__c = c.Id;
		knobCreek.SKU__c = 'Test Barrel';
		knobCreek.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Knob_Creek_Full_Barrel').getRecordTypeId();
		knobCreek.Product_Type__c = 'Bourbon';

		Barrel__c sampleBarrel1 = new Barrel__c();
		sampleBarrel1.Brand__c = 'Knob Creek';
		sampleBarrel1.SKU__c = 'Sample Barrel 1';
		sampleBarrel1.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Knob_Creek_Sample_Kit').getRecordTypeId();
		sampleBarrel1.Product_Type__c = 'Bourbon';

		Barrel__c sampleBarrel2 = new Barrel__c();
		sampleBarrel2.Brand__c = 'Knob Creek';
		sampleBarrel2.SKU__c = 'Sample Barrel 2';
		sampleBarrel2.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Knob_Creek_Sample_Kit').getRecordTypeId();
		sampleBarrel2.Product_Type__c = 'Bourbon';

		Barrel__c sampleBarrel3 = new Barrel__c();
		sampleBarrel3.Brand__c = 'Knob Creek';
		sampleBarrel3.SKU__c = 'Sample Barrel 3';
		sampleBarrel3.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Knob_Creek_Sample_Kit').getRecordTypeId();
		sampleBarrel3.Product_Type__c = 'Bourbon';

		insert new List<Barrel__c> {knobCreek, sampleBarrel1, sampleBarrel2, sampleBarrel3};

		// create sample kit
		Sample_Kit__c sKit = new Sample_Kit__c();
		sKit.Barrel_Order_Group__c = bg.Id;
		insert sKit;

		Sample__c sample1 = new Sample__c();
		sample1.Label__c = 'A';
		sample1.Barrel__c = sampleBarrel1.Id;
		sample1.Sample_Kit__c = sKit.Id;

		Sample__c sample2 = new Sample__c();
		sample2.Label__c = 'B';
		sample2.Barrel__c = sampleBarrel2.Id;
		sample2.Sample_Kit__c = sKit.Id;

		Sample__c sample3 = new Sample__c();
		sample3.Label__c = 'C';
		sample3.Barrel__c = sampleBarrel3.Id;
		sample3.Sample_Kit__c = sKit.Id;

		insert new List<Sample__c> {sample1, sample2, sample3};

	}

	public static Case getCaseById(Id caseId) {
		return [select id from Case where Id = :caseId limit 1];
	}

	public static Case getCaseByBrand(String brand) {
		return [select id, Barrel_Selected__c, Status, Remote_Selection_Date__c, Barrel_Order_Group__c from Case where Brand__c = :brand limit 1];
	}

	public static List<Case> getCurrentNumberOfCases() {
		return [select Id from Case];
	}

	public static List<Sample__c> getSamplesByBarrelGroupId(Id barrelGroupId) {
		return [select Id, Barrel__c, Label__c from Sample__c where Sample_Kit__r.Barrel_Order_Group__c = :barrelGroupId];
	}

	public static Sample__c getSampleByLabel(String label) {
		return [select Id, Barrel__c, Label__c, Sample_Kit__c from Sample__c where Label__c = :label limit 1];
	}

	public static Account getTestAccount() {
		return [select id from Account where Name = 'Test Account'];
	}


	public static testMethod void updateBarrelWithSelectedSampleTest() {
		Case c = getCaseByBrand('Knob Creek');
		Sample__c sample = getSampleByLabel('A');

		Test.startTest();

		Sample_Kit__c sampleKit = [select id, Barrel_Order_Group__c, Tracking_Number__c from Sample_Kit__c where Id = :sample.Sample_Kit__c];
		Case relatedCase = [select id, Sample_Kit_Shipped__c from Case where Barrel_Order_Group__c = :sampleKit.Barrel_Order_Group__c];

		System.assertEquals(false, relatedCase.Sample_Kit_Shipped__c);

		sampleKit.Tracking_Number__c = '1234';
		update sampleKit;

		Case updatedCase = [select id, Sample_Kit_Shipped__c from Case where Barrel_Order_Group__c = :sampleKit.Barrel_Order_Group__c];

		Test.stopTest();

		System.assertEquals(true, updatedCase.Sample_Kit_Shipped__c);
	}








}