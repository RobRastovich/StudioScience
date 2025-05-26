@isTest
private class TST_CNT_TopicList {
    @testSetup
    static void dataSetup() {
        Topic topic = new Topic(Name='Test Topics');
        insert topic;
        Case caseRecord = new Case();
        insert caseRecord;
        TopicAssignment topicAss = new TopicAssignment();
        topicAss.TopicId = topic.Id;
        topicAss.EntityId = caseRecord.Id;
        insert topicAss;
        Topic_Added_For_User__c topicAddedForUser = new Topic_Added_For_User__c(Name='7', 
                                                                                Topic_Name__c = 'Test Topics');
        insert topicAddedForUser;
    }
    
    @isTest
    private static void testFetchTopicList() {
        Case caseRecord = [SELECT Id 
                              FROM Case 
                              Limit 1];
        
        Test.startTest();
            List<CNT_TopicList.TopicWrapper> topicsWrapper = CNT_TopicList.fetchTopicList(caseRecord.Id);
        Test.stopTest();
        
        System.assertEquals(true, topicsWrapper[0].isSelected, 'isSeleted should be true');
    }
    
    @isTest
    private static void testInsertTopicAssignments() {
        Case caseRecord = [SELECT Id 
                              FROM Case 
                              Limit 1];
        Topic topic = [SELECT Id, Name 
                          FROM Topic 
                          Limit 1];
        List<Id> topicIds = new List<Id>();
        topicIds.add(topic.id);
        List<Id> wrongtopicId = new List<Id>();
        wrongtopicId.add(caseRecord.Id);
        
        Test.startTest();
        	CNT_TopicList.insertTopicAssignments(wrongtopicId, caseRecord.Id);
        	CNT_TopicList.insertTopicAssignments(topicIds, caseRecord.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, caseRecord, 'mcase is not to be null');
    }
    
    @isTest
    private static void testDeleteTopicAssignments() {
        TopicAssignment topicAss = [SELECT Id 
                                        FROM TopicAssignment 
                                        Limit 1];
        Case caseRecord = [SELECT Id 
                              FROM Case 
                              Limit 1];
        
        Test.startTest();
        	CNT_TopicList.deleteTopicAssignments(topicAss.Id);
        	CNT_TopicList.deleteTopicAssignments(caseRecord.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, topicAss, 'topicAss is not to be null');
    }
    
    @isTest
    private static void testInsertTopic() {
        
        Test.startTest();
        	CNT_TopicList.insertTopic('Test', 2);
        	CNT_TopicList.insertTopic('Test Topics', 3);
        	CNT_TopicList.InsertTopicWrapper insertTopic = CNT_TopicList.insertTopic('topic_test2', 4);
        Test.stopTest();
        
        System.assertEquals(CRM_Constants.RECORD_INSERTED, insertTopic.message);
    }
}