public without sharing class GBS_SuggestedDocsCmpCtrl {

	@AuraEnabled
	public static LightningComponentUtility.RequestStatus getSuggestedDocs(String picklistValue, String gbsCenter) {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();
		// used to identify correct field value once it has been translated in the lightning component


		try {

			responseMap.put('links', buildLinks(picklistValue));

		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage() +'\n' + e.getStackTraceString();
			success = false;
		}

		LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}

    	public static List<GBS_Flow_Document_Setting__mdt> getSuggestedDocumentCustomMetadata(String picklistValue) {
		return [select Id
		        , Business_Function__c
		        , Display_Text__c
		        , Link__c
		        , GBS_Flow_Picklist_Setting__r.Custom_Label__c
		        , GBS_Flow_Picklist_Setting__r.Value__c from GBS_Flow_Document_Setting__mdt where GBS_Flow_Picklist_Setting__r.Value__c = :picklistValue];
	}

    public static List<Link> buildLinks(String picklistValue){
        List<Link> links = new List<Link>();
        for(GBS_Flow_Document_Setting__mdt doc : getSuggestedDocumentCustomMetadata(picklistValue)){
            links.add(new Link(doc.Link__c, doc.Display_Text__c));
        }

        return links;
    }


	public class Link {
		@AuraEnabled public String url;
		@AuraEnabled public String label;

		public Link(String url, String label) {
			this.url = url;
			this.label = label;
		}
	}
}