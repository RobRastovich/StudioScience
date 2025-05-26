@isTest (SeeAllData=false)
public class ComplianceCaseAttachmentControllerTest {
    @testSetup static void setup() {
        CaseComplianceUtilityTest.insertStateMetadataCustomSetting();
    }

    public static testMethod void testGetDocumentTypePicklistValuesBrandReg(){
        Case brCase = CaseComplianceUtilityTest.createBrandRegistrationCase();
        insert brCase;

        Test.startTest();
        List<String> picklistValues = ComplianceCaseAttachmentController.getDocumentTypePicklistValues(brCase.Id);
        Set<String> docTypeSet = new Set<String>(ComplianceConstants.BR_DOC_TYPE_LIST);
        
        System.assert(docTypeSet.containsAll(picklistValues));
        Test.stopTest();
    }

    public static testMethod void testGetDocumentTypePicklistValuesSubCase(){
        Case brCase = CaseComplianceUtilityTest.createBrandRegistrationCase();
        insert brCase;

        Case subCase = CaseComplianceUtilityTest.createBrandRegistrationComplianceSubCase(brCase.Id, 'Illinois');
        insert subCase;

        Test.startTest();
        Set<String> docTypeSet = new Set<String>(ComplianceConstants.BR_SUBCASE_DOC_TYPE_LIST);
        List<String> picklistValues = ComplianceCaseAttachmentController.getDocumentTypePicklistValues(subCase.Id);

        System.assert(docTypeSet.containsAll(picklistValues));

        subCase.Status = ComplianceConstants.CASE_STATUS_WAITING_FOR_APPROVAL;
        update subCase;

        picklistValues = ComplianceCaseAttachmentController.getDocumentTypePicklistValues(subCase.Id);
        System.assert(docTypeSet.containsAll(picklistValues));

        Test.stopTest();
    }

    public static testMethod void testGetDocumentTypePicklistValuesQuoteRequest(){
        Case qrCase = CaseComplianceUtilityTest.createQuoteRequestCase('State Contact');
        insert qrCase;

        Test.startTest();
        Set<String> docTypeSet = new Set<String>(ComplianceConstants.QR_DOC_TYPE_LIST);
        List<String> picklistValues = ComplianceCaseAttachmentController.getDocumentTypePicklistValues(qrCase.Id);

        System.assert(docTypeSet.containsAll(picklistValues));
        Test.stopTest();
    }

    public static testMethod void testGetDocumentTypePicklistValuesPricePosting(){
        Case ppCase = CaseComplianceUtilityTest.createPricePostingCase();
        insert ppCase;

        Test.startTest();
        Set<String> docTypeSet = new Set<String>(ComplianceConstants.PP_DOC_TYPE_LIST);
        List<String> picklistValues = ComplianceCaseAttachmentController.getDocumentTypePicklistValues(ppCase.Id);

        System.assert(docTypeSet.containsAll(picklistValues));
        Test.stopTest();
    }

    public static testMethod void testGetDocumentTypePicklistValuesPriceFiling(){
        Case pfCase = CaseComplianceUtilityTest.createPriceFilingCase();
        insert pfCase;

        Test.startTest();
        Set<String> docTypeSet = new Set<String>(ComplianceConstants.PF_DOC_TYPE_LIST);
        List<String> picklistValues = ComplianceCaseAttachmentController.getDocumentTypePicklistValues(pfCase.Id);

        System.assert(docTypeSet.containsAll(picklistValues));
        Test.stopTest();
    }

    public static testMethod void testGetDocumentTypePicklistValuesDiscount(){
        Case discountCase = CaseComplianceUtilityTest.createDiscountCase();
        insert discountCase;

        Test.startTest();
        Set<String> docTypeSet = new Set<String>(ComplianceConstants.DISC_DOC_TYPE_LIST);
        List<String> picklistValues = ComplianceCaseAttachmentController.getDocumentTypePicklistValues(discountCase.Id);

        System.assert(docTypeSet.containsAll(picklistValues));
        Test.stopTest();
    }

    public static testMethod void testSetSelectedAttachmentFlagPriorApprovalSubCaseSubmitted(){
        String notSubmittedStatus = ComplianceConstants.CASE_STATUS_NOT_SUBMITTED;
        String waitingForApprovalStatus = ComplianceConstants.CASE_STATUS_WAITING_FOR_APPROVAL;

        Case brCase = CaseComplianceUtilityTest.createBrandRegistrationCase();
        insert brCase;

        Case subCase = CaseComplianceUtilityTest.createBrandRegistrationComplianceSubCase(brCase.Id, 'Illinois');
        insert subCase;
        subCase.State_Type__c = 'Prior Approval;';
        subCase.OwnerId = UserInfo.getUserId();
        update subCase;

        Test.startTest();
        subCase = [SELECT Id, Status, Submission_Date__c, Approval_Date__c FROM Case WHERE Id=:subCase.Id];
        System.assertEquals(notSubmittedStatus, subCase.Status, 'Status should be "Not Submitted".');
        System.assertEquals(null, subCase.Submission_Date__c, 'Case should not have a submission date yet.');
        System.assertEquals(null, subCase.Approval_Date__c, 'Case should not have an approval date yet.');
        ComplianceCaseAttachmentController.setSelectedAttachmentFlag(subCase.Id, 'Submission');
        subCase = [SELECT Id, Status, Submission_Date__c, Approval_Date__c FROM Case WHERE Id=:subCase.Id];
        System.assertEquals(waitingForApprovalStatus, subCase.Status, 'Case should be in the "Waiting for Approval" status.');
        System.assertEquals(System.today(), subCase.Submission_Date__c, 'Case should have a submission date.');
        System.assertEquals(null, subCase.Approval_Date__c, 'Case should not have an approval date, it is not yet approved.');
        Test.stopTest();
    }

    public static testMethod void testSetSelectedAttachmentFlagPriorApprovalSubCaseApproved(){
        String notSubmittedStatus = ComplianceConstants.CASE_STATUS_NOT_SUBMITTED;
        String waitingForApprovalStatus = ComplianceConstants.CASE_STATUS_WAITING_FOR_APPROVAL;
        String waitingForPostingStatus = ComplianceConstants.CASE_STATUS_WAITING_FOR_POSTING;
        String closedStatus = ComplianceConstants.CASE_STATUS_CLOSED;
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        Case brCase = CaseComplianceUtilityTest.createBrandRegistrationCase();
        insert brCase;

        Case subCase = CaseComplianceUtilityTest.createBrandRegistrationComplianceSubCase(brCase.Id, 'Illinois');
        insert subCase;
        subCase.State_Type__c = 'Prior Approval;';
        subCase.OwnerId = UserInfo.getUserId();
        update subCase;
        ComplianceCaseAttachmentController.setSelectedAttachmentFlag(subCase.Id, 'Submission');

        Test.startTest();
        subCase = [SELECT Id, Status, Submission_Date__c, Approval_Date__c FROM Case WHERE Id=:subCase.Id];
        System.assertEquals(waitingForApprovalStatus, subCase.Status, 'Status should be "Waiting for Approval".');
        System.assertEquals(System.today(), subCase.Submission_Date__c, 'Case should have a submission date of today.');
        System.assertEquals(null, subCase.Approval_Date__c, 'Case should not have an approval date yet.');
        ComplianceCaseAttachmentController.setSelectedAttachmentFlag(subCase.Id, 'Approval');
        subCase = [SELECT Id, Status, Submission_Date__c, Approval_Date__c FROM Case WHERE Id=:subCase.Id];
        //System.assertEquals(closedStatus, subCase.Status, 'Case should be in the "Closed" status.');
        //System.assertEquals(System.today(), subCase.Approval_Date__c, 'Case should not have a posting date.');
        Test.stopTest();
    }

    public static testMethod void testSetSelectedAttachmentFlagAutoApprovalSubCaseSubmitted(){
        String notSubmittedStatus = ComplianceConstants.CASE_STATUS_NOT_SUBMITTED;
        String waitingForApprovalStatus = ComplianceConstants.CASE_STATUS_WAITING_FOR_APPROVAL;
        String waitingForPostingStatus = ComplianceConstants.CASE_STATUS_WAITING_FOR_POSTING;
        String closedStatus = ComplianceConstants.CASE_STATUS_CLOSED;

        Case brCase = CaseComplianceUtilityTest.createBrandRegistrationCase();
        insert brCase;

        Case subCase = CaseComplianceUtilityTest.createBrandRegistrationComplianceSubCase(brCase.Id, 'Illinois');
        insert subCase;
        subCase.State_Type__c = 'Auto Approval;';
        subCase.OwnerId = UserInfo.getUserId();
        update subCase;

        Test.startTest();
        subCase = [SELECT Id, Status, Submission_Date__c, Approval_Date__c FROM Case WHERE Id=:subCase.Id];
        System.assertEquals(notSubmittedStatus, subCase.Status, 'Status should be "Not Submitted".');
        System.assertEquals(null, subCase.Submission_Date__c, 'Case should not have a submission date yet.');
        System.assertEquals(null, subCase.Approval_Date__c, 'Case should not have an approval date yet.');
        ComplianceCaseAttachmentController.setSelectedAttachmentFlag(subCase.Id, 'Submission');
        subCase = [SELECT Id, Status, Submission_Date__c, Approval_Date__c FROM Case WHERE Id=:subCase.Id];
        //System.assertEquals(closedStatus, subCase.Status, 'Case should be in the "Closed" status.');
        //System.assertEquals(System.today(), subCase.Submission_Date__c, 'Case should have a submission date.');
        //System.assertEquals(System.today(), subCase.Approval_Date__c, 'Case should have an approval date');
        Test.stopTest();
    }

    public static testMethod void testSetSelectedAttachmentFlagPriorApprovalPricePostingSubCaseApproved(){
        String notSubmittedStatus = ComplianceConstants.CASE_STATUS_NOT_SUBMITTED;
        String waitingForApprovalStatus = ComplianceConstants.CASE_STATUS_WAITING_FOR_APPROVAL;
        String waitingForPostingStatus = ComplianceConstants.CASE_STATUS_WAITING_FOR_POSTING;
        String closedStatus = ComplianceConstants.CASE_STATUS_CLOSED;
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        Case brCase = CaseComplianceUtilityTest.createBrandRegistrationCase();
        insert brCase;

        Case subCase = CaseComplianceUtilityTest.createBrandRegistrationComplianceSubCase(brCase.Id, 'Illinois');
        insert subCase;
        subCase.State_Type__c = 'Auto Approval;Price Posting;';
        subCase.OwnerId = UserInfo.getUserId();
        update subCase;
        ComplianceCaseAttachmentController.setSelectedAttachmentFlag(subCase.Id, 'Submission');

        Test.startTest();
        subCase = [SELECT Id, Status, Submission_Date__c, Approval_Date__c, Posting_Date__c FROM Case WHERE Id=:subCase.Id];
        System.assertEquals(waitingForPostingStatus, subCase.Status, 'Case should be in the "Waiting for Posting" status.');
        System.assertEquals(null, subCase.Posting_Date__c, 'Case posting date should be null.');
        Test.stopTest();
    }

    public static testMethod void testSetSelectedAttachmentFlagPricePostingAutoApprovalSubCaseSubmitted(){
        String notSubmittedStatus = ComplianceConstants.CASE_STATUS_NOT_SUBMITTED;
        String waitingForApprovalStatus = ComplianceConstants.CASE_STATUS_WAITING_FOR_APPROVAL;
        String waitingForPostingStatus = ComplianceConstants.CASE_STATUS_WAITING_FOR_POSTING;
        String closedStatus = ComplianceConstants.CASE_STATUS_CLOSED;

        Case brCase = CaseComplianceUtilityTest.createBrandRegistrationCase();
        insert brCase;

        Case subCase = CaseComplianceUtilityTest.createBrandRegistrationComplianceSubCase(brCase.Id, 'Illinois');
        insert subCase;
        subCase.State_Type__c = 'Auto Approval;Price Posting;';
        subCase.OwnerId = UserInfo.getUserId();
        update subCase;

        Test.startTest();
        subCase = [SELECT Id, Status, Submission_Date__c, Approval_Date__c FROM Case WHERE Id=:subCase.Id];
        System.assertEquals(notSubmittedStatus, subCase.Status, 'Status should be "Not Submitted".');
        System.assertEquals(null, subCase.Submission_Date__c, 'Case should not have a submission date yet.');
        System.assertEquals(null, subCase.Approval_Date__c, 'Case should not have an approval date yet.');
        ComplianceCaseAttachmentController.setSelectedAttachmentFlag(subCase.Id, 'Submission');
        subCase = [SELECT Id, Status, Submission_Date__c, Approval_Date__c FROM Case WHERE Id=:subCase.Id];
        System.assertEquals(waitingForPostingStatus, subCase.Status, 'Case should be in the "Waiting for Posting" status.');
        System.assertEquals(System.today(), subCase.Submission_Date__c, 'Case should have a submission date.');
        System.assertEquals(System.today(), subCase.Approval_Date__c, 'Case should have an approval date');
        Test.stopTest();
    }

    public static testMethod void testSetSelectedAttachmentFlagPricePostingSubmission(){
        String workingStatus = ComplianceConstants.CASE_STATUS_WORKING;
        String closePendingStatus = ComplianceConstants.CASE_STATUS_CLOSE_PENDING;
        
        Case ppCase = CaseComplianceUtilityTest.createPricePostingCase();
        insert ppCase;

        Test.startTest();

        ppCase = [SELECT Id, Status, Submission_Date__c FROM Case WHERE Id=:ppCase.Id];
        System.assertEquals(workingStatus, ppCase.Status, 'Status should be "Working".');
        System.assertEquals(null, ppCase.Submission_Date__c, 'Case should not have a submission date yet.');
        ComplianceCaseAttachmentController.setSelectedAttachmentFlag(ppCase.Id, ComplianceConstants.DOCUMENT_TYPE_SUBMISSION);
        ppCase = [SELECT Id, Status, Submission_Date__c, Compliance_Flagset__c FROM Case WHERE Id=:ppCase.Id];
        System.assertEquals(closePendingStatus, ppCase.Status, 'Status should be "Close Pending".');
        System.assertEquals(System.today(), ppCase.Submission_Date__c, 'Case should now have a submission date.');
        Test.stopTest();
    }

    public static testMethod void testSetSelectedAttachmentFlagPricePostingStateManagerApproval(){      
        String stateManagerApprovalFlag = ComplianceConstants.FLAG_PRICE_POSTING_STATE_MANAGER_APPROVAL;
        Case ppCase = CaseComplianceUtilityTest.createPricePostingCase();
        insert ppCase;

        Test.startTest();

        ppCase = [SELECT Id, Status, Submission_Date__c, Compliance_Flagset__c FROM Case WHERE Id=:ppCase.Id];
        System.assert(ppCase.Compliance_Flagset__c == null, 'This case should not have the State Manager Approval flag yet.');
        ComplianceCaseAttachmentController.setSelectedAttachmentFlag(ppCase.Id, ComplianceConstants.DOCUMENT_TYPE_STATE_MANAGER_APPROVAL);
        ppCase = [SELECT Id, Status, Submission_Date__c, Compliance_Flagset__c FROM Case WHERE Id=:ppCase.Id];
        System.assert(ppCase.Compliance_Flagset__c.contains(stateManagerApprovalFlag), 'This case should have the State Manager Approval flag.');       
        
        Test.stopTest();
    }

    public static testMethod void testSetSelectedAttachmentFlagPricePostingSubmissionConfirmation(){        
        String submissionConfirmationFlag = ComplianceConstants.FLAG_PRICE_POSTING_SUBMISSION_CONFIRMATION;
        Case ppCase = CaseComplianceUtilityTest.createPricePostingCase();
        insert ppCase;

        Test.startTest();

        ppCase = [SELECT Id, Status, Submission_Date__c, Compliance_Flagset__c FROM Case WHERE Id=:ppCase.Id];
        System.assert(ppCase.Compliance_Flagset__c == null, 'This case should not have the Submission Confirmation flag yet.');
        ComplianceCaseAttachmentController.setSelectedAttachmentFlag(ppCase.Id, ComplianceConstants.DOCUMENT_TYPE_SUBMISSION_CONFIRMATION);
        ppCase = [SELECT Id, Status, Submission_Date__c, Compliance_Flagset__c FROM Case WHERE Id=:ppCase.Id];
        System.assert(ppCase.Compliance_Flagset__c.contains(submissionConfirmationFlag), 'This case should have the Submission Confirmation flag.');        
        
        Test.stopTest();
    }

    public static testMethod void testSetSelectedAttachmentFlagPriceFilingBlankWorkbook(){
        String documentBlankWorkbook = ComplianceConstants.DOCUMENT_TYPE_BLANK_WORKBOOK;
        Case pfCase = CaseComplianceUtilityTest.createPriceFilingCase();
        insert pfCase;

        Test.startTest();
        pfCase = [SELECT Id, Status, Submission_Date__c, Compliance_Flagset__c FROM Case WHERE Id=:pfCase.Id];
        System.assertEquals(pfCase.Status, 'New', 'This case should be in the "New" status.');
        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should have been sent yet.');       
        ComplianceCaseAttachmentController.setSelectedAttachmentFlag(pfCase.Id, documentBlankWorkbook);     
        pfCase = [SELECT Id, Status, Submission_Date__c, Compliance_Flagset__c FROM Case WHERE Id=:pfCase.Id];
        System.assertEquals(pfCase.Status, 'Waiting for State Manager', 'This case should be in the "Waiting for State Manager" status.');
        System.assertEquals(1, Limits.getEmailInvocations(), 'The email to the State Manager should have been sent.');      
        Test.stopTest();
    }

    public static testMethod void testSetSelectedAttachmentFlagPriceFilingFinalizedWorkbook(){
        String documentBlankWorkbook = ComplianceConstants.DOCUMENT_TYPE_BLANK_WORKBOOK;
        String documentFinalizedWorkbook = ComplianceConstants.DOCUMENT_TYPE_FINALIZED_WORKBOOK;
        Case pfCase = CaseComplianceUtilityTest.createPriceFilingCase();
        insert pfCase;

        ComplianceCaseAttachmentController.setSelectedAttachmentFlag(pfCase.Id, documentBlankWorkbook);

        Test.startTest();
        pfCase = [SELECT Id, Status, Submission_Date__c, Compliance_Flagset__c FROM Case WHERE Id=:pfCase.Id];
        System.assertEquals(pfCase.Status, 'Waiting for State Manager', 'This case should be in the "Waiting for State Manager" status.');
        ComplianceCaseAttachmentController.setSelectedAttachmentFlag(pfCase.Id, documentFinalizedWorkbook);     
        pfCase = [SELECT Id, Status, Submission_Date__c, Compliance_Flagset__c FROM Case WHERE Id=:pfCase.Id];
        System.assertEquals(pfCase.Status, 'Waiting for Approval', 'This case should be in the "Waiting for Approval Manager" status.');
        System.assertEquals(1, Limits.getEmailInvocations(), 'The email to Commercial Finance should have been sent.');     
        Test.stopTest();
    }

    public static testMethod void testSetSelectedAttachmentFlagPriceFilingSubmission(){
        String documentSubmission = ComplianceConstants.DOCUMENT_TYPE_SUBMISSION;
        String documentBlankWorkbook = ComplianceConstants.DOCUMENT_TYPE_BLANK_WORKBOOK;
        String documentFinalizedWorkbook = ComplianceConstants.DOCUMENT_TYPE_FINALIZED_WORKBOOK;
        Case pfCase = CaseComplianceUtilityTest.createPriceFilingCase();
        insert pfCase;

        ComplianceCaseAttachmentController.setSelectedAttachmentFlag(pfCase.Id, documentFinalizedWorkbook);     

        Test.startTest();
        pfCase = [SELECT Id, Status, Submission_Date__c, Compliance_Flagset__c FROM Case WHERE Id=:pfCase.Id];
        ComplianceCaseAttachmentController.setSelectedAttachmentFlag(pfCase.Id, documentSubmission);        
        pfCase = [SELECT Id, Status, Submission_Date__c, Compliance_Flagset__c FROM Case WHERE Id=:pfCase.Id];
        //System.assertEquals(pfCase.Status, 'Close Pending', 'This case should be in the "Close Pending" status.');
        System.assertEquals(pfCase.Status, 'Waiting for Approval', 'This case should be in the "Waiting for Approval".');
        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should be sent in the testing context.');       
        Test.stopTest();
    }

    public static testMethod void testSetSelectedAttachmentFlagDiscountUpload(){
        String documentTypeDiscount = ComplianceConstants.DOCUMENT_TYPE_DISCOUNTS_DOCUMENT;
        String sysAdminProfile = ComplianceConstants.SYSTEM_ADMINISTRATOR_PROFILE;
        User noStateUser = CaseComplianceUtilityTest.createComplianceTestUser(sysAdminProfile, 'test-compliance-user-1=beamsuntory@example.com');
        noStateUser.Represented_States__c = '';
        insert noStateUser;
        
        Case discountCase = CaseComplianceUtilityTest.createDiscountCase();
        System.runAs(noStateUser){
            discountCase.Approval_Needed__c = 'Yes';
            insert discountCase;
        }

        Test.startTest();
        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should have been sent.');       
        ComplianceCaseAttachmentController.setSelectedAttachmentFlag(discountCase.Id, documentTypeDiscount);        
        System.assertEquals(1, Limits.getEmailInvocations(), 'The discount approval email should have been sent.');     
        Test.stopTest();
    }

    public static testMethod void testAssignDocumentTypesAfterUpload(){
        ContentVersion testContentVersion = CaseComplianceUtilityTest.createContentVersion(null);
        testContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: testContentVersion.Id];
        List<Id> contentDocumentIdList = new List<Id>{testContentVersion.ContentDocumentId};
        
        Id brandCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Brand Registration').getRecordTypeId();
        Case c = new Case();
        c.Status = 'Waiting for Sub Cases';
        c.In_field_Date__c= system.today()+2;
        c.RecordTypeId = brandCaseRecordTypeId;
        c.Type = 'Informational';
        insert c;
        
        Case childcase = new Case();
        Id custrtypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Data').getRecordTypeId();

        childcase.Status = 'New';
        childcase.In_field_Date__c= system.today()+2;
        childcase.RecordTypeId = custrtypeId;
        childcase.ParentId = c.id;
        insert childcase;
        Test.startTest();
        ComplianceCaseAttachmentController.assignDocumentTypesAfterUpload(ComplianceConstants.DOCUMENT_TYPE_OTHER, contentDocumentIdList,c.Id);
        
        
        List<ContentVersion> cvList = [SELECT Id, Document_Type__c, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: contentDocumentIdList];
        for(ContentVersion cv: cvList){
            System.assertEquals(ComplianceConstants.DOCUMENT_TYPE_OTHER, cv.Document_Type__c, 'Each Content Version should have a Document Type of "Other".');
        }
        Test.stopTest();
    }

    public static testMethod void testDeleteAllButMostRecentDocumentType(){
        Case ppCase = CaseComplianceUtilityTest.createPricePostingCase();
        insert ppCase;
        ContentVersion testContentVersion1 = CaseComplianceUtilityTest.createContentVersion(ComplianceConstants.DOCUMENT_TYPE_OTHER);
        ContentVersion testContentVersion2 = CaseComplianceUtilityTest.createContentVersion(ComplianceConstants.DOCUMENT_TYPE_OTHER);
        ContentVersion testContentVersion3 = CaseComplianceUtilityTest.createContentVersion(ComplianceConstants.DOCUMENT_TYPE_OTHER);
        testContentVersion1 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: testContentVersion1.Id];
        testContentVersion2 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: testContentVersion2.Id];
        testContentVersion3 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: testContentVersion3.Id];
        ContentDocumentLink testDocumentLink1 = CaseComplianceUtilityTest.createContentDocumentLink(ppCase.Id, testContentVersion1.ContentDocumentId);
        ContentDocumentLink testDocumentLink2 = CaseComplianceUtilityTest.createContentDocumentLink(ppCase.Id, testContentVersion2.ContentDocumentId);
        ContentDocumentLink testDocumentLink3 = CaseComplianceUtilityTest.createContentDocumentLink(ppCase.Id, testContentVersion3.ContentDocumentId);

        Test.startTest();

        ComplianceCaseAttachmentController.deleteAllButMostRecentDocumentType(ppCase.Id, ComplianceConstants.DOCUMENT_TYPE_OTHER);

        Test.stopTest();
    }
}