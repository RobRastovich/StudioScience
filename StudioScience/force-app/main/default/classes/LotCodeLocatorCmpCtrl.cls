public without sharing class LotCodeLocatorCmpCtrl {
	@testVisible
	public static Boolean forceException = false;

	/**************************************************************************************************************
	Description:	Pulls in all custom metadata for Lot Codes so that they can be displayed to end users in the
					Customer Community Quality Claim Flow
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	1/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus getLotCodeImages() {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();
		LightningComponentUtility.RequestStatus requestStatus;
		Map<String, Brand_Lot_Code_Setting__mdt> brandToLotCodeImage = new Map<String, Brand_Lot_Code_Setting__mdt>();

		try {

			if (Test.isRunningTest() && forceException) {
				DmlException e = new DmlException();
				e.setMessage('Error thrown for test class');
				throw e;
			}

			for (Brand_Lot_Code_Setting__mdt lotCode : getLotCodeCustomMetadata()) {
				if (!brandToLotCodeImage.containsKey(lotCode.Brand__c)) {
					brandToLotCodeImage.put(lotCode.Brand__c, lotCode);
				}
			}

			responseMap.put('brandToLotCodeImage', brandToLotCodeImage);

		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message += 'Error Message: ' + e.getMessage();
			message += ',\r';
			message += 'StackTrace: ' + e.getStackTraceString();
			success = false;

			Custom_Exception_Logs__c error = CreateExceptionLog.createExceptionLog('LotCodeLocatorCmpCtrl', 'getLotCodeImages', String.valueOf(message), 'Fatal', true);
			String endUserMessage = 'An Error Occurred, Please Contact Customer Service. Reference Id: ' + error.Id;

			requestStatus = new LightningComponentUtility.RequestStatus(success, endUserMessage, responseMap);
			return requestStatus;
		}

		requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}


	public static List<Brand_Lot_Code_Setting__mdt> getLotCodeCustomMetadata() {
		return  [select Id
		         , MasterLabel
		         , Static_Resource_Name__c
		         , Brand__c from Brand_Lot_Code_Setting__mdt];
	}
}