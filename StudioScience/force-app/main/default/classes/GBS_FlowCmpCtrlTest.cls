@isTest
private class GBS_FlowCmpCtrlTest {
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
	}

	public static User getUserByAlias(String alias) {
		return [select Id,GBS_Centers__c,Access_Group__c from User where Alias = :alias limit 1];
	}

	public static testMethod void buildPicklistOptionsForUserWithNoGBSCenterAssignedTest() {
		LightningComponentUtility.RequestStatus response;
		User u = getUserByAlias('beamtu');
		Test.startTest();
		System.RunAs(u) {
			response = GBS_FlowCmpCtrl.buildPicklistOptions();
		}

		Test.stopTest();

		System.assertEquals('US/Canada', response.responseMap.get('gbsCenter'), 'GBS Center should be US/Canada');
	}

	public static testMethod void buildPicklistOptionsForUserWithMXGBSCenterAssignedTest() {
		LightningComponentUtility.RequestStatus response;
		User u = getUserByAlias('beamtu');
		u.GBS_Centers__c = 'MX';
		update u;

		Test.startTest();
		System.RunAs(u) {
			response = GBS_FlowCmpCtrl.buildPicklistOptions();
		}

		Test.stopTest();
		
		System.assertEquals('Mexico', response.responseMap.get('gbsCenter'), 'GBS Center should be Mexico');
	}




}