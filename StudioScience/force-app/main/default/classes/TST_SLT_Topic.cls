@isTest
private class TST_SLT_Topic {
    @testSetup
    static void dataSetup() {
        Topic topic = new Topic(Name='Test Topics');
        insert topic;
    }
    
    @isTest
    private static void testGetTopicList() {
        set<String> topicList = new set<String>();
        topicList.add('Test Topics');
                
        Test.startTest();
        	List<Topic> topics = SLT_Topic.getTopicList(topicList);
        Test.stopTest();
        
        System.assertEquals(true, topics.size()>0 ,'It should return Topics');
    }
    
    @isTest
    private static void testCheckTopicExistinSystem() {
        
        Test.startTest();
        	List<Topic> topicList = SLT_Topic.checkTopicExistinSystem('Test Topics');
        Test.stopTest();
        
        System.assertEquals(true, topicList.size()>0 ,'It should return Topics');
    }
}