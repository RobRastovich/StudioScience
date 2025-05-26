public without sharing class GBS_BreadCrumbCmpCtrl {

	@AuraEnabled
	public static LightningComponentUtility.RequestStatus getCaseFieldLabels(Map<String, String> fieldApiMap) {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();
		Map<String, Map<String, String>> picklistFieldValueToLabelMap = new Map<String, Map<String, String>>();
		String breadCrumb = '';

		try {
			Map<String, Schema.SObjectField> fieldMap = Case.getSObjectType().getDescribe().fields.getMap();

			for (String field : fieldApiMap.keySet()) {
				List<Schema.PicklistEntry> picklistValues = fieldMap.get(field).getDescribe().getPickListValues();

				for (Schema.PicklistEntry ple : picklistValues) {
					if (!picklistFieldValueToLabelMap.containsKey(field)) {
						picklistFieldValueToLabelMap.put(field, new Map<String, String> {ple.getValue() => ple.getLabel()});
					} else {
						picklistFieldValueToLabelMap.get(field).put(ple.getValue(), ple.getLabel());
					}
				}
			}

			responseMap.put('fieldMap', picklistFieldValueToLabelMap);

		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage();
			message = +'\n';
			message = + e.getStackTraceString();
			success = false;
		}

		LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}
}