@isTest
private class CS_FlowCmpCtrlTest {
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
		return [select Id,Access_Group__c from User where Alias = :alias limit 1];
	}

	@isTest public static void buildPicklistOptionsTest() {
		LightningComponentUtility.RequestStatus response;
		User u = getUserByAlias('beamtu');
		Test.startTest();
		System.RunAs(u) {
			response = CS_FlowCmpCtrl.buildPicklistOptions();
		}

		Test.stopTest();

		System.assertNotEquals(null, response.responseMap.get('typeCategoryIds'));
		System.assertNotEquals(null, response.responseMap.get('labelToValueTranslationMap'));
		System.assertNotEquals(null, response.responseMap.get('valueToLabelTranslationMap'));
		System.assertNotEquals(null, response.responseMap.get('picklistIdToValue'));
		System.assertNotEquals(null, response.responseMap.get('picklistIdToIdsMap'));
	}

	@isTest public static void buildPicklistOptionsExceptionTest() {
		LightningComponentUtility.RequestStatus response;
		CS_FlowCmpCtrl.forceException = true;

		Test.startTest();

		response = CS_FlowCmpCtrl.buildPicklistOptions();

		Test.stopTest();
	}
}