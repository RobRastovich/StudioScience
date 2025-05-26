public with sharing class ForecastSnapshotHomePageController {

	public Boolean batchProcessed;
	public Boolean batchComplete {get; set;}
	public BatchJobInfo batchInfoObj {get; set;}
	public String userDrivenSnapshotDescription {get; set;}
	public Boolean showUSReport {get; set;}
	public String forecastingHeading {get; set;}

	public ForecastSnapshotHomePageController() {
		try{
			batchProcessed = false;
			batchComplete = false;
			showUSReport = false;
			batchInfoObj = new BatchJobInfo();

			String tabId = ApexPages.currentPage().getParameters().get('sfdc.tabName');
			// Get tab set describes for each app
			List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();

			// Iterate through each tab set describe for each app and display the info
			for (DescribeTabSetResult tsr : tabSetDesc) {
				String appLabel = tsr.getLabel();
				// Display tab info for the Brand Investment app
				if (appLabel == Label.Forecast_Snapshot_App_Name_BI) {
					List<Schema.DescribeTabResult> tabDesc = tsr.getTabs();
					for (Schema.DescribeTabResult tr : tabDesc) {
						//check only the forecasting tabs
						if(tr.getLabel() == Label.Forecast_Snapshot_Tab_US){
							List<String> tabURL = tr.getUrl().split('=');
							List<String> tabIdForPage = tabURL[1].split('&');
							if(tabId == tabIdForPage[0]){
								forecastingHeading = Label.Forecast_Snapshot_US_Heading;
								showUSReport = true;
							}
						} else if(tr.getLabel() == Label.Forecast_Snapshot_Tab_AUS){
							List<String> tabURL = tr.getUrl().split('=');
							List<String> tabIdForPage = tabURL[1].split('&');
							if(tabId == tabIdForPage[0]){
								forecastingHeading = Label.Forecast_Snapshot_AUS_Heading;
								showUSReport = false;
							}
						}
					}
				}
			}
		} catch(Exception ex){
			System.debug(ex);
		}
	}
	/***
		Returns url of report to embed on ForecastSnapshotHomePage
	***/
	public String getReportURL(){
		String reportUrl = '';
		try {
			if(showUSReport){
				reportUrl = new PageReference('/' + Label.ForecastReport).getContent().toString();
			} else {
				reportUrl = new PageReference('/' + Label.ForecastReportAUS).getContent().toString();
			}
		//getContent() will error out in Apex Test Classes so this try catch is to allow testing of this method
		} catch (Exception ex) {
			reportUrl = 'Report does not exist';
		}
		return reportUrl;
	}

	/***
		calls BatchForecastSnapshotMonthly class in order to take a user driven snapshot
	***/
	public void takeSnapshot(){
		try{
			//Get the Record Type ID for Forecasts
			ID forecastRecordTypeId = BI_UtilityLogic.getRecordTypeId(BI_Constants.OBJECT_CAMPAIGNSPEND, 
				BI_Constants.RECORDTYPE_CAMPAIGNSPEND_FORECAST);
			//call the BatchForecastSnapshotMonthly class
			BatchForecastSnapshotMonthly forecastSnapshotMonthly = new BatchForecastSnapshotMonthly();
			String myQuery = 'SELECT Id, CurrencyIsoCode, (SELECT Id, Amount__c, Forecast_Month_Date__c, Forecast_Month__c FROM Campaign_Spend__r WHERE RecordTypeId = \'' + forecastRecordTypeId + '\'), Name, Brand_Quality__c, Brand_Quality__r.Name, ParentMarketingPlan__c, CampaignBalance__c, CampaignBrand__c, ForecastedCampaignSpend__c FROM Campaign__c';
			myQuery += ' WHERE Year__c =  \'' + String.valueOf(System.today().year()) + '\'';
			forecastSnapshotMonthly.query = myQuery;
			//sets variable in batch class to create user driven snapshot records
			forecastSnapshotMonthly.automated = false;
			//sets description for snapshot records
			forecastSnapshotMonthly.userDrivenDescription = userDrivenSnapshotDescription;
			ID batchprocessid = Database.executeBatch(forecastSnapshotMonthly, 200);
			//sets flag to start progress bar logic in getBatchMessage()
			batchProcessed = true;
			batchInfoObj.showProgressBar = true;
			getBatchMessage();
		} catch(Exception ex){
			CreateExceptionLog.insertErrorLog('ForcastSnapshotHomePageController', 'takeSnapshot', String.valueOf(ex), 'Fatal');
		}
	}

	/***
		Queries the batch job progress and outputs the percent complete to the vf page and updates the progress bar
	***/
	public PageReference getBatchMessage(){
		try{
			if (batchProcessed) {
				Double itemsProcessed;
				Double totalItems ;
				String status = '';
				//Query for BatchForecastSnapshotMonthly job
				for (AsyncApexJob forecastJob : [SELECT TotalJobItems, Status, NumberOfErrors, MethodName, JobType, JobItemsProcessed,
				CreatedDate, CreatedById, CompletedDate, ApexClassId, ApexClass.Name, Id
				FROM AsyncApexJob WHERE ApexClass.Name = 'BatchForecastSnapshotMonthly'
				ORDER BY CreatedDate DESC LIMIT 1]) {
					itemsProcessed = forecastJob.JobItemsProcessed;
					totalItems = forecastJob.TotalJobItems;
					status = forecastJob.Status;
				}
				//Determine the percent complete based on the number of batches complete and set message
				if (totalItems == 0 && status != 'Completed') {
					batchInfoObj.percent = 0;
					batchInfoObj.batchMsg = '0%';
				} else {
					//if job is complete set batchComplete flag to true
					if(status == 'Completed'){
						batchComplete = true;
						batchInfoObj.percent = 100;
						batchInfoObj.batchMsg = String.valueof(100) + '%';
					} else {
						batchInfoObj.percent = ((itemsProcessed  / totalItems) * 100.0).intValue();
						batchInfoObj.batchMsg = String.valueof(((itemsProcessed  / totalItems) * 100.0).intValue()) + '%';
					}
				}

			} else {
				batchInfoObj.batchMsg = '0%';
			}
			return null;
		} catch(Exception ex){
			CreateExceptionLog.insertErrorLog('ForcastSnapshotHomePageController', 'getBatchMessage', String.valueOf(ex), 'Error');
			return null;
		}
	}

	public class BatchJobInfo {
		public Integer percent {get;set;}
		public String batchMsg {get; set;}
		public Boolean showProgressBar {get; set;}
	}
}