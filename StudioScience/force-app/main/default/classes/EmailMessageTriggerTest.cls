/**************************************************************************************
Apex Class Name     : EmailMessageTriggerTest
Created Date        : 20-11-2021
Function            : Test class of EmailMessage trigger.
*************************************************************************************/
@isTest
public class EmailMessageTriggerTest {

    @testSetup
    static void setUpTestData() {    
        Case newCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        newCase.Status = 'In Progress';
        newCase.Status = 'Confirmation email sent';
        insert newCase;
    }

    @isTest
    static void testEmailMessageTrigger() {
        EmailMessage em=new EmailMessage();
        insert em;
    }
    
    @isTest
    static void testEmailMessageTriggerInsert() {
        Case createdCase = [SELECT Id FROM CASE LIMIT 1];
        Test.startTest();
            EmailMessage emailMsg = new EmailMessage();
            emailMsg.ParentId = createdCase.Id;
            emailMsg.Subject = 'test';
            insert emailMsg;
        Test.stopTest();
        List<EmailMessage> lstMails = [Select Id from EmailMessage];
        System.assertEquals(true, lstMails.size() > 0, 'Record inserted successfully');
    }
}