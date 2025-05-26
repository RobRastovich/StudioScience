public class EXT_BI_CampaignHelper {
    public static final Integer BI_BATCH_SIZE = 10;
    public static final string STATUS_IO_REJECTED = 'IO Rejected';
    public static final string STATUS_IO_CREATED = 'IO Created';
    public static final string STATUS_IO_PENDING = 'IO Pending';
    public static final string STATUS_WBS_REJECTED = 'WBS Rejected';
    public static final string STATUS_WBS_CREATED = 'WBS Created';
    public static final string STATUS_WBS_PENDING = 'WBS Pending';
    public static final string IO_EXTENSION_STRUCTURE = 'BAPI_TE_AUFK';
    public static final string WBS_EXTENSION_STRUCTURE = 'BAPI_TE_WBS_ELEMENT';
    public static final string WBS_EXTENSION_STRUCTURE2 = 'BI_AUSTRALIA';
    
    public static final Integer ORDERNAME_TEXT_CHAR_LIMIT = 40;
    public static final Integer REQUEST_STATUS_MSG_TEXT_CHAR_LIMIT = 255;
    public static final Integer CHAR_LIMIT_LONG_TEXT = 131072;
    public static final Integer CHAR_LIMIT_STATUS_CODE = 50;
    
    public static final List<string> CAMPAIGN_COMMON_QUERY_FIELDS  = new List<string>{'Id', 'CurrencyIsoCode', 'Name', 'SAP_Company_Code__c', 'SAP_Controlling_Area__c', 'SAP_Cost_Center__c', 'Related_Priority__r.SAP_Code__c,Platform__r.SAP_Code__c', 'Region__c', 'Division__c', 'Territory__c', 'CampaignType__c', 'GLAccountType__c', 'ParentMarketingPlan__r.Brand__r.Name', 'RequestStatus__c', 'Year__C'};
    public static final List<string> CAMPAIGN_IO_QUERY_FIELDS  = new List<string>{'IOCode__c'};
    public static final List<string> CAMPAIGN_WBS_QUERY_FIELDS  = new List<string>{'WBSCode__c','Brand__c','ParentMarketingPlan__r.Brand__r.WBSCodeSegment__c','Brand_Quality__c','ForecastedCampaignSpend__c','GLCode__c','PlannedCampaignSpend__c','Program__c','Platform__c', 'Brand_Quality__r.Name', 'Brand_Quality__r.WBSCodeSegment__c','Brand_Quality__r.BQSS__c'};

    public static final Map<String, String> REJECTED_STATUS_BY_APPNAME_MAP = new Map<String, String>{
        UTL_API_Utility.APPNAME_USBI => STATUS_IO_REJECTED,
        UTL_API_Utility.APPNAME_AUSBI => STATUS_WBS_REJECTED
    };

    public static void handleCampaignBatch(List<Campaign__c> campaigns, UTL_API_Utility.CSRFAuthInfo csrfAuthInfo, String appName) {
        try {
            sendCampaignCodeToSAP(campaigns, csrfAuthInfo, appName);
        } catch(Exception e) {
            String errorMessage = Label.SAP_BI_Processing_Exception + e.getMessage();
            system.debug(errorMessage);
            CreateExceptionLog.insertErrorLog('EXT_BI_CampaignHelper', 'handleCampaignBatch', String.valueOf(errorMessage) + '\n' + e.getStackTraceString(), 'Fatal');
        }
    }

    public static void handleCampaignRecord(List<Campaign__c> campaigns, UTL_API_Utility.CSRFAuthInfo csrfAuthInfo, String appName) {
        try {
            sendCampaignCodeToSAP(campaigns, csrfAuthInfo, appName);
        } catch(Exception e) {
            String errorMessage = Label.SAP_BI_Processing_Exception + e.getMessage();
            system.debug(errorMessage);
            CreateExceptionLog.insertErrorLog('EXT_BI_CampaignHelper', 'handleCampaignRecord', String.valueOf(errorMessage) + '\n' + e.getStackTraceString(), 'Fatal');
            // Update campaign status to Rejected and throw the exception message. 
            if(campaigns!=null && campaigns.size()>0){
                Campaign__c campaignRecord = campaigns[0];
                campaignRecord.RequestStatus__c = REJECTED_STATUS_BY_APPNAME_MAP.get(appName);
                campaignRecord.Request_Status_Message__c = errorMessage.left(REQUEST_STATUS_MSG_TEXT_CHAR_LIMIT);
                update campaignRecord;
            } 
        }
    }

    private static void sendCampaignCodeToSAP(List<Campaign__c> campaigns, UTL_API_Utility.CSRFAuthInfo csrfAuthInfo, String appName) {
        List<SAP_API_Logger__c> apiLoggerUpsertList = new List<SAP_API_Logger__c>();
        List<Campaign__c> campaignUpdateList = new List<Campaign__c>();
        String requestBody = '';
        HttpResponse response = null;
        Set<id> campaignIdSet = new Map<id, Campaign__c>(campaigns).keySet();
        Map<String, String> apiLoggerByRecordIdMap = UTL_API_Utility.getAPILoggers(campaignIdSet);   
        try{  
            for(Campaign__c campaign : campaigns) {
                requestBody = (appName == UTL_API_Utility.APPNAME_USBI) ? prepareIOCampaignRequestJSON(campaign) : prepareWBSCampaignRequestJSON(campaign) ;
                UTL_API_Utility.HttpResponseWrapper responseWrapper = UTL_API_Utility.sendDataToSAPRequest(requestBody, UTL_API_Utility.CONTENT_TYPE_JSON, UTL_API_Utility.CONTENT_TYPE_JSON, csrfAuthInfo);  
                String errorMessage = '';
                // Logging the exception accured during the call out.
                if(!responseWrapper.isSuccess) {
                    errorMessage = responseWrapper.errorMessage;
                    handleCalloutFailure(errorMessage, campaign, requestBody, apiLoggerUpsertList, campaignUpdateList, apiLoggerByRecordIdMap, appname);
                    continue;
                }
                response = responseWrapper.response;  
                // Update the Sales Order record as per the http response
                Campaign__c updatedCampaign = updateCampaignsRecords(campaign.Id, response,appName);
                if(updatedCampaign != null) {
                    campaignUpdateList.add(updatedCampaign);
                }
                String statusCode = String.valueOf(response.getStatusCode());
                if(!Test.isRunningTest() && String.isNotBlank(response.getBody())) {
                    SAP_ErrorResponse sapErrorResponse = SAP_ErrorResponse.parse(response.getBody());
                    if(sapErrorResponse.error != null){
                        errorMessage = sapErrorResponse.error.message.value;
                    }
                }
                SAP_API_Logger__c log = UTL_API_Utility.createAPILogger(campaign.id, campaign.name, appName, requestBody, statusCode, response.getBody(), errorMessage );               
                if(apiLoggerByRecordIdMap.containsKey(campaign.Id)) {
                    log.id = apiLoggerByRecordIdMap.get(campaign.Id);
                }
                apiLoggerUpsertList.add(log);
            }
            if(!campaignUpdateList.isEmpty()) {
                Database.SaveResult[] updateResult = Database.update(campaignUpdateList,false);
                for(Integer i=0; i < updateResult.size(); i++) {
                    if(!updateResult.get(i).isSuccess()) { 
                        SAP_API_Logger__c log = UTL_API_Utility.createAPILogger(campaignUpdateList.get(i).Id, campaignUpdateList.get(i).name, appName, requestBody, UTL_API_Utility.APEX_FAILURE ,response.getBody(), updateResult[i].getErrors()[0].getMessage());
                        apiLoggerUpsertList.add(log);
                    }
                }
            } 
        }
        catch(Exception e) {
            String errorMessage = 'Exception while processing record to SAP in Batch Transaction for ids: ' + campaignIdSet +'. Error: '+ e.getMessage();
            SAP_API_Logger__c log = UTL_API_Utility.createAPILogger('', '', appName, requestBody, UTL_API_Utility.TRANSACTION_FAILURE, '' ,errorMessage);    
            apiLoggerUpsertList.add(log);
            CreateExceptionLog.insertErrorLog('EXT_BI_SalesOrderHelper', 'sendCampaignCodeToSAP', errorMessage, 'Fatal');
        } 
        finally {
            UTL_API_Utility.saveAPILogger(apiLoggerUpsertList);
        }
    }

    public static void handleCalloutFailure(String errorMessage, Campaign__c campaign, String requestBody, 
                        List<SAP_API_Logger__c> apiLoggerUpsertList, 
                        List<Campaign__c> campaignUpdateList,
                        Map<String, String> apiLoggerByRecordIdMap,
                        String appname) {
        SAP_API_Logger__c log = UTL_API_Utility.createAPILogger(campaign.Id , campaign.Name, appName, requestBody,UTL_API_Utility.STATUS_CODE_CALLOUT_EXCEPTION , null ,errorMessage.left(REQUEST_STATUS_MSG_TEXT_CHAR_LIMIT));                     
        if(apiLoggerByRecordIdMap.containsKey(campaign.Id)) {
            log.id = apiLoggerByRecordIdMap.get(campaign.Id);
        }
        apiLoggerUpsertList.add(log);
        Campaign__c campaignToUpdate = new Campaign__c(Id = campaign.Id);
        campaignToUpdate.RequestStatus__c = REJECTED_STATUS_BY_APPNAME_MAP.get(appName);
        campaignToUpdate.Request_Status_Message__c = errorMessage != null ? errorMessage.left(REQUEST_STATUS_MSG_TEXT_CHAR_LIMIT) : null; 
        campaignUpdateList.add(campaignToUpdate);
    }
    
    public static String prepareIOCampaignRequestJSON(Campaign__c campaign){  
        BI_US_CampaignRequestModel campaignRequest = new BI_US_CampaignRequestModel();

        BI_US_CampaignRequestModel.d campaignObj = new BI_US_CampaignRequestModel.d(); 
        //Mapping
        campaignObj.Order = campaign.IOCode__c;
        campaignObj.OrderType = 'SF01';//campaign.CampaignType__c;
        if (campaign.Name!=null) {
            campaignObj.OrderName =  campaign.Name.left(ORDERNAME_TEXT_CHAR_LIMIT);
        }
        campaignObj.CoArea = campaign.SAP_Controlling_Area__c;
        campaignObj.CompCode = campaign.SAP_Company_Code__c;
        campaignObj.Respcctr = campaign.SAP_Cost_Center__c;
        campaignObj.Currency_bi = campaign.CurrencyIsoCode;

        campaignObj.Extension = prepareIOExtentionHelper(campaign);    
        
        campaignRequest.d = campaignObj;       
        
        String reqBody = JSON.serializePretty(campaignRequest);
        reqBody = reqBody.replace('"Currency_bi" :', '"Currency" :');
        SYstem.debug('reqBody with extension--->'+reqBody);
        return reqBody;
    }

    public static BI_US_CampaignRequestModel.Extension prepareIOExtentionHelper(Campaign__c campaign){
        List<BI_US_CampaignRequestModel.Results> resultsList = new List<BI_US_CampaignRequestModel.Results>();

        BI_US_CampaignRequestModel.Results result1 = new BI_US_CampaignRequestModel.Results();      
        result1.Order = campaign.IOCode__c;
        result1.Structure = IO_EXTENSION_STRUCTURE;
        result1.FieldName = 'ZZPROGRAM';
        result1.Value = String.isBlank(campaign.Related_Priority__r.SAP_Code__c)?'':campaign.Related_Priority__r.SAP_Code__c;
        resultsList.add(result1);

        BI_US_CampaignRequestModel.Results result2 = new BI_US_CampaignRequestModel.Results();      
        result2.Order = campaign.IOCode__c;
        result2.Structure = IO_EXTENSION_STRUCTURE;
        result2.FieldName = 'ZZPLATFORM';
        result2.Value = String.isBlank(campaign.Platform__r.SAP_Code__c)?'':campaign.Platform__r.SAP_Code__c;
        resultsList.add(result2);

        BI_US_CampaignRequestModel.Results result3 = new BI_US_CampaignRequestModel.Results();      
        result3.Order = campaign.IOCode__c;
        result3.Structure = IO_EXTENSION_STRUCTURE;
        result3.FieldName = 'ZZREGION';
        result3.Value = String.isBlank(campaign.Region__c)?'':campaign.Region__c;
        resultsList.add(result3);

        BI_US_CampaignRequestModel.Results result4 = new BI_US_CampaignRequestModel.Results();      
        result4.Order = campaign.IOCode__c;
        result4.Structure = IO_EXTENSION_STRUCTURE;
        result4.FieldName = 'ZZDIVISION';
        result4.Value = String.isBlank(campaign.Division__c)?'':campaign.Division__c;
        resultsList.add(result4);

        BI_US_CampaignRequestModel.Results result5 = new BI_US_CampaignRequestModel.Results();      
        result5.Order = campaign.IOCode__c;
        result5.Structure = IO_EXTENSION_STRUCTURE;
        result5.FieldName = 'ZZTERRITORY';
        result5.Value = String.isBlank(campaign.Territory__c)?'':campaign.Territory__c;
        resultsList.add(result5);

        BI_US_CampaignRequestModel.Results result6 = new BI_US_CampaignRequestModel.Results();      
        result6.Order = campaign.IOCode__c;
        result6.Structure = IO_EXTENSION_STRUCTURE;
        result6.FieldName = 'ZZCAMPAIGN_TYPE';
        result6.Value = String.isBlank(campaign.CampaignType__c)?'':campaign.CampaignType__c;
        resultsList.add(result6);

        BI_US_CampaignRequestModel.Results result7 = new BI_US_CampaignRequestModel.Results();      
        result7.Order = campaign.IOCode__c;
        result7.Structure = IO_EXTENSION_STRUCTURE;
        result7.FieldName = 'ZZGL_ACCOUNT_TYPE';
        result7.Value = String.isBlank(campaign.GLAccountType__c)?'':campaign.GLAccountType__c;
        resultsList.add(result7);

        BI_US_CampaignRequestModel.Results result8 = new BI_US_CampaignRequestModel.Results();      
        result8.Order = campaign.IOCode__c;
        result8.Structure = IO_EXTENSION_STRUCTURE;
        result8.FieldName = 'ZZCAMPAIGN_BRAND';
        result8.Value = String.isBlank(campaign.ParentMarketingPlan__r.Brand__r.Name)?'':campaign.ParentMarketingPlan__r.Brand__r.Name;
        resultsList.add(result8);

        BI_US_CampaignRequestModel.Extension extention = new BI_US_CampaignRequestModel.Extension();
        extention.results = resultsList;

        return extention;
    }
    
    public static String prepareWBSCampaignRequestJSON(Campaign__c campaign){
        BI_AUS_CampaignRequestModel campaignRequest = new BI_AUS_CampaignRequestModel();

        BI_AUS_CampaignRequestModel.d campaignObj = new BI_AUS_CampaignRequestModel.d();
        campaignObj.WbsElement = campaign.WBSCode__c;
        campaignObj.Description = campaign.Name.left(ORDERNAME_TEXT_CHAR_LIMIT);
        campaignObj.CompanyCode = campaign.SAP_Company_Code__c;
        campaignObj.ControllingArea = campaign.SAP_Controlling_Area__c;
        campaignObj.Currency_bi = 'AUD';
        campaignObj.CurrencyIso = 'AUD';
        if(campaign.Year__c!=null && campaign.ParentMarketingPlan__r.Brand__r.WBSCodeSegment__c!=null)
        	campaignObj.WbsUp = 'AU'+campaign.Year__c.right(2)+campaign.ParentMarketingPlan__r.Brand__r.WBSCodeSegment__c;
        else
            campaignObj.WbsUp = 'AU';
        campaignObj.SystemStatus = '';
        campaignObj.ProjectDefinition = 'BI'+'AU'+campaign.Year__c;
        campaignObj.WbsPlanningElement = true;
        campaignObj.WbsAccountAssignmentElement = true;
        campaignObj.WbsBillingElement = true;
        campaignObj.UserFieldChar201 = 'AU01';
        campaignObj.UserFieldChar202 = '900';
        campaignObj.UserFieldChar101 = campaign.Brand_Quality__r.BQSS__c;
        campaignObj.UserFieldQuan1 = '0.000';
        campaignObj.UserFieldQuan2 = '0.000';
        campaignObj.UserFieldCurr1 = '0.000'; 
        campaignObj.UserFieldCurr2 = '0.000'; 
        campaignObj.UserFieldFlag1 = false;
        campaignObj.UserFieldFlag2 = false; 
        campaignObj.WbsSummarization = false; 
        campaignObj.Statistical = false; 
        campaignObj.Evgew = '0';
        campaignObj.Planintegrated = false;
        campaignObj.WbsBasicDuration = '0.0';
        campaignObj.WbsForecastDuration = '0.0';
        campaignObj.WbsActualDurUnit = '';
        campaignObj.WbsActualDuration = '0.0';
        campaignObj.NetworkAssignment = '0';
        campaignRequest.d = campaignObj;

        campaignObj.WBSElementToExtension = prepareWBSExtentionMethod(campaign);
        campaignObj.WBSElementToProject = prepareWBSProjectMethod(campaign);

        String reqBody = JSON.serializePretty(campaignRequest);
        reqBody = reqBody.replace('"Currency_bi" :', '"Currency" :');
        SYstem.debug('reqBody with extension--->'+reqBody);
        return reqBody;
    }
    
    public static BI_AUS_CampaignRequestModel.WBSElementToProject prepareWBSProjectMethod(Campaign__c campaign){
        BI_AUS_CampaignRequestModel.WBSElementToProject wbsElementToProject = new BI_AUS_CampaignRequestModel.WBSElementToProject();
        wbsElementToProject.ProjectDefinition = 'BI'+'AU'+campaign.Year__c;
        wbsElementToProject.Description =  'Brand Investment Australia ' + campaign.Year__c;
        wbsElementToProject.CompCode = campaign.SAP_Company_Code__c;
        wbsElementToProject.ControllingArea = campaign.SAP_Controlling_Area__c;
        wbsElementToProject.ProjectProfile = 'ZAU0001';
        wbsElementToProject.ProjectStock = false;
        wbsElementToProject.Statistical = false;
        return wbsElementToProject;
    }

    public static BI_AUS_CampaignRequestModel.WBSElementToExtension prepareWBSExtentionMethod(Campaign__c campaign){
        List<BI_AUS_CampaignRequestModel.Results> resultsList = new List<BI_AUS_CampaignRequestModel.Results>();

        BI_AUS_CampaignRequestModel.Results result1 = new BI_AUS_CampaignRequestModel.Results();      
        result1.WBSElement = campaign.WBSCode__c;
        result1.Structure = WBS_EXTENSION_STRUCTURE;
        result1.FieldName = 'WBS_ELEMENT';
        result1.Value = String.isBlank(campaign.WBSCode__c)?'':campaign.WBSCode__c;
        resultsList.add(result1);

        BI_AUS_CampaignRequestModel.Results result2 = new BI_AUS_CampaignRequestModel.Results();      
        result2.WBSElement = campaign.WBSCode__c;
        result2.Structure = WBS_EXTENSION_STRUCTURE;
        result2.FieldName = 'ZZPRODHIER';
        result2.Value = '';
        resultsList.add(result2);

        BI_AUS_CampaignRequestModel.Results result3 = new BI_AUS_CampaignRequestModel.Results();      
        result3.WBSElement = campaign.WBSCode__c;
        result3.Structure = WBS_EXTENSION_STRUCTURE;
        result3.FieldName = 'ZREGION';
        result3.Value = String.isBlank(campaign.Region__c)?'':campaign.Region__c;
        resultsList.add(result3);

        BI_AUS_CampaignRequestModel.Results result4 = new BI_AUS_CampaignRequestModel.Results();      
        result4.WBSElement = campaign.WBSCode__c;
        result4.Structure = WBS_EXTENSION_STRUCTURE;
        result4.FieldName = 'ZDIVISION';
        result4.Value = String.isBlank(campaign.Division__c)?'':campaign.Division__c;
        resultsList.add(result4);

        BI_AUS_CampaignRequestModel.Results result5 = new BI_AUS_CampaignRequestModel.Results();      
        result5.WBSElement = campaign.WBSCode__c;
        result5.Structure = WBS_EXTENSION_STRUCTURE;
        result5.FieldName = 'ZTERRITORY';
        result5.Value = String.isBlank(campaign.Territory__c)?'':campaign.Territory__c;
        resultsList.add(result5);

        BI_AUS_CampaignRequestModel.Results result6 = new BI_AUS_CampaignRequestModel.Results();      
        result6.WBSElement = campaign.WBSCode__c;
        result6.Structure = WBS_EXTENSION_STRUCTURE;
        result6.FieldName = 'ZCAMPAIGN_TYPE';
        result6.Value = String.isBlank(campaign.CampaignType__c)?'':campaign.CampaignType__c;
        resultsList.add(result6);

        BI_AUS_CampaignRequestModel.Results result7 = new BI_AUS_CampaignRequestModel.Results();      
        result7.WBSElement = campaign.WBSCode__c;
        result7.Structure = WBS_EXTENSION_STRUCTURE;
        result7.FieldName = 'ZCAMPAIGN_BRAND';
        result7.Value = String.isBlank(campaign.ParentMarketingPlan__r.Brand__r.Name)?'':campaign.ParentMarketingPlan__r.Brand__r.Name;
        resultsList.add(result7);

        BI_AUS_CampaignRequestModel.Results result8 = new BI_AUS_CampaignRequestModel.Results();      
        result8.WBSElement = campaign.WBSCode__c;
        result8.Structure = WBS_EXTENSION_STRUCTURE;
        result8.FieldName = 'ZGL_ACCOUNT_TYPE';
        result8.Value = String.isBlank(campaign.GLAccountType__c)?'':campaign.GLAccountType__c;
        resultsList.add(result8);

        BI_AUS_CampaignRequestModel.Results result9 = new BI_AUS_CampaignRequestModel.Results();      
        result9.WBSElement = campaign.WBSCode__c;
        result9.Structure = WBS_EXTENSION_STRUCTURE;
        result9.FieldName = 'ZZPROGRAM';
        result9.Value = '';
        // If Related_Priority field is null,the value of the result for ZZPROGRAM will be replaced by a blank value
        if(campaign.Related_Priority__r != null) {
        	result9.Value = String.isBlank(campaign.Related_Priority__r.SAP_Code__c)?'':campaign.Related_Priority__r.SAP_Code__c;
        }
        resultsList.add(result9);

        BI_AUS_CampaignRequestModel.Results result10 = new BI_AUS_CampaignRequestModel.Results();      
        result10.WBSElement = campaign.WBSCode__c;
        result10.Structure = WBS_EXTENSION_STRUCTURE;
        result10.FieldName = 'ZZPLATFORM';
        // If Platform field is null,the value of the result for ZZPLATFORM will be replaced by a blank value
        result10.Value = '';
        if(campaign.Platform__r != null) {
        	result10.Value = String.isBlank(campaign.Platform__r.SAP_Code__c)?'':campaign.Platform__r.SAP_Code__c;
        }
        resultsList.add(result10);


        BI_AUS_CampaignRequestModel.Results result11 = new BI_AUS_CampaignRequestModel.Results();      
        result11.WBSElement = campaign.WBSCode__c;
        result11.Structure = WBS_EXTENSION_STRUCTURE2;
        result11.FieldName = 'COUNTRY_CODE';
        result11.Value = 'AU';
        resultsList.add(result11);

        BI_AUS_CampaignRequestModel.Results result12 = new BI_AUS_CampaignRequestModel.Results();      
        result12.WBSElement = campaign.WBSCode__c;
        result12.Structure = WBS_EXTENSION_STRUCTURE2;
        result12.FieldName = 'COUNTRY_DESCRIPTION';
        result12.Value = 'AUSTRALIA';
        resultsList.add(result12);

        BI_AUS_CampaignRequestModel.Results result13 = new BI_AUS_CampaignRequestModel.Results();      
        result13.WBSElement = campaign.WBSCode__c;
        result13.Structure = WBS_EXTENSION_STRUCTURE2;
        result13.FieldName = 'YEAR';
        result13.Value = String.isBlank(campaign.Year__c)?'':campaign.Year__c;
        resultsList.add(result13);

        BI_AUS_CampaignRequestModel.Results result14 = new BI_AUS_CampaignRequestModel.Results();      
        result14.WBSElement = campaign.WBSCode__c;
        result14.Structure = WBS_EXTENSION_STRUCTURE2;
        result14.FieldName = 'BUKRS';
        result14.Value = String.isBlank(campaign.SAP_Company_Code__c)?'':campaign.SAP_Company_Code__c;
        resultsList.add(result14);
        
        BI_AUS_CampaignRequestModel.Results result15 = new BI_AUS_CampaignRequestModel.Results();      
        result15.WBSElement = campaign.WBSCode__c;
        result15.Structure = WBS_EXTENSION_STRUCTURE2;
        result15.FieldName = 'KOKRS';
        result15.Value = String.isBlank(campaign.SAP_Controlling_Area__c)?'':campaign.SAP_Controlling_Area__c;
        resultsList.add(result15);

        BI_AUS_CampaignRequestModel.Results result16 = new BI_AUS_CampaignRequestModel.Results();      
        result16.WBSElement = campaign.WBSCode__c;
        result16.Structure = WBS_EXTENSION_STRUCTURE2;
        result16.FieldName = 'BRAND_NAME';
        result16.Value = String.isBlank(campaign.Brand__c)?'':campaign.Brand__c;
        resultsList.add(result16);

        BI_AUS_CampaignRequestModel.Results result17 = new BI_AUS_CampaignRequestModel.Results();      
        result17.WBSElement = campaign.WBSCode__c;
        result17.Structure = WBS_EXTENSION_STRUCTURE2;
        result17.FieldName = 'BRAND_CODE';
        result17.Value = String.isBlank(campaign.ParentMarketingPlan__r.Brand__r.WBSCodeSegment__c)?'':campaign.ParentMarketingPlan__r.Brand__r.WBSCodeSegment__c;
        resultsList.add(result17);

        BI_AUS_CampaignRequestModel.Results result18 = new BI_AUS_CampaignRequestModel.Results();      
        result18.WBSElement = campaign.WBSCode__c;
        result18.Structure = WBS_EXTENSION_STRUCTURE2;
        result18.FieldName = 'BRAND_BUDGET';
        result18.Value = '';
        resultsList.add(result18);
        
        BI_AUS_CampaignRequestModel.Results result19 = new BI_AUS_CampaignRequestModel.Results();      
        result19.WBSElement = campaign.WBSCode__c;
        result19.Structure = WBS_EXTENSION_STRUCTURE2;
        result19.FieldName = 'BRAND_BUDGET_CURRENCY';
        result19.Value = 'AUD';
        resultsList.add(result19);

        BI_AUS_CampaignRequestModel.Results result20 = new BI_AUS_CampaignRequestModel.Results();      
        result20.WBSElement = campaign.WBSCode__c;
        result20.Structure = WBS_EXTENSION_STRUCTURE2;
        result20.FieldName = 'BRAND_QUALITY_NAME';
        // If BRAND_QUALITY field is null,the value of the result for BRAND_QUALITY_NAME will be replaced by a blank value
        result20.Value = '';
        if(campaign.Brand_Quality__r != null) {
        	result20.Value = String.isBlank(campaign.Brand_Quality__r.Name)?'':campaign.Brand_Quality__r.Name;
        }
        resultsList.add(result20);

        BI_AUS_CampaignRequestModel.Results result21 = new BI_AUS_CampaignRequestModel.Results();      
        result21.WBSElement = campaign.WBSCode__c;
        result21.Structure = WBS_EXTENSION_STRUCTURE2;
        result21.FieldName = 'BRAND_QUALITY_CODE';
        // If BRAND_QUALITY field is null,the value of the result for BRAND_QUALITY_CODE will be replaced by a blank value 
        result21.Value = '';
        if(campaign.Brand_Quality__r != null) {
        	result21.Value = String.isBlank(campaign.Brand_Quality__r.WBSCodeSegment__c)?'':campaign.Brand_Quality__r.WBSCodeSegment__c;
        }
        resultsList.add(result21);

        BI_AUS_CampaignRequestModel.Results result22 = new BI_AUS_CampaignRequestModel.Results();      
        result22.WBSElement = campaign.WBSCode__c;
        result22.Structure = WBS_EXTENSION_STRUCTURE2;
        result22.FieldName = 'PERIOD_FROM';
        result22.Value = '1';
        resultsList.add(result22);

        BI_AUS_CampaignRequestModel.Results result23 = new BI_AUS_CampaignRequestModel.Results();      
        result23.WBSElement = campaign.WBSCode__c;
        result23.Structure = WBS_EXTENSION_STRUCTURE2;
        result23.FieldName = 'PERIOD_TO';
        result23.Value = '12';
        resultsList.add(result23);

        BI_AUS_CampaignRequestModel.Results result24 = new BI_AUS_CampaignRequestModel.Results();      
        result24.WBSElement = campaign.WBSCode__c;
        result24.Structure = WBS_EXTENSION_STRUCTURE2;
        result24.FieldName = 'VERSION';
        result24.Value = '0';
        resultsList.add(result24);

        BI_AUS_CampaignRequestModel.Results result25 = new BI_AUS_CampaignRequestModel.Results();      
        result25.WBSElement = campaign.WBSCode__c;
        result25.Structure = WBS_EXTENSION_STRUCTURE2;
        result25.FieldName = 'PLAN_CURRTYPE';
        result25.Value = 'C';
        resultsList.add(result25);
        
        BI_AUS_CampaignRequestModel.Results result26 = new BI_AUS_CampaignRequestModel.Results();      
        result26.WBSElement = campaign.WBSCode__c;
        result26.Structure = WBS_EXTENSION_STRUCTURE2;
        result26.FieldName = 'FORECASTED_CAMPAIGN_BUDGET';
        result26.Value = String.valueOf(campaign.ForecastedCampaignSpend__c);
        resultsList.add(result26);

        BI_AUS_CampaignRequestModel.Results result27 = new BI_AUS_CampaignRequestModel.Results();      
        result27.WBSElement = campaign.WBSCode__c;
        result27.Structure = WBS_EXTENSION_STRUCTURE2;
        result27.FieldName = 'FORECASTED_CAMPAIGN_BUDGET_CUR';
        result27.Value = 'AUD';
        resultsList.add(result27);
        
        BI_AUS_CampaignRequestModel.Results result28 = new BI_AUS_CampaignRequestModel.Results();      
        result28.WBSElement = campaign.WBSCode__c;
        result28.Structure = WBS_EXTENSION_STRUCTURE2;
        result28.FieldName = 'COST_ELEM';
        result28.Value = String.isBlank(campaign.GLCode__c)?'':campaign.GLCode__c;
        resultsList.add(result28);
        
        BI_AUS_CampaignRequestModel.Results result29 = new BI_AUS_CampaignRequestModel.Results();      
        result29.WBSElement = campaign.WBSCode__c;
        result29.Structure = WBS_EXTENSION_STRUCTURE2;
        result29.FieldName = 'DIST_KEY_VAR_VAL';
        result29.Value = '2';
        resultsList.add(result29);

        BI_AUS_CampaignRequestModel.Results result30 = new BI_AUS_CampaignRequestModel.Results();      
        result30.WBSElement = campaign.WBSCode__c;
        result30.Structure = WBS_EXTENSION_STRUCTURE2;
        result30.FieldName = 'BUDGET_ACTIVITY';
        result30.Value = 'KBUD';
        resultsList.add(result30);
        
        BI_AUS_CampaignRequestModel.Results result31 = new BI_AUS_CampaignRequestModel.Results();      
        result31.WBSElement = campaign.WBSCode__c;
        result31.Structure = WBS_EXTENSION_STRUCTURE2;
        result31.FieldName = 'CAMPAIGN_BUDGET';
        result31.Value = String.valueOf(campaign.PlannedCampaignSpend__c);
        resultsList.add(result31);

        BI_AUS_CampaignRequestModel.Results result32 = new BI_AUS_CampaignRequestModel.Results();      
        result32.WBSElement = campaign.WBSCode__c;
        result32.Structure = WBS_EXTENSION_STRUCTURE2;
        result32.FieldName = 'CAMPAIGN_BUDGET_CURRENCY';
        result32.Value = 'AUD';
        resultsList.add(result32);

        BI_AUS_CampaignRequestModel.WBSElementToExtension extention = new BI_AUS_CampaignRequestModel.WBSElementToExtension();
        extention.results = resultsList;
        return extention;
    }
    
    
    public static Campaign__c updateCampaignsRecords(Id campaignId, HttpResponse response, String appName) {
        System.debug('****INSIDE UPDATE OF CAMPAIGN****');
        Campaign__c campaignToUpdate = null;
        String responseBody = response.getBody();
        if(String.isNotBlank(responseBody))
        {
            campaignToUpdate = new Campaign__c(Id = campaignId);
                //responseBody = responseBody.replaceFirst('"Currency" :', '"Currency_bi" :');
                if(response.getStatusCode() == 201){
                    if(appName == UTL_API_Utility.APPNAME_USBI){
                    	System.debug('***CREATED IO CODE SENT SUCCESSFULLY***');
                    	campaignToUpdate.RequestStatus__c = STATUS_IO_CREATED;  
                    }
                    else if(appName == UTL_API_Utility.APPNAME_AUSBI){
                        System.debug('***CREATED WBS CODE SENT SUCCESSFULLY***');
                    	campaignToUpdate.RequestStatus__c = STATUS_WBS_CREATED;
                    }
                    campaignToUpdate.Code_Created_Date__c = Date.today();
                    campaignToUpdate.Request_Status_Message__c = '';
                } else {
                    SAP_ErrorResponse sapErrorResponse = SAP_ErrorResponse.parse(responseBody);
                    campaignToUpdate.RequestStatus__c = REJECTED_STATUS_BY_APPNAME_MAP.get(appName);
                    String errorMessageFromSAP = sapErrorResponse.error.message.value.left(REQUEST_STATUS_MSG_TEXT_CHAR_LIMIT);
                    campaignToUpdate.Request_Status_Message__c = UTL_API_Utility.getUserFriendlyError(errorMessageFromSAP ,appName);
                }
            }
        return campaignToUpdate;
    }
    
    public static UTL_API_Utility.CSRFAuthInfo getUserAuthenticationInfo(String appName){ 
        return UTL_API_Utility.getCSRFToken_oAuth(appName); 
    }
    
    public static String prepareCampaignQuery(String appName, List<Id> campaignIdList) {
        List<string> combinedFieldList = new List<string>();
        combinedFieldList.addAll(CAMPAIGN_COMMON_QUERY_FIELDS);
        combinedFieldList.addAll( (appName == UTL_API_Utility.APPNAME_USBI) ? CAMPAIGN_IO_QUERY_FIELDS : CAMPAIGN_WBS_QUERY_FIELDS); 
        return 'SELECT '+ String.join(combinedFieldList, ',') +' FROM Campaign__c WHERE Id IN :campaignIdList AND (RequestStatus__c != \'IO Created\' AND RequestStatus__c != \'WBS Created\')';
    }
    
}