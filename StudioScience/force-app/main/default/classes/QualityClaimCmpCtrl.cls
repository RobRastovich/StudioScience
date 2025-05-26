public without sharing class QualityClaimCmpCtrl {
	@testVisible
	public static Boolean forceException = false;


	public static List<String> getCasePicklistValues(String apiName) {
		List<String> returnedTypeList = new List<String>();
		List<String> optionLabels = new List<String>();
		Map<String, Schema.SObjectField> fieldMap = Case.getSObjectType().getDescribe().fields.getMap();
		List<Schema.PicklistEntry> picklistValues = fieldMap.get(apiName).getDescribe().getPickListValues();

		for (Schema.PicklistEntry ple : picklistValues) {
			optionLabels.add(ple.getLabel());
		}

		return optionLabels;
	}

	/**************************************************************************************************************
	Description:	Returns picklist values used in the lightning component QualityClaimCmp
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	10/2018     Craig Austgen       Initial Creation

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
				'productSize' 	=> getCasePicklistValues('Product_Size__c'),
				'bottlingPlant' => getCasePicklistValues('Bottling_Plant__c'),
				'countries' 	=> getCasePicklistValues('Product_Destination_Country__c')
			};
			responseMap.put('picklistFields', picklistFields);

		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message += 'Error Message: ' + e.getMessage();
			message += ',\r';
			message += 'StackTrace: ' + e.getStackTraceString();
			success = false;
			Custom_Exception_Logs__c error = CreateExceptionLog.createExceptionLog('QualityClaimCmpCtrl', 'getPicklistOptions', String.valueOf(message), 'Fatal', true);
			String endUserMessage = 'An Error Occurred, Please Contact Customer Service. Reference Id: ' + error.Id;

			requestStatus = new LightningComponentUtility.RequestStatus(success, endUserMessage, responseMap);
			return requestStatus;
		}

		requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}

	/**************************************************************************************************************
	Description:	Returns information about the current user
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	10/2018     Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus getUserInformation(String userId) {
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

			User u = [select id, ContactId, Profile.UserLicense.Name, isBailmentUser__c from User where Id = :Id.valueOf(userId)];
			responseMap.put('userInfo', u);
			responseMap.put('userId', u.Id);
			responseMap.put('userLicense', u.Profile.UserLicense.Name);

		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message += 'Error Message: ' + e.getMessage();
			message += ',\r';
			message += 'StackTrace: ' + e.getStackTraceString();
			success = false;
			Custom_Exception_Logs__c error = CreateExceptionLog.createExceptionLog('QualityClaimCmpCtrl', 'getUserInformation', String.valueOf(message), 'Fatal', true);
			String endUserMessage = 'An Error Occurred, Please Contact Customer Service. Reference Id: ' + error.Id;

			requestStatus = new LightningComponentUtility.RequestStatus(success, endUserMessage, responseMap);
			return requestStatus;
		}

		requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}



}