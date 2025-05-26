public class unForecastedBudgetCampaignController {

    campaign__c c; 
    
    public unForecastedBudgetCampaignController(ApexPages.StandardController controller) {
         c= (Campaign__c )controller.getRecord();
    }
    
    public void updateCampaign(){
        system.debug('is budget change @@'+ c.Is_Budget_Change__c);
        c.Is_Budget_Change__c=false;
        update c;
    }

}