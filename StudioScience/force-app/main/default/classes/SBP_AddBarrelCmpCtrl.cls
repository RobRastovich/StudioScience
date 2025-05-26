public without sharing class SBP_AddBarrelCmpCtrl {
	/**************************************************************************************************************
    Author:        Craig Austgen
    Company:       Slalom, LLC
    Description:   On a trip and tour a certain number of barrels will be specified before hand, but there is the option to 
    				select additional barrels at the plant if the user chooses to, this method clones the values 
    				from the existing case and creates a new case for the new barrel
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    7/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus createNewCase(String caseId) {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();

		try {
			Database.DMLOptions dmo = new Database.DMLOptions();
			dmo.AssignmentRuleHeader.useDefaultRule = true;

			Case currentCase = [select id, Brand__c, Barrel_Order_Group__c,Product_Type__c, RecordTypeId, AccountId, Retail_Account__c, ContactId, Plant_Event__c from Case where Id = : Id.valueOf(caseId)];

			Case newCase = currentCase.clone(false, false, false, false);
			Database.insert(newCase, dmo);

			responseMap.put('newCase', newCase.Id);
			responseMap.put('case', newCase);
			responseMap.put('recordTypeId', SBP_Constants.fullBarrelBrandRTIdMap.get(newCase.Brand__c));

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