global class BatchForecastSnapshotMonthly implements Database.Batchable<sObject> {

	public String query;
	public Integer currentMonth;
	public Integer currentYear;
	public Boolean automated;
	public String userDrivenDescription;

	global BatchForecastSnapshotMonthly() {
		//get current month and year
		currentMonth = System.now().month();
		currentYear = System.now().year();
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		try{
			List<Forecast_Snapshot__c> forecastSnapshotsToUpsert = new List<Forecast_Snapshot__c>();
			//create list of months to compare the currentMonth value with
			List<String> months = new List<String> {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December', 'Error Getting Date'};
			//record types to be used for automated or user driven Forecast_Snapshot__c records
			Id automatedSnapshotRecordTypeId = Schema.SObjectType.Forecast_Snapshot__c.getRecordTypeInfosByName().get('Automated').getRecordTypeId();
			Id userDrivenSnapshotRecordTypeId = Schema.SObjectType.Forecast_Snapshot__c.getRecordTypeInfosByName().get('User Driven').getRecordTypeId();
			Set<Id> campaignIds = new Set<Id>();
			//get current month string value
			String currentMonthValue = months[currentMonth - 1];
			Map<Id, Forecast_Snapshot__c> forecastSnapshotMap = new Map<Id, Forecast_Snapshot__c>();
			//set campaign ids from scope into a set to query existing Forecast_Snapshot__c records
			for(sObject s : scope){
				Campaign__c campObj = (Campaign__c)s;
				campaignIds.add(campObj.Id);
			}
			//get existing Forecast_Snapshot__c records to check against
			List<Forecast_Snapshot__c> forecastSnapshotList = [SELECT Id, Campaign__c, Forecast_Month__c FROM Forecast_Snapshot__c WHERE Campaign__c IN :campaignIds AND Forecast_Month__c = :currentMonthValue AND RecordTypeId = :automatedSnapshotRecordTypeId];
			for(Forecast_Snapshot__c forecast : forecastSnapshotList){
				forecastSnapshotMap.put(forecast.Campaign__c, forecast);
			}
			//iterate through the scope
			for(sObject s : scope){
				Campaign__c campObj = (Campaign__c)s;
				Forecast_Snapshot__c newForecastSnapshot = new Forecast_Snapshot__c();
				newForecastSnapshot.CurrencyIsoCode = campObj.CurrencyIsoCode;
				if (currentMonth != null) {
					String autoMonthlySnapshotName = 'Auto: ' + campObj.Brand_Quality__r.Name + ' ' + currentMonthValue + ' ' + currentYear;
					String userMonthlySnapshotName = 'User Driven: ' + campObj.Brand_Quality__r.Name + ' ' + currentMonthValue + ' ' + currentYear;
					//check if automated monthly or user driven snapshot record
					if(automated){
						//Check to make sure the name of the new record is less than or equal to 80 characters otherwise an error will throw on insert
						if(autoMonthlySnapshotName.length() <= BI_Constants.MAX_NUMBER_OF_CHARACTERS_IN_NAME_FIELD){
							newForecastSnapshot.Name = 'Auto: ' + campObj.Brand_Quality__r.Name + ' ' + currentMonthValue + ' ' + currentYear;
						} else {
							newForecastSnapshot.Name = 'Auto: Forecast Snapshot Monthly ' + currentMonthValue + ' ' + currentYear;
						}
						newForecastSnapshot.RecordTypeId = automatedSnapshotRecordTypeId;
					} else {
						//Check to make sure the name of the new record is less than or equal to 80 characters otherwise an error will throw on insert
						if(userMonthlySnapshotName.length() <= BI_Constants.MAX_NUMBER_OF_CHARACTERS_IN_NAME_FIELD){
							newForecastSnapshot.Name = 'User Driven: ' + campObj.Brand_Quality__r.Name + ' ' + currentMonthValue + ' ' + currentYear;
						} else {
							newForecastSnapshot.Name = 'User Driven: Forecast Snapshot Monthly ' + currentMonthValue + ' ' + currentYear;
						}
						newForecastSnapshot.RecordTypeId = userDrivenSnapshotRecordTypeId;
						newForecastSnapshot.User_Driven_Snapshot_Description__c = userDrivenDescription;
					}
				} else {
					newForecastSnapshot.Name = 'N/A';
				}
				//snapshot fields from the Campaign__c record
				newForecastSnapshot.Brand_Quality__c = campObj.Brand_Quality__c;
				newForecastSnapshot.Campaign__c = campObj.Id;
				newForecastSnapshot.Forecast_Amount__c = campObj.ForecastedCampaignSpend__c;
				newForecastSnapshot.Forecast_Date__c = System.today();
				newForecastSnapshot.Marketing_Plan__c = campObj.ParentMarketingPlan__c;
				if(s.getSObjects('Campaign_Spend__r') != null){
					for(sObject spen : s.getSObjects('Campaign_Spend__r')){
						Campaign_Spend__c spendObj = (Campaign_Spend__c)spen;
						if (spendObj.Forecast_Month__c == 'Jan') {
							newForecastSnapshot.Jan_Forecast_Amount__c = spendObj.Amount__c;
						} else if (spendObj.Forecast_Month__c == 'Feb') {
							newForecastSnapshot.Feb_Forecast_Amount__c = spendObj.Amount__c;
						} else if (spendObj.Forecast_Month__c == 'Mar') {
							newForecastSnapshot.Mar_Forecast_Amount__c = spendObj.Amount__c;
						} else if (spendObj.Forecast_Month__c == 'Apr') {
							newForecastSnapshot.Apr_Forecast_Amount__c = spendObj.Amount__c;
						} else if (spendObj.Forecast_Month__c == 'May') {
							newForecastSnapshot.May_Forecast_Amount__c = spendObj.Amount__c;
						} else if (spendObj.Forecast_Month__c == 'Jun') {
							newForecastSnapshot.Jun_Forecast_Amount__c = spendObj.Amount__c;
						} else if (spendObj.Forecast_Month__c == 'Jul') {
							newForecastSnapshot.Jul_Forecast_Amount__c = spendObj.Amount__c;
						} else if (spendObj.Forecast_Month__c == 'Aug') {
							newForecastSnapshot.Aug_Forecast_Amount__c = spendObj.Amount__c;
						} else if (spendObj.Forecast_Month__c == 'Sep') {
							newForecastSnapshot.Sep_Forecast_Amount__c = spendObj.Amount__c;
						} else if (spendObj.Forecast_Month__c == 'Oct') {
							newForecastSnapshot.Oct_Forecast_Amount__c = spendObj.Amount__c;
						} else if (spendObj.Forecast_Month__c == 'Nov') {
							newForecastSnapshot.Nov_Forecast_Amount__c = spendObj.Amount__c;
						} else if (spendObj.Forecast_Month__c == 'Dec') {
							newForecastSnapshot.Dec_Forecast_Amount__c = spendObj.Amount__c;
						}
					}
				}
				/*check if campaign already has a Forecast_Snapshot__c record for the month and it is an automated job.
				If both true then just update the existing record and do not create a new one.*/
				if(forecastSnapshotMap.containsKey(campObj.Id) && automated){
					newForecastSnapshot.Id = forecastSnapshotMap.get(campObj.Id).Id;
					forecastSnapshotsToUpsert.add(newForecastSnapshot);
				/*If there is not an existing Forecast_Snapshot__c record or the job is user driven then create a new Forecast_Snapshot__c record
				for the campaign.*/
				} else {
					forecastSnapshotsToUpsert.add(newForecastSnapshot);
				}
			}
			//insert or update the Forecast_Snapshot__c records
			if(!forecastSnapshotsToUpsert.isEmpty()){
				upsert forecastSnapshotsToUpsert;
			}
		} catch(Exception ex){
			CreateExceptionLog.insertErrorLog('BatchForecastSnapshotMonthly', 'execute', String.valueOf(ex), 'Fatal');
		}
	}

	global void finish(Database.BatchableContext BC) {
	}
}