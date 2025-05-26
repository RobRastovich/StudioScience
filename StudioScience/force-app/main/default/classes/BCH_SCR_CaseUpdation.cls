public class BCH_SCR_CaseUpdation implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        Id ConsumerInquiryRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumer_Inquiry').getRecordTypeId();
        String QUERY_FOR_CASE_UPDATION = 'SELECT Id, Status, CaseClosedType__c, ClosedDate, Actual_Closed_Date__c, LastModifiedDate, AgentResponseOnCase__c, ConsumerResponseOnCase__c, (SELECT Id, Status, FromAddress, Incoming, CreatedDate, CreatedBy.Name FROM EmailMessages) FROM Case WHERE Status IN (\'Resolved\', \'Closed\') AND recordTypeId =: ConsumerInquiryRecordTypeId AND (CaseClosedType__c = NULL OR Actual_Closed_Date__c = NULL OR AgentResponseOnCase__c = NULL OR ConsumerResponseOnCase__c = NULL)';
        return Database.getQueryLocator(QUERY_FOR_CASE_UPDATION);
    }
    
    public void execute(Database.BatchableContext BC, List<Case> cases) { 
        System.debug('Start Batch - '+ cases);
        Integer totalSizeRecords = cases.size();
        System.debug('Size of records ' + totalSizeRecords);
        SCR_CaseUpdationScripts.updateCaseClosedType(cases);
    }   
    
    public void finish(Database.BatchableContext BC){         
    }
    
}