@isTest
Private class SBP_AccountApplicationShareHandlerTest {
    @testSetup static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        Profile p1 = [SELECT Id FROM Profile WHERE Name = 'Company Employee'];
        
        //Account Application submitter
        User appSubmitter = new User(Alias = 'beamsub', Email = 'standarduser_submitter@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
                                     EmailEncodingKey = 'UTF-8', LastName = 'Submitter', LanguageLocaleKey = 'en_US',
                                     LocaleSidKey = 'en_US', ProfileId = p.Id,
                                     TimeZoneSidKey = 'America/Chicago', UserName = 'submiterformmapplication@test-user-system.com.test-only');
        
        //Account Application diplomat
        User appdiplomat = new User(Alias = 'beamdip', Email = 'standarduser_diplomat@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
                                    EmailEncodingKey = 'UTF-8', LastName = 'Diplomat', LanguageLocaleKey = 'en_US',
                                    LocaleSidKey = 'en_US', ProfileId = p.Id, User_Type__c = 'Diplomat',
                                    TimeZoneSidKey = 'America/Chicago', UserName = 'diplomatformmapplication@test-user-system.com.test-only');
        
        //Account Application HM
        User appHeritageManager = new User(Alias = 'beamhm', Email = 'standarduserhm@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
                                           EmailEncodingKey = 'UTF-8', LastName = 'HeritagaManager', LanguageLocaleKey = 'en_US',
                                           LocaleSidKey = 'en_US', ProfileId = p.Id, Single_Barrel_Region__c = 'East', User_Type__c = 'Heritage Manager',
                                           TimeZoneSidKey = 'America/Chicago', UserName = 'hmformmapplication@test-user-system.com.test-only');
        
        
        //Creating HM and Diplomats Users for Account Applciation
        List<User> accApplicationUsers = new List<User>();
        accApplicationUsers.add(appSubmitter);
        accApplicationUsers.add(appdiplomat);
        accApplicationUsers.add(appHeritageManager);
        
        insert accApplicationUsers;
        
        // create application question set
        Application_Question_Set__c makersMarkQuestionSet = new Application_Question_Set__c();
        makersMarkQuestionSet.Brand__c = 'Makers Mark';
        makersMarkQuestionSet.Name = 'Maker\'s Mark Domestic';
        insert makersMarkQuestionSet;
        
        // create application questions
        Application_Question__c q1 = new Application_Question__c(Question__c = 'Is the account a P/G/S account overall?', Type__c = 'Radio', Application_Question_Set__c = makersMarkQuestionSet.Id);
        
        Application_Question__c q2 = new Application_Question__c(Question__c = 'Is the account EDGE?', Type__c = 'Radio', Application_Question_Set__c = makersMarkQuestionSet.Id);
        
        Application_Question__c q3 = new Application_Question__c(Question__c = 'Is the account a premium or luxury account?', Type__c = 'Radio', Application_Question_Set__c = makersMarkQuestionSet.Id);
        
        
        insert new List<Application_Question__c> {q1, q2, q3};
            // create answers for each question
            Application_Answer__c q1a1 = new Application_Answer__c(Answer__c = 'Yes', Application_Question__c = q1.Id);
        Application_Answer__c q1a2 = new Application_Answer__c(Answer__c = 'No', Application_Question__c = q1.Id);
        
        Application_Answer__c q2a1 = new Application_Answer__c(Answer__c = 'Yes', Application_Question__c = q2.Id);
        Application_Answer__c q2a2 = new Application_Answer__c(Answer__c = 'No', Application_Question__c = q2.Id);
        
        Application_Answer__c q3a1 = new Application_Answer__c(Answer__c = 'Yes', Application_Question__c = q3.Id);
        Application_Answer__c q3a2 = new Application_Answer__c(Answer__c = 'No', Application_Question__c = q3.Id);
        
        insert new List<Application_Answer__c> {q1a1, q1a2, q2a1, q2a2, q3a1, q3a2};
            
            
            Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.BillingState = 'IL';
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();
        insert testAccount;
        
        List<Account_Application__c> accApplicationList = new List<Account_Application__c>();
        
        Account_Application__c makersApplication = new Account_Application__c();
        makersApplication.Brand__c = 'Makers Mark';
        makersApplication.Status__c = 'Pending Approval';
        makersApplication.State__c = 'Illinois';
        makersApplication.Application_Question_Set__c = makersMarkQuestionSet.Id;
        makersApplication.Account__c = testAccount.Id;
        makersApplication.Submitter__c = accApplicationUsers[0].Id;
        makersApplication.Regional_Diplomat__c = accApplicationUsers[1].Id;
        makersApplication.Diplomat_Partner_for_Your_Barrel__c = accApplicationUsers[1].Id;
        makersApplication.Heritage_Manager__c = accApplicationUsers[2].Id;
        accApplicationList.add(makersApplication);
        
        insert accApplicationList;
        
        Application_Response__c r1q1 = new Application_Response__c(Account_Application__c = accApplicationList[0].Id, Answer_Text__c = 'Yes', Application_Question__c = q1.Id);
        insert r1q1;
        
    }
    
    public static testMethod void shareAccountApplicationWithHMGroupTest() {
        
        //get all the Account Applcation
        List<Account_Application__c> accApplicationList = [Select id, Submitter__c, Heritage_Manager__c, Status__c from Account_Application__c where Brand__c = 'Makers Mark'];
        system.debug('list> ' + accApplicationList);
        Test.startTest();
        SBP_AccountApplicationShareHandler.shareAccountApplicationWithGroup(accApplicationList);
        Test.stopTest();
    } 
    
    public static testMethod void shareAccountApplicationWithHMGroupEmptyListTest() {
        
        //set the empty list of Account Applcations
        List<Account_Application__c> accApplicationList = new List<Account_Application__c>();
        Test.startTest();
        SBP_AccountApplicationShareHandler.shareAccountApplicationWithGroup(accApplicationList);
        Test.stopTest();
    }     
    
    public static testMethod void getGroupIdForAccountApplicationShareTest() {
        
        //get all the Account Applcation
        List<Account_Application__c> accApplicationList = [Select id, Submitter__c, Heritage_Manager__c, Status__c from Account_Application__c where Brand__c = 'Makers Mark'];
        Test.startTest();
        //get HM  public group name
        Map<String, Id> groupNameToGroupId = new Map<String, Id>();
        for (Group g : [SELECT Id, Name, DeveloperName From Group WHERE Name LIKE 'Heritage Manager%']) {
            groupNameToGroupId.put(g.Name, g.Id);
        }
        
        //Get Map of the Id -> User for the HM's for each Account Application
        User u = [SELECT Id, Name, Single_Barrel_Region__c FROM User WHERE Id =: accApplicationList[0].Heritage_Manager__c];
        
        SBP_AccountApplicationShareHandler.getGroupIdForAccountApplicationShare(groupNameToGroupId, u);
        Test.stopTest();
    } 
}