@isTest
public class TST_SRV_CustomSettings {
    @isTest
    public static void testCreateInstanceTopic() {
        
        Test.startTest();
        	Topic_Added_For_User__c instance = SRV_CustomSettings.createInstanceTopic('Test', 5);
        Test.stopTest();
        
        System.assertEquals(instance.Topic_Name__c, 'Test', 'Instance Topic Name Should Be Test');
    }
}