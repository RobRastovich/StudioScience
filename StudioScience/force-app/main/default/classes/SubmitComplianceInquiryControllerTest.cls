@isTest
public  class SubmitComplianceInquiryControllerTest {

	@testSetup static void setup() {
		CaseComplianceUtilityTest.insertStateMetadataCustomSetting();
	}

	@isTest
	public static void testGetPicklistValues() {
		CaseComplianceUtility.RequestStatus requestStatus = SubmitComplianceInquiryController.getPicklistValueMap();
		System.assertEquals(True, String.valueOf(requestStatus.responseMap.get('stateValues')).contains('Alaska'));
	}

	@isTest
	public static void testGetContentDocumentDatatest() {

		Case ppCase = CaseComplianceUtilityTest.createPricePostingCase();
		insert ppCase;
		ContentVersion testContentVersion1 = CaseComplianceUtilityTest.createContentVersion(ComplianceConstants.DOCUMENT_TYPE_OTHER);
		ContentVersion testContentVersion2 = CaseComplianceUtilityTest.createContentVersion(ComplianceConstants.DOCUMENT_TYPE_OTHER);
		ContentVersion testContentVersion3 = CaseComplianceUtilityTest.createContentVersion(ComplianceConstants.DOCUMENT_TYPE_OTHER);
		testContentVersion1 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = : testContentVersion1.Id];
		testContentVersion2 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = : testContentVersion2.Id];
		testContentVersion3 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = : testContentVersion3.Id];
		ContentDocumentLink testDocumentLink1 = CaseComplianceUtilityTest.createContentDocumentLink(ppCase.Id, testContentVersion1.ContentDocumentId);
		ContentDocumentLink testDocumentLink2 = CaseComplianceUtilityTest.createContentDocumentLink(ppCase.Id, testContentVersion2.ContentDocumentId);
		ContentDocumentLink testDocumentLink3 = CaseComplianceUtilityTest.createContentDocumentLink(ppCase.Id, testContentVersion3.ContentDocumentId);

		CaseComplianceUtility.RequestStatus requestStatus = SubmitComplianceInquiryController.getContentDocumentData(new List<Id> {testContentVersion1.ContentDocumentId, testContentVersion2.ContentDocumentId, testContentVersion3.ContentDocumentId});
		List<Object> docs = (List<Object>) requestStatus.responseMap.get('documentList');

		
		System.assertEquals(3, docs.size(), 'There should be 3 documents in the list');
	}

	@isTest
	public static void testDeleteContentDocumentList() {
		Case ppCase = CaseComplianceUtilityTest.createPricePostingCase();
		insert ppCase;
		ContentVersion testContentVersion1 = CaseComplianceUtilityTest.createContentVersion(ComplianceConstants.DOCUMENT_TYPE_OTHER);
		ContentVersion testContentVersion2 = CaseComplianceUtilityTest.createContentVersion(ComplianceConstants.DOCUMENT_TYPE_OTHER);
		ContentVersion testContentVersion3 = CaseComplianceUtilityTest.createContentVersion(ComplianceConstants.DOCUMENT_TYPE_OTHER);
		testContentVersion1 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = : testContentVersion1.Id];
		testContentVersion2 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = : testContentVersion2.Id];
		testContentVersion3 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = : testContentVersion3.Id];
		ContentDocumentLink testDocumentLink1 = CaseComplianceUtilityTest.createContentDocumentLink(ppCase.Id, testContentVersion1.ContentDocumentId);
		ContentDocumentLink testDocumentLink2 = CaseComplianceUtilityTest.createContentDocumentLink(ppCase.Id, testContentVersion2.ContentDocumentId);
		ContentDocumentLink testDocumentLink3 = CaseComplianceUtilityTest.createContentDocumentLink(ppCase.Id, testContentVersion3.ContentDocumentId);

		CaseComplianceUtility.RequestStatus requestStatus = SubmitComplianceInquiryController.deleteContentDocumentList(testContentVersion1.ContentDocumentId, new List<Id> {testContentVersion1.ContentDocumentId, testContentVersion2.ContentDocumentId, testContentVersion3.ContentDocumentId});

		List<Object> docs = (List<Object>) requestStatus.responseMap.get('documentList');
		System.assertEquals(2, docs.size());
	}

	@isTest
	public static void testRetrieveComplianceAccount() {
		CaseComplianceUtility.RequestStatus requestStatus = SubmitComplianceInquiryController.retrieveComplianceAccount();

		//List<Object> account = (List<Object>) requestStatus.responseMap.get('accountId');
		System.assertNotEquals(NULL, requestStatus.responseMap.get('accountId'), 'The compliance account should have been created');
	}

	@isTest
	public static void testInsertComplianceInquiryCase() {
		Case ppCase = CaseComplianceUtilityTest.createPricePostingCase();
		insert ppCase;
		ContentVersion testContentVersion1 = CaseComplianceUtilityTest.createContentVersion(ComplianceConstants.DOCUMENT_TYPE_OTHER);
		testContentVersion1 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = : testContentVersion1.Id];
		ContentDocumentLink testDocumentLink1 = CaseComplianceUtilityTest.createContentDocumentLink(ppCase.Id, testContentVersion1.ContentDocumentId);

		CaseComplianceUtility.RequestStatus requestStatus = SubmitComplianceInquiryController.insertComplianceInquiryCase('Illinois', 'Other', 'Details', new List<Id>{testDocumentLink1.ContentDocumentId});

		System.assertNotEquals(NULL, requestStatus.responseMap.get('case'), 'A case should exist');
	}

	@isTest
	public static void testGetStateRepresentativeEmailListStatNotInList() {
		Test.startTest();
		List<String> stateReps = SubmitComplianceInquiryController.getStateRepresentativeEmailList('State not in list');
		Test.stopTest();

		System.assertNotEquals(NULL, stateReps, 'If there is not matching state then users will be pulled from the Group complianceTeamGroup');

	}

	@isTest
	public static void testGetStateRepresentativeEmailListExistingState() {
		String coordinatorProfile = ComplianceConstants.QUOTE_REQUEST_COMPLIANCE_COORDINATOR_PROFILE;
		User illinoisUser = CaseComplianceUtilityTest.createComplianceTestUser(coordinatorProfile, 'test-compliance-user-1=beamsuntory@example.com');
		illinoisUser.Represented_States__c = 'Illinois';
		User californiaUser = CaseComplianceUtilityTest.createComplianceTestUser(coordinatorProfile, 'test-compliance-user-2=beamsuntory@example.com');
		californiaUser.Represented_States__c = 'California';
		insert new List<User> {illinoisUser, californiaUser};

		Test.startTest();
		List<String> stateReps = SubmitComplianceInquiryController.getStateRepresentativeEmailList('Illinois');
		Test.stopTest();

		System.assertNotEquals(NULL, stateReps, 'There should be users for this state');
	}



}