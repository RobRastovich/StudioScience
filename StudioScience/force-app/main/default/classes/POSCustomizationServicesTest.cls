@isTest
private class POSCustomizationServicesTest {
	@testSetup static void setup() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
		User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id,
		                  TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser@test-user-system.com.test-only');
		insert u;

		Account testAccount = new Account();
		testAccount.Name = 'Test Account';
		testAccount.BillingState = 'IL';
		testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();

		Account intAccount = new Account();
		intAccount.Name = 'Single Barrel International Account';
		intAccount.BillingState = 'IL';
		intAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();

		Account retailAccount = new Account();
		retailAccount.Name = 'Retail Account';
		retailAccount.BillingState = 'IL';
		retailAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();

		insert new List<Account> {testAccount, retailAccount, intAccount};

		Barrel_Order_Group__c bg = new Barrel_Order_Group__c();
		bg.Type__c = 'Trip and Tour';

		Barrel_Order_Group__c bg2 = new Barrel_Order_Group__c();
		bg2.Type__c = 'Trip and Tour';

		Barrel_Order_Group__c bg3 = new Barrel_Order_Group__c();
		bg3.Type__c = 'Split Barrel';

		Barrel_Order_Group__c bg4 = new Barrel_Order_Group__c();
		bg4.Type__c = 'Split Barrel';

		insert new List<Barrel_Order_Group__c> {bg, bg2, bg3, bg4};


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
		c2.Account_Missing__c = true;
		c2.Retail_Account_Name__c = 'Missing Account Name';
		c2.Retail_Account__c = intAccount.Id;
		c2.Brand__c = 'Makers Mark';
		c2.AccountId = testAccount.Id;
		c2.Bottle_Text_Entered__c = true;

		Case c3 = new Case();
		c3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Standard').getRecordTypeId();
		c3.Type = 'Split Barrel';
		c3.Barrel_Order_Group__c = bg3.Id;
		c3.Brand__c = 'Knob Creek';
		c3.Barrel_Selected__c = false;
		c3.Retail_Account__c = retailAccount.Id;
		c3.Product_Type__c = 'Bourbon';
		c3.ccEmail__c = 'test@test.com';
		c3.AccountId = testAccount.Id;

		Case c4 = new Case();
		c4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Standard').getRecordTypeId();
		c4.Type = 'Split Barrel';
		c4.Barrel_Order_Group__c = bg4.Id;
		c4.Brand__c = 'Knob Creek';
		c4.Barrel_Selected__c = false;
		c4.Account_Missing__c = true;
		c4.Retail_Account_Name__c = 'Missing Account Name 2';
		c4.Retail_Account__c = intAccount.Id;
		c4.Product_Type__c = 'Bourbon';
		c4.ccEmail__c = 'test@test.com';
		c4.AccountId = testAccount.Id;
        
        //Added by Mahesh
        Case c5 = new Case();
		c5.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Standard').getRecordTypeId();
		c5.Type = 'Sample Kit';
		c5.Barrel_Order_Group__c = bg.Id;
		c5.Brand__c = 'Jim Beam';
		c5.Barrel_Selected__c = false;
		c5.Retail_Account__c = retailAccount.Id;
		c5.ccEmail__c = 'test@test.com';
		c5.AccountId = testAccount.Id;
		caseServices.runTrigger =false;
		insert new List<Case> {c, c2, c3, c4,c5};


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

		Barrel__c knobCreekSplit = new Barrel__c();
		knobCreekSplit.Brand__c = 'Knob Creek';
		knobCreekSplit.Case__c = c3.Id;
		knobCreekSplit.SKU__c = 'Knob Creek Split';
		knobCreekSplit.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Knob_Creek_Split_Barrel').getRecordTypeId();
		knobCreekSplit.Product_Type__c = 'Bourbon';

		Barrel__c knobCreekSplitNoAccount = new Barrel__c();
		knobCreekSplitNoAccount.Brand__c = 'Knob Creek';
		knobCreekSplitNoAccount.Case__c = c4.Id;
		knobCreekSplitNoAccount.SKU__c = 'Knob Creek Split No Account';
		knobCreekSplitNoAccount.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Knob_Creek_Split_Barrel').getRecordTypeId();
		knobCreekSplitNoAccount.Product_Type__c = 'Bourbon';

		//Added by Mahesh
        Barrel__c  jimBeam = new Barrel__c();
		jimBeam.Brand__c = 'Jim Beam';
		jimBeam.Case__c = c5.Id;
		jimBeam.SKU__c = 'Test Barrel';
		jimBeam.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Jim_Beam_Full_Barrel').getRecordTypeId();
        
        insert new List<Barrel__c> {knobCreek, makersMark, knobCreekSplit, knobCreekSplitNoAccount, jimBeam };

		Case splitCase = new Case();
		splitCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Split_Barrel').getRecordTypeId();
		splitCase.Type = 'Split Barrel';
		splitCase.Barrel__c = knobCreekSplit.Id;
		splitCase.Brand__c = 'Knob Creek';
		splitCase.Barrel_Selected__c = false;
		splitCase.Account_Missing__c = false;
		splitCase.Retail_Account__c = retailAccount.Id;
		splitCase.Product_Type__c = 'Bourbon';
		splitCase.ccEmail__c = 'test@test.com';
		splitCase.AccountId = testAccount.Id;

		Case splitCaseNoAccount = new Case();
		splitCaseNoAccount.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Split_Barrel').getRecordTypeId();
		splitCaseNoAccount.Type = 'Split Barrel';
		splitCaseNoAccount.Barrel__c = knobCreekSplitNoAccount.Id;
		splitCaseNoAccount.Brand__c = 'Knob Creek';
		splitCaseNoAccount.Barrel_Selected__c = false;
		splitCase.Account_Missing__c = true;
		splitCaseNoAccount.Retail_Account__c = intAccount.Id;
		splitCaseNoAccount.Product_Type__c = 'Bourbon';
		splitCaseNoAccount.ccEmail__c = 'test@test.com';
		splitCaseNoAccount.AccountId = testAccount.Id;

		//insert new List<Case> {splitCase, splitCaseNoAccount};

	
                }          
    }
    
    public static Case getCaseById(Id caseId) {
        return [select id from Case where Id = :caseId limit 1];
    }
    
    public static Account_Barrel_Recipe__c getBarrelRecipeByAccountName(String accountName) {
        return [select id, Barrel_Recipe__c from Account_Barrel_Recipe__c where Account__r.Name = :accountName limit 1];
    }
    
    public static Case getCaseByBrand(String brand) {
        return [select id, Barrel_Selected__c, AccountId, Retail_Account__c, Status, Remote_Selection_Date__c from Case where Brand__c = :brand limit 1];
    }
    
    public static List<Case> getCurrentNumberOfCases() {
        return [select Id from Case];
    }
    
    public static List<Barrel__c> getCurrentNumberOfBarrels() {
        return [select Id from Barrel__c];
    }
    
    public static Barrel__c getBarrelByBrand(String brand) {
        return [select Id from Barrel__c where Brand__c = :brand limit 1];
        
    }
    
	public static Barrel__c getBarrelBySku(String sku) {
		return [select Id from Barrel__c where SKU__c = :sku limit 1];
	}

	public static Account getTestAccount() {
		return [select id from Account where Name = 'Test Account'];
	}

	public static List<POS_Customization__c> getPOSCustomizationsByBarrel(Id barrelId) {
		return [select id, Insert_Text__c from POS_Customization__c where Barrel__c = :barrelId];
	}

	public static List<POS_Customization__c> getPOSCustomizationsByCase(Id caseId) {
		return [select id, Insert_Text__c from POS_Customization__c where Case__c = :caseId];
	}

	public static Case getCaseByBarrel(Id barrelId) {
		return [select id from Case where Barrel__c = :barrelId limit 1];
	}



	public static testMethod void updateInsertTextWithAccountNameTest() {
		Barrel__c barrel = getBarrelByBrand('Knob Creek');

		Test.startTest();

		List<POS_Customization__c> posItems = new List<POS_Customization__c>();
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Barrel Plaque', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Floor Display', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Barrel', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));

		insert posItems;

		Test.stopTest();

		for (POS_Customization__c pos : getPOSCustomizationsByBarrel(barrel.Id)) {
			System.assertEquals('Retail Account', pos.Insert_Text__c, 'Insert text should equal the name of the account attached to the barrel');
		}
	}

	public static testMethod void updateInsertTextWithAccountNameWithMissingAccountNameTest() {
		Barrel__c barrel = getBarrelByBrand('Makers Mark');

		Test.startTest();

		List<POS_Customization__c> posItems = new List<POS_Customization__c>();
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Barrel Plaque', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID, Bypass_Validation__c = true));
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Floor Display', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID, Bypass_Validation__c = true));
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Barrel', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID, Bypass_Validation__c = true));

		insert posItems;

		Test.stopTest();

		for (POS_Customization__c pos : getPOSCustomizationsByBarrel(barrel.Id)) {
			System.assertEquals('Missing Account Name', pos.Insert_Text__c, 'Insert text should equal the name of the account attached to the barrel');
		}
	}

	/*
	public static testMethod void updateInsertTextWithAccountNameWithAccountNameSplitBarrelTest() {
		Barrel__c barrel = getBarrelBySku('Knob Creek Split');
		Case c = getCaseByBarrel(barrel.Id);

		Test.startTest();

		List<POS_Customization__c> posItems = new List<POS_Customization__c>();
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Barrel Plaque', Case__c = c.Id, RecordTypeId = SBP_Constants.POS_SPLIT_BARREL_RT_ID));
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Floor Display', Case__c = c.Id, RecordTypeId = SBP_Constants.POS_SPLIT_BARREL_RT_ID));
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Barrel', Case__c = c.Id, RecordTypeId = SBP_Constants.POS_SPLIT_BARREL_RT_ID));

		insert posItems;

		Test.stopTest();

		for (POS_Customization__c pos : getPOSCustomizationsByCase(c.Id)) {
			System.assertEquals('Retail Account', pos.Insert_Text__c, 'Insert text should equal the name of the account attached to the barrel');
		}
	}

	public static testMethod void updateInsertTextWithAccountNameWithMissingAccountNameSplitBarrelTest() {
		Barrel__c barrel = getBarrelBySku('Knob Creek Split No Account');
		Case c = getCaseByBarrel(barrel.Id);

		Test.startTest();

		List<POS_Customization__c> posItems = new List<POS_Customization__c>();
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Barrel Plaque', Case__c = c.Id, RecordTypeId = SBP_Constants.POS_SPLIT_BARREL_RT_ID));
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Floor Display', Case__c = c.Id, RecordTypeId = SBP_Constants.POS_SPLIT_BARREL_RT_ID));
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Barrel', Case__c = c.Id, RecordTypeId = SBP_Constants.POS_SPLIT_BARREL_RT_ID));

		insert posItems;

		Test.stopTest();

		for (POS_Customization__c pos : getPOSCustomizationsByCase(c.Id)) {
			System.assertEquals('Missing Account Name 2', pos.Insert_Text__c, 'Insert text should equal the name of the account attached to the barrel');
		}
	} */

	//Added by Mahesh
    public static testMethod void updateInsertTextWithBottleLabelTextTest() {
		Barrel__c barrel = getBarrelByBrand('Knob Creek');

		Test.startTest();

		List<POS_Customization__c> posItems = new List<POS_Customization__c>();
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Bottle Label Text', Type__c = 'Bottle Plate Text', Insert_Text__c = 'TestTest', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Bottle Label Text', Type__c = 'Floor Display', Insert_Text__c = 'TestTest', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Bottle Label Text', Type__c = 'Barrel', Insert_Text__c = 'TestTest', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));

		insert posItems;

		Test.stopTest();

		for (POS_Customization__c pos : getPOSCustomizationsByBarrel(barrel.Id)) {
			System.assertEquals('TestTest', pos.Insert_Text__c, 'Insert text should equal the name of the Bottle Label Text attached to the barrel');
		}
	}
    
    public static testMethod void updateInsertTextWithAccountNameJBTest() {
		Barrel__c barrel = getBarrelByBrand('Jim Beam');

		Test.startTest();

		List<POS_Customization__c> posItems = new List<POS_Customization__c>();
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Barrel Plaque', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Floor Display', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Barrel', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));
		POSCustomizationServices.runTrigger=true;
		insert posItems;
		POSCustomizationServices.runTrigger=true;
        update posItems;
		Test.stopTest();
	}

    public static testMethod void testUpdateBottleLabelText(){
        Barrel__c barrel = getBarrelByBrand('Makers Mark');
        Test.startTest();
        
        List<POS_Customization__c> posItems = new List<POS_Customization__c>();
        posItems.add(new POS_Customization__c(Type__c = 'Bottle Plate Text', Insert_Text__c = 'TestTest', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));
        posItems.add(new POS_Customization__c(Type__c = 'Bottle Label Text City and State', Insert_Text__c = 'TestTest', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));  
        POSCustomizationServices.runTrigger=true;
        insert posItems;
        POSCustomizationServices.updateBottleLabelText(posItems);
        Test.stopTest();
	}
	public static testMethod void testUncheckBottleTextEnteredOnCase(){
        Barrel__c barrel = getBarrelByBrand('Makers Mark');
        Test.startTest();
        
        List<POS_Customization__c> posItems = new List<POS_Customization__c>();
        posItems.add(new POS_Customization__c(Type__c = 'Bottle Plate Text', Insert_Text__c = 'TestTest', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));
        posItems.add(new POS_Customization__c(Type__c = 'Bottle Label Text City and State', Insert_Text__c = 'TestTest', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));  
        POSCustomizationServices.runTrigger=true;
        system.debug('coming in insert positems');
        insert posItems;
        system.debug('coming in delete positems');
        POSCustomizationServices.runTrigger=true;    
        delete posItems;
        system.debug('coming in delete positems 2');
        Test.stopTest();
	}

    public static testMethod void testUpdateBottleLabelTextSendEmail(){
        Barrel__c barrel = getBarrelByBrand('Makers Mark');
        Test.startTest();
        
        List<POS_Customization__c> posItems = new List<POS_Customization__c>();
        posItems.add(new POS_Customization__c(Type__c = 'Bottle Plate Text', Insert_Text__c = 'TestTest', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID, Bypass_Validation__c = true));
        posItems.add(new POS_Customization__c(Type__c = 'Bottle Label Text City and State', Insert_Text__c = 'TestTest', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID, Bypass_Validation__c = true));  
        POSCustomizationServices.runTrigger=true;
        insert posItems;
        for(POS_Customization__c itm : posItems) {
            itm.Insert_Text__c = 'TestUpdate';
        }
        POSCustomizationServices.runTrigger=true;
        update posItems;
        Test.stopTest();
	}
}