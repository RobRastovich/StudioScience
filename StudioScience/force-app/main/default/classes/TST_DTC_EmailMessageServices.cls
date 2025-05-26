@isTest
public class TST_DTC_EmailMessageServices {
    @testSetup
    static void setUpTestData() {    
        Case newCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        newCase.Status = 'Closed';
        insert newCase;
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test123456@abc.org';
        email.Incoming = True;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = newCase.Id;
        insert email;
    }
    
    @isTest
    private static void testCheckStatusFlowOfCaseStatusDTC() {
        // Case newCase = [SELECT Id, Status 
                         //   FROM Case];
        EmailMessage email = [SELECT Id, FromAddress, Incoming, ToAddress, Subject, HtmlBody, ParentId 
                                 FROM EmailMessage
                                 WHERE Subject = 'Test email'
                                 LIMIT 1];
        List<EmailMessage> newList = new List<EmailMessage>{email};
            Map<Id, EmailMessage> oldMap = new Map<Id, EmailMessage>();
        oldMap.put(email.Id,email);
        
        Test.startTest();
        DTC_EmailMessageServices.updateCaseStatusToReopenWhenReply(newList, oldMap);
        Test.stopTest();
        Case newCase1 = [SELECT Id, Status 
                            FROM Case];
        System.assertEquals('Reopen', newCase1.Status, 'The status is not Reopen.');
    }
}