@isTest
public class TST_TI_UPS_API_Batch {
    @testSetup
    static void setup() {
        List<Barrel__c> ListOfBarrel = new List<Barrel__c>();        
        for(Integer i=0;i<=10;i++){
          ListOfBarrel.add(new Barrel__c(Tracking_Number__c='1234567'+i, CarrierNew__c='TForce', UPS_Delivery_Status__c='New'));  
        }
        if(ListOfBarrel!=null)
        	insert ListOfBarrel;
    }
    
    @isTest static void test_TI_UPS_API_Batch(){
        Test.startTest();
            TI_UPS_API_Batch batchObject = new TI_UPS_API_Batch('Barrel__c','TForce');
            Id batchId = Database.executeBatch(batchObject);
		Test.stopTest();
        System.assertNotEquals(null, batchId, 'Returned batchid is not null');
    }
    
}