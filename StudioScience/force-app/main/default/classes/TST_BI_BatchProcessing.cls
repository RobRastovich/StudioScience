@isTest
public class TST_BI_BatchProcessing {
    
    public static Integer currentYear = System.Today().year();
    
    @testSetup static void setup() {
        list<StoredCredentials__c> sc_lst = new list<StoredCredentials__c>();
        StoredCredentials__c sc_qa = new StoredCredentials__c(Name = 'SAP Credentials QA', Username__c = 'TestUser', Password__c = 'TestPassword', Full_Endpoint__c = 'https://intq.beamsuntory.com:44371');
        StoredCredentials__c sc_prod = new StoredCredentials__c(Name = 'SAP Credentials', Username__c = 'TestUser', Password__c = 'TestPassword', Full_Endpoint__c = 'https://int.beamsuntory.com:44371');
        sc_lst.add(sc_qa);
        sc_lst.add(sc_prod);
        insert sc_lst;
        Id platformRecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Platform').getRecordTypeId();
        Program__c testProgram = new Program__c();
        testProgram.Name = 'Other';
        testProgram.RecordTypeId = platformRecordTypeId;

        Id programRecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Focus Calendar National Priority').getRecordTypeId();
        Program__c testProgram2 = new Program__c();
        testProgram2.Name = 'Other';
        testProgram2.RecordTypeId = programRecordTypeId;
        testProgram2.FocusType__c = '2018 Program';

        insert new List<Program__c>{testProgram, testProgram2};
    }
    
    static Program__c getOtherProgram()
    {
        Id programRecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Focus Calendar National Priority').getRecordTypeId();
        System.debug([SELECT Id FROM Program__c WHERE Name = 'Other' AND RecordTypeId =: programRecordTypeId]);
        return [SELECT Id FROM Program__c WHERE Name = 'Other' AND RecordTypeId =: programRecordTypeId ];      
    }
    
    static Campaign__c createCampaignForIO()
    {
        TestDataFactory.createMarketingPlanHierarchy();
        Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();
        List<String> planNames = new List<String>();
        planNames.add('2018 US JBW American AMR SDP Heritage Arkansas $5K'); 
        planNames.add('2018 US JBW American AMR SDP Heritage Louisana $15K'); 
        planNames.add('2018 US JBW American AMR SDP Legacy Missouri $20K'); 
    
        Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
        MarketingPlan__c plan1 = plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K');
        MarketingPlan__c plan2 = plans.get('2018 US JBW American AMR SDP Heritage Louisana $15K');
        MarketingPlan__c plan3 = plans.get('2018 US JBW American AMR SDP Legacy Missouri $20K');
    
        plan1.Next_IO_Sequence__c = null;
        plan1.SAP_Controlling_Area__c = '2000';
        plan1.SAP_Company_Code__c = 'US30';
        plan1.SAP_Cost_Center__c = 'US30NA33';      
        update plan1;
        Campaign__c camp1 = TestDataFactory.MapCampaign(plan1.Id, 3000.00, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 1, 27), 'USD', tagsMap.get('BQ_Jim Beam White'));
        camp1.Related_Priority__c = getOtherProgram().Id;
        camp1.RequestStatus__c = 'IO Rejected';
        insert camp1;
        return camp1;
    }
    
    static Campaign__c createCampaignForWBS()
    {
        TestDataFactory.createWBSAUSMarketingPlanHierarchy();
        Map<String, Id> tagsMap = TestDataFactory.GetTagsMap();
        List<String> planNames = new List<String>();
        planNames.add('2017 AUS CCL Australian CCL BTL NSW $5K'); 
        Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
        MarketingPlan__c plan1 = plans.get('2017 AUS CCL Australian CCL BTL NSW $5K');

        //Plan1 will not have a Next Sequence Number set yet.
        plan1.Next_IO_Sequence__c = null;
        plan1.SAP_Controlling_Area__c = '2000';
        plan1.SAP_Company_Code__c = 'US30';
        plan1.SAP_Cost_Center__c = 'US30NA33';
        update plan1;
        System.debug(LoggingLevel.INFO, plan1);

        //Create the campaigns
        Campaign__c camp1 = TestDataFactory.MapCampaign(plan1.Id, 3000.00, date.newinstance(2017, 1, 5), date.newinstance(2017, 1, 27), 'AUD', tagsMap.get('BQ_Canadian Club'));
        System.debug(LoggingLevel.INFO, camp1);
        camp1.Related_Priority__c = getOtherProgram().Id;
        insert camp1;
        return camp1;
    }
    
    static testMethod void testBIProcessingBatch() 
    {   
        Campaign__c camp1 = createCampaignForIO();
        List<Id> campaignIdList = new List<Id>();
        campaignIdList.add(camp1.id);
        
        Campaign__c camp2 = createCampaignForWBS();
        List<Id> campaignIdList2 = new List<Id>();
        campaignIdList2.add(camp2.id);
        
        UTL_API_Utility.CSRFAuthInfo csrfAuthInfoUS = EXT_BI_CampaignHelper.getUserAuthenticationInfo(UTL_API_Utility.APPNAME_USBI);
		UTL_API_Utility.CSRFAuthInfo csrfAuthInfoAUS = EXT_BI_CampaignHelper.getUserAuthenticationInfo(UTL_API_Utility.APPNAME_AUSBI);        
        Test.startTest();
        BCH_BI_CampaignProcessing obj = new BCH_BI_CampaignProcessing(campaignIdList,csrfAuthInfoUS,UTL_API_Utility.APPNAME_USBI);
        DataBase.executeBatch(obj);
        BCH_BI_CampaignProcessing obj2 = new BCH_BI_CampaignProcessing(campaignIdList2,csrfAuthInfoAUS,UTL_API_Utility.APPNAME_AUSBI);
        DataBase.executeBatch(obj2);
        Test.stopTest();
        Campaign__c cmpUS= [Select id,IOCode__c,RequestStatus__c from Campaign__c where id =:camp1.id];
        Campaign__c cmpAUS= [Select id,WBSCode__c,RequestStatus__c from Campaign__c where id =:camp1.id];
        System.assert(cmpUS.IOCode__c!='');
        System.assert(cmpAUS.WBSCode__c!='');
    }

}