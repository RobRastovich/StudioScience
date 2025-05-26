@isTest (SeeAllData=false)
public class SetPriceFilingApprovalControllerTest {
	
    @testSetup static void setup() {
    	CaseComplianceUtilityTest.insertStateMetadataCustomSetting();
    }


    public static testMethod void testController(){
    	SetPriceFilingApprovalController con = new SetPriceFilingApprovalController();
    }

	public static testMethod void testGetFinalizedWorkbookFromCase(){
	    Case priceFilingCase = CaseComplianceUtilityTest.createPriceFilingCase();
	    insert priceFilingCase;

		String coordinatorProfile = ComplianceConstants.QUOTE_REQUEST_COMPLIANCE_COORDINATOR_PROFILE;
		User illinoisUser = CaseComplianceUtilityTest.createComplianceTestUser(coordinatorProfile, 'test-compliance-user-1=beamsuntory@example.com');
		illinoisUser.Represented_States__c = 'Illinois';
		insert new List<User>{illinoisUser};

		ContentVersion finalizedWorkbook;
		System.runAs(illinoisUser){
	    	finalizedWorkbook = CaseComplianceUtilityTest.createContentVersion('Finalized Workbook');
		}

	    finalizedWorkbook = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: finalizedWorkbook.Id];
	    CaseComplianceUtilityTest.createContentDocumentLink(priceFilingCase.Id, finalizedWorkbook.ContentDocumentId);

	    Test.startTest();

	    SetPriceFilingApprovalController.getFinalizedWorkbookFromCase(priceFilingCase.Id);

	    Test.stopTest();
	}
	
	public static testMethod void testGetFinalizedWorkbookFromCaseNullId(){
	    Test.startTest();

	    SetPriceFilingApprovalController.getFinalizedWorkbookFromCase(null);

	    Test.stopTest();
	}

	public static testMethod void testGetFinalizedWorkbookFromCaseNoAttachment(){
	    Case priceFilingCase = CaseComplianceUtilityTest.createPriceFilingCase();
	    insert priceFilingCase;

	    Test.startTest();

	    SetPriceFilingApprovalController.getFinalizedWorkbookFromCase(priceFilingCase.Id);

	    Test.stopTest();
	}


	public static testMethod void testRecordResponseToCaseApproved(){
		String sysAdminProfile = ComplianceConstants.SYSTEM_ADMINISTRATOR_PROFILE;
		User noStateUser = CaseComplianceUtilityTest.createComplianceTestUser(sysAdminProfile, 'test-compliance-user-1=beamsuntory@example.com');
		noStateUser.Represented_States__c = '';
		insert noStateUser;
		Case priceFilingCase;
		System.runAs(noStateUser){
			priceFilingCase = CaseComplianceUtilityTest.createPriceFilingCase();
			insert priceFilingCase;			
		}
		
		Test.startTest();
		System.debug(LoggingLevel.INFO, SetPriceFilingApprovalController.recordResponseToCase(priceFilingCase.Id, 'approved', 'description'));
		Test.stopTest();
	}

	public static testMethod void testRecordResponseToCaseRejected(){
		String sysAdminProfile = ComplianceConstants.SYSTEM_ADMINISTRATOR_PROFILE;
		User noStateUser = CaseComplianceUtilityTest.createComplianceTestUser(sysAdminProfile, 'test-compliance-user-1=beamsuntory@example.com');
		noStateUser.Represented_States__c = '';
		insert noStateUser;
		Case priceFilingCase;
		System.runAs(noStateUser){
			priceFilingCase = CaseComplianceUtilityTest.createPriceFilingCase();
			insert priceFilingCase;			
		}
		
		Test.startTest();
		System.debug(LoggingLevel.INFO, SetPriceFilingApprovalController.recordResponseToCase(priceFilingCase.Id, 'rejected', 'description'));
		Test.stopTest();
	}

	public static testMethod void testRecordResponseToCaseNullResponse(){
		String sysAdminProfile = ComplianceConstants.SYSTEM_ADMINISTRATOR_PROFILE;
		User noStateUser = CaseComplianceUtilityTest.createComplianceTestUser(sysAdminProfile, 'test-compliance-user-1=beamsuntory@example.com');
		noStateUser.Represented_States__c = '';
		insert noStateUser;
		Case priceFilingCase;
		System.runAs(noStateUser){
			priceFilingCase = CaseComplianceUtilityTest.createPriceFilingCase();
			insert priceFilingCase;			
		}
		
		Test.startTest();
		System.debug(LoggingLevel.INFO, SetPriceFilingApprovalController.recordResponseToCase(priceFilingCase.Id, null, 'description'));
		Test.stopTest();
	}

	public static testMethod void testRecordResponseToCaseNullId(){
		Test.startTest();
		System.debug(LoggingLevel.INFO, SetPriceFilingApprovalController.recordResponseToCase(null, 'approved', 'description'));
		Test.stopTest();
	}

	public static testMethod void testRecordResponseToCaseException(){
		String sysAdminProfile = ComplianceConstants.SYSTEM_ADMINISTRATOR_PROFILE;
		User noStateUser = CaseComplianceUtilityTest.createComplianceTestUser(sysAdminProfile, 'test-compliance-user-1=beamsuntory@example.com');
		noStateUser.Represented_States__c = '';
		insert noStateUser;
		Case priceFilingCase;
		System.runAs(noStateUser){
			priceFilingCase = CaseComplianceUtilityTest.createPriceFilingCase();
			insert priceFilingCase;
			priceFilingCase.State_Manager_Email__c = null;
			update priceFilingCase;
		}
		
		Test.startTest();
		System.debug(LoggingLevel.INFO, SetPriceFilingApprovalController.recordResponseToCase(priceFilingCase.Id, 'approved', 'description'));
		Test.stopTest();
	}

}