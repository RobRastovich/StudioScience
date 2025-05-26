public class FeedItemTriggerHandler {
    static Set<String> closedStatusSet = new Set<String>();

    public static void handleNewCaseFeedItem(List<FeedItem> newFeedItems) {
        if (closedStatusSet.isEmpty()) {
            for (CaseStatus status : [Select MasterLabel From CaseStatus where IsClosed = true]) {
                closedStatusSet.add(status.MasterLabel);
            }
        }

        final String CASE_PREFIX = '500';
        List<Case> casesToUpdate = new List<Case>();
        //Key: CaseId, Value: FeedItem
        Map<Id, FeedItem> caseFeedItemMap = new Map<Id, FeedItem>();
        for (FeedItem fi : newFeedItems) {
            if (((String) fi.ParentId).startsWith(CASE_PREFIX)) {
                caseFeedItemMap.put(fi.ParentId, fi);
            }
        }

        if (!caseFeedItemMap.isEmpty()) {
            List<Case> caseList = [SELECT Id, BSI_Function__c, Status, OwnerId, Submitter__c, CreatedById FROM Case WHERE Id IN: caseFeedItemMap.keySet() AND BSI_Function__c = 'GBS' AND Owner.Type = 'User'];
            System.debug(LoggingLevel.INFO, caseList);
            for (Case c : caseList) {
                //The creator of the Feed Item was the Owner of the Case
                if (caseFeedItemMap.get(c.Id).CreatedById == c.OwnerId) {
                    c.New_Activity__c = false;
                    casesToUpdate.add(c);
                }
                //The creator of the Feed Item was the Submitter of the Case
                else if (caseFeedItemMap.get(c.Id).CreatedById == c.Submitter__c) {
                    c.New_Activity__c = true;
                    if (!closedStatusSet.contains(c.Status) && c.Status != 'Reopened') {
                        c.Status = 'In Progress';
                    }
                    casesToUpdate.add(c);
                }
            }
        }
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }
}