public without sharing class SetItemController {
	public SetItemController() {
		
	}

	/*
	* Method Run on Init of SetItemAvailabilityComponentHelper
	*/
	@AuraEnabled
	public static CaseComplianceUtility.RequestStatus getRelatedQuoteRequests(Id caseId){
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();
		try{
			Map<Id, Quote_Request__c> quoteRequests = new Map<Id, Quote_Request__c>(
				[SELECT Id, Item_Name__c, Item_Size__c, Item_Price__c, Price_Needed__c, Item_Available__c, 
						Quote_Type__c, Priority__c, State__c, Unavailability_Reason__c, Unavailability_Reason_Other__c, 
						Additional_Comments__c FROM Quote_Request__c WHERE Case__c =: caseId]);
			responseMap.put('quoteRequestMap', quoteRequests);
			
			if(caseId == null){
				success = false;
				message = 'There was no Case found with the given Id.';
			} else if(quoteRequests.size() == 0){
				success = false;
				message = 'There were no Quote Requests found for the given Case Id.';
			}
		} catch(Exception e){
			success = false;
			message = e.getMessage();
		}

		CaseComplianceUtility.RequestStatus requestStatus = new CaseComplianceUtility.RequestStatus(success, message, responseMap);
		return requestStatus;
	}

	/*
	* Method Run on Init of SetItemAvailabilityComponentHelper
	*/
	@AuraEnabled
	public static CaseComplianceUtility.RequestStatus getCurrentCase(Id caseId){
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();
		try{
			Case currCase = [SELECT Id, Approved__c, Submitted_Compliance__c, Owner.Type FROM Case WHERE Id =: caseId];
			responseMap.put('case', currCase);
		} catch(Exception e){
			success = false;
			message = e.getMessage();
		}

		CaseComplianceUtility.RequestStatus requestStatus = new CaseComplianceUtility.RequestStatus(success, message, responseMap);
		return requestStatus;
	}

	/*
	* Method Run on Init of SetItemAvailabilityComponentHelper
	*/
	@AuraEnabled
	public static List<String> getUnavailabilityReasonPicklistValues(){
		String itemSizeAPIName = ComplianceConstants.QUOTE_REQUEST_UNAVAILABILITY_REASON_FIELD_API_NAME;
		List<String> optionLabels = new List<String>();
		Map<String, Schema.SObjectField> fieldMap = Quote_Request__c.getSObjectType().getDescribe().fields.getMap();
		List<Schema.PicklistEntry> picklistValues = fieldMap.get(itemSizeAPIName).getDescribe().getPickListValues();
		
		for (Schema.PicklistEntry ple : picklistValues) {
			optionLabels.add(ple.getLabel());
		}

		return optionLabels;
	}

	@AuraEnabled
	public static CaseComplianceUtility.RequestStatus updateRelatedQuoteRequests(Map<Id, Quote_Request__c> quoteMap, Id caseId){
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();

		Boolean needsPricing = false;
		String availabilitySetFlag = ComplianceConstants.FLAG_QUOTE_REQUEST_AVAILABILITY_SET;
		Case currCase = [SELECT Id, Compliance_Flagset__c FROM Case WHERE Id =: caseId];
		currCase = CaseComplianceUtility.setComplianceFlagsetValue(currCase, availabilitySetFlag);
		currCase.Submitted_Compliance__c = true;
		for(Quote_Request__c qr: quoteMap.values()){
			if(qr.Price_Needed__c != null && qr.Price_Needed__c == 'Yes'){
				needsPricing = true;
				break;
			}
		}
        Boolean allUnavailable = true;
        for(Quote_Request__c qr: quoteMap.values()){
            if(qr.Item_Available__c == 'Yes'){
                allUnavailable = false;
                break;
            }
        }
        if(allUnavailable){
            currCase.Status = 'Close Pending';
        } 
        else if(needsPricing){
			currCase.Status = 'Waiting for Approval';
			currCase.Approval_Needed__c = 'Yes';
		} 
        else {
			currCase.Status = 'Waiting for Submission';
			currCase.Approval_Needed__c = 'No';
		}

		try{
			update quoteMap.values();
			update currCase;
			CaseComplianceUtility.sendEmailQuoteRequestItemAvailability(caseId);
            
		}catch(Exception e){
			success = false;
			message = e.getMessage();
		}

		CaseComplianceUtility.RequestStatus requestStatus = new CaseComplianceUtility.RequestStatus(success, message, responseMap);
		return requestStatus;
	}

	@AuraEnabled
	public static CaseComplianceUtility.RequestStatus updateQuoteRequests(List<Quote_Request__c> quoteList, Id caseId, Boolean hasUnpriced){
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();
		
		try{
			update quoteList;
			if(!hasUnpriced){
				String pricingSetFlag = ComplianceConstants.FLAG_QUOTE_REQUEST_PRICING_SET;
				Case currCase = [SELECT Id, Compliance_Flagset__c FROM Case WHERE Id =: caseId];
				currCase = CaseComplianceUtility.setComplianceFlagsetValue(currCase, pricingSetFlag);
				currCase.Status='Waiting for Submission';
				currCase.Approval_Status__c='Approved';
				currCase.Approved__c=true;
				currCase.Approval_Date__c=System.Today();
				update currCase;
			}
		} catch(Exception e){
			success = false;
			message = e.getMessage();
		}

		CaseComplianceUtility.RequestStatus requestStatus = new CaseComplianceUtility.RequestStatus(success, message, responseMap);
		return requestStatus;
	}
}