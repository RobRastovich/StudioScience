public without sharing class ComboInputCmpCtrl {

    public static List<PicklistWrapper> getPicklistFieldValues(String objectName, String pickListFieldName){
        List<PicklistWrapper> picklistValues = new List<PicklistWrapper>();

        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        List<Schema.PicklistEntry> values = objectType.getDescribe().fields.getMap().get(pickListFieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry picklistVal : values) {
            picklistValues.add(new PicklistWrapper(picklistVal.getLabel(),picklistVal.getValue()));
        }
        return picklistValues;
    }

    /**************************************************************************************************************
	Description:	Returns picklist values
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	3/2019     Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus getPicklistOptions(String fieldApiName, String objectApiName) {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();
		LightningComponentUtility.RequestStatus requestStatus;

		try {

			responseMap.put('picklistValues', getPicklistFieldValues(objectApiName,fieldApiName));

		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage() +'\n' + e.getStackTraceString();
			success = false;

			requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
			return requestStatus;
		}

		requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}

    	public class PicklistWrapper {
		@AuraEnabled public String label;
		@AuraEnabled public String value;

		public PicklistWrapper(String label, String value) {
			this.label = label;
			this.value = value;
		}
	}
}