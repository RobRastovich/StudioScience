public class BCH_SCR_CaseStatusUpdationToDuplicate implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        Id ConsumerInquiryRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumer_Inquiry').getRecordTypeId();
        String QUERY_FOR_CASE_UPDATION = 'SELECT Id, Status FROM Case WHERE Status = \'DUP - No Action\' AND recordTypeId =: ConsumerInquiryRecordTypeId';
        return Database.getQueryLocator(QUERY_FOR_CASE_UPDATION);
    }
    
    public void execute(Database.BatchableContext BC, List<Case> cases) { 
        System.debug('Start Batch - '+ cases);
        Integer totalSizeRecords = cases.size();
        System.debug('Size of records ' + totalSizeRecords);
        SCR_CaseUpdationScripts.updateCaseStatusToDuplicate(cases);
    }   
    
    public void finish(Database.BatchableContext BC){         
    }
    
}