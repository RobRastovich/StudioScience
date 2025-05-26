@isTest
private class AccountApplicationServicesTest {
	@testSetup static void setup() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id,
		                  TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuseraast@test-user-system.com.test-only');
        insert u; 

		// create application question set
		Application_Question_Set__c makersMarkQuestionSet = new Application_Question_Set__c();
		makersMarkQuestionSet.Brand__c = 'Makers Mark';
		makersMarkQuestionSet.Name = 'Maker\'s Mark Domestic';
		insert makersMarkQuestionSet;

		Application_Question_Set__c elTesoroQuestionSet = new Application_Question_Set__c();
		elTesoroQuestionSet.Brand__c = 'El Tesoro';
		elTesoroQuestionSet.Name = 'El Tesoro';
		insert elTesoroQuestionSet;
        
		Application_Question_Set__c bakerQuestionSet = new Application_Question_Set__c();
		bakerQuestionSet.Brand__c = 'Baker\'s';
		bakerQuestionSet.Name = 'Bakers';
		insert bakerQuestionSet;

		// create application questions
		Application_Question__c q1 = new Application_Question__c(Question__c = 'Is the account a P/G/S account overall?', Type__c = 'Radio', Application_Question_Set__c = makersMarkQuestionSet.Id);
		Application_Question__c q2 = new Application_Question__c(Question__c = 'Is the account a P/G/S account overall?', Type__c = 'Radio', Application_Question_Set__c = elTesoroQuestionSet.Id);
		Application_Question__c q7 = new Application_Question__c(Question__c = 'Is the account a P/G/S account overall?', Type__c = 'Text', Application_Question_Set__c = bakerQuestionSet.Id);
        
		Application_Question__c q3 = new Application_Question__c(Question__c = 'Is the account EDGE?', Type__c = 'Radio', Application_Question_Set__c = makersMarkQuestionSet.Id);
		Application_Question__c q4 = new Application_Question__c(Question__c = 'Is the account EDGE?', Type__c = 'Radio', Application_Question_Set__c = elTesoroQuestionSet.Id);
		Application_Question__c q8 = new Application_Question__c(Question__c = 'Is the account EDGE?', Type__c = 'Text', Application_Question_Set__c = bakerQuestionSet.Id);
        
		Application_Question__c q5 = new Application_Question__c(Question__c = 'Is the account a premium or luxury account?', Type__c = 'Radio', Application_Question_Set__c = makersMarkQuestionSet.Id);
		Application_Question__c q6 = new Application_Question__c(Question__c = 'Is the account a premium or luxury account?', Type__c = 'Radio', Application_Question_Set__c = elTesoroQuestionSet.Id);
		Application_Question__c q9 = new Application_Question__c(Question__c = 'Is the account a premium or luxury account?', Type__c = 'Text', Application_Question_Set__c = bakerQuestionSet.Id);
        
		insert new List<Application_Question__c> {q1, q2, q3, q4, q5, q6, q7, q8, q9};
		// create answers for each question
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
        
        
		insert new List<Application_Answer__c> {q1a1, q1a2, q2a1, q2a2, q3a1, q3a2, q4a1, q4a2, q5a1, q5a2, q6a1, q6a2 };


		Account testAccount = new Account();
		testAccount.Name = 'Test Account';
		testAccount.BillingState = 'IL';
		testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();
		insert testAccount;

		Account_Application__c makersApplication = new Account_Application__c();
		makersApplication.Brand__c = 'Makers Mark';
		makersApplication.Status__c = 'New';
		makersApplication.State__c = '';
		makersApplication.Application_Question_Set__c = makersMarkQuestionSet.Id;
		makersApplication.Account__c = testAccount.Id;
		insert makersApplication;

		Application_Response__c r1q1 = new Application_Response__c(Account_Application__c = makersApplication.Id, Answer_Text__c = 'Yes', Application_Question__c = q1.Id);
		insert r1q1;
        
		//LSB-153
		Application_Question_Set__c lscQuestionSet = SBP_TestDataFactory.createApplicationQuestionSet(true);
        Account_Application__c laphroaigApplication = SBP_TestDataFactory.createAccountApplication(lscQuestionSet,
			testAccount, true);
	}

	public static Application_Question_Set__c getApplicationQuestionSet(String questionSetName) {
		return [select id from Application_Question_Set__c where Name = :questionSetName limit 1];
	}

	public static Account_Application__c getAccountApplicationByBrand(String brand) {
		return [select id, Status__c from Account_Application__c where Brand__c = :brand limit 1];
	}

	public static Account_Application__c getAccountApplicationById(Id appId) {
		return [select id, Status__c, Case__c, Regional_Diplomat__c from Account_Application__c where Id = :appId limit 1];
	}

	public static List<Case> getCurrentNumberOfCases() {
		return [select Id from Case];
	}

	public static List<Account_Application__c> getAllAccountApplicationByBrand(String brand) {
		return [select id, Status__c from Account_Application__c where Brand__c = :brand];
	}

	public static Account getTestAccount() {
		return [select id from Account where Name = 'Test Account'];
	}

	public static List<Application_Question__c> getQuestionsByBrand(String brand) {
		return [select id from Application_Question__c where Application_Question_Set__r.Brand__c = :brand];
	}

	public static testMethod void updateRegionalDiplomatTest() {
		Application_Question_Set__c makersMarkQuestionSet = getApplicationQuestionSet('Maker\'s Mark Domestic');
		Account testAccount = getTestAccount();

		Test.startTest();

		Account_Application__c makersApplication = new Account_Application__c();
		makersApplication.Brand__c = 'Makers Mark';
		makersApplication.Status__c = 'New';
		makersApplication.Regional_Diplomat__c = null;
		makersApplication.Application_Question_Set__c = makersMarkQuestionSet.Id;
		makersApplication.Account__c = testAccount.Id;

		insert makersApplication;

		Account_Application__c app = getAccountApplicationById(makersApplication.Id);

		System.assertNotEquals(NULL, app.Regional_Diplomat__c, 'A Regional Diplomat should exist for this application');


		Test.stopTest();
	}
	// when the account does not exist in Salesforce
	public static testMethod void updateRegionalDiplomatForInternationalApplicationTest() {
		Application_Question_Set__c makersMarkQuestionSet = getApplicationQuestionSet('Maker\'s Mark Domestic');

		Test.startTest();

		Account_Application__c makersApplication = new Account_Application__c();
		makersApplication.Brand__c = 'Makers Mark';
		makersApplication.Status__c = 'New';
		makersApplication.State__c = 'Illinois';
		makersApplication.Account_Name__c = 'Missing Account Name';
		makersApplication.Regional_Diplomat__c = null;
		makersApplication.Application_Question_Set__c = makersMarkQuestionSet.Id;

		insert makersApplication;

		Account_Application__c app = getAccountApplicationById(makersApplication.Id);

		System.assertNotEquals(NULL, app.Regional_Diplomat__c, 'A Regional Diplomat should exist for this application');


		Test.stopTest();
	}

	public static testMethod void applicationApprovedCreatesCaseTest() {
		Application_Question_Set__c makersMarkQuestionSet = getApplicationQuestionSet('Maker\'s Mark Domestic');
		Account testAccount = getTestAccount();

		List<Case> currentNumberOfCases = getCurrentNumberOfCases();
		System.assertEquals(0, currentNumberOfCases.size(), 'No Cases Should exist');

		Test.startTest();

		Account_Application__c makersApplication = new Account_Application__c();
		makersApplication.Brand__c = 'Makers Mark';
		makersApplication.Status__c = 'New';
		makersApplication.Regional_Diplomat__c = null;
		makersApplication.Case__c = null;
		makersApplication.Application_Question_Set__c = makersMarkQuestionSet.Id;
		makersApplication.Account__c = testAccount.Id;
		makersApplication.Submitter__c = UserInfo.getUserId();
		insert makersApplication;

		Account_Application__c app = getAccountApplicationById(makersApplication.Id);

		app.Status__c = 'Approved';
		update app;

		Test.stopTest();

		List<Case> updatedNumberOfCases = getCurrentNumberOfCases();
		Account_Application__c updatedApp = getAccountApplicationById(makersApplication.Id);

		System.assertNotEquals(NULL, updatedApp.Case__c, 'A case should be added to the account application record');
		System.assertEquals(currentNumberOfCases.size() + 1, updatedNumberOfCases.size(), 'One case should have be created');
	}


	public static testMethod void bakerApplicationApprovedCreatesCaseTest() {
		Application_Question_Set__c makersMarkQuestionSet = getApplicationQuestionSet('Bakers');
		Account testAccount = getTestAccount();
		Barrel_Number__c newBarrel = new Barrel_Number__c();
		newBarrel.Brand__c = 'Baker\'s';
		newBarrel.Next_Barrel_Number__c = '1';
		insert newBarrel;
		List<Case> currentNumberOfCases = getCurrentNumberOfCases();
		System.assertEquals(0, currentNumberOfCases.size(), 'No Cases Should exist');

		Test.startTest();

		Account_Application__c makersApplication = new Account_Application__c();
		makersApplication.Brand__c = 'Baker\'s';
		makersApplication.Status__c = 'New';
		makersApplication.Regional_Diplomat__c = null;
		makersApplication.Case__c = null;
		makersApplication.Application_Question_Set__c = makersMarkQuestionSet.Id;
		makersApplication.Account__c = testAccount.Id;
		makersApplication.Submitter__c = UserInfo.getUserId();
		insert makersApplication;

		Account_Application__c app = getAccountApplicationById(makersApplication.Id);

		app.Status__c = 'Approved';
		update app;

		Test.stopTest();

		List<Case> updatedNumberOfCases = getCurrentNumberOfCases();
		Account_Application__c updatedApp = getAccountApplicationById(makersApplication.Id);

		System.assertNotEquals(NULL, updatedApp.Case__c, 'A case should be added to the account application record');
		System.assertEquals(currentNumberOfCases.size() + 1, updatedNumberOfCases.size(), 'One case should have be created');
	}
    
    //Added By Abhishek Sharma
    public static testMethod void laphroaigApplicationApprovedCreatesCaseTest() {
        Account testAccount = getTestAccount();
        List<Case> currentNumberOfCases = getCurrentNumberOfCases();
        Account_Application__c laphroaigApplication = [SELECT Id 
                                                       FROM Account_Application__c 
                                                       WHERE Brand__c =: SBP_Constants.LAPHROAIG_SINGLE_CASK 
                                                       LIMIT 1];
        Account_Application__c app = getAccountApplicationById(laphroaigApplication.Id);
        app.Status__c = 'Approved';
        update app;

        Test.startTest();
        	List<Case> updatedNumberOfCases = getCurrentNumberOfCases();
        Test.stopTest();

        System.assertEquals(currentNumberOfCases.size() + 1, updatedNumberOfCases.size(), 'One case should have be created');
    }
}