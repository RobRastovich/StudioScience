@isTest
private class SBP_SampleSelectionCmpCtrlTest {
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

		//LSB-143
		List<Barrel_Order_Group__c> barrelOrderGroupList = new List<Barrel_Order_Group__c>();
		Barrel_Order_Group__c bg = new Barrel_Order_Group__c();
		bg.Type__c = 'Trip and Tour';
		barrelOrderGroupList.add(bg);
        
        //LSB-143
        Barrel_Order_Group__c bg1 = new Barrel_Order_Group__c();
		bg1.Type__c = 'Sample Kit';
		barrelOrderGroupList.add(bg1);
		INSERT barrelOrderGroupList;
        
		//LSB-143
		List<Case> casesList = new List<Case>();
		Case c = new Case();
		c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Standard').getRecordTypeId();
		c.Type = 'Trip and Tour';
		c.Barrel_Order_Group__c = barrelOrderGroupList[0].Id;
		c.Brand__c = 'Knob Creek';
		c.Product_Type__c = 'Bourbon';
		c.ccEmail__c = 'test@test.com';
		c.AccountId = testAccount.Id;
		casesList.add(c);
        
        //LSB-143
        Case case1 = new Case();
        case1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Laphroaig_Single_Cask').getRecordTypeId();
        case1.Type = 'Sample Kit';
		case1.Barrel_Order_Group__c = barrelOrderGroupList[1].Id;
		case1.Brand__c = 'Laphroaig Single Cask';
		case1.ccEmail__c = 'test@test.com';
		case1.AccountId = testAccount.Id;
		casesList.add(case1);
		INSERT casesList;
        
        List<Barrel__c> barrelList = new List<Barrel__c>();
		Barrel__c knobCreek = new Barrel__c();
		knobCreek.Brand__c = 'Knob Creek';
		knobCreek.Case__c = casesList[0].Id;
		knobCreek.SKU__c = 'Test Barrel';
		knobCreek.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Knob_Creek_Full_Barrel').getRecordTypeId();
		knobCreek.Product_Type__c = 'Bourbon';
        barrelList.add(knobCreek);
        
        //LSB-143
        Barrel__c laphroaig = new Barrel__c();
		laphroaig.Brand__c = 'Laphroaig Single Cask';
		laphroaig.Case__c = casesList[1].Id;
		laphroaig.SKU__c = 'Test Barrel';
		laphroaig.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Laphroaig_Single_Cask_Full_Barrel').getRecordTypeId();
        barrelList.add(laphroaig);
        
        //LSB-143
        Barrel__c sampleBarrelLSC = new Barrel__c();
		sampleBarrelLSC.Brand__c = 'Laphroaig Single Cask';
		sampleBarrelLSC.SKU__c = 'Test Barrel';
		sampleBarrelLSC.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Laphroaig_Single_Cask_Sample_Kit').getRecordTypeId();
        barrelList.add(sampleBarrelLSC);
        
        //LSB-143
        Barrel__c sampleBarrelLSC1 = new Barrel__c();
		sampleBarrelLSC1.Brand__c = 'Laphroaig Single Cask';
		sampleBarrelLSC1.SKU__c = 'Test Barrel';
		sampleBarrelLSC1.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Laphroaig_Single_Cask_Sample_Kit').getRecordTypeId();
        barrelList.add(sampleBarrelLSC1);
        
		Barrel__c sampleBarrel1 = new Barrel__c();
		sampleBarrel1.Brand__c = 'Knob Creek';
		sampleBarrel1.SKU__c = 'Sample Barrel 1';
		sampleBarrel1.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Knob_Creek_Sample_Kit').getRecordTypeId();
		sampleBarrel1.Product_Type__c = 'Bourbon';
        barrelList.add(sampleBarrel1);
        
		Barrel__c sampleBarrel2 = new Barrel__c();
		sampleBarrel2.Brand__c = 'Knob Creek';
		sampleBarrel2.SKU__c = 'Sample Barrel 2';
		sampleBarrel2.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Knob_Creek_Sample_Kit').getRecordTypeId();
		sampleBarrel2.Product_Type__c = 'Bourbon';
        barrelList.add(sampleBarrel2);
        
		Barrel__c sampleBarrel3 = new Barrel__c();
		sampleBarrel3.Brand__c = 'Knob Creek';
		sampleBarrel3.SKU__c = 'Sample Barrel 3';
		sampleBarrel3.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Knob_Creek_Sample_Kit').getRecordTypeId();
		sampleBarrel3.Product_Type__c = 'Bourbon';
        barrelList.add(sampleBarrel3);
        
        if(!barrelList.isEmpty()){
            insert barrelList;
        }

		//LSB-143
		List<Sample_Kit__c> sampleKitList = new List<Sample_Kit__c>(); 
		// create sample kit 
		Sample_Kit__c sKit = new Sample_Kit__c();
		sKit.Barrel_Order_Group__c = barrelOrderGroupList[0].Id;
		sampleKitList.add(sKit);

		//LSB-143        
        Sample_Kit__c sKit1 = new Sample_Kit__c();
		sKit1.Barrel_Order_Group__c = barrelOrderGroupList[1].Id;
		sampleKitList.add(sKit1);
		INSERT sampleKitList;

        List<Sample__c> sampleList = new List<Sample__c>();
		Sample__c sample1 = new Sample__c();
		sample1.Label__c = 'A';
		sample1.Barrel__c = sampleBarrel1.Id;
		sample1.Sample_Kit__c = sampleKitList[0].Id;
        sampleList.add(sample1);
        
		Sample__c sample2 = new Sample__c();
		sample2.Label__c = 'B';
		sample2.Barrel__c = sampleBarrel2.Id;
		sample2.Sample_Kit__c = sampleKitList[0].Id;
        sampleList.add(sample2);
        
		Sample__c sample3 = new Sample__c();
		sample3.Label__c = 'C';
		sample3.Barrel__c = sampleBarrel3.Id;
		sample3.Sample_Kit__c = sampleKitList[0].Id;
        sampleList.add(sample3);
        
        //LSB-143
        Sample__c sample4 = new Sample__c();
		sample4.Label__c = 'D';
		sample4.Barrel__c = laphroaig.Id;
		sample4.Sample_Kit__c = sampleKitList[1].Id;
        sampleList.add(sample4);
        
        //LSB-143
        Sample__c sample5 = new Sample__c();
		sample5.Label__c = 'C';
		sample5.Barrel__c = sampleBarrelLSC.Id;
		sample5.Sample_Kit__c = sampleKitList[1].Id;
        sampleList.add(sample5);

        //LSB-143
        Sample__c sample6 = new Sample__c();
		sample6.Label__c = 'D';
		sample6.Barrel__c = sampleBarrelLSC1.Id;
		sample6.Sample_Kit__c = sampleKitList[1].Id;
        sampleList.add(sample6);

        if(!sampleList.isEmpty()){
            insert sampleList;
        }
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
		return [select Id, Barrel__c, Label__c from Sample__c where Label__c = :label limit 1];
	}

	public static Account getTestAccount() {
		return [select id from Account where Name = 'Test Account'];
	}


	public static testMethod void getSamplesTest() {
		Case c = getCaseByBrand('Knob Creek');
        Case case1 = getCaseByBrand('Laphroaig Single Cask');
		List<Sample__c> samples = getSamplesByBarrelGroupId(c.Barrel_Order_Group__c);
        List<Sample__c> samples1 = getSamplesByBarrelGroupId(case1.Barrel_Order_Group__c);

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_SampleSelectionCmpCtrl.getSamples(String.valueOf(c.Id));
		LightningComponentUtility.RequestStatus response1 = SBP_SampleSelectionCmpCtrl.getSamples(String.valueOf(case1.Id));
        
		Test.stopTest();

		System.assertEquals(3, response.responseMap.get('numberOfSamples'), 'There should be 3 samples created');
		System.assertEquals(true, response.success, 'Operation should return successfully');
        System.assertEquals(true, response1.success, 'Operation should return successfully');
	}

	public static testMethod void getSamplesErrorTest() {
		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_SampleSelectionCmpCtrl.getSamples('');

		Test.stopTest();

		System.assertEquals(false, response.success, 'Operation should not return successfully');
	}

	public static testMethod void updateBarrelWithSelectedSampleTest() {
		Case c = getCaseByBrand('Knob Creek');
		Sample__c sample = getSampleByLabel('A');

		Barrel__c barrelRelatedToCase = [select id from Barrel__c where Case__c = :c.Id];

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_SampleSelectionCmpCtrl.updateBarrelWithSelectedSample(String.valueOf(c.Id), String.valueOf(sample.Id));

		List<Barrel__c> newBarrelRelatedToCase = [select id from Barrel__c where Case__c = :c.Id];

		Test.stopTest();

		System.assertEquals(1, newBarrelRelatedToCase.size(), 'There should be one barrel related to the Case');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}

	public static testMethod void updateBarrelWithSelectedSampleErrorTest() {
		Test.startTest();
		LightningComponentUtility.RequestStatus response = SBP_SampleSelectionCmpCtrl.updateBarrelWithSelectedSample('', '');
		Test.stopTest();
		System.assertEquals(false, response.success, 'Operation should not return successfully');
	}

	public static testMethod void createNewCaseTest() {
		Case c = getCaseByBrand('Knob Creek');
		Sample__c sample = getSampleByLabel('B');
		List<Case> cases = getCurrentNumberOfCases();
		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_SampleSelectionCmpCtrl.createNewCase(String.valueOf(c.Id), String.valueOf(sample.Id));

		List<Case> updatedCase = getCurrentNumberOfCases();

		Test.stopTest();

		System.assertEquals(cases.size(), updatedCase.size(), 'Only One case should have been created');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}

	public static testMethod void createNewCaseErrorTest() {
		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_SampleSelectionCmpCtrl.createNewCase('', '');

		Test.stopTest();

		System.assertEquals(false, response.success, 'Operation should not return successfully');
	}

	public static testMethod void updateBarrelWithSelectedSampleAndTransferPOSTest() {
		Case c = getCaseByBrand('Knob Creek');
		Sample__c sample = getSampleByLabel('B');

		Barrel__c barrelRelatedToCase = [select id from Barrel__c where Case__c = :c.Id];

		Test.startTest();

		List<POS_Customization__c> posItems = new List<POS_Customization__c>();
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Barrel Plaque', Barrel__c = barrelRelatedToCase.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Floor Display', Barrel__c = barrelRelatedToCase.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));
		posItems.add(new POS_Customization__c(Get_Insert_Text_From__c = 'Account Name', Type__c = 'Barrel', Barrel__c = barrelRelatedToCase.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));
		insert posItems;

		LightningComponentUtility.RequestStatus response = SBP_SampleSelectionCmpCtrl.updateBarrelWithSelectedSample(String.valueOf(c.Id), String.valueOf(sample.Id));

		Barrel__c newBarrelRelatedToCase = [select id from Barrel__c where Case__c = :c.Id Limit 1];

		List<POS_Customization__c> updatedPOSItems = [select id, Barrel__c from POS_Customization__c where Barrel__r.Case__c = :c.Id];
		Test.stopTest();

		System.assertEquals(true, response.success, 'Operation should return successfully');
	}
    
    public static testMethod void getRelatedSampleKitTest(){
        Case c = getCaseByBrand('Knob Creek');
        Test.startTest();
        LightningComponentUtility.RequestStatus response = SBP_SampleSelectionCmpCtrl.getRelatedSampleKit(String.valueOf(c.Id));
        Test.stopTest();
        System.assertEquals(true, response.success, 'Operation should return successfully');
	}
	
    /**
    *  @description : This method is use to check restriction for unchecking a selected sample.
    **/
    @isTest static void testIsSampleAlreadySelected() {
        Test.startTest();
        Case c = getCaseByBrand('Knob Creek');
        Sample__c sample = getSampleByLabel('B');
        Sample__c sampleToUpdate = new Sample__c(Id = sample.Id);
        sampleToUpdate.Sample_Selected__c = true;
        update sampleToUpdate;
        sampleToUpdate.Sample_Selected__c = false;
        Database.SaveResult result = Database.update(sampleToUpdate, false);
        Test.stopTest();
        System.assertEquals(Label.Sample_Uncheck_Restriction, result.errors[0].message);
    }
    
    /**
    *  @description : This method is use to check restriction for selecting a sample for already selected sample kit.
    **/
    @isTest static void testIsSampleKitSelectedForSample() {
        Test.startTest();
        Case c = getCaseByBrand('Knob Creek');
        Sample__c sample = getSampleByLabel('B');
        Sample__c sampleToUpdate = new Sample__c(Id = sample.Id);
        sampleToUpdate.Sample_Selected__c = true;
        update sampleToUpdate;
        Sample__c anotherSampleToUpdate = getSampleByLabel('A');
        anotherSampleToUpdate.Sample_Selected__c = true;
        Database.SaveResult result = Database.update(anotherSampleToUpdate, false);
        Test.stopTest();
        System.assertEquals(Label.Sample_Kit_Already_Selected, result.errors[0].message);
    }
    
    //LSB-143
    @isTest static void testIsSampleKitSelectedForSample1() {
        Case case1 = getCaseByBrand('Laphroaig Single Cask');
        List<Sample__c> sampleList = [SELECT Id, Barrel__c, Label__c 
		                        FROM Sample__c 
                                WHERE Barrel__r.Brand__c = 'Laphroaig Single Cask' 
							    AND ( Label__c = 'D' OR Label__c = 'C')];
        sampleList[0].Sample_Selected__c = true;

        Test.startTest();
            update sampleList[0];
            sampleList[1].Sample_Selected__c = true;
            Database.SaveResult resultLSC = Database.update(sampleList[1], false);
        Test.stopTest();
        System.assertEquals(Label.Sample_Kit_Already_Selected, resultLSC.errors[0].message, 'sample kit is not selected');
    }
}