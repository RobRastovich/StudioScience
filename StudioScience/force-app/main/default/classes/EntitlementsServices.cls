public without sharing class EntitlementsServices {
	public EntitlementsServices() {

	}

	public static void completeMilestoneOnCaseClose(List<Case> newCases, Map<Id, Case> oldMap) {
		String quoteRequestRTName = ComplianceConstants.RECORDTYPE_QUOTE_REQUEST;
		Id quoteRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(quoteRequestRTName).getRecordTypeId();

		Set<Id> caseIdSet = new Set<Id>();
		for (Case c : newCases) {
			if (c.RecordTypeId == quoteRequestRecordTypeId) {
				caseIdSet.add(c.Id);
			}
			if (CSConstants.orderClaimRecordTypeIds.contains(c.RecordTypeId) && !CSConstants.CLOSED_STATUS_VARIATIONS.contains(oldMap.get(c.Id).Status) && CSConstants.CLOSED_STATUS_VARIATIONS.contains(c.Status)) {
				caseIdSet.add(c.Id);
			}
			if (GBS_Constants.gbsRecordTypeIds.contains(c.RecordTypeId) && !GBS_Constants.CLOSED_STATUS_VARIATIONS.contains(oldMap.get(c.Id).Status) && GBS_Constants.CLOSED_STATUS_VARIATIONS.contains(c.Status)) {
				caseIdSet.add(c.Id);
			}
			if (CSConstants.qualityClaimRecordTypeIds.contains(c.RecordTypeId) && !CSConstants.QC_CLOSED_STATUS_VARIATIONS.contains(oldMap.get(c.Id).Status) && CSConstants.CLOSED_STATUS_VARIATIONS.contains(c.Status)) {
				caseIdSet.add(c.Id);
			}

		}
		if (!caseIdSet.isEmpty()) {
			List <CaseMilestone> cMilestones =  [select id, MilestoneType.Name, case.status from CaseMilestone where isCompleted = false and caseid in : caseIdSet];

			for (CaseMilestone cMilestone : cMilestones) {
				cMilestone.CompletionDate = system.now();
			}
			if (!cMilestones.isEmpty()) {
				Database.Update(cMilestones, false);
			}
		}
	}

	public static List<CaseMilestone> getCaseMilestoneByMilestoneId(Set<Id> caseMilestoneIds) {
		return  [select Id
		         , StartDate
		         , TargetDate
		         , CompletionDate
		         , MilestoneTypeId
		         , MilestoneType.Name
		         , IsCompleted
		         , BusinessHoursId
		         , CaseId
		         , Case.Status
		         , Case.RecordTypeId
		         , TargetResponseInMins
		         , TargetResponseInHrs
		         , TargetResponseInDays
		         , TimeRemainingInMins
		         , TimeSinceTargetInMins
		         , IsViolated FROM CaseMilestone where Id IN :caseMilestoneIds];
	}
	public static List<CaseMilestone> getCaseMilestoneByCaseId(Set<Id> caseIds) {
		return  [select Id
		         , StartDate
		         , TargetDate
		         , CompletionDate
		         , MilestoneTypeId
		         , MilestoneType.Name
		         , IsCompleted
		         , BusinessHoursId
		         , CaseId
		         , Case.Status
		         , Case.RecordTypeId
		         , TargetResponseInMins
		         , TargetResponseInHrs
		         , TargetResponseInDays
		         , TimeRemainingInMins
		         , TimeSinceTargetInMins
		         , IsViolated FROM CaseMilestone where CaseId IN :caseIds AND IsCompleted = false];
	}

	@future
	public static void updateClonedMilestonesFuture(Set<Id> caseMilestoneIds, Set<Id> caseIds) {
		List<CaseMilestone> caseMilestones = new List<CaseMilestone>();
		if (caseMilestoneIds != null) {
			caseMilestones = getCaseMilestoneByMilestoneId(caseMilestoneIds);
		} else if (caseIds != null) {
			caseMilestones = getCaseMilestoneByCaseId(caseIds);
		}
		List<Cloned_Milestone__c> clonedMilestones = ClonedMilestone.buildAndUpdateClonedMilestones(caseMilestones);

		if (!clonedMilestones.isEmpty()) {
			upsert clonedMilestones;
		}
	}

	public static void updateClonedMilestones(Set<Id> caseMilestoneIds, Set<Id> caseIds) {
		List<CaseMilestone> caseMilestones = new List<CaseMilestone>();
		if (caseMilestoneIds != null) {
			caseMilestones = getCaseMilestoneByMilestoneId(caseMilestoneIds);
		} else if (caseIds != null) {
			caseMilestones = getCaseMilestoneByCaseId(caseIds);
		}
		List<Cloned_Milestone__c> clonedMilestones = ClonedMilestone.buildAndUpdateClonedMilestones(caseMilestones);

		if (!clonedMilestones.isEmpty()) {
			upsert clonedMilestones;
		}
	}

}