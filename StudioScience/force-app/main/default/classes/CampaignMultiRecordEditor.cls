public with sharing class CampaignMultiRecordEditor extends PageControllerBase {
    public Boolean MyAllowCreateIO {get; set;}
    public Boolean MyAllowCreateWBS {get; set;}
    public Boolean MyAllowAdd {get; set;}
    public Boolean MyAllowEdit {get; set;}
    public Boolean MyAllowDelete {get; set;}
      
    public String MysObj {get; set;}
    public String MyRecId {get; set;}
    public String MyRelationField {get; set;}
    public list<String> MyFieldList {get; set;}
    public list<String> MySearchFieldList {get; set;}
    public list<String> MyLabelOverrideFieldList {get; set;}
    public list<String> MyLabelOverrideTextList {get; set;}
    public list<String> MyDefaultValueFieldList {get; set;}
    public list<String> MyDefaultValueTextList {get; set;}

    public Boolean isWBSEnabled {get; set;}
    public String nextIOSequenceLabel {get; set;}
    public String nextWBSSequenceLabel {get; set;}

    public String MyBlockTitle {get; set;}
    public ApexPages.StandardController standardController {get; set; }
    public MarketingPlan__c currMP;
    public static String GL2018CampaignRTName = BI_Constants.RECORDTYPE_CAMPAIGN_IO_2018;

    //forecast variables to send to the MultiRecordComponent when the forecast popup is opened
    public Boolean forecastMyAllowAdd {get; set;}
    public Boolean forecastMyAllowEdit {get; set;}
    public Boolean forecastMyAllowDelete {get; set;}
    public Boolean showForecastModal {get; set;}
    public String forecastMysObj {get; set;}
    public String forecastMyRecId {get; set;}
    public String forecastMyRelationField {get; set;}
    public list<String> forecastMyFieldList {get; set;}
    public list<String> forecastMySearchFieldList {get; set;}
    public list<String> forecastMyLabelOverrideFieldList {get; set;}
    public list<String> forecastMyLabelOverrideTextList {get; set;}
    public list<String> forecastMyDefaultValueFieldList {get; set;}
    public list<String> forecastMyDefaultValueTextList {get; set;}
    public String forecastMyBlockTitle {get; set;}
    public String forecastMyFilter {get; set; }
    public String forecastMySort {get; set; }
 
    public CampaignMultiRecordEditor(ApexPages.StandardController stdController) {
        this.standardController = stdController;
        Id recordId = this.standardController.getId();
        MarketingPlan__c currMarketingPlan = (MarketingPlan__c) this.standardController.getRecord();
        String recordTypeName = [SELECT Id, RecordType.DeveloperName FROM MarketingPlan__c WHERE Id=:recordId].RecordType.DeveloperName;
        System.debug(LoggingLevel.INFO, 'RecordTypeName: ' + recordTypeName);

        isWBSEnabled = BI_Constants.isWBSMarketingPlan(recordTypeName);
        nextIOSequenceLabel = BI_Constants.NEXT_IO_SEQUENCE;
        nextWBSSequenceLabel = BI_Constants.NEXT_WBS_SEQUENCE;

        MyAllowAdd = true;
        MyAllowEdit = true;
        MyAllowDelete = false;
        
        //For Create IO Button
        MyAllowCreateIO = !isWBSEnabled;
        MyAllowCreateWBS = isWBSEnabled;
        
        MyBlockTitle = 'Edit Campaigns';
        MysObj = 'Campaign__c';
        MyRecId = '' + recordId; 
        MyRelationField = 'ParentMarketingPlan__c';

        //'CampaignBrand__c', 'Strategy__c', 'Objective__c', 'CampaignType__c', 'GLAccountType__c', 'GLCode__c'
        MyDefaultValueFieldList = new list<String> {'Description__c'};
        MyDefaultValueTextList = new list<String> {''};
        
        currMP = [SELECT Brand__r.CampaignBrand__c, Year__c FROM MarketingPlan__c WHERE Id = :recordId];
        String defaultCampaignBrand = currMP.Brand__r.CampaignBrand__c;
        System.debug(LoggingLevel.INFO,'Default CampaignBrand: ' + defaultCampaignBrand);

        configureGrid(isWBSEnabled);

        //set forecast variables to send to the MultiRecordComponent when the forecast popup is opened
        forecastMyAllowAdd = true;
        forecastMyAllowEdit = true;
        forecastMyAllowDelete = true;
        forecastMysObj = 'Campaign_Spend__c';
        forecastMyRecId = '';
        forecastMyRelationField = 'ParentCampaign__c';
        forecastMyFieldList = new List<String>{'Forecast_Month__c', 'Amount__c','Spend_Type__c'};
        forecastMySearchFieldList = new List<String> {  'Forecast_Month__c' };
        forecastMyLabelOverrideFieldList = new List<String> { };
        forecastMyLabelOverrideTextList = new List<String> { };
        forecastMyDefaultValueFieldList = new List<String> { };
        forecastMyBlockTitle = 'Edit Forecasts';
        forecastMyFilter = 'RecordType.Name = \'Forecast\'';
        forecastMySort = 'Forecast_Month__c';
    }

    public void configureGrid(Boolean isWBSEnabled){
        if(isWBSEnabled){
            configureWBSGrid();
        } else {
            configureIOGrid();
        }
    }

    public void configureIOGrid(){
        MyFieldList = new list<String> {
            'IOCode__c',
            'Name',
            'Brand_Quality__c',
            'CampaignBrand__c',
            'ForecastedCampaignSpend__c',
            'PlannedCampaignSpend__c',
            'ActualCampaignSpend__c',
            'CommittedCampaignSpend__c',
            'SFPR_Campaign_Spend__c',
            'CampaignBalance__c',
            'Comments__c',
            'InitialStartDate__c',
            'InitialEndDate__c',
            //'CampaignBrand__c',
            'CampaignType__c',
            'GLAccountType__c',
            'GLDescription__c',
            'GLCode__c',
            'Prioirty_JTBD__c',
            'Related_Priority__c',
            'Description__c'
        };

        MySearchFieldList = new List<String> {
            'Name',
            'IOCode__c',
            'CampaignType__c',
            'GLAccountType__c',
            'GLDescription__c'
        };

        MyLabelOverrideFieldList = new list<String> {
                                                        'ForecastedCampaignSpend__c',
                                                        'PlannedCampaignSpend__c',
                                                        'CampaignBalance__c',
                                                        'ActualCampaignSpend__c',
                                                        'CommittedCampaignSpend__c',
                                                        'SFPR_Campaign_Spend__c' };
        MyLabelOverrideTextList = new list<String> {    
                                                        'Forecasting Lookup',
                                                        'Budget',
                                                        'Balance',
                                                        'Actual',
                                                        'Committed',
                                                        'Pending',
                                                        'Description' };
        

        /*
        * This code segment was added for the 2018 GL Code integrity fix. Logically, it should be removed after the 2017-2018 transition, as 
        * 2018 GL Code controlling fields should then be configured on the original record types
        * vvvvv
        */
        try{
            //If the Campaign is an IO Campaign and the Marketing Plan's Year is 2018, override
            //Record Type with the Campaign IO 2018 Record Type to ensure correct GL Data is shown.
            Id campaignIO2018RecordTypeId = BI_UtilityLogic.getRecordTypeId('Campaign__c', GL2018CampaignRTName);
            if(MyAllowCreateIO && currMP.Year__c == '2018'){
                MyDefaultValueFieldList.add('RecordTypeId');
                MyDefaultValueTextList.add(String.valueOf(campaignIO2018RecordTypeId));
            }
        } catch(System.NullPointerException ne){
            System.debug(LoggingLevel.INFO, 'Exception, Null Pointer Exception: Either Current Marketing Plan Year value is null or MyAllowCreateIO is null: ' + ne.getMessage());
        } catch(System.QueryException qe){
            System.debug(LoggingLevel.INFO, 'Exception, Query Exception: Could not find a Record Type matching ' + GL2018CampaignRTName + ': ' + qe.getMessage());
        } catch(Exception e){
            System.debug(LoggingLevel.INFO, 'Exception: Unpredicted Exception: ' + e.getMessage());
        }
        /*
        * ^^^^^
        * This code segment was added for the 2018 GL Code integrity fix. Logically, it should be removed after the 2017-2018 transition, as 
        * 2018 GL Code controlling fields should then be configured on the original record types
        */
    }

    public void configureWBSGrid(){
        MyFieldList = new List<String> {
            'WBSCode__c',
            'Name',
            'Owner__c',
            'Owner_Team__c',
            'OLT_Filter__c',
            'Brand_Quality__c',
            'PlannedCampaignSpend__c',
            'ActualCampaignSpend__c',
            'CommittedCampaignSpend__c',
            'CampaignBalance__c',
            'Balance_Budget_vs_Campaign_Forecast__c',
            'Comments__c',
            'CampaignType__c',
            'GLAccountType__c',
            'GLDescription__c',
            'GLCode__c',
            'ForecastedCampaignSpend__c',
            'Territory_Aus__c',
            'Related_Priority__c',
            'NationalAccount__c',
            'FBS_RTD__c',
            'Description__c',
            'ATL_OR_BTL__c',
            'ON_OFF_Premise__c',
            'InitialStartDate__c',
            'InitialEndDate__c'
            
        };

        MySearchFieldList = new list<String> {
            'Name',
            'WBSCode__c',
            'CampaignType__c',
            'GLAccountType__c',
            'GLDescription__c'
        };

        MyLabelOverrideFieldList = new list<String> {
            'ForecastedCampaignSpend__c',
            'PlannedCampaignSpend__c',
            'CampaignBalance__c',
            'ActualCampaignSpend__c',
            'CommittedCampaignSpend__c',
            'Comments__c',
            'Related_Priority__c',
            'NationalAccount__c',
            'Balance_Budget_vs_Campaign_Forecast__c'
        };

        MyLabelOverrideTextList = new list<String> {
            'Forecasting Lookup',
            'Budget',
            'Balance',
            'Actual',
            'Committed',
            'Budget Change Comments',
            'Programs',
            'Accounts',
            'Balance (Bud vs Forecast)'
        };
    }
        
    public override void RefreshPage() {
        //Without Test.isRunningTest(), this lines errors because of the following sObject error:
        //System.SObjectException: You cannot call reset when the data is being passed into the controller by the caller.
        if (!Test.isRunningTest()) {
            this.standardController.reset();
        } 
    }

    /***
    * openForecastModal - Opens the forecast Modal
    ***/
    public PageReference openForecastModal(){
        try{
            showForecastModal = true;
            return null;
        } catch (Exception ex){
            CreateExceptionLog.insertErrorLog('CampaignMultiRecordEditor', 'openForecastModal', String.valueOf(ex), 'Error');
            return null;
        }
    }

    /***
    * closeForecastModal - Closes the forecast Modal
    ***/
    public PageReference closeForecastModal(){
        try{
            showForecastModal = false;
            return null;
        } catch (Exception ex){
            CreateExceptionLog.insertErrorLog('CampaignMultiRecordEditor', 'closeForecastModal', String.valueOf(ex), 'Error');
            return null;
        }
    }
}