@isTest(seeAllData = false)
public class TST_TimeRemainingCmpApexController {
    @TestSetup
    static void makeData(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = p.Id,
                          TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser@test-user-system.com.test-only');
        INSERT u;
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.BillingState = 'IL';
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();
		insert testAccount;
        
        List<Case> casesToInsert = new List<Case>();
        Case testCase = new Case();
        testCase.Status = 'Preparing Barrel';
        testCase.Brand__c = SBP_Constants.LAPHROAIG_SINGLE_CASK;
        testCase.AccountId = testAccount.Id;
        casesToInsert.add(testCase);
        
        if(!casesToInsert.isEmpty()){
            insert casesToInsert;
        }
        
        Account_Application__c laphroaigApplication = new Account_Application__c();
		laphroaigApplication.Brand__c = 'Laphroaig Single Cask';
        laphroaigApplication.Case__c = testCase.Id;
        laphroaigApplication.Submitter__c = u.Id;
        insert laphroaigApplication;
    }
    @isTest
    public static void testGetPOSRecordBrand() {
		Case testCase = [SELECT Id 
                         	FROM Case 
                         	WHERE Brand__c =: SBP_Constants.LAPHROAIG_SINGLE_CASK 
                         	LIMIT 1];
        Test.startTest();
        	String testBrandValue = TimeRemainingCmpApexController.getPOSRecordBrand(Id.valueOf(testCase.Id));
        Test.stopTest();
        System.assertEquals(SBP_Constants.LAPHROAIG_SINGLE_CASK, testBrandValue, 'Correct Brand is Fetched');
        
    }
    @isTest
    public static void testSendEmail(){
        Case recordCase = [SELECT Id, Status
                         	FROM Case 
                         	WHERE Brand__c =: SBP_Constants.LAPHROAIG_SINGLE_CASK 
                         	LIMIT 1];
        Test.startTest();
        	TimeRemainingCmpApexController.sendEmail(recordCase.Id);
        Test.stopTest();
        Case responseCase = [SELECT Id, Status
                         	FROM Case 
                         	WHERE Brand__c =: SBP_Constants.LAPHROAIG_SINGLE_CASK 
                         	LIMIT 1];
        System.assertEquals('Preparing Barrel', responseCase.Status, 'Method call successful!');
    }
}