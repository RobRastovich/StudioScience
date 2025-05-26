@isTest
private class LocalActionUtilityCtrlTest {
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

		Plant_Event__c event = new Plant_Event__c();
		event.Scheduled_Date__c = Date.today();
		event.Time_of_Day__c = 'AM';
		insert event;


		Case c = new Case();
		c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Standard').getRecordTypeId();
		c.Type = 'Trip and Tour';
		c.Plant_Event__c = event.Id;
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
	}

	public static Case getCaseById(Id caseId) {
		return [select id from Case where Id = :caseId limit 1];
	}

	public static Case getCaseByPlantEventId(Id eventId) {
		return [select id, isTripToday__c from Case where Plant_Event__c = :eventId limit 1];
	}

	public static Plant_Event__c getEventByDate(Date dateVal) {
		return [select id, isTripToday__c from Plant_Event__c where Scheduled_Date__c = :dateVal limit 1];
	}

	public static Barrel_Number__c getBarrelNumberByBrand(String brand) {
		return [select id, Brand__c, Next_Barrel_Number__c from Barrel_Number__c where Brand__c = :brand limit 1];
	}

	public static Case getCaseByBrand(String brand) {
		return [select id, Barrel_Selected__c, Status, Barrel_Order_Group__c, Flow_Completed__c from Case where Brand__c = :brand limit 1];
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

	public static testMethod void updateRelatedCaseWhenTripIsTodayTest() {
		Plant_Event__c event = getEventByDate(Date.today());
		Case c = getCaseByPlantEventId(event.Id);

		System.assertEquals(FALSE, c.isTripToday__c, 'Flag should be set to false');

		Test.startTest();

		event.isTripToday__c = true;
		update event;

		Case updatedCase = getCaseByPlantEventId(event.Id);

		Test.stopTest();

		System.assertEquals(TRUE, updatedCase.isTripToday__c, 'Plant event should update the related cases');
	}

	public static testMethod void getRecordTypeFullBarrelTest() {
		Test.startTest();

		LightningComponentUtility.RequestStatus response = LocalActionUtilityCtrl.getRecordType('Knob Creek', 'Barrel', 'Full');

		Test.stopTest();

		System.assertEquals(SBP_Constants.KNOB_CREEK_FULL_BARREL_RT_ID, response.responseMap.get('recordTypeId'), 'RecordTypeId should match');
	}

	public static testMethod void getRecordTypeSplitBarrelTest() {
		Test.startTest();

		LightningComponentUtility.RequestStatus response = LocalActionUtilityCtrl.getRecordType('Knob Creek', 'Barrel', 'Split');

		Test.stopTest();

		System.assertEquals(SBP_Constants.KNOB_CREEK_SPLIT_BARREL_RT_ID, response.responseMap.get('recordTypeId'), 'RecordTypeId should match');
	}

	public static testMethod void getRecordTypeSampleBarrelTest() {
		Test.startTest();

		LightningComponentUtility.RequestStatus response = LocalActionUtilityCtrl.getRecordType('Knob Creek', 'Barrel', 'Sample Kit');

		Test.stopTest();

		System.assertEquals(SBP_Constants.KNOB_CREEK_SAMPLE_KIT_RT_ID, response.responseMap.get('recordTypeId'), 'RecordTypeId should match');
	}


	public static testMethod void getRecordTypeCaseTest() {
		Test.startTest();

		LightningComponentUtility.RequestStatus response = LocalActionUtilityCtrl.getRecordType('Knob Creek', 'Case', 'Full');

		Test.stopTest();

		System.assertEquals(SBP_Constants.SINGLE_BARREL_STANDARD_RT_ID, response.responseMap.get('recordTypeId'), 'RecordTypeId should match');
	}

	public static testMethod void getRecordTypeCaseSplitBarrelTest() {
		Test.startTest();

		LightningComponentUtility.RequestStatus response = LocalActionUtilityCtrl.getRecordType('Knob Creek', 'Case', 'Split');

		Test.stopTest();

		System.assertEquals(SBP_Constants.SINGLE_BARREL_SPLIT_BARREL_RT_ID, response.responseMap.get('recordTypeId'), 'RecordTypeId should match');
	}

	public static testMethod void getRecordTypePlantEventTest() {
		Test.startTest();

		LightningComponentUtility.RequestStatus response = LocalActionUtilityCtrl.getRecordType('Knob Creek', 'Plant Event', 'Full');

		Test.stopTest();

		System.assertEquals(SBP_Constants.KNOB_CREEK_EVENT_RT_ID, response.responseMap.get('recordTypeId'), 'RecordTypeId should match');
	}

	public static testMethod void getRecordTypePOSFullTest() {
		Test.startTest();

		LightningComponentUtility.RequestStatus response = LocalActionUtilityCtrl.getRecordType('Knob Creek', 'POS Customization', 'Full');

		Test.stopTest();

		System.assertEquals(SBP_Constants.POS_FULL_BARREL_RT_ID, response.responseMap.get('recordTypeId'), 'RecordTypeId should match');
	}

	public static testMethod void getRecordTypePOSSplitTest() {
		Test.startTest();

		LightningComponentUtility.RequestStatus response = LocalActionUtilityCtrl.getRecordType('Knob Creek', 'POS Customization', 'Split');

		Test.stopTest();

		System.assertEquals(SBP_Constants.POS_SPLIT_BARREL_RT_ID, response.responseMap.get('recordTypeId'), 'RecordTypeId should match');
	}

	public static testMethod void createCaseAndBarrelGroupTest() {
		Test.startTest();

		LightningComponentUtility.RequestStatus response = LocalActionUtilityCtrl.createCaseAndBarrelGroup('Knob Creek', 'Bourbon', 'Trip and Tour');

		Test.stopTest();

		System.assertEquals(SBP_Constants.SINGLE_BARREL_STANDARD_RT_ID, response.responseMap.get('caseRecordTypeId'), 'RecordTypeId should match');
	}

	public static testMethod void updateCaseCompletedTest() {
		Test.startTest();
		Case c = getCaseByBrand('Knob Creek');
		System.assertEquals(FALSE, c.Flow_Completed__c, 'Flow Completed Should be false');

		LightningComponentUtility.RequestStatus response = LocalActionUtilityCtrl.updateCaseFlowCompleted(String.valueOf(c.Barrel_Order_Group__c));
		Case updatedCase = [select id, Flow_Completed__c from Case where Id = :c.Id];

		Test.stopTest();

		System.assertEquals(TRUE, updatedCase.Flow_Completed__c, 'Flow Completed Should be updated to true');
	}

	@isTest public static void assignAccountIdTest() {
		Test.startTest();
		Case c = getCaseByBrand('Knob Creek');

		Account testAccount2 = new Account();
		testAccount2.Name = 'Test Account2';
		testAccount2.BillingState = 'IL';
		testAccount2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();
		insert testAccount2;

		LightningComponentUtility.RequestStatus response = LocalActionUtilityCtrl.assignAccountId(String.valueOf(c.Id),String.valueOf(testAccount2.Id),'AccountId');
		Case updatedCase = [select id, AccountId from Case where Id = :c.Id];

		Test.stopTest();

		System.assertEquals(testAccount2.Id, updatedCase.AccountId, 'Account Ids should match');
	}

	@isTest public static void assignAccountIdMissingTest() {
		Test.startTest();
		Case c = getCaseByBrand('Knob Creek');

		LightningComponentUtility.RequestStatus response = LocalActionUtilityCtrl.assignAccountId(String.valueOf(c.Id),'','AccountId');

		Test.stopTest();

		System.assertEquals(false, response.success, 'Response should have failed');
	}
    
    @isTest public static void updateBonusCouponTest1(){
        Bonus_Coupon__c bc = new Bonus_Coupon__c();
        bc.Status__c = 'Redeemed';
        bc.gvc_Reported_Wholesaler__c = 'Test WholeSaler';
        bc.Amount__c = 1.00;
        insert bc;
        test.startTest();
        LightningComponentUtility.RequestStatus response = LocalActionUtilityCtrl.updateBonusCoupon(bc);
        test.stopTest();
        System.debug('Bonus Coupon Success:::'+response);  
        System.assertEquals(true, response.success, 'Response should be successfull');
    }
    @isTest public static void updateBonusCouponTest2(){
        Bonus_Coupon__c bc = null;
        test.startTest();
        LightningComponentUtility.RequestStatus response = LocalActionUtilityCtrl.updateBonusCoupon(bc);
        test.stopTest();
        System.debug('Bonus Coupon Failure:::'+response);  
        System.assertEquals(false, response.success, 'Response should be un-successfull');
    }
}