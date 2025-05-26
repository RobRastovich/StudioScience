@isTest
public class TST_dhlCaseViewController {
    
    @testSetup
    static void setUpTestData() {  
        Case newCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, true); 
    }
    
    @isTest
    private static void testCheckStatusFlowOfCaseStatusDTC() {
        List<Case> newList = [SELECT id, OwnerId, Status from Case];
        
        Test.startTest();
        Case cas = dhlCaseViewController.getCaseRecord(newList[0].Id);
        Test.stopTest();
        
        System.assertEquals(newList[0].Id, cas.Id, 'The returnd case is incorrect. ');
    }
}