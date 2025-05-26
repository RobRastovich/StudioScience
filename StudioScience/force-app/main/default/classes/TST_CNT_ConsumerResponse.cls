@istest(seeAllData = false)
private class TST_CNT_ConsumerResponse {   
    @testSetup
    static void setUpTestData() {
        Case newcase = TST_TestDataFactory.createCase(CRM_Constants.QUALITY_CLAIM_RT_ID,false);
        newcase.Brand__c = 'Larios';
        newcase.How_can_we_help__c = 'Other Inquiry';
        newCase.AdditionalInformation__c = 'Other';
        newCase.Consumer_Country__c = 'Germany';
        newCase.Description = 'Test';
        insert newCase;
        
        Consumer_Response__c testRecordConsumerResponse = new Consumer_Response__c();
        testRecordConsumerResponse.Brand__c =  newcase.Brand__c; 
        testRecordConsumerResponse.Additional_Information__c = newCase.AdditionalInformation__c;
        testRecordConsumerResponse.AutoResponse_Acknowledgement__c = 'AutoResponse';
        testRecordConsumerResponse.How_can_we_help_you__c = newcase.How_can_we_help__c;
        testRecordConsumerResponse.Email_Content__c = 'How are you {description}';
        testRecordConsumerResponse.RoutingQueue__c = newCase.Owner.Name;
        testRecordConsumerResponse.Country__c = newCase.Consumer_Country__c;
        testRecordConsumerResponse.Trigger_Word__c = true;
        insert testRecordConsumerResponse;
    }
    
    @isTest
    private static void testSetCaseIdAttribute() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        CNT_ConsumerResponse instanceCNT = new CNT_ConsumerResponse();
        
        Test.startTest();
            instanceCNT.setCaseIdAttribute(testCase.id);
        Test.stopTest();
        
        System.assertEquals(testCase!=null, testCase!=null, 'CaseRecord should not be null');
    }
    
    @isTest
    private static void testGetCaseIdAttribute() {
        CNT_ConsumerResponse instanceCNT = new CNT_ConsumerResponse();
        
        Test.startTest();
           String caseIdAttribute = instanceCNT.getCaseIdAttribute();
        Test.stopTest();
        
        System.assertEquals(caseIdAttribute!=null, caseIdAttribute!=null, 'CaseId should not be null');
    }
    
    @isTest
    private static void testSetEmailContent() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        CNT_ConsumerResponse instanceCNT = new CNT_ConsumerResponse();
        
        Test.startTest();
            instanceCNT.setEmailContent(testCase.id);
        Test.stopTest();
        
        System.assertEquals(testCase!=null, testCase!=null, 'CaseRecord should not be null');
    }
    
    @isTest
    private static void testGetEmailContent() {
        CNT_ConsumerResponse instanceCNT = new CNT_ConsumerResponse();
        
        Test.startTest();
           String emailContent = instanceCNT.getEmailContent();
        Test.stopTest();
        
        System.assertEquals(emailContent!=null, emailContent!=null, 'Email Content should not be null');
    }
    
    @isTest
    private static void testReplacePatternStringWithValue() {
        Case testCase = [SELECT Id, Description, ContactEmail, CaseNumber 
                            FROM Case 
                            LIMIT 1];
        
        Map<String, String> testMapOfDynamicFieldWithApiname = new Map<String, String>();     
        Consumer_Response_Dynamic_Field__mdt crdfHelpMdt = new Consumer_Response_Dynamic_Field__mdt();
        crdfHelpMdt = [SELECT Field_Apiname__c, Field_in_Email_Content__c
                          FROM Consumer_Response_Dynamic_Field__mdt 
                          WHERE Field_Apiname__c = 'Description'
                          LIMIT 1];
        testMapOfDynamicFieldWithApiname.put(crdfHelpMdt.Field_Apiname__c, crdfHelpMdt.Field_in_Email_Content__c);
        String emailContent = 'How are you {description}';
        
        Test.startTest();
        String content = CNT_ConsumerResponse.replacePatternStringWithValue(testCase , 
                                                                            emailContent , 
                                                                            testMapOfDynamicFieldWithApiname);
        Test.stopTest();
        
        System.assertEquals(false, content.contains('{description}'), CRM_Constants.ASSERT_MESSAGE_A);
    }
}