@isTest
private class GBS_MultipleLanguageEmailControllerTest {
	@testSetup static void setup() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

		User u = new User();
		u.Alias = 'beamtu';
		u.Email = 'standarduser@testorg.com';
		u.EmailEncodingKey = 'UTF-8';
		u.LastName = 'Test';
		u.FirstName = 'Test';
		u.LanguageLocaleKey = 'en_US';
		u.LocaleSidKey = 'en_US';
		u.ProfileId = p.Id;
		u.TimeZoneSidKey = 'America/Chicago';
		u.UserName = 'beamsuntorytestuser@test-user-system.com.test-only';
		insert u;

		Account testAccount = new Account();
		testAccount.Name = 'Test Account';
		testAccount.BillingState = 'IL';
		testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();
		insert testAccount;

		Case c = new Case();
		c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Payroll').getRecordTypeId();
		c.Type = 'Payroll';
		c.AccountId = testAccount.Id;
		insert c;
	}

	public static User getUserByAlias(String alias) {
		return [select Id, GBS_Centers__c, Access_Group__c from User where Alias = :alias limit 1];
	}

	public static Case getCaseByType(String caseType) {
		return [select Id from Case where Type = :caseType];
	}

	public static testMethod void buildPicklistOptionsForUserWithNoGBSCenterAssignedTest() {
		Case c = getCaseByType('Payroll');
		User u = getUserByAlias('beamtu');

		GBS_MultipleLanguageEmailController ctrl = new GBS_MultipleLanguageEmailController();
		ctrl.emailTemplateDeveloperName = 'Case_Assigned_en_US';
		ctrl.emailWhoId = u.Id;
		ctrl.emailRelatedToId = c.Id;

		Test.startTest();

		String htmBody = ctrl.getMergedEmailHtmlBody();
		String textBody = ctrl.getMergedEmailPlainTextBody();
		String subject = ctrl.getMergedEmailSubject();

		Test.stopTest();

		System.assertNotEquals(null, htmBody, 'Body should not be empty');
		System.assertNotEquals(null, textBody, 'Body should not be empty');
		System.assertNotEquals(null, subject, 'Subject should not be empty');
	}

}