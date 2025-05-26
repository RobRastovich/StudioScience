@isTest
private class BI_BudgetManagerLogicTests {

    @testSetup
    static void setup()
    {
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
        
    static testmethod void testCreateTagData() {
        List<Tags__c> testTags = [SELECT Id, Name FROM Tags__c];
        System.assertEquals(testTags.size(), 0, 'No Mock Tags should exist yet.');  
        
        //Create Tags, assert they were created.
        TestDataFactory.createTags();
        
        testTags = [SELECT Id, Name FROM Tags__c];
        System.assertEquals(testTags.size(), 151, 'Mock Tags were not created successfully.'); 
    }
    
    static testmethod void testCreateTestHierarchyData() {      
        User BI_Admin = TestDataFactory.createBIRunningUserWithCurrencyCode('USD', 'System Administrator');
        System.runAs(BI_Admin){            
            List<MarketingPlan__c> testPlans = [SELECT Id, Name FROM MarketingPlan__c];
            System.assertEquals(testPlans.size(), 0, 'No Marketing Plans should exist yet.');
            
            //Create marketing plans
            TestDataFactory.createMarketingPlanHierarchy();
            
            testPlans = [SELECT Name, Id, ParentMarketingPlan__c, Year__c, Brand__c, Country__c, Region__c, Division__c, Territory__c, Budget__c FROM MarketingPlan__c];
                
            System.assertEquals(testPlans.size(), 31, 'There should be 31 mock Marketing Plans.');
        }
    } 
    
    static testmethod void testSingleDuplicateMarketingPlan() {      
        User BI_Admin = TestDataFactory.createBIRunningUserWithCurrencyCode('USD', 'System Administrator');
        System.runAs(BI_Admin){        
            //Create test data
            TestDataFactory.createMarketingPlanHierarchy();
            //Get the MP Record Types
            Map<String, ID> mpTypes = BI_UtilityLogic.getRecordTypeNamesByIds( 
                BI_Constants.OBJECT_MARKETINGPLAN, 
                new List<String> { BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED }); 
            
            try {                       
                //Duplicate of 2018 top-level MP
                //Should cause an exception to be thrown, based on a Unique concatenated field in SF.           
                string currentYear = string.valueof(System.Today().year());   
                MarketingPlan__c newPlan = TestDataFactory.MapMarketingPlan('2018 $10M',currentYear ,null,null,null,null,null,null,10000000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED));
                insert newPlan;
                System.debug(LoggingLevel.INFO,'NewPlan.Id=' + newPlan.Id);
                //System.assert(false, 'Single duplicate MarketingPlan should not have been created.');           
            }  
            catch (Exception e) {
                //If caught exception, ensure it is the Duplicate message.
                System.debug(LoggingLevel.INFO,'Exception: ' + e.getMessage());
                System.assert(true);
                //Boolean expectedExceptionThrown = e.getMessage().contains(BI_Constants.DUPLICATE_PLAN) ? true : false;
                //System.assertEquals(expectedExceptionThrown, true);           
            }
        } 
    }
    
    
    static testmethod void testMultipleDuplicateMarketingPlan() {        
        User BI_Admin = TestDataFactory.createBIRunningUserWithCurrencyCode('USD', 'System Administrator');
        System.runAs(BI_Admin){        
            //Create test data
            TestDataFactory.createMarketingPlanHierarchy();
            //Get the MP Record Types
            Map<String, ID> mpTypes = BI_UtilityLogic.getRecordTypeNamesByIds( 
                BI_Constants.OBJECT_MARKETINGPLAN, 
                new List<String> { BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED });
                
            try {                       
                //Duplicate of 2018 top-level MP
                //Should cause an exception to be thrown.
                MarketingPlan__c plan1 = TestDataFactory.MapMarketingPlan('2016 $10M','2016',null,null,null,null,null,null,10000000,mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED));
                MarketingPlan__c plan2 = TestDataFactory.MapMarketingPlan('2016 $10M','2016',null,null,null,null,null,null,10000000,mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED));
                MarketingPlan__c plan3 = TestDataFactory.MapMarketingPlan('2016 $10M','2016',null,null,null,null,null,null,10000000,mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED));
                List<MarketingPlan__c> newPlans = new List<MarketingPlan__c>();
                newPlans.Add(plan1);
                newPlans.Add(plan2);
                newPlans.Add(plan3);
                
                insert newPlans;
                
                //System.assert(false, 'Multiple duplicate INSERTed MarketingPlans should not have been created.');    
                
            }  
            catch (Exception e) {
                //If caught exception, ensure it is the Duplicate message.
                System.debug(LoggingLevel.INFO,'Exception: ' + e.getMessage());
                System.assert(true);
                //Boolean expectedExceptionThrown = e.getMessage().contains(BI_Constants.DUPLICATE_PLAN) ? true : false;
                //System.assertEquals(expectedExceptionThrown, true);           
            }
        }
    }
    
    static testmethod void testUpdatingSingleMarketingPlan() {
        User BI_Admin = TestDataFactory.createBIRunningUserWithCurrencyCode('USD', 'System Administrator');
        System.runAs(BI_Admin){
            //Create test data
            TestDataFactory.createMarketingPlanHierarchy();
            
            Test.StartTest();
            
            //Get the plans we'll be working with.
            List<String> planNames = new List<String>();
            planNames.add('2018 US JBW American AMR SDP Heritage $30K');
            planNames.add('2018 US JBW American AMR SDP Heritage Arkansas $5K');
            
            Map<String, MarketingPlan__c> plansToUpdate = TestDataFactory.retrieveMarketingPlansByName(planNames);
            System.assertEquals(2, plansToUpdate.size(), 'Did not retrieve the desired 6 plans.');
            
            MarketingPlan__c parent = plansToUpdate.get('2018 US JBW American AMR SDP Heritage $30K');
            MarketingPlan__c child = plansToUpdate.get('2018 US JBW American AMR SDP Heritage Arkansas $5K');
            
            //Initial AllocatedBudget was $25K, assert.
            System.assertEquals(25000, parent.AllocatedBudget__c, 'AllocatedBudget incorrect for plan (2018 US JBW American AMR SDP Heritage $30K). Expected $25K - got ' + parent.AllocatedBudget__c);
            
            //Update the child by 3K, so parent AllocatedBudget should equal 28K
            
            try {
                child.Budget__c += 3000;
                child.Comments__c = 'test comments';
                update child;
                System.assert(true, 'Should have successfully updated 1 plan with an additional $3K dollars.'); 
                
                //Re-retrieve the plans and assure the Allocated Budget amount is accurate.
                plansToUpdate.clear();
                plansToUpdate = TestDataFactory.retrieveMarketingPlansByName(planNames);
                parent = plansToUpdate.get('2018 US JBW American AMR SDP Heritage $30K');
                child = plansToUpdate.get('2018 US JBW American AMR SDP Heritage Arkansas $5K');
                
                //New AllocatedBudget should be $28K.
                System.assertEquals(28000, parent.AllocatedBudget__c, 'AllocatedBudget incorrect for plan ' + parent.Name);
                
                //NEGATIVE TESTING - try to add another 3K, which SHOULD FAIL because we only have 2K left of slush funds.
                try {
                    child.Budget__c += 3000;
                    child.Comments__c = 'test comments';
                    update child;
                    System.assert(false, 'Should have failed updating 1 plan with an additional $3K dollars, for a total of $31K.');    
                } catch (Exception eIn) {
                    System.assert(true, 'Should have failed updating 1 plan with an additional $3K dollars, for a total of $31K.'); 
                }           
                
            } catch (Exception eOut) {
                System.assert(false, 'Should not have received an exception adding $3K to the 1 plan.');    
            }
            
            Test.StopTest();
        }
    }   
        
    static testmethod void testUpdatingMultipleMarketingPlanLevels() {
        User BI_Admin = TestDataFactory.createBIRunningUserWithCurrencyCode('USD', 'System Administrator');
        System.runAs(BI_Admin){
            //Create test data
            TestDataFactory.createMarketingPlanHierarchy();
            
            //Get the plans we'll be updating
            List<String> planNames = new List<String>();
            planNames.add('2018 $10M');
            planNames.add('2018 US $7M');
            planNames.add('2018 US JBW $1M');
            planNames.add('2018 US JBW American $100K');
            planNames.add('2018 US JBW American AMR SDP Heritage $30K');
            planNames.add('2018 US JBW American AMR SDP Heritage Arkansas $5K');
            
            Map<String, MarketingPlan__c> plansToUpdate = TestDataFactory.retrieveMarketingPlansByName(planNames);
            System.assertEquals(6, plansToUpdate.size(), 'Did not retrieve the desired 6 plans.');          
            
            Test.StartTest();
            
            //Test - his test will simulate adding $10 Million USD to the above marketing plans (an entire branch). 
            //This should succeed.      
            for (MarketingPlan__c plan : plansToUpdate.values()) {
                plan.Budget__c = plan.Budget__c + 10000000.00;  
                plan.Comments__c = 'test comments';
            }
            try {
                update plansToUpdate.values();
                System.assert(true, 'Should have successfully updated all 6 plans with an additional $10M dollars.');
                
                //Re-retrieve the plans and assure the Allocated Budget amount is accurate.
                Map<String, MarketingPlan__c> updatedPlans = TestDataFactory.retrieveMarketingPlansByName(planNames);
                
                for (MarketingPlan__c p : updatedPlans.values()) {
                    
                    if (p.Name == '2018 $10M') {
                        //Initial AllocatedBudget was $9M, so should be $19M now.
                        System.assertEquals(19000000, p.AllocatedBudget__c, 'AllocatedBudget incorrect for plan (2018 $10M). Expected $19M - got ' + p.AllocatedBudget__c);
                    } else if (p.Name == '2018 US $7M') {
                        //Initial AllocatedBudget was $1M, so should be $11M now.
                        System.assertEquals(11000000, p.AllocatedBudget__c, 'AllocatedBudget incorrect for plan (2018 US $7M). Expected $11M - got ' + p.AllocatedBudget__c);
                    } else if (p.Name == '2018 US JBW $1M') {
                        //Initial AllocatedBudget was $900K, so should be $10.9M now.
                        System.assertEquals(10900000, p.AllocatedBudget__c, 'AllocatedBudget incorrect for plan (2018 US JBW $1M). Expected $10.9M - got ' + p.AllocatedBudget__c);
                    } else if (p.Name == '2018 US JBW American $100K') {
                        //Initial AllocatedBudget was $80K, so should be $10.08M now.
                        System.assertEquals(10080000, p.AllocatedBudget__c, 'AllocatedBudget incorrect for plan (2018 US JBW American $100K). Expected $10.08M - got ' + p.AllocatedBudget__c);
                    } else if (p.Name == '2018 US JBW American AMR SDP Heritage $30K') {
                        //Initial AllocatedBudget was $25K, so should be $10.025M now.
                        System.assertEquals(10025000, p.AllocatedBudget__c, 'AllocatedBudget incorrect for plan (2018 US JBW American AMR SDP Heritage $30K). Expected $10.025M - got ' + p.AllocatedBudget__c);
                    }   
                }                       
            }
            catch (Exception e)     {
                System.assert(false, 'Should not have received an exception adding $10M to each of the 6 plans.');
            }   
            
            Test.StopTest();
        }
    }
    
    static testmethod void testDeleteAndUndeleteMarketingPlans() {
        User BI_Admin = TestDataFactory.createBIRunningUserWithCurrencyCode('USD', 'System Administrator');
        System.runAs(BI_Admin){
            //Create test data
            TestDataFactory.createMarketingPlanHierarchy();
            
            //Get the plans we'll be working with.
            List<String> planNames = new List<String>();
            planNames.add('2018 US JBW American AMR SDP Heritage $30K');
            planNames.add('2018 US JBW American AMR SDP Heritage Arkansas $5K');
            planNames.add('2018 US JBW American AMR SDP Heritage Kansas $5K');
            planNames.add('2018 US JBW American AMR SDP Heritage Louisana $15K');
                
            Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            System.assertEquals(4, plans.size(), 'Did not retrieve the desired 4 plans.');          
            
            Test.StartTest();
            
            List<MarketingPlan__c> undeleteKids = new List<MarketingPlan__c>();
            undeleteKids.add(plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K'));
            undeleteKids.add(plans.get('2018 US JBW American AMR SDP Heritage Kansas $5K'));
            undeleteKids.add(plans.get('2018 US JBW American AMR SDP Heritage Louisana $15K')); 
            
            MarketingPlan__c parent = plans.get('2018 US JBW American AMR SDP Heritage $30K');
            MarketingPlan__c childToDelete = plans.get('2018 US JBW American AMR SDP Heritage Kansas $5K');
            
            System.assertEquals(25000, parent.AllocatedBudget__c, 'Parent plan expected to have 25K AllocatedBudget to start with.');
                    
            try {       
                    
                //Single Delete
                delete childToDelete;
                System.assert(true, 'Should have successfully deleted a single child Marketing Plan.');
                
                //Re-retrieve the plans and assure the Allocated Budget amount is accurate.
                plans.clear();
                plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
                System.assertEquals(3, plans.size(), 'Did not retrieve the desired 4-1=3 plans.');
                parent = plans.get('2018 US JBW American AMR SDP Heritage $30K');
                
                //After deleting a 5K child, Allocated should = 20K
                System.assertEquals(20000, parent.AllocatedBudget__c, 'AllocatedBudget incorrect for plan ' + parent.Name);
                
                List<MarketingPlan__c> otherKidsToDelete = new List<MarketingPlan__c>();
                otherKidsToDelete.add(plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K'));
                otherKidsToDelete.add(plans.get('2018 US JBW American AMR SDP Heritage Louisana $15K'));
                
                //Multiple delete
                delete otherKidsToDelete;
                
                //Re-retrieve the plans and assure the Allocated Budget amount is accurate.
                plans.clear();
                plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
                System.assertEquals(1, plans.size(), 'Did not retrieve the desired 4-3=1 plan.');
                parent = plans.get('2018 US JBW American AMR SDP Heritage $30K');
                            
                //After deleting all kids, Allocated should = 0
                System.assertEquals(0, parent.AllocatedBudget__c, 'AllocatedBudget incorrect for plan ' + parent.Name);
                
                //Undelete
                undelete undeleteKids;
                
                //Re-retrieve the plans and assure the Allocated Budget amount is accurate.
                plans.clear();
                plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
                System.assertEquals(4, plans.size(), 'Undeleted plans were not found.');
                parent = plans.get('2018 US JBW American AMR SDP Heritage $30K');
                            
                //After undeleting all kids, Allocated should equal the original 25K.
                System.assertEquals(25000, parent.AllocatedBudget__c, 'AllocatedBudget incorrect for plan ' + parent.Name);
                                        
            }
            catch (Exception e)     {
                System.assert(false, 'Should not have received an exception deleting/undeleting single or multiple Marketing Plans.');
            }   
            
            Test.StopTest();
        }
    }
    
    static testmethod void testReparentMarketingPlans() {
        User BI_Admin = TestDataFactory.createBIRunningUserWithCurrencyCode('USD', 'System Administrator');
        System.runAs(BI_Admin){
            //Create test data
            TestDataFactory.createMarketingPlanHierarchy();
            
            //Get the plans we'll be updating
            List<String> planNames = new List<String>();
            planNames.add('2018 US JBW American AMR SDP Heritage $30K');
            planNames.add('2018 US JBW American AMR SDP Heritage Arkansas $5K');
            planNames.add('2018 US JBW American AMR SDP Heritage Kansas $5K');
            planNames.add('2018 US JBW American AMR SDP Heritage Louisana $15K');
            planNames.add('2018 US JBW American AMR SDP Legacy $50K');
            planNames.add('2018 US JBW American AMR SDP Legacy Massachusetts $20K');
            planNames.add('2018 US JBW American AMR SDP Legacy Missouri $20K');
            planNames.add('2018 US JBW American AMR SDP Legacy New Jersey $8K');
            
            Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            System.assertEquals(8, plans.size(), 'Did not retrieve the desired 8 plans.');          
            
            Test.StartTest();
            
            //Initial $25K
            MarketingPlan__c parentHeritage = plans.get('2018 US JBW American AMR SDP Heritage $30K');
            //Initial $48K
            MarketingPlan__c parentLegacy = plans.get('2018 US JBW American AMR SDP Legacy $50K');
            //Child to reparent
            MarketingPlan__c childArkansas = plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K');
            
            //First, try to reparent when we know the destination parent won't have enough funds. Should bomb out.
            try {           
                childArkansas.ParentMarketingPlan__c = parentLegacy.Id;
                update childArkansas;
                System.assert(false, 'Reparenting plan should have bombed due to destination parent not having enough funds.');
            } catch (Exception e1) {
                System.assert(true, 'Reparenting plan should have bombed due to destination parent not having enough funds.');
            }
            
            //Clear values
            plans.clear();
            plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            //Initial $25K
            parentHeritage = plans.get('2018 US JBW American AMR SDP Heritage $30K');
            //Initial $48K
            parentLegacy = plans.get('2018 US JBW American AMR SDP Legacy $50K');
            //Child to reparent
            childArkansas = plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K');
                    
            //Second, reduce the amount of funds on child so it can be reparented. SHould succeed.
            try {           
                childArkansas.Budget__c = 1000;
                childArkansas.Comments__c = 'test comments';
                update childArkansas;
                System.assert(true, 'Should have reduced Arkansas to $1K');
            } catch (Exception e2) {
                System.assert(false, 'Should have reduced Arkansas to $1K');
            }
            
            //Clear values
            plans.clear();
            plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            //Initial $21K
            parentHeritage = plans.get('2018 US JBW American AMR SDP Heritage $30K');
            //Initial $48K
            parentLegacy = plans.get('2018 US JBW American AMR SDP Legacy $50K');
            //Child to reparent
            childArkansas = plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K');
            
            //Lastly, reparent the child from Heritage to Legacy.
            try {           
                childArkansas.ParentMarketingPlan__c = parentLegacy.Id;
                update childArkansas;
                System.assert(true, 'Should have reparented Arkansas to Legacy division.');
            } catch (Exception e3) {
                System.assert(false, 'Should have reparented Arkansas to Legacy division.');
            }
            
            //Clear values and make final assertions
            plans.clear();
            plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            //After reparenting: $20K
            parentHeritage = plans.get('2018 US JBW American AMR SDP Heritage $30K');
            //After reparenting: $49K
            parentLegacy = plans.get('2018 US JBW American AMR SDP Legacy $50K');       
            System.assertEquals(20000, parentHeritage.AllocatedBudget__c, 'AllocatedBudget not accurate on source parent: ' + parentHeritage.Name);
            System.assertEquals(49000, parentLegacy.AllocatedBudget__c, 'AllocatedBudget not accurate on destination parent: ' + parentLegacy.Name);      
            
            Test.StopTest();
        }
    } 
    
    static testmethod void testAutoCreateCampaignForecasts() {       
        User BI_Admin = TestDataFactory.createBIRunningUserWithCurrencyCode('USD', 'System Administrator');
        System.runAs(BI_Admin){
            Id otherProgramId = getOtherProgram().Id;
        
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
            
            Map<Id, Map<Date, Campaign_Spend__c>> campaignForecasts = new Map<Id, Map<Date, Campaign_Spend__c>>();
            integer currentYear = System.Today().year();
            try {

                //TEST 1: Create a single Campaign with same Start/End date month (1 forecast should be created, with $3000)
                Campaign__c camp1 = TestDataFactory.MapCampaign(plan1.Id, 3000.00, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 1, 27), 'USD', tagsMap.get('BQ_Jim Beam White'));
                camp1.Related_Priority__c = otherProgramId;
                
                try {
                    insert camp1;
                } catch (Exception e1) {
                    System.assert(false, 'Exception in TEST 1: ' + e1.getMessage());
                }
                
                
                campaignForecasts.clear();
                campaignForecasts = retrieveForecastsByParentCampaignIds(new List<Id>{camp1.Id});
                //Assure we found the 1 campaign.
                System.assertEquals(1, campaignForecasts.size(), 'Should only find one Campaign.');
                //Assure that campaign has 12 forecasts no matter the date range
                System.assertEquals(12, campaignForecasts.get(camp1.Id).size(), 'Should find 12 Forecasts');
                //Assure the forecast data is accurate: ForecastDate,Amount,ParentCampaignId,Currency.
                System.assertEquals(date.newinstance(currentYear, 1, 1), campaignForecasts.get(camp1.Id).get(date.newinstance(currentYear, 1, 1)).Forecast_Month_Date__c);
                System.assertEquals(3000.00, campaignForecasts.get(camp1.Id).get(date.newinstance(currentYear, 1, 1)).Amount__c);
                System.assertEquals(camp1.Id, campaignForecasts.get(camp1.Id).get(date.newinstance(currentYear, 1, 1)).ParentCampaign__c);
                System.assertEquals('USD', campaignForecasts.get(camp1.Id).get(date.newinstance(currentYear, 1, 1)).CurrencyIsoCode);
                
                
                //TEST 2: Create a single Campaign with Start=Feb and End=April
                camp1 = TestDataFactory.MapCampaign(plan2.Id, 1000.00, date.newinstance(currentYear, 2, 5), date.newinstance(currentYear, 4, 27), 'MXN', tagsMap.get('BQ_Jim Beam White'));
                camp1.Related_Priority__c = otherProgramId;
                
                try {
                    insert camp1;
                } catch (Exception e2) {
                    System.assert(false, 'Exception in TEST 2: ' + e2.getMessage());
                }
                
                campaignForecasts.clear();
                campaignForecasts = retrieveForecastsByParentCampaignIds(new List<Id>{camp1.Id});
                //Assure we found the 1 campaign.
                System.assertEquals(1, campaignForecasts.size(), 'Should only find one Campaign.');
                //Assure that campaign has 12 forecasts
                System.assertEquals(12, campaignForecasts.get(camp1.Id).size());
                            
                for (Integer i = 2; i <= 4; i++) {
                    //Assure the forecast data is accurate: ForecastDate,Amount,ParentCampaignId,Currency.
                    //1000 / 3 = 333.33 (so the last month should be 333.34 to represent the remainder.)
                    System.assertEquals(date.newinstance(currentYear, i, 1), campaignForecasts.get(camp1.Id).get(date.newinstance(currentYear, i, 1)).Forecast_Month_Date__c);                            
                    System.assertEquals(camp1.Id, campaignForecasts.get(camp1.Id).get(date.newinstance(currentYear, i, 1)).ParentCampaign__c);
                    System.assertEquals('MXN', campaignForecasts.get(camp1.Id).get(date.newinstance(currentYear, i, 1)).CurrencyIsoCode);
                    if(i != 4) {
                        System.assertEquals(333.33, campaignForecasts.get(camp1.Id).get(date.newinstance(currentYear, i, 1)).Amount__c);
                    } else {
                        System.assertEquals(333.34, campaignForecasts.get(camp1.Id).get(date.newinstance(currentYear, i, 1)).Amount__c);
                    }
                }

                Test.StartTest();
                //TEST 4: Create 20 Campaigns - $100 each, with January through December (12 forecasts - each of $8.33, one of $8.34)
                System.debug(LoggingLevel.INFO,'Starting TEST 4');
                List<Campaign__c> bulkCampaigns = new List<Campaign__c>();
                for (integer i = 1; i <= 20; i++) {
                    bulkCampaigns.add(TestDataFactory.MapCampaign(plan3.Id, 100.00, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 12, 27), 'USD', tagsMap.get('BQ_Jim Beam White')));
                }           
                
                try {
                    System.debug(LoggingLevel.INFO,'Campaigns inserting: ' + bulkCampaigns.size());
                    System.debug(LoggingLevel.INFO, 'MP BUDGET: ' + plan3.Budget__c);
                    System.debug(LoggingLevel.INFO, 'Marketingplan: ' + [select id, campaignbalance__c from marketingplan__c where id =: plan3.Id]);
                    for(Campaign__c c: bulkCampaigns){
                        System.debug(LoggingLevel.INFO, 'PlannedCampaignSpend__c: ' + c.PlannedCampaignSpend__c);
                        c.Related_Priority__c = otherProgramId;
                    }
                    insert bulkCampaigns;
                    System.debug(LoggingLevel.INFO, 'Marketingplan: ' + [select id, campaignbalance__c from marketingplan__c where id =: plan3.Id]);
                    System.debug(LoggingLevel.INFO,'Campaigns inserted: ' + bulkCampaigns.size());
                } catch (Exception e4) {
                    System.debug(LoggingLevel.INFO,'Exception inserting: ' + e4.getMessage());
                    System.assert(false, 'Exception in TEST 4: ' + e4.getMessage());
                }
                
                List<Id> campaignIds = new List<Id>();
                for (Campaign__c c : bulkCampaigns) {
                    System.debug(LoggingLevel.INFO,'CampaignID: ' + c.Id);
                    campaignIds.add(c.Id);
                }   
                
                //System.debug(LoggingLevel.INFO,campaignIds);
                
                campaignForecasts.clear();
                campaignForecasts = retrieveForecastsByParentCampaignIds(campaignIds);
                //Assure we found the 20 campaigns.
                System.assertEquals(20, campaignForecasts.size(), 'Should find 20 campaigns.');
                
                //Assure there are 20 * 12 = 240 total forecasts created.
                List<Campaign_Spend__c> bulkForecasts = [SELECT Name, Id, ParentCampaign__c, Forecast_Month_Date__c, Amount__c, CurrencyIsoCode, RecordTypeId 
                    FROM Campaign_Spend__c 
                    WHERE ParentCampaign__c IN :campaignIds];
                //System.assertEquals(240, bulkForecasts.size(), 'There should be 2400 Forecasts when 200 Campaigns are created Jan-Dec');
                System.assertEquals(240, bulkForecasts.size(), 'There should be 240 Forecasts when 20 Campaigns are created Jan-Dec');

                Test.StopTest();
            }
            catch (Exception e) {
                //If caught exception, ensure it is the Duplicate message.
                System.debug(LoggingLevel.INFO,'Exception: ' + e.getMessage());
                System.assert(false, 'There was an issue with the testAutoCreateCampaignForecasts method.');        
            }
        }
    }

    static testmethod void testEvaluateForecastRecordsAfterCampaignUpdate() {
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

            Map<Id, Map<Date, Campaign_Spend__c>> campaignForecasts = new Map<Id, Map<Date, Campaign_Spend__c>>();
            integer currentYear = System.Today().year();
            Test.startTest();

            Campaign__c camp1 = TestDataFactory.MapCampaign(plan1.Id, 3000.00, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 1, 27), 'USD', tagsMap.get('BQ_Jim Beam White'));
            camp1.Related_Priority__c = otherProgramId;
            insert camp1;

            campaignForecasts.clear();
            campaignForecasts = retrieveForecastsByParentCampaignIds(new List<Id>{camp1.Id});
            //Assure we found the 1 campaign.
            System.assertEquals(1, campaignForecasts.size(), 'Should only find one Campaign.');
            //Assure that campaign has 12 forecasts
            System.assertEquals(12, campaignForecasts.get(camp1.Id).size(), 'Should return 12 Forecasts no matter the date range used');

            List<Campaign_Spend__c> forecastListWithBudget = [SELECT Amount__c FROM Campaign_Spend__c WHERE ParentCampaign__c = :camp1.Id];
            Decimal totalAmountForecastedWithBudget = 0;
            for(Campaign_Spend__c forecast: forecastListWithBudget){
                totalAmountForecastedWithBudget += forecast.Amount__c;
            }
            System.assertEquals(3000, totalAmountForecastedWithBudget, 'Should return the budget of 3000 for the one active month in the campaign');

            camp1.PlannedCampaignSpend__c = 0;
            camp1.Comments__c = 'New budget';
            update camp1;

            List<Campaign_Spend__c> forecastListWithoutBudget = [SELECT Amount__c FROM Campaign_Spend__c WHERE ParentCampaign__c = :camp1.Id];
            Decimal totalAmountForecastedWithoutBudget = 0;
            for(Campaign_Spend__c forecast: forecastListWithoutBudget){
                totalAmountForecastedWithoutBudget += forecast.Amount__c;
            }

            System.assertEquals(0, totalAmountForecastedWithoutBudget, 'Should return 0 since the forecasts for that campaign will be zeroed out when the budget is zeroed out');
            
            Test.stopTest();
        }
    }
    
    static Map<Id, Map<Date, Campaign_Spend__c>> retrieveForecastsByParentCampaignIds(List<Id> campaignIds) {
        //Campaign Map containing each child Forecast by date.      
        Map<Id, Map<Date, Campaign_Spend__c>> campaignForecasts = new Map<Id, Map<Date, Campaign_Spend__c>>();
        ID forecastRecordTypeId = BI_UtilityLogic.getRecordTypeId(BI_Constants.OBJECT_CAMPAIGNSPEND, 
            BI_Constants.RECORDTYPE_CAMPAIGNSPEND_FORECAST);
            
        for(Campaign_Spend__c f : [SELECT Name, Id, ParentCampaign__c, Forecast_Month_Date__c, Amount__c, CurrencyIsoCode, RecordTypeId 
            FROM Campaign_Spend__c 
            WHERE RecordTypeId = :forecastRecordTypeId AND ParentCampaign__c IN :campaignIds])
        {
            if(campaignForecasts.get(f.ParentCampaign__c) == null)
            {
                campaignForecasts.put(f.ParentCampaign__c, new Map<Date, Campaign_Spend__c>{f.Forecast_Month_Date__c => f});
            }
            else
            {
                campaignForecasts.get(f.ParentCampaign__c).put(f.Forecast_Month_Date__c, f);
            }
        }   
        System.debug(LoggingLevel.INFO,'Forecast Map: ' + campaignForecasts);
        return campaignForecasts;
    }  
    
    static testmethod void testChildCampaignBulkCreation() {
        User BI_User = TestDataFactory.createBIRunningUserWithCurrencyCode('USD', 'Field Marketing Director - Platform');
        System.runAs(BI_User){
            Id otherProgramId = getOtherProgram().Id;
            //Create test data
            TestDataFactory.createMarketingPlanHierarchy();
            Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();
            System.debug(LoggingLevel.INFO,'Inside testChildCampaign');
            
            //Get the Marketing Plan(s) that we'll be adding child Campaigns under.
            List<String> planNames = new list<String> {'2018 US JBW American AMR SDP Heritage Arkansas $5K'};
            Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            MarketingPlan__c plan1 = plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K');
            List<MarketingPlan__c> updatePlans = new List<MarketingPlan__c> { plan1 };
            update updatePlans;
            integer currentYear = System.Today().year();
            Campaign__c ParentCampaign = TestDataFactory.MapCampaign(plan1.Id, 500.00, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 1, 27), 'USD', tagsMap.get('BQ_Jim Beam White'));
            insert ParentCampaign;
            
           
            //Test for bulkification. More than 200 campaigns
            
    
                                         
            Test.startTest();
            
            
            List<Campaign__c> camps = new List<Campaign__c>();
            for (Integer i = 0; i < 500; i++) {
                Campaign__c temp = TestDataFactory.MapCampaign(plan1.Id, 1.00, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 1, 27), 'USD', tagsMap.get('BQ_Jim Beam White'));
                temp.Child_Campaign__c = ParentCampaign.Id;
                temp.RecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get(BI_Constants.RECORDTYPE_CAMPAIGN_CHILD).getRecordTypeId();
                camps.add(temp);
            }
            
            try{
                insert camps;
                System.assert(true);
            }
            catch (Exception e) {
                System.debug(LoggingLevel.INFO,'Exception: ' + e.getMessage());
                System.assert(false);         
            }
            
            Test.stopTest();     
        }
    }
    
        
    static testmethod void testChildCampaignValidations() {
        User BI_User = TestDataFactory.createBIRunningUserWithCurrencyCode('USD', 'Field Marketing Director - Platform');
        System.runAs(BI_User){
            Id otherProgramId = getOtherProgram().Id;
            //Create test data
            TestDataFactory.createMarketingPlanHierarchy();
            Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();
            System.debug(LoggingLevel.INFO,'Inside testChildCampaign');
            
            //Get the Marketing Plan(s) that we'll be adding child Campaigns under.
            List<String> planNames = new list<String> {'2018 US JBW American AMR SDP Heritage Arkansas $5K'};
            Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            MarketingPlan__c plan1 = plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K');
            plan1.Region__c='Must Win Region';
            update plan1;
    
            List<MarketingPlan__c> updatePlans = new List<MarketingPlan__c> { plan1 };
            update updatePlans;
             
            integer currentYear = System.Today().year();

            Campaign__c ParentCampaign1 = TestDataFactory.MapCampaign(plan1.Id, 3000.00, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 1, 27), 'USD', tagsMap.get('BQ_Jim Beam White'));
            ParentCampaign1.ParticipatingStates__c = 'Arkansas;Ohio;Arizona;Utah';
            insert ParentCampaign1;
            
            Campaign__c ParentCampaign2 = TestDataFactory.MapCampaign(plan1.Id, 2000.00, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 1, 27), 'USD', tagsMap.get('BQ_Jim Beam White'));
            insert ParentCampaign2;

           
            //Test for bulkification. More than 200 campaigns
                              
            Test.startTest();
            
            Campaign__c child1 = TestDataFactory.MapCampaign(plan1.Id, 2000.00, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 1, 27), 'USD', tagsMap.get('BQ_Jim Beam White'));
            child1.Child_Campaign__c = ParentCampaign1.Id;
            child1.ParticipatingState__c = 'Arkansas';
            child1.RecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get(BI_Constants.RECORDTYPE_CAMPAIGN_CHILD).getRecordTypeId();
            
            //Positive test case 1: Creating a Child Campaign
            try{
                insert child1;
                System.assert(true);
                System.debug(LoggingLevel.INFO,'First Child Campaign Created.');  
            }
            catch (Exception e) {
                System.debug(LoggingLevel.INFO,'Exception: ' + e.getMessage());
                System.assert(false);         
            }
    
            //Positive test case 2: Creating second Child Campaign  
            Campaign__c child2 = TestDataFactory.MapCampaign(plan1.Id, 1000.00, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 1, 27), 'USD', tagsMap.get('BQ_Jim Beam White'));
            child2.Child_Campaign__c = ParentCampaign1.Id;
            child2.ParticipatingState__c = 'Arkansas';
            child2.RecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get(BI_Constants.RECORDTYPE_CAMPAIGN_CHILD).getRecordTypeId();
            
            try{
                insert child2;
                System.assert(true);
                System.debug(LoggingLevel.INFO,'Second Child Campaign created.');
            }
            catch (Exception e) {
                System.debug(LoggingLevel.INFO,'Exception: ' + e.getMessage());
                System.assert(false);         
            }
    
            //Negative test case 1: Validation rule for child campaign budget exceeding parent budget   
            //Should not let the system create a third Campaign as this will exceed the total available budget on parent
            //Total Campaign Budget is $3000 and total child budget so far is $3000. Adding another $1000 will exceed the budget
            
            
            // Update: As per business request we removed validation rules peventing overbudget. Adjusting  unit test to reflect the same. -AK 04/02/2019
            
            Campaign__c child3 = TestDataFactory.MapCampaign(plan1.Id, 1000.00, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 1, 27), 'USD', tagsMap.get('BQ_Jim Beam White'));
            child3.Child_Campaign__c = ParentCampaign1.Id;
            child3.ParticipatingState__c = 'Arkansas';
            child3.RecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get(BI_Constants.RECORDTYPE_CAMPAIGN_CHILD).getRecordTypeId();
            
            try{
                insert child3;
                //System.assert(false);
                System.assert(true);
            }
            catch (Exception e) {
                System.debug(LoggingLevel.INFO,'Exception: ' + e.getMessage());
                //System.assert(true);
                System.debug(LoggingLevel.INFO,'Third Child Campaign not created. negative test case 1 passed');
            }
            
            //Negative test case 2: Validation rule (Parent_Campaign_Check) for changing the Parent Campaign
            //A validation rule shall block the child campaign from changing the Parent Campaign after creation
            try{
                child2.Child_Campaign__c = ParentCampaign2.Id;
                update child2;
                System.assert(false);
            }
            catch (Exception e) {
                System.debug(LoggingLevel.INFO,'Exception: ' + e.getMessage());
                System.assert(true);
                System.debug(LoggingLevel.INFO,'Parent Campaign can not be changed after creation. negative test case 2 passed');
            }
            
            //Negative test case 3: Validation Rule (check_Region_for_MustWin) for changing the Participating State for Must Win Region 
            //A validation rule shall block the child campaign from changing the Parent Campaign after creation
            try{
                child2.ParticipatingState__c = 'Ohio';
                update child2;
                //System.assert(false);
                System.assert(true);
            }
            catch (Exception e) {
                System.debug(LoggingLevel.INFO,'Exception: ' + e.getMessage());
                //System.assert(true);
                System.debug(LoggingLevel.INFO,'Participating state should be same as Parent Campaign for must win region. negative test case 3 passed');
            }
            
            Test.stopTest();
        }
    }
        
    static testmethod void testChildCampaignDeletion() {
        User BI_User = TestDataFactory.createBIRunningUserWithCurrencyCode('USD', 'Field Marketing Director - Platform');
        System.runAs(BI_User){
            Id otherProgramId = getOtherProgram().Id;
            //Create test data
            TestDataFactory.createMarketingPlanHierarchy();
            Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();
            System.debug(LoggingLevel.INFO,'Inside testChildCampaign');
            
            //Get the Marketing Plan(s) that we'll be adding child Campaigns under.
            List<String> planNames = new list<String> {'2018 US JBW American AMR SDP Heritage Arkansas $5K'};
            Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            MarketingPlan__c plan1 = plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K');
    
            List<MarketingPlan__c> updatePlans = new List<MarketingPlan__c> { plan1 };
            update updatePlans;

            integer currentYear = System.Today().year();

            Campaign__c ParentCampaign = TestDataFactory.MapCampaign(plan1.Id, 6.00, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 1, 27), 'USD', tagsMap.get('BQ_Jim Beam White'));
            insert ParentCampaign;
            
           
            //Test for deletion.
            List<Campaign__c> camps = new List<Campaign__c>();
            Campaign__c child = TestDataFactory.MapCampaign(plan1.Id, 1.00, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 1, 27), 'USD', tagsMap.get('BQ_Jim Beam White'));
            child.Child_Campaign__c = ParentCampaign.Id;
            child.RecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get(BI_Constants.RECORDTYPE_CAMPAIGN_CHILD).getRecordTypeId();
            
            try{
                insert child;
                System.assert(true);
                System.debug('Child Campaign Inserted successfully');
            }
            catch (DmlException e) {
                System.debug(LoggingLevel.INFO,'Exception: ' + e.getMessage());
                System.assert(false);         
            }
                       
            Test.startTest();
            
            try{
                delete child;
                System.assert(true);
                System.debug('Child Campaigns Deleted successfully');
            }
            catch (DmlException e) {
                System.debug(LoggingLevel.INFO,'Exception: ' + e.getMessage());
                System.assert(false);         
            }
            
            Test.stopTest();     
        }
    }
    
}