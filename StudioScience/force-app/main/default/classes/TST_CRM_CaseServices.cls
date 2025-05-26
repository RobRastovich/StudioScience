@isTest
public class TST_CRM_CaseServices {
    
    @testSetup
    static void setupMethod(){
        List<Case> caseList = new List<Case>();
        Case newCase1 = TST_TestDataFactory.createCase(CRM_Constants.CONSUMER_INQUIRY_RT_ID, false);
        Contact newContact = TST_TestDataFactory.createContact(null, true);
        newCase1.ContactId = newContact.Id;
        newCase1.How_can_we_help__c = 'Other Inquiry';
        newcase1.AdditionalInformation__c = 'Other';
        newCase1.Description = CRM_Constants.AGENT_CLOSED;
        newCase1.SuppliedEmail =  'test@crm.com';
        newCase1.Submitter__c =  UserInfo.getUserId();
        insert newCase1;
        Case newCase2 = TST_TestDataFactory.createCase(CRM_Constants.CONSUMER_INQUIRY_RT_ID, false);
        newCase2.ContactId = newContact.Id;
        newCase2.First_name__c = 'Test CRM ONE';
        newCase2.How_can_we_help__c = 'Other Inquiry';
        newCase2.AdditionalInformation__c = 'Other';
        insert newCase2;
    }
    
    @isTest
    public static void testMandatoryFieldNotBlank() {
        List<Case> testCase = [SELECT Id , Status
                         FROM Case  
                         LIMIT 2];
        try{	
            testCase[0].Status = CRM_Constants.CASE_STATUS_CLOSED;
            testCase[0].Product_Type__c = '';
            testCase[1].status = CRM_Constants.CASE_STATUS_RESOLVED;
            testCase[1].Brand__c = '';
            Test.startTest();
            	update testCase;
            Test.stopTest();
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown = false;
            if(e.getMessage().contains(CRM_Constants.Product_cannot_be_blank) 
                || e.getMessage().contains(CRM_Constants.Brand_cannot_be_blank)){
                expectedExceptionThrown = true;
            }
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    
    @isTest
    public static void testUpdateDateTimeAssignedOnCase() {
        Case testCase = [SELECT Id , Status, Date_Time_Assigned__c
                            FROM Case  
                            LIMIT 1];
        testCase.Status = CRM_Constants.CASE_STATUS_ASSIGNED;
        
        Test.startTest();
        	update testCase;
        Test.stopTest();
        Case testCaseAfterUpdate = [SELECT Id , Status, Date_Time_Assigned__c
                                       FROM Case  
                                       WHERE ID =: testCase.ID];
        System.assertNotEquals(null, testCaseAfterUpdate.Date_Time_Assigned__c, 'Date Time Assigned Should Not be blank');   
    }
    
    @isTest
    public static void testUpdateCaseClosedFieldsOnStatusChanged() {
        Case testCase = [SELECT Id , Status, Date_Time_Assigned__c, Actual_Closed_Date__c
                            FROM Case  
                            LIMIT 1];
        testCase.Actual_Closed_Date__c = DateTime.newInstance(2023, 11, 24, 15, 0, 0);
        testCase.Date_Time_Assigned__c = DateTime.newInstance(2023, 12, 4, 12, 0, 0);
        testCase.Status = CRM_Constants.CASE_STATUS_CLOSED;
        Case testCaseWhenDateAssignedIsNull = [SELECT Id , Status, Date_Time_Assigned__c, Actual_Closed_Date__c, Description
                                                  FROM Case  
                                                  WHERE First_name__c = 'Test CRM ONE'];
        testCaseWhenDateAssignedIsNull.Actual_Closed_Date__c = DateTime.newInstance(2023, 11, 24, 15, 0, 0);
        testCaseWhenDateAssignedIsNull.Status = CRM_Constants.CASE_STATUS_CLOSED;
        
        Test.startTest();
        	update testCase;
            update testCaseWhenDateAssignedIsNull; 
        Test.stopTest();
        Case testCaseAfterUpdate = [SELECT Id , Status, Business_Hours_To_Resolve__c
                                       FROM Case  
                                       WHERE ID =: testCase.ID];
        System.assertNotEquals(null, testCaseAfterUpdate.Business_Hours_To_Resolve__c, 'Business Hours Should Not be blank');   
    }
}