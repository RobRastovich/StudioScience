@isTest
private class SBP_POSItemCmpCtrlTest {
    
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

        Account intAccount = new Account();
        intAccount.Name = 'Single Barrel International Account';
        intAccount.BillingState = 'IL';
        intAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();

        Account retailAccount = new Account();
        retailAccount.Name = 'Retail Account';
        retailAccount.BillingState = 'IL';
        retailAccount.PremiseType__c = 'On Premise';
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
        
        /** changes start here on 8-Sep-20
        *	@description: new Case object with field Account_Missing__c: true is created
        **/
        Case c6 = new Case();
        c6.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Standard').getRecordTypeId();
        c6.Type = 'Trip and Tour';
        c6.Barrel_Order_Group__c = bg.Id;
        c6.Brand__c = 'Knob Creek';
        c6.Barrel_Selected__c = false;
        c6.Retail_Account__c = retailAccount.Id;
        c6.Product_Type__c = 'Bourbon';
        c6.ccEmail__c = 'test@test.com';
        c6.AccountId = testAccount.Id;
        c6.Account_Missing__c= true;
        /*
        *changes end here on 8-Sep-20
        */

        Case c2 = new Case();
        c2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Proof_Specific').getRecordTypeId();
        c2.Type = 'Trip and Tour';
        c2.Barrel_Order_Group__c = bg2.Id;
        c2.Account_Missing__c = true;
        c2.Retail_Account_Name__c = 'Missing Account Name';
        c2.Retail_Account__c = intAccount.Id;
        c2.Brand__c = 'Makers Mark';
        c2.AccountId = testAccount.Id;

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
        
        Case c5 = new Case();
        c5.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Proof_Specific').getRecordTypeId();
        c5.Type = 'Split Barrel';
        c5.Barrel_Order_Group__c = bg2.Id;
        c5.Account_Missing__c = true;
        c5.Retail_Account_Name__c = 'Missing Account Name';
        c5.Retail_Account__c = intAccount.Id;
        c5.Brand__c = 'Makers Mark';
        c5.AccountId = testAccount.Id;
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        
        insert new List<Case> {c, c2, c3, c4, c5, c6};


        Barrel__c knobCreek = new Barrel__c();
        knobCreek.Brand__c = 'Knob Creek';
        knobCreek.Case__c = c.Id;
        knobCreek.SKU__c = 'Test Barrel';
        knobCreek.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Knob_Creek_Full_Barrel').getRecordTypeId();
        knobCreek.Product_Type__c = 'Bourbon';
        
        /** changes start here on 8-Sep-20
        *	@description: new Barrel object is created with SKU__c: 'Test Barrel'
        **/
        Barrel__c knobCreek1 = new Barrel__c();
        knobCreek1.Brand__c = 'Knob Creek';
        knobCreek1.Case__c = c6.Id;
        knobCreek1.SKU__c = 'Test Barrel';
        knobCreek1.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Knob_Creek_Full_Barrel').getRecordTypeId();
        knobCreek1.Product_Type__c = 'Bourbon';
        
        /** changes end here on 8-Sep-20
        *
        **/

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
		
        insert new List<Barrel__c> {knobCreek,knobCreek1, makersMark, knobCreekSplit, knobCreekSplitNoAccount };
       
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

        insert new List<Case> {splitCase, splitCaseNoAccount};
        
        String posItemsJson = '[{'
                              + '    "Type__c": "Barrel Plaque",'
                              + '    "Attention__c": "Ramon Perez",'
                              + '    "Company__c": "Southern Glazer\'s Wine & Spirits",'
                              + '    "Street__c": "300 East Crossroads Parkway",'
                              + '    "City__c": "Bollingbrook",'
                              + '    "Country__c": "US",'
                              + '    "State__c": "NY",'
                              + '    "Zip__c": "60440",'
                              + '    "Phone__c": "(312) 659-9373"'
                              + '}, {'
                              + '    "Type__c": "Hang Tag",'
                              + '    "Attention__c": "Ramon Perez",'
                              + '    "Company__c": "Southern Glazer\'s Wine & Spirits",'
                              + '    "Street__c": "300 East Crossroads Parkway",'
                              + '    "City__c": "Bollingbrook",'
                              + '    "Country__c": "US",'
                              + '    "State__c": "NY",'
                              + '    "Zip__c": "60440",'
                              + '    "Phone__c": "(312) 659-9373"'
                              + '}, {'
                              + '    "Type__c": "Pour Spout",'
                              + '    "Attention__c": "Ramon Perez",'
                              + '    "Company__c": "Southern Glazer\'s Wine & Spirits",'
                              + '    "Street__c": "300 East Crossroads Parkway",'
                              + '    "City__c": "Bollingbrook",'
                              + '    "Country__c": "US",'
                              + '    "State__c": "NY",'
                              + '    "Zip__c": "60440",'
                              + '    "Phone__c": "(312) 659-9373"'
                              + '}, {'
                              + '    "Type__c": "Menu Insert Card",'
                              + '    "Attention__c": "Ramon Perez",'
                              + '    "Company__c": "Southern Glazer\'s Wine & Spirits",'
                              + '    "Street__c": "300 East Crossroads Parkway",'
                              + '    "City__c": "Bollingbrook",'
                              + '    "Country__c": "US",'
                              + '    "State__c": "NY",'
                              + '    "Zip__c": "60440",'
                              + '    "Phone__c": "(312) 659-9373"'
                              + '}, {'
                              + '    "Type__c": "Bottle Cradle",'
                              + '    "Attention__c": "Ramon Perez",'
                              + '    "Company__c": "Southern Glazer\'s Wine & Spirits",'
                              + '    "Street__c": "300 East Crossroads Parkway",'
                              + '    "City__c": "Bollingbrook",'
                              + '    "Country__c": "US",'
                              + '    "State__c": "NY",'
                              + '    "Zip__c": "60440",'
                              + '    "Phone__c": "(312) 659-9373"'
                              + '}, {'
                              + '    "Type__c": "Barrel",'
                              + '    "Attention__c": "Ramon Perez",'
                              + '    "Company__c": "Southern Glazer\'s Wine & Spirits",'
                              + '    "Street__c": "300 East Crossroads Parkway",'
                              + '    "City__c": "Bollingbrook",'
                              + '    "Country__c": "US",'
                              + '    "State__c": "NY",'
                              + '    "Zip__c": "60440",'
                              + '    "Phone__c": "(312) 659-9373"'
                              + '}]';
        
        /** changes start here on 8-Sep-20
		* @description: data created for POS_Customization__c
		**/
        POS_Customization__c pos1= new POS_Customization__c();
        pos1.Type__c= 'Bottle Plate Text';
        pos1.Insert_Text__c='test'; 
        pos1.Barrel__c= makersMark.Id;
        
        POS_Customization__c pos2= new POS_Customization__c();
        pos2.Type__c= 'Bottle Plate Text';
        pos2.Insert_Text__c='test'; 
        pos2.Case__c= c5.Id;

        POS_Customization__c pos3= new POS_Customization__c();
        pos3.Type__c= 'Bottle Label Text City and State';
        pos3.Insert_Text__c='test'; 
        pos3.Case__c= c5.Id;




        insert new List<POS_Customization__c> {pos1, pos2, pos3};
		/** changes end here on 8-Sep-20
        *
        **/
    }
    
    public static String getPosItemsJson(){
        String posItemJson= '[{'
                              + '    "Type__c": "Bottle Plate Text",'
                              + '    "Attention__c": "Ramon Perez",'
                              + '    "Company__c": "Southern Glazer\'s Wine & Spirits",'
                              + '    "Street__c": "300 East Crossroads Parkway",'
                              + '    "City__c": "Bollingbrook",'
                              + '    "Country__c": "US",'
                              + '    "State__c": "NY",'
                              + '    "Zip__c": "60440",'
                              + '    "Phone__c": "(312) 659-9373"'
                              + '}, {'
                              + '    "Type__c": "Hang Tag",'
                              + '    "Attention__c": "Ramon Perez",'
                              + '    "Company__c": "Southern Glazer\'s Wine & Spirits",'
                              + '    "Street__c": "300 East Crossroads Parkway",'
                              + '    "City__c": "Bollingbrook",'
                              + '    "Country__c": "US",'
                              + '    "State__c": "NY",'
                              + '    "Zip__c": "60440",'
                              + '    "Phone__c": "(312) 659-9373"'
                              + '}, {'
                              + '    "Type__c": "Pour Spout",'
                              + '    "Attention__c": "Ramon Perez",'
                              + '    "Company__c": "Southern Glazer\'s Wine & Spirits",'
                              + '    "Street__c": "300 East Crossroads Parkway",'
                              + '    "City__c": "Bollingbrook",'
                              + '    "Country__c": "US",'
                              + '    "State__c": "NY",'
                              + '    "Zip__c": "60440",'
                              + '    "Phone__c": "(312) 659-9373"'
                              + '}, {'
                              + '    "Type__c": "Menu Insert Card",'
                              + '    "Attention__c": "Ramon Perez",'
                              + '    "Company__c": "Southern Glazer\'s Wine & Spirits",'
                              + '    "Street__c": "300 East Crossroads Parkway",'
                              + '    "City__c": "Bollingbrook",'
                              + '    "Country__c": "US",'
                              + '    "State__c": "NY",'
                              + '    "Zip__c": "60440",'
                              + '    "Phone__c": "(312) 659-9373"'
                              + '}, {'
                              + '    "Type__c": "Bottle Cradle",'
                              + '    "Attention__c": "Ramon Perez",'
                              + '    "Company__c": "Southern Glazer\'s Wine & Spirits",'
                              + '    "Street__c": "300 East Crossroads Parkway",'
                              + '    "City__c": "Bollingbrook",'
                              + '    "Country__c": "US",'
                              + '    "State__c": "NY",'
                              + '    "Zip__c": "60440",'
                              + '    "Phone__c": "(312) 659-9373"'
                              + '}, {'
                              + '    "Type__c": "Barrel",'
                              + '    "Attention__c": "Ramon Perez",'
                              + '    "Company__c": "Southern Glazer\'s Wine & Spirits",'
                              + '    "Street__c": "300 East Crossroads Parkway",'
                              + '    "City__c": "Bollingbrook",'
                              + '    "Country__c": "US",'
                              + '    "State__c": "NY",'
                              + '    "Zip__c": "60440",'
                              + '    "Phone__c": "(312) 659-9373"'
                              + '}]';
        return posItemJson;
    }

    public static Case getCaseById(Id caseId) {
        return [select id, POS_Items_Selected__c, Bottle_Text_Entered__c,Status  from Case where Id = :caseId limit 1];
    }

    public static Account_Barrel_Recipe__c getBarrelRecipeByAccountName(String accountName) {
        return [select id, Barrel_Recipe__c from Account_Barrel_Recipe__c where Account__r.Name = :accountName limit 1];
    }

    public static Case getCaseByBrand(String brand) {
        return [select id, Barrel_Selected__c, AccountId, Retail_Account__c, Status, Remote_Selection_Date__c from Case where Brand__c = :brand limit 1];
    }
    
    /** changes start here on 8-Sep-20
    * @description: This method is used to get case by brand and type
    **/
    public static Case getCaseByBrandAndType(String brand, String type) {
        return [select id, Barrel_Selected__c, AccountId, Retail_Account__c, Status, Remote_Selection_Date__c from Case where Brand__c = :brand AND Type = :type limit 1];
    }
    /** changes end here on 8-Sep-20
    *
    **/
    public static List<Case> getCurrentNumberOfCases() {
        return [select Id from Case];
    }

    public static List<Barrel__c> getCurrentNumberOfBarrels() {
        return [select Id from Barrel__c];
    }

    public static Barrel__c getBarrelByBrand(String brand) {
        return [select Id, Case__c from Barrel__c where Brand__c = :brand limit 1];
    }

    public static Barrel__c getBarrelBySku(String sku) {
        return [select Id, Case__c,Case__r.Status from Barrel__c where SKU__c = :sku limit 1];
    }
    
    /**changes start here on 8-Sep-20
    *	@description: This method is used where Account_Missing__c is set true
    **/
    public static Barrel__c getBarrelBySkuAccountMissing(String sku) {
        return [select Id, Case__c,Case__r.Status from Barrel__c where SKU__c = :sku AND Case__r.Account_Missing__c= true limit 1];
    }
    
    /**
    * changes end here on 8-Sep-20
    **/

    public static Account getTestAccount() {
        return [select id from Account where Name = 'Test Account'];
    }

    public static List<POS_Customization__c> getPOSCustomizationsByBarrel(Id barrelId) {
        return [select id, Insert_Text__c,Type__c from POS_Customization__c where Barrel__c = :barrelId];
    }

    public static List<POS_Customization__c> getPOSCustomizationsByCase(Id caseId) {
        return [select id, Insert_Text__c from POS_Customization__c where Case__c = :caseId];
    }


    public static testMethod void getSingleBarrelCustomMetaDataSettingsTest() {
        
        Test.startTest();

        Barrel__c barrel = getBarrelByBrand('Knob Creek');
        List<POS_Customization__c> posItems = new List<POS_Customization__c>();
        posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Barrel Plaque', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));
        posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Floor Display', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));
        posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Barrel', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));

        insert posItems;

        LightningComponentUtility.RequestStatus response = SBP_POSItemCmpCtrl.getSingleBarrelCustomMetaDataSettings('Indiana', 'Knob Creek', 'On Premise','Rye');
        Test.stopTest();

        System.assertNotEquals(NULL, response.responseMap.get('brandToPOSItemMap'), 'Custom metadata should be returned');

    }

    public static testMethod void insertPOSItemsBarrelTest() { 

        Test.startTest();

        Barrel__c barrel = getBarrelByBrand('Makers Mark');
        List<POS_Customization__c> posItems = [select id from POS_Customization__c];
        //System.assertEquals(0, posItems.size(), 'There should not be any POS Items created');
		
        LightningComponentUtility.RequestStatus response = SBP_POSItemCmpCtrl.insertPOSItems(getPosItemsJson(), String.valueOf(barrel.Id));

        Test.stopTest();

        System.assertEquals(6, response.responseMap.get('numberOfPosItems'), '6 POS Items should have been added');
    }
    /** changes start here on 8-Sep-20
    *	@description: This testMethod is used when objectType = 'Case__c' 
    **/ 
    public static testMethod void insertPOSItemsCaseTest() {  

        Test.startTest();

        Barrel__c barrel = getBarrelByBrand('Makers Mark');
        List<POS_Customization__c> posItems = [select id from POS_Customization__c];
        //System.assertEquals(0, posItems.size(), 'There should not be any POS Items created');

        LightningComponentUtility.RequestStatus response = SBP_POSItemCmpCtrl.insertPOSItems(getPosItemsJson(), getCaseByBrand('Makers Mark').Id);
		
        Test.stopTest();

        System.assertEquals(6, response.responseMap.get('numberOfPosItems'), '6 POS Items should have been added');
    }
    
    /** changes start here on 8-Sep-20
    *	@description: This testMethod is used when objectType = 'Case__c' && Type__c = 'Bottle Plate Text' 
    **/
    public static testMethod void insertPOSItemsCaseByTypeTest() {

        Test.startTest();

        Barrel__c barrel = getBarrelByBrand('Makers Mark');
        List<POS_Customization__c> posItems = [select id from POS_Customization__c];
        //System.assertEquals(0, posItems.size(), 'There should not be any POS Items created');

        LightningComponentUtility.RequestStatus response1 = SBP_POSItemCmpCtrl.insertPOSItems('[]', getCaseByBrandAndType('Makers Mark', 'Split Barrel').Id);
        Test.stopTest();

        System.assertEquals(0, response1.responseMap.get('numberOfPosItems'), 'No POS Items should have been added');
    }
    /** changes end here on 8-Sep-20
    *
    **/
    

    public static testMethod void getDistributorRecordTest() {

        Test.startTest();

        Barrel__c barrel = getBarrelBySku('Test Barrel');
        LightningComponentUtility.RequestStatus response = SBP_POSItemCmpCtrl.getDistributorRecord(String.valueOf(barrel.Id));

        Test.stopTest();

        System.assertNotEquals(NULL, response.responseMap.get('account'), 'account should be returned');
    }
    
    /** changes start here on 8-Sep-20
    *	@description: This method is used to test DistributorRecord by Brand on Case__c
    **/
    public static testMethod void getDistributorRecordByBrandTest() {
        
        Test.startTest();
        Barrel__c barrel = getBarrelBySku('Test Barrel');
        LightningComponentUtility.RequestStatus response1 = SBP_POSItemCmpCtrl.getDistributorRecord(getCaseByBrand('Makers Mark').Id);

        Test.stopTest();
        System.assertNotEquals(NULL, response1.responseMap.get('account'), 'account should be returned');
    }

    public static testMethod void getDistributorRecordErrorTest() {

        Test.startTest();

        Barrel__c barrel = getBarrelBySku('Test Barrel');
        LightningComponentUtility.RequestStatus response = SBP_POSItemCmpCtrl.getDistributorRecord('');

        Test.stopTest();

        System.assertEquals(false, response.success, 'Operation should not return successfully');
    }

    public static testMethod void updateStepsAsCompletedTest() {
        Test.startTest();
        Barrel__c barrel = getBarrelBySku('Test Barrel');
        Case c = getCaseById(barrel.Case__c);
        LightningComponentUtility.RequestStatus response = SBP_POSItemCmpCtrl.updateStepsAsCompleted(String.valueOf(barrel.Id), true, true);
        Case updatedCase = getCaseById(barrel.Case__c);
        Test.stopTest();
        
		System.assertEquals(c.POS_Items_Selected__c, false);
        System.assertEquals(c.Bottle_Text_Entered__c, false);
        System.assertEquals(updatedCase.POS_Items_Selected__c, true);
        System.assertEquals(updatedCase.Bottle_Text_Entered__c, true);
        System.assertNotEquals(NULL, response.responseMap.get('updatedRecord'), 'updatedRecord should be returned');
    }
    
    /** changes start here on 8-Sep-20
    *	@description: This method is used to get Case__c by Brand
    **/
    public static testMethod void updateStepsAsCompletedByBrandTest() {
        Test.startTest();
        Barrel__c barrel = getBarrelBySku('Test Barrel');
        Case c = getCaseById(barrel.Case__c);
        LightningComponentUtility.RequestStatus response1 = SBP_POSItemCmpCtrl.updateStepsAsCompleted(getCaseByBrand('Makers Mark').Id, true, true);
        Case updatedCase = getCaseById(barrel.Case__c);
        Test.stopTest();
        System.assertEquals(c.POS_Items_Selected__c, false);
        System.assertEquals(c.Bottle_Text_Entered__c, false);
        System.assertEquals(updatedCase.POS_Items_Selected__c, false);
        System.assertEquals(updatedCase.Bottle_Text_Entered__c, false);
        System.assertNotEquals(NULL, response1.responseMap.get('updatedRecord'), 'updatedRecord should be returned');

    }
    
    /** changes end here on 8-Sep-20
    *
    **/
    public static testMethod void updateStepsAsCompletedErrorTest() {
        Test.startTest();
        Case c = getCaseByBrand('Knob Creek');
        LightningComponentUtility.RequestStatus response = SBP_POSItemCmpCtrl.updateStepsAsCompleted('', false, false);
        Test.stopTest();
        System.assertEquals(false, response.success, 'Operation should not return successfully');
    }

    public static testMethod void getBottleLabelImagesTest() {
        Test.startTest();
        Barrel__c barrel = getBarrelBySku('Test Barrel');
        Case c = getCaseById(barrel.Case__c);        
        LightningComponentUtility.RequestStatus response = SBP_POSItemCmpCtrl.getBottleLabelImages('Indiana', 'On Premise');
        Test.stopTest();
        System.assertEquals(c.POS_Items_Selected__c, false);
        System.assertEquals(c.Bottle_Text_Entered__c, false);
        System.assertNotEquals(NULL, response.responseMap.get('bottleLabelMap'), 'Bottle plate labels should be uploaded');
    }

    public static testMethod void getBottleLabelImagesNewYorkTest() {
        Test.startTest();
        Barrel__c barrel = getBarrelBySku('Test Barrel');
        Case c = getCaseById(barrel.Case__c);
        LightningComponentUtility.RequestStatus response = SBP_POSItemCmpCtrl.getBottleLabelImages('New York', 'On Premise');
        Test.stopTest();
        System.assertEquals(c.POS_Items_Selected__c, false);
        System.assertEquals(c.Bottle_Text_Entered__c, false);
        System.assertNotEquals(NULL, response.responseMap.get('bottleLabelMap'), 'Bottle plate labels should be uploaded');
    }

    public static testMethod void getRecordDetailsCaseTest() {
        Test.startTest();
        Barrel__c barrel = getBarrelBySku('Test Barrel');
        Case c = getCaseById(barrel.Case__c);
        LightningComponentUtility.RequestStatus response = SBP_POSItemCmpCtrl.getRecordDetails(String.ValueOf(c.Id));
        Test.stopTest();
        System.assertEquals(c.POS_Items_Selected__c, false);
        System.assertEquals(c.Bottle_Text_Entered__c, false);
        System.assertEquals('On Premise', response.responseMap.get('premiseType'), 'Should be On Premise type');
    }
    
    /** changes start here on 8-Sep-20
    * @descripition: This method is used to get record details by Brand and Type
    **/
    public static testMethod void getRecordDetailsCaseByBrandAndTypeTest() {
        Test.startTest();
        Barrel__c barrel = getBarrelBySku('Test Barrel');
        Case c = getCaseById(barrel.Case__c);
        LightningComponentUtility.RequestStatus response1 = SBP_POSItemCmpCtrl.getRecordDetails(getCaseByBrandAndType('Makers Mark', 'Split Barrel').Id);
        Test.stopTest();
        System.assertEquals(c.POS_Items_Selected__c, false);
        System.assertEquals(c.Bottle_Text_Entered__c, false);
        System.assertEquals(NULL, response1.responseMap.get('premiseType'), 'Should be NULL');
    }

    public static testMethod void getRecordDetailsBarrelTest() {
        Test.startTest();
        Barrel__c barrel = getBarrelBySku('Test Barrel');
        Case c = getCaseById(barrel.Case__c);
        LightningComponentUtility.RequestStatus response = SBP_POSItemCmpCtrl.getRecordDetails(String.ValueOf(barrel.Id));
        Test.stopTest();
        System.assertEquals(c.POS_Items_Selected__c, false);
        System.assertEquals(c.Bottle_Text_Entered__c, false);
        System.assertEquals('On Premise', response.responseMap.get('premiseType'), 'Should be On Premise type');
    }
    
    /** changes start here on 8-Sep-20
    *@description: This method is used to test record details with Account_Missing on Case__c set to true;
    **/
    public static testMethod void getRecordDetailsBarrelAccountMissingTest() {
        Test.startTest();
        Barrel__c barrel = getBarrelBySku('Test Barrel');
        Case c = getCaseById(barrel.Case__c);
        LightningComponentUtility.RequestStatus response1 = SBP_POSItemCmpCtrl.getRecordDetails(getBarrelBySkuAccountMissing('Test Barrel').Id);
        Test.stopTest();
		System.assertEquals(c.POS_Items_Selected__c, false);
        System.assertEquals(c.Bottle_Text_Entered__c, false);	
        System.assertEquals(NULL, response1.responseMap.get('premiseType'), 'Should be NULL');
    }

    public static testMethod void getRecordDetailsBarrelErrorTest() {
        Test.startTest();
        LightningComponentUtility.RequestStatus response = SBP_POSItemCmpCtrl.getRecordDetails('');
        Test.stopTest();
        System.assertEquals(false, response.success, 'Operation should not return successfully');
    }

    public static testMethod void getPosItemsTest() {
        
        Test.startTest();
        
        Barrel__c barrel = getBarrelByBrand('Knob Creek');
        List<POS_Customization__c> posItems = new List<POS_Customization__c>();
        posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Barrel Plaque', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));
        posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Floor Display', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));
        posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Barrel', Barrel__c = barrel.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));
        insert posItems;
        LightningComponentUtility.RequestStatus response = SBP_POSItemCmpCtrl.getPOSRecords(String.valueOf(barrel.Case__c));
        Test.stopTest();
        System.assertEquals(3, response.responseMap.get('numOfPOSItems'), '3 POS Items should exist');
    }

    public static testMethod void getPosItemsErrorTest() {
        
        Test.startTest();
        
        Barrel__c barrel = getBarrelByBrand('Knob Creek');
        LightningComponentUtility.RequestStatus response = SBP_POSItemCmpCtrl.getPOSRecords('');
        
        Test.stopTest();
        System.assertEquals(false, response.success, 'Operation should not return successfully');
    }
    
    public static testMethod void getAccountTest(){
        Test.startTest();
        Barrel__c barrel = getBarrelBySku('Test Barrel');
        Case c = getCaseById(barrel.Case__c);
        SBP_POSItemCmpCtrl.getAccountNamefromCase(c.Id);
        Test.stopTest();
    }
    
    public static testMethod void getCaseStatusTest(){
        Test.startTest();
        Barrel__c barrel = getBarrelBySku('Test Barrel');
	    // Barrel__c barrelrec = new Barrel__c();
        Case c = getCaseById(barrel.Case__c);
        SBP_POSItemCmpCtrl.getRecordStatusDetails(barrel.Id); 
        Test.stopTest();
    }
    
    //added by Nishant Khandal for LSB-76
    @isTest
    public static void testGetPOSRecordBrand() {
		
        Test.startTest();
        Case testCase = new Case();
        testCase.Brand__c = SBP_Constants.LAPHROAIG_SINGLE_CASK;
        INSERT testCase;
        	String testBrandValue = SBP_POSItemCmpCtrl.getPOSRecordBrand(Id.valueOf(testCase.Id));
        Test.stopTest();
        System.assertEquals(SBP_Constants.LAPHROAIG_SINGLE_CASK, testBrandValue, 'Correct Brand is Fetched');
        
    }

    @isTest
    public static void testgetPOSrecordAttachements() {
        Barrel__c  barrel = getBarrelByBrand('Makers Mark');
        List<POS_Customization__c> posCustomizationList = getPOSCustomizationsByBarrel(barrel.Id);
        ContentVersion content=new ContentVersion();
        ContentVersion contentVersion = new ContentVersion();
        content.Title='Header_Picture1';
        content.PathOnClient='/' + content.Title + '.jpg';
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body');
        content.VersionData=bodyBlob;
        content.Description = posCustomizationList[0].Id; 
        content.IsMajorVersion = true;	
        insert content;
        List<ContentDocument> documentsObj = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId=:content.Id];
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=posCustomizationList[0].Id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'V';
        contentlink.Visibility = 'AllUsers';
        insert contentlink;
        List<ContentDistribution> contentDistributionList = new List<ContentDistribution>();
        for(POS_Customization__c posRecord : posCustomizationList){
            if(posRecord.Type__c=='Bottle Plate Text'){
                ContentDistribution conDis = new ContentDistribution();
                conDis.Name = content.Title;
                conDis.ContentVersionId = content.Id;
                conDis.PreferencesAllowViewInBrowser= true;
                conDis.PreferencesNotifyOnVisit = false;
                conDis.PreferencesAllowViewInBrowser = true;
                conDis.PreferencesAllowOriginalDownload=true;
                conDis.RelatedRecordId = posRecord.Id;
                conDis.PreferencesLinkLatestVersion=true;
                conDis.PreferencesPasswordRequired=false;
                contentDistributionList.add(conDis);
            }
        }
        insert  contentDistributionList;

        Test.startTest();
            LightningComponentUtility.RequestStatus response = SBP_POSItemCmpCtrl.getPOSrecordAttachements(String.valueOf(barrel.Case__c));
        Test.stopTest();
        System.assertEquals(true, response.success);
    }
    
    @isTest
    public static void testsendEmailToCustomers() {
        Barrel__c  barrel = getBarrelByBrand('Makers Mark');
        List<POS_Customization__c> posCustomizationList = getPOSCustomizationsByBarrel(barrel.Id);
        ContentVersion content=new ContentVersion();
        ContentVersion contentVersion = new ContentVersion();
        content.Title='Header_Picture1';
        content.PathOnClient='/' + content.Title + '.jpg';
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body');
        content.VersionData=bodyBlob;
        content.Description = posCustomizationList[0].Id; 
        content.IsMajorVersion = true;
        insert content;
        List<ContentDocument> documentsObj = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId=:content.Id];
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=posCustomizationList[0].Id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'V';
        contentlink.Visibility = 'AllUsers';
        insert contentlink;
        List<ContentDistribution> contentDistributionList = new List<ContentDistribution>();
        for(POS_Customization__c posRecord : posCustomizationList){
            if(posRecord.Type__c=='Bottle Plate Text'){
                ContentDistribution conDis = new ContentDistribution();
                conDis.Name = content.Title;
                conDis.ContentVersionId = content.Id;
                conDis.PreferencesAllowViewInBrowser= true;
                conDis.PreferencesNotifyOnVisit = false;
                conDis.PreferencesAllowViewInBrowser = true;
                conDis.PreferencesAllowOriginalDownload=true;
                conDis.RelatedRecordId = posRecord.Id;
                conDis.PreferencesLinkLatestVersion=true;
                conDis.PreferencesPasswordRequired=false;
                contentDistributionList.add(conDis);
            }
        }
        insert  contentDistributionList;
        LightningComponentUtility.RequestStatus response = SBP_POSItemCmpCtrl.getPOSrecordAttachements(String.valueOf(barrel.Case__c));
        List<SBP_POSItemCmpCtrl.POSAttachementDetails> posAttachementDetailsList = new List<SBP_POSItemCmpCtrl.POSAttachementDetails>(); 
        posAttachementDetailsList = (List<SBP_POSItemCmpCtrl.POSAttachementDetails>)response.responseMap.get('posAttachementDetailsList');
        posAttachementDetailsList[0].toEmailAddress = 'standarduser@testorg.com';
        posAttachementDetailsList[0].ccEmailAddress = 'standarduser@testorg.com';
        String jasonWrapper = JSON.serialize(response.responseMap.get('posAttachementDetailsList'));

        Test.startTest();
            String result = SBP_POSItemCmpCtrl.sendEmailToCustomers(jasonWrapper);
        Test.stopTest();
        System.assertEquals(result,'success');
    }

    @isTest
    private static void testInsertPOSAttachmentImage(){
        Barrel__c  barrel = getBarrelByBrand('Makers Mark');
        List<POS_Customization__c> posCustomizationList = getPOSCustomizationsByBarrel(barrel.Id);
        List<Map<String,String>> listMap = new List<Map<String,String>>();
        map<String,String> valueMap = new map<String, String>();
        valueMap.put('parentId',posCustomizationList[0].Id);
        valueMap.put('body','Hello Friend');
        valueMap.put('contentType','text');
        valueMap.put('name','02195074_Off Premise Account 1 Distributor.txt');
        listMap.add(valueMap);
        String jsonContent = JSON.serialize(listMap);

        Test.startTest();

        LightningComponentUtility.RequestStatus returnRequest = SBP_POSItemCmpCtrl.insertPOSAttachmentImage(jsonContent);

        Test.stopTest();
        System.assert(returnRequest.success,'Failed Assertion');
    }

    @isTest
    private static void testGetAttachment(){
        Barrel__c  barrel = getBarrelByBrand('Makers Mark');
        List<POS_Customization__c> posCustomizationList = getPOSCustomizationsByBarrel(barrel.Id);
        List<Map<String,String>> posMapList = new List<Map<String,String>>();
        map<String,String> posDataValueMap = new map<String, String>();
        posDataValueMap.put('parentId',posCustomizationList[0].Id);
        posDataValueMap.put('body','Hello Friend');
        posDataValueMap.put('contentType','text');
        posDataValueMap.put('name','02195074_Off Premise Account 1 Distributor.txt');
        posMapList.add(posDataValueMap);
        String jsonContent = JSON.serialize(posMapList);
        SBP_POSItemCmpCtrl.insertPOSAttachmentImage(jsonContent);

        Test.startTest();

        LightningComponentUtility.RequestStatus returnRequest = SBP_POSItemCmpCtrl.getAttachment(posCustomizationList[0].Id);

        Test.stopTest();
        System.assert(returnRequest.success, 'Failed Assertion! Could not fetch attachment');
    }

    @isTest
    private static void testGetBrandStaveMapForBarrelId(){
        Barrel__c  barrel = getBarrelByBrand('Makers Mark');
        List<POS_Customization__c> posCustomizationList = getPOSCustomizationsByBarrel(barrel.Id);
        Barrel_Recipe__c barrelRecipe = new Barrel_Recipe__c(Brand__c = 'Makers Mark');
        insert barrelRecipe;
        barrel.Barrel_Recipe__c = barrelRecipe.Id;
        update barrel;
        List<Stave__c> staveList = new List<Stave__c>();
        staveList.add(new Stave__c(Name = 'Baked_American_Pure_2__c', Barrel_Recipe__c = barrelRecipe.Id, Type__c = 'Baked American Pure 2', Quantity__c = 4));
        staveList.add(new Stave__c(Name = 'Mendiant__c', Barrel_Recipe__c = barrelRecipe.Id, Type__c = 'Mendiant', Quantity__c = 6));
        insert staveList;

        Test.startTest();

        LightningComponentUtility.RequestStatus returnRequest = SBP_POSItemCmpCtrl.getBrandStaveMap(barrel.Id);

        Test.stopTest();
        System.assert(returnRequest.success, 'Failed Assertion! Could not fetch stave information for barrel');
    }

    @isTest
    private static void testGetBrandStaveMapForCaselId(){
        Barrel__c  barrel = getBarrelByBrand('Makers Mark');
        List<POS_Customization__c> posCustomizationList = getPOSCustomizationsByBarrel(barrel.Id);
        Barrel_Recipe__c barrelRecipe = new Barrel_Recipe__c(Brand__c = 'Makers Mark');
        insert barrelRecipe;
        barrel.Barrel_Recipe__c = barrelRecipe.Id;
        update barrel;
        List<Stave__c> staveList = new List<Stave__c>();
        staveList.add(new Stave__c(Name = 'Baked_American_Pure_2__c', Barrel_Recipe__c = barrelRecipe.Id, Type__c = 'Baked American Pure 2', Quantity__c = 4));
        staveList.add(new Stave__c(Name = 'Mendiant__c', Barrel_Recipe__c = barrelRecipe.Id, Type__c = 'Mendiant', Quantity__c = 6));
        insert staveList;

        Test.startTest();

        LightningComponentUtility.RequestStatus returnRequest = SBP_POSItemCmpCtrl.getBrandStaveMap(barrel.Case__c);

        Test.stopTest();
        System.assert(returnRequest.success, 'Failed Assertion! Could not fetch stave information for case');
    }

    @isTest
    private static void testGetPOSRecordWithStaveInfoForMM(){
        Barrel__c  barrel = getBarrelByBrand('Makers Mark');
        List<POS_Customization__c> posCustomizationList = getPOSCustomizationsByBarrel(barrel.Id);
        Barrel_Recipe__c barrelRecipe = new Barrel_Recipe__c(Brand__c = 'Makers Mark');
        insert barrelRecipe;
        barrel.Barrel_Recipe__c = barrelRecipe.Id;
        update barrel;
        List<Stave__c> staveList = new List<Stave__c>();
        staveList.add(new Stave__c(Name = 'Baked_American_Pure_2__c', Barrel_Recipe__c = barrelRecipe.Id, Type__c = 'Baked American Pure 2', Quantity__c = 4));
        staveList.add(new Stave__c(Name = 'Mendiant__c', Barrel_Recipe__c = barrelRecipe.Id, Type__c = 'Mendiant', Quantity__c = 6));
        insert staveList;

        Test.startTest();

        LightningComponentUtility.RequestStatus returnRequest = SBP_POSItemCmpCtrl.getPOSRecordWithStaveInfoForMM(posCustomizationList[0].Id);

        Test.stopTest();
        System.assert(returnRequest.success, 'Failed Assertion! Could not fetch POS record with stave information for Makers Mark');
    }

    @isTest
    private static void testUpsertPOSItems(){
        Barrel__c  barrel = getBarrelByBrand('Makers Mark');
        List<POS_Customization__c> posCustomizationList = getPOSCustomizationsByBarrel(barrel.Id);
        List<Map<String,String>> posMapList = new List<Map<String,String>>();
        map<String,String> posDataValueMap = new map<String, String>();
        posDataValueMap.put('id',posCustomizationList[0].Id);
        posDataValueMap.put('insertText','Test One Two');
        posDataValueMap.put('barrel',barrel.Id);
        posDataValueMap.put('type',posCustomizationList[0].Type__c);
        posDataValueMap.put('posItemSeq','0');
        posDataValueMap.put('state','WA');
        posMapList.add(posDataValueMap);

        Test.startTest();

        LightningComponentUtility.RequestStatus returnRequest = SBP_POSItemCmpCtrl.upsertPOSItems(JSON.serialize(posMapList));

        Test.stopTest();
        System.assert(returnRequest.success, 'Failed Assertion! Could not upsert POS record');
    }

    @isTest
    private static void testUpdateAttachmentImage(){
        Barrel__c  barrel = getBarrelByBrand('Makers Mark');
        List<POS_Customization__c> posCustomizationList = getPOSCustomizationsByBarrel(barrel.Id);
        List<Map<String,String>> listMap = new List<Map<String,String>>();
        map<String,String> valueMap = new map<String, String>();
        valueMap.put('parentId',posCustomizationList[0].Id);
        valueMap.put('body','Hello Friend');
        valueMap.put('contentType','text');
        valueMap.put('name','02195074_Off Premise Account 1 Distributor.txt');
        listMap.add(valueMap);
        String jsonContent = JSON.serialize(listMap);

        List<Map<String,String>> posMapList = new List<Map<String,String>>();
        map<String,String> posDataValueMap = new map<String, String>();
        posDataValueMap.put('id',posCustomizationList[0].Id);
        posDataValueMap.put('insertText','Test One Two');
        posDataValueMap.put('barrel',barrel.Id);
        posDataValueMap.put('type',posCustomizationList[0].Type__c);
        posDataValueMap.put('posItemSeq','0');
        posDataValueMap.put('state','WA');
        posMapList.add(posDataValueMap);

        SBP_POSItemCmpCtrl.insertPOSAttachmentImage(jsonContent);

        Test.startTest();

        LightningComponentUtility.RequestStatus returnRequest = SBP_POSItemCmpCtrl.updateAttachmentImage('The New Content',posCustomizationList[0].Id,JSON.serialize(posMapList));

        Test.stopTest();
        System.assert(returnRequest.success,'Failed to update the Attached Image');
    }

    @isTest
    private static void testUpdateAttachmentImageWhenAttachmentIsAbsent(){
        Barrel__c  barrel = getBarrelByBrand('Makers Mark');
        List<POS_Customization__c> posCustomizationList = getPOSCustomizationsByBarrel(barrel.Id);

        List<Map<String,String>> posMapList = new List<Map<String,String>>();
        map<String,String> posDataValueMap = new map<String, String>();
        posDataValueMap.put('id',posCustomizationList[0].Id);
        posDataValueMap.put('insertText','Test One Two');
        posDataValueMap.put('barrel',barrel.Id);
        posDataValueMap.put('type',posCustomizationList[0].Type__c);
        posDataValueMap.put('posItemSeq','0');
        posDataValueMap.put('state','WA');
        posMapList.add(posDataValueMap);

        Test.startTest();

        LightningComponentUtility.RequestStatus returnRequest = SBP_POSItemCmpCtrl.updateAttachmentImage('The New Content',posCustomizationList[0].Id,JSON.serialize(posMapList));

        Test.stopTest();
        System.assert(returnRequest.success,'Failed to update the Attached Image');
    }
}