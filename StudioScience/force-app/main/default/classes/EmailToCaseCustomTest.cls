@isTest
public with sharing class EmailToCaseCustomTest {
       
    static testMethod void EmailToCaseCustomTest() {

        // Create a new email and envelope object.
        string emailAddress = 'user@test.com';
        Messaging.InboundEmail emailMessage = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        emailMessage.subject = 'test test';
        emailMessage.FromAddress = emailAddress;
        emailMessage.plainTextBody  = 'Email Address: user@test.com  \n Name: Test Test';  
         
        // Call the class and test it with the data in the testMethod.
        EmailToCaseCustom  emlObj = new EmailToCaseCustom();
        emlObj.handleInboundEmail(emailMessage, env );

        // test that account from email created
        list <Account> aCC = [select id from account where PersonEmail  =: emailAddress];
        system.assert(aCC.size()==1);

        //test that case is created for this account
        list <Case> c = [select id from case where AccountID  =: acc[0].id];
        system.assert(c.size()==1);
    }
}