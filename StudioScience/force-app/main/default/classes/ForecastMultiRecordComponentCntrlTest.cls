@isTest
private class ForecastMultiRecordComponentCntrlTest {
    /*
    *********************************** TESTING FORECASTS and SPEND **************************************
    */
    static integer currentYear = System.Today().year();  
    @testSetup static void setup() {

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
    
    static testmethod void testForecastGrid() {
        
        //Create test data
        TestDataFactory.createMarketingPlanHierarchy();
        Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();
        
        //  2018 US JBW American AMR SDP Heritage Arkansas $5K              
        List<String> planNames = new List<String>();
        planNames.add('2018 US JBW American AMR SDP Heritage Arkansas $5K'); 
        Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
        
        MarketingPlan__c parentRec = plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K');
        ID parentId = parentRec.Id;
        
        //Create a test Campaign, with 12 forecast months
        Campaign__c theTempCamp = TestDataFactory.MapCampaign(parentId, 1.20, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 12, 27), 'USD', tagsMap.get('BQ_Jim Beam White'));
        theTempCamp.Name = 'test forecasts and spend';
        theTempCamp.Related_Priority__c = getOtherProgram().Id;
        insert theTempCamp;
                        
        Test.startTest();
        
        //Test the Page controller extension and the Component Controller.
        ForecastMultiRecordEditor pageCont = new ForecastMultiRecordEditor(new ApexPages.StandardController(theTempCamp));
        
        //Simulate Component Attributes being set via binding to PageControllerExt properties.
        ForecastMultiRecordComponentController cont = new ForecastMultiRecordComponentController(); 
        cont.pageController = pageCont; 
        pageCont.setComponentController(cont);
        pageCont.RefreshPage();

        cont.sObjectType = pageCont.MysObj;     
        cont.ParentRecId = pageCont.MyRecId;
        cont.RelationField = pageCont.MyRelationField;
        cont.FieldList = pageCont.MyFieldList;
        cont.LabelOverrideFieldList = pageCont.MyLabelOverrideFieldList;
        cont.LabelOverrideTextList = pageCont.MyLabelOverrideTextList;
        cont.DefaultValueFieldList = pageCont.MyDefaultValueFieldList;
        cont.DefaultValueTextList = pageCont.MyDefaultValueTextList;
        cont.AllowAdd = pageCont.MyAllowAdd;
        cont.AllowEdit = pageCont.MyAllowEdit;
        cont.AllowDelete = pageCont.MyAllowDelete;
        cont.SearchFieldList = pageCont.MySearchFieldList;
        cont.DefaultRelatedListFilter = pageCont.MyFilter;
        cont.ShowAutoForecast = true;
            
        //Initiate the querying
        List<ForecastMultiRecordComponentController.ColumnWrapper> tmpColumnList = cont.ColumnList;
        List<ForecastMultiRecordComponentController.ObjectWrapper> tmpObjectList = cont.ObjectList;
        List<ForecastMultiRecordComponentController.QueryWhereFilter> tmpFilterList = cont.FilterList;
        
        system.assertEquals(12, cont.ObjectList.size(), 'Should be 12 Forecast records.');
        system.assertEquals(1, cont.FilterList.size());
        system.assertEquals(1, cont.TotalPages, 'Total Pages should be 1');
            
        //Test Picklist Filtering
        for (ForecastMultiRecordComponentController.QueryWhereFilter q : cont.FilterList) {     
            if (q.FieldName == 'Forecast_Month__c' && q.FieldType == 'Picklist') {              
                q.SelectedOptions = new List<String> { 'Jan', 'Feb', 'Mar' };
            }   
        }
        
        cont.DoSearch();
        system.assertEquals(1, cont.TotalPages, 'Total Pages should be 1 filtered Name to only a single campaign');
        system.assertEquals(3, cont.ObjectList.size(), '3 Forecasts should be found, Jan, Feb and Mar.');
                
        cont.ClearAllFilters();
        system.assertEquals(1, cont.TotalPages, 'Removed all filters, should be back to 1 pages.');
        system.assertEquals(12, cont.ObjectList.size(), '12 forecasts should be found after Clear All Filters.');
        
        
        unForecastedBudgetCampaignController unForecast = new unForecastedBudgetCampaignController(new ApexPages.StandardController(theTempCamp));
        unForecast.updateCampaign();

        //Test GetFriendlyMessage
        String returnMessage = cont.GetFriendlyMessage(null);
        System.assertEquals('An error occurred. Please try again or contact your administrator.', returnMessage, 'Should return generic system message');

        String returnMessage2 = cont.GetFriendlyMessage('FIELD_CUSTOM_VALIDATION_EXCEPTION, An error occured: []');
        System.assertEquals('An error occured', returnMessage2.trim(), 'Should return custom message that was passed to method minus the FIELD_CUSTOM_VALIDATION_EXCEPTION part of the string');

        //Test DoNext and DoPrevious, even though we expect them to do nothing because there's one page.
        cont.DoPrevious();
        system.assertEquals(12, tmpObjectList.size());
        cont.DoNext();
        system.assertEquals(12, tmpObjectList.size());
        
        //Test Toggle Filters
        system.assertEquals(false, cont.FilterVisible, 'Filters should be hidden by default');
        cont.DoFilterToggle();
        system.assertEquals(true, cont.FilterVisible, 'Filters should be visible after toggle.');
        cont.DoFilterToggle();
        system.assertEquals(false, cont.FilterVisible, 'Filters should be hidden after second toggle.');
        
        //Test EDIT ALL
        cont.ActionId = null;
        cont.DoEditAll();
        system.assertEquals(12, cont.ObjectList.size(), 'Should be 12 rows.');
        for (ForecastMultiRecordComponentController.ObjectWrapper w : cont.ObjectList) {
            system.assertEquals(true, w.IsEditMode, 'Every row should be in Edit Mode after DoEditAll()');
        }
        
        //Test CANCEL
        cont.DoCancel();
        system.assertEquals(12, cont.ObjectList.size(), 'Should be back to 12 rows.');
        for (ForecastMultiRecordComponentController.ObjectWrapper w : cont.ObjectList) {
            system.assertEquals(false, w.IsEditMode, 'No rows should be in Edit mode after Cancel');
        }
        
        //Test EDIT
        cont.ActionId = null;
        cont.DoEdit();
        for (ForecastMultiRecordComponentController.ObjectWrapper w : cont.ObjectList) {
            system.assertEquals(false, w.IsEditMode, 'No rows should be in Edit mode after DoEdit without an ActionId');
        }
        cont.ActionId = cont.ObjectList.get(1).obj.Id;
        cont.DoEdit();
        decimal tempAmount = (decimal)cont.ObjectList.get(1).obj.get('Amount__c') - 100.00;
        cont.ObjectList.get(1).obj.put('Amount__c', tempAmount);
        system.assertEquals(true, cont.ObjectList.get(1).IsEditMode, 'Second row should be in Edit Mode.');
        cont.DoSave();
        system.assertEquals(tempAmount, cont.ObjectList.get(1).obj.get('Amount__c'));
            
        //Test ADD 
        //ADDed rows get inserted above existing rows, but below other new rows. So the first
        //2 added rows should be in index 0 and 1, respectively.
        cont.DoAdd();
        system.assertEquals(13, cont.ObjectList.size(), 'Should now be 13 rows.');
        cont.DoAdd();
        system.assertEquals(14, cont.ObjectList.size(), 'Should now be 14 rows.');
        system.assertEquals('1', cont.ObjectList.get(0).AddedRowNumber);
        system.assertEquals('2', cont.ObjectList.get(1).AddedRowNumber);    
        
        cont.refreshPage();
        //Test REMOVE
        cont.ActionRowNumber = '1';
        cont.DoRemove();
        cont.ActionRowNumber = '2';
        cont.DoRemove();
        system.assertEquals(12, cont.ObjectList.size(), 'Should now be 12 rows after Removes.');  

         for (ForecastMultiRecordComponentController.ObjectWrapper w : cont.ObjectList) {
            if (w.obj.get('Forecast_Month__c') == 'Dec') {
                cont.ActionId = w.obj.Id;
                break;  
            }
        }
        cont.DoDelete();
        system.assertEquals(11, cont.ObjectList.size(), 'Should be 11 records after a successful delete.');

        cont.DoAdd();
        system.assertEquals(12, cont.ObjectList.size(), 'Should now be 12 rows.');
        system.assertEquals(true, cont.ObjectList.get(0).IsEditMode, 'Added row should be in Edit mode in the first row index.');
        cont.ObjectList.get(0).obj.put('Forecast_Month__c', 'Dec');  
        cont.ObjectList.get(0).obj.put('Amount__c',100.00);
        cont.ObjectList.get(0).obj.put('Recordtypeid', '012o0000000oaxaAAA');

        //Test SAVE ALL
        cont.DoSave();
        system.assertEquals(12, cont.ObjectList.size(), 'Should now be 12 fully saved Forecast records.');
        for (ForecastMultiRecordComponentController.ObjectWrapper w : cont.ObjectList) {
            system.assertEquals(false, w.IsEditMode, 'No rows should be in Edit mode after SaveAll');
        }
        
        //Test DELETE - none should delete when ActionId is null
        cont.ActionId = null;
        cont.DoDelete();
        system.assertEquals(12, cont.ObjectList.size(), 'Should still be 12 records after a bad delete.');

        cont.SortToggle();
        system.assertEquals('Name', cont.SortField, 'Should still be sorted by Name');
        system.assertEquals('desc NULLS LAST', cont.SortDirection, 'Sort Direction should now be desc NULL LAST');

        //Checkbox example CampaignType__c
        ForecastMultiRecordComponentController.QueryWhereFilter campaignSpendTypeFilter = cont.FilterList.get(0);
        system.assertEquals(campaignSpendTypeFilter.Options.size(), campaignSpendTypeFilter.SelectedOptions.size());      
        //Simulate deselecting a checkbox
        campaignSpendTypeFilter.SelectedOptions.remove(0);
        system.assertEquals(campaignSpendTypeFilter.Options.size() - 1, campaignSpendTypeFilter.SelectedOptions.size());
        //Simualte do toggle all, which should check them all 
        cont.ActionFilterFieldName = 'Forecast_Month__c';
        cont.DoToggleCheckboxFilter();
        system.assertEquals(campaignSpendTypeFilter.Options.size(), campaignSpendTypeFilter.SelectedOptions.size());

        Test.stopTest();
    }

    static testmethod void testAutoReforecast() {
        //Create test data
        TestDataFactory.createMarketingPlanHierarchy();
        Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();
        
        //  2018 US JBW American AMR SDP Heritage Arkansas $5K              
        List<String> planNames = new List<String>();
        planNames.add('2018 US JBW American AMR SDP Heritage Arkansas $5K'); 
        Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
        
        MarketingPlan__c parentRec = plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K');
        ID parentId = parentRec.Id;
        
        //Create a test Campaign, with 12 forecast months
        Campaign__c theTempCamp = TestDataFactory.MapCampaign(parentId, 1000, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 12, 27), 'USD', tagsMap.get('BQ_Jim Beam White'));
        theTempCamp.Name = 'test forecasts and spend';
        theTempCamp.Related_Priority__c = getOtherProgram().Id;
        insert theTempCamp;

        Test.startTest();
        
            //Test the Page controller extension and the Component Controller.
            ForecastMultiRecordEditor pageCont = new ForecastMultiRecordEditor(new ApexPages.StandardController(theTempCamp));
            
            //Simulate Component Attributes being set via binding to PageControllerExt properties.
            ForecastMultiRecordComponentController cont = new ForecastMultiRecordComponentController(); 
            cont.pageController = pageCont; 
            pageCont.setComponentController(cont);
            pageCont.RefreshPage();

            cont.sObjectType = pageCont.MysObj;     
            cont.ParentRecId = pageCont.MyRecId;
            cont.RelationField = pageCont.MyRelationField;
            cont.FieldList = pageCont.MyFieldList;
            cont.LabelOverrideFieldList = pageCont.MyLabelOverrideFieldList;
            cont.LabelOverrideTextList = pageCont.MyLabelOverrideTextList;
            cont.DefaultValueFieldList = pageCont.MyDefaultValueFieldList;
            cont.DefaultValueTextList = pageCont.MyDefaultValueTextList;
            cont.AllowAdd = pageCont.MyAllowAdd;
            cont.AllowEdit = pageCont.MyAllowEdit;
            cont.AllowDelete = pageCont.MyAllowDelete;
            cont.SearchFieldList = pageCont.MySearchFieldList;
            cont.DefaultRelatedListFilter = pageCont.MyFilter;
            cont.ShowAutoForecast = true;
                
            //Initiate the querying
            List<ForecastMultiRecordComponentController.ColumnWrapper> tmpColumnList = cont.ColumnList;
            List<ForecastMultiRecordComponentController.ObjectWrapper> tmpObjectList = cont.ObjectList;
            List<ForecastMultiRecordComponentController.QueryWhereFilter> tmpFilterList = cont.FilterList;
            
            system.assertEquals(12, cont.ObjectList.size(), 'Should be 12 Forecast records.');
            system.assertEquals(1, cont.FilterList.size());
            system.assertEquals(1, cont.TotalPages, 'Total Pages should be 1');

            theTempCamp.PlannedCampaignSpend__c = 0;
            theTempCamp.Comments__c = 'Budget removed';
            update theTempCamp;

            List<Campaign_Spend__c> forecastListWithoutBudget = [SELECT Amount__c FROM Campaign_Spend__c WHERE ParentCampaign__c = :theTempCamp.Id];
            Decimal totalAmountForecastedWithoutBudget = 0;
            for(Campaign_Spend__c forecast: forecastListWithoutBudget){
                totalAmountForecastedWithoutBudget += forecast.Amount__c;
            }

            System.assertEquals(0, totalAmountForecastedWithoutBudget, 'Should return 0 since the forecasts for that campaign will be zeroed out when the budget is zeroed out');
            theTempCamp.PlannedCampaignSpend__c = 1000;
            theTempCamp.Comments__c = 'Budget added';
            update theTempCamp;
            cont.DoAutoForecast();

            List<Campaign_Spend__c> forecastListWithBudget = [SELECT Amount__c FROM Campaign_Spend__c WHERE ParentCampaign__c = :theTempCamp.Id];
            Decimal totalAmountForecastedWithBudget = 0;
            for(Campaign_Spend__c forecast: forecastListWithBudget){
                totalAmountForecastedWithBudget += forecast.Amount__c;
            }

            System.assertEquals(1000, totalAmountForecastedWithBudget, 'Should return 1000 since the DoAutoForecast method automatically straight lined the budget for the active months');
        
        Test.stopTest();
    }
}