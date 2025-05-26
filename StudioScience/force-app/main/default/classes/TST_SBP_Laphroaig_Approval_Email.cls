@isTest(seeAllData = false)
public class TST_SBP_Laphroaig_Approval_Email {

    @testSetup
    static void dataSetup() {
        List<Case> insertCases = new List<Case>();
        Case laphroaigTestCase = new Case();
        laphroaigTestCase.Brand__c = SBP_Constants.LAPHROAIG_SINGLE_CASK;
        insertCases.add(laphroaigTestCase);
        
        if(insertCases.size() > 0 && !insertCases.isEmpty()){
            insert insertCases;
        }
    }

	@isTest
    public static void testGetCaseNumber() {
		Case testCase = [SELECT Id, CaseNumber
                         FROM Case 
                         WHERE Brand__c =: SBP_Constants.LAPHROAIG_SINGLE_CASK 
                         LIMIT 1];
        SBP_Laphroaig_Approval_Email_Controller.recordId = testCase.Id;

        Test.startTest();
        	String recordCaseNumber = SBP_Laphroaig_Approval_Email_Controller.getCaseNumber();
        Test.stopTest();

        System.assertEquals(testCase.CaseNumber, recordCaseNumber, 'Correct Id is Fetched');
    }

    @isTest
    public static void testGetCaseURL() {
        Case testCase = [SELECT Id, CaseNumber
                         FROM Case 
                         WHERE Brand__c =: SBP_Constants.LAPHROAIG_SINGLE_CASK 
                         LIMIT 1];
        SBP_Laphroaig_Approval_Email_Controller.recordId = testCase.Id;

        Test.startTest();
        	String testURL = SBP_Laphroaig_Approval_Email_Controller.getURL();
        Test.stopTest();

        Boolean isCorrectURL = false;
        if (testURL.contains(testCase.Id)) {
            isCorrectURL = true;
        }

        System.assertEquals(false, String.isEmpty(testURL), 'URL is Fetched');
        System.assertEquals(true, isCorrectURL, 'Correct URL is Fetched');
    }
}