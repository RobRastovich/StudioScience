@isTest (SeeAllData=false)
public class SetDiscountsApprovalControllerTest {


    @testSetup static void setup() {
    	CaseComplianceUtilityTest.insertStateMetadataCustomSetting();
    }


    public static testMethod void testController(){
    	SetDiscountsApprovalController con = new SetDiscountsApprovalController();
    }

	public static testMethod void testGetDiscountInitNoAttachment(){
		Case discountCase = CaseComplianceUtilityTest.createDiscountCase();
		insert discountCase;


		Test.startTest();

		discountCase = [SELECT Id, Approval_Status__c FROM Case WHERE Id =: discountCase.Id];

		CaseComplianceUtility.RequestStatus request = SetDiscountsApprovalController.getDiscountInit(discountCase.Id);
		Map<String, Object> responseMap = request.responseMap;
    	System.assertEquals(false, request.success, 'The request should have been unsuccessful.');
		System.assertNotEquals(null, request.message, 'Because the request was unsuccessful, there should be an error message.');

		System.assertEquals(false, responseMap.containsKey('versionId'), 'Because the request was unsuccessful, the map should not contain the "versionId" key.');
		System.assertEquals(false, responseMap.containsKey('documentId'), 'Because the request was unsuccessful, the map should not contain the "documentId" key.');
		System.assertEquals(false, responseMap.containsKey('documentStatus'), 'Because the request was unsuccessful, the map should not contain the "documentStatus" key.');
		System.assertEquals(false, responseMap.containsKey('approvalStatus'), 'Because the request was unsuccessful, the map should not contain the "approvalStatus" key.');
		
		Test.stopTest();
	}

	public static testMethod void testGetDiscountInit(){
		Case discountCase = CaseComplianceUtilityTest.createDiscountCase();
		insert discountCase;

		String coordinatorProfile = ComplianceConstants.QUOTE_REQUEST_COMPLIANCE_COORDINATOR_PROFILE;
		User illinoisUser = CaseComplianceUtilityTest.createComplianceTestUser(coordinatorProfile, 'test-compliance-user-1=beamsuntory@example.com');
		illinoisUser.Represented_States__c = 'Illinois';
		insert new List<User>{illinoisUser};

		ContentVersion discountsDocument;
		System.runAs(illinoisUser){
		    discountsDocument = CaseComplianceUtilityTest.createContentVersion('Discounts Document');
		}

	    discountsDocument = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: discountsDocument.Id];
	    CaseComplianceUtilityTest.createContentDocumentLink(discountCase.Id, discountsDocument.ContentDocumentId);

		Test.startTest();
		discountCase = [SELECT Id, Approval_Status__c FROM Case WHERE Id =: discountCase.Id];

		CaseComplianceUtility.RequestStatus request = SetDiscountsApprovalController.getDiscountInit(discountCase.Id);
		Map<String, Object> responseMap = request.responseMap;
    	System.assertEquals(true, request.success, 'The request should have been successful.');
		System.assertEquals(null, request.message, 'Because the request was successful, there should be no error message.');

		System.assertEquals(true, responseMap.containsKey('versionId'), 'Because the request was successful, the map should contain the "versionId" key.');
		Id contentVersionId = (Id) responseMap.get('versionId');
		System.assertEquals(discountsDocument.Id, contentVersionId, 'The Id of both Content Versions should be identical.');
		
		System.assertEquals(true, responseMap.containsKey('documentId'), 'Because the request was successful, the map should contain the "documentId" key.');
		Id contentDocumentId = (Id) responseMap.get('documentId');
		System.assertEquals(discountsDocument.ContentDocumentId, contentDocumentId, 'The Id of both Content Documents should be identical.');

		System.assertEquals(true, responseMap.containsKey('documentStatus'), 'Because the request was successful, the map should contain the "documentStatus" key.');
		String documentStatus = (String) responseMap.get('documentStatus');
		System.assertEquals(null, documentStatus, 'The Document Status should be null, as it has not been approved or rejected yet.');

		System.assertEquals(true, responseMap.containsKey('approvalStatus'), 'Because the request was successful, the map should contain the "approvalStatus" key.');
		String approvalStatus = (String) responseMap.get('approvalStatus');
		System.assertEquals(discountCase.Approval_Status__c, approvalStatus, 'The Case Approval Status should be identical.');

		Test.stopTest();
	}

	public static testMethod void testRecordApprovalStatusApproved(){
		String coordinatorProfile = ComplianceConstants.QUOTE_REQUEST_COMPLIANCE_COORDINATOR_PROFILE;
		User illinoisUser = CaseComplianceUtilityTest.createComplianceTestUser(coordinatorProfile, 'test-compliance-user-1=beamsuntory@example.com');
		illinoisUser.Represented_States__c = 'Illinois';
		insert new List<User>{illinoisUser};

		Case discountCase;
		System.runAs(illinoisUser){
			discountCase = CaseComplianceUtilityTest.createDiscountCase();
			insert discountCase;
		}


	    ContentVersion discountsDocument = CaseComplianceUtilityTest.createContentVersion('Discounts Document');
	    discountsDocument = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: discountsDocument.Id];
	    CaseComplianceUtilityTest.createContentDocumentLink(discountCase.Id, discountsDocument.ContentDocumentId);


		Test.startTest();

		discountCase = [SELECT Id, Approved__c, Approval_Date__c, Approval_Status__c, Status, Document_Change_Description__c FROM Case WHERE Id =: discountCase.Id];
		System.assertEquals(false, discountCase.Approved__c, 'This case should not be marked approved yet.');
		System.assertEquals(null, discountCase.Approval_Date__c, 'This case should not be marked approved yet and should not have an Approval Date.');
		System.assertEquals(null, discountCase.Approval_Status__c, 'This case should not have an Approval Status yet.');
		System.assertEquals('New', discountCase.Status, 'This case should have the following status: "New".');


		CaseComplianceUtility.RequestStatus request = SetDiscountsApprovalController.recordApprovalStatus(discountCase.Id, discountsDocument.Id, true, '');
    	System.assertEquals(true, request.success, 'The request should have been successful.');
		System.assertEquals(null, request.message, 'Because the request was successful, there should be no error message.');
		
		discountCase = [SELECT Id, Approved__c, Approval_Date__c, Approval_Status__c, Status, Document_Change_Description__c FROM Case WHERE Id =: discountCase.Id];
		System.assertEquals(true, discountCase.Approved__c, 'This case should not be marked approved yet.');
		System.assertEquals(System.today(), discountCase.Approval_Date__c, 'This case should not be marked approved yet and should not have an Approval Date.');
		System.assertEquals('Approved', discountCase.Approval_Status__c, 'This case should not have an Approval Status yet.');
		System.assertEquals('Waiting for Submission', discountCase.Status, 'This case should have the following status: "Waiting for Submission".');

		discountsDocument = [SELECT Id, Document_Status__c FROM ContentVersion WHERE Id =: discountsDocument.Id];
		System.assertEquals('Approved', discountsDocument.Document_Status__c, 'This document should be marked approved.');

		System.assertEquals(1, Limits.getEmailInvocations(), 'Discount Approval Changed email should have been sent.');


		Test.stopTest();
	}

	public static testMethod void testRecordApprovalStatusRejected(){
		String coordinatorProfile = ComplianceConstants.QUOTE_REQUEST_COMPLIANCE_COORDINATOR_PROFILE;
		User illinoisUser = CaseComplianceUtilityTest.createComplianceTestUser(coordinatorProfile, 'test-compliance-user-1=beamsuntory@example.com');
		illinoisUser.Represented_States__c = 'Illinois';
		insert new List<User>{illinoisUser};

		Case discountCase;
		System.runAs(illinoisUser){
			discountCase = CaseComplianceUtilityTest.createDiscountCase();
			insert discountCase;
		}


	    ContentVersion discountsDocument = CaseComplianceUtilityTest.createContentVersion('Discounts Document');
	    discountsDocument = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: discountsDocument.Id];
	    CaseComplianceUtilityTest.createContentDocumentLink(discountCase.Id, discountsDocument.ContentDocumentId);


		Test.startTest();

		discountCase = [SELECT Id, Approved__c, Approval_Date__c, Approval_Status__c, Status, Document_Change_Description__c FROM Case WHERE Id =: discountCase.Id];
		System.assertEquals(false, discountCase.Approved__c, 'This case should not be marked approved yet.');
		System.assertEquals(null, discountCase.Approval_Date__c, 'This case should not be marked approved yet and should not have an Approval Date.');
		System.assertEquals(null, discountCase.Approval_Status__c, 'This case should not have an Approval Status yet.');
		System.assertEquals('New', discountCase.Status, 'This case should have the following status: "New".');


		CaseComplianceUtility.RequestStatus request = SetDiscountsApprovalController.recordApprovalStatus(discountCase.Id, discountsDocument.Id, false, 'description');
    	System.assertEquals(true, request.success, 'The request should have been successful.');
		System.assertEquals(null, request.message, 'Because the request was successful, there should be no error message.');
		
		discountsDocument = [SELECT Id, Document_Status__c FROM ContentVersion WHERE Id =: discountsDocument.Id];
		System.assertEquals('Rejected', discountsDocument.Document_Status__c, 'This document should be marked rejected.');

		System.assertEquals(1, Limits.getEmailInvocations(), 'Discount Approval Changed email should have been sent.');

		Test.stopTest();
	}

	public static testMethod void testRecordApprovalStatusNullContentVersionId(){
		String coordinatorProfile = ComplianceConstants.QUOTE_REQUEST_COMPLIANCE_COORDINATOR_PROFILE;
		User illinoisUser = CaseComplianceUtilityTest.createComplianceTestUser(coordinatorProfile, 'test-compliance-user-1=beamsuntory@example.com');
		illinoisUser.Represented_States__c = 'Illinois';
		insert new List<User>{illinoisUser};

		Case discountCase;
		System.runAs(illinoisUser){
			discountCase = CaseComplianceUtilityTest.createDiscountCase();
			insert discountCase;
		}

		Test.startTest();

		discountCase = [SELECT Id, Approved__c, Approval_Date__c, Approval_Status__c, Status, Document_Change_Description__c FROM Case WHERE Id =: discountCase.Id];
		System.assertEquals(false, discountCase.Approved__c, 'This case should not be marked approved yet.');
		System.assertEquals(null, discountCase.Approval_Date__c, 'This case should not be marked approved yet and should not have an Approval Date.');
		System.assertEquals(null, discountCase.Approval_Status__c, 'This case should not have an Approval Status yet.');
		System.assertEquals('New', discountCase.Status, 'This case should have the following status: "New".');

		CaseComplianceUtility.RequestStatus request = SetDiscountsApprovalController.recordApprovalStatus(discountCase.Id, null, true, 'description');
    	System.assertEquals(false, request.success, 'The request should have been unsuccessful.');
		System.assertNotEquals(null, request.message, 'Because the request was unsuccessful, there should be an error message.');

		Test.stopTest();
	}

}