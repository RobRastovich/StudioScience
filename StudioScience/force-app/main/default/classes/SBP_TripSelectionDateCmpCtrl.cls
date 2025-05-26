public class SBP_TripSelectionDateCmpCtrl {
	/**************************************************************************************************************
	Author:        Craig Austgen
	Company:       Slalom, LLC
	Description:
	Inputs:        accountId:
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	7/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus getRejectedDates(String caseId) {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();

		try {
			List<CaseHistory> caseHistory = [SELECT Id, CaseId, Field, OldValue, NewValue FROM CaseHistory where CaseId = :Id.valueOf(caseId) AND Field = 'Remote_Selection_Date__c'];

			if (!caseHistory.isEmpty()) {
				responseMap.put('caseHistory', caseHistory);
			} else {
				responseMap.put('caseHistory', null);
			}

		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage();
			success = false;
		}

		LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}

	/**************************************************************************************************************
	Author:        Craig Austgen
	Company:       Slalom, LLC
	Description:
	Inputs:        accountId:
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	7/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus getCase(String caseId) {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();
		Boolean showInput = false;

		try {
			Case c = [select id, Remote_Selection_Date__c, Type, Approval_Status__c from Case where Id = :Id.valueOf(caseId)];

			if (c.Approval_Status__c == 'Rejected' || String.isBlank(c.Approval_Status__c)) {
				showInput = true;
			}

			responseMap.put('case', c);
			responseMap.put('dateStatus', c.Approval_Status__c);
			responseMap.put('showInput', showInput);

		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage();
			success = false;

		}

		LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}

	/**************************************************************************************************************
	Author:        Craig Austgen
	Company:       Slalom, LLC
	Description:
	Inputs:        accountId:
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	7/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus updateCase(String selectionDate, String caseId) {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();

		try {
			Case c = new Case();
			c.put('Id', Id.valueOf(caseId));
			c.put('Remote_Selection_Date__c', Date.valueOf(selectionDate));
			update c;

			responseMap.put('case', c);
		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage();
			success = false;

		}

		LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}
}