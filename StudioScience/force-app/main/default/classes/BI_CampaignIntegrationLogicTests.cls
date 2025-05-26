@isTest
private class BI_CampaignIntegrationLogicTests {
     static integer currentYear = System.Today().year();
     static string cmpCode = 'YYYYY'+ string.valueof(currentYear).substring(2)+'04002';

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
        testProgram2.FocusType__c = 'Current Program';

        insert new List<Program__c>{testProgram, testProgram2};
    }
    
    static Program__c getOtherProgram()
    {
        Id programRecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Focus Calendar National Priority').getRecordTypeId();
        return [SELECT Id FROM Program__c WHERE Name = 'Other' AND RecordTypeId =: programRecordTypeId];
    }

    static testmethod void testSingleWBS(){
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
            camp1.Related_Priority__c = getOtherProgram().Id;
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

    static testmethod void testSingleIO() {
        User BI_Admin = TestDataFactory.createBIRunningUserWithCurrencyCode('USD', 'System Administrator');
        System.runAs(BI_Admin){
            //Create test data
            TestDataFactory.createMarketingPlanHierarchy();
            Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();
    
            //Get the Marketing Plan(s) that we'll be adding child Campaigns under.
            List<String> planNames = new List<String>();
            planNames.add('2018 US JBW American AMR SDP Heritage Arkansas $5K'); 
            planNames.add('2018 US JBW American AMR SDP Heritage Louisana $15K'); 
            planNames.add('2018 US JBW American AMR SDP Legacy Missouri $20K'); 
    
            Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            MarketingPlan__c plan1 = plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K');
            MarketingPlan__c plan2 = plans.get('2018 US JBW American AMR SDP Heritage Louisana $15K');
            MarketingPlan__c plan3 = plans.get('2018 US JBW American AMR SDP Legacy Missouri $20K');
    
            //Plan1 will not have a Next Sequence Number set yet.
            plan1.Next_IO_Sequence__c = null;
            plan1.SAP_Controlling_Area__c = '2000';
            plan1.SAP_Company_Code__c = 'US30';
            plan1.SAP_Cost_Center__c = 'US30NA33';
    
            update plan1;
            
            //Create the campaigns
            Campaign__c camp1 = TestDataFactory.MapCampaign(plan1.Id, 3000.00, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 1, 27), 'USD', tagsMap.get('BQ_Jim Beam White'));
            camp1.Related_Priority__c = getOtherProgram().Id;
            insert camp1;
    
            set<Id> campaignIds = new set<Id>();
            campaignIds.add(camp1.Id);
            try {                    
                Test.startTest();
                
                //Send campaigns to logic
                List<CampaignIOResult> results = BI_CampaignIntegrationLogic.generateIOCodes(campaignIds);
        
                system.assertEquals(results.size(), 1, 'Should have received 1 Campaign IO result.');    
                system.assertEquals(results.get(0).IsSuccess, true, 'IO should have been successful');

                String code = 'YYYYY'+ string.valueof(currentYear).substring(2)+'04002';
                system.assertEquals(code, cmpCode, 'Expected IO code '+ cmpCode);
                system.assertEquals(results.get(0).Campaign.RequestStatus__c, 'IO Pending', 'Status should be IO Pending');
        
                Test.stopTest();                                                                                
            }
            catch (Exception e) {
                //If caught exception, ensure it is the Duplicate message.
                System.debug(LoggingLevel.INFO,'Exception: ' + e.getMessage());
                System.assert(false, 'There was an issue with IO tests.');      
            }
        }
    }
    
    static testmethod void testMultipleWBS() {
        User BI_AUS_Admin = TestDataFactory.createBIRunningUserWithCurrencyCode('AUD', 'System Administrator');
        System.runAs(BI_AUS_Admin){
            Id otherProgramId = getOtherProgram().Id;
            //Create test data
            TestDataFactory.createWBSAUSMarketingPlanHierarchy();
            Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();
            System.debug(LoggingLevel.INFO,'Inside testMultipleIO');
            //Get the Marketing Plan(s) that we'll be adding child Campaigns under.
            List<String> planNames = new List<String>();
            planNames.add('2017 AUS CCL Australian CCL BTL NSW $5K'); 
            planNames.add('2017 AUS CCL Australian CCL BTL VIC $10K'); 
            //planNames.add('2017 AUS CCL Australian CCL BTL QLD $15K');    
    
            Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            MarketingPlan__c plan1 = plans.get('2017 AUS CCL Australian CCL BTL NSW $5K');
            MarketingPlan__c plan2 = plans.get('2017 AUS CCL Australian CCL BTL VIC $10K');
            //MarketingPlan__c plan3 = plans.get('2017 AUS CCL Australian CCL BTL QLD $15K');
                
            //Plan1 will not have a Next Sequence Number set yet.
            plan1.Next_IO_Sequence__c = null;
            plan1.SAP_Controlling_Area__c = '2000';
            plan1.SAP_Company_Code__c = 'US30';
            plan1.SAP_Cost_Center__c = 'US30NA33';
    
            //Plan2 will have Sequence set already.
            plan2.Next_IO_Sequence__c = 200;
            plan2.SAP_Controlling_Area__c = '2000';
            plan2.SAP_Company_Code__c = 'US30';
            plan2.SAP_Cost_Center__c = 'US30NA33';
    
            List<MarketingPlan__c> updatePlans = new List<MarketingPlan__c> { plan1, plan2 };
            update updatePlans;
    
            List<Campaign__c> camps = new List<Campaign__c>();
            for (Integer i = 0; i < 20; i++) {
                camps.add(TestDataFactory.MapCampaign(plan1.Id, 0.00, date.newinstance(2017, 1, 5), date.newinstance(2017, 1, 27), 'AUD', tagsMap.get('BQ_Canadian Club')));    
            }
            for (Integer i = 0; i < 20; i++) {
                camps.add(TestDataFactory.MapCampaign(plan2.Id, 0.00, date.newinstance(2017, 1, 5), date.newinstance(2017, 1, 27), 'AUD', tagsMap.get('BQ_Canadian Club')));    
            }
            
            for(Campaign__c camp : camps)
            {
                camp.Related_Priority__c = otherProgramId;
            }
    
            insert camps;
    
            set<Id> campaignIds = new set<Id>();
            for (Campaign__c c : camps) {
                campaignIds.add(c.Id);
            }
                                
            Test.startTest();
            
            //Send campaigns to logic
            System.debug(LoggingLevel.INFO,'Calling generateWBSCodes');
            List<CampaignWBSResult> results = BI_CampaignIntegrationLogic.generateWBSCodes(campaignIds);
    
            system.assertEquals(40, results.size(), 'Should have received 40 Campaign WBS result.');
    
            for (CampaignWBSResult cr : results) {
                system.assertEquals(true, cr.IsSuccess, 'WBS should have been successful');
                system.assertEquals(false, String.IsBlank(cr.Campaign.WBSCode__c), 'Expected WBS code to be populated');
                system.assertEquals('WBS Pending', cr.Campaign.RequestStatus__c, 'Status should be WBS Pending');   
            }    
    
            //Assure sequence numbers updated.
            plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            plan1 = plans.get('2017 AUS CCL Australian CCL BTL NSW $5K');
            plan2 = plans.get('2017 AUS CCL Australian CCL BTL VIC $10K');
    
            system.assertEquals(21, plan1.Next_IO_Sequence__c, 'Plan1 should have Next Sequence Number of 21');
            system.assertEquals(220, plan2.Next_IO_Sequence__c, 'Plan2 should have Next Sequence Number of 220');
    
            Test.stopTest();     
        }
    }

    static testmethod void testWBSFailures() {
        User BI_AUS_Admin = TestDataFactory.createBIRunningUserWithCurrencyCode('AUD', 'System Administrator');
        System.runAs(BI_AUS_Admin){
            Id otherProgramId = getOtherProgram().Id;
            //Create test data
            TestDataFactory.createWBSAUSMarketingPlanHierarchy();
            Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();

            //Get the Marketing Plan(s) that we'll be adding child Campaigns under.
            List<String> planNames = new List<String>();
            planNames.add('2017 AUS CCL Australian CCL BTL NSW $5K'); 
    
            Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            MarketingPlan__c plan1 = plans.get('2017 AUS CCL Australian CCL BTL NSW $5K');
    
            plan1.Next_IO_Sequence__c = null;
            plan1.SAP_Controlling_Area__c = '2000';
            plan1.SAP_Company_Code__c = 'US30';
            plan1.SAP_Cost_Center__c = 'US30NA33';      
            update plan1;
    
            //Create the campaigns
            Campaign__c camp1 = TestDataFactory.MapCampaign(plan1.Id, 0.00, date.newinstance(2017, 1, 5), date.newinstance(2017, 1, 27), 'AUD', tagsMap.get('BQ_Canadian Club'));
            camp1.WBSCode__c = 'AU17BADTESTXX001';   
            camp1.Related_Priority__c = otherProgramId;                   
            insert camp1;
    
            set<Id> campaignIds = new set<Id>();
            campaignIds.add(camp1.Id);
                            
            Test.startTest();
                
            //Test 1 - already has an IO
            List<CampaignWBSResult> results = BI_CampaignIntegrationLogic.generateWBSCodes(campaignIds);
            system.assertEquals(results.size(), 1, 'Should have received 1 Campaign WBS result.');   
            system.assertEquals(true, results.get(0).IsSuccess, 'WBS should have failed due to already having an WBS.');
            system.assertEquals(null, results.get(0).Message);
            
            //Test 3 - Duplicate IO. 
            //Initially the MP has a NULL Next Sequence, so our IO Code will be 001. Then reset the sequence back to 1 and create another 
            //campaign.
            results = BI_CampaignIntegrationLogic.generateWBSCodes(campaignIds);    
            system.assertEquals(1, results.size(), 'Should have received 1 Campaign WBS result.');
            system.assertEquals('AU17CCLAUSNSW002', results.get(0).Campaign.WBSCode__c, 'WBS Code should be AU17CCLAUSNSW001');
            camp1.WBSCode__c = 'AU17CCLAUSNSW001';
            update camp1;
            plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            plan1 = plans.get('2017 AUS CCL Australian CCL BTL NSW $5K');
            plan1.Next_IO_Sequence__c = 1;
            update plan1;
            Campaign__c camp2 = TestDataFactory.MapCampaign(plan1.Id, 0.00, date.newinstance(2017, 1, 5), date.newinstance(2017, 1, 27), 'AUD', tagsMap.get('BQ_Canadian Club'));
            camp2.Related_Priority__c = otherProgramId;
            insert camp2;
            results = BI_CampaignIntegrationLogic.generateWBSCodes(new set<Id> { camp2.Id });
            system.assertEquals(1, results.size(), 'Should have received 1 Campaign WBS result.');
            system.assertEquals(false, results.get(0).IsSuccess, 'WBS should have failed due to Duplicate WBS.');
            system.assertEquals(BI_Constants.WBS_DUPLICATE, results.get(0).Message, 'Should receive Duplicate WBS message');
            
            //Test 4 - Year not populated (its a formula field inheriting the MP's year, so we have to invalidate the MP.)
            plan1.Year__c = null;
            plan1.Next_IO_Sequence__c = 2; //go back to valid value
            update plan1;
            results = BI_CampaignIntegrationLogic.generateWBSCodes(new set<Id> { camp2.Id });
            system.assertEquals(1, results.size(), 'Should have received 1 Campaign WBS result.');
            system.assertEquals(false, results.get(0).IsSuccess, 'WBS should have failed due empty Year.');
            system.assertEquals(BI_Constants.WBS_YEAR_MISSING, results.get(0).Message, 'WBS should have failed due empty Year.');
    
            //Test 5 - Controlling Area null 
            plan1.Year__c = '2018'; //go back to valid value
            plan1.SAP_Controlling_Area__c = null;
            plan1.SAP_Company_Code__c = null;
            plan1.SAP_Cost_Center__c = null;
            update plan1;
            results = BI_CampaignIntegrationLogic.generateWBSCodes(new set<Id> { camp2.Id });
            system.assertEquals(1, results.size(), 'Should have received 1 Campaign WBS result.');
            system.assertEquals(false, results.get(0).IsSuccess, 'WBS should have failed due empty Controlling Area.');
            system.assertEquals(BI_Constants.WBS_SAP_CONTROLLINGAREA, results.get(0).Message, 'WBS should have failed due empty Controlling Area.');
    
            //Test 6 - Company Code null
            plan1.SAP_Controlling_Area__c = '2000';//go back to valid value
            update plan1;
            results = BI_CampaignIntegrationLogic.generateWBSCodes(new set<Id> { camp2.Id });
            system.assertEquals(1, results.size(), 'Should have received 1 Campaign WBS result.');
            system.assertEquals(false, results.get(0).IsSuccess, 'WBS should have failed due empty Company Code.');
            system.assertEquals(BI_Constants.WBS_SAP_COMPANYCODE, results.get(0).Message, 'WBS should have failed due empty Company Code.');
    
            //Test 7 - Cost Center null
            plan1.SAP_Company_Code__c = 'US30';//go back to valid value
            plan1.SAP_Cost_Center__c = null;
            update plan1;
            results = BI_CampaignIntegrationLogic.generateWBSCodes(new set<Id> { camp2.Id });
            system.assertEquals(1, results.size(), 'Should have received 1 Campaign WBS result.');
            system.assertEquals(false, results.get(0).IsSuccess, 'WBS should have failed due empty Cost Center.');
            system.assertEquals(BI_Constants.WBS_SAP_COSTCENTER, results.get(0).Message, 'WBS should have failed due empty Cost Center.');
        
            Test.stopTest();
        }
    }   

    static testmethod void testMultipleIO() {
        User BI_Admin = TestDataFactory.createBIRunningUserWithCurrencyCode('USD', 'System Administrator');
        System.runAs(BI_Admin){
            Id otherProgramId = getOtherProgram().Id;
            //Create test data
            TestDataFactory.createMarketingPlanHierarchy();
            Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();
            System.debug(LoggingLevel.INFO,'Inside testMultipleIO');
            //Get the Marketing Plan(s) that we'll be adding child Campaigns under.
            List<String> planNames = new List<String>();
            planNames.add('2018 US JBW American AMR SDP Heritage Arkansas $5K'); 
            planNames.add('2018 US JBW American AMR SDP Heritage Louisana $15K'); 
            planNames.add('2018 US JBW American AMR SDP Legacy Missouri $20K'); 
    
            Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            MarketingPlan__c plan1 = plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K');
            MarketingPlan__c plan2 = plans.get('2018 US JBW American AMR SDP Heritage Louisana $15K');
                
            //Plan1 will not have a Next Sequence Number set yet.
            plan1.Next_IO_Sequence__c = null;
            plan1.SAP_Controlling_Area__c = '2000';
            plan1.SAP_Company_Code__c = 'US30';
            plan1.SAP_Cost_Center__c = 'US30NA33';
    
            //Plan2 will have Sequence set already.
            plan2.Next_IO_Sequence__c = 200;
            plan2.SAP_Controlling_Area__c = '2000';
            plan2.SAP_Company_Code__c = 'US30';
            plan2.SAP_Cost_Center__c = 'US30NA33';
    
            List<MarketingPlan__c> updatePlans = new List<MarketingPlan__c> { plan1, plan2 };
            update updatePlans;
    
            List<Campaign__c> camps = new List<Campaign__c>();
            for (Integer i = 0; i < 20; i++) {
                camps.add(TestDataFactory.MapCampaign(plan1.Id, 0.00, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 1, 27), 'USD', tagsMap.get('BQ_Jim Beam White')));   
            }
            for (Integer i = 0; i < 20; i++) {
                camps.add(TestDataFactory.MapCampaign(plan2.Id, 0.00, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 1, 27), 'USD', tagsMap.get('BQ_Jim Beam White')));   
            }
            
            for(Campaign__c camp : camps)
            {
                camp.Related_Priority__c = otherProgramId;
            }
    
            insert camps;
    
            set<Id> campaignIds = new set<Id>();
            for (Campaign__c c : camps) {
                campaignIds.add(c.Id);
            }
                                
            Test.startTest();
            
            //Send campaigns to logic
            System.debug(LoggingLevel.INFO,'Calling generateIOCodes');
            List<CampaignIOResult> results = BI_CampaignIntegrationLogic.generateIOCodes(campaignIds);
    
            system.assertEquals(40, results.size(), 'Should have received 40 Campaign IO result.');
    
            for (CampaignIOResult cr : results) {
                system.assertEquals(true, cr.IsSuccess, 'IO should have been successful');
                system.assertEquals(false, String.IsBlank(cr.Campaign.IOCode__c), 'Expected IO code to be populated');
                system.assertEquals('IO Pending', cr.Campaign.RequestStatus__c, 'Status should be IO Pending'); 
            }    
    
            //Assure sequence numbers updated.
            plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            plan1 = plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K');
            plan2 = plans.get('2018 US JBW American AMR SDP Heritage Louisana $15K');
    
            system.assertEquals(21, plan1.Next_IO_Sequence__c, 'Plan1 should have Next Sequence Number of 21');
            system.assertEquals(220, plan2.Next_IO_Sequence__c, 'Plan2 should have Next Sequence Number of 220');
    
            Test.stopTest();     
        }
    }
     
    static testmethod void testIOFailures() {
        User BI_Admin = TestDataFactory.createBIRunningUserWithCurrencyCode('USD', 'System Administrator');
        System.runAs(BI_Admin){
            Id otherProgramId = getOtherProgram().Id;
            //Create test data
            TestDataFactory.createMarketingPlanHierarchy();
            Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();
    
            //Get the Marketing Plan(s) that we'll be adding child Campaigns under.
            List<String> planNames = new List<String>();
            planNames.add('2018 US JBW American AMR SDP Heritage Arkansas $5K');    
    
            Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            MarketingPlan__c plan1 = plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K');
            MarketingPlan__c planBadBrandQuality = plans.get('2018 US JBW Southern SOU Western Arizona $20K');
    
            plan1.Next_IO_Sequence__c = null;
            plan1.SAP_Controlling_Area__c = '2000';
            plan1.SAP_Company_Code__c = 'US30';
            plan1.SAP_Cost_Center__c = 'US30NA33';      
            update plan1;
    
            //Create the campaigns
            Campaign__c camp1 = TestDataFactory.MapCampaign(plan1.Id, 0.00, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 1, 27), 'USD', tagsMap.get('BQ_Jim Beam White'));
            camp1.IOCode__c = 'BADTEST12345';
            camp1.Related_Priority__c = otherProgramId;                       
            insert camp1;
    
            set<Id> campaignIds = new set<Id>();
            campaignIds.add(camp1.Id);
                            
            Test.startTest();
                
            //Test 1 - already has an IO
            System.debug(LoggingLevel.INFO,'Test 1 - already has an IO');
            List<CampaignIOResult> results = BI_CampaignIntegrationLogic.generateIOCodes(campaignIds);
            system.assertEquals(results.size(), 1, 'Should have received 1 Campaign IO result.');    
            system.assertEquals(true, results.get(0).IsSuccess, 'IO should have failed due to already having an IO.');
            system.assertEquals(null, results.get(0).Message);
    
            //Test 2 - brandquality is bad, should be 5 chars long.
            System.debug(LoggingLevel.INFO,'Test 2 - brandquality is bad.');
            Tags__c jbw = new Tags__c(Id=tagsMap.get('BQ_Jim Beam White'), IOCodeSegment__c='1234');
            jbw.IOCodeSegment__c = '1234';
            update jbw;
    
            camp1.IOCode__c = '';
            update camp1;
            results = BI_CampaignIntegrationLogic.generateIOCodes(campaignIds);
            system.assertEquals(results.size(), 1, 'Should have received 1 Campaign IO result.');    
            system.assertEquals(false, results.get(0).IsSuccess, 'IO should have failed due to bad BrandQuality.');
            system.assertEquals(BI_Constants.IO_BRANDQUALITY, results.get(0).Message);
            //Put the BrandQuality back to valid.
            jbw.IOCodeSegment__c = 'YYYYY';
            update jbw;
    
            //Test 3 - Territory is bad, should be 2 chars long in IOCodeSegment
            System.debug(LoggingLevel.INFO,'Test 3 - Territory is bad.');
            Tags__c arkansasTerritory = new Tags__c(Id=tagsMap.get('Arkansas'), IOCodeSegment__c='1');
            update arkansasTerritory;
            results = BI_CampaignIntegrationLogic.generateIOCodes(campaignIds);
            system.assertEquals(results.size(), 1, 'Should have received 1 Campaign IO result.');    
            system.assertEquals(false, results.get(0).IsSuccess, 'IO should have failed due to bad Territory.');
            system.assertEquals(BI_Constants.IO_TERRITORY, results.get(0).Message);
            //Put Territory back to valid.
            arkansasTerritory.IOCodeSegment__c = '04';
            update arkansasTerritory;
    
            //Test 4 - Duplicate IO. 
            //Initially the MP has a NULL Next Sequence, so our IO Code will be 001. Then reset the sequence back to 1 and create another 
            //campaign.
            results = BI_CampaignIntegrationLogic.generateIOCodes(campaignIds); 
            system.assertEquals(1, results.size(), 'Should have received 1 Campaign IO result.');
            system.assertEquals(cmpCode, results.get(0).Campaign.IOCode__c, 'IO Code should be '+cmpCode);
            plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            plan1 = plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K');
            system.assertEquals(3, plan1.Next_IO_Sequence__c, 'Next Sequence should be 2 after the first was created.');
            plan1.Next_IO_Sequence__c = 1;
            update plan1;
            Campaign__c camp2 = TestDataFactory.MapCampaign(plan1.Id, 0.00, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 1, 27), 'USD', tagsMap.get('BQ_Jim Beam White'));
            camp2.Related_Priority__c = otherProgramId;
            insert camp2;
            results = BI_CampaignIntegrationLogic.generateIOCodes(new set<Id> { camp2.Id });
            system.assertEquals(1, results.size(), 'Should have received 1 Campaign IO result.');
            system.assertEquals(true, results.get(0).IsSuccess, 'IO should have failed due to Duplicate IO.');
            system.assertEquals(null, results.get(0).Message, 'Should receive Duplicate IO message');
            
            //Test 5 - Year not populated (its a formula field inheriting the MP's year, so we have to invalidate the MP.)
            plan1.Year__c = null;
            plan1.Next_IO_Sequence__c = 2; //go back to valid value
            update plan1;
            results = BI_CampaignIntegrationLogic.generateIOCodes(new set<Id> { camp2.Id });
            system.assertEquals(1, results.size(), 'Should have received 1 Campaign IO result.');
            system.assertEquals(false, results.get(0).IsSuccess, 'IO should have failed due empty Year.');
            system.assertEquals(BI_Constants.IO_YEAR_MISSING, results.get(0).Message, 'IO should have failed due empty Year.');
    
            //Test 6 - Controlling Area null 
            plan1.Year__c = '2018'; //go back to valid value
            plan1.SAP_Controlling_Area__c = null;
            plan1.SAP_Company_Code__c = null;
            plan1.SAP_Cost_Center__c = null;
            update plan1;
            results = BI_CampaignIntegrationLogic.generateIOCodes(new set<Id> { camp2.Id });
            system.assertEquals(1, results.size(), 'Should have received 1 Campaign IO result.');
            system.assertEquals(false, results.get(0).IsSuccess, 'IO should have failed due empty Controlling Area.');
            system.assertEquals(BI_Constants.IO_SAP_CONTROLLINGAREA, results.get(0).Message, 'IO should have failed due empty Controlling Area.');
    
            //Test 7 - Company Code null
            plan1.SAP_Controlling_Area__c = '2000';//go back to valid value
            update plan1;
            results = BI_CampaignIntegrationLogic.generateIOCodes(new set<Id> { camp2.Id });
            system.assertEquals(1, results.size(), 'Should have received 1 Campaign IO result.');
            system.assertEquals(false, results.get(0).IsSuccess, 'IO should have failed due empty Company Code.');
            system.assertEquals(BI_Constants.IO_SAP_COMPANYCODE, results.get(0).Message, 'IO should have failed due empty Company Code.');
    
            //Test 8 - Cost Center null
            plan1.SAP_Company_Code__c = 'US30';//go back to valid value
            plan1.SAP_Cost_Center__c = null;
            update plan1;
            results = BI_CampaignIntegrationLogic.generateIOCodes(new set<Id> { camp2.Id });
            system.assertEquals(1, results.size(), 'Should have received 1 Campaign IO result.');
            system.assertEquals(false, results.get(0).IsSuccess, 'IO should have failed due empty Cost Center.');
            system.assertEquals(BI_Constants.IO_SAP_COSTCENTER, results.get(0).Message, 'IO should have failed due empty Cost Center.');
        
            Test.stopTest();
        }
    }


}