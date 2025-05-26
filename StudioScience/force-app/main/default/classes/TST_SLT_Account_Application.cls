@isTest(seeAllData = false)
public class TST_SLT_Account_Application {
    @testSetup
    static void dataSetup() {
        Case recordCase = SBP_TestDataFactory.createCase(null, true);
        
        Account testAccount = new Account();
		testAccount.Name = 'Test Account';
		testAccount.BillingState = 'IL';
		testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().
                                       get('OffPremise').getRecordTypeId();
		insert testAccount;
        
        Account_Application__c makersApplication = new Account_Application__c();
		makersApplication.Brand__c = 'Makers Mark';
		makersApplication.Status__c = 'New';
		makersApplication.State__c = '';
		makersApplication.Account__c = testAccount.Id;
        makersApplication.Case__c = recordCase.Id;
		insert makersApplication;
    }
    
    @isTest
    public static void testGetAccountAppByAccountBrandStatus() {
        Account_Application__c accountApplication = [SELECT Id, Brand__c, Status__c 
                                                        FROM Account_Application__c];
        String brand = accountApplication.Brand__c;
        Id accountId = accountApplication.Id;
        String status = accountApplication.Status__c;
        Test.startTest();
        List<Account_Application__c> accountApplicationRecord = SLT_Account_Application.getAccountAppByAccountBrandStatus(
                                                                    accountId, brand, status);
        Test.stopTest();
        System.assertEquals(false, accountApplicationRecord == null, 'Account Application found');
    }
    
    @isTest
    public static void testGetAccountApplicationByCaseId() {
        Case recordCase = [SELECT Id
                              FROM Case];
        
        Test.startTest();
            Account_Application__c accountApplicationRecord = SLT_Account_Application.getAccountApplicationByCaseId(recordCase.Id);
        Test.stopTest();
        
        System.assertEquals(false, accountApplicationRecord == null, 'Account Application found');
    }
}