@IsTest()
public class BEST_UserApprovalControllerTest {
    
    @IsTest
    static void updateContactonApprovalTest() {
        Account acc = new Account();
        acc.Name = 'Demo';
        insert acc;
        
        Contact testContact = new Contact();
        testContact.AccountId = acc.Id;
        testContact.lastName = 'test';
        testContact.User_Approval_Status__c = 'Pending Review';
        insert testContact;
        
        Test.startTest();        
            String res = BEST_UserApprovalController.updateContactOnApproval(testContact.Id);                     
        Test.stopTest();
        
        Contact trialContact = [Select Id, User_Approval_Status__c from Contact where Id =: testContact.Id];
        System.assertEquals('Approved', trialContact.User_Approval_Status__c);
    }
    
    @IsTest
    static void updateContactReasonOnRejectionTest() {
        Account acc = new Account();
        acc.Name = 'Demo';
        insert acc;
        
        Id PortalRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Portal_User').getRecordTypeId();
        Contact testContact = new Contact();
        testContact.AccountId = acc.Id;
        testContact.lastName = 'test';
        testContact.User_Approval_Status__c = 'Pending Review';
        testContact.recordTypeId = PortalRecordTypeId;
        testContact.email = 'test@test.in';
        insert testContact; 
        
        Test.startTest();
            BEST_UserApprovalController.updateContactReasonOnRejection(testContact.Id, 'Bad reason');
        Test.stopTest();
        
        Contact trialContact = [Select User_Approval_Status__c from Contact where Id =: testContact.Id];
        System.assertEquals('Rejected', trialContact.User_Approval_Status__c);
    }
    
    @IsTest
    static void getContactDetailsTest() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact testContact = new Contact();
        testContact.AccountId = acc.Id;
        testContact.lastName = 'test';
        testContact.Email = 'test@test.in';
        testContact.User_Approval_Status__c = 'Pending Review';
        testContact.Territory__c = 'Alaska';
        testContact.Rejection_Reason__c = 'bad reason';
        insert testContact; 
        
        Test.startTest();
            Contact resultContact = BEST_UserApprovalController.getContactDetails(testContact.Id);
        Test.stopTest();
        
        System.assertEquals(true, resultContact != null);
    }

}