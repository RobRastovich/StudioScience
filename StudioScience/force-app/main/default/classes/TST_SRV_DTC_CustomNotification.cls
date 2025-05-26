@isTest
public class TST_SRV_DTC_CustomNotification {
    @testSetup
    static void dataSetup() {
        CustomNotificationType custom = TST_TestDataFactory.createCustomNotificationType(null, false);
        Case caseDetail = TST_TestDataFactory.createCase(null, true);
    }

    @isTest
    private static void testCustomNotification() {
        CustomNotificationType customNotification = [SELECT Id, DeveloperName 
                                                        FROM CustomNotificationType][0];
        Case caseDetail = [SELECT Id, OwnerID 
                           FROM Case][0];
      
        Test.startTest();
            SRV_DTC_CustomNotification.sendCustomNotificatioToOwner('title', 'body', customNotification.Id, caseDetail.Id, 
                new Set<String>{caseDetail.OwnerID});
        Test.stopTest();

        System.assertEquals(True, SRV_DTC_CustomNotification.isNotificationSent , 'Custom notification sending failed.');
    }
}