public with sharing class QC_FACTSInfoInputCtrl {

	@testVisible
	public static Boolean forceException = false;

	public static List<String> getIncidentPicklistValues(String apiName) {
		List<String> returnedTypeList = new List<String>();
		List<String> optionLabels = new List<String>();
		Map<String, Schema.SObjectField> fieldMap = Incident__c.getSObjectType().getDescribe().fields.getMap();
		List<Schema.PicklistEntry> picklistValues = fieldMap.get(apiName).getDescribe().getPickListValues();

		for (Schema.PicklistEntry ple : picklistValues) {
			optionLabels.add(ple.getLabel());
		}

		return optionLabels;
	}

	/**************************************************************************************************************
	Description:	Returns picklist values used in the lightning component QC_FACTSInfoInput
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	2/2019     	Connor Gallaher    Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus getPicklistOptions() {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();
		LightningComponentUtility.RequestStatus requestStatus;

		try {

			if (Test.isRunningTest() && forceException) {
				DmlException e = new DmlException();
				e.setMessage('Error thrown for test class');
				throw e;
			}
			
			Map<String, List<String>> picklistFields = new Map<String, List<String>> {
				'recommendation'	=> getIncidentPicklistValues('Recommendation__c'),
				'impact' 			=> getIncidentPicklistValues('Impact__c')
			};
			responseMap.put('picklistFields', picklistFields);

		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message += 'Error Message: ' + e.getMessage();
			message += ',\r';
			message += 'StackTrace: ' + e.getStackTraceString();
			success = false;
		}

		requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}
}