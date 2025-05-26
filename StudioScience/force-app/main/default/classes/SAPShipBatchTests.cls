@isTest
public class SAPShipBatchTests {
    @testSetup
    static void setup() {
        Case testCase = new Case(SAP_Number__c = 'Test123');
        insert testCase;
        
        List<Barrel__c> ListOfBarrel = new List<Barrel__c>();        
        for(Integer i=0; i<=10; i++) {
            ListOfBarrel.add(new Barrel__c(Ship_Date__c = Date.today(), Case__c = testCase.Id));  
        }
        if(ListOfBarrel != null)
            insert ListOfBarrel;
    }
    
    @isTest static void test_SAPShipBatch() {
        
        Test.startTest();
            SAPShipBatch batchObject = new SAPShipBatch();
            Id batchId = Database.executeBatch(batchObject);
        Test.stopTest();
        
        System.assertNotEquals(null, batchId, 'Returned batch id is not null');
    }
}