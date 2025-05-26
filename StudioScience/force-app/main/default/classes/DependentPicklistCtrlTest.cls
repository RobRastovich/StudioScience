@isTest
private class DependentPicklistCtrlTest {
	@testSetup static void setup() {


	}

	public static User getUserByLastname(String lastName) {
		return [select id from User where LastName = :lastName limit 1];
	}

	public static testMethod void getUserInformationTest() {
		List<String> issueDefinitions = new List<String>();
		issueDefinitions.add('Broken/Cracked');
		issueDefinitions.add('Leaking');
		issueDefinitions.add('Label Missing/Torn/Smudged/Loose');
		issueDefinitions.add('Missing Refund Statement');
		issueDefinitions.add('Broken Closure');
		issueDefinitions.add('Other - Bottle');

		

		Test.startTest();

		Id userId = Userinfo.getUserId();

		Map<String, List<String>> response = DependentPicklistCtrl.getDependentOptions('Case', 'Type', 'Issue_Type_Definition__c');

		Test.stopTest();


		System.assertEquals(issueDefinitions, response.get('Bottle'), 'bottle dependencies should match');
	}

	
}