public class LightningComponentUtility {

	public class RequestStatus {
		@AuraEnabled public Boolean success;
		@AuraEnabled public String message;
		@AuraEnabled public Map<String, Object> responseMap;

		public RequestStatus(Boolean success, String message, Map<String, Object> responseMap) {
			this.success = success;
			this.message = message;
			this.responseMap = responseMap;
		}
	}

	@AuraEnabled
	public static ListView getListView(String listViewName, String objectApiName) {
		ListView listview = new ListView();
		try {
			listview = [SELECT Id, Name FROM ListView WHERE SobjectType = :objectApiName and Name = :listViewName limit 1];

		} catch (Exception err) {

		}
		// Perform isAccessible() check here
		return listview;
	}
}