global class BatchForecastSnapshotWeekly implements Database.Batchable<sObject> {

	public String query;
	public Integer currentMonth;
	public Integer currentYear;
	public String weekOfMonth;

	global BatchForecastSnapshotWeekly() {
		//get current month, year, and week
		currentMonth = System.now().month();
		currentYear = System.now().year();
		weekOfMonth = System.now().format('W');
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		try{
			List<Forecast_Snapshot_Weekly__c> forecastSnapshotsWeeklyToInsert = new List<Forecast_Snapshot_Weekly__c>();
			List<Forecast_Snapshot__c> forecastSnapshotsNewMonthlyToInsert = new List<Forecast_Snapshot__c>();
			List<Forecast_Snapshot_Weekly__c> forecastSnapshotsWeeklyToInsertWithNewMonthlyRecord = new List<Forecast_Snapshot_Weekly__c>();
			//create list of months to compare the currentMonth value with
			List<String> months = new List<String> {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December', 'Error Getting Date'};
			//record types to be used for automated Forecast_Snapshot__c or Forecast_Snapshot_Weekly__c records
			Id automatedMonthlySnapshotRecordTypeId = Schema.SObjectType.Forecast_Snapshot__c.getRecordTypeInfosByName().get('Automated').getRecordTypeId();
			Id automatedWeeklySnapshotRecordTypeId = Schema.SObjectType.Forecast_Snapshot_Weekly__c.getRecordTypeInfosByName().get('Automated').getRecordTypeId();
			//get current month string value
			String currentMonthValue = months[currentMonth - 1];
			Set<Id> campaignIds = new Set<Id>();
			Map<Id, Forecast_Snapshot__c> forecastSnapshotMap = new Map<Id, Forecast_Snapshot__c>();
			//set campaign ids from scope into a set to query existing Forecast_Snapshot__c records
			for(sObject s : scope){
				Campaign__c campObj = (Campaign__c)s;
				campaignIds.add(campObj.Id);
			}
			//get existing Forecast_Snapshot__c records to check against
			List<Forecast_Snapshot__c> forecastSnapshotList = [SELECT Id, Campaign__c, Forecast_Month__c FROM Forecast_Snapshot__c WHERE Campaign__c IN :campaignIds AND Forecast_Month__c = :currentMonthValue AND RecordTypeId = :automatedMonthlySnapshotRecordTypeId];
			for(Forecast_Snapshot__c forecast : forecastSnapshotList){
				forecastSnapshotMap.put(forecast.Campaign__c, forecast);
			}
			//iterate through the scope
			for (sObject s : scope) {
				Campaign__c campObj = (Campaign__c)s;
				/*Create a monthly Forecast_Snapshot__c and weekly Forecast_Snapshot_Weekly__c records.
				The monthly forecast snapshot record will only be created if there is not an existing
				monthly record already present in the system for the campaign.  There needs to be a relationship
				between monthly and weekly snapshot records.*/
				Forecast_Snapshot_Weekly__c newForecastWeeklySnapshot = new Forecast_Snapshot_Weekly__c();
				Forecast_Snapshot__c newForecastMonthlySnapshot = new Forecast_Snapshot__c();
				newForecastWeeklySnapshot.CurrencyIsoCode = campObj.CurrencyIsoCode;
				newForecastMonthlySnapshot.CurrencyIsoCode = campObj.CurrencyIsoCode;
				newForecastWeeklySnapshot.RecordTypeId = automatedWeeklySnapshotRecordTypeId;
				newForecastMonthlySnapshot.RecordTypeId = automatedMonthlySnapshotRecordTypeId;
				if (currentMonth != null) {
					String weeklySnapshotName = 'Auto: ' + campObj.Brand_Quality__r.Name + ' ' + currentMonthValue + ' ' + currentYear + ' Week ' + weekOfMonth;
					String monthlySnapshotName = 'Auto: ' + campObj.Brand_Quality__r.Name + ' ' + currentMonthValue + ' ' + currentYear;
					//Check to make sure the name of the new record is less than or equal to 80 characters otherwise an error will throw on insert
					if(weeklySnapshotName.length() <= BI_Constants.MAX_NUMBER_OF_CHARACTERS_IN_NAME_FIELD){
						newForecastWeeklySnapshot.Name = 'Auto: ' + campObj.Brand_Quality__r.Name + ' ' + currentMonthValue + ' ' + currentYear + ' Week ' + weekOfMonth;
					} else {
						newForecastWeeklySnapshot.Name = 'Auto: Forecast Snapshot Weekly ' + currentMonthValue + ' ' + currentYear + ' Week ' + weekOfMonth;
					}
					//Check to make sure the name of the new record is less than or equal to 80 characters otherwise an error will throw on insert
					if(monthlySnapshotName.length() <= BI_Constants.MAX_NUMBER_OF_CHARACTERS_IN_NAME_FIELD){
						newForecastMonthlySnapshot.Name = 'Auto: ' + campObj.Brand_Quality__r.Name + ' ' + currentMonthValue + ' ' + currentYear;
					} else {
						newForecastMonthlySnapshot.Name = 'Auto: Forecast Snapshot Monthly ' + currentMonthValue + ' ' + currentYear;
					}
				} else {
					newForecastWeeklySnapshot.Name = 'N/A';
					newForecastMonthlySnapshot.Name = 'N/A';
				}
				//snapshot fields from the Campaign__c record
				newForecastWeeklySnapshot.Brand_Quality__c = campObj.Brand_Quality__c;
				newForecastMonthlySnapshot.Brand_Quality__c = campObj.Brand_Quality__c;
				newForecastWeeklySnapshot.Campaign__c = campObj.Id;
				newForecastmonthlySnapshot.Campaign__c = campObj.Id;
				newForecastWeeklySnapshot.Campaign_Forecast_Amount__c = campObj.ForecastedCampaignSpend__c;
				newForecastMonthlySnapshot.Forecast_Amount__c = campObj.ForecastedCampaignSpend__c;
				newForecastWeeklySnapshot.Forecast_Date__c = System.today();
				newForecastMonthlySnapshot.Forecast_Date__c = System.today().toStartOfMonth();
				newForecastWeeklySnapshot.Marketing_Plan__c = campObj.ParentMarketingPlan__c;
				newForecastMonthlySnapshot.Marketing_Plan__c = campObj.ParentMarketingPlan__c;
				if(s.getSObjects('Campaign_Spend__r') != null){
					for (sObject spen : s.getSObjects('Campaign_Spend__r')) {
						Campaign_Spend__c spendObj = (Campaign_Spend__c)spen;
						if (spendObj.Forecast_Month__c == 'Jan') {
							newForecastWeeklySnapshot.Jan_Forecast_Amount__c = spendObj.Amount__c;
							newForecastMonthlySnapshot.Jan_Forecast_Amount__c = spendObj.Amount__c;
						} else if (spendObj.Forecast_Month__c == 'Feb') {
							newForecastWeeklySnapshot.Feb_Forecast_Amount__c = spendObj.Amount__c;
							newForecastMonthlySnapshot.Feb_Forecast_Amount__c = spendObj.Amount__c;
						} else if (spendObj.Forecast_Month__c == 'Mar') {
							newForecastWeeklySnapshot.Mar_Forecast_Amount__c = spendObj.Amount__c;
							newForecastMonthlySnapshot.Mar_Forecast_Amount__c = spendObj.Amount__c;
						} else if (spendObj.Forecast_Month__c == 'Apr') {
							newForecastWeeklySnapshot.Apr_Forecast_Amount__c = spendObj.Amount__c;
							newForecastMonthlySnapshot.Apr_Forecast_Amount__c = spendObj.Amount__c;
						} else if (spendObj.Forecast_Month__c == 'May') {
							newForecastWeeklySnapshot.May_Forecast_Amount__c = spendObj.Amount__c;
							newForecastMonthlySnapshot.May_Forecast_Amount__c = spendObj.Amount__c;
						} else if (spendObj.Forecast_Month__c == 'Jun') {
							newForecastWeeklySnapshot.Jun_Forecast_Amount__c = spendObj.Amount__c;
							newForecastMonthlySnapshot.Jun_Forecast_Amount__c = spendObj.Amount__c;
						} else if (spendObj.Forecast_Month__c == 'Jul') {
							newForecastWeeklySnapshot.Jul_Forecast_Amount__c = spendObj.Amount__c;
							newForecastMonthlySnapshot.Jul_Forecast_Amount__c = spendObj.Amount__c;
						} else if (spendObj.Forecast_Month__c == 'Aug') {
							newForecastWeeklySnapshot.Aug_Forecast_Amount__c = spendObj.Amount__c;
							newForecastMonthlySnapshot.Aug_Forecast_Amount__c = spendObj.Amount__c;
						} else if (spendObj.Forecast_Month__c == 'Sep') {
							newForecastWeeklySnapshot.Sep_Forecast_Amount__c = spendObj.Amount__c;
							newForecastMonthlySnapshot.Sep_Forecast_Amount__c = spendObj.Amount__c;
						} else if (spendObj.Forecast_Month__c == 'Oct') {
							newForecastWeeklySnapshot.Oct_Forecast_Amount__c = spendObj.Amount__c;
							newForecastMonthlySnapshot.Oct_Forecast_Amount__c = spendObj.Amount__c;
						} else if (spendObj.Forecast_Month__c == 'Nov') {
							newForecastWeeklySnapshot.Nov_Forecast_Amount__c = spendObj.Amount__c;
							newForecastMonthlySnapshot.Nov_Forecast_Amount__c = spendObj.Amount__c;
						} else if (spendObj.Forecast_Month__c == 'Dec') {
							newForecastWeeklySnapshot.Dec_Forecast_Amount__c = spendObj.Amount__c;
							newForecastMonthlySnapshot.Dec_Forecast_Amount__c = spendObj.Amount__c;
						}
					}
				}
				/*check if campaign already has a Forecast_Snapshot__c record for the month.
				If there is a record for the month then set the Forecast_Snapshot_Monthly__c relationship field
				to that monthly records Id*/
				if(forecastSnapshotMap.containsKey(campObj.Id)){
					newForecastWeeklySnapshot.Forecast_Snapshot_Monthly__c = forecastSnapshotMap.get(campObj.Id).Id;
					forecastSnapshotsWeeklyToInsert.add(newForecastWeeklySnapshot);
				/*If there is not an existing monthly Forecast_Snapshot__c record then we will add the
				weekly forecast snapshot record to a list to be inserted and we will also add the 
				placeholder monthly snapshot record we created above to a list to be inserted.  After the new
				monthly record is inserted it will be used to set the weekly's relationship field.*/
				} else {
					forecastSnapshotsWeeklyToInsertWithNewMonthlyRecord.add(newForecastWeeklySnapshot);
					forecastSnapshotsNewMonthlyToInsert.add(newForecastMonthlySnapshot);
				}
			}
			//insert the new monthly forecast snapshot records
			if(!forecastSnapshotsNewMonthlyToInsert.isEmpty()){
				insert forecastSnapshotsNewMonthlyToInsert;
			}
			/*set the relationship field (Forecast_Snapshot_Monthly__c) on the Forecast_Snapshot_Weekly__c record
			with the newly inserted Forecast_Snapshot__c record in order to create that master detial relationship*/
			if(!forecastSnapshotsWeeklyToInsertWithNewMonthlyRecord.isEmpty()){
				Map<Id, Forecast_Snapshot__c> newForecastMonthlySnapshotMap = new Map<Id, Forecast_Snapshot__c>();
				for(Forecast_Snapshot__c forecast : forecastSnapshotsNewMonthlyToInsert){
					newForecastMonthlySnapshotMap.put(forecast.Campaign__c, forecast);
				}
				for(Forecast_Snapshot_Weekly__c forecastWeek : forecastSnapshotsWeeklyToInsertWithNewMonthlyRecord){
					if(newForecastMonthlySnapshotMap.containsKey(forecastWeek.Campaign__c)){
						forecastWeek.Forecast_Snapshot_Monthly__c = newForecastMonthlySnapshotMap.get(forecastWeek.Campaign__c).Id;
					}
				}
				insert forecastSnapshotsWeeklyToInsertWithNewMonthlyRecord;
			}
			//insert the new weekly forecast snapshot records
			if(!forecastSnapshotsWeeklyToInsert.isEmpty()){
				insert forecastSnapshotsWeeklyToInsert;
			}
		} catch(Exception ex){
			CreateExceptionLog.insertErrorLog('BatchForecastSnapshotWeekly', 'execute', String.valueOf(ex), 'Fatal');
		}
	}

	global void finish(Database.BatchableContext BC) {
	}
}