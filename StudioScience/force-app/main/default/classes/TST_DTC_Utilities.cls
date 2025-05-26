@isTest
public class TST_DTC_Utilities {

    @testSetup
    static void dataSetup() {
        Case caseDetail = TST_TestDataFactory.createCase(null, true);
        DTC_Settings__c settings = TST_TestDataFactory.createDTCSettings(true);
    }

    @isTest
    private static void testAddBusinessDays() {
        Case caseDetail = [SELECT id, CreatedDate 
                            FROM Case][0];
        Test.startTest();
            Date created = DTC_Utilities.AddBusinessDays(Date.valueOf(caseDetail.CreatedDate), 3);
        Test.stopTest();

        System.assertNotEquals(null, created , 'Returned date cannot be null.');
    }

    @isTest
    private static void testSendEmailShouldProcessMails() {
        List<String> toAddresses = DTC_Utilities.fetchGBSEmails();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate template = [SELECT Id, Name, Body, HtmlValue, Subject 
                                    FROM EmailTemplate 
                                    WHERE Name =: DTC_Constants.DTC_ET_DISPUTEVALID LIMIT 1];        

        Test.startTest();
            Messaging.SingleEmailMessage mail = DTC_Utilities.createSingleEmailMessage(template.Name, 
                DTC_Constants.DTC_EMAIL_BEAMSUNTORY, toAddresses, null); 
                mails.add(mail);
                DTC_Utilities.sendEmail(mails);
        Test.stopTest();
        
        System.assertEquals(false, (mail == null), 'Email record is not processed for send when expected');
    }

    @isTest
    private static void testCreateSingleEmailMessageShouldReturnSingleEmailMessage() {
        List<String> toAddresses = DTC_Utilities.fetchGBSEmails();
        EmailTemplate template = [SELECT Id, Name, Body, HtmlValue, Subject 
                                    FROM EmailTemplate 
                                    WHERE Name =: DTC_Constants.DTC_ET_DISPUTEVALID LIMIT 1]; 

        Test.startTest();
            Messaging.SingleEmailMessage mail = DTC_Utilities.createSingleEmailMessage(template.Name, 
                DTC_Constants.DTC_EMAIL_BEAMSUNTORY, toAddresses, null); 
        Test.stopTest();

        System.assertNotEquals(null, mail, 'SingleEmailMessage should not be null');
    }

    @isTest
    private static void testFetchGBSEmails() {
        List<String> emailsList = new List<String>();
    
        Test.startTest();
            emailsList = DTC_Utilities.fetchGBSEmails(); 
        Test.stopTest();

        System.assertNotEquals(null, emailsList, 'Email list should not be null');
    }
}