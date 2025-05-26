@isTest
private class SBP_FileUploadCmpCtrlTest {
    
    @future
    public static void insertUser()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = p.Id,
                          TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser@test-user-system.com.test-only');
        insert u;
    }
    
	@testSetup static void setup() {
        insertUser();

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

	public static testMethod void getRelatedFilesTest() {
		Case c = getCaseByBrand('Knob Creek');

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_FileUploadCmpCtrl.getRelatedFiles(c.Id);

		System.assertEquals(new List<ContentDocumentLink>(), response.responseMap.get('files'), 'There should be no files returned');
		System.assertEquals(true, response.success, 'Operation should return successfully');

		Test.stopTest();
	}

	public static testMethod void updateApplicationTest() {
		Case c = getCaseByBrand('Knob Creek');
		Account a = getAccountByName('Retail Account');

		Test.startTest();

		Account_Application__c makersApplication = new Account_Application__c();
		makersApplication.Brand__c = 'Makers Mark';
		makersApplication.Status__c = 'New';
		makersApplication.Account__c = a.Id;
		makersApplication.Submitter__c = UserInfo.getUserId();
		insert makersApplication;

		String jsonApplication = '[ {"Account_Application__c":"' + makersApplication.Id + '"'
		                         + ', "Application_Status__c":"Approved"'
		                         + ', "Question_Text__c":"Is the account a P/G/S account overall?"'
		                         + ', "Answer_Text__c":"Yes"}]';

		Boolean response = SBP_FileUploadCmpCtrl.updateApplications(jsonApplication);

		Account_Application__c app = [select id, Status__c from Account_Application__c where id = :makersApplication.Id];
		Test.stopTest();

		System.assertEquals(TRUE, response, 'File should be uploaded');
		System.assertEquals('Approved', app.Status__c, 'File should be uploaded');
	}


	public static testMethod void updatePOSItemsTest() {
		Case c = getCaseByBrand('Knob Creek');
		Account a = getAccountByName('Retail Account');

		Barrel__c barrel = getBarrelByBrand('Makers Mark');

		Test.startTest();

		List<POS_Customization__c> posItems = new List<POS_Customization__c>();
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Barrel Plaque', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Floor Display', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Barrel', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));

		insert posItems;


		String posItemsJson = '	[ {"Id":"' + posItems[0].Id + '"'
		                      + ', "Tracking_URL__c":"test"'
		                      + ', "Name":"ITEM-0082"}'
		                      + ', {"Id": "' + posItems[1].Id + '"'
		                      + ', "Tracking_URL__c": "test"'
		                      + ', "Name": "ITEM-0275"}'
		                      + ', {"Id": "' + posItems[2].Id + '"'
		                      + ', "Tracking_URL__c": "test"'
		                      + ', "Name": "ITEM-0083"}]';


		Boolean response = SBP_FileUploadCmpCtrl.updatePOS(posItemsJson);

		List<POS_Customization__c> updatedPos = [select id, Tracking_URL__c from POS_Customization__c];
		Test.stopTest();

		for (POS_Customization__c pos : updatedPos) {
			System.assertEquals('test', pos.Tracking_URL__c, 'Tracking URL should be updated');
		}

		System.assertEquals(TRUE, response, 'File should be uploaded');
	}

	public static testMethod void validateVerificationCodeTest() {
		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_FileUploadCmpCtrl.validateVerificationCode('2222');

		Test.stopTest();

		System.assertEquals(TRUE, response.responseMap.get('isValidCode'), 'Valid code should be entered');
	}



}