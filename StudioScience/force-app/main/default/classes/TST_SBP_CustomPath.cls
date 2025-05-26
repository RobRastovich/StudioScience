@isTest
public class TST_SBP_CustomPath {

    @testSetup
    static void setUpTestData() {
        Case newCase = SBP_TestDataFactory.createCase(SBP_Constants.SINGLE_BARREL_LAPHROAIG_RT_ID, true);
    }
    
    @isTest
    public static void testGetCaseDetailByID() {
        Case testCase = [SELECT Id 
                         FROM Case 
                         WHERE Brand__c =: SBP_Constants.LAPHROAIG_SINGLE_CASK 
                         LIMIT 1];
                         
        test.startTest();
        	Case recordCase = SBP_CustomPath.getCaseRecord(testCase.Id);
        test.stopTest();

        System.assertEquals(false, recordCase == null, 'Case details not found.');
    }

    @isTest
    public static void testGetStatus() {
        List<String> listOfStatusWithSubStatus = new List<String>();
                         
        test.startTest();
            listOfStatusWithSubStatus = SBP_CustomPath.getStatus(SBP_Constants.LAPHROAIG_SINGLE_CASK );
        test.stopTest();

        System.assertNotEquals(null, listOfStatusWithSubStatus, 'Metadata records not found.');
    }
}