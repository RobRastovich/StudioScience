@isTest
private class MultiRecordComponentControllerTests {
    static integer currentYear = System.Today().year();
    
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

    static testmethod void testMarketingPlanGrid() {
        
        //Create test data
        TestDataFactory.createMarketingPlanHierarchy();
        Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();
        
        //2018 US JBW American AMR SDP Heritage $30K
        //  2018 US JBW American AMR SDP Heritage Arkansas $5K
        //  2018 US JBW American AMR SDP Heritage Kansas $5K
        //  2018 US JBW American AMR SDP Heritage Louisana $15K
        
        List<String> planNames = new List<String>();
        planNames.add('2018 US JBW American AMR SDP Heritage $30K');
        planNames.add('2018 US JBW American AMR SDP Heritage Arkansas $5K'); 
        planNames.add('2018 US JBW American AMR SDP Heritage Kansas $5K'); 
        planNames.add('2018 US JBW American AMR SDP Heritage Louisana $15K');
        Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
        
        MarketingPlan__c parentRec = plans.get('2018 US JBW American AMR SDP Heritage $30K');
        ID parentId = parentRec.Id;
        
        //Test the Page controller extension and the Component Controller.
        MarketingPlanMultiRecordEditor pageCont = new MarketingPlanMultiRecordEditor(new ApexPages.StandardController(parentRec));
        
        //Simulate Component Attributes being set via binding to PageControllerExt properties.
        MultiRecordComponentController cont = new MultiRecordComponentController();
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
        cont.ShowCreateIOButton = false;
        cont.SearchFieldList = pageCont.MySearchFieldList;
        
        Test.startTest();
            
        //Initiate the querying
        List<MultiRecordComponentController.ColumnWrapper> tmpColumnList = cont.ColumnList;
        List<MultiRecordComponentController.QueryWhereFilter> tmpFilterList = cont.FilterList;
        List<MultiRecordComponentController.ObjectWrapper> tmpObjectList = cont.ObjectList;
        
        
        system.assertEquals(3, tmpObjectList.size());
        system.assertEquals(15, tmpColumnlist.size());
        system.assertEquals(3, tmpFilterList.size());
        system.assertEquals(true, cont.IsFilterable);
        system.assertEquals(1, cont.TotalPages, 'Total Pages should be 1');
        
        //Test DoNext and DoPrevious, even though we expect them to do nothing because there's one page.
        cont.DoPrevious();
        system.assertEquals(3, tmpObjectList.size());
        cont.DoNext();
        system.assertEquals(3, tmpObjectList.size());
        
        //Test Toggle Filters
        system.assertEquals(false, cont.FilterVisible, 'Filters should be hidden by default');
        cont.DoFilterToggle();
        system.assertEquals(true, cont.FilterVisible, 'Filters should be visible after toggle.');
        cont.DoFilterToggle();
        system.assertEquals(false, cont.FilterVisible, 'Filters should be hidden after second toggle.');
        
        //Test EDIT ALL
        cont.ActionId = null;
        cont.DoEditAll();
        system.assertEquals(3, cont.ObjectList.size(), 'Should be 3 rows.');
        for (MultiRecordComponentController.ObjectWrapper w : cont.ObjectList) {
            system.assertEquals(true, w.IsEditMode, 'Every row should be in Edit Mode after DoEditAll()');
        }
        
        //Test CANCEL
        cont.DoCancel();
        system.assertEquals(3, cont.ObjectList.size(), 'Should be back to 3 rows.');
        for (MultiRecordComponentController.ObjectWrapper w : cont.ObjectList) {
            system.assertEquals(false, w.IsEditMode, 'No rows should be in Edit mode after Cancel');
        }
        
        //Test EDIT
        cont.ActionId = null;
        cont.DoEdit();
        for (MultiRecordComponentController.ObjectWrapper w : cont.ObjectList) {
            system.assertEquals(false, w.IsEditMode, 'No rows should be in Edit mode after DoEdit without an ActionId');
        }
        cont.ActionId = cont.ObjectList.get(1).obj.Id;
        cont.DoEdit();
        decimal tempBudget = (decimal)cont.ObjectList.get(1).obj.get('Budget__c') - 100.00;
        cont.ObjectList.get(1).obj.put('Budget__c', tempBudget);
        cont.ObjectList.get(1).obj.put('Comments__c', 'Test Comments'); 
        system.assertEquals(true, cont.ObjectList.get(1).IsEditMode, 'Second row should be in Edit Mode.');
        cont.DoSave();
        system.assertEquals(tempBudget, cont.ObjectList.get(1).obj.get('Budget__c'));
            
        //Test ADD 
        //ADDed rows get inserted above existing rows, but below other new rows. So the first
        //2 added rows should be in index 0 and 1, respectively.
        cont.DoAdd();
        system.assertEquals(4, cont.ObjectList.size(), 'Should now be 4 rows.');
        cont.DoAdd();
        system.assertEquals(5, cont.ObjectList.size(), 'Should now be 5 rows.');
        system.assertEquals('1', cont.ObjectList.get(0).AddedRowNumber);
        system.assertEquals('2', cont.ObjectList.get(1).AddedRowNumber);    
        
        //Test REMOVE
        cont.ActionRowNumber = '1';
        cont.DoRemove();
        cont.ActionRowNumber = '2';
        cont.DoRemove();
        system.assertEquals(3, cont.ObjectList.size(), 'Should now be 3 rows after Removes.');  
        
        cont.DoAdd();
        cont.DoCancel();
        system.assertEquals(3, cont.ObjectList.size(), 'Should now be 3 rows after Removes.');  
            
        cont.DoAdd();
        system.assertEquals(4, cont.ObjectList.size(), 'Should now be 4 rows.');
        system.assertEquals(true, cont.ObjectList.get(0).IsEditMode, 'Added row should be in Edit mode in the first row index.');
        cont.ObjectList.get(0).obj.put('Name', 'ZZZ TEST MP');  
        cont.ObjectList.get(0).obj.put('ParentMarketingPlan__c',parentId);
        cont.ObjectList.get(0).obj.put('Territory__c', tagsMap.get('Georgia'));
        cont.ObjectList.get(0).obj.put('Year__c','2018');
        cont.ObjectList.get(0).obj.put('Brand__c', cont.ObjectList.get(1).obj.get('Brand__c'));
        cont.ObjectList.get(0).obj.put('Country__c', 'US');
        cont.ObjectList.get(0).obj.put('Region__c', 'American');
        cont.ObjectList.get(0).obj.put('Division__c', 'AMR SDP Heritage Division');     
        cont.ObjectList.get(0).obj.put('Budget__c', 0.0);
        //cont.ObjectList.get(0).obj.put('RecordTypeId', cont.ObjectList.get(1).obj.get('RecordTypeId'));
        
        //Test SAVE ALL
        cont.DoSave();
        system.assertEquals(4, cont.ObjectList.size(), 'Should now be 4 fully saved MPs.');
        for (MultiRecordComponentController.ObjectWrapper w : cont.ObjectList) {
            system.assertEquals(false, w.IsEditMode, 'No rows should be in Edit mode after SaveAll');
        }
        
        //Test SAVE that should fail. (Changing Budget without adding Comments should fail.)
        cont.ActionId = cont.ObjectList.get(1).obj.Id;
        cont.DoEdit();
        cont.ObjectList.get(1).obj.put('Budget__c', 100000000000.0);
        cont.DoSave();
        system.assertEquals(4, cont.ObjectList.size());
        //Make sure an Error message was added to the page.
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        system.assert(msgs.size() > 0, 'Should have found an error message updating the Budget with no comments.');
        
        cont.DoCancel();
        
        //Test DELETE - none should delete when ActionId is null
        cont.ActionId = null;
        cont.DoDelete();
        system.assertEquals(4, cont.ObjectList.size(), 'Should still be 4 records after a bad delete.');
        for (MultiRecordComponentController.ObjectWrapper w : cont.ObjectList) {
            
            if (w.obj.get('Name') == 'ZZZ TEST MP') {
                cont.ActionId = w.obj.Id;
                break;  
            }
        }
        cont.DoDelete();
        system.assertEquals(3, cont.ObjectList.size(), 'Should be 3 records after a successful delete.');
        
        //Test Sorting
        system.assertEquals('Name', cont.SortField, 'MarketingPlan should be initially sorted by Name');
        system.assertEquals('asc', cont.SortDirection, 'asc should be initial sort direction.');        
        cont.SortToggle();
        system.assertEquals('Name', cont.SortField, 'Should still be sorted by Name');
        system.assertEquals('desc NULLS LAST', cont.SortDirection, 'Sort Direction should now be desc NULL LAST');
        cont.SortField = 'Territory__c';
        cont.SortToggle();
        system.assertEquals('Territory__c', cont.SortField, 'Should now be sorted by Territory');
        system.assertEquals('asc', cont.SortDirection, 'Sort Direction should now be reset to asc');
        cont.SortField = 'Name';
        cont.SortToggle();
        system.assertEquals('Name', cont.SortField, 'Finally sorted back on Name.');
        system.assertEquals('asc', cont.SortDirection, 'Sort Direction should be reset to asc');
        
        Test.stopTest();
            
    }
    
    /*
    *********************************** TESTING CAMPAIGNS **************************************
    */
    
    static testmethod void testCampaignGrid() {
        Id otherProgramId = getOtherProgram().Id;
        
        //Create test data
        TestDataFactory.createMarketingPlanHierarchy();
        Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();
        
        //  2018 US JBW American AMR SDP Heritage Arkansas $5K              
        List<String> planNames = new List<String>();
        planNames.add('2018 US JBW American AMR SDP Heritage Arkansas $5K'); 
        Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
        
        MarketingPlan__c parentRec = plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K');
        parentRec.SAP_Controlling_Area__c = '2000';
        parentRec.SAP_Company_Code__c = 'US30';
        parentRec.SAP_Cost_Center__c = 'US30NA33';
        update parentRec;
        
        ID parentId = parentRec.Id;
        
        //Create 100 test Campaigns
        List<Campaign__c> bulkCampaigns = new List<Campaign__c>();
        for (Integer i = 1; i <= 8; i++) {
            Campaign__c theTempCamp = TestDataFactory.MapCampaign(parentId, 1.00, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 1, 27), 'USD', tagsMap.get('BQ_Jim Beam White'));
            theTempCamp.Name = 'test' + i + 'test';
            theTempCamp.Related_Priority__c = otherProgramId;
            bulkCampaigns.add(theTempCamp);
        }   
        insert bulkCampaigns;
            
        Test.startTest();
        
        //Test the Page controller extension and the Component Controller.
        CampaignMultiRecordEditor pageCont = new CampaignMultiRecordEditor(new ApexPages.StandardController(parentRec));
        
        //Simulate Component Attributes being set via binding to PageControllerExt properties.
        MultiRecordComponentController cont = new MultiRecordComponentController();   
        cont.pageController = pageCont; 
        pageCont.setComponentController(cont);
        pageCont.RefreshPage();
        system.assertEquals(pageCont.getMyComponentController(), cont);
            
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
        cont.ShowCreateIOButton = pageCont.MyAllowCreateIO;
        cont.SearchFieldList = pageCont.MySearchFieldList;
            
        //Initiate the querying
        List<MultiRecordComponentController.ColumnWrapper> tmpColumnList = cont.ColumnList;
        List<MultiRecordComponentController.ObjectWrapper> tmpObjectList = cont.ObjectList;
        List<MultiRecordComponentController.QueryWhereFilter> tmpFilterList = cont.FilterList;
        
        system.assertEquals(8, tmpObjectList.size(), 'Should be 10 Campaigns for this MP');
        system.assertEquals(5, tmpFilterList.size());
        system.assertEquals(1, cont.TotalPages, 'Total Pages should be 1 because 8 / 25 = 1');
        
        //Test DoNext and DoPrevious, even though we expect them to do nothing because there's one page.
        system.assertEquals(8, cont.ObjectList.size());
        
        system.assertEquals(1, cont.StdSetController.getPageNumber(), 'Should be on Page 1.');
        cont.DoNext();
        system.assertEquals(1, cont.StdSetController.getPageNumber(), 'Should still be on Page 1.');
        system.assertEquals(8, tmpObjectList.size());
        cont.DoPrevious();
        system.assertEquals(1, cont.StdSetController.getPageNumber(), 'Should remain on page 1.');
        
        //Test IO Creation
        for (Integer i = 0; i < 5; i++) {
            cont.ObjectList.get(i).IsSelected = true;
        }
        cont.UpdateSelectedSet();
        cont.DoCreateIOs();
        for (Integer i = 0; i < 5; i++) {
            system.assertNotEquals('', cont.ObjectList.get(i).obj.get('IOCode__c'), 'IO Code should exist');
        }
        //Test IO Creation exceptions.
        cont.ObjectList.get(0).IsSelected = true;
        cont.UpdateSelectedSet();
        cont.DoCreateIOs();
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        system.assert(msgs.size() == 0, 'Should have found an error creating an IO for a campaign that has one already.');
        //Test IO with no checkboxes checked.
        for (Integer i = 0; i < cont.ObjectList.size(); i++) {
            cont.ObjectList.get(i).IsSelected = false;
        }
        cont.DoCancel();
        cont.UpdateSelectedSet();
        cont.DoCreateIOs();
        msgs = ApexPages.getMessages();
        system.assert(msgs.size() > 0, 'Should have found message: Please select at least one row using checkboxes before Creating IOs.');
        cont.DoCancel();
        cont.refreshPage();
        //Test Toggle Filters
        system.assertEquals(false, cont.FilterVisible, 'Filters should be hidden by default');
        cont.DoFilterToggle();
        system.assertEquals(true, cont.FilterVisible, 'Filters should be visible after toggle.');
        cont.DoFilterToggle();
        system.assertEquals(false, cont.FilterVisible, 'Filters should be hidden after second toggle.');
                        
        //Test Filtering
        //List<MultiRecordComponentController.QueryWhereFilter> tmpFilterList = cont.FilterList;
        system.assertEquals(5, cont.FilterList.size());
        for (MultiRecordComponentController.QueryWhereFilter q : cont.FilterList) {     
            if (q.FieldName == 'Name') {
                q.FilterText = 'test5test';
            }   
        }
        
        cont.DoSearch();
        system.assertEquals(1, cont.TotalPages, 'Total Pages should be 1 filtered Name to only a single campaign');
        system.assertEquals(1, cont.ObjectList.size(), 'Only one record should be found');
        
        cont.ClearAllFilters();
        system.assertEquals(1, cont.TotalPages, 'Removed all filters, should be back to 1 pages.');
        
        //Checkbox example CampaignType__c
        MultiRecordComponentController.QueryWhereFilter campaignTypeFilter = cont.FilterList.get(2);
        system.assertEquals(campaignTypeFilter.Options.size(), campaignTypeFilter.SelectedOptions.size());      
        //Simulate deselecting a checkbox
        campaignTypeFilter.SelectedOptions.remove(0);
        system.assertEquals(campaignTypeFilter.Options.size() - 1, campaignTypeFilter.SelectedOptions.size());
        //Simualte do toggle all, which should check them all 
        cont.ActionFilterFieldName = 'CampaignType__c';
        cont.DoToggleCheckboxFilter();
        system.assertEquals(campaignTypeFilter.Options.size(), campaignTypeFilter.SelectedOptions.size());
        //Simulate deselect all
        cont.ActionFilterFieldName = 'CampaignType__c';
        cont.DoToggleCheckboxFilter();
        system.assertEquals(0, campaignTypeFilter.SelectedOptions.size());
        //Simulate check all
        cont.ActionFilterFieldName = 'CampaignType__c';
        cont.DoToggleCheckboxFilter();
        system.assertEquals(campaignTypeFilter.Options.size(), campaignTypeFilter.SelectedOptions.size());
        
        Test.stopTest();
            
    }
    
    static testmethod void testCampaignGridWBS(){
        Id otherProgramId = getOtherProgram().Id;
        //Create test data
        TestDataFactory.createWBSAUSMarketingPlanHierarchy();
        Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();

        //  2018 US JBW American AMR SDP Heritage Arkansas $5K              
        List<String> planNames = new List<String>();
        planNames.add('2017 AUS CCL Australian CCL BTL NSW $5K'); 
        Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);   
        
        MarketingPlan__c parentRec = plans.get('2017 AUS CCL Australian CCL BTL NSW $5K');
        parentRec.SAP_Controlling_Area__c = '6000';
        parentRec.SAP_Company_Code__c = 'AU60';
        parentRec.SAP_Cost_Center__c = 'Y';
        update parentRec;
        
        ID parentId = parentRec.Id;

        //Create 100 test Campaigns
        List<Campaign__c> bulkCampaigns = new List<Campaign__c>();
        for (Integer i = 1; i <= 20; i++) {
            Campaign__c theTempCamp = TestDataFactory.MapCampaign(parentId, 1.00, date.newinstance(2017, 1, 5), date.newinstance(2017, 1, 27), 'AUD', tagsMap.get('BQ_Canadian Club'));
            theTempCamp.Name = 'test' + i + 'test';
            theTempCamp.Related_Priority__c = otherProgramId;
            bulkCampaigns.add(theTempCamp);
        }   
        insert bulkCampaigns;
            
        Test.startTest();
        
        //Test the Page controller extension and the Component Controller.
        CampaignMultiRecordEditor pageCont = new CampaignMultiRecordEditor(new ApexPages.StandardController(parentRec));

        //Simulate Component Attributes being set via binding to PageControllerExt properties.
        MultiRecordComponentController cont = new MultiRecordComponentController();   
        cont.pageController = pageCont; 
        pageCont.setComponentController(cont);
        pageCont.RefreshPage();
        system.assertEquals(pageCont.getMyComponentController(), cont);
            
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
        cont.ShowCreateIOButton = pageCont.MyAllowCreateIO;
        cont.ShowCreateWBSButton = pageCont.MyAllowCreateWBS;        
        cont.SearchFieldList = pageCont.MySearchFieldList;

        //Initiate the querying
        List<MultiRecordComponentController.ColumnWrapper> tmpColumnList = cont.ColumnList;
        List<MultiRecordComponentController.ObjectWrapper> tmpObjectList = cont.ObjectList;
        List<MultiRecordComponentController.QueryWhereFilter> tmpFilterList = cont.FilterList;
        
        system.assertEquals(20, tmpObjectList.size(), 'Should be 200 Campaigns for this MP, but only 25 at a time.');
        system.assertEquals(5, tmpFilterList.size());
        system.assertEquals(1, cont.TotalPages, 'Total Pages should be 1 because 20 / 25 = 1');
        
        //Test DoNext and DoPrevious, even though we expect them to do nothing because there's one page.
        system.assertEquals(20, cont.ObjectList.size());
        
        system.assertEquals(1, cont.StdSetController.getPageNumber(), 'Should be on Page 1.');
        cont.DoNext();
        system.assertEquals(1, cont.StdSetController.getPageNumber(), 'Should still be on Page 1.');
        system.assertEquals(20, tmpObjectList.size());
        cont.DoPrevious();
        system.assertEquals(1, cont.StdSetController.getPageNumber(), 'Should remain on page 1.');
        
        //Test IO Creation
        for (Integer i = 0; i < 5; i++) {
            cont.ObjectList.get(i).IsSelected = true;
        }
        cont.UpdateSelectedSet();
        cont.DoCreateWBSCodes();
        for (Integer i = 0; i < 5; i++) {
            system.assertNotEquals('', cont.ObjectList.get(i).obj.get('WBSCode__c'), 'WBS Code should exist');
        }
        //Test IO Creation exceptions.
        cont.ObjectList.get(0).IsSelected = true;
        cont.UpdateSelectedSet();
        cont.DoCreateWBSCodes();
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        system.assert(msgs.size() == 0, 'Should have found an error creating an WBS for a campaign that has one already.');
        //Test IO with no checkboxes checked.
        for (Integer i = 0; i < cont.ObjectList.size(); i++) {
            cont.ObjectList.get(i).IsSelected = false;
        }
        cont.DoCancel();
        cont.UpdateSelectedSet();
        cont.DoCreateWBSCodes();
        msgs = ApexPages.getMessages();
        system.assert(msgs.size() > 0, 'Should have found message: Please select at least one row using checkboxes before Creating WBS Codes.');
        cont.DoCancel();
            
        //Test Toggle Filters
        system.assertEquals(false, cont.FilterVisible, 'Filters should be hidden by default');
        cont.DoFilterToggle();
        system.assertEquals(true, cont.FilterVisible, 'Filters should be visible after toggle.');
        cont.DoFilterToggle();
        system.assertEquals(false, cont.FilterVisible, 'Filters should be hidden after second toggle.'); 

        pageCont.configureGrid(false);               
    }

    static testmethod void testCampaignIOGrid2017_2018GL() {
        
        //Create test data
        TestDataFactory.createTags();
        Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();
        Map<String, ID> mpTypes = BI_UtilityLogic.getRecordTypeNamesByIds(BI_Constants.OBJECT_MARKETINGPLAN, new List<String> {BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED});
        Id mpRTId = mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED);
        Id brandTag = tagsMap.get('Sauza');
        Id bqTag = tagsMap.get('BQ_Sauza');
        Id terrTag = tagsMap.get('Illinois');
        List<Tags__c> activeTags = new List<Tags__c>{
            new Tags__c(Id=brandTag, Active__c=true),
            new Tags__c(Id=bqTag, Active__c=true),
            new Tags__c(Id=terrTag, Active__c=true)
        };
        update activeTags;
        MarketingPlan__c testMP2017 = TestDataFactory.MapMarketingPlan('Test 2017 IO MP', '2017', 'US', 'Midwest', 'Central', terrTag, bqTag, null, 100000, mpRTId);
        testMP2017.SAP_Controlling_Area__c = '2000';
        testMP2017.SAP_Company_Code__c = 'US30';
        testMP2017.SAP_Cost_Center__c = 'US30NA33';
        testMP2017.Brand__c = brandTag;
        MarketingPlan__c testMP2018 = TestDataFactory.MapMarketingPlan('Test 2018 IO MP', '2018', 'US', 'Midwest', 'Central', terrTag, bqTag, null, 100000, mpRTId);
        testMP2018.SAP_Controlling_Area__c = '2000';
        testMP2018.SAP_Company_Code__c = 'US30';
        testMP2018.SAP_Cost_Center__c = 'US30NA33';
        testMP2018.Brand__c = brandTag;
        insert new List<MarketingPlan__c>{testMP2017, testMP2018};

        Test.startTest();
        //Create Test 2017 Campaign Data (Original GLs)
        /*----------------------------------------------------------------------------*/
        //Test the Page controller extension and the Component Controller.
        CampaignMultiRecordEditor pageCont2017 = new CampaignMultiRecordEditor(new ApexPages.StandardController(testMP2017));        
        
        //Simulate Component Attributes being set via binding to PageControllerExt properties.
        MultiRecordComponentController cont2017 = new MultiRecordComponentController();   
        cont2017.pageController = pageCont2017; 
        pageCont2017.setComponentController(cont2017);
        pageCont2017.RefreshPage();
        system.assertEquals(pageCont2017.getMyComponentController(), cont2017);
            
        cont2017.sObjectType = pageCont2017.MysObj;     
        cont2017.ParentRecId = pageCont2017.MyRecId;
        cont2017.RelationField = pageCont2017.MyRelationField;
        cont2017.FieldList = pageCont2017.MyFieldList;
        cont2017.LabelOverrideFieldList = pageCont2017.MyLabelOverrideFieldList;
        cont2017.LabelOverrideTextList = pageCont2017.MyLabelOverrideTextList;
        cont2017.DefaultValueFieldList = pageCont2017.MyDefaultValueFieldList;
        cont2017.DefaultValueTextList = pageCont2017.MyDefaultValueTextList;
        
        cont2017.AllowAdd = pageCont2017.MyAllowAdd;
        cont2017.AllowEdit = pageCont2017.MyAllowEdit;
        cont2017.AllowDelete = pageCont2017.MyAllowDelete;
        cont2017.ShowCreateIOButton = pageCont2017.MyAllowCreateIO;
        cont2017.SearchFieldList = pageCont2017.MySearchFieldList;
            
        //Initiate the querying
        List<String> DefaultValueFieldList2017 = pageCont2017.MyDefaultValueFieldList;
        List<String> DefaultValueTextList2017 = pageCont2017.MyDefaultValueTextList;
        Map<String, String> DefaultValueMap2017 = new map<String, String>();
        if (DefaultValueFieldList2017 != null && DefaultValueTextList2017 != null) {
            for (Integer i=0; i < DefaultValueFieldList2017.size(); i++) {
                if (i < DefaultValueTextList2017.size()) {
                    DefaultValueMap2017.put(DefaultValueFieldList2017[i], DefaultValueTextList2017[i]);
                }
            }
        }
        //Create Test 2018 Campaign Data (New GLs)
        /*----------------------------------------------------------------------------*/
        //Test the Page controller extension and the Component Controller.
        CampaignMultiRecordEditor pageCont2018 = new CampaignMultiRecordEditor(new ApexPages.StandardController(testMP2018));        
        
        //Simulate Component Attributes being set via binding to PageControllerExt properties.
        MultiRecordComponentController cont2018 = new MultiRecordComponentController();   
        cont2018.pageController = pageCont2018; 
        pageCont2018.setComponentController(cont2018);
        pageCont2018.RefreshPage();
        system.assertEquals(pageCont2018.getMyComponentController(), cont2018);
            
        cont2018.sObjectType = pageCont2018.MysObj;     
        cont2018.ParentRecId = pageCont2018.MyRecId;
        cont2018.RelationField = pageCont2018.MyRelationField;
        cont2018.FieldList = pageCont2018.MyFieldList;
        cont2018.LabelOverrideFieldList = pageCont2018.MyLabelOverrideFieldList;
        cont2018.LabelOverrideTextList = pageCont2018.MyLabelOverrideTextList;
        cont2018.DefaultValueFieldList = pageCont2018.MyDefaultValueFieldList;
        cont2018.DefaultValueTextList = pageCont2018.MyDefaultValueTextList;
        
        cont2018.AllowAdd = pageCont2018.MyAllowAdd;
        cont2018.AllowEdit = pageCont2018.MyAllowEdit;
        cont2018.AllowDelete = pageCont2018.MyAllowDelete;
        cont2018.ShowCreateIOButton = pageCont2018.MyAllowCreateIO;
        cont2018.SearchFieldList = pageCont2018.MySearchFieldList;

        List<String> DefaultValueFieldList2018 = pageCont2018.MyDefaultValueFieldList;
        List<String> DefaultValueTextList2018 = pageCont2018.MyDefaultValueTextList;
        Map<String, String> DefaultValueMap2018 = new map<String, String>();
        if (DefaultValueFieldList2018 != null && DefaultValueTextList2018 != null) {
            for (Integer i=0; i < DefaultValueFieldList2018.size(); i++) {
                if (i < DefaultValueTextList2018.size()) {
                    DefaultValueMap2018.put(DefaultValueFieldList2018[i], DefaultValueTextList2018[i]);
                }
            }
        }
        //Actual Assertions
        /*----------------------------------------------------------------------------*/
        Id campaignRecordTypeId = DefaultValueMap2018.get('RecordTypeId');
        RecordType campaignRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE Id =: campaignRecordTypeId];

        MarketingPlan__c requeriedMP2017 = [SELECT Id, Year__c FROM MarketingPlan__c WHERE Id =: testMP2017.Id];
        System.assertEquals('2017', requeriedMP2017.Year__c, 'We would expect the year of this Marketing Plan to by 2017.');
        System.assertEquals(true, pageCont2017.MyAllowCreateIO, 'We would expect that this page would allow the creation of IO codes.');
        System.assertEquals(1, DefaultValueFieldList2017.size(), 'We would expect there to be one parameter (Description) for a 2017 Marketing Plan.');
        System.assertEquals(1, DefaultValueTextList2017.size(), 'We would expect there to be one values (Description value) for a 2017 Marketing Plan.');
        System.assertEquals(false, DefaultValueMap2017.containsKey('RecordTypeId'), 'We would expect that RecordTypeId is NOT a key in the map.');
        System.assertEquals(true, DefaultValueMap2017.containsKey('Description__c'), 'We would expect that Description__c is a key in the map.');

        MarketingPlan__c requeriedMP2018 = [SELECT Id, Year__c FROM MarketingPlan__c WHERE Id =: testMP2018.Id];
        System.assertEquals('2018', requeriedMP2018.Year__c, 'We would expect the year of this Marketing Plan to by 2018.');
        System.assertEquals(true, pageCont2018.MyAllowCreateIO, 'We would expect that this page would allow the creation of IO codes.');
        System.assertEquals(2, DefaultValueFieldList2018.size(), 'We would expect there to be two parameters (Description and RecordTypeId) for a 2018 Marketing Plan.');
        System.assertEquals(2, DefaultValueTextList2018.size(), 'We would expect there to be two values (Description and RecordTypeId values) for a 2018 Marketing Plan.');
        System.assertEquals(true, DefaultValueMap2018.containsKey('RecordTypeId'), 'We would expect that RecordTypeId is a key in the map.');
        System.assertEquals(true, DefaultValueMap2018.containsKey('Description__c'), 'We would expect that Description__c is a key in the map.');
        System.assertEquals(BI_Constants.RECORDTYPE_CAMPAIGN_IO_2018, campaignRecordType.DeveloperName, 'We would expect that the Record Type set as default would be the Campaign IO 2018 Record Type.');
        System.assertEquals(campaignRecordType.Id, DefaultValueMap2018.get('RecordTypeId'), 'We would expect that the Record Type Id would be the same as that of the Default Value Mapping.');
        /*----------------------------------------------------------------------------*/
        Test.stopTest();
    }
    
    /*
    *********************************** TESTING FORECASTS and SPEND **************************************
    */
    
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
        CampaignSpendMultiRecordEditor pageCont2 = new CampaignSpendMultiRecordEditor(new ApexPages.StandardController(theTempCamp));
        
        
        //Simulate Component Attributes being set via binding to PageControllerExt properties.
        MultiRecordComponentController cont = new MultiRecordComponentController(); 
        cont.pageController = pageCont; 
        pageCont.setComponentController(cont);
        pageCont.RefreshPage();
        pageCont2.RefreshPage();
            
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
        cont.ShowCreateIOButton = false;
        cont.SearchFieldList = pageCont.MySearchFieldList;
        cont.DefaultRelatedListFilter = pageCont.MyFilter;
            
        //Initiate the querying
        List<MultiRecordComponentController.ColumnWrapper> tmpColumnList = cont.ColumnList;
        List<MultiRecordComponentController.ObjectWrapper> tmpObjectList = cont.ObjectList;
        List<MultiRecordComponentController.QueryWhereFilter> tmpFilterList = cont.FilterList;
        
        system.assertEquals(12, cont.ObjectList.size(), 'Should be 12 Forecast records.');
        system.assertEquals(1, cont.FilterList.size());
        system.assertEquals(1, cont.TotalPages, 'Total Pages should be 1');
            
        //Test Picklist Filtering
        for (MultiRecordComponentController.QueryWhereFilter q : cont.FilterList) {     
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
            MultiRecordComponentController cont = new MultiRecordComponentController(); 
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
            List<MultiRecordComponentController.ColumnWrapper> tmpColumnList = cont.ColumnList;
            List<MultiRecordComponentController.ObjectWrapper> tmpObjectList = cont.ObjectList;
            List<MultiRecordComponentController.QueryWhereFilter> tmpFilterList = cont.FilterList;
            
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
    
    
    static testmethod void testCampaignPlanning() {
        
        Id otherProgramId = getOtherProgram().Id;
        //Create test data
        //Create test data
        TestDataFactory.createWBSAUSMarketingPlanHierarchy();
        Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();

        //  2018 US JBW American AMR SDP Heritage Arkansas $5K              
        List<String> planNames = new List<String>();
        planNames.add('2017 AUS CCL Australian CCL BTL NSW $5K'); 
        Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);   
        
        MarketingPlan__c parentRec = plans.get('2017 AUS CCL Australian CCL BTL NSW $5K');
        parentRec.SAP_Controlling_Area__c = '6000';
        parentRec.SAP_Company_Code__c = 'AU60';
        parentRec.SAP_Cost_Center__c = 'Y';
        update parentRec;
        
        ID parentMarkId = parentRec.Id;
        
        Campaign__c parentCamp = TestDataFactory.MapCampaign(parentMarkId, 1.00, date.newinstance(2017, 1, 5), date.newinstance(2017, 1, 27), 'AUD', tagsMap.get('BQ_Canadian Club'));
        insert parentCamp;

        //Create 100 test Campaigns
        List<Campaign_Spend__c> bulkCampaignSpendPlanning = new List<Campaign_Spend__c>();
        for (Integer i = 1; i <= 100; i++) {
            Campaign_Spend__c theTempCamp = TestDataFactory.MapCampaignSpendPlanning(parentCamp.Id, 'AUD', 'POS');
            bulkCampaignSpendPlanning.add(theTempCamp);
        }   
        insert bulkCampaignSpendPlanning;
            
        Test.startTest();
        
        //Test the Page controller extension and the Component Controller.
        CampaignPlanningEditor pageCont = new CampaignPlanningEditor(new ApexPages.StandardController(parentCamp));

        //Simulate Component Attributes being set via binding to PageControllerExt properties.   
        pageCont.RefreshPage();
    }
    
    //Added by Mahesh as part of AUS Campaign Planning Restructure Project
    static testmethod void testCampaignPlanningMonthly() {
        Id otherProgramId = getOtherProgram().Id;
        //Create test data
        TestDataFactory.createWBSAUSMarketingPlanHierarchy();
        Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();

        //  2018 US JBW American AMR SDP Heritage Arkansas $5K              
        List<String> planNames = new List<String>();
        planNames.add('2017 AUS CCL Australian CCL BTL NSW $5K'); 
        Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);   
        
        MarketingPlan__c parentRec = plans.get('2017 AUS CCL Australian CCL BTL NSW $5K');
        parentRec.SAP_Controlling_Area__c = '6000';
        parentRec.SAP_Company_Code__c = 'AU60';
        parentRec.SAP_Cost_Center__c = 'Y';
        update parentRec;
        
        ID parentMarkId = parentRec.Id;
        
        Campaign__c parentCamp = TestDataFactory.MapCampaign(parentMarkId, 1.00, date.newinstance(2017, 1, 5), date.newinstance(2017, 1, 27), 'AUD', tagsMap.get('BQ_Canadian Club'));
        insert parentCamp;

        //Create 100 test Campaigns
        List<Campaign_Spend__c> bulkCampaignSpendPlanning = new List<Campaign_Spend__c>();
        for (Integer i = 1; i <= 100; i++) {
            Campaign_Spend__c theTempCamp = TestDataFactory.MapCampaignSpendPlanning(parentCamp.Id, 'AUD', 'POS');
            bulkCampaignSpendPlanning.add(theTempCamp);
        }   
        insert bulkCampaignSpendPlanning;
            
        Test.startTest();
        
        //Test the Page controller extension and the Component Controller.
        CampaignPlanningMonthlyBasisController campaignMonthlyContr = new CampaignPlanningMonthlyBasisController(new ApexPages.StandardController(parentCamp));
        List<Campaign_Spend__c> campaignSpendList = campaignMonthlyContr.campaignPlanning;
        CampaignBudgetMonthlyBasisController campaignMonthlyBudgetContr = new CampaignBudgetMonthlyBasisController(new ApexPages.StandardController(parentCamp));
        List<Campaign__c> campaignBudgetList = campaignMonthlyBudgetContr.campaignBudget;
        Test.stopTest();
    }

    //Added by Mahesh as part of AUS Campaign Planning Restructure Project
    static testmethod void testsaveEditViewDeleteCampaignSpend() {
        Id otherProgramId = getOtherProgram().Id;
        //Create test data
        TestDataFactory.createWBSAUSMarketingPlanHierarchy();
        Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();

        //  2018 US JBW American AMR SDP Heritage Arkansas $5K              
        List<String> planNames = new List<String>();
        planNames.add('2017 AUS CCL Australian CCL BTL NSW $5K'); 
        Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);   
        
        MarketingPlan__c parentRec = plans.get('2017 AUS CCL Australian CCL BTL NSW $5K');
        parentRec.SAP_Controlling_Area__c = '6000';
        parentRec.SAP_Company_Code__c = 'AU60';
        parentRec.SAP_Cost_Center__c = 'Y';
        update parentRec;
        
        ID parentMarkId = parentRec.Id;
        
        Campaign__c parentCamp = TestDataFactory.MapCampaign(parentMarkId, 1.00, date.newinstance(2017, 1, 5), date.newinstance(2017, 1, 27), 'AUD', tagsMap.get('BQ_Canadian Club'));
        insert parentCamp;
        System.debug('parentCamp is:::'+parentCamp.Id);
        Campaign_Spend__c testcampaignSpendPlanning = TestDataFactory.MapCampaignSpendPlanning(parentCamp.Id, 'AUD', 'POS');
        testcampaignSpendPlanning.Amount__c = 20.00;
        testcampaignSpendPlanning.Planning_Month__c = 'Jan';
        insert testcampaignSpendPlanning;
        
  
        System.debug('testcampaignSpendPlanning is:::'+testcampaignSpendPlanning);
        
        Campaign__c parentCampnew = TestDataFactory.MapCampaign(parentMarkId, 12.00, date.newinstance(2017, 1, 6), date.newinstance(2017, 1, 28), 'AUD', tagsMap.get('BQ_Canadian Club'));
        insert parentCampnew;
        
        Campaign_Spend__c testone = new Campaign_Spend__c();
        testone.ParentCampaign__c= parentCampnew.Id;
        testone.CurrencyIsoCode = 'AUD';
        testone.Planning_Month__c = 'Jan';
        testone.Amount__c = -10;
         
        Campaign_Spend__c testtwo = new Campaign_Spend__c();
        testtwo.ParentCampaign__c= parentCampnew.Id;
        testtwo.CurrencyIsoCode = 'AUD';
        testtwo.Planning_Month__c = 'Feb';
        testtwo.Amount__c = 10;
                
        List<Campaign_Spend__c> campSpendMonthList = new List<Campaign_Spend__c>();
        campSpendMonthList.add(testone);
        campSpendMonthList.add(testtwo);
        insert campSpendMonthList;      
          
        System.debug('campSpendMonthList size is:::'+campSpendMonthList.size());
        Test.startTest();
        
        //Test the Page controller extension and the Component Controller.
        CampaignPlanningMonthlyBasisController campaignMonthlyContr = new CampaignPlanningMonthlyBasisController(new ApexPages.StandardController(parentCamp));
        campaignMonthlyContr.objCampaignSpend = testcampaignSpendPlanning;
        campaignMonthlyContr.campaignPlanningMonthList = campSpendMonthList;
        campaignMonthlyContr.ShowPopup();
        campaignMonthlyContr.Cancel();
        ApexPages.CurrentPage().getParameters().put('selectedCampaignPlanningEditRecord',testcampaignSpendPlanning.Id);
        campaignMonthlyContr.editCampaignPlanningRecord();
        ApexPages.CurrentPage().getParameters().put('selectedCampaignMonthlyPlanningEditRecord',testcampaignSpendPlanning.Id);
        campaignMonthlyContr.viewCampaignPlanningRecord();
        ApexPages.CurrentPage().getParameters().put('selectedCampaignPlanningRecord',testcampaignSpendPlanning.Id);
        //campaignMonthlyContr.saveMonthlyBudgetCampaignSpend();
        ApexPages.CurrentPage().getParameters().put('selectedMonthlyBudgetCampaignPlanningEditRecord',testcampaignSpendPlanning.Id);
        //campaignMonthlyContr.editCampaignBudgetMonthlyRecord();
        campaignMonthlyContr.deleteCampaignPlanningRecord();
       
        Test.stopTest();
    }
    
    //Added by Mahesh as part of AUS Campaign Planning Restructure Project
    static testmethod void testSaveEditCampaignBudgetMonthlyRecord() {
        Id otherProgramId = getOtherProgram().Id;
        //Create test data
        TestDataFactory.createWBSAUSMarketingPlanHierarchy();
        Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();

        //  2018 US JBW American AMR SDP Heritage Arkansas $5K              
        List<String> planNames = new List<String>();
        planNames.add('2017 AUS CCL Australian CCL BTL NSW $5K'); 
        Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);   
        
        MarketingPlan__c parentRec = plans.get('2017 AUS CCL Australian CCL BTL NSW $5K');
        parentRec.SAP_Controlling_Area__c = '6000';
        parentRec.SAP_Company_Code__c = 'AU60';
        parentRec.SAP_Cost_Center__c = 'Y';
        update parentRec;
        
        ID parentMarkId = parentRec.Id;
        
        Campaign__c parentCamp = TestDataFactory.MapCampaign(parentMarkId, 1.00, date.newinstance(2017, 1, 5), date.newinstance(2017, 1, 27), 'AUD', tagsMap.get('BQ_Canadian Club'));
        insert parentCamp;
        System.debug('parentCamp is:::'+parentCamp.Id);
        Campaign_Spend__c testcampaignSpendPlanning = TestDataFactory.MapCampaignSpendPlanning(parentCamp.Id, 'AUD', 'POS');
        testcampaignSpendPlanning.Amount__c = 20.00;
        testcampaignSpendPlanning.Planning_Month__c = 'Jan';
        insert testcampaignSpendPlanning;
        
  
        System.debug('testcampaignSpendPlanning is:::'+testcampaignSpendPlanning);
        
        Campaign__c parentCampnew = TestDataFactory.MapCampaign(parentMarkId, 12.00, date.newinstance(2017, 1, 6), date.newinstance(2017, 1, 28), 'AUD', tagsMap.get('BQ_Canadian Club'));
        insert parentCampnew;
        
        Campaign_Spend__c testone = new Campaign_Spend__c();
        testone.ParentCampaign__c= parentCampnew.Id;
        testone.CurrencyIsoCode = 'AUD';
        testone.Planning_Month__c = 'Jan';
        testone.Amount__c = -10;
         
        Campaign_Spend__c testtwo = new Campaign_Spend__c();
        testtwo.ParentCampaign__c= parentCampnew.Id;
        testtwo.CurrencyIsoCode = 'AUD';
        testtwo.Planning_Month__c = 'Feb';
        testtwo.Amount__c = 10;
                
        List<Campaign_Spend__c> campSpendMonthList = new List<Campaign_Spend__c>();
        campSpendMonthList.add(testone);
        campSpendMonthList.add(testtwo);
        insert campSpendMonthList;      
          
        System.debug('campSpendMonthList size is:::'+campSpendMonthList.size());
        
        List<user> userForTesting = [SELECT Id FROM User WHERE profile.name='AUS Marketing - Platform' and isActive=true LIMIT 1];
        System.runAs(userForTesting[0]) // normally you want to verify the list has data first as this could cause null exception
        {
            Test.startTest();
        
            //Test the Page controller extension and the Component Controller.
            CampaignBudgetMonthlyBasisController campaignMonthlyContr = new CampaignBudgetMonthlyBasisController(new ApexPages.StandardController(parentCamp));
            campaignMonthlyContr.objCampaignSpend = testcampaignSpendPlanning;
            campaignMonthlyContr.campaignBudgetMonthList = campSpendMonthList;
            campaignMonthlyContr.ShowPopup();
            campaignMonthlyContr.Cancel();
            //ApexPages.CurrentPage().getParameters().put('selectedCampaignPlanningRecord',testcampaignSpendPlanning.Id);
            campaignMonthlyContr.saveMonthlyBudgetCampaignSpend();
            ApexPages.CurrentPage().getParameters().put('selectedMonthlyBudgetCampaignPlanningEditRecord',testcampaignSpendPlanning.Id);
            campaignMonthlyContr.editCampaignBudgetMonthlyRecord();
            campaignMonthlyContr.getIsMemberOfGroup();
       
            Test.stopTest();
        }
    }
    //Added by Mahesh as part of AUS Campaign Planning Restructure Project
    static testMethod void testNegativeAmount(){
        Id otherProgramId = getOtherProgram().Id;
        //Create test data
        TestDataFactory.createWBSAUSMarketingPlanHierarchy();
        Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();

        //  2018 US JBW American AMR SDP Heritage Arkansas $5K              
        List<String> planNames = new List<String>();
        planNames.add('2017 AUS CCL Australian CCL BTL NSW $5K'); 
        Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);   
        
        MarketingPlan__c parentRec = plans.get('2017 AUS CCL Australian CCL BTL NSW $5K');
        parentRec.SAP_Controlling_Area__c = '6000';
        parentRec.SAP_Company_Code__c = 'AU60';
        parentRec.SAP_Cost_Center__c = 'Y';
        update parentRec;
        
        ID parentMarkId = parentRec.Id;
        
        Campaign__c parentCamp = TestDataFactory.MapCampaign(parentMarkId, 1.00, date.newinstance(2017, 1, 5), date.newinstance(2017, 1, 27), 'AUD', tagsMap.get('BQ_Canadian Club'));
        insert parentCamp;
        
        Campaign_Spend__c testcampaignSpendPlanning = TestDataFactory.MapCampaignSpendPlanning(parentCamp.Id, 'AUD', 'POS');    
        testcampaignSpendPlanning.Amount__c = -20.00;        
        insert testcampaignSpendPlanning;
        CampaignPlanningMonthlyBasisController campaignMonthlyContr = new CampaignPlanningMonthlyBasisController(new ApexPages.StandardController(parentCamp));
        campaignMonthlyContr.objCampaignSpend = testcampaignSpendPlanning;
        campaignMonthlyContr.saveCampaignSpend();
    }
    
    static testMethod void checkUserNamedCredentialTest(){
        Test.startTest();
        UTL_BI_AuthWrapper getAuthInfoForUS = MultiRecordComponentController.checkUserNamedCredential(UTL_API_Utility.APPNAME_USBI);
        UTL_BI_AuthWrapper getAuthInfoForAUS = MultiRecordComponentController.checkUserNamedCredential(UTL_API_Utility.APPNAME_AUSBI);
        UTL_BI_AuthWrapper getAuthInfoForSO = MultiRecordComponentController.checkUserNamedCredential(UTL_API_Utility.APPNAME_SO);
        Test.stopTest();
        System.assert(getAuthInfoForUS.userAuthorise==false);
        System.assert(getAuthInfoForAUS.userAuthorise==false);   
    }
    
    static testMethod void sendIOCodesToSAPTest(){
        Test.startTest();
        MultiRecordComponentController obj = new MultiRecordComponentController();
        PageReference ref = obj.sendCodesToSAP();
        Test.stopTest();
        System.assert(ref==null);
    }
    
    static testMethod void sendWBSCodesToSAPTest(){
        Test.startTest();
        MultiRecordComponentController obj = new MultiRecordComponentController();
        PageReference ref = obj.sendCodesToSAP();
        Test.stopTest();
        System.assert(ref==null);
    }
        
  }