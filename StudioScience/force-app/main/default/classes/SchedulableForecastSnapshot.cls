global class SchedulableForecastSnapshot implements Schedulable {

    global void execute(SchedulableContext sc) {
        try{
        	//Get the Record Type ID for Forecasts
    		ID forecastRecordTypeId = BI_UtilityLogic.getRecordTypeId(BI_Constants.OBJECT_CAMPAIGNSPEND, 
    			BI_Constants.RECORDTYPE_CAMPAIGNSPEND_FORECAST);
        	//Call the BatchForecastSnapshotWeekly class
            BatchForecastSnapshotWeekly forecastSnapshotWeekly = new BatchForecastSnapshotWeekly();
            String myQuery = 'SELECT Id, CurrencyIsoCode, (SELECT Id, Amount__c, Forecast_Month_Date__c, Forecast_Month__c FROM Campaign_Spend__r WHERE RecordTypeId = \'' + forecastRecordTypeId + '\'), Name, Brand_Quality__c, Brand_Quality__r.Name, ParentMarketingPlan__c, CampaignBalance__c, CampaignBrand__c, ForecastedCampaignSpend__c FROM Campaign__c';
            myQuery += ' WHERE Year__c =  \'' + String.valueOf(System.today().year()) + '\'';
            forecastSnapshotWeekly.query = myQuery;
            ID batchprocessid = Database.executeBatch(forecastSnapshotWeekly, 200);
        } catch (Exception ex){
            CreateExceptionLog.insertErrorLog('SchedulableForecastSnapshot', 'execute', String.valueOf(ex), 'Fatal');
        }
    }
}