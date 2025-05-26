@isTest
private class TST_SLT_TopicAssignments {
    
	@testSetup
    static void dataSetup() {
        
        Topic topic = new Topic(Name='Test Topics');
        insert topic;
        Case mcase = new Case();
        insert mcase;
        TopicAssignment topicAssignment = new TopicAssignment(EntityId = mcase.Id, TopicId = topic.Id);
        insert topicAssignment;   
    }
    
    @isTest
    private static void testFetchTopicAssignments() {
        Case mcase = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        	List<TopicAssignment> topicsAssignmentsList = SLT_TopicAssignments.fetchTopicAssignments(mcase.Id);
        Test.stopTest();
        
        System.assertEquals(true, topicsAssignmentsList.size() > 0, 'It should return topicsAssignments');
    }
}