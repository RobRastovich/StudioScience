@isTest
private class TST_TopicReport {
	@testSetup static void setup() {
        Topic topic = new Topic(Name='Test Topics');
        insert topic;
        RecordType record_type = [SELECT Id,Name FROM RecordType WHERE sObjectType='Case' AND name='Quality Claim' LIMIT 1];
        Case caseRecord = TST_TestDataFactory.createCase(record_type.Id, false);
        caseRecord.How_can_we_help__c = 'Where To Buy Product';
        caseRecord.AdditionalInformation__c = '';
        insert caseRecord;
        TopicAssignment topicAss = new TopicAssignment();
        topicAss.TopicId = topic.Id;
        topicAss.EntityId = caseRecord.Id;
        insert topicAss;
    }
    
    @isTest
    private static void testTopicRecport() {
        Date startDate, endDate;
        endDate = Date.today().addDays(1);
        startDate = Date.today().addDays(-3);
        List<String> recordTypeList = new List<String>{'Quality Claim'};
            
        Test.startTest();
        	Map<String,List<Case>> mapCaseList = TopicReport.mapTopicAssignments(String.valueOf(startDate), String.valueOf(endDate), recordTypeList);
        Test.stopTest();
        
        System.assertEquals(true, mapCaseList.containskey('Test Topics'), 'mapCaseList shuold contains key Test Topics');
    }
}