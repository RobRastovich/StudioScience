@isTest
private class ContentDocumentServicesTest {
    
    @future
    public static void createUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = p.Id,
                          TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser@test-user-system.com.test-only');
        insert u;     
    }
    
	@testSetup static void setup() {
        createUser();
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
		return [select id, Barrel_Selected__c, Purchase_Order_Uploaded__c, Status from Case where Brand__c = :brand limit 1];
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


	public static testMethod void updatePoUploadFlagOnCaseTest() {
		Case c = getCaseByBrand('Knob Creek');
		Barrel__c barrel = getBarrelBySku('Test Barrel');

		System.assertEquals(FALSE, c.Purchase_Order_Uploaded__c, 'Purchase order flag should be set to false');


		Test.startTest();

		Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
		ContentVersion testContentVersion = new ContentVersion(
		    Title = 'Attachment Name: ' + String.valueOf(System.now()),
		    PathOnClient = '/Header_Picture1' + String.valueOf(System.now()) + '.pdf',
		    VersionData = bodyBlob,
		    origin = 'H'
		);
		insert testContentVersion;

		ContentVersion contentVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id LIMIT 1];

		ContentDocumentLink contentlink = new ContentDocumentLink();
		contentlink.LinkedEntityId = c.Id;
		contentlink.ContentDocumentId = contentVersion.ContentDocumentId;
		contentlink.ShareType = 'V';
		insert contentlink;

		ContentDocument cd = [select id from ContentDocument where id = :contentVersion.ContentDocumentId];

		Case updatedCase = getCaseByBrand('Knob Creek');
		System.assert(updatedCase.Purchase_Order_Uploaded__c != NULL);
		delete cd;

		Test.stopTest();

		Case updatedCase2 = getCaseByBrand('Knob Creek');
		System.assertEquals(FALSE, updatedCase2.Purchase_Order_Uploaded__c, 'A file being uploaded should update the case purchase order flag');


	}
    
    public static testMethod void handleBeforeDelete() {
        ContentDocumentTriggerHandler.handleBeforeDelete();
        
    }
    


}