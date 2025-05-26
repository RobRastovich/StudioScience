@isTest(seeAllData = false)
public class TST_SLT_Case {
    @testSetup
    static void dataSetup() {
        List<Case> caseList = new List<Case>();
        Account acc = SBP_TestDataFactory.createAccount(null, false);
        acc.Attention__c = 'xyz';
        acc.TDL_Match_Code__c = 'abcdef';
        acc.PremiseType__c = 'On Premise';
        acc.BillingCity = 'Jaipur';
        acc.BillingState = 'Rajsthan';
        acc.BillingPostalCode = '234234';
        acc.Phone = '234234234';
        acc.BillingStreet = 'dfvsdf';
        insert acc;
        
        Case laphroaigTestCase = SBP_TestDataFactory.createCase(SBP_Constants.SINGLE_BARREL_LAPHROAIG_RT_ID, false);
        laphroaigTestCase.AccountId = acc.Id;
        caseList.add(laphroaigTestCase);
        if(caseList.size() > 0 && !caseList.isEmpty()){
            insert caseList;
        }
    }
    
    @isTest
    public static void testGetCaseByID() {
        Case testCase = [SELECT Id 
                         FROM Case 
                         WHERE Brand__c =: SBP_Constants.LAPHROAIG_SINGLE_CASK 
                         LIMIT 1];

        test.startTest();
        	Case recordCase = SLT_Case.getCaseByID(testCase.Id);
        test.stopTest();

        System.assertEquals(false, recordCase == null, 'Case Is Fetched By ID');
    }

    @isTest
    public static void testGetCaseDetailByID() {
        Case testCase = [SELECT Id 
                         FROM Case 
                         WHERE Brand__c =: SBP_Constants.LAPHROAIG_SINGLE_CASK 
                         LIMIT 1];
                         
        Test.StartTest();
        	Case recordCase = SLT_Case.getCaseDetailByID(testCase.Id);
        Test.StopTest();

        System.assertEquals(false, recordCase == null, 'Case details not found.');
    }
    
    //Added By Nishant Khandal LSB-20
    @isTest
    public static void testGetCaseAccountDetailsByID() {
        Case testCase = [SELECT Id 
                         FROM Case 
                         WHERE Brand__c =: SBP_Constants.LAPHROAIG_SINGLE_CASK 
                         LIMIT 1];
                         
        Test.StartTest();
        	Case recordCase = SLT_Case.getCaseAccountDetailsByID(testCase.Id);
        Test.StopTest();

        System.assertEquals(false, recordCase == null, 'Case details not found.');
    }

    @isTest
    public static void testGetCasesListById() {
        Case testCase = [SELECT Id 
                         FROM Case 
                         WHERE Brand__c =: SBP_Constants.LAPHROAIG_SINGLE_CASK 
                         LIMIT 1];
                         
        Test.StartTest();
        	List<Case> recordCase = SLT_Case.getCasesListById(new Set<Id>{testCase.Id});
        Test.StopTest();

        System.assertEquals(false, recordCase == null, 'Case details not found.');
    }
}