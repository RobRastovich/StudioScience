@isTest
public class SBP_SMApplicationCmpCtrlTest {
    
    @testSetup static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User demoUser = new User(Alias = 'alias', Email = 'test@test.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
                                 EmailEncodingKey = 'UTF-8', LastName = 'demoUser', LanguageLocaleKey = 'en_US',
                                 LocaleSidKey = 'en_US', ProfileId = p.Id,
                                 TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestusersmacct@test-user-system.com.test-only',User_Type__c = 'Diplomat', Represented_States__c = 'Alaska');
        insert demoUser;
        Plant_Event__c p2 = (new Plant_event__c(Scheduled_Date__c = System.Today().addDays(49)));
        p2.ownerId = demoUser.id;
        p2.Time_of_day__c = 'PM';
        p2.Brand__C = 'Makers Mark';
        insert p2;
        
        Application_Question_Set__c makersMarkQuestionSet = new Application_Question_Set__c();
        makersMarkQuestionSet.Brand__c = 'Makers Mark';
        makersMarkQuestionSet.Name = 'Maker\'s Mark Domestic';
        insert makersMarkQuestionSet;
        
        // create application questions
        Application_Question__c q1 = new Application_Question__c(Question__c = 'Is the account a P/G/S account overall?', Type__c = 'Radio', Application_Question_Set__c = makersMarkQuestionSet.Id);
        
        Application_Question__c q3 = new Application_Question__c(Question__c = 'Is the account EDGE?', Type__c = 'Radio', Application_Question_Set__c = makersMarkQuestionSet.Id);
        
        Application_Question__c q5 = new Application_Question__c(Question__c = 'Is the account a premium or luxury account?', Type__c = 'Radio', Application_Question_Set__c = makersMarkQuestionSet.Id);
        
        insert new List<Application_Question__c> {q1, q3, q5};
            // create answers for each question
        Application_Answer__c q1a1 = new Application_Answer__c(Answer__c = 'Yes', Application_Question__c = q1.Id);
        Application_Answer__c q1a2 = new Application_Answer__c(Answer__c = 'No', Application_Question__c = q1.Id);
        
        Application_Answer__c q3a1 = new Application_Answer__c(Answer__c = 'Yes', Application_Question__c = q3.Id);
        Application_Answer__c q3a2 = new Application_Answer__c(Answer__c = 'No', Application_Question__c = q3.Id);
        
        Application_Answer__c q5a1 = new Application_Answer__c(Answer__c = 'Yes', Application_Question__c = q5.Id);
        Application_Answer__c q5a2 = new Application_Answer__c(Answer__c = 'No', Application_Question__c = q5.Id);
        
        
        insert new List<Application_Answer__c> {q1a1, q1a2, q3a1, q3a2, q5a1, q5a2};
            
            
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.BillingState = 'IL';
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();
        insert testAccount;
        
        Account_Application__c makersApplication = new Account_Application__c();
        makersApplication.Brand__c = 'Makers Mark';
        makersApplication.Status__c = 'New';
        makersApplication.State__c = 'Alaska';
        makersApplication.Application_Question_Set__c = makersMarkQuestionSet.Id;
        makersApplication.Account__c = testAccount.Id;
        insert makersApplication;
        
        Case c = new Case();
        c.Retail_Account__c = testAccount.Id;
        c.Status = 'Closed';
        insert c;
        
    }
    
    public static testMethod void getSMCaseTest() {
        User u =[Select id from User where user_type__c = 'Diplomat' limit 1];
        test.startTest();
        System.runAs(u){
            List<Case> c = SBP_SMApplicationCmpCtrl.getSMCase();
            test.stopTest();
            System.assert(c != null);
        }        
    }
    
    public static testMethod void getSMApplicationTest() {
        User u =[Select id from User where user_type__c = 'Diplomat' limit 1];
        test.startTest();
        System.runAs(u){
            List<Account_Application__c> app = SBP_SMApplicationCmpCtrl.getSMApplication();
            test.stopTest();
            System.assert(app != null);
        }        
    }
    
    public static testMethod void fetchPortalLinkTest() {
        test.startTest();
        String s = SBP_SMApplicationCmpCtrl.fetchPortalLink();
        test.stopTest();
        System.assert(s != null);        
    }
    
}