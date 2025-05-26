@isTest
private class TST_TI_UPS_API_BatchScheduler{
    @testSetup
    static void setup() {
        Case testCase = new Case();
        testCase.Status = 'Open';
        insert testCase;
        
        Barrel__c testBarrel = new Barrel__c();
        testBarrel.Tracking_Number__c = '1234';
        testBarrel.CarrierNew__c = 'TForce';
        testBarrel.UPS_Delivery_Status__c = 'In Transit';
        insert testBarrel;
    }
    
    public static testMethod void tiUpsApiBatchSchedulerTest() {
        TI_UPS_API_BatchScheduler sch1 = new TI_UPS_API_BatchScheduler();
        String sch = '0 0 11 * * ?';
        
        Test.startTest();
            Id jobId = System.schedule('tiUpsApiBatchScheduler', sch, sch1);
        Test.stopTest();
        
        CronTrigger ct = [SELECT Id, CronExpression FROM CronTrigger WHERE Id =: jobId];
        System.assertEquals(true, jobId != null, 'Job Id should be populated');
        System.assertEquals(sch, ct.CronExpression, 'Cron Expression should be same');
    }
}