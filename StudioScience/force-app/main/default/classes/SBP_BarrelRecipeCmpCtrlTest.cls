@isTest
private class SBP_BarrelRecipeCmpCtrlTest {
	@testSetup static void setup() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id,
		                  TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuserbrcct@test-user-system.com.test-only');
		//insert u;
		List<Barrel_Number__c> lstBarrelNumber= new List<Barrel_Number__c>();
        Barrel_Number__c knobCreekBarrelNumber = new Barrel_Number__c();
        knobCreekBarrelNumber.Brand__c = 'Knob Creek';
        knobCreekBarrelNumber.Product_Type__c = 'Bourbon';
        knobCreekBarrelNumber.Next_Barrel_Number__c = '1';
        lstBarrelNumber.add(knobCreekBarrelNumber);
        
        Barrel_Number__c MakersMark1 = new Barrel_Number__c();
        MakersMark1.Brand__c = 'Makers Mark';
        MakersMark1.Next_Barrel_Number__c = '1';
        lstBarrelNumber.add(MakersMark1);
        
        insert lstBarrelNumber;
        
        Account testAccount = new Account();
		testAccount.Name = 'Test Account';
		testAccount.BillingState = 'IL';
		testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();
		insert testAccount;

		Account retailAccount = new Account();
		retailAccount.Name = 'Retail Account';
		retailAccount.BillingState = 'IL';
		retailAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();
		insert retailAccount;


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
		c.Barrel_Selected__c = false;
		c.Retail_Account__c = retailAccount.Id;
		c.Product_Type__c = 'Bourbon';
		c.ccEmail__c = 'test@test.com';
		c.AccountId = testAccount.Id;

		Case c2 = new Case();
		c2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Proof_Specific').getRecordTypeId();
		c2.Type = 'Trip and Tour';
		c2.Barrel_Order_Group__c = bg2.Id;
		c2.Retail_Account__c = retailAccount.Id;
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

		Barrel_Recipe__c recipe1 = new Barrel_Recipe__c();
		recipe1.Brand__c = 'Makers Mark';
		insert recipe1;

		List<Stave__c> staves = new List<Stave__c>();
		staves.add(new Stave__c(Barrel_Recipe__c = recipe1.Id, Type__c = 'Baked American Pure 2', Quantity__c = 2));
		staves.add(new Stave__c(Barrel_Recipe__c = recipe1.Id, Type__c = 'Seared French Cuvee', Quantity__c = 2));
		staves.add(new Stave__c(Barrel_Recipe__c = recipe1.Id, Type__c = 'Maker\'s 46', Quantity__c = 2));
		staves.add(new Stave__c(Barrel_Recipe__c = recipe1.Id, Type__c = 'Roasted French Mocha', Quantity__c = 2));
		staves.add(new Stave__c(Barrel_Recipe__c = recipe1.Id, Type__c = 'Toasted French Spice', Quantity__c = 2));

		insert staves;

		Account_Barrel_Recipe__c abr = new Account_Barrel_Recipe__c();
		abr.Account__c = retailAccount.Id;
		abr.Barrel_Recipe__c = recipe1.Id;
		insert abr;

	}

	public static Case getCaseById(Id caseId) {
		return [select id from Case where Id = :caseId limit 1];
	}

	public static Account_Barrel_Recipe__c getBarrelRecipeByAccountName(String accountName) {
		return [select id, Barrel_Recipe__c from Account_Barrel_Recipe__c where Account__r.Name = :accountName limit 1];
	}

	public static Case getCaseByBrand(String brand) {
		return [select id, Barrel_Selected__c, Status, Remote_Selection_Date__c from Case where Brand__c = :brand limit 1];
	}

	public static List<Case> getCurrentNumberOfCases() {
		return [select Id from Case];
	}

	public static List<Barrel__c> getCurrentNumberOfBarrels() {
		return [select Id from Barrel__c];
	}

	public static Account getTestAccount() {
		return [select id from Account where Name = 'Test Account'];
	}


	public static testMethod void getSingleBarrelStaveCustomMetadataTest() {
		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_BarrelRecipeCmpCtrl.getSingleBarrelStaveCustomMetadata('Makers Mark');

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('staves'), 'There should staves in the system');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}

	public static testMethod void getCaseTest() {
		Case c = getCaseByBrand('Knob Creek');

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_BarrelRecipeCmpCtrl.getCase(String.valueOf(c.Id));

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('barrelSelected'), 'A case value should be returned');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}

	public static testMethod void getCaseErrorTest() {
		Test.startTest();
		Case c = getCaseByBrand('Makers Mark');

		LightningComponentUtility.RequestStatus response = SBP_BarrelRecipeCmpCtrl.getCase('');

		Test.stopTest();

		System.assertEquals(false, response.success, 'Operation should not return successfully');
	}

	public static testMethod void createBarrelRecordTest() {
		Case c = getCaseByBrand('Makers Mark');
		List<Barrel__c> barrels = getCurrentNumberOfBarrels();

		Account_Barrel_Recipe__c abr = getBarrelRecipeByAccountName('Retail Account');

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_BarrelRecipeCmpCtrl.createBarrelRecord(String.valueOf(c.Id), 'Makers Mark', String.valueOf(abr.Barrel_Recipe__c));

		List<Barrel__c> barrelsUpdated = getCurrentNumberOfBarrels();
		Test.stopTest();

		//System.assertNotEquals(NULL, response.responseMap.get('barrelId'), 'A barrel id should exist');
		//System.assertEquals(barrels.size(), barrelsUpdated.size(), 'No barrel should be created');
		//System.assertEquals(true, response.success, 'Operation should return successfully');
	}

	public static testMethod void createBarrelRecordErrorTest() {
		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_BarrelRecipeCmpCtrl.createBarrelRecord('', 'Makers Mark', '');

		List<Barrel__c> barrelsUpdated = getCurrentNumberOfBarrels();
		Test.stopTest();

		System.assertEquals(false, response.success, 'Operation should not return successfully');
	}

	public static testMethod void getRecentRecipesTest() {
		Case c = getCaseByBrand('Makers Mark');

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_BarrelRecipeCmpCtrl.getRecentRecipes(String.valueOf(c.Id), 'Makers Mark');

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('recipes'), 'Recipes should exist');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}

	public static testMethod void getRecentRecipesErrorTest() {
		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_BarrelRecipeCmpCtrl.getRecentRecipes('', 'Makers Mark');

		Test.stopTest();

		System.assertEquals(false, response.success, 'Operation should not return successfully');
	}

	public static testMethod void createBarrelRecipeTest() {
		Case c = getCaseByBrand('Makers Mark');

		String jsonRecipe = '[{"Type__c":"Baked American Pure 2","Quantity__c":"2"},{"Type__c":"Seared French Cuvee","Quantity__c":"2"},{"Type__c":"Maker\'s 46","Quantity__c":"2"},{"Type__c":"Roasted French Mocha","Quantity__c":"4"}]';


		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_BarrelRecipeCmpCtrl.createBarrelRecipe(jsonRecipe, String.valueOf(c.Id));

		Test.stopTest();

		//System.assertNotEquals(NULL, response.responseMap.get('newRecipe'), 'Recipe should exist');
		//System.assertEquals(true, response.success, 'Operation should return successfully');
	}

	public static testMethod void createBarrelRecipeExistingRecipeTest() {
		Case c = getCaseByBrand('Makers Mark');

		String jsonRecipe = '[{"Type__c":"Baked American Pure 2","Quantity__c":"2"}'
		                    + ',{"Type__c":"Seared French Cuvee","Quantity__c":"2"}'
		                    + ',{"Type__c":"Maker\'s 46","Quantity__c":"2"}'
		                    + ',{"Type__c":"Roasted French Mocha","Quantity__c":"2"}'
		                    + ',{"Type__c":"Toasted French Spice","Quantity__c":"2"}]';


		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_BarrelRecipeCmpCtrl.createBarrelRecipe(jsonRecipe, String.valueOf(c.Id));

		Test.stopTest();

		//System.assertNotEquals(NULL, response.responseMap.get('newRecipe'), 'Recipe should exist');
		//System.assertEquals(true, response.success, 'Operation should return successfully');
	}
    
    public static testMethod void isMochaPresentTest() {
        Case c = getCaseByBrand('Makers Mark');       
        
        Test.startTest();
        
        Boolean response = SBP_BarrelRecipeCmpCtrl.isMochaPresent(String.valueOf(c.Id), 'Makers Mark' );
        
        Test.stopTest();
        System.assertEquals(true, response);
    }




}