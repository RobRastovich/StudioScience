public class SBP_SplitBarrelCmpCtrl {

	/**************************************************************************************************************
	Author:        Craig Austgen
	Company:       Slalom, LLC
	Description:
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	7/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static Map<String, List<String>> getSplitBarrelPickListValues() {
		return SBP_AccountInfoCmpCtrl.getSingleBarrelPicklistValues();
	}


	/**************************************************************************************************************
		Author:        Craig Austgen
		Company:       Slalom, LLC
		Description:
		History
		<Date>      <Authors Name>     <Brief Description of Change>
		7/2018     	Craig Austgen       Initial Creation

		***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus insertSplitBarrelRecords(String jsonBarrels, String caseId) {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();
		List<String> splitBarrelIds = new List<String>();

		try {
			Barrel__c newBarrel = new Barrel__c();
			newBarrel.Case__c = Id.valueOf(caseId);
			newBarrel.RecordTypeId = SBP_Constants.KNOB_CREEK_SPLIT_BARREL_RT_ID;
			newBarrel.Warehouse__c = null;
			newBarrel.Rick__c = null;
			newBarrel.Floor__c = null;
			newBarrel.Story__c = null;
			insert newBarrel;

			Case caseRecord = [select id, Brand__c, Retail_Account__c from Case where id = :Id.valueOf(caseId) limit 1];

			Database.DMLOptions dmo = new Database.DMLOptions();
			dmo.AssignmentRuleHeader.useDefaultRule = true;

			List<Case> splitBarrels = (List<Case>)System.JSON.deserialize(jsonBarrels, List<Case>.Class);
			for (Case c : splitBarrels) {
				c.Barrel__c = newBarrel.Id;
				c.RecordTypeId = SBP_Constants.SINGLE_BARREL_SPLIT_BARREL_RT_ID;
				c.Brand__c = caseRecord.Brand__c;
				c.Retail_Account__c = caseRecord.Retail_Account__c;
			}

			Database.insert(splitBarrels, dmo);

			responseMap.put('barrelId', newBarrel.Id);
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