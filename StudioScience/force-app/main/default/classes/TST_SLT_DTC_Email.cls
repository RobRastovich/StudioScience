@isTest
public class TST_SLT_DTC_Email {
	
    @testSetup
    static void setUpTestData() { 
        List<Case> insertCases = new List<Case>();
        Case newCase1 = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        newCase1.Status = 'In Progress';
        newCase1.OrderID__c = 'testO1234';
        newCase1.Sub_Status__c = 'Confirmation email sent';
        insert newCase1;
        EmailMessage emailMessage = new EmailMessage();
        emailMessage.FromAddress = 'test987@gmail.com';
        emailMessage.ParentId = newCase1.Id;
        insert emailMessage;
    }
    
    @isTest
    public static void testGetEmailList(){
        List<EmailMessage> emailMessageList= [SELECT Id, FromAddress, ParentId FROM EmailMessage];
        List<Case> caseList= [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
            List<EmailMessage> expectedEmailList= SLT_DTC_Email.getEmailList(caseList);
        Test.stopTest();
        System.debug('expected size is '+expectedEmailList.size());
        System.assertEquals(expectedEmailList.size(), 1, 'list size is not 1'); 
    }
}