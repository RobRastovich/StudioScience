public class ContentDocumentLinkTriggerHandler {

	/*public static void handleBeforeInsert(List<ContentDocumentLink> files) {

	}

	public static void handleBeforeUpdate(List<ContentDocumentLink> files, Map<Id, ContentDocumentLink> oldFiles) {

	}*/

	public static void handleBeforeDelete(List<ContentDocumentLink> files, Map<Id, ContentDocumentLink> oldFiles) {
        ContentDocumentServices.updatePoUploadFlagOnCase(files, oldFiles);
	}
	

	public static void handleAfterInsert(List<ContentDocumentLink> files, Map<Id, ContentDocumentLink> newFiles) {
		ContentDocumentLinkServices.updatePoUploadFlagOnCase(files, newFiles);
	}
/*
	public static void handleAfterUpdate(List<ContentDocumentLink> files, Map<Id, ContentDocumentLink> oldFiles) {

	}
	*/


}