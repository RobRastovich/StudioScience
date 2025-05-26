@isTest
private class TST_CRM_SLT_Case {
    @testSetup
    static void dataSetup() {
        List<Case> caseList = new List<Case>();
        Account acc = TST_TestDataFactory.createAccount(null, true);
        
        Case lariosTestCase = TST_TestDataFactory.createCase(CRM_Constants.QUALITY_CLAIM_RT_ID, false);
        lariosTestCase.AccountId = acc.Id;
        lariosTestCase.Brand__c = CRM_Constants.LARIOS_BRAND;
	    lariosTestCase.How_can_we_help__c = '';
        lariosTestCase.AdditionalInformation__c = '';
        caseList.add(lariosTestCase);
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
        if(caseList.size() > 0 && !caseList.isEmpty()){
            insert caseList;
        }
    }
    
    /**
    *  @description : This method is use to cover this method getCasesOwnerName(CRM).
    **/
    @isTest
    private static void testGetCasesOwnerName() {
        Case testCase = [SELECT Id 
                            FROM Case 
                            WHERE Brand__c =: CRM_Constants.LARIOS_BRAND
                            LIMIT 1];
                       
        Test.StartTest();
        	Case recordCase = CRM_SLT_Case.getCasesOwnerName(testCase.Id,new Set<String>{'Brand__c', 'Status'});
        Test.StopTest();
		
        System.assertEquals(false, recordCase == null, CRM_Constants.CASE_ASSERT_MESSAGE);
    }
    
    @isTest 
    private static void testGetQClaimAndCInquiryRecorTypeCases() {
        Date startDate, endDate;
        endDate = Date.today().addDays(1);
        startDate = Date.today().addDays(-3);
        List<String> recordTypeList = new List<String>{'Quality Claim'};
        
        Test.startTest();
        	List<Case> caseList = CRM_SLT_Case.getQClaimAndCInquiryRecorTypeCases(startDate, endDate, recordTypeList);
        Test.stopTest();
        
        System.assertEquals(true, caseList.size()>0, 'Caselist not be empty');
    }
}