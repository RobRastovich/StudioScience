@isTest
private class BatchForecastSnapshotWeeklyTest {

    @testSetup static void testSetup() {

        Id platformRecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Platform').getRecordTypeId();
        Program__c testProgram = new Program__c();
        testProgram.Name = 'Other';
        testProgram.RecordTypeId = platformRecordTypeId;

        Id programRecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Focus Calendar National Priority').getRecordTypeId();
        Program__c testProgram2 = new Program__c();
        testProgram2.Name = 'Other';
        testProgram2.RecordTypeId = programRecordTypeId;
        testProgram2.FocusType__c = 'Current Program';
        string sYear =  String.valueOf(System.today().year()); 


        insert new List<Program__c>{testProgram, testProgram2};

        User BI_Admin = TestDataFactory.createBIRunningUserWithCurrencyCode('USD', 'System Administrator');
        System.runAs(BI_Admin){
            //Create test data
            TestDataFactory.createMarketingPlanHierarchy();
            Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();
            
            //Get the Marketing Plan(s) that we'll be adding child Campaigns under.
            List<String> planNames = new List<String>();
            planNames.add('2018 US JBW American AMR SDP Legacy Missouri $20K');
            
            Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            MarketingPlan__c plan1 = plans.get('2018 US JBW American AMR SDP Legacy Missouri $20K');

            plan1.Year__c = sYear;
            update plan1;

            List<Campaign__c> bulkCampaigns = new List<Campaign__c>();
            for (integer i = 1; i <= 20; i++) {
                bulkCampaigns.add(TestDataFactory.MapCampaign(plan1.Id, 100.00, date.newinstance(integer.valueof(sYear), 1, 5), date.newinstance(integer.valueof(sYear), 12, 27), 'USD', tagsMap.get('BQ_Jim Beam White')));
            }
            
            for(Campaign__c camp : bulkCampaigns)
            {
                camp.Related_Priority__c = testProgram2.Id;
             }
            insert bulkCampaigns;
        }
    }

    @isTest static void BatchForecastSnapshotWeeklyTest() {
        Test.startTest();

            BatchForecastSnapshotWeekly forecastSnapshotWeekly = new BatchForecastSnapshotWeekly();
            forecastSnapshotWeekly.query = 'SELECT Id, Name, RecordType.Name, Sliced__c, Exchange_Account__c, Status__c FROM Account';
            String myQuery = 'SELECT Id, CurrencyIsoCode, (SELECT Id, Amount__c, Forecast_Month_Date__c, Forecast_Month__c FROM Campaign_Spend__r), Name, Brand_Quality__c, Brand_Quality__r.Name, ParentMarketingPlan__c, CampaignBalance__c, CampaignBrand__c, ForecastedCampaignSpend__c FROM Campaign__c';
            myQuery += ' WHERE Year__c =  \'' + String.valueOf(System.today().year()) + '\'';
            forecastSnapshotWeekly.query = myQuery;
            ID batchprocessid = Database.executeBatch(forecastSnapshotWeekly);

        Test.stopTest();

        List<MarketingPlan__c> marketingPlan = [SELECT Id FROM MarketingPlan__c WHERE Name = '2018 US JBW American AMR SDP Legacy Missouri $20K'];
        List<Forecast_Snapshot__c> forecastSnapshotList = [SELECT Id, Forecast_Amount__c, Marketing_Plan__c FROM Forecast_Snapshot__c];
        System.assertEquals(20, forecastSnapshotList.size(), 'Should return 20 Forecast_Snapshot__c records for the 20 inserted campaign records');
        System.assertEquals(100.00, forecastSnapshotList[0].Forecast_Amount__c, 'Should return 100.00 since each campaign had a 100.00 budget');
        System.assertEquals(marketingPlan[0].Id, forecastSnapshotList[0].Marketing_Plan__c, 'Should return the plan1 marketing plan Id since every campaign is related to that marketing plan');

        List<Forecast_Snapshot_Weekly__c> forecastSnapshotWeeklyList = [SELECT Id, Campaign_Forecast_Amount__c, Marketing_Plan__c FROM Forecast_Snapshot_Weekly__c];
        System.assertEquals(20, forecastSnapshotWeeklyList.size(), 'Should return 20 Forecast_Snapshot_Weekly__c records for the 20 inserted campaign records');
        System.assertEquals(100.00, forecastSnapshotWeeklyList[0].Campaign_Forecast_Amount__c, 'Should return 100.00 since each campaign had a 100.00 budget');
        System.assertEquals(marketingPlan[0].Id, forecastSnapshotWeeklyList[0].Marketing_Plan__c, 'Should return the plan1 marketing plan Id since every campaign is related to that marketing plan');
    }
}