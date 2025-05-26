/**************************************************************************************
 Apex Class Name     : ClonedMilestone
 Created Date        : 3/2018
 Function            : Methods copy data from the Standard object CaseMilestone to
 						a new custom object "Cloned_Milestone__c" so that we can build
 						better reports
*************************************************************************************/

public with sharing class ClonedMilestone {


	/**************************************************************************************************************
	Method name:    	buildAndUpdateClonedMilestones
	Object:         	Cloned_Milestone__c
	Date:           	3/2018
	Details and Notes:  Copies data from the standard object CaseMilestone to a custom object "Cloned_Milestone__c"
						And either creates a new record or updates the existing one.
	***************************************************************************************************************/
	public static List<Cloned_Milestone__c> buildAndUpdateClonedMilestones(List<CaseMilestone> caseMilestones) {
		List<Cloned_Milestone__c> clonedMilestones = new List<Cloned_Milestone__c>();
		Map<Id, CaseMilestone> caseMilestoneMap = new Map<Id, CaseMilestone>(caseMilestones);
		Map<Id, Id> caseMilestoneToClonedMilestone = getExistingClonedMilestones(caseMilestoneMap.keySet());
		Map<Id, Case> caseMap = getCaseMapByMilestone(caseMilestones);


		for (CaseMilestone cm : caseMilestones) {

			Cloned_Milestone__c clone = new Cloned_Milestone__c();
			if (caseMilestoneToClonedMilestone.containsKey(cm.Id)) {
				clone.Id = caseMilestoneToClonedMilestone.get(cm.Id);
			}
			clone.Business_Hours__c = cm.BusinessHoursId;
			clone.Case__c = cm.CaseId;
			clone.Start_Date__c = cm.StartDate;
			clone.Completion_Date__c = cm.CompletionDate;
			clone.Target_Date__c = cm.TargetDate;
			clone.Completed__c = cm.IsCompleted;
			clone.Case_Milestone_Id__c = String.valueOf(cm.Id);
			clone.Milestone_Name__c = cm.MilestoneType.Name;
			clone.Violation__c = cm.IsViolated;
			clone.Milestone_Type_Id__c = String.valueOf(cm.MilestoneTypeId);
			clone.Target_Response_Mins__c = cm.TargetResponseInMins;
			clone.Target_Response_Hours__c = cm.TargetResponseInHrs;
			clone.Target_Response_Days__c = cm.TargetResponseInDays;
			clone.Time_Remaining_Mins__c = cm.TimeRemainingInMins.split(':')[0];
			clone.Overdue_Mins__c = cm.TimeSinceTargetInMins.split(':')[0];
			if (caseMap.containsKey(cm.CaseId) && !cm.IsCompleted) {
				clone.ReOpened__c = caseMap.get(cm.CaseId).isReOpened__c;
			}
			clonedMilestones.add(clone);
		}

		return clonedMilestones;
	}

	public static Map<Id, Id> getExistingClonedMilestones(Set<Id> caseMilestoneIds) {
		Map<Id, Id> caseMilestoneToClonedMilestone = new Map<Id, Id>();
		for (Cloned_Milestone__c clonedMilestone : [select id, Case_Milestone_Id__c from Cloned_Milestone__c where Case_Milestone_Id__c IN : caseMilestoneIds]) {
			caseMilestoneToClonedMilestone.put(clonedMilestone.Case_Milestone_Id__c, clonedMilestone.Id);
		}

		return caseMilestoneToClonedMilestone;
	}

	public static Map<Id, Case> getCaseMapByMilestone(List<CaseMilestone> caseMilestones) {
		Set<Id> caseIds = new Set<Id>();
		Map<Id, Case> caseMap = new Map<Id, Case>();

		for (CaseMilestone cm : caseMilestones) {
			caseIds.add(cm.CaseId);
		}

		for (Case c : [Select Id, isReOpened__c from Case where Id IN :caseIds]) {
			caseMap.put(c.Id, c);
		}

		return caseMap;
	}
}