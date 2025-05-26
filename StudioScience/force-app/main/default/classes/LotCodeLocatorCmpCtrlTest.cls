@isTest
private class LotCodeLocatorCmpCtrlTest {
	@testSetup static void setup() {

		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = new User(Alias = 'beamtu', Email = 'standarduser2@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id,
		                  TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser@test-user-system.com.test-only');
		insert u;

	}

	@isTest
	public static void getLotCodeImagesTest() {
		LightningComponentUtility.RequestStatus response;

		Test.startTest();

		response = LotCodeLocatorCmpCtrl.getLotCodeImages();

		Test.stopTest();

		System.assertNotEquals(null, response.responseMap.get('brandToLotCodeImage'));
	}

	@isTest
	public static void getLotCodeImagesExceptionTest() {
		LightningComponentUtility.RequestStatus response;

		Test.startTest();

		LotCodeLocatorCmpCtrl.forceException = true;
		response = LotCodeLocatorCmpCtrl.getLotCodeImages();

		Test.stopTest();
	}
}