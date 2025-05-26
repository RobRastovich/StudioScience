@isTest
public class BEST_AccountLookupTest {
    
    public static testMethod void searchAccountTest() {
        
        Account objVendorAccount = new Account();
        objVendorAccount.Name = 'Test Vendor Account';
        objVendorAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Vendor').getRecordTypeId();
        objVendorAccount.billingstreet = 'test';
        objVendorAccount.billingcity = 'test';
        objVendorAccount.billingstate = 'test';
        objVendorAccount.billingPostalCode = 'test';
        objVendorAccount.BillingCountry = 'test';
        objVendorAccount.Account_Manager_Email__c = 'test123@test.com';
        insert objVendorAccount;
        Test.startTest();
        
        List <BEST_AccountLookup.RecordsData> res = BEST_AccountLookup.fetchRecords('Account', 'Name','Test Vendor Account','');
        
        Test.stopTest();
        
        System.assert(res != null);
    }
    
}