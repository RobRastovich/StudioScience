@isTest
private class TST_SLT_Consumer_Response {
    @isTest
    private static void testGetConsumerResponseRecord() {
        Case newcase = TST_TestDataFactory.createCase(CRM_Constants.QUALITY_CLAIM_RT_ID,false);
        newcase.Brand__c = 'Larios';
        newcase.How_can_we_help__c = 'Other Inquiry';
        newCase.AdditionalInformation__c = 'Other';
        
        Consumer_Response__c testRecordConsumerResponse = new Consumer_Response__c();
        testRecordConsumerResponse.Brand__c =  newcase.Brand__c; 
        testRecordConsumerResponse.Additional_Information__c = newCase.AdditionalInformation__c;
        testRecordConsumerResponse.AutoResponse_Acknowledgement__c = 'AutoResponse';
        testRecordConsumerResponse.How_can_we_help_you__c = newcase.How_can_we_help__c;
        testRecordConsumerResponse.Email_Content__c = 'How are you {description}';
        testRecordConsumerResponse.RoutingQueue__c = null;
        testRecordConsumerResponse.Trigger_Word__c = true;
        insert testRecordConsumerResponse;
        
        Test.startTest();
            testRecordConsumerResponse = SLT_Consumer_Response.getConsumerResponseRecord(newcase);
        Test.stopTest();
        
        System.assertEquals(testRecordConsumerResponse!=null, newcase!=null, 'Records should not be null');    
    }
    
    @isTest
    private static void testGetConsumerResponseRecordForElse() {
        Case newcase = TST_TestDataFactory.createCase(CRM_Constants.QUALITY_CLAIM_RT_ID,false);
        newcase.Brand__c = 'Larios';
        newcase.trigger_word__c = True;
        
        Consumer_Response__c testRecordConsumerResponse = new Consumer_Response__c();
        testRecordConsumerResponse.Brand__c =  newcase.Brand__c; 
        testRecordConsumerResponse.Additional_Information__c = 'Other';
        testRecordConsumerResponse.AutoResponse_Acknowledgement__c = 'Acknowledgement';
        testRecordConsumerResponse.How_can_we_help_you__c = 'Other Inquiry';
        testRecordConsumerResponse.Email_Content__c = 'How are you {description}';
        testRecordConsumerResponse.Trigger_Word__c = true;
        testRecordConsumerResponse.RoutingQueue__c = '';
        testRecordConsumerResponse.Country__c = 'Germany';
        insert testRecordConsumerResponse;
        
        Test.startTest();
            testRecordConsumerResponse = SLT_Consumer_Response.getConsumerResponseRecord(newcase);
        Test.stopTest();
        
        System.assertEquals(testRecordConsumerResponse!=null, newcase!=null, 'Records should not be null');    
    }
    @isTest
    private static void testGetConsumerResponseRecordWhenParentIdNotNull() {
        Case parentNewCase = TST_TestDataFactory.createCase(CRM_Constants.CONSUMER_INQUIRY_RT_ID,false);
        parentNewCase.Brand__c = 'Sipsmith';
        parentNewCase.How_can_we_help__c = 'Other Inquiry';
        parentNewCase.AdditionalInformation__c = 'Other';
        parentNewCase.Consumer_Country__c = 'Germany';
        parentNewCase.Description = 'Test11111';
        insert parentNewCase;
        
        Case newcase = TST_TestDataFactory.createCase(CRM_Constants.CONSUMER_INQUIRY_RT_ID,false);
        newcase.Brand__c = 'Sipsmith';
        newcase.ParentId = parentNewCase.Id;
        
        Consumer_Response__c testRecordConsumerResponse = new Consumer_Response__c();
        testRecordConsumerResponse.Brand__c =  'Sipsmith'; 
        testRecordConsumerResponse.Additional_Information__c = null;
        testRecordConsumerResponse.AutoResponse_Acknowledgement__c = 'Acknowledgement';
        testRecordConsumerResponse.How_can_we_help_you__c = null;
        testRecordConsumerResponse.Email_Content__c = 'How are you {description}';
        testRecordConsumerResponse.RoutingQueue__c = 'Sipsmith';
        testRecordConsumerResponse.Trigger_Word__c = false;
        insert testRecordConsumerResponse;
        
        Test.startTest();
            Consumer_Response__c returnConsumerResponse = SLT_Consumer_Response.getConsumerResponseRecord(newcase);
        Test.stopTest();
        
        System.assert(returnConsumerResponse.Brand__c == 'Sipsmith', 'Brand should be same.');
    }
}