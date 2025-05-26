global class SchedulableForecastSnapshotMonthly implements Schedulable {

	global void execute(SchedulableContext sc) {
		try{
			//Get the Record Type ID for Forecasts
			ID forecastRecordTypeId = BI_UtilityLogic.getRecordTypeId(BI_Constants.OBJECT_CAMPAIGNSPEND, 
				BI_Constants.RECORDTYPE_CAMPAIGNSPEND_FORECAST);
			//call the BatchForecastSnapshotMonthly class
			BatchForecastSnapshotMonthly forecastSnapshotMonthly = new BatchForecastSnapshotMonthly();
			String myQuery = 'SELECT Id, CurrencyIsoCode, (SELECT Id, Amount__c, Forecast_Month_Date__c, Forecast_Month__c FROM Campaign_Spend__r WHERE RecordTypeId = \'' + forecastRecordTypeId + '\'), Name, Brand_Quality__c, Brand_Quality__r.Name, ParentMarketingPlan__c, CampaignBalance__c, CampaignBrand__c, ForecastedCampaignSpend__c FROM Campaign__c';
			myQuery += ' WHERE Year__c =  \'' + String.valueOf(System.today().year()) + '\'';
			forecastSnapshotMonthly.query = myQuery;
			//set the automated variable to true
			forecastSnapshotMonthly.automated = true;
			ID batchprocessid = Database.executeBatch(forecastSnapshotMonthly, 200);
		} catch (Exception ex){
			CreateExceptionLog.insertErrorLog('SchedulableForecastSnapshotMonthly', 'execute', String.valueOf(ex), 'Fatal');
		}
	}
}