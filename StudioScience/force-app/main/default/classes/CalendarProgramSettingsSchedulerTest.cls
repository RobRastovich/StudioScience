@isTest
private class CalendarProgramSettingsSchedulerTest {
    static testMethod void scheduleTest() {
        List<Tags__c> lstInsertTag= new List<Tags__c>();
        TestDataProgramCalendar testData= new TestDataProgramCalendar();
        testData.createCalendarSetting();
        lstInsertTag=testData.createTerritory();
        insert lstInsertTag;
        testData.createDistributorAccount(lstInsertTag[0].id);
        test.starttest();
        CalendarProgramSettingsScheduler  schtest = new CalendarProgramSettingsScheduler ();      
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        system.schedule('Test', CRON_EXP,schtest );
        
        test.stoptest();
    }
    
    static testMethod void deleteTagTest() {
        List<Tags__c> lstInsertTag= new List<Tags__c>();
        TestDataProgramCalendar testData= new TestDataProgramCalendar();
        lstInsertTag=testData.createTerritory();
        insert lstInsertTag;
        test.starttest();
        delete lstInsertTag;
        test.stoptest();
    }

}