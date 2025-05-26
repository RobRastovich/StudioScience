@isTest
private class SBP_AccountInfoCmpCtrlTest {
	@testSetup static void setup() {
        Test.startTest();
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
        
        Test.stopTest();

	}

    public static void insertAllocHierarchy(){
                List<Brand__c> lstBrand = new List<brand__c>();
        Brand__c newBrand = new Brand__c(Name = 'Knob Creek Bourbon',Is_Active__c = true);
        lstBrand.add(newBrand);
        insert lstBrand;
        String YearOfAlloc = String.valueOf(Date.today().year());
        List<Brand_Allocation__c> lstBrandAllocation = new List<Brand_Allocation__c>();
        Brand_Allocation__c newAllocation = new Brand_Allocation__c(Brand__c = newBrand.Id, Is_Active__c=true, 
                                                                    Program_Type__c='Trip and Tour', Time_Interval__c ='Year',Time_Period__c='Yearly',
                                                                   Year_Of_Allocation__c = YearOfAlloc);
        lstBrandAllocation.add(newAllocation);
        insert lstBrandAllocation;
        List<Country__c> lstCountry = new List<Country__c>();
        Country__c newCountry = new Country__c(Name='US',IsActive__c= true,Alias__c='US');
        lstCountry.add(newCountry);
        insert lstCountry;
        List<Brand_Country_Allocation__c> lstCountryAllocation = new List<Brand_Country_Allocation__c>();
        Brand_Country_Allocation__c countryAlloc = new Brand_Country_Allocation__c(Brand_Allocation__c = newAllocation.Id,
                                                                                  Country__c = newCountry.Id,Is_Active__c= true);
        lstCountryAllocation.add(countryAlloc);
        insert lstCountryAllocation;
        List<Region__c> lstRegion = new List<Region__c>();
        Region__c newRegion = new Region__c(Name = 'Cental', Country__c = newCountry.Id, IsActive__c = true);
        Region__c nationalAccount = new Region__c(Name = 'National Accounts', Country__c = newCountry.Id, IsActive__c = true);
        Region__c militaryAccount = new Region__c(Name = 'Military', Country__c = newCountry.Id, IsActive__c = true);
        lstRegion.add(newRegion);
        lstRegion.add(nationalAccount);
        lstRegion.add(militaryAccount);
        insert lstRegion;
        List<Brand_Country_Region_Allocation__c> lstRegionAlloc = new List<Brand_Country_Region_Allocation__c>();
        Brand_Country_Region_Allocation__c newRegionAlloc = new Brand_Country_Region_Allocation__c(Brand_Country_Allocation__c = countryAlloc.Id, Region__c = newRegion.Id);
        lstRegionAlloc.add(newRegionAlloc);
        Brand_Country_Region_Allocation__c newMilitaryRegionAlloc = new Brand_Country_Region_Allocation__c(Brand_Country_Allocation__c = countryAlloc.Id, Region__c = militaryAccount.Id,
                                                                                                          Is_Leaf_Node__c = true, Allocations_Per_Interval__c = 10);
        Brand_Country_Region_Allocation__c newNationAlRegion = new Brand_Country_Region_Allocation__c(Brand_Country_Allocation__c = countryAlloc.Id, Region__c = nationalAccount.Id);
        lstRegionAlloc.add(newMilitaryRegionAlloc);
        lstRegionAlloc.add(newNationAlRegion);
        insert lstRegionAlloc;
        List<State__c> lstState = new List<State__c>();
        State__c newState2 = new State__c(Name='IL', Region__c = newRegion.Id,country__c = newCountry.Id, IsActive__c = true,Alias__c='te',State_Manager__c = UserInfo.getUserId());
        State__c offPremiseState = new State__c(Name='Off Premise', Region__c = nationalAccount.Id,country__c = newCountry.Id, IsActive__c = true,Alias__c='Off',State_Manager__c = UserInfo.getUserId());
        lstState.add(newState2);
        lstState.add(offPremiseState);
        insert lstState;
        list<Brand_Country_Region_State_Allocation__c> lstStateAlloc = new List<Brand_Country_Region_State_Allocation__c>();
        Brand_Country_Region_State_Allocation__c newStateAlloc2 = new Brand_Country_Region_State_Allocation__c(Brand_Country_Region_Allocation__c = newRegionAlloc.Id, State__c = newState2.Id,
        Is_Leaf_Node__c = false, Is_Active__c = true);
        Brand_Country_Region_State_Allocation__c offPremiseStateAlloc = new Brand_Country_Region_State_Allocation__c(Brand_Country_Region_Allocation__c = newNationAlRegion.Id, State__c = offPremiseState.Id,
        Is_Leaf_Node__c = true, Is_Active__c = true, Allocations_Per_Interval__c = 10);
        lstStateAlloc.add(newStateAlloc2);
        lstStateAlloc.add(offPremiseStateAlloc);
        insert lstStateAlloc;

        list<Brand_Country_Region_State_Dist_Alloc__c> lstDistAlloc = new List<Brand_Country_Region_State_Dist_Alloc__c>();
        Brand_Country_Region_State_Dist_Alloc__c newDistAlloc = new Brand_Country_Region_State_Dist_Alloc__c(
        Account__c = getTestAccount().Id, Allocations_Per_Interval__c = 10, Brand_Country_Region_State_Allocation__c =newStateAlloc2.Id, 
            Is_Active__c=true,Is_Leaf_Node__c=true);
        lstDistAlloc.add(newDistAlloc);
        insert lstDistAlloc;
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

	public static Account getTestAccount() {
		return [select id from Account where Name = 'Test Account'];
	}
    
	public static Account getReatilerAccountAccount() {
		return [select id from Account where Name = 'Retail Account'];
	}
    
    public static Brand_Country_Region_State_Dist_Alloc__c getDistAlloc(){
        return[select Id, Allocations_Per_Interval__c,Used_Allocations__c from Brand_Country_Region_State_Dist_Alloc__c];
    }

    public static Brand_Country_Region_State_Allocation__c getStateAlloc(){
        return[select Id, Allocations_Per_Interval__c,Used_Allocations__c from Brand_Country_Region_State_Allocation__c where State__r.Name = 'IL'];
    }
    
    public static Brand_Country_Region_Allocation__c getRegionAlloc(){
        return[select Id, Allocations_Per_Interval__c,Used_Allocations__c from Brand_Country_Region_Allocation__c where Region__r.Name = 'Cental'];
    }
	public static testMethod void getSingleBarrelLabelsTest() {
		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_AccountInfoCmpCtrl.getSingleBarrelLabels();

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('labelMap'), 'There should be labels');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}

	public static testMethod void updateCaseTest() {
		Case c = getCaseByBrand('Knob Creek');

		Test.startTest();

		String jsonCases = '[{"Id":"' + c.Id + '",'
		                   + '"CcEmail__c":"",'
		                   + '"Remote_Selection_Date__c":null,'
		                   + '"Type":"Distiller\'s Choice",'
		                   + '"Premise__c":"On Premise",'
		                   + '"AccountId":"' + c.AccountId + '",'
		                   + '"Retail_Account__c":"' + c.Retail_Account__c + '",'
		                   + '"Split_Order__c":false}]';


		LightningComponentUtility.RequestStatus response = SBP_AccountInfoCmpCtrl.updateCase(jsonCases,false);

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('cases'), 'Case should be updated');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}

	public static testMethod void updateCaseNoRetailAccountInJsonTest() {
		Case c = getCaseByBrand('Knob Creek');

		Test.startTest();

		String jsonCases = '[{"Id":"' + c.Id + '",'
		                   + '"CcEmail__c":"",'
		                   + '"Remote_Selection_Date__c":null,'
		                   + '"Type":"Distiller\'s Choice",'
		                   + '"Premise__c":"On Premise",'
		                   + '"AccountId":"' + c.AccountId + '",'
		                   + '"Retail_Account__c":null,'
		                   + '"Split_Order__c":false}]';


		LightningComponentUtility.RequestStatus response = SBP_AccountInfoCmpCtrl.updateCase(jsonCases,true);

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('cases'), 'Case should be updated');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}

	public static testMethod void updateCaseNoRetailBarrelRelatedToCaseTest() {
		Case c = getCaseByBrand('Knob Creek');

		Test.startTest();

		Case c2 = new Case();
		c2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Standard').getRecordTypeId();
		c2.Type = 'Trip and Tour';
		c2.Brand__c = 'Knob Creek';
		c2.Barrel_Selected__c = false;
		c2.Product_Type__c = 'Bourbon';
		c2.ccEmail__c = 'test@test.com';
		insert c2;

		String jsonCases = '[{"Id":"' + c2.Id + '",'
		                   + '"CcEmail__c":"",'
		                   + '"Remote_Selection_Date__c":null,'
		                   + '"Type":"Distiller\'s Choice",'
		                   + '"Premise__c":"On Premise",'
		                   + '"AccountId":"' + c.AccountId + '",'
		                   + '"Retail_Account__c":null,'
		                   + '"Split_Order__c":false}]';


		LightningComponentUtility.RequestStatus response = SBP_AccountInfoCmpCtrl.updateCase(jsonCases,true);

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('cases'), 'Case should be updated');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}



	public static testMethod void getPicklistValuesTest() {

		Test.startTest();

		Map<String, List<String>> fieldMap = SBP_AccountInfoCmpCtrl.getSingleBarrelPicklistValues();

		Test.stopTest();

		System.assertNotEquals(NULL, fieldMap.get('premise'), 'Premise shoudl not be empty');
	}

		public static testMethod void updateCaseForNoAllocationAailableOnDist() {
		Case c = getCaseByBrand('Knob Creek');
            insertAllocHierarchy();
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Used_Allocations__c = 10;
        update distAlloc;
            
		Test.startTest();

		String jsonCases = '[{"Id":"' + c.Id + '",'
		                   + '"CcEmail__c":"",'
		                   + '"Remote_Selection_Date__c":null,'
		                   + '"Type":"Distiller\'s Choice",'
		                   + '"Premise__c":"On Premise",'
		                   + '"AccountId":"' + c.AccountId + '",'
		                   + '"Retail_Account__c":null,'
		                   + '"Split_Order__c":false}]';


		LightningComponentUtility.RequestStatus response = SBP_AccountInfoCmpCtrl.updateCase(jsonCases,true);

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('cases'), 'Case should be updated');
		System.assertEquals(false, response.success, 'Operation should return successfully');
	}

    public static testMethod void updateCaseForNoAllocationAvailableOnState() {
		Case c = getCaseByBrand('Knob Creek');
        insertAllocHierarchy();
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        delete distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = true;
        stateAlloc.Allocations_Per_Interval__c = 10;
        stateAlloc.Used_Allocations__c = 10;
        update stateAlloc;
		Test.startTest();

		String jsonCases = '[{"Id":"' + c.Id + '",'
		                   + '"CcEmail__c":"",'
		                   + '"Remote_Selection_Date__c":null,'
		                   + '"Type":"Distiller\'s Choice",'
		                   + '"Premise__c":"On Premise",'
		                   + '"AccountId":"' + c.AccountId + '",'
		                   + '"Retail_Account__c":null,'
		                   + '"Split_Order__c":false}]';


		LightningComponentUtility.RequestStatus response = SBP_AccountInfoCmpCtrl.updateCase(jsonCases,true);

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('cases'), 'Case should be updated');
		System.assertEquals(false, response.success, 'Operation should return successfully');
	}
    
    public static testMethod void updateCaseForNoAllocationAvailableOnRegion() {
		Case c = getCaseByBrand('Knob Creek');
        insertAllocHierarchy();
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        delete distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = false;
        delete stateAlloc;
        Brand_Country_Region_Allocation__c regionAlloc = getRegionAlloc();
        regionAlloc.Is_Leaf_Node__c = true;
        regionAlloc.Allocations_Per_Interval__c = 10;
        regionAlloc.Used_Allocations__c = 10;
        update regionAlloc;
		Test.startTest();

		String jsonCases = '[{"Id":"' + c.Id + '",'
		                   + '"CcEmail__c":"",'
		                   + '"Remote_Selection_Date__c":null,'
		                   + '"Type":"Distiller\'s Choice",'
		                   + '"Premise__c":"On Premise",'
		                   + '"AccountId":"' + c.AccountId + '",'
		                   + '"Retail_Account__c":null,'
		                   + '"Split_Order__c":false}]';


		LightningComponentUtility.RequestStatus response = SBP_AccountInfoCmpCtrl.updateCase(jsonCases,true);

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('cases'), 'Case should be updated');
		System.assertEquals(false, response.success, 'Operation should return successfully');
	}
    
    public static testMethod void updateCaseForAllocationAvailableOnRegion() {
		Case c = getCaseByBrand('Knob Creek');
        insertAllocHierarchy();
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        delete distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = false;
        delete stateAlloc;
        Brand_Country_Region_Allocation__c regionAlloc = getRegionAlloc();
        regionAlloc.Is_Leaf_Node__c = true;
        regionAlloc.Allocations_Per_Interval__c = 10;
        regionAlloc.Used_Allocations__c = 0;
        update regionAlloc;
		Test.startTest();

		String jsonCases = '[{"Id":"' + c.Id + '",'
		                   + '"CcEmail__c":"",'
		                   + '"Remote_Selection_Date__c":null,'
		                   + '"Type":"Distiller\'s Choice",'
		                   + '"Premise__c":"On Premise",'
		                   + '"AccountId":"' + c.AccountId + '",'
		                   + '"Retail_Account__c":null,'
		                   + '"Split_Order__c":false}]';


		LightningComponentUtility.RequestStatus response = SBP_AccountInfoCmpCtrl.updateCase(jsonCases,true);

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('cases'), 'Case should be updated');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}
    
    public static testMethod void updateCaseForAllocationAvailableOnState() {
		Case c = getCaseByBrand('Knob Creek');
        insertAllocHierarchy();
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        delete distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = true;
        stateAlloc.Allocations_Per_Interval__c = 10;
        stateAlloc.Used_Allocations__c = 0;
        update stateAlloc;
		Test.startTest();

		String jsonCases = '[{"Id":"' + c.Id + '",'
		                   + '"CcEmail__c":"",'
		                   + '"Remote_Selection_Date__c":null,'
		                   + '"Type":"Distiller\'s Choice",'
		                   + '"Premise__c":"On Premise",'
		                   + '"AccountId":"' + c.AccountId + '",'
		                   + '"Retail_Account__c":null,'
		                   + '"Split_Order__c":false}]';


		LightningComponentUtility.RequestStatus response = SBP_AccountInfoCmpCtrl.updateCase(jsonCases,true);

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('cases'), 'Case should be updated');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}
    
    public static testMethod void updateCaseForNationalAccount() {
		Case c = getCaseByBrand('Knob Creek');
        c.National_Account_Flag__c  = true;
        c.Retail_Account__c = getReatilerAccountAccount().Id;
        update c;
        insertAllocHierarchy();
		Test.startTest();

		String jsonCases = '[{"Id":"' + c.Id + '",'
		                   + '"CcEmail__c":"",'
		                   + '"Remote_Selection_Date__c":null,'
		                   + '"Type":"Distiller\'s Choice",'
		                   + '"Premise__c":"On Premise",'
            			   + '"National_Account_Flag__c":true,'
		                   + '"AccountId":"' + c.AccountId + '",'
		                   + '"Retail_Account__c":"'+c.Retail_Account__c+'",'
		                   + '"Split_Order__c":false}]';


		LightningComponentUtility.RequestStatus response = SBP_AccountInfoCmpCtrl.updateCase(jsonCases,true);

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('cases'), 'Case should be updated');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}
    
    public static testMethod void updateCaseForMilitary() {
		Case c = getCaseByBrand('Knob Creek');
        Account distributorAccount = getTestAccount();
        distributorAccount.Military__c = 'Military';
        update distributorAccount;
        insertAllocHierarchy();
		Test.startTest();

		String jsonCases = '[{"Id":"' + c.Id + '",'
		                   + '"CcEmail__c":"",'
		                   + '"Remote_Selection_Date__c":null,'
		                   + '"Type":"Distiller\'s Choice",'
		                   + '"Premise__c":"On Premise",'
		                   + '"AccountId":"' + c.AccountId + '",'
		                   + '"Retail_Account__c":null,'
		                   + '"Split_Order__c":false}]';


		LightningComponentUtility.RequestStatus response = SBP_AccountInfoCmpCtrl.updateCase(jsonCases,true);

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('cases'), 'Case should be updated');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}
    
		public static testMethod void updateCaseForAllocationAailableOnDist() {
		Case c = getCaseByBrand('Knob Creek');
            insertAllocHierarchy();
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Used_Allocations__c = 0;
        update distAlloc;
            
		Test.startTest();

		String jsonCases = '[{"Id":"' + c.Id + '",'
		                   + '"CcEmail__c":"",'
		                   + '"Remote_Selection_Date__c":null,'
		                   + '"Type":"Distiller\'s Choice",'
		                   + '"Premise__c":"On Premise",'
		                   + '"AccountId":"' + c.AccountId + '",'
		                   + '"Retail_Account__c":null,'
		                   + '"Split_Order__c":false}]';


		LightningComponentUtility.RequestStatus response = SBP_AccountInfoCmpCtrl.updateCase(jsonCases,true);

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('cases'), 'Case should be updated');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}
    
    public static testMethod void updateCaseForNoAllocationAvailableOnDistState() {
		Case c = getCaseByBrand('Knob Creek');
        insertAllocHierarchy();
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        update distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = true;
        stateAlloc.Allocations_Per_Interval__c = 10;
        stateAlloc.Used_Allocations__c = 10;
        update stateAlloc;
		Test.startTest();

		String jsonCases = '[{"Id":"' + c.Id + '",'
		                   + '"CcEmail__c":"",'
		                   + '"Remote_Selection_Date__c":null,'
		                   + '"Type":"Distiller\'s Choice",'
		                   + '"Premise__c":"On Premise",'
		                   + '"AccountId":"' + c.AccountId + '",'
		                   + '"Retail_Account__c":null,'
		                   + '"Split_Order__c":false}]';


		LightningComponentUtility.RequestStatus response = SBP_AccountInfoCmpCtrl.updateCase(jsonCases,true);

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('cases'), 'Case should be updated');
		System.assertEquals(false, response.success, 'Operation should return successfully');
	}
    public static testMethod void updateCaseForAllocationAvailableOnDistState() {
		Case c = getCaseByBrand('Knob Creek');
        insertAllocHierarchy();
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        update distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = true;
        stateAlloc.Allocations_Per_Interval__c = 10;
        stateAlloc.Used_Allocations__c = 0;
        update stateAlloc;
		Test.startTest();

		String jsonCases = '[{"Id":"' + c.Id + '",'
		                   + '"CcEmail__c":"",'
		                   + '"Remote_Selection_Date__c":null,'
		                   + '"Type":"Distiller\'s Choice",'
		                   + '"Premise__c":"On Premise",'
		                   + '"AccountId":"' + c.AccountId + '",'
		                   + '"Retail_Account__c":null,'
		                   + '"Split_Order__c":false}]';


		LightningComponentUtility.RequestStatus response = SBP_AccountInfoCmpCtrl.updateCase(jsonCases,true);

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('cases'), 'Case should be updated');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}
    
    public static testMethod void updateCaseForNoAllocationAvailableOnDistStateRegion() {
		Case c = getCaseByBrand('Knob Creek');
        insertAllocHierarchy();
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        update distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = false;
        update stateAlloc;
        Brand_Country_Region_Allocation__c regionAlloc = getRegionAlloc();
        regionAlloc.Is_Leaf_Node__c = true;
        regionAlloc.Allocations_Per_Interval__c = 10;
        regionAlloc.Used_Allocations__c = 10;
        update regionAlloc;
		Test.startTest();

		String jsonCases = '[{"Id":"' + c.Id + '",'
		                   + '"CcEmail__c":"",'
		                   + '"Remote_Selection_Date__c":null,'
		                   + '"Type":"Distiller\'s Choice",'
		                   + '"Premise__c":"On Premise",'
		                   + '"AccountId":"' + c.AccountId + '",'
		                   + '"Retail_Account__c":null,'
		                   + '"Split_Order__c":false}]';


		LightningComponentUtility.RequestStatus response = SBP_AccountInfoCmpCtrl.updateCase(jsonCases,true);

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('cases'), 'Case should be updated');
		System.assertEquals(false, response.success, 'Operation should return successfully');
	}
    
    public static testMethod void updateCaseForAllocationAvailableOnDistStateRegion() {
		Case c = getCaseByBrand('Knob Creek');
        insertAllocHierarchy();
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        update distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = false;
        update stateAlloc;
        Brand_Country_Region_Allocation__c regionAlloc = getRegionAlloc();
        regionAlloc.Is_Leaf_Node__c = true;
        regionAlloc.Allocations_Per_Interval__c = 10;
        regionAlloc.Used_Allocations__c = 0;
        update regionAlloc;
		Test.startTest();

		String jsonCases = '[{"Id":"' + c.Id + '",'
		                   + '"CcEmail__c":"",'
		                   + '"Remote_Selection_Date__c":null,'
		                   + '"Type":"Distiller\'s Choice",'
		                   + '"Premise__c":"On Premise",'
		                   + '"AccountId":"' + c.AccountId + '",'
		                   + '"Retail_Account__c":null,'
		                   + '"Split_Order__c":false}]';


		LightningComponentUtility.RequestStatus response = SBP_AccountInfoCmpCtrl.updateCase(jsonCases,true);

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('cases'), 'Case should be updated');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}
    
    public static testMethod void updateCaseForNoAllocationAvailableOnStateRegion() {
		Case c = getCaseByBrand('Knob Creek');
        insertAllocHierarchy();
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        delete distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = false;
        update stateAlloc;
        Brand_Country_Region_Allocation__c regionAlloc = getRegionAlloc();
        regionAlloc.Is_Leaf_Node__c = true;
        regionAlloc.Allocations_Per_Interval__c = 10;
        regionAlloc.Used_Allocations__c = 10;
        update regionAlloc;
		Test.startTest();

		String jsonCases = '[{"Id":"' + c.Id + '",'
		                   + '"CcEmail__c":"",'
		                   + '"Remote_Selection_Date__c":null,'
		                   + '"Type":"Distiller\'s Choice",'
		                   + '"Premise__c":"On Premise",'
		                   + '"AccountId":"' + c.AccountId + '",'
		                   + '"Retail_Account__c":null,'
		                   + '"Split_Order__c":false}]';


		LightningComponentUtility.RequestStatus response = SBP_AccountInfoCmpCtrl.updateCase(jsonCases,true);

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('cases'), 'Case should be updated');
		System.assertEquals(false, response.success, 'Operation should return successfully');
	}
    
    public static testMethod void updateCaseForAllocationAvailableOnStateRegion() {
		Case c = getCaseByBrand('Knob Creek');
        insertAllocHierarchy();
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        delete distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = false;
        update stateAlloc;
        Brand_Country_Region_Allocation__c regionAlloc = getRegionAlloc();
        regionAlloc.Is_Leaf_Node__c = true;
        regionAlloc.Allocations_Per_Interval__c = 10;
        regionAlloc.Used_Allocations__c = 0;
        update regionAlloc;
		Test.startTest();

		String jsonCases = '[{"Id":"' + c.Id + '",'
		                   + '"CcEmail__c":"",'
		                   + '"Remote_Selection_Date__c":null,'
		                   + '"Type":"Distiller\'s Choice",'
		                   + '"Premise__c":"On Premise",'
		                   + '"AccountId":"' + c.AccountId + '",'
		                   + '"Retail_Account__c":null,'
		                   + '"Split_Order__c":false}]';


		LightningComponentUtility.RequestStatus response = SBP_AccountInfoCmpCtrl.updateCase(jsonCases,true);

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('cases'), 'Case should be updated');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}
    
    @isTest
    public static void testGetDetailsOfCaseAccountLSC(){
        Case caseObj= [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
            LightningComponentUtility.RequestStatus response = SBP_AccountInfoCmpCtrl.getDetailsOfCaseAccountLSC(caseObj.Id);
        Test.stopTest();
        
        System.assertEquals(true, response.success, 'Operation should return successfully');
    }
}