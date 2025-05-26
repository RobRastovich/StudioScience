@isTest
private class BarrelServicesTest {
    @testSetup static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
                              EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                              LocaleSidKey = 'en_US', ProfileId = p.Id,
                              TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser@test-user-system.com.test-only');
            insert u;
        }
        
        List<Barrel_Number__c> lstBarrelNumber= new List<Barrel_Number__c>();
        Barrel_Number__c knobCreekBarrelNumber = new Barrel_Number__c();
        knobCreekBarrelNumber.Brand__c = 'Knob Creek';
        knobCreekBarrelNumber.Product_Type__c = 'Bourbon';
        knobCreekBarrelNumber.Next_Barrel_Number__c = '1';
        lstBarrelNumber.add(knobCreekBarrelNumber);
        
        Barrel_Number__c baker = new Barrel_Number__c();
        baker.Brand__c = 'Baker\'s';
        baker.Next_Barrel_Number__c = '1';
        lstBarrelNumber.add(baker);
        
        Barrel_Number__c ETLC = new Barrel_Number__c();
        ETLC.Brand__c = 'El Tesoro Laphroaig Cask';
        ETLC.Next_Barrel_Number__c = '1';
        lstBarrelNumber.add(ETLC);
        
        Barrel_Number__c laphroaigBarrelNumber = new Barrel_Number__c();
        laphroaigBarrelNumber.Brand__c = 'Laphroaig Single Cask';
        laphroaigBarrelNumber.Next_Barrel_Number__c = '1';
        lstBarrelNumber.add(laphroaigBarrelNumber);
        
        insert lstBarrelNumber;
        
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
        c.Submitter__c = UserInfo.getUserId();
        c.AccountId = testAccount.Id;
        
        Case c2 = new Case();
        c2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Proof_Specific').getRecordTypeId();
        c2.Type = 'Trip and Tour';
        c2.Barrel_Order_Group__c = bg2.Id;
        c2.Brand__c = 'Makers Mark';
        c2.Regional_Diplomat__c = UserInfo.getUserId();
        c2.AccountId = testAccount.Id;
        
        Case c3 = new Case();
        c3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Standard').getRecordTypeId();
        c3.Type = 'Sample Kit';
        c3.Barrel_Order_Group__c = bg.Id;
        c3.Brand__c = 'Baker\'s';
        c3.ccEmail__c = 'test@test.com';
        c3.Submitter__c = UserInfo.getUserId();
        c3.AccountId = testAccount.Id;
        
        Case c4 = new Case();
        c4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Proof_Specific').getRecordTypeId();
        c4.Type = 'Sample Kit';
        c4.Barrel_Order_Group__c = bg.Id;
        c4.Brand__c = 'El Tesoro Laphroaig Cask';
        c4.ccEmail__c = 'test@test.com';
        c4.Submitter__c = UserInfo.getUserId();
        c4.AccountId = testAccount.Id;

        Case laphroaigCase = SBP_TestDataFactory.createCase(null, false);
        
        insert new List<Case> {c, c2, c3, c4, laphroaigCase};
            
            
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
        
        Barrel__c bakers = new Barrel__c();
        bakers.Brand__c = 'Baker\'s';
        bakers.Case__c = c.Id;
        bakers.SKU__c = 'Test Barrel';
        bakers.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Baker_s_Sample_Kit').getRecordTypeId();
        
        Barrel__c etlcBarrelNumber = new Barrel__c();
        etlcBarrelNumber.Brand__c = 'El Tesoro Laphroaig Cask';
        etlcBarrelNumber.Case__c = c4.Id;
        etlcBarrelNumber.SKU__c = 'Test Barrel';
        etlcBarrelNumber.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('El_Tesoro_Laphroaig_Cask_Sample_Kit').getRecordTypeId();
        
        Barrel__c laphroaigBarrel = SBP_TestDataFactory.createBarrel(null, laphroaigCase, false);
        insert new List<Barrel__c> {knobCreek, makersMark, bakers, etlcBarrelNumber, laphroaigBarrel};
            
            }
    
    public static Case getCaseById(Id caseId) {
        return [select id from Case where Id = :caseId limit 1];
    }
    
    public static Barrel_Number__c getBarrelNumberByBrand(String brand) {
        return [select id, Brand__c, Next_Barrel_Number__c from Barrel_Number__c where Brand__c = :brand limit 1];
    }
    
    public static Case getCaseByBrand(String brand) {
        return [select id, Barrel_Selected__c, Status from Case where Brand__c = :brand limit 1];
    }
    
    public static Barrel__c getBarrelBySku(String sku) {
        return [select id, Selection_Date__c, Barrel_Number__c, SKU_Entered_Date__c from Barrel__c where SKU__c = :sku limit 1];
    }
    
    public static List<Case> getCurrentNumberOfCases() {
        return [select Id from Case];
    }
    
    public static Account getTestAccount() {
        return [select id from Account where Name = 'Test Account'];
    }
    
    
    public static testMethod void checkIfBarrelWasSelectedTest() {
        Case c = getCaseByBrand('Knob Creek');
        Barrel__c barrel = getBarrelBySku('Test Barrel');
        
        System.assertEquals(FALSE, c.Barrel_Selected__c, 'Barrel should not be selected yet');
        
        Test.startTest();
        
        barrel.Selection_Date__c = Date.today();
        update barrel;
        
        Case updatedCase = getCaseByBrand('Knob Creek');
        
        Test.stopTest();
        
        System.assertEquals(TRUE, updatedCase.Barrel_Selected__c, 'Barrel should now be selected ');
    }
    
    public static testMethod void checkIfFinalDetailsWereEnteredKnobCreekTest() {
        Case c = getCaseByBrand('Knob Creek');
        Barrel__c barrel = getBarrelBySku('Test Barrel');
        
        System.assertNotEquals(SBP_Constants.PENDING_FINAL_DETAILS, c.Status, 'Case Status show not be pending final details ');
        
        Test.startTest();
        
        barrel.Quantity__c = 10;
        barrel.SKU__c = 'US123';
        barrel.Ship_Date__c = Date.today();
        update barrel;
        
        Case updatedCase = getCaseByBrand('Knob Creek');
        
        Test.stopTest();
        
        System.assertEquals(SBP_Constants.PENDING_FINAL_DETAILS, updatedCase.Status, 'case status should be final details');
    }
    
    public static testMethod void checkIfFinalDetailsWereEnteredMakersMarkTest() {
        Case c = getCaseByBrand('Makers Mark');
        Barrel__c barrel = getBarrelBySku('Test Barrel 2');
        
        System.assertNotEquals(SBP_Constants.PENDING_PURCHASE_ORDER, c.Status, 'Case Status show not be pending purchase order ');
        
        Test.startTest();
        
        barrel.Quantity__c = 10;
        barrel.SKU__c = 'US123';
        barrel.Ship_Date__c = Date.today();
        update barrel;
        
        Case updatedCase = getCaseByBrand('Makers Mark');
        Barrel__c updatedBarrel = getBarrelBySku('US123');
        
        System.assertEquals(SBP_Constants.PENDING_PURCHASE_ORDER, updatedCase.Status, 'case status should be pending purchase order');
        //System.assertEquals(Datetime.now(), updatedBarrel.SKU_Entered_Date__c);
        Test.stopTest();
        
    }
    
    public static testMethod void checkIfNextBarrelNumberWasAssignedTest() {
        Barrel_Number__c barrelNumber = getBarrelNumberByBrand('Knob Creek');
        
        Test.startTest();
        
        Barrel__c knobCreek = new Barrel__c();
        knobCreek.Barrel_Number__c = '';
        knobCreek.Brand__c = 'Knob Creek';
        knobCreek.SKU__c = 'Test Barrel 3';
        knobCreek.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Knob_Creek_Full_Barrel').getRecordTypeId();
        knobCreek.Product_Type__c = 'Bourbon';
        insert knobCreek;
        
        Barrel__c barrel = getBarrelBySku('Test Barrel 3');
        
        Test.stopTest();
        
        System.assertEquals(barrelNumber.Next_Barrel_Number__c, barrel.Barrel_Number__c, 'barrel number should equal the next barrel number' + barrel);
    }
    
    public static testMethod void sendFinalDetailsEmailTest() {
        
        Test.startTest();
        
        Barrel__c barrel = getBarrelBySku('Test Barrel');
        barrel.Barrel_Approved__c = true;
        update barrel;
        
        
        Test.stopTest();
        
    }
    
    public static testMethod void sendEmailBasedOnQuantityAndProofTest() {
        
        Test.startTest();
        
        Barrel__c barrel = getBarrelBySku('Test Barrel 2');
        barrel.Quantity__c = 10;
        barrel.Proof__c = 12;
        update barrel;
        
        Test.stopTest();
        
    }

    @isTest
    public static void testUpdateCaseStatusAndSubStatus() {
		Barrel__c newBarrel = [SELECT Id, Brand__c, Case__c, Bottling_Date__c, SKU__c, Quantity__c, Proof__c, Barrel_Proof__c
                                    FROM Barrel__c 
                                    WHERE Brand__c = : SBP_Constants.LAPHROAIG_SINGLE_CASK 
                                    LIMIT 1];
        Barrel__c oldApp = newBarrel.clone(true, false, false, false);
		Map<Id, Barrel__c> oldMap = new Map<Id, Barrel__c>();
        oldApp.Bottling_Date__c = null;
        oldMap.put(oldApp.Id, oldApp);
        newBarrel.SKU__c = null;
        List<Barrel__c> newList = new List<Barrel__c>{newBarrel};
                         
        Test.StartTest();
        	BarrelServices.updateCaseStatusAndSubStatus(newList, oldMap);
        Test.StopTest();

		Case createdCase = new Case();
		createdCase = [SELECT Id, Status, Sub_Status__c 
							FROM Case 
							WHERE Brand__c = : SBP_Constants.LAPHROAIG_SINGLE_CASK 
							LIMIT 1];

        System.assertEquals(SBP_Constants.PREPARING_BARREL, createdCase.Status, 'Case status not updated when expected to be.');
        System.assertEquals(SBP_Constants.PREPARING_STO, createdCase.Sub_Status__c, 'Case Sub status not updated when expected to be.');
    }
    
    @isTest
    public static void testUpdateCaseStatusAndSubStatusAwaitingDistributorPO() {
		Barrel__c newBarrel = [SELECT Id, Brand__c, Case__c, Bottling_Date__c, SKU__c, Quantity__c, Proof__c, Barrel_Proof__c
                                    FROM Barrel__c 
                                    WHERE Brand__c = : SBP_Constants.LAPHROAIG_SINGLE_CASK 
                                    LIMIT 1];
        Barrel__c oldApp = newBarrel.clone(true, false, false, false);
		Map<Id, Barrel__c> oldMap = new Map<Id, Barrel__c>();
        oldApp.SKU__c = null;
        oldApp.Proof__c = null;
        oldApp.Quantity__c = null;
        oldApp.Barrel_Proof__c = null;
        oldMap.put(oldApp.Id, oldApp);
        List<Barrel__c> newList = new List<Barrel__c>{newBarrel};
                         
        Test.StartTest();
        	BarrelServices.updateCaseStatusAndSubStatus(newList, oldMap);
        Test.StopTest();

		Case createdCase = new Case();
		createdCase = [SELECT Id, Status, Sub_Status__c 
							FROM Case 
							WHERE Brand__c = : SBP_Constants.LAPHROAIG_SINGLE_CASK 
							LIMIT 1];

        System.assertEquals(SBP_Constants.AWAITING_DISTRIBUTOR_PO, createdCase.Sub_Status__c, 'Case Sub status not updated when expected to be.');
    }
    public static testMethod void sendEmailForLessQuantityOnKCBarrelsTest() {
        
        Test.startTest();
        
        Barrel__c barrel = getBarrelBySku('Test Barrel');
        barrel.Quantity__c = 17;
 
        update barrel;
        
        Test.stopTest();
        
    }
}