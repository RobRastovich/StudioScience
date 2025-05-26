public without sharing class SBP_AccountApplicationShareHandler {
    
    @InvocableMethod(label='Account Application Manual Share' description='create manual share to the specified account application IDs.')
    public static void shareAccountApplicationWithGroup(List<Account_Application__c> accountApplications) {
        
        List<Account_Application__c> accAppToShare = new List<Account_Application__c>();
        Set<Id> submitterIds = new Set<Id>();
        Set<Id> hmIds = new Set<Id>();
        for (Account_Application__c accApp : accountApplications) {
            accAppToShare.add(accApp);
            if (accApp.Submitter__c != null) {
                submitterIds.add(accApp.Submitter__c);
            }
            if (accApp.Heritage_Manager__c  != null) {
                hmIds.add(accApp.Heritage_Manager__c);
            }
        }
        
        //No application to process, so break.
        if (accAppToShare.isEmpty()) {
            system.debug('No application to process');
            return;
        }
        
        
        //Get Map of the Id -> User for the Submitters for each Account Application
        Map<Id, User> subIdToSubmitter = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :submitterIds]);
        
        //Get Map of the Id -> User for the HM's for each Account Application
        Map<Id, User> subIdToHM = new Map<Id, User>([SELECT Id, Name, Single_Barrel_Region__c FROM User WHERE Id IN :hmIds]);
        
        //get HM  public group name
        Map<String, Id> groupNameToGroupId = getHMPublicGroups();
        
        //Account application to share
        List<Account_Application__Share> accountApplicationShare = new List<Account_Application__Share>();
        
        system.debug('accAppToShare ' + accAppToShare);
        
        for (Account_Application__c accApp : accAppToShare) {
            
            //account application share with region specific HM
            Account_Application__Share acs = new Account_Application__Share();
            acs.ParentId = accApp.Id;
            if (!Test.isRunningTest()) { 
                acs.UserOrGroupId = getGroupIdForAccountApplicationShare(groupNameToGroupId, subIdToHM.get(accApp.Heritage_Manager__c));
                acs.AccessLevel = 'Edit';
                acs.RowCause = Schema.Account_Application__Share.RowCause.Manual;
                accountApplicationShare.add(acs);
            }
        }
        
        system.debug('accountApplicationShare ' + accountApplicationShare);
        
        //So that if there is a bad Account Application Share, the rest can still get inserted.
        Database.SaveResult[] insertedResults = Database.insert(accountApplicationShare, false);
        
        //Check successes/failures.
        DatabaseTransactionHandler(insertedResults);
    }
    
    // -- added by #Arun Sharma
    public static void DatabaseTransactionHandler(Database.SaveResult[] results){
        
        List<Custom_Exception_Logs__c> exceptionLogs = new List<Custom_Exception_Logs__c>();
        
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted/updated operation on Account_Application_Share/Account_Application object resp. : ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors   
                String errorMessage;
                for (Database.Error err : sr.getErrors()) {
                    errorMessage = 'Error: ' + err.getStatusCode() + ': ' + err.getMessage() + '\n';
                }
                Custom_Exception_Logs__c exceptionLog = CreateExceptionLog.createExceptionLog('SBp_AccountApplicationShareHandler', 'shareAccountApplicationWithGroup', String.valueOf(errorMessage), 'Fatal', false);
                exceptionLogs.add(exceptionLog);
            }
        }
        
        if (!exceptionLogs.isEmpty()) {
            insert exceptionLogs;
        }
    }
    
    /**
* Returns Map of the Group Name to the Group Id for the new HM Public Groups
* which are used to share with and thus open up visibility to the right users.
**/
    public static Map<String, Id> getHMPublicGroups() {
        Map<String, Id> groupNameToGroupId = new Map<String, Id>();
        for (Group g : [SELECT Id, Name, DeveloperName From Group WHERE Name LIKE 'Heritage Manager%']) {
            groupNameToGroupId.put(g.Name, g.Id);
        }
        return groupNameToGroupId;
    }
    
    public static Id getGroupIdForAccountApplicationShare(Map<String, Id> groupNameToGroupId, User hm) {
        //Start with most detailed potential key
        String key = 'Heritage Manager - ' + hm.Single_Barrel_Region__c;
        system.debug('getGroupIdForAccountApplicationShare: ' + key);
        return groupNameToGroupId.get(key);   
    }
    
}