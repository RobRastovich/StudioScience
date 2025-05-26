global class SchedulableClonedMilestone implements Schedulable {
	global void execute(SchedulableContext sc) {
		Id orderClaimRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim).getRecordTypeId();
		Id orderClaimSubCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim_Sub_Case).getRecordTypeId();

		try {
			String query = 'select Id '
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

			BatchClonedMilestone batch = new BatchClonedMilestone(query);
			ID batchprocessid = Database.executeBatch(batch, 200);
		} catch (Exception ex) {
			CreateExceptionLog.insertErrorLog('SchedulableClonedMilestone', 'execute', String.valueOf(ex), 'Fatal');
		}
	}
}