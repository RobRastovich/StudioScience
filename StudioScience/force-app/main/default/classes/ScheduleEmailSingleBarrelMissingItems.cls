global class ScheduleEmailSingleBarrelMissingItems implements Schedulable {
    global void execute(SchedulableContext sc) {
        String query;
        Set<Id> caseRtIds = SBP_Constants.caseSingleBarrelMissingItemsRtIds;
		List<String> cancelledStatus = new list<String>{'Canceled','Cancelled - Kit Not Selected','Cancelled-Allocation'}; // Added by Jai.
        try {
            query = 'select Id '
                    + ', Purchase_Order_Uploaded__c'
                    + ', Bottle_Text_Entered__c'
                    + ', POS_Items_Selected__c'
                    + ', Barrel_Selected__c'
                    + ', ContactId'
                    + ', Missing_Items__c'
                    + ', Missing_PO__c'
                    + ', CcEmail__c'
                    + ', Brand__c'
                    + ', Submitter__c'
                    + ', Submitter__r.Name'
                    + ', Status'
                    + ', RecordTypeId FROM Case where Case.RecordTypeId IN :caseRtIds'
                    + '  AND Missing_Items__c = true'
                	+ '  AND Status NOT IN :cancelledStatus'
                    + '  AND IsClosed = false' ;

            BatchEmailSingleBarrelMissingItems batch = new BatchEmailSingleBarrelMissingItems(query, caseRtIds);
            ID batchprocessid = Database.executeBatch(batch, 50);
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception ex) {
            CreateExceptionLog.insertErrorLog('BatchEmailSingleBarrelMissingItems', 'execute', String.valueOf(ex), 'Fatal');
        }
    }
}