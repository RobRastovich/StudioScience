@isTest
private class GeoLocationCmpCtrlTest {
	@testSetup static void setup() {
		Account testAccount = new Account();
		testAccount.Name = 'Test Account';
		testAccount.BillingState = 'IL';
		testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();

		insert testAccount;

		Case c = new Case();
		c.Brand__c = 'Knob Creek';
		c.ccEmail__c = 'test@test.com';
		c.AccountId = testAccount.Id;
		insert c;

	}

	public static Case getCaseByBrand(String brand) {
		return [select id from Case where Brand__c = :brand limit 1];
	}

	public static testMethod void updateGeolocationTest() {
		Test.startTest();

		Case c = getCaseByBrand('Knob Creek');

		sObject sObj = GeoLocationCmpCtrl.updateGeoLocation(String.valueOf(c.Id), 'Geolocation', 10, 10);

		Test.stopTest();

		Case updatedCase = [select id, Geolocation__Latitude__s, Geolocation__Longitude__s from case where Id =:c.Id];


		System.assertEquals(c.Id, sObj.Id, 'User Id should match');
		System.assertEquals(10, updatedCase.Geolocation__Latitude__s, 'lat should be 10');
	}

}