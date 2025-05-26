global class BatchClonedMilestone implements Database.Batchable<sObject> {

	String query;
	Id orderClaimRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim).getRecordTypeId();
	Id orderClaimSubCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim_Sub_Case).getRecordTypeId();

	global BatchClonedMilestone(String query) {
		this.query = query;
	}
	global BatchClonedMilestone() {
		query = 'select Id '
		        + ', StartDate'
		        + ', TargetDate'
		        + ', CompletionDate'
		        + ', MilestoneTypeId'
		        + ', MilestoneType.Name'
		        + ', IsCompleted'
		        + ', BusinessHoursId'
		        + ', CaseId'
		        + ', Case.Status'
		        + ', Case.RecordTypeId'
		        + ', TargetResponseInMins'
		        + ', TargetResponseInHrs'
		        + ', TargetResponseInDays'
		        + ', TimeRemainingInMins'
		        + ', TimeSinceTargetInMins'
		        + ', IsViolated FROM CaseMilestone where Case.RecordTypeId = \'' + orderClaimRecordTypeId + '\' OR Case.RecordTypeId = \'' + orderClaimSubCaseRecordTypeId + '\' ';

	}


	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<CaseMilestone> scope) {

		List<Cloned_Milestone__c> clonedMilestones = ClonedMilestone.buildAndUpdateClonedMilestones(scope);

		Database.UpsertResult[] cMilestones = Database.upsert(clonedMilestones, false);

		for (Database.UpsertResult cm : cMilestones) {
			if (cm.isSuccess()) {
			} else {
				for (Database.Error err : cm.getErrors()) {
					//CreateExceptionLog.insertErrorLog('BatchForecastSnapshotMonthly', 'execute', String.valueOf(ex), 'Fatal');
				}
			}
		}
	}

	global void finish(Database.BatchableContext BC) {

	}

}