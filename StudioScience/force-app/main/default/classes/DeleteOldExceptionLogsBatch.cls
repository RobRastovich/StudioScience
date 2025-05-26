global class DeleteOldExceptionLogsBatch implements Database.Batchable<sobject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        Date twoMonthsAgo = System.today().addMonths(-2);
        String query = 'SELECT Id FROM Custom_Exception_Logs__c WHERE CreatedDate < :twoMonthsAgo';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<Custom_Exception_Logs__c> scope) {
        try{
            if(scope != null && !scope.isEmpty()){
                delete scope;
            } 
        }catch (Exception e) {
            System.debug('Error message: '+e.getMessage());
        } 
    }
    
    global void finish(Database.BatchableContext context) {
        // Perform any post-processing if needed
    }
    
    global void execute(SchedulableContext sc) {
        DeleteOldExceptionLogsBatch deb = new DeleteOldExceptionLogsBatch();
        Database.executeBatch(deb);
    }
}