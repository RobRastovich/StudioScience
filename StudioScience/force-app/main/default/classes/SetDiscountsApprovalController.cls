public without sharing class SetDiscountsApprovalController {
	public SetDiscountsApprovalController() {
		
	}

	@AuraEnabled
	public static CaseComplianceUtility.RequestStatus getDiscountInit(String caseId){
		String docType = 'Discounts Document';
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();

		List<ContentDocumentLink> caseContentDocumentLinkList = [SELECT Id, ContentDocumentId
																	FROM ContentDocumentLink 
																	WHERE LinkedEntityId =: caseId];
		Set<Id> contentDocumentIdSet = new Set<Id>();
		for(ContentDocumentLink cdl: caseContentDocumentLinkList){
			contentDocumentIdSet.add(cdl.ContentDocumentId);
		}
		
		try{
			Case currCase = [SELECT Id, Approval_Status__c FROM Case WHERE Id =: caseId LIMIT 1];

			ContentVersion currContentVersion = [SELECT Id, Document_Type__c, Document_Status__c, ContentDocumentId
													FROM ContentVersion 
													WHERE ContentDocumentId IN: contentDocumentIdSet
													AND Document_Type__c =: docType
													AND IsLatest = true
													ORDER BY ContentDocument.CreatedDate DESC
													LIMIT 1];
			
			responseMap.put('versionId', currContentVersion.Id);
			responseMap.put('documentId', currContentVersion.ContentDocumentId);
			responseMap.put('documentStatus', currContentVersion.Document_Status__c);
			responseMap.put('approvalStatus', currCase.Approval_Status__c);
		} catch(Exception e){
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage();
			success = false;
		}

		CaseComplianceUtility.RequestStatus requestStatus = new CaseComplianceUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}

	/*
	* Case Id: The Id of the Case
	* Document Id: The Id of the Document
	* Boolean Response: TRUE indicates approval, FALSE indicates rejection
	* String ChangeDescription: An optional String field 
	* Returns: A RequestStatus Object
	*/
	@AuraEnabled
	public static CaseComplianceUtility.RequestStatus recordApprovalStatus(String caseId, String versionId, Boolean response, String changeDescription){
		Boolean success = true;
		String message = null;

		try{
			String approvalStatus = (response==true) ? 'Approved' : 'Rejected';

			Case currCase = new Case(Id=caseId, Approval_Status__c=approvalStatus );
			if(!String.isBlank(changeDescription) && !response){
				currCase.Document_Change_Description__c = changeDescription;
			}
			if(response){
				currCase.Approved__c = true;
				currCase.Approval_Date__c = System.today();
				currCase.Status = 'Waiting for Submission';
			}

			update currCase;

			CaseComplianceUtility.sendEmailOnDiscountApprovalStatusChange(caseId, response);

			ContentVersion currVersion = new ContentVersion(Id=versionId, Document_Status__c=approvalStatus);
			update currVersion;
		} catch(Exception e){
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage();
			success = false;
		}

		CaseComplianceUtility.RequestStatus requestStatus = new CaseComplianceUtility.RequestStatus(success, message, null);
		System.debug(LoggingLevel.INFO, 'Request Object: ' + requestStatus);
		return requestStatus;
	}

}