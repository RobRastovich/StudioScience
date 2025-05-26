@isTest
public class TST_SLT_DTC_CustomNotification {

    @testSetup
    static void dataSetup() {
        CustomNotificationType custom = TST_TestDataFactory.createCustomNotificationType(null, false);
    }

    @isTest
    private static void testGetCustomNotification() {
        CustomNotificationType custom = [SELECT Id, DeveloperName FROM CustomNotificationType][0];

        Test.startTest();
            CustomNotificationType created = SLT_DTC_CustomNotification.getCustomNotification(custom.DeveloperName);
        Test.stopTest();

        System.assertNotEquals(null, created.Id , 'No Records created when expected');
    }
}