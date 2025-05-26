@isTest
private class BI_WBSCalloutUtilityTests
{
    @testSetup
    static void setup()
    {
        list<StoredCredentials__c> sc_lst = new list<StoredCredentials__c>();
        StoredCredentials__c sc_qa = new StoredCredentials__c(Name = 'SAP Credentials QA', Username__c = 'TestUser', Password__c = 'TestPassword', Full_Endpoint__c = 'https://intq.beamsuntory.com:44371');
        StoredCredentials__c sc_prod = new StoredCredentials__c(Name = 'SAP Credentials', Username__c = 'TestUser', Password__c = 'TestPassword', Full_Endpoint__c = 'https://int.beamsuntory.com:44371');
        sc_lst.add(sc_qa);
        sc_lst.add(sc_prod);
        insert sc_lst;
        TestDataFactory.createBIRunningUserWithCurrencyCode('AUD', 'System Administrator');
        TestDataFactory.createWBSAUSMarketingPlanHierarchy();
        Map<String, Id> tagsMap = TestDataFactory.GetTagsMap();
        List<String> planNames = new List<String>();
        planNames.add('2017 AUS CCL Australian CCL BTL NSW $5K'); 
        Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
        MarketingPlan__c plan1 = plans.get('2017 AUS CCL Australian CCL BTL NSW $5K');

        plan1.Next_IO_Sequence__c = null;
        plan1.SAP_Controlling_Area__c = '2000';
        plan1.SAP_Company_Code__c = 'US30';
        plan1.SAP_Cost_Center__c = 'US30NA33';
        update plan1;

        Id platformRecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Platform').getRecordTypeId();
        Program__c testProgram = new Program__c();
        testProgram.Name = 'Other';
        testProgram.RecordTypeId = platformRecordTypeId;

        Id programRecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Focus Calendar National Priority').getRecordTypeId();
        Program__c testProgram2 = new Program__c();
        testProgram2.Name = 'Other';
        testProgram2.RecordTypeId = programRecordTypeId;
        testProgram2.FocusType__c = 'Current Program';

        insert new List<Program__c>{testProgram, testProgram2};

        Campaign__c camp1 = TestDataFactory.MapCampaign(plan1.Id, 3000.00, date.newinstance(2017, 1, 5), date.newinstance(2017, 1, 27), 'AUD', tagsMap.get('BQ_Canadian Club'));
        camp1.Related_Priority__c = testProgram2.Id;
        Campaign__c camp2 = TestDataFactory.MapCampaign(plan1.Id, 2000.00, date.newinstance(2017, 1, 5), date.newinstance(2017, 1, 27), 'AUD', tagsMap.get('BQ_Canadian Club'));
        camp2.Related_Priority__c = testProgram2.Id;
        insert new List<Campaign__c>{camp1, camp2};
    }

    private static User getAdminUser()
    {
        return [SELECT Id, CurrencyIsoCode, Profile.Name FROM User WHERE Username = 'BI_TestUser@test.com'];
    }

    private static Campaign__c getCampaign()
    {
        return [SELECT Id, Brand_Quality__c FROM Campaign__c LIMIT 1];
    }

    private static List<Campaign__c> getCampaigns()
    {
        return [SELECT Id, Brand_Quality__c FROM Campaign__c];
    }

    private static MarketingPlan__c getPlan()
    {
        return [SELECT Id, Brand__c FROM MarketingPlan__c WHERE Next_IO_Sequence__c = null AND SAP_Controlling_Area__c = '2000' LIMIT 1];
    }

    static testmethod void testGenerateCalloutParamsSuccessful()
    {
        User BI_AUS_Admin = getAdminUser();
        System.runAs(BI_AUS_Admin)
        {
            Campaign__c camp1 = getCampaign();
            MarketingPlan__c plan1 = getPlan();
            List<BGSW_WBS_v2.Items_element> generatedElements = BI_WBSCalloutUtility.generateCalloutParamElements(new Set<Id>{camp1.Id});
            System.assertEquals(1, generatedElements.size(), 'Exactly one WBS_Element should have been generated');
            BGSW_WBS_v2.Items_element element = generatedElements[0];

            Campaign__c requeriedCampaign = [SELECT Id, Name, WBSCode__c, Country__c, SAP_Company_Code__c, SAP_Controlling_Area__c, GLCode__c, 
                                                    GLAccountType__c, Program__c, PlannedCampaignSpend__c, ForecastedCampaignSpend__c, CampaignType__c, 
                                                    ParentMarketingPlan__r.Brand__r.Name FROM Campaign__c WHERE Id =: camp1.Id];
            MarketingPlan__c level3MarketingPlan = [SELECT Id, Name, Year__c, MP_Level__c, Budget__c, CurrencyIsoCode, Brand__c, Country__c, 
                                                            Region__c, Division__c, Territory__r.Name FROM MarketingPlan__c WHERE MP_Level__c='3' AND Brand__c =: plan1.Brand__c LIMIT 1];
            Tags__c brandQuality = [SELECT Id, Name, WBSCodeSegment__c FROM Tags__c WHERE Id =: camp1.Brand_Quality__c];
            Tags__c brand = [SELECT Id, Name, WBSCodeSegment__c FROM Tags__c WHERE Id =: plan1.Brand__c];

            System.assertEquals(String.valueOf((level3MarketingPlan.Budget__c).setScale(2)), element.BRAND_BUDGET, 'The brand budget value should match the level 3 Marketing Plan budget');
            System.assertEquals(brand.Name, element.BRAND_NAME, 'The brand name should match the Marketing Plan brand');
            System.assertEquals(brand.WBSCodeSegment__c, element.BRAND_CODE, 'The brand code segment for Canadian Club should be "CCLB"');
            System.assertEquals(brandQuality.Name, element.BRAND_QUALITY_NAME, 'The brand quality name should match the Campaign brand quality');
            System.assertEquals(brandQuality.WBSCodeSegment__c, element.BRAND_QUALITY_CODE, 'The brand quality code segment for Canadian Club should be "CCL"');
            System.assertEquals(requeriedCampaign.ParentMarketingPlan__r.Brand__r.Name, element.CAMPAIGN_BRAND, 'The campaign brand name should match the level 3 Marketing Plan Brand Name');
            System.assertEquals(String.valueOf((requeriedCampaign.PlannedCampaignSpend__c).setScale(2)), element.CAMPAIGN_BUDGET, '');
            System.assertEquals(requeriedCampaign.Name, element.CAMPAIGN_NAME, '');
            System.assertEquals(requeriedCampaign.CampaignType__c, element.CAMPAIGN_TYPE, '');
            System.assertEquals((requeriedCampaign.Country__c).left(2), element.COUNTRY_CODE, '');
            System.assertEquals(String.valueOf((requeriedCampaign.ForecastedCampaignSpend__c).setScale(2)), element.FORECASTED_CAMPAIGN_BUDGET, '');
            System.assertEquals(requeriedCampaign.GLAccountType__c, element.GL_ACCOUNT_TYPE, 'The brand quality code segment for Canadian Club should be "CCL"');
            System.assertEquals(requeriedCampaign.GLCode__c, element.GL_CODE, 'The brand quality code segment for Canadian Club should be "CCL"');
            System.assertEquals(requeriedCampaign.Program__c, element.PROGRAM, 'The brand quality code segment for Canadian Club should be "CCL"');
            System.assertEquals(requeriedCampaign.SAP_Company_Code__c, element.SAP_COMPANY_CODE, 'The brand quality code segment for Canadian Club should be "CCL"');
            System.assertEquals(requeriedCampaign.SAP_Controlling_Area__c, element.SAP_CONTROLLING_AREA, 'The brand quality code segment for Canadian Club should be "CCL"');
            System.assertEquals(requeriedCampaign.WBSCode__c, element.WBS_ID, 'The brand quality code segment for Canadian Club should be "CCL"');
        }
    }

    static testmethod void testGenerateCalloutParamsNoCampaign()
    {
        User BI_AUS_Admin = getAdminUser();
        System.runAs(BI_AUS_Admin)
        {
            Campaign__c camp1 = getCampaign();
            Id campaignId = camp1.Id;

            delete camp1;

            List<BGSW_WBS_v2.Items_element> generatedElements = BI_WBSCalloutUtility.generateCalloutParamElements(new Set<Id>{campaignId});
        }
    }

    static testmethod void testRecordWBSResults()
    {
        User BI_AUS_Admin = getAdminUser();
        System.runAs(BI_AUS_Admin)
        {
            List<Campaign__c> campaigns = getCampaigns();
            Campaign__c camp1 = campaigns[0];
            Campaign__c camp2 = campaigns[1];

            BI_CampaignIntegrationLogic.generateWBSCodes(new Set<Id>{camp1.Id, camp2.Id});
            camp1 = [SELECT Id, WBSCode__c, RequestStatus__c FROM Campaign__c WHERE Id =: camp1.Id];
            camp2 = [SELECT Id, WBSCode__c, RequestStatus__c FROM Campaign__c WHERE Id =: camp2.Id];

            System.assertEquals('WBS Pending', camp1.RequestStatus__c, 'Request Status should be WBS Pending after generating WBS Code');
            System.assertEquals('WBS Pending', camp2.RequestStatus__c, 'Request Status should be WBS Pending after generating WBS Code');

            BGSW_WBS_v2.Result_element result1 = new BGSW_WBS_v2.Result_element();
            result1.ID=camp1.WBSCode__c;
            result1.Created='TRUE';

            BGSW_WBS_v2.Result_element result2 = new BGSW_WBS_v2.Result_element();
            result2.ID=camp2.WBSCode__c;
            result2.Created='FALSE';

            BI_WBSCalloutUtility.recordWBSResults(new Set<Id>{camp1.Id}, new List<BGSW_WBS_v2.Result_element>{result1});
            BI_WBSCalloutUtility.recordWBSResults(new Set<Id>{camp2.Id}, new List<BGSW_WBS_v2.Result_element>{result2});

            camp1 = [SELECT Id, WBSCode__c, RequestStatus__c FROM Campaign__c WHERE Id =: camp1.Id];
            camp2 = [SELECT Id, WBSCode__c, RequestStatus__c FROM Campaign__c WHERE Id =: camp2.Id];

            System.assertEquals('WBS Created', camp1.RequestStatus__c, 'Campaign 1 should be set to "WBS Created"');
            System.assertEquals('WBS Rejected', camp2.RequestStatus__c, 'Campaign 2 should be set to "WBS Rejected"');
        }
    }

    static testmethod void testMakeCalloutWBS()
    {
        User BI_AUS_Admin = getAdminUser();
        System.runAs(BI_AUS_Admin)
        {
            Campaign__c camp1 = getCampaign();

            BI_CampaignIntegrationLogic.generateWBSCodes(new Set<Id>{camp1.Id});
            camp1 = [SELECT Id, WBSCode__c FROM Campaign__c WHERE Id =: camp1.Id];
    
            BGSW_WBS_HttpCalloutMock mocks = new BGSW_WBS_HttpCalloutMock(camp1.WBSCode__c, 'TRUE', 'WBS was created successfully');
            Test.startTest();
            Test.setMock(WebServiceMock.Class, mocks);
            BI_WBSCalloutUtility.makeCallout(new Set<Id>{camp1.Id});
            Test.stopTest();
        }
    }
}