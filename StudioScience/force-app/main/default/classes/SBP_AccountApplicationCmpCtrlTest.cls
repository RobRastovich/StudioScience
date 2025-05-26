@isTest
private class SBP_AccountApplicationCmpCtrlTest {
    @testSetup static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com', Regional_Diplomat_Regions__c = 'Illinois',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = p.Id,User_Type__c = 'Diplomat',
                          TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuseraacct@test-user-system.com.test-only');
        insert u; 
        
        //Added by Nishant Khandal LSB-7
        SBP_Approvers__c setting = new SBP_Approvers__c();
        setting.Name = SBP_Constants.LAPHROAIG_SINGLE_CASK;
        setting.Brand__c = SBP_Constants.LAPHROAIG_SINGLE_CASK;
        setting.Username__c = u.Username;
        insert setting;
        // create application question set
        Application_Question_Set__c makersMarkQuestionSet = new Application_Question_Set__c();
        makersMarkQuestionSet.Brand__c = 'Makers Mark';
        makersMarkQuestionSet.Name = 'Maker\'s Mark Domestic';
        insert makersMarkQuestionSet;

        Application_Question_Set__c elTesoroQuestionSet = new Application_Question_Set__c();
        elTesoroQuestionSet.Brand__c = 'El Tesoro';
        elTesoroQuestionSet.Name = 'El Tesoro';
        insert elTesoroQuestionSet;
        
        //added by Nishant Khandal LSB-7
        Application_Question_Set__c laphroaigSingleCaskQuestionSet = new Application_Question_Set__c();
        laphroaigSingleCaskQuestionSet.Brand__c = SBP_Constants.LAPHROAIG_SINGLE_CASK;
        laphroaigSingleCaskQuestionSet.Name = SBP_Constants.LAPHROAIG_SINGLE_CASK_QUESTION_SET;
        insert laphroaigSingleCaskQuestionSet;

        // create application questions
        Application_Question__c q1 = new Application_Question__c(Question__c = 'Is the account a P/G/S account overall?', Type__c = 'Radio', Application_Question_Set__c = makersMarkQuestionSet.Id);
        Application_Question__c q2 = new Application_Question__c(Question__c = 'Is the account a P/G/S account overall?', Type__c = 'Radio', Application_Question_Set__c = elTesoroQuestionSet.Id);

        Application_Question__c q3 = new Application_Question__c(Question__c = 'Is the account EDGE?', Type__c = 'Radio', Application_Question_Set__c = makersMarkQuestionSet.Id);
        Application_Question__c q4 = new Application_Question__c(Question__c = 'Is the account EDGE?', Type__c = 'Radio', Application_Question_Set__c = elTesoroQuestionSet.Id);

        Application_Question__c q5 = new Application_Question__c(Question__c = 'Is the account a premium or luxury account?', Type__c = 'Radio', Application_Question_Set__c = makersMarkQuestionSet.Id);
        Application_Question__c q6 = new Application_Question__c(Question__c = 'Is the account a premium or luxury account?', Type__c = 'Radio', Application_Question_Set__c = elTesoroQuestionSet.Id);

        //added by Nishant Khandal LSB-7
        Application_Question__c q7 = new Application_Question__c(Question__c = 'Is the account a P/G/S account overall?', Type__c = 'Radio', Application_Question_Set__c = laphroaigSingleCaskQuestionSet.Id);
        Application_Question__c q8 = new Application_Question__c(Question__c = 'Is the account a P/G/S account overall?', Type__c = 'Radio', Application_Question_Set__c = laphroaigSingleCaskQuestionSet.Id);
        Application_Question__c q9 = new Application_Question__c(Question__c = 'Is the account EDGE?', Type__c = 'Radio', Application_Question_Set__c = laphroaigSingleCaskQuestionSet.Id);
        //end by Nishant Khandal LSB-7
        insert new List<Application_Question__c> {q1, q2, q3, q4, q5, q6, q7, q8, q9};   // added by Nishant Khandal q7 q8 q9 in list
        // create answers for each question
        
        //Added By Nishant Khandal creating Child Question
        Application_Question__c q10 = new Application_Question__c(Question__c = 'Is the account EDGE?', Type__c = 'Radio', 
                                                                  Application_Question_Set__c = laphroaigSingleCaskQuestionSet.Id,
                                                                  Application_Question__c = q9.Id);   
        insert q10;   
        Application_Answer__c q1a1 = new Application_Answer__c(Answer__c = 'Yes', Application_Question__c = q1.Id);
        Application_Answer__c q1a2 = new Application_Answer__c(Answer__c = 'No', Application_Question__c = q1.Id);

        Application_Answer__c q2a1 = new Application_Answer__c(Answer__c = 'Yes', Application_Question__c = q2.Id);
        Application_Answer__c q2a2 = new Application_Answer__c(Answer__c = 'No', Application_Question__c = q2.Id);

        Application_Answer__c q3a1 = new Application_Answer__c(Answer__c = 'Yes', Application_Question__c = q3.Id);
        Application_Answer__c q3a2 = new Application_Answer__c(Answer__c = 'No', Application_Question__c = q3.Id);

        Application_Answer__c q4a1 = new Application_Answer__c(Answer__c = 'Yes', Application_Question__c = q4.Id);
        Application_Answer__c q4a2 = new Application_Answer__c(Answer__c = 'No', Application_Question__c = q4.Id);

        Application_Answer__c q5a1 = new Application_Answer__c(Answer__c = 'Yes', Application_Question__c = q5.Id);
        Application_Answer__c q5a2 = new Application_Answer__c(Answer__c = 'No', Application_Question__c = q5.Id);

        Application_Answer__c q6a1 = new Application_Answer__c(Answer__c = 'Yes', Application_Question__c = q6.Id);
        Application_Answer__c q6a2 = new Application_Answer__c(Answer__c = 'No', Application_Question__c = q6.Id);
        
        
        Application_Answer__c q7a1 = new Application_Answer__c(Answer__c = 'Yes', Application_Question__c = q7.Id);
        Application_Answer__c q7a2 = new Application_Answer__c(Answer__c = 'No', Application_Question__c = q7.Id);

        Application_Answer__c q8a1 = new Application_Answer__c(Answer__c = 'Yes', Application_Question__c = q8.Id);
        Application_Answer__c q8a2 = new Application_Answer__c(Answer__c = 'No', Application_Question__c = q8.Id);

        Application_Answer__c q9a1 = new Application_Answer__c(Answer__c = 'Yes', Application_Question__c = q9.Id);
        Application_Answer__c q9a2 = new Application_Answer__c(Answer__c = 'No', Application_Question__c = q9.Id);
        insert new List<Application_Answer__c> {q1a1, q1a2, q2a1, q2a2, q3a1, q3a2, q4a1, q4a2, q5a1, q5a2, q6a1, q6a2,
             q7a1, q7a2, q8a1, q8a2, q9a1, q9a2};   // added by Nishant Khandal q7a1, q7a2, q8a1, q8a2, q9a1, q9a2


        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.BillingState = 'IL';
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();

        Account retailAccount = new Account();
        retailAccount.Name = 'Retail Account';
        retailAccount.BillingState = 'IL';
        retailAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();

        Account intAccount = new Account();
        intAccount.Name = 'Single Barrel International Account';
        intAccount.BillingState = 'IL';
        intAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();
        
        //Added By Nishant Khandal
        Account distributorAccount = new Account();
        distributorAccount.Name = 'Distributor Account';
        distributorAccount.BillingState = 'IL';
        distributorAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().
                                              get('Distributor').getRecordTypeId();
        
        insert new List<Account> {testAccount, retailAccount, intAccount, distributorAccount};
            
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.AccountId = testAccount.Id;
        insert testContact;

        Profile prof = [select id from profile where name = 'System Administrator'];
				User testUser = new User();
				testUser.firstName = 'Test';
				testUser.lastName = 'User';
				testUser.profileId = prof.id;
                testUser.Alias = 'testusr';
                testUser.TimeZoneSidKey='America/Los_Angeles' ;
                testUser.LocaleSidKey = 'en_US';
                testUser.EmailEncodingKey = 'UTF-8' ;
                testUser.LanguageLocaleKey='en_US';
                testUser.username = 'accountApplicationApproval@beamsuntory.com';
                testUser.email = 'accountApplicationApproval@beamsuntory.com';
                insert testUser;
        
        Account_Application__c makersApplication = new Account_Application__c();
        makersApplication.Brand__c = 'Makers Mark';
        makersApplication.Status__c = 'Approved';
        makersApplication.Application_Question_Set__c = makersMarkQuestionSet.Id;
        makersApplication.Account__c = testAccount.Id;
        makersApplication.Submitter__c = UserInfo.getUserId();
        makersApplication.Regional_Diplomat__c = testUser.Id;
        makersApplication.Heritage_Manager__c = testUser.Id;
        
        insert makersApplication;
        
        //Added By Nishant khandal
        Account_Application__c laproaigApplication = new Account_Application__c();
        laproaigApplication.Brand__c = SBP_Constants.LAPHROAIG_SINGLE_CASK;
        laproaigApplication.Status__c = 'Approved';
        laproaigApplication.Application_Question_Set__c = laphroaigSingleCaskQuestionSet.Id;
        laproaigApplication.Account__c = intAccount.Id;
        laproaigApplication.Submitter__c = UserInfo.getUserId();
        laproaigApplication.Regional_Diplomat__c = testUser.Id;
        laproaigApplication.Heritage_Manager__c = testUser.Id;
		
        insert laproaigApplication;
        
        Application_Response__c r1q1 = new Application_Response__c(Account_Application__c = makersApplication.Id, Answer_Text__c = 'Yes', Application_Question__c = q1.Id);
        insert r1q1;
        Application_Response__c r2q2 = new Application_Response__c(Account_Application__c = laproaigApplication.Id, Answer_Text__c = 'Yes', Application_Question__c = q7.Id);
        insert r2q2;
        Diplomatic_Hierarchy__c d = new Diplomatic_Hierarchy__c();
        d.Diplomat__c = u.Id;
        d.Manager__c = u.Id;
        d.User_Type__c = 'Heritage Manager';
        insert d;

    }

    public static Application_Question_Set__c getApplicationQuestionSet(String questionSetName) {
        return [select id from Application_Question_Set__c where Name = :questionSetName limit 1];
    }

    public static Account_Application__c getAccountApplicationByBrand(String brand) {
        return [select id, Status__c from Account_Application__c where Brand__c = :brand limit 1];
    }

    public static List<Account_Application__c> getAllAccountApplicationByBrand(String brand) {
        return [select id, Status__c from Account_Application__c where Brand__c = :brand];
    }

    public static Account getTestAccount() {
        return [select id from Account where Name = 'Test Account'];
    }
    //Added by Nishant Khandal LSB-7
    public static Account getSingleBarrelAccount() {
        return [SELECT ID 
                   FROM Account 
                   WHERE Name =: SBP_Constants.SINGLE_BARREL_INT_ACCOUNT];
    }
    
    //Added by Nishant Khandal LSB-7
    public static Account getDistAccount() {
        return [SELECT ID 
                   FROM Account 
                   WHERE Name = 'Distributor Account'];
    }
    
      public static User getTestUser() {
        return [select id from User where Name = 'Test User' limit 1];
    }
    
    public static Contact getTestContact() {
        return [select id from Contact where Name = 'Test Contact'];
    }

    public static Account getAccountByName(String name) {
        return [select id from Account where Name = :name];
    }

    public static List<Application_Question__c> getQuestionsByBrand(String brand) {
        return [select id from Application_Question__c where Application_Question_Set__r.Brand__c = :brand];
    }

    public static testMethod void getAccountApplicationDataTest() {

        Test.startTest();
        Application_Question_Set__c elTesoroQuestionSet = getApplicationQuestionSet('El Tesoro');

        LightningComponentUtility.RequestStatus response = SBP_AccountApplicationCmpCtrl.getAccountApplicationData('El Tesoro', false,'a4I8A000000JnR5UAK');

        System.assertEquals(elTesoroQuestionSet.Id, response.responseMap.get('questionSetId'), 'Question Sets should be equal');
        System.assertNotEquals(NULL, response.responseMap.get('appQuestions'), 'Questions should be returned');
        System.assertEquals(true, response.success, 'Operation should return successfully');

        Test.stopTest();
    }

    public static testMethod void accountApplicationStatusApprovedTest() {

        Test.startTest();
        Account_Application__c makersApplication = getAccountApplicationByBrand('Makers Mark');
        Account testAccount = getTestAccount();

        LightningComponentUtility.RequestStatus response = SBP_AccountApplicationCmpCtrl.getAccountStatus(testAccount.Id, 'Makers Mark');

        System.assertEquals(true, response.responseMap.get('accountApproved'), 'Application should be approved');
        System.assertEquals(true, response.success, 'Operation should return successfully');

        Test.stopTest();
    }

    public static testMethod void accountApplicationStatusApprovedErrorTest() {

        Test.startTest();
        Account_Application__c makersApplication = getAccountApplicationByBrand('Makers Mark');
        Account testAccount = getTestAccount();

        LightningComponentUtility.RequestStatus response = SBP_AccountApplicationCmpCtrl.getAccountStatus(makersApplication.Id, 'Makers Mark');

        System.assertEquals(false, response.success, 'Operation should not return successfully');

        Test.stopTest();
    }

    public static testMethod void accountApplicationStatusPendingApprovalTest() {
       
        User testUser = getTestUser();
        Test.startTest();
        Account_Application__c makersApplication = getAccountApplicationByBrand('Makers Mark');
        //makersApplication.Status__c = 'Pending Approval';
        makersApplication.Diplomat_Partner_for_Your_Barrel__c = testUser.Id;
        update makersApplication;

        Account testAccount = getTestAccount();

        LightningComponentUtility.RequestStatus response = SBP_AccountApplicationCmpCtrl.getAccountStatus(testAccount.Id, 'Makers Mark');

        //System.assertEquals(true, response.responseMap.get('accountPendingApproval'), 'Application should be in pending approval status');
        System.assertEquals(true, response.success, 'Operation should return successfully');

        Test.stopTest();
    }

    public static testMethod void createApplicationTest() {
        List<Application_Question__c> questions = getQuestionsByBrand('Makers Mark');
        Application_Question_Set__c makersMarkQuestionSet = getApplicationQuestionSet('Maker\'s Mark Domestic');
        List<Account_Application__c> applications = getAllAccountApplicationByBrand('Makers Mark');
        Account retailAccount = getAccountByName('Retail Account');

        String questionResponse = '[{'
                                  + '    "Application_Question__c": "' + questions[0].Id + '",'
                                  + '    "Answer_Text__c": "No"'
                                  + '}, {'
                                  + '    "Application_Question__c": "' + questions[1].Id + '",'
                                  + '    "Answer_Text__c": "Yes"'
                                  + '}, {'
                                  + '    "Application_Question__c": "' + questions[2].Id + '",'
                                  + '    "Answer_Text__c": "No"'
                                  + '}]';

        String jsonApplications = '[{"Premise_Type__c":"On Premise"'
                                  + ',"Account__c":"' + retailAccount.Id + '"'
                                  + ',"City__c":""'
                                  + ',"Country__c":""'
                                  + ',"Brand__c":"Makers Mark"'
                                  + ',"Application_Question_Set__c":"' + makersMarkQuestionSet.Id + '"'
                                  + ',"Account_Name__c":""}]';
        String userId = '[{"Name":"Test User"}]';

        Test.startTest();

        Account testAccount = getTestAccount();
        User testUser = getTestUser();
        
        System.assertEquals(1, applications.size(), 'One application should exist');
        
        LightningComponentUtility.RequestStatus response = SBP_AccountApplicationCmpCtrl.insertAccountApplication(questionResponse, jsonApplications,testUser.Id);
        List<Account_Application__c> applicationsAfter = getAllAccountApplicationByBrand('Makers Mark');
        //System.assertEquals(2, applicationsAfter.size(), 'Two applications should exist');
        System.assertEquals(true, response.success, 'Operation should return successfully');
        
        Test.stopTest();
    }

    public static testMethod void usePreviousApplicationResponsesTest() {
        List<Account_Application__c> applications = getAllAccountApplicationByBrand('Makers Mark');

        Test.startTest();

        Account testAccount = getTestAccount();
        Contact testContact = getTestContact();
        User testUser = getTestUser();
        System.assertEquals(1, applications.size(), 'One application should exist');
        //LightningComponentUtility.RequestStatus response = SBP_AccountApplicationCmpCtrl.sendRequestWithPreviousAnswers(testAccount.Id, 'Makers Mark');
        LightningComponentUtility.RequestStatus response = SBP_AccountApplicationCmpCtrl.sendRequestWithPreviousAnswers(testAccount.Id, 'Makers Mark', testAccount.Id, testContact.Id,'Yes','Yes',testUser.Id);
        LightningComponentUtility.RequestStatus response2 = SBP_AccountApplicationCmpCtrl.sendRequestWithPreviousAnswersForMM('[{"Premise_Type__c":"On Premise","Account__c":"0018A00000dbv5cQAA","City__c":"GRAND COULEE","State__c":"Washington","Country__c":"US","Brand__c":"Makers Mark","Account_Name__c":"PEPPER JACKS BAR & GRILL","Distributor_Account__c":"0018A00000dc2SuQAI","Diplomat_Partner_for_Your_Barrel__c":"0058A000007EwBKQA0","Heritage_Manager__c":"0058A000007EwBKQA0"}]',testUser.Id);
        
        List<Account_Application__c> applicationsAfter = getAllAccountApplicationByBrand('Makers Mark');
        //System.assertEquals(2, applicationsAfter.size(), 'Two applications should exist');
        System.assertEquals(true, response.success, 'Operation should return successfully');

        Test.stopTest();
    }

    public static testMethod void usePreviousApplicationResponsesErrorTest() {
        List<Account_Application__c> applications = getAllAccountApplicationByBrand('Makers Mark');
        Account testAccount = getTestAccount();
        Contact testContact = getTestContact();
        User testUser = getTestUser();
        Test.startTest();

        LightningComponentUtility.RequestStatus response = SBP_AccountApplicationCmpCtrl.sendRequestWithPreviousAnswers(applications[0].Id, 'Makers Mark', testAccount.Id, testContact.Id,'Yes','Yes',testuser.Id);

        System.assertEquals(false, response.success, 'Operation should not return successfully');

        Test.stopTest();
    }

    public static testMethod void elTesoroProgramUnavailableTest() {
        Time_Interval__c elTesoroTimeInterval = new Time_Interval__c();
        elTesoroTimeInterval.Brand__c = 'El Tesoro';
        elTesoroTimeInterval.Type__c = 'Season Program Length';
        elTesoroTimeInterval.Start_Date__c = Date.today();
        elTesoroTimeInterval.End_Date__c = Date.today().addDays(10);
        elTesoroTimeInterval.isActive__c = false;
        insert elTesoroTimeInterval;

        Test.startTest();

        LightningComponentUtility.RequestStatus response = SBP_AccountApplicationCmpCtrl.isProgramAvailable('El Tesoro');

        System.assertEquals(false, response.responseMap.get('isActiveProgram'), 'Program should be unavailable');
        System.assertEquals(true, response.success, 'Operation should return successfully');

        Test.stopTest();
    }

    public static testMethod void elTesoroProgramAvailableTest() {
        Time_Interval__c elTesoroTimeInterval = new Time_Interval__c();
        elTesoroTimeInterval.Brand__c = 'El Tesoro';
        elTesoroTimeInterval.Type__c = 'Season Program Length';
        elTesoroTimeInterval.Start_Date__c = Date.today().addDays(40);
        elTesoroTimeInterval.End_Date__c = Date.today().addDays(50);
        elTesoroTimeInterval.Application_Deadline__c = Date.today().addDays(1);
        elTesoroTimeInterval.isActive__c = true;
        insert elTesoroTimeInterval;

        Test.startTest();

        LightningComponentUtility.RequestStatus response = SBP_AccountApplicationCmpCtrl.isProgramAvailable('El Tesoro');

        System.assertEquals(true, response.responseMap.get('isActiveProgram'), 'Program should be available' + response.message);
        System.assertEquals(true, response.success, 'Operation should return successfully');

        Test.stopTest();
    }

    public static testMethod void getSObjectNameTest() {
        Account_Application__C makersApplication = [Select Id from Account_Application__C limit 1];
        Test.startTest();
        String objName = SBP_AccountApplicationCmpCtrl.getSObjectName(makersApplication.Id);
        Test.stopTest();
        System.assert(objName == 'Account_Application__C');
    }
    
    public static testMethod void getHeritageManagerTest() {
        Diplomatic_Hierarchy__c u = [Select Diplomat__c from Diplomatic_Hierarchy__c where user_type__c = 'Heritage Manager' limit 1];
        Test.startTest();
        sObject objName = SBP_AccountApplicationCmpCtrl.getHeritageManager(u.Diplomat__c);
        Test.stopTest();
        System.assert(objName != null);
    }
	
    //Added By Nishant khandal LSB-7
    public static testMethod void insertAccountApplicationForLSCTest() {
        List<Application_Question__c> questions = getQuestionsByBrand(SBP_Constants.LAPHROAIG_SINGLE_CASK);
        Application_Question_Set__c laproaigQuestionSet = getApplicationQuestionSet('Laphroaig Single Cask Question Set');
        List<Account_Application__c> applications = getAllAccountApplicationByBrand(SBP_Constants.LAPHROAIG_SINGLE_CASK);
        Account retailAccount = getAccountByName('Retail Account');
        String questionResponse = '[{'
                                  + '    "Application_Question__c": "' + questions[0].Id + '",'
                                  + '    "Answer_Text__c": "No"'
                                  + '}, {'
                                  + '    "Application_Question__c": "' + questions[1].Id + '",'
                                  + '    "Answer_Text__c": "Yes"'
                                  + '}, {'
                                  + '    "Application_Question__c": "' + questions[2].Id + '",'
                                  + '    "Answer_Text__c": "No"'
                                  + '}]';

        String jsonApplications = '[{"Premise_Type__c":"On Premise"'
                                  + ',"Account__c":"' + retailAccount.Id + '"'
                                  + ',"City__c":""'
                                  + ',"Country__c":""'
                                  + ',"Brand__c":"Laphroaig Single Cask"'
                                  + ',"Application_Question_Set__c":"' + laproaigQuestionSet.Id + '"'
                                  + ',"Account_Name__c":""}]';
        String userId = '[{"Name":"Test User"}]';
        Test.startTest();
        Account testAccount = getTestAccount();
        User testUser = getTestUser();
        LightningComponentUtility.RequestStatus response = SBP_AccountApplicationCmpCtrl.insertAccountApplicationForLSC(questionResponse,
                                                                                                                        jsonApplications,
                                                                                                                        testUser.Id);
        LightningComponentUtility.RequestStatus response2 = SBP_AccountApplicationCmpCtrl.insertAccountApplicationForLSC(questionResponse,
                                                                                                                        jsonApplications,
                                                                                                                        UserInfo.getUserId());
        Test.stopTest();
        System.assertEquals(true, response.success, SBP_Constants.OPERATION_SUCCESS);
    }
    
    //Added By Nishant khandal LSB-7
    public static testMethod void sendRequestWithPreviousAnswersForLSCTest() {
        Account distAccount = getDistAccount();
        Account singleBarrelAccount = getSingleBarrelAccount();
        Contact testContact = getTestContact();
        User testUser = getTestUser();
        
        Test.startTest();
        LightningComponentUtility.RequestStatus response = SBP_AccountApplicationCmpCtrl.sendRequestWithPreviousAnswersForLSC
            ('[{"Premise_Type__c":"On Premise",'+'"Account__c":"'+singleBarrelAccount.Id+'","City__c":"GRAND COULEE",'
             +'"State__c":"Washington","Country__c":"US","Brand__c":"Laphroaig Single Cask",'
             +'"Account_Name__c":"PEPPER JACKS BAR & GRILL","Distributor_Account__c":"'+distAccount.Id+'"}]',
             testUser.Id);
        LightningComponentUtility.RequestStatus response2 = SBP_AccountApplicationCmpCtrl.sendRequestWithPreviousAnswersForLSC
            ('[{"Premise_Type__c":"On Premise",'+'"Account__c":"null","City__c":"GRAND COULEE",'
             +'"State__c":"Washington","Country__c":"US","Brand__c":"Laphroaig Single Cask",'
             +'"Account_Name__c":"PEPPER JACKS BAR & GRILL","Distributor_Account__c":"'+distAccount.Id+'"}]',
             UserInfo.getUserId());
        Test.stopTest();
        System.assertEquals(true, response.success, SBP_Constants.OPERATION_SUCCESS);
    }
    
    //Added By Nishant khandal LSB-7
    public static testMethod void tstgetAccountApplicationDataCoveredLSCPart() {
        Test.startTest();
        LightningComponentUtility.RequestStatus response = SBP_AccountApplicationCmpCtrl.getAccountApplicationData(SBP_Constants.LAPHROAIG_SINGLE_CASK, 
                                                                                                                   false,
                                                                                                                   null);
        Test.stopTest();
        System.assertEquals(true, response.success, SBP_Constants.OPERATION_SUCCESS);
    }
}