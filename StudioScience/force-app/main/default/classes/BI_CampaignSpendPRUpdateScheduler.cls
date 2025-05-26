public class BI_CampaignSpendPRUpdateScheduler implements Schedulable{
    
    public void execute(SchedulableContext sc) {
        List<Campaign_Spend__c> campaignSpendList = [SELECT id, RecordTypeId
                            FROM Campaign_Spend__c
                            WHERE Recordtype.name='Pending'
                            AND PR_Header__r.status__c = 'Completed'];    
       
        Id campSpendRecordtypeId = Schema.SObjectType.Campaign_Spend__c.getRecordTypeInfosByName().get('Committed').getRecordTypeId();
    
        for(Campaign_Spend__c rec : campaignSpendList){
            rec.RecordTypeId= campSpendRecordtypeId;
        }
        try {
            if(!campaignSpendList.isEmpty()){
                System.debug('inside update before update');
            	update campaignSpendList;
                System.debug('inside update after update');
        	}
        } catch (DmlException e) {
            // Process exception here
            
            String errorMessage = 'Error: ' + e.getMessage() + '\n' + e.getStackTraceString();
            System.debug('error here' + errorMessage);
            CreateExceptionLog.insertErrorLog('BI_CampaignSpendPRUpdateScheduler', 'execute', String.valueOf(errorMessage), 'Fatal');
        }
            
	}
}