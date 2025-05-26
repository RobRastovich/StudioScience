public class BCH_SCR_CaseUpdationBrandFamily implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        Id consumerInquiryRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumer_Inquiry').getRecordTypeId();
        Id qualityClaimRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Quality_Claim').getRecordTypeId();
        String QUERY_FOR_CASE_UPDATION = 'SELECT Id, Brand__c, Brand_Family__c FROM Case WHERE RecordTypeId IN (:consumerInquiryRecordTypeId,:qualityClaimRecordTypeId) AND Brand_Family__c = null AND Brand__c <> null';
        return Database.getQueryLocator(QUERY_FOR_CASE_UPDATION);
    }
    
    public void execute(Database.BatchableContext BC, List<Case> cases) { 
        System.debug('Start Batch - '+ cases);
        Integer totalSizeRecords = cases.size();
        System.debug('Size of records ' + totalSizeRecords);
        SCR_CaseUpdationScripts.updateCaseBrandFamily(cases);
    }   
   
    public void finish(Database.BatchableContext BC){         
    }
}