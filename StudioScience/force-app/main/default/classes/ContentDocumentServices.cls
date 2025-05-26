public class ContentDocumentServices {


	/**************************************************************************************************************
	Author:        Craig Austgen
	Company:       Slalom, LLC
	Description:	For the Single Barrel Program a purchase order is required to continue through the barrel order
					if a file is deleted and no other files remain then the flag will be updated on the related case
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	7/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	public static void updatePoUploadFlagOnCase(List<ContentDocumentLink> files, Map<Id, ContentDocumentLink> fileMap) {
		Set<Id> caseIds = new Set<Id>();
		Map<Id, Case> casesToUpdate = new Map<Id, Case>();
		Set<Id> fileIds = fileMap.keySet();
		Map<Id, List<ContentDocumentLink>> caseToFileMap = new Map<Id, List<ContentDocumentLink>>();

		for (ContentDocumentLink cdl : [select Id, LinkedEntity.Type, LinkedEntityId from ContentDocumentLink where Id IN :fileIds]) {
			if (cdl.LinkedEntity.Type == 'Case') {
				caseIds.add(cdl.LinkedEntityId);
			}
		}
        if(caseIds.isEmpty()){
            return;
        }
		for (ContentDocumentLink cdl : [select id, LinkedEntityId from ContentDocumentLink where LinkedEntityId IN :caseIds]) {
			if (!caseToFileMap.containsKey(cdl.LinkedEntityId)) {
				caseToFileMap.put(cdl.LinkedEntityId, new List<ContentDocumentLink>{cdl});
			} else {
				caseToFileMap.get(cdl.LinkedEntityId).add(cdl);
			}
		}
		List<Case> cases = [select id, Purchase_Order_Uploaded__c, RecordType.Developername from Case where Id IN :caseIds AND
		                    (RecordTypeId IN :SBP_Constants.caseSingleBarrelRtIds)];

		for (Case c : cases) {
			if (caseToFileMap.containsKey(c.Id)) {
				if (caseToFileMap.get(c.Id).size() <= 1) {
					c.Purchase_Order_Uploaded__c = false;
					casesToUpdate.put(c.Id, c);
				}
			}
		}

		if (!casesToUpdate.isEmpty()) {
			update casesToUpdate.values();
		}
	}
}