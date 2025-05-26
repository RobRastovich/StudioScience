public without sharing class RelatedRecordInfoCtrl {
	@testVisible
	public static Boolean forceException = false;
	/**************************************************************************************************************
	Description:	queries for the related record Id to be used in the lightning:recordEditForm component
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	1/2019     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus getRelatedRecord(String recordId, String fieldApiName) {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();
		LightningComponentUtility.RequestStatus requestStatus;
		Id recordIdVal = Id.valueOf(recordId);
		String relatedRecordId;

		try {
			if (Test.isRunningTest() && forceException) {
				DmlException e = new DmlException();
				e.setMessage('Error thrown for test class');
				throw e;
			}
			// get id from apiName
			DescribeSObjectResult describeResult = recordIdVal.getSObjectType().getDescribe();
			List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet());
			String query = ' SELECT ' + String.join(fieldNames, ',') + ' FROM ' + describeResult.getName() +
			               ' WHERE ' +
			               ' Id = :recordIdVal' + ' LIMIT 1';

			List<sObject> records = Database.query(query);

			for (sObject record : Database.query(query)) {
				relatedRecordId = (Id) record.get(fieldApiName);
				break;
			}

			responseMap.put('relatedRecordId', relatedRecordId);

		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message += 'Error Message: ' + e.getMessage();
			message += ',\r';
			message += 'StackTrace: ' + e.getStackTraceString();
			success = false;

			Custom_Exception_Logs__c error = CreateExceptionLog.createExceptionLog('getRelatedRecord', 'getRelatedRecord', String.valueOf(message), 'Fatal', true);
			String endUserMessage = 'An Error Occurred, Please Contact Customer Service. Reference Id: ' + error.Id;

			requestStatus = new LightningComponentUtility.RequestStatus(success, endUserMessage, responseMap);
			return requestStatus;
		}

		requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}
}