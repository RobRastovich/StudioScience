@isTest (SeeAllData=false)
public class SetItemControllerTest {

    @testSetup static void setup() {
    	CaseComplianceUtilityTest.insertStateMetadataCustomSetting();
    }

    public static testMethod void testConstructor(){
    	SetItemController con = new SetItemController();
    }

	public static testMethod void testGetRelatedQuoteRequests(){
		Case qrCase = CaseComplianceUtilityTest.createQuoteRequestCase('State Contact');
		insert qrCase;

		List<Quote_Request__c> qrList = new List<Quote_Request__c>();
		for(Integer i = 0; i < 5; i++){
			qrList.add(CaseComplianceUtilityTest.createQuoteRequest(qrCase.Id));
		}
		insert qrList;

		Test.startTest();

		CaseComplianceUtility.RequestStatus request = SetItemController.getRelatedQuoteRequests(qrCase.Id);
		System.assertEquals(true, request.success, 'The request should have been successful.');
		System.assertEquals(null, request.message, 'Because the request was successful, there should be no error message.');
		System.assertEquals(qrList.size(), ((Map<Id, Quote_Request__c>) request.responseMap.get('quoteRequestMap')).size(), 
								'There should be an identical number of Quote Requests as were returned.');
		
		Test.stopTest();
	}

	public static testMethod void testGetRelatedQuoteRequestsNullId(){

		Test.startTest();

		CaseComplianceUtility.RequestStatus request = SetItemController.getRelatedQuoteRequests(null);
		System.assertEquals(false, request.success, 'The request should have been unsuccessful.');
		System.assertNotEquals(null, request.message, 'Because the request was unsuccessful, there should be an error message.');

		Test.stopTest();
	}

	public static testMethod void testGetRelatedQuoteRequestsNoQuotes(){
		Case qrCase = CaseComplianceUtilityTest.createQuoteRequestCase('State Contact');
		insert qrCase;

		Test.startTest();

		CaseComplianceUtility.RequestStatus request = SetItemController.getRelatedQuoteRequests(qrCase.Id);
		System.assertEquals(false, request.success, 'The request should have been unsuccessful.');
		System.assertNotEquals(null, request.message, 'Because the request was unsuccessful, there should be an error message.');
				
		Test.stopTest();
	}

	public static testMethod void testGetCurrentCase(){
		Case qrCase = CaseComplianceUtilityTest.createQuoteRequestCase('State Contact');
		insert qrCase;

		Test.startTest();

		CaseComplianceUtility.RequestStatus request = SetItemController.getCurrentCase(qrCase.Id);
		System.assertEquals(true, request.success, 'The request should have been successful.');
		System.assertEquals(null, request.message, 'Because the request was successful, there should be no error message.');
		Case responseCase = (Case) request.responseMap.get('case');
		System.assertEquals(qrCase.Id, responseCase.Id, 'The Id of this Case should be identical to the one stored.');

		Test.stopTest();
	}

	public static testMethod void testGetCurrentCaseNullId(){
		Test.startTest();

		CaseComplianceUtility.RequestStatus request = SetItemController.getCurrentCase(null);
		System.assertEquals(false, request.success, 'The request should have been unsuccessful.');
		System.assertNotEquals(null, request.message, 'Because the request was unsuccessful, there should be an error message.');
		System.assertEquals(false, request.responseMap.containsKey('case'), 'There should be no key "case" in the map, as the Case was not retrieved.');
		
		Test.stopTest();
	}

	public static testMethod void testGetUnavailabilityReasonPicklistValues(){
		Test.startTest();

		List<String> picklistValues = SetItemController.getUnavailabilityReasonPicklistValues();
		String itemSizeAPIName = ComplianceConstants.QUOTE_REQUEST_UNAVAILABILITY_REASON_FIELD_API_NAME;
		List<String> optionLabels = new List<String>();
		Map<String, Schema.SObjectField> fieldMap = Quote_Request__c.getSObjectType().getDescribe().fields.getMap();
		List<Schema.PicklistEntry> entryValues = fieldMap.get(itemSizeAPIName).getDescribe().getPickListValues();
		Set<String> picklistValueSet = new Set<String>();
		
		for(Schema.PicklistEntry entry: entryValues){
			picklistValueSet.add(entry.getLabel());
		}

		for(String val: picklistValues){
			System.assert(picklistValueSet.contains(val));
		}

		Test.stopTest();
	}

	public static testMethod void testUpdateRelatedQuoteRequestsPriceNeededFailedEmail(){
		Case qrCase = CaseComplianceUtilityTest.createQuoteRequestCase('State Contact');
		insert qrCase;

		List<Quote_Request__c> qrList = new List<Quote_Request__c>();
		for(Integer i = 0; i < 5; i++){
			Quote_Request__c qr = CaseComplianceUtilityTest.createQuoteRequest(qrCase.Id);
			qr.Price_Needed__c = 'Yes';
			qrList.add(qr);
		}
		insert qrList;
		CaseComplianceUtility.RequestStatus relatedRequest = SetItemController.getRelatedQuoteRequests(qrCase.Id);
		Map<Id, Quote_Request__c> qrMap = (Map<Id, Quote_Request__c>) relatedRequest.responseMap.get('quoteRequestMap');

		Test.startTest();
		
		System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should have been sent yet.');
		CaseComplianceUtility.RequestStatus updateRequest = SetItemController.updateRelatedQuoteRequests(qrMap, qrCase.Id);
		System.assertEquals(0, Limits.getEmailInvocations(), 'SendEmail should fail, owner is a group.');

		Test.stopTest();
	}

	public static testMethod void testUpdateRelatedQuoteRequestsPriceNeededWithEmail(){
		String sysAdminProfile = ComplianceConstants.SYSTEM_ADMINISTRATOR_PROFILE;
		User noStateUser = CaseComplianceUtilityTest.createComplianceTestUser(sysAdminProfile, 'test-compliance-user-1=beamsuntory@example.com');
		noStateUser.Represented_States__c = '';
		insert noStateUser;

		Case qrCase = CaseComplianceUtilityTest.createQuoteRequestCase('State Contact');
		insert qrCase;

		qrCase.OwnerId = noStateUser.Id;
		update qrCase;

		List<Quote_Request__c> qrList = new List<Quote_Request__c>();
		for(Integer i = 0; i < 5; i++){
			Quote_Request__c qr = CaseComplianceUtilityTest.createQuoteRequest(qrCase.Id);
			qr.Price_Needed__c = 'Yes';
			qrList.add(qr);
		}
		insert qrList;
		CaseComplianceUtility.RequestStatus relatedRequest = SetItemController.getRelatedQuoteRequests(qrCase.Id);
		Map<Id, Quote_Request__c> qrMap = (Map<Id, Quote_Request__c>) relatedRequest.responseMap.get('quoteRequestMap');

		Test.startTest();
		
		System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should have been sent yet.');
		CaseComplianceUtility.RequestStatus updateRequest = SetItemController.updateRelatedQuoteRequests(qrMap, qrCase.Id);
		System.assertEquals(1, Limits.getEmailInvocations(), 'SendEmail should not fail, owner is a user.');

		Test.stopTest();
	}

	public static testMethod void testUpdateRelatedQuoteRequestsNoPriceNeededWithEmail(){
		String sysAdminProfile = ComplianceConstants.SYSTEM_ADMINISTRATOR_PROFILE;
		User noStateUser = CaseComplianceUtilityTest.createComplianceTestUser(sysAdminProfile, 'test-compliance-user-1=beamsuntory@example.com');
		noStateUser.Represented_States__c = '';
		insert noStateUser;

		Case qrCase = CaseComplianceUtilityTest.createQuoteRequestCase('State Contact');
		insert qrCase;

		qrCase.OwnerId = noStateUser.Id;
		update qrCase;

		List<Quote_Request__c> qrList = new List<Quote_Request__c>();
		for(Integer i = 0; i < 5; i++){
			Quote_Request__c qr = CaseComplianceUtilityTest.createQuoteRequest(qrCase.Id);
			qr.Price_Needed__c = 'No';
			qrList.add(qr);
		}
		insert qrList;
		CaseComplianceUtility.RequestStatus relatedRequest = SetItemController.getRelatedQuoteRequests(qrCase.Id);
		Map<Id, Quote_Request__c> qrMap = (Map<Id, Quote_Request__c>) relatedRequest.responseMap.get('quoteRequestMap');

		Test.startTest();
		
		System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should have been sent yet.');
		CaseComplianceUtility.RequestStatus updateRequest = SetItemController.updateRelatedQuoteRequests(qrMap, qrCase.Id);
		System.assertEquals(1, Limits.getEmailInvocations(), 'SendEmail should not fail, owner is a user.');

		Test.stopTest();
	}

	public static testMethod void testUpdateQuoteRequestsHasUnpriced(){
		String sysAdminProfile = ComplianceConstants.SYSTEM_ADMINISTRATOR_PROFILE;
		User noStateUser = CaseComplianceUtilityTest.createComplianceTestUser(sysAdminProfile, 'test-compliance-user-1=beamsuntory@example.com');
		noStateUser.Represented_States__c = '';
		insert noStateUser;

		Case qrCase = CaseComplianceUtilityTest.createQuoteRequestCase('State Contact');
		insert qrCase;

		qrCase.OwnerId = noStateUser.Id;
		update qrCase;

		List<Quote_Request__c> qrList = new List<Quote_Request__c>();
		for(Integer i = 0; i < 5; i++){
			Quote_Request__c qr = CaseComplianceUtilityTest.createQuoteRequest(qrCase.Id);
			qr.Price_Needed__c = 'No';
			qrList.add(qr);
		}
		insert qrList;

		Test.startTest();

		CaseComplianceUtility.RequestStatus request = SetItemController.updateQuoteRequests(qrList, qrCase.Id, true);
		System.assertEquals(true, request.success, 'The request should have been successful.');
		System.assertEquals(null, request.message, 'Because the request was successful, there should be no error message.');

		Test.stopTest();
	}

	public static testMethod void testUpdateQuoteRequestsNoneUnpriced(){
		String sysAdminProfile = ComplianceConstants.SYSTEM_ADMINISTRATOR_PROFILE;
		User noStateUser = CaseComplianceUtilityTest.createComplianceTestUser(sysAdminProfile, 'test-compliance-user-1=beamsuntory@example.com');
		noStateUser.Represented_States__c = '';
		insert noStateUser;

		Case qrCase = CaseComplianceUtilityTest.createQuoteRequestCase('State Contact');
		insert qrCase;

		qrCase.OwnerId = noStateUser.Id;
		update qrCase;

		List<Quote_Request__c> qrList = new List<Quote_Request__c>();
		for(Integer i = 0; i < 5; i++){
			Quote_Request__c qr = CaseComplianceUtilityTest.createQuoteRequest(qrCase.Id);
			qr.Price_Needed__c = 'No';
			qrList.add(qr);
		}
		insert qrList;

		Test.startTest();

		CaseComplianceUtility.RequestStatus request = SetItemController.updateQuoteRequests(qrList, qrCase.Id, false);
		qrCase = [SELECT Id, Status, Approval_Status__c, Approval_Date__c FROM Case WHERE Id =: qrCase.Id];
		System.assertEquals('Waiting for Submission', qrCase.Status, 'This Case should be in the "Waiting for Submission" status.');
		System.assertEquals('Approved', qrCase.Approval_Status__c, 'This Case should be approved.');
		System.assertEquals(System.today(), qrCase.Approval_Date__c, 'This Case should have an approval date of today.');
		System.assertEquals(true, request.success, 'The request should have been successful.');
		System.assertEquals(null, request.message, 'Because the request was successful, there should be no error message.');

		Test.stopTest();
	}

	public static testMethod void testUpdateQuoteRequestsNullId(){
		Case qrCase = CaseComplianceUtilityTest.createQuoteRequestCase('State Contact');
		insert qrCase;

		List<Quote_Request__c> qrList = new List<Quote_Request__c>();
		for(Integer i = 0; i < 5; i++){
			Quote_Request__c qr = CaseComplianceUtilityTest.createQuoteRequest(qrCase.Id);
			qr.Price_Needed__c = 'No';
			qrList.add(qr);
		}
		insert qrList;

		Test.startTest();

		CaseComplianceUtility.RequestStatus request = SetItemController.updateQuoteRequests(qrList, null, false);
		System.assertEquals(false, request.success, 'The request should have been unsuccessful.');
		System.assertNotEquals(null, request.message, 'Because the request was unsuccessful, there should be an error message.');

		Test.stopTest();
	}

}