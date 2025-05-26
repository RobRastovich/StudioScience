@isTest
private class QualityClaimCmpCtrlTest {
	@testSetup static void setup() {

		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = new User(Alias = 'beamtu', Email = 'standarduser2@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id,
		                  TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser@test-user-system.com.test-only');
		insert u;

	}

	public static User getUserByEmail(String email) {
		return [select Id from User where Email = :email limit 1];
	}

	
	@isTest public static void getUserInformationTest() {
		User u = getUserByEmail('standarduser2@testorg.com');
		LightningComponentUtility.RequestStatus response;

		Test.startTest();
		System.runAs(u) {

			response = QualityClaimCmpCtrl.getUserInformation(String.valueOf(u.Id));
		}

		Test.stopTest();

		System.assertEquals(u.Id, response.responseMap.get('userId'), 'User Id should match');
	}
	
	@isTest public static void getUserInformationExceptionTest() {
		User u = getUserByEmail('standarduser2@testorg.com');
		LightningComponentUtility.RequestStatus response;

		Test.startTest();
		System.runAs(u) {
			QualityClaimCmpCtrl.forceException = true;
			response = QualityClaimCmpCtrl.getUserInformation(String.valueOf(u.Id));
		}

		Test.stopTest();
	}
	
	@isTest public static void getPicklistValuesTest() {
		LightningComponentUtility.RequestStatus response;

		Test.startTest();

		Id userId = Userinfo.getUserId();

		response = QualityClaimCmpCtrl.getPicklistOptions();

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('picklistFields'), 'List should not be empty');
	}

	@isTest public static void getPicklistValuesExceptionTest() {
		LightningComponentUtility.RequestStatus response;

		Test.startTest();

		QualityClaimCmpCtrl.forceException = true;
		Id userId = Userinfo.getUserId();

		response = QualityClaimCmpCtrl.getPicklistOptions();

		Test.stopTest();

	}

}