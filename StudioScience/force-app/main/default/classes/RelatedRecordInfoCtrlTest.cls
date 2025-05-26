@isTest
private class RelatedRecordInfoCtrlTest {
	@testSetup static void setup() {

		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = new User(Alias = 'beamtu', Email = 'standarduser2@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id,
		                  TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser@test-user-system.com.test-only');
		insert u;

		Case parentCase = new Case();
		parentCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Quality_Claim').getRecordTypeId();
		insert parentCase;

		Case childCase = new Case();
		childCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Quality_Claim_Sub_Case').getRecordTypeId();
		childCase.parentId = parentCase.Id;
		childCase.Description = 'Test';
		childCase.Origin = 'Mobile App';
		insert childCase;


	}

	public static User getUserByEmail(String email) {
		return [select Id from User where Email = :email limit 1];
	}

	public static Case getCaseByOrigin(String origin) {
		return [select Id,ParentId from Case where Origin = :origin limit 1];
	}

	@isTest
	public static void getRelatedRecordTest() {
		Case c = getCaseByOrigin('Mobile App');

		LightningComponentUtility.RequestStatus response;
		
		Test.startTest();

		response = RelatedRecordInfoCtrl.getRelatedRecord(String.valueOf(c.Id), 'ParentId');

		Test.stopTest();

		System.assertEquals(c.ParentId, response.responseMap.get('relatedRecordId'), 'User Id should match');
	}

	@isTest
	public static void getRelatedRecordExceptionTest() {
		Case c = getCaseByOrigin('Mobile App');

		LightningComponentUtility.RequestStatus response;
		
		Test.startTest();
		RelatedRecordInfoCtrl.forceException = true;
		response = RelatedRecordInfoCtrl.getRelatedRecord(String.valueOf(c.Id), 'ParentId');

		Test.stopTest();

	}
}