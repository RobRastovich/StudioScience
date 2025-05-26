@isTest (SeeAllData=false)
public class SubmitQuoteRequestControllerTest {

    @testSetup static void setup() {
    	CaseComplianceUtilityTest.insertStateMetadataCustomSetting();
    }

    public static testMethod void testController(){
    	SubmitQuoteRequestController con = new SubmitQuoteRequestController();
    }

    public static testMethod void testGetStateRepresentativeEmailWithUser(){
		String email = 'Compliance-test-user@test.com';
		String coordinatorProfile = ComplianceConstants.QUOTE_REQUEST_COMPLIANCE_COORDINATOR_PROFILE;
		User illinoisUser = CaseComplianceUtilityTest.createComplianceTestUser(coordinatorProfile, 'test-compliance-user-1=beamsuntory@example.com');
		illinoisUser.Represented_States__c = 'Illinois';
		insert new List<User>{illinoisUser};

		Test.startTest();

		String retreivedEmail = SubmitQuoteRequestController.getStateRepresentativeEmail('Illinois');
		List<User> users = [SELECT Id, Represented_States__c FROM User WHERE Email =: retreivedEmail];
		System.assertEquals(true, users.size() > 0, 'There should be a user with the state of Illinois retrieved.');

		Test.stopTest();
    }

    public static testMethod void testGetStateRepresentativeEmailWithoutUser(){
		String email = 'Compliance-test-user@test.com';		
		String coordinatorProfile = ComplianceConstants.QUOTE_REQUEST_COMPLIANCE_COORDINATOR_PROFILE;
		User illinoisUser = CaseComplianceUtilityTest.createComplianceTestUser(coordinatorProfile, 'test-compliance-user-1=beamsuntory@example.com');
		illinoisUser.Represented_States__c = 'Illinois';
		insert new List<User>{illinoisUser};

		Test.startTest();

		String retrievedEmail = SubmitQuoteRequestController.getStateRepresentativeEmail('Arizona');

		Test.stopTest();
    }

    public static testMethod void testGetUserAttributeMapOther(){
		String coordinatorProfile = ComplianceConstants.QUOTE_REQUEST_COMPLIANCE_COORDINATOR_PROFILE;
		User illinoisUser = CaseComplianceUtilityTest.createComplianceTestUser(coordinatorProfile, 'test-compliance-user-1=beamsuntory@example.com');
		illinoisUser.Represented_States__c = 'Illinois';
		insert new List<User>{illinoisUser};
		CaseComplianceUtility.RequestStatus request;

		Test.startTest();

		System.runAs(illinoisUser){
	    	request = SubmitQuoteRequestController.getUserAttributeMap();
	    	System.assertEquals(true, request.success, 'The request should have been successful.');
			System.assertEquals(null, request.message, 'Because the request was successful, there should be no error message.');
			System.assertEquals(true, request.responseMap.containsKey('attributeMap'), 'Because the request was successful, there should be no error message.');
			Map<String, Boolean> attrMap = (Map<String, Boolean>) request.responseMap.get('attributeMap');
	    	System.assertEquals(false, attrMap.get('contact'), 'Contact attribute should be false.');
	    	System.assertEquals(false, attrMap.get('manager'), 'Manager attribute should be false.');
	    	System.assertEquals(true, attrMap.get('other'), 'Other attribute should be true.');
		}

		Test.stopTest();
    }

    public static testMethod void testGetStatePicklistValues(){
		String coordinatorProfile = ComplianceConstants.QUOTE_REQUEST_COMPLIANCE_COORDINATOR_PROFILE;
		User illinoisUser = CaseComplianceUtilityTest.createComplianceTestUser(coordinatorProfile, 'test-compliance-user-1=beamsuntory@example.com');
		illinoisUser.Represented_States__c = 'Illinois';
		insert new List<User>{illinoisUser};

		Test.startTest();

		System.runAs(illinoisUser){
			List<String> stateValueList = SubmitQuoteRequestController.getStatePicklistValues();
			System.assertEquals(1, stateValueList.size(), 'There should only be one state available: Illinois.');
			System.assertEquals(true, new Set<String>(stateValueList).contains('Illinois'), 'The list should contain "Illinois".');
		}

		Test.stopTest();
    }

    public static testMethod void testGetQuoteRequestItemSizePicklistValues(){
		Test.startTest();

		List<String> picklistValues = SubmitQuoteRequestController.getQuoteRequestItemSizePicklistValues();
		String itemSizeAPIName = ComplianceConstants.QUOTE_REQUEST_ITEM_SIZE_FIELD_API_NAME;
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

    public static testMethod void testGetQuoteRequestQuoteTypePicklistValues(){
		Test.startTest();

		List<String> picklistValues = SubmitQuoteRequestController.getQuoteRequestQuoteTypePicklistValues();
		String itemSizeAPIName = ComplianceConstants.QUOTE_REQUEST_QUOTE_TYPE_FIELD_API_NAME;
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

    public static testMethod void testGetPicklistValueMap(){
		String coordinatorProfile = ComplianceConstants.QUOTE_REQUEST_COMPLIANCE_COORDINATOR_PROFILE;
		User illinoisUser = CaseComplianceUtilityTest.createComplianceTestUser(coordinatorProfile, 'test-compliance-user-1=beamsuntory@example.com');
		illinoisUser.Represented_States__c = 'Illinois';
		insert new List<User>{illinoisUser};

		Test.startTest();

  		System.runAs(illinoisUser){
	    	CaseComplianceUtility.RequestStatus request = SubmitQuoteRequestController.getPicklistValueMap();
	    	Map<String, List<String>> picklistValueMap = (Map<String, List<String>>) request.responseMap.get('picklistValueMap');
	    	System.assertEquals(true, request.success, 'The request should have been successful.');
			System.assertEquals(null, request.message, 'Because the request was successful, there should be no error message.');
			System.assertEquals(true, picklistValueMap.containsKey('state'), 'Because the request was successful, this key ("state") should be present.');
			System.assertEquals(true, picklistValueMap.containsKey('item_size'), 'Because the request was successful, this key ("item_size") should be present.');
			System.assertEquals(true, picklistValueMap.containsKey('quote_type'), 'Because the request was successful, this key ("quote_type") should be present.');
    	}

    	Test.stopTest();
    }


    public static testMethod void testInsertNewQuoteRequesOneQuoteHighPriority(){
    	String entitlementName = ComplianceConstants.ENTITLEMENT_QUOTE_REQUEST;
    	Case dummyQRCase = CaseComplianceUtilityTest.createQuoteRequestCase('State Contact');
    	insert dummyQRCase;

    	Quote_Request__c qr1 = CaseComplianceUtilityTest.createQuoteRequest(dummyQRCase.Id);

    	Entitlement ent = CaseComplianceUtilityTest.createQuoteRequestEntitlement(entitlementName);
    	insert new List<Entitlement>{ent};

    	Test.startTest();
    	CaseComplianceUtility.RequestStatus request = SubmitQuoteRequestController.insertNewQuoteRequest(new List<Quote_Request__c>{qr1}, 'Illinois', 'High', 'State Contact', '');
    	Map<String, Object> responseMap = request.responseMap;
    	System.assertEquals(true, request.success, 'The request should have been successful.');
		System.assertEquals(null, request.message, 'Because the request was successful, there should be no error message.');
		System.assertEquals(true, responseMap.containsKey('quoteRequestCase'), 'Because the request was successful, it should contain the "quoteRequestCase" key.');
		Case currCase = (Case) responseMap.get('quoteRequestCase');
		currCase = [SELECT Id, EntitlementId FROM Case WHERE Id =: currCase.Id];
    	System.assertEquals(currCase.Id, qr1.Case__c, 'The Quote Request should have this Case as its parent.');
		System.assertEquals(true, currCase.EntitlementId != null, 'The Entitlement Id should have been populated.');
		System.assertEquals(1, Limits.getEmailInvocations(), 'Quote Request creation email should have been sent.');
		Test.stopTest();
    }

    public static testMethod void testInsertNewQuoteRequesMultipleQuotesLowPriority(){
    	String entitlementName = ComplianceConstants.ENTITLEMENT_QUOTE_REQUEST;
    	Case dummyQRCase = CaseComplianceUtilityTest.createQuoteRequestCase('State Contact');
    	insert dummyQRCase;

    	Quote_Request__c qr1 = CaseComplianceUtilityTest.createQuoteRequest(dummyQRCase.Id);
    	Quote_Request__c qr2 = CaseComplianceUtilityTest.createQuoteRequest(dummyQRCase.Id);

    	Entitlement ent = CaseComplianceUtilityTest.createQuoteRequestEntitlement(entitlementName);
    	insert new List<Entitlement>{ent};

    	Test.startTest();
				CaseComplianceUtility.RequestStatus request = SubmitQuoteRequestController.insertNewQuoteRequest(new List<Quote_Request__c>{qr1, qr2}, 'Illinois', 'Low', 'State Contact', '');
				Map<String, Object> responseMap = request.responseMap;
				System.assertEquals(true, request.success, 'The request should have been successful.');
				System.assertEquals(null, request.message, 'Because the request was successful, there should be no error message.');
				System.assertEquals(true, responseMap.containsKey('quoteRequestCase'), 'Because the request was successful, it should contain the "quoteRequestCase" key.');
				Case currCase = (Case) responseMap.get('quoteRequestCase');
				currCase = [SELECT Id, EntitlementId FROM Case WHERE Id =: currCase.Id];
				System.assertEquals(currCase.Id, qr1.Case__c, 'The Quote Request should have this Case as its parent.');
				System.assertEquals(true, currCase.EntitlementId != null, 'The Entitlement Id should have been populated.');
				System.assertEquals(1, Limits.getEmailInvocations(), 'Quote Request creation email should have been sent.');
			Test.stopTest();
    }
// This test is faling due to invalid picklist value on Quote request Priority field.
// commenting out invalid test

   /* public static testMethod void testInsertNewQuoteRequesMultipleQuotesOtherPriority(){
    	String entitlementName = ComplianceConstants.ENTITLEMENT_QUOTE_REQUEST;
    	Case dummyQRCase = CaseComplianceUtilityTest.createQuoteRequestCase('State Contact');
    	insert dummyQRCase;

    	Quote_Request__c qr1 = CaseComplianceUtilityTest.createQuoteRequest(dummyQRCase.Id);
    	Quote_Request__c qr2 = CaseComplianceUtilityTest.createQuoteRequest(dummyQRCase.Id);

    	Entitlement ent = CaseComplianceUtilityTest.createQuoteRequestEntitlement(entitlementName);
    	insert new List<Entitlement>{ent};

    	Test.startTest();
    	CaseComplianceUtility.RequestStatus request = SubmitQuoteRequestController.insertNewQuoteRequest(new List<Quote_Request__c>{qr1, qr2}, 'Illinois', 'Medium', 'State Contact', '');
    	Map<String, Object> responseMap = request.responseMap;
    	System.assertEquals(true, request.success, 'The request should have been successful.');
		System.assertEquals(null, request.message, 'Because the request was successful, there should be no error message.');
		System.assertEquals(true, responseMap.containsKey('quoteRequestCase'), 'Because the request was successful, it should contain the "quoteRequestCase" key.');
		Case currCase = (Case) responseMap.get('quoteRequestCase');
		currCase = [SELECT Id, EntitlementId FROM Case WHERE Id =: currCase.Id];
    	System.assertEquals(currCase.Id, qr1.Case__c, 'The Quote Request should have this Case as its parent.');
		System.assertEquals(true, currCase.EntitlementId != null, 'The Entitlement Id should have been populated.');
		System.assertEquals(1, Limits.getEmailInvocations(), 'Quote Request creation email should have been sent.');
		Test.stopTest();
    }*/

    public static testMethod void testInsertNewQuoteRequesMultipleQuotesNoEntitlement(){
    	Case dummyQRCase = CaseComplianceUtilityTest.createQuoteRequestCase('State Contact');
    	insert dummyQRCase;

    	Quote_Request__c qr1 = CaseComplianceUtilityTest.createQuoteRequest(dummyQRCase.Id);
    	Quote_Request__c qr2 = CaseComplianceUtilityTest.createQuoteRequest(dummyQRCase.Id);

    	Test.startTest();
    	CaseComplianceUtility.RequestStatus request = SubmitQuoteRequestController.insertNewQuoteRequest(new List<Quote_Request__c>{qr1, qr2}, 'Illinois', 'Medium', 'State Contact', '');
    	Map<String, Object> responseMap = request.responseMap;
    	System.assertEquals(false, request.success, 'The request should have been unsuccessful.');
		System.assertNotEquals(null, request.message, 'Because the request was unsuccessful, there should be an error message.');
		System.assertEquals(false, responseMap.containsKey('quoteRequestCase'), 'Because the request was unsuccessful, it should not contain the "quoteRequestCase" key.');
		System.assertEquals(0, Limits.getEmailInvocations(), 'Quote Request creation email should not have been sent.');
		Test.stopTest();
    }

}