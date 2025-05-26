public with sharing class BI_WBSCalloutUtility {

    /*
    * Helper method for the callout process
    * Takes a set of Campaign Ids
    * Retrieves and returns a set of Ids belonging to Level 3 (Brand) Marketing Plans above the Campaigns within the set
    */
    public static Set<Id> retrieveRelatedL3MarketingPlans(Set<Id> campaignIds){
        Set<Id> returnedMPIdSet = new Set<Id>();
        List<Campaign__c> campaigns = [SELECT Id, ParentMarketingPlan__c, ParentMarketingPlan__r.MP_Level__c FROM Campaign__c WHERE Id IN: campaignIds];

        Set<Id> mpIdSet = new Set<Id>();
        for(Campaign__c c: campaigns){
            mpIdSet.add(c.ParentMarketingPlan__c);  
        }

        while(!mpIdSet.isEmpty()){
            List<MarketingPlan__c> mpList = [SELECT Id, ParentMarketingPlan__c, Brand__r.Name, CurrencyIsoCode, MP_Level__c FROM MarketingPlan__c WHERE Id IN: mpIdSet];
            mpIdSet.clear();
            for(MarketingPlan__c mp: mpList){
                if(mp.MP_Level__c == '3'){
                    returnedMPIdSet.add(mp.Id);
                } else {
                    mpIdSet.add(mp.ParentMarketingPlan__c);
                }
            }
        }
        System.debug(LoggingLevel.INFO, returnedMPIdSet);
        return returnedMPIdSet;
    }

    /*
    * Helper method for the callout process
    * Takes a set of Campaign Ids.
    * Retrieves relevant information about all campaigns and generates WBS_Element values
    * Returns a list of WBS_Element values for use with a SOAP Callout
    */
    public static List<BGSW_WBS_v2.Items_element> generateCalloutParamElements(Set<Id> transmittedCampaignIds){
        System.debug('inside generateCalloutParamElements:::');
        List<BGSW_WBS_v2.Items_element> itemsList = new List<BGSW_WBS_v2.Items_element>();
        Set<Id> brandIdSet = new Set<Id>();
        Set<Id> campaignIdSet = new Set<Id>();
        Map<Id, Id> campaignBrandMap = new Map<Id, Id>();
        Map<Id, Decimal> brandBudgetMap = new Map<Id, Decimal>();
        Map<Id, String> brandCurrencyCodeMap = new Map<Id, String>();

        List<Campaign__c> transmittedCampaigns = [SELECT Id, Name, WBSCode__c, ParentMarketingPlan__c, 
                                                    ParentMarketingPlan__r.Brand__c,
                                                    ParentMarketingPlan__r.Brand__r.Name, 
                                                    ParentMarketingPlan__r.Brand__r.WBSCodeSegment__c, 
                                                    ParentMarketingPlan__r.Country__c, ParentMarketingPlan__r.Year__c, 
                                                    ParentMarketingPlan__r.SAP_Company_Code__c, ParentMarketingPlan__r.SAP_Controlling_Area__c,
                                                    CampaignType__c, ForecastedCampaignSpend__c, CurrencyIsoCode, PlannedCampaignSpend__c,
                                                    Brand_Quality__r.Name, Brand_Quality__r.WBSCodeSegment__c, Brand_Quality__r.BQSS__c, GLCode__c, GLAccountType__c,
                                                    Region__c, Division__c, Territory__c, Related_Priority__r.Name, Related_Priority__r.Description__c,
                                                    Related_Priority__r.SAP_Code__c, Platform__r.SAP_Code__c
                                                    FROM Campaign__c WHERE Id IN: transmittedCampaignIds];
        System.debug('---List Size---'+transmittedCampaigns.size());                                            

        //Capturing Brand Ids for querying the budget of the Level 3 Marketing Plan
        for(Campaign__c currCampaign: transmittedCampaigns){
            brandIdSet.add(currCampaign.ParentMarketingPlan__r.Brand__c);
            campaignBrandMap.put(currCampaign.Id, currCampaign.ParentMarketingPlan__r.Brand__c);
            campaignIdSet.add(currCampaign.Id);
        }
        System.debug('---Map--'+campaignBrandMap);
        Set<Id> level3MarketingPlanIdSet = retrieveRelatedL3MarketingPlans(campaignIdSet);
        List<MarketingPlan__c> level3MarketingPlans = [SELECT Id, Name, MP_Level__c, Budget__c, CurrencyIsoCode, Brand__c FROM MarketingPlan__c WHERE MP_Level__c='3' AND Brand__c IN: brandIdSet AND Id IN: level3MarketingPlanIdSet];
        for(MarketingPlan__c currMarketingPlan: level3MarketingPlans){
            System.debug(LoggingLevel.INFO, currMarketingPlan.Name +': ' + currMarketingPlan.MP_Level__c);
            brandBudgetMap.put(currMarketingPlan.Brand__c, currMarketingPlan.Budget__c);
            brandCurrencyCodeMap.put(currMarketingPlan.Brand__c, currMarketingPlan.CurrencyIsoCode);
        }

        //SAP will only accept decimal values with 2 or fewer digits, otherwise it will raise an exception. Must set scale for numeric values to 2
        for(Campaign__c currCampaign: transmittedCampaigns){
            BGSW_WBS_v2.Items_element currItem = new BGSW_WBS_v2.Items_element();
           /* 
            currItem.WBS_ID                                 = currCampaign.WBSCode__c;
            currItem.BRAND_NAME                             = 'Canadian Club'; //currCampaign.ParentMarketingPlan__r.Brand__r.Name;
            currItem.BRAND_CODE                             = 'CACL';//currCampaign.ParentMarketingPlan__r.Brand__r.WBSCodeSegment__c;
            currItem.BRAND_BUDGET                           = String.valueOf(brandBudgetMap.get(campaignBrandMap.get(currCampaign.Id)).setScale(2, RoundingMode.HALF_UP));
            currItem.BRAND_BUDGET_CURRENCY                  = currCampaign.CurrencyIsoCode;//String.valueOf(brandCurrencyCodeMap.get(campaignBrandMap.get(currCampaign.Id)));
            currItem.BRAND_QUALITY_CODE                     = 'CCL'; //currCampaign.Brand_Quality__r.WBSCodeSegment__c;
            currItem.BRAND_QUALITY_NAME                     = 'Canadian Club RTD' ;//currCampaign.Brand_Quality__r.Name;
            currItem.CAMPAIGN_NAME                          = currCampaign.Name;
            currItem.COUNTRY_CODE                           = currCampaign.ParentMarketingPlan__r.Country__c.left(2);
            currItem.YEAR                                   = '2019'; //currCampaign.ParentMarketingPlan__r.Year__c;
            currItem.SAP_COMPANY_CODE                       = currCampaign.ParentMarketingPlan__r.SAP_Company_Code__c;
            currItem.SAP_CONTROLLING_AREA                   = currCampaign.ParentMarketingPlan__r.SAP_Controlling_Area__c;
            currItem.CAMPAIGN_TYPE                          = currCampaign.CampaignType__c;
            currItem.COUNTRY_DESCRIPTION                    = currCampaign.ParentMarketingPlan__r.Country__c;
            currItem.BQSS                                   = 'DVGARXXBN'; //   currCampaign.Brand_Quality__r.BQSS__c;
            currItem.FORECASTED_CAMPAIGN_BUDGET             = '1000'; //String.valueOf(currCampaign.ForecastedCampaignSpend__c.setScale(2, RoundingMode.HALF_UP));
            currItem.FORECASTED_CAMPAIGN_BUDGET_CURRENCY    = 'AUD'; //currCampaign.CurrencyIsoCode;
            currItem.CAMPAIGN_BUDGET                        = String.valueOf(currCampaign.PlannedCampaignSpend__c.setScale(2, RoundingMode.HALF_UP));
            currItem.CAMPAIGN_BUDGET_CURRENCY               = 'AUD'; //currCampaign.CurrencyIsoCode;
            currItem.CAMPAIGN_BRAND                         = 'Canadian Club'; //currCampaign.ParentMarketingPlan__r.Brand__r.Name;
            currItem.GL_CODE                                = '15352'; //currCampaign.GLCode__c;
            currItem.GL_ACCOUNT_TYPE                        = currCampaign.GLAccountType__c;
            currItem.REGION                                 = currCampaign.Region__c;
            currItem.DIVISION                               = currCampaign.Division__c;
            currItem.TERRITORY                              = currCampaign.Territory__c;
            currItem.PROGRAM                                = currCampaign.Related_Priority__r.SAP_Code__c;
            currItem.PLATFORM                               = currCampaign.Platform__r.SAP_Code__c;
            */
            
            currItem.WBS_ID                                 = currCampaign.WBSCode__c;
            currItem.BRAND_NAME                             = currCampaign.ParentMarketingPlan__r.Brand__r.Name;
            currItem.BRAND_CODE                             = currCampaign.ParentMarketingPlan__r.Brand__r.WBSCodeSegment__c;
            currItem.BRAND_BUDGET                           = String.valueOf(brandBudgetMap.get(campaignBrandMap.get(currCampaign.Id)).setScale(2, RoundingMode.HALF_UP));
            currItem.BRAND_BUDGET_CURRENCY                  = currCampaign.CurrencyIsoCode;//String.valueOf(brandCurrencyCodeMap.get(campaignBrandMap.get(currCampaign.Id)));
            currItem.BRAND_QUALITY_CODE                     = currCampaign.Brand_Quality__r.WBSCodeSegment__c;
            currItem.BRAND_QUALITY_NAME                     = currCampaign.Brand_Quality__r.Name;
            currItem.CAMPAIGN_NAME                          = currCampaign.Name;
            currItem.COUNTRY_CODE                           = currCampaign.ParentMarketingPlan__r.Country__c.left(2);
            currItem.YEAR                                   = currCampaign.ParentMarketingPlan__r.Year__c;
            currItem.SAP_COMPANY_CODE                       = currCampaign.ParentMarketingPlan__r.SAP_Company_Code__c;
            currItem.SAP_CONTROLLING_AREA                   = currCampaign.ParentMarketingPlan__r.SAP_Controlling_Area__c;
            currItem.CAMPAIGN_TYPE                          = currCampaign.CampaignType__c;
            currItem.COUNTRY_DESCRIPTION                    = currCampaign.ParentMarketingPlan__r.Country__c;
            currItem.BQSS                                   = currCampaign.Brand_Quality__r.BQSS__c;
            currItem.FORECASTED_CAMPAIGN_BUDGET             = String.valueOf(currCampaign.ForecastedCampaignSpend__c.setScale(2, RoundingMode.HALF_UP));
            currItem.FORECASTED_CAMPAIGN_BUDGET_CURRENCY    = currCampaign.CurrencyIsoCode;
            currItem.CAMPAIGN_BUDGET                        = String.valueOf(currCampaign.PlannedCampaignSpend__c.setScale(2, RoundingMode.HALF_UP));
            currItem.CAMPAIGN_BUDGET_CURRENCY               = currCampaign.CurrencyIsoCode;
            currItem.CAMPAIGN_BRAND                         = currCampaign.ParentMarketingPlan__r.Brand__r.Name;
            currItem.GL_CODE                                = currCampaign.GLCode__c;
            currItem.GL_ACCOUNT_TYPE                        = currCampaign.GLAccountType__c;
            currItem.REGION                                 = currCampaign.Region__c;
            currItem.DIVISION                               = currCampaign.Division__c;
            currItem.TERRITORY                              = currCampaign.Territory__c;
            currItem.PROGRAM                                = currCampaign.Related_Priority__r.SAP_Code__c;
            currItem.PLATFORM                               = currCampaign.Platform__r.SAP_Code__c;
            System.debug(LoggingLevel.INFO, 'Current Item: ' + currItem);
            itemsList.add(currItem);
        }
        System.debug('itemsList:::'+itemsList);
        return itemsList;
    }

    /*
    * Helper method for the callout process.
    * Takes a set of Campaign Ids and a List of BGSW WBS Result elements.
    * WBS Result elements contain a WBS Id and a creation status:
    *   If Created=='TRUE', the WBS Element was created successfully and the correlated campaign's Request Status is updated to 'WBS Created'
    *   If Created=='FALSE', the WBS Element was not created successfully and the correlated campaign's Request Status is updated to 'WBS Rejected'
    * Uses DML to update the original campaigns with the new statuses 
    */
    public static void recordWBSResults(Set<Id> campaignIds, List<BGSW_WBS_v2.Result_element> results){
        //System.debug('inside recordWBSResults:::');
        for(BGSW_WBS_v2.Result_element result: results){
            //System.debug('inside recordWBSResults:::for');
            //System.debug(LoggingLevel.INFO, result.response);
            //System.debug(LoggingLevel.INFO, result.id);
            //System.debug(LoggingLevel.INFO, result.created);
        }
        List<Campaign__c> transmittedCampaigns = [SELECT Id, WBSCode__c, RequestStatus__c FROM Campaign__c WHERE Id IN: campaignIds];
        Map<String, BGSW_WBS_v2.Result_element> wbsResultMap = new Map<String, BGSW_WBS_v2.Result_element>();
        for(BGSW_WBS_v2.Result_element result: results){
            wbsResultMap.put(result.id, result);
        }
        for(Campaign__c campaign: transmittedCampaigns){
            try{
                if(campaign.RequestStatus__c == null || !campaign.RequestStatus__c.equals('WBS Created')){
                    if((wbsResultMap.get(campaign.WBSCode__c).Created).equalsIgnoreCase('TRUE')){
                        System.debug('inside if::');
                        campaign.RequestStatus__c = 'WBS Created';
                    } else {
                        System.debug('inside else::::');
                        campaign.RequestStatus__c = 'WBS Rejected';
                    }
                    if(String.isEmpty(wbsResultMap.get(campaign.WBSCode__c).response))
                        wbsResultMap.get(campaign.WBSCode__c).response = '';
                    campaign.Request_Status_Message__c = wbsResultMap.get(campaign.WBSCode__c).response.left(EXT_BI_CampaignHelper.REQUEST_STATUS_MSG_TEXT_CHAR_LIMIT);
                }
            } catch(Exception e){
                System.debug(LoggingLevel.INFO, e.getMessage());
                campaign.RequestStatus__c = 'WBS Rejected';
                if(wbsResultMap.containsKey(campaign.WBSCode__c)){
                    campaign.Request_Status_Message__c = wbsResultMap.get(campaign.WBSCode__c).response.left(EXT_BI_CampaignHelper.REQUEST_STATUS_MSG_TEXT_CHAR_LIMIT);
                }
            }
        }
        update transmittedCampaigns;
    }

    /*
    * Callout method which takes in a set of Campaign Ids, generates a list of WBS_Elements, and transmits them to the SAP endpoint
    * Because there is a callout made, the method must be marked @future with callout=true
    * Callout requires parameters:
    *   Authorization: Basic + Base64Encoded(Username:Password)
    *   Content-Type: text/xml
    */
    @future (callout=true)
    public static void makeCallout(Set<Id> transmittedCampaignIds){
        System.debug('inside makeCallout:::');
        StoredCredentials__c sapCredentials;
        if(Global_Utility.isProd()){
           sapCredentials = StoredCredentials__c.getInstance('SAP Credentials'); 
        }
        else{
        	sapCredentials = StoredCredentials__c.getInstance('SAP Credentials QA');
        }    
        Blob headerValue = Blob.valueOf(sapCredentials.Username__c+':'+sapCredentials.Password__c);
        String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue);
        System.debug('headerValue::'+headerValue+'authorizationHeader::'+authorizationHeader+'sapCredentials::'+sapCredentials);
        system.debug('transmittedCampaignIds: ' + transmittedCampaignIds);
        List<BGSW_WBS_v2.Items_element> items = generateCalloutParamElements(transmittedCampaignIds);
        BGSW_WBS_v2 bgsw = new BGSW_WBS_v2();
        Map<String, String> headers = new Map<String, String>{
            'Authorization' => authorizationHeader,
            'Content-Type' => 'text/xml'
        };
        BGSW_WBS_v2.HTTPS_Port https = new BGSW_WBS_v2.HTTPS_Port();
        https.assignHeaders(headers);
        List<BGSW_WBS_v2.Result_element> response = new List<BGSW_WBS_v2.Result_element>();
        try{
            
            response = https.BWS_Out(items);
            System.debug('response after calling::'+response);
        } catch(Exception e){
            List<Campaign__c> errorCampaigns = new List<Campaign__c>();
            for(Id cId: transmittedCampaignIds){
                Campaign__c temp = new Campaign__c(Id=cId);
                temp.RequestStatus__c = 'WBS Rejected';
                temp.Request_Status_Message__c = 'The server could not be reached, callout was rejected.';
                errorCampaigns.add(temp);
            }
            update errorCampaigns;
        }
        recordWBSResults(transmittedCampaignIds, response);
    }
}