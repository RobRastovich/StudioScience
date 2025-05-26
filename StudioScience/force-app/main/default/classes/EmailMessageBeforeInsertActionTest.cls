@isTest(SeeAllData = false)
public class EmailMessageBeforeInsertActionTest {    
    @isTest static void emailMessageBeforeInsert() {     
        
        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case';
        c.origin = 'Email';
        c.RecordTypeId = CSConstants.DAL_US_RT_ID;
        c.Submitter__c = UserInfo.getUserId();
        insert c;
        
        EmailMessage em = new EmailMessage(FromAddress = 'dal@test.com', Incoming = true, ToAddress = 'cs@test.com', CcAddress = 'dal_us@test.com', Subject = 'Test email', TextBody = 'Test body', ParentId = c.Id);
        insert em;
        
        Test.startTest();  
        EmailMessageBeforeInsertAction.updatingCcAddressOnCase(new List<Id> {em.Id});
        Test.stopTest();               
    }
    
}