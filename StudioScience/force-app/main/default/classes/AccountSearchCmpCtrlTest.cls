@isTest
private class AccountSearchCmpCtrlTest {
	@testSetup static void setup() {

		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = new User(Alias = 'beamtu', Email = 'standarduser2@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id,
		                  TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser@test-user-system.com.test-only');
		insert u;

		List<Account> accts = createAccounts(10, 'OnPremise', true);
		List<Case> cases = createCases(10, 'Quality_Claim', false);

		for (Integer i = 0; i < 10; i++) {
			cases[i].AccountId = accts[i].Id;
			cases[i].Submitter__c = UserInfo.getUserId();
		}
		caseServices.runTrigger = false;
		insert cases;

	}

	public static User getUserByEmail(String email) {
		return [select Id from User where Email = :email limit 1];
	}

	@isTest
	public static void searchForRecentRecordsTest() {

		Test.startTest();

		List<Account> accts = AccountSearchCmpCtrl.searchForRecentRecords(String.valueOf(UserInfo.getUserId()), new List<String> {'OnPremise'});

		Test.stopTest();

		System.assertEquals(accts.size(), 10, '10 Accounts should be returned');
	}

	@isTest
	public static void searchForRecordsSOQLTest() {
		String query = 'SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry FROM Account where Name LIKE \'Test%\' AND RecordType.DeveloperName = \'OnPremise\'  LIMIT 50';

		Test.startTest();

		List<Account> accts = AccountSearchCmpCtrl.searchForRecordsSOQL(query);

		Test.stopTest();

		System.assertEquals(accts.size(), 10, '10 Accounts should be returned');
	}

	@isTest
	public static void searchForRecordsSOQLOneResultTest() {
		String query = 'SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry FROM Account where Name LIKE \'Test Account 2%\' AND RecordType.DeveloperName = \'OnPremise\'  LIMIT 50';

		Test.startTest();

		List<Account> accts = AccountSearchCmpCtrl.searchForRecordsSOQL(query);

		Test.stopTest();

		System.assertEquals(accts.size(), 1, '1 Account should be returned');
	}

	public static List<Account> createAccounts(Integer numOfRecords, String recordTypeDevName, Boolean autoCreate) {
		List<Account> accountsToCreate = new List<Account>();

		for (Integer i = 0; i < numOfRecords; i++) {
			Account acct = new Account();
			acct.Name = 'Test Account ' + i;
			acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
			accountsToCreate.add(acct);
		}

		if (autoCreate) {
			insert accountsToCreate;
		}

		return accountsToCreate;
	}

	public static List<Case> createCases(Integer numOfRecords, String recordTypeDevName, Boolean autoCreate) {
		List<Case> recordsToCreate = new List<Case>();

		for (Integer i = 0; i < numOfRecords; i++) {
			Case c = new Case();
			c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
			recordsToCreate.add(c);
		}

		if (autoCreate) {
			insert recordsToCreate;
		}

		return recordsToCreate;
	}
}