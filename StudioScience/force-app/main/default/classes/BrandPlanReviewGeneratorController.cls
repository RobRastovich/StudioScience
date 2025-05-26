public with sharing class BrandPlanReviewGeneratorController{
    public transient Map<String, Map<String, Map<String, List<Campaign__c>>>> mpNameMap {get;set;}
    public transient Map<String, Decimal> mpSubtotalMap {get;set;}
    public transient Map<String, Decimal> accSubtotalMap {get;set;}
    public transient Map<String, Map<String, Map<String, Decimal>>> subtotalMap {get;set;}
    public transient Decimal totalForecastedCampaignSpend {get;set;}
    public transient Map<String, Map<String, Decimal>> accFbsRtdSubtotalMap {get;set;}
    public MarketingPlan__c currMarketingPlan {get;set;}

    public BrandPlanReviewGeneratorController(ApexPages.StandardController con) {
        Id mpId = con.getId();
        currMarketingPlan = [SELECT Id, Name, CurrencyIsoCode, Region__c, Brand__r.Name, Budget__c FROM MarketingPlan__c WHERE Id =: mpId];
        extractCampaignDetails(currMarketingPlan.Id);
    }

    public Set<Id> retrieveChildCampaigns(Id level3mp){
        totalForecastedCampaignSpend = 0.00;
        Map<Id, Campaign__c> childCampaigns = new Map<Id, Campaign__c>([SELECT Id, ForecastedCampaignSpend__c FROM Campaign__c WHERE
                                                ParentMarketingPlan__c =: level3mp OR
                                                ParentMarketingPlan__r.ParentMarketingPlan__c =: level3mp OR
                                                ParentMarketingPlan__r.ParentMarketingPlan__r.ParentMarketingPlan__c =: level3mp OR
                                                ParentMarketingPlan__r.ParentMarketingPlan__r.ParentMarketingPlan__r.ParentMarketingPlan__c =: level3mp OR
                                                ParentMarketingPlan__r.ParentMarketingPlan__r.ParentMarketingPlan__r.ParentMarketingPlan__r.ParentMarketingPlan__c =: level3mp]);
        for(Campaign__c c: childCampaigns.values()){
            totalForecastedCampaignSpend += c.ForecastedCampaignSpend__c;
        }
        totalForecastedCampaignSpend = totalForecastedCampaignSpend.setScale(2);
        return childCampaigns.keySet();

    }

    public void extractCampaignDetails(Id level3mp){
        /*
            MP Name                                                     Total
            |________Account Name                                       Total
                     |______________RTD/FBS                             Total
                                    |________Campaign Name____Budget    Total
        */
        mpNameMap = new Map<String, Map<String, Map<String, List<Campaign__c>>>>();

        List<Campaign__c> childCampaigns = [SELECT Id, Name, PlannedCampaignSpend__C, FBS_RTD__c, NationalAccount__r.Name, ParentMarketingPlan__r.Name
                                            FROM Campaign__c
                                            WHERE Id IN: retrieveChildCampaigns(level3mp)];
        for(Campaign__c c: childCampaigns){
            String mpName = c.ParentMarketingPlan__r.Name == null ? 'None' : c.ParentMarketingPlan__r.Name;
            
            Map<String, List<Campaign__c>> fbsRtdMap;

            if(!mpNameMap.containsKey(mpName)){
                mpNameMap.put(mpName, new Map<String, Map<String, List<Campaign__c>>>());
            }

            String accName = c.NationalAccount__r.Name == null ? 'None' : c.NationalAccount__r.Name;
            if(!mpNameMap.get(mpName).containsKey(accName)){
                mpNameMap.get(mpName).put(accName, new Map<String, List<Campaign__c>>());
            }

            fbsRtdMap = mpNameMap.get(mpName).get(accName);
            String fbsRtdKey = c.FBS_RTD__c == null ? 'None' : c.FBS_RTD__c;
            if(!fbsRtdMap.containsKey(fbsRtdKey)){
                fbsRtdMap.put(fbsRtdKey, new List<Campaign__c>{});
            }

            if(fbsRtdMap.containsKey(fbsRtdKey)){
                fbsRtdMap.get(fbsRtdKey).add(c);
            }
        }

        mpSubtotalMap = new Map<String, Decimal>();
        accSubtotalMap = new Map<String, Decimal>();
        accFbsRtdSubtotalMap = new Map<String, Map<String, Decimal>>();
        subtotalMap = new Map<String, Map<String, Map<String, Decimal>>>();
        for(String mpKey: mpNameMap.keySet()){
            if(!subtotalMap.containsKey(mpKey)){
                subtotalMap.put(mpKey, new Map<String, Map<String, Decimal>>());
                subtotalMap.get(mpKey).put('ACCOUNT', new Map<String, Decimal>());
            }
            Decimal mpTotal = 0;
            for(String accKey: mpNameMap.get(mpKey).keySet()){
                if(!subtotalMap.get(mpKey).containsKey(accKey+'FBS_RTD')){
                    subtotalMap.get(mpKey).put(accKey+'FBS_RTD', new Map<String, Decimal>());                
                }
                Decimal accTotal = 0;
                for(String fbsRtdKey: mpNameMap.get(mpKey).get(accKey).keySet()){
                    Decimal fbsRtdTotal = 0;
                    if(!accFbsRtdSubtotalMap.containsKey(accKey)){
                        accFbsRtdSubtotalMap.put(accKey, new Map<String, Decimal>());
                    }
                    for(Campaign__c c: mpNameMap.get(mpKey).get(accKey).get(fbsRtdKey)){
                        fbsRtdTotal += c.PlannedCampaignSpend__c;
                    }
                    accTotal += fbsRtdTotal;
                    accFbsRtdSubtotalMap.get(accKey).put(fbsRtdKey, fbsRtdTotal);
                    subtotalMap.get(mpKey).get(accKey+'FBS_RTD').put(fbsRtdKey, fbsRtdTotal);
                }
                mpTotal += accTotal;
                accSubtotalMap.put(accKey, accTotal);
                subtotalMap.get(mpKey).get('ACCOUNT').put(accKey, accTotal);
            }
            mpSubtotalMap.put(mpKey, mpTotal);
            System.debug(LoggingLevel.INFO, subtotalMap);
        }
    }
}