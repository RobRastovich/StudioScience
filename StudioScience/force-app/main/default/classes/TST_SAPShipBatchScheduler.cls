@isTest(SeeAllData = false)
public class TST_SAPShipBatchScheduler {
    @testSetup
    static void setup() {
        Case testCase = new Case();
        testCase.SAP_Number__c = '1234';
        testCase.Status = 'Open';
        insert testCase;
        
        Barrel__c testBarrel = new Barrel__c();
        testBarrel.Ship_Date__c = Date.today();
        testBarrel.Tracking_Number__c = '';
        insert testBarrel;
    }
    public static testMethod void SAPShipBatchSchedulerTest() {
        SAPShipBatchScheduler sch1 = new SAPShipBatchScheduler();
        String sch = '0 0 11 * * ?';
        Test.startTest();
            Id jobId = System.schedule('SAPShipBatchScheduler', sch, sch1);
        Test.stopTest();
        System.assertEquals(true, jobId != null, 'Job Id should be populated');
    }
}