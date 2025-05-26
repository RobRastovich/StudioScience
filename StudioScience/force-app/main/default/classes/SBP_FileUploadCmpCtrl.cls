public class SBP_FileUploadCmpCtrl {

	/**************************************************************************************************************
	Author:        Craig Austgen
	Company:       Slalom, LLC
	Description:	Pulls in all related files to the record Id.  The FileUploadCmp uses this data to show related files
					in the community
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	7/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus getRelatedFiles(Id recordId) {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();

		try {
			List<ContentDocumentLink> cdls = [select Id, ContentDocument.Title, ContentDocument.Id, ContentDocument.ContentSize, ContentDocument.FileType, LinkedEntity.Type, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :recordId];

			responseMap.put('files', cdls);

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
	Description:	A csv file will be uploaded by the innerworkings team via a salesforce site, they will update the
					tracking number for each pos item and upload the file, which will update the salesforce records
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	7/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static Boolean updatePOS(String jsonPOS) {
		List<POS_Customization__c> posItems = (List<POS_Customization__c>)System.JSON.deserialize(jsonPOS, List<POS_Customization__c>.Class);
		for (POS_Customization__c pos : posItems) {
			pos.Uploaded_Date__c = DateTime.now();
			pos.Uploaded_by__c = UserInfo.getUserId();
		}
		system.debug(posItems);
		if (!posItems.isEmpty()) {
			update posItems;
			return true;
		} else {
			return false;
		}
	}

	/**************************************************************************************************************
	Author:        Craig Austgen
	Company:       Slalom, LLC
	Description:	A csv file will be sent to the El Tesoro team with open application and once those applications
					have been updated on their end whether an application has been approved or rejected and then
					upload the file which will update the corresponding salesforce records
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	7/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static Boolean updateApplications(String jsonApplications) {
		System.debug(jsonApplications);
		Map<Id, Account_Application__c> applicationMap = new Map<Id, Account_Application__c>();
		List<Application_Response__c> responses = (List<Application_Response__c>)System.JSON.deserialize(jsonApplications, List<Application_Response__c>.Class);
		System.debug(responses);
		for (Application_Response__c response : responses) {
			if (!applicationMap.containsKey(response.Account_Application__c)) {
				Account_Application__c app = new Account_Application__c();
				app.put('Id', response.Account_Application__c);
				app.put('Status__c', response.Application_Status__c);

				applicationMap.put(app.Id, app);
			}

		}
		system.debug(applicationMap);
		if (!applicationMap.isEmpty()) {
			update applicationMap.values();
			return true;
		} else {
			return false;
		}

	}

	/**************************************************************************************************************
	Author:        Craig Austgen
	Company:       Slalom, LLC
	Description:	Pulls in all related files to the record Id.  The FileUploadCmp uses this data to show related files
				in the community
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	7/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus validateVerificationCode(String verificationCode) {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();
		Boolean isValidCode = false;

		String code = String.escapeSingleQuotes(verificationCode);

		try {
			Single_Barrel_Verification_Code__mdt setting = [select id, Code__c, Brand__c, Object__c from Single_Barrel_Verification_Code__mdt where Code__c = :code limit 1];
			if (setting != null) {
				isValidCode = true;
			}
			responseMap.put('isValidCode', isValidCode);
			responseMap.put('brand', setting.Brand__c);
			responseMap.put('object', setting.Object__c);

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