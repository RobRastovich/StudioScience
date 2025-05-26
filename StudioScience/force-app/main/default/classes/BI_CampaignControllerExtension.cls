global class BI_CampaignControllerExtension {
    
    private final Campaign__c campaign;
    private ApexPages.StandardController standardController;
    
    public String getAPPNAME_USBI() {
            return UTL_API_Utility.APPNAME_USBI;
    }
    
    public String getAPPNAME_AUSBI() {
            return UTL_API_Utility.APPNAME_AUSBI;
    }
    
    public BI_CampaignControllerExtension(ApexPages.StandardController stdController) {
        this.standardController = stdController;
        this.campaign = (Campaign__c)stdController.getRecord();
        System.debug(LoggingLevel.INFO,this.campaign);
    }
    
    @RemoteAction
    global static void sendCodeToSAP(Id recordId,String appName){
        List<Id> campaignIdList = new List<Id>();
        campaignIdList.add(recordId);
        UTL_API_Utility.CSRFAuthInfo csrfResponse = UTL_API_Utility.getCSRFToken_oAuth(appName);
        
        String queryString = EXT_BI_CampaignHelper.prepareCampaignQuery(appName, campaignIdList);
        List<Campaign__c> campaignList = Database.query(queryString);
        if(campaignList.size()>0)
        	EXT_BI_CampaignHelper.handleCampaignRecord(campaignList, csrfResponse, appName);
    }
    
    @RemoteAction
    global static String generateCodeFromPageLayout(Id recordId,String appName)
    {              
        set<Id> campaignIds = new set<Id>{ recordId };
        System.debug(LoggingLevel.INFO,'Campaign IDs: ' + campaignIds);

        List<Id> campaignIdList = new List<Id>(campaignIds);
        String queryString = EXT_BI_CampaignHelper.prepareCampaignQuery(appName, campaignIdList);
        List<Campaign__c> campaignList = Database.query(queryString);
        List<SAP_API_Logger__c> apiLoggerInsertList = new List<SAP_API_Logger__c>();
        for(Campaign__c campaign : campaignList) {
            String requestBody = (appName == UTL_API_Utility.APPNAME_USBI) ? EXT_BI_CampaignHelper.prepareIOCampaignRequestJSON(campaign) : EXT_BI_CampaignHelper.prepareWBSCampaignRequestJSON(campaign) ;
            SAP_API_Logger__c log = UTL_API_Utility.createAPILogger(campaign.Id,campaign.Name, appName, requestBody, UTL_API_Utility.STATUS_CODE_REQ_INIT, '');
            apiLoggerInsertList.add(log);
        }
        UTL_API_Utility.saveAPILogger(apiLoggerInsertList);
   
        if(appName == UTL_API_Utility.APPNAME_USBI){
            List<CampaignIOResult> resultsUS = BI_CampaignIntegrationLogic.generateIOCodes(campaignIds);
            System.debug(LoggingLevel.INFO,'IO Results:' + resultsUS);
            return resultsUS.get(0).Message;
        }
        else{
            List<CampaignWBSResult> resultsAUS = BI_CampaignIntegrationLogic.generateWBSCodes(campaignIds);
            System.debug(LoggingLevel.INFO,'WBS Results:' + resultsAUS);
            return resultsAUS.get(0).Message;
        }
    }
    
    @RemoteAction
    global static Boolean isNamedCredentialExists(String appName){
        return UTL_API_Utility.checkUserNamedCredential(UserInfo.getUserId(),appName);
    }
    
    @RemoteAction
    global static Boolean isUserAuthenticated(String appName) {
        UTL_API_Utility.CSRFAuthInfo csrfResponse = EXT_BI_CampaignHelper.getUserAuthenticationInfo(appName);
        return csrfResponse.isUserAuthorized;
    }
    
}