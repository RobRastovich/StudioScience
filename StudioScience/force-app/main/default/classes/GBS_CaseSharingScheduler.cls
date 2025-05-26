global class GBS_CaseSharingScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        List<Case> cases = [SELECT Id, RecordTypeId, Type, GBS_Center__c, Category_1__c, Submitter__c, GBS_Sharing__c 
                            FROM Case WHERE 
                            // 11-11-2020 ref: Jira story #SAL-420 -- edited by #Arun Sharma
                            BSI_Function__c = 'GBS' AND GBS_Sharing__c = false 
                            AND isclosed = false and Type != null
                            AND RecordTypeId != :GBS_Constants.HR_RT_ID
                            Order By CreatedDate Desc Limit 10];    
        GBS_CaseSharingHandler.shareCaseWithGroup(cases);
    }
}