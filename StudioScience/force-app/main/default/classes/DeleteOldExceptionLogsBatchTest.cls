@isTest
public class DeleteOldExceptionLogsBatchTest {
    @isTest
    static void testBatch_DeletesOldLogs() {
        List<Custom_Exception_Logs__c> logs = new List<Custom_Exception_Logs__c>();
        for (Integer i = 0; i < 5; i++) {
            Custom_Exception_Logs__c log = new Custom_Exception_Logs__c();
            log.CreatedDate = System.today().addMonths(-3);
            logs.add(log);
        }
        insert logs;
        String CRON_EXP = '0 0 * * * ?';
        
        Test.startTest();
        
        String jobId = System.schedule('Hello', CRON_EXP, new DeleteOldExceptionLogsBatch());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
    }
}