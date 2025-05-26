@isTest
private class CreateExceptionLogTest {
	@testSetup static void setup() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id,
		                  TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser@test-user-system.com.test-only');
		insert u;

	}

	public static testMethod void createExceptionLogRightAwayTest() {
		List<Custom_Exception_Logs__c> errors = new List<Custom_Exception_Logs__c>();

		Test.startTest();

		errors.add(CreateExceptionLog.createExceptionLog('TestClass', 'testmethod', 'Error message', 'Warning', false));
		errors.add(CreateExceptionLog.createExceptionLog('TestClass2', 'testmethod1', 'Error message', 'Warning', false));
		insert errors;

		Test.stopTest();

		List<Custom_Exception_Logs__c> logs = [Select Id from Custom_Exception_Logs__c];

		System.assertEquals(2, logs.size(), '2 logs should have been created');
	}

	public static testMethod void createExceptionLogOneExceptionLogTest() {
		Test.startTest();

		CreateExceptionLog.insertErrorLog('TestClass', 'testmethod', 'Error message', 'Warning');

		Test.stopTest();

		List<Custom_Exception_Logs__c> logs = [Select Id from Custom_Exception_Logs__c];

		System.assertEquals(1, logs.size(), '1 log should have been created');
	}


}