@isTest
public class ShipmentTrackingBatchSchedulerTest {
    @isTest 
    static void testExecute() {  
        Test.startTest();
        ShipmentTrackingBatchScheduler sh1 = new ShipmentTrackingBatchScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1);
        Test.stopTest();
    }
}