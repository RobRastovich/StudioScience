@isTest
public class TST_SLT_DTC_Group {
    @testSetup
    static void dataSetup() {
        Group grpdetail = TST_TestDataFactory.createGroup(true, DTC_Constants.QUEUE_DTC);
    }

    @isTest
    private static void testGetQueueByName() {

        Test.startTest();
            Group groupDetail = SLT_DTC_Group.getQueueByName(DTC_Constants.WHISKY_DROP);
        Test.stopTest();

        System.assertNotEquals(null, groupDetail , 'No Records returned when expected');
    }
}