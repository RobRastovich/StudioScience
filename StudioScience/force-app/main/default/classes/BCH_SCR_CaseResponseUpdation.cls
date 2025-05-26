public class BCH_SCR_CaseResponseUpdation implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        Id ConsumerInquiryRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumer_Inquiry').getRecordTypeId();
        String QUERY_FOR_CASE_UPDATION = 'SELECT Id, AgentResponseOnCase__c, ConsumerResponseOnCase__c, (SELECT Id, Status, FromAddress, Incoming, CreatedDate, CreatedBy.Name FROM EmailMessages) FROM Case WHERE recordTypeId =: ConsumerInquiryRecordTypeId AND (AgentResponseOnCase__c = NULL OR ConsumerResponseOnCase__c = NULL) AND Status NOT IN (\'Resolved\', \'Closed\')';
        return Database.getQueryLocator(QUERY_FOR_CASE_UPDATION);
    }
    
    public void execute(Database.BatchableContext BC, List<Case> cases) { 
        System.debug('Start Batch - '+ cases);
        Integer totalSizeRecords = cases.size();
        System.debug('Size of records ' + totalSizeRecords);
        SCR_CaseUpdationScripts.updateCaseResponse(cases);
    }   
    
    public void finish(Database.BatchableContext BC){         
    }
    
}