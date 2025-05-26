@isTest
public with sharing class PurchaseHistoryTrigger_Test {
    @isTest
    static void TestInsertPurchaseHistory() {
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'paccount';
        insert acc;
        Purchase_History__c phObj = new Purchase_History__c(Brand__c = 'Bowmore',
                                                            Product_Cost__c=10000,
                                                            Date_of_Purchase__c = system.today(),
                                                            Account__c = acc.Id
                                                           );
        Test.startTest();
        insert phObj;
        Test.stopTest();
        System.assert(phObj != null);
    }
}