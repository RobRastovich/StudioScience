public class BCH_BI_CampaignProcessing implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    
    private List<Id> campaignIdList = new List<Id>();
    private Integer totalSizeRecords = 0;
    private UTL_API_Utility.CSRFAuthInfo csrfAuthInfo;
    private String appName;
    
    public BCH_BI_CampaignProcessing(List<Id> campaignIdList, UTL_API_Utility.CSRFAuthInfo csrfAuthInfo, String appName) {
        this.campaignIdList = campaignIdList;
        this.csrfAuthInfo = csrfAuthInfo;
        this.appName = appName;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(EXT_BI_CampaignHelper.prepareCampaignQuery(appName,campaignIdList));
    }
    
    public void execute(Database.BatchableContext BC, List<Campaign__c> campaigns) { 
        totalSizeRecords += campaigns.size();
        EXT_BI_CampaignHelper.handleCampaignBatch(campaigns, csrfAuthInfo, appName);
    }   
    
    public void finish(Database.BatchableContext BC){
        EXT_BI_EmailNotificationHelper.sendingEmailNotification(campaignIdList, appName);
    }
}