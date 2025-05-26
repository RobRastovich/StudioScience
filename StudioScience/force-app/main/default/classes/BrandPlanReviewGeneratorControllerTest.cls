@isTest
private class BrandPlanReviewGeneratorControllerTest {
    @testSetup static void setup() {

        Id platformRecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Platform').getRecordTypeId();
        Program__c testProgram = new Program__c();
        testProgram.Name = 'Other';
        testProgram.RecordTypeId = platformRecordTypeId;

        Id programRecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Focus Calendar National Priority').getRecordTypeId();
        Program__c testProgram2 = new Program__c();
        testProgram2.Name = 'Other';
        testProgram2.FocusType__c = 'Current Program';
        testProgram2.RecordTypeId = programRecordTypeId;

        insert new List<Program__c>{testProgram, testProgram2};
        User BI_AUS_Admin = TestDataFactory.createBIRunningUserWithCurrencyCode('AUD', 'System Administrator');
        System.runAs(BI_AUS_Admin){
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
            camp1.Related_Priority__c = testProgram2.Id;
            insert camp1;
    
            set<Id> campaignIds = new set<Id>();
            campaignIds.add(camp1.Id);
            try {                    
                Test.startTest();
                
                //Send campaigns to logic
                List<CampaignWBSResult> results = BI_CampaignIntegrationLogic.generateWBSCodes(campaignIds);
        
                system.assertEquals(results.size(), 1, 'Should have received 1 Campaign WBS result.');   
                system.assertEquals(results.get(0).IsSuccess, true, 'WBS should have been successful');
                system.assertEquals(results.get(0).Campaign.WBSCode__c, 'AU17CCLAUSNSW001', 'Expected IO code AU17CCLAUSNSW001');
                system.assertEquals(results.get(0).Campaign.RequestStatus__c, 'WBS Pending', 'Status should be WBS Pending');
        
                Test.stopTest();                                                                                
            }
            catch (Exception e) {
                //If caught exception, ensure it is the Duplicate message.
                System.debug(LoggingLevel.INFO,'Exception: ' + e.getMessage());
                System.assert(false, 'There was an issue with WBS tests.');         
            }           
        }
    }

    static testmethod void testAssertSetup(){
        System.assertNotEquals(0, [SELECT COUNT() FROM Campaign__c]);
        System.assertNotEquals(0, [SELECT COUNT() FROM MarketingPlan__c]);
    }

    static testmethod void testRetrieveChildCampaigns(){
        PageReference pageRef = Page.BrandPlanReviewGenerator;
        Test.setCurrentPage(pageRef);
        Campaign__c testCampaign = [SELECT Id, ParentMarketingPlan__c FROM Campaign__c LIMIT 1];
        MarketingPlan__c mp = [SELECT Id FROM MarketingPlan__c WHERE Id =: testCampaign.ParentMarketingPlan__c LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(mp);
        BrandPlanReviewGeneratorController bpCon = new BrandPlanReviewGeneratorController(sc);      
        Set<Id> retrievedCampaignIdSet = bpCon.retrieveChildCampaigns(mp.Id);
        List<Campaign__c> retrievedCampaigns = [SELECT Id FROM Campaign__c WHERE ParentMarketingPlan__c =: mp.Id];
        System.assertEquals(true, retrievedCampaignIdSet.contains(testCampaign.Id));
        for(Campaign__c c: retrievedCampaigns){
            System.assertEquals(true, retrievedCampaignIdSet.contains(c.Id));
        }
    }

    static testmethod void testExtractCampaignDetails(){
        PageReference pageRef = Page.BrandPlanReviewGenerator;
        Test.setCurrentPage(pageRef);
        Campaign__c testCampaign = [SELECT Id, ParentMarketingPlan__c FROM Campaign__c LIMIT 1];
        MarketingPlan__c mp = [SELECT Id FROM MarketingPlan__c WHERE Id =: testCampaign.ParentMarketingPlan__c LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(mp);
        BrandPlanReviewGeneratorController bpCon = new BrandPlanReviewGeneratorController(sc);      
        bpCon.extractCampaignDetails(mp.Id);
    }   
}