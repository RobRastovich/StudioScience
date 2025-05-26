public without sharing class AccountSearchCmpCtrl {

	@AuraEnabled
	public static List <SObject> searchForRecordsSOQL(String searchQuery) {
        system.debug('Search Query>>>' +searchQuery);
		return Database.query(searchQuery);
	}

	@AuraEnabled
	public static List <Account> searchForRecentRecords(String userId, List<String> recordTypeDevNames) {
		Set <Id> accountIds = new Set <Id>();

		for (Case c: [select id, AccountId from Case where Submitter__c =: Id.valueOf(userId)]) {
			accountIds.add(c.AccountId);
		}
		return [SELECT Id, Name, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, BillingState from Account where Id IN: accountIds AND RecordType.DeveloperName IN :recordTypeDevNames order by Name];
	}

}