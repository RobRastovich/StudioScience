public without sharing class SetPriceFilingApprovalController {
	public SetPriceFilingApprovalController() {
		
	}

	@AuraEnabled
	public static /*Map<String, String>*/ CaseComplianceUtility.RequestStatus getFinalizedWorkbookFromCase(String caseId){
		String documentTypeFilter = 'Finalized Workbook';
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();

		try{
			if(!String.isBlank(caseId)){
				Case currCase = [SELECT Approval_Status__c, Approved__c, Rejected__c FROM Case WHERE Id =: caseId];
				responseMap.put('approved', String.valueOf(currCase.Approved__c));
				responseMap.put('rejected', String.valueOf(currCase.Rejected__c));
			} else {
				responseMap.put('approved', null);
				responseMap.put('rejected', null);
			}
			Set<Id> cdlIdSet = new Set<Id>();
			List<ContentDocumentLink> cdLinkList = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.CreatedDate 
													FROM ContentDocumentLink 
													WHERE LinkedEntityId=:caseId];

			for(ContentDocumentLink cdl: cdLinkList){
				cdlIdSet.add(cdl.ContentDocumentId);
			}

			List<ContentVersion> cvList = [SELECT Id, ContentDocumentId, ContentDocument.CreatedDate 
											FROM ContentVersion 
											WHERE Document_Type__c=:documentTypeFilter 
											AND IsLatest=true
											AND ContentDocumentId IN: cdlIdSet
											ORDER BY ContentDocument.CreatedDate DESC];

			//If there's at least one Content Version with Document Type of "Finalized Workbook", that's the one we want
			//Because we're sorting by ContentDocument's CreatedDate Descending, the file in index 0 should be the most recently uploaded
			//Since we used IsLatest=True, we can say that it's also the most recent version of this Document	
			if(cvList.size() > 0){
				responseMap.put('documentId', cvList[0].ContentDocumentId);
			} else {
				responseMap.put('documentId', null);
			}
		} catch(Exception e){
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage();
			success = false;
		}
		CaseComplianceUtility.RequestStatus requestStatus = new CaseComplianceUtility.RequestStatus(success, message, responseMap);
		return requestStatus;
	}

	@AuraEnabled
	public static CaseComplianceUtility.RequestStatus recordResponseToCase(String caseId, String response, String changeDescription){
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();
		String caseIdBlankMessage = 'Case Id was null or empty';
		String responseBlankMessage = 'The response value was null or empty';
		Boolean approved = false;
		try{
			String approvalStatus = (response=='approved') ? 'Approved' : 'Rejected';
			if(!String.isBlank(caseId)){
				if(String.isBlank(response)){
					message = responseBlankMessage;
					success = false;
				} else if(response.equalsIgnoreCase('approved')) {
					Case tempCase = new Case(Id=caseId, Approval_Status__c=approvalStatus, Approved__c=true, Approval_Date__c=System.Today(), Rejected__c=false, Status='Waiting for Submission');
					update tempCase;
					CaseComplianceUtility.sendEmailOnPriceFilingApprovalStatusChange(caseId, true);
				} else if(response.equalsIgnoreCase('rejected')) {
					Case tempCase = new Case(Id=caseId, Approval_Status__c=approvalStatus, Approved__c=false, Rejected__c=true, Document_Change_Description__c=changeDescription);
					update tempCase;
					CaseComplianceUtility.sendEmailOnPriceFilingApprovalStatusChange(caseId, false);
				}
			} else {
				message = caseIdBlankMessage;
				success = false;
			}			
		} catch(Exception e){
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage();
			success = false;
		}
		CaseComplianceUtility.RequestStatus requestStatus = new CaseComplianceUtility.RequestStatus(success, message, responseMap);
		return requestStatus;
	}
}