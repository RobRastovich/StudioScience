public class FeedCommentTriggerHandler{
	static Set<String> closedStatusSet = new Set<String>();
	
	public static void handleNewCaseFeedComment(List<FeedComment> newFeedComments){
		if(closedStatusSet.isEmpty()){
			for (CaseStatus status:[Select MasterLabel From CaseStatus where IsClosed=true]) {
				closedStatusSet.add(status.MasterLabel);
			}
		}

		final String CASE_PREFIX = '500';
		List<Case> casesToUpdate = new List<Case>();
		//Key: CaseId, Value: FeedItem
		Map<Id, FeedComment> caseFeedCommentMap = new Map<Id, FeedComment>();
		for(FeedComment fc: newFeedComments){
			if(((String) fc.ParentId).startsWith(CASE_PREFIX)){
				caseFeedCommentMap.put(fc.ParentId, fc);
			}
		}
		if(caseFeedCommentMap.size() > 0){
			List<Case> caseList = [SELECT Id, Status, OwnerId, Submitter__c FROM Case WHERE Id IN: caseFeedCommentMap.keySet() AND BSI_Function__c = 'GBS' AND Owner.Type = 'User'];
			for(Case c: caseList){
				//The creator of the Feed Item was the Owner of the Case
				if(caseFeedCommentMap.get(c.Id).CreatedById == c.OwnerId){
					c.New_Activity__c = false;
					casesToUpdate.add(c);
				} 
				//The creator of the Feed Item was the Submitter of the Case
				else if(caseFeedCommentMap.get(c.Id).CreatedById == c.Submitter__c){
					c.New_Activity__c = true;
					if(!closedStatusSet.contains(c.Status)){
						c.Status = 'Active';
					}	
					casesToUpdate.add(c);
				}
			}
		}
		if(casesToUpdate.size() > 0){
			update casesToUpdate;
		}
	}
}