@isTest
private class CaseTriggerTest
{
    static testMethod void TestCase()
    { 
        String CASE_RT_Standard = 'Standard Case';
        Id caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CASE_RT_Standard).getRecordTypeId();
         //Insert new case
        Case c = new Case();
        c.Status = 'New';
        c.Last_Status_Change__c = System.Now();
        c.RecordTypeId = caseRTId;
        insert c;
        
        c.Subject = 'test';
        update c;
    }
}