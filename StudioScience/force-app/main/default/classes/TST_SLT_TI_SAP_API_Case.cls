@isTest
public class TST_SLT_TI_SAP_API_Case {
    @testSetup static void setup(){
        Case caseObj = new Case(SAP_Number__c='1022432980');
        insert caseObj;
    }
    
    @isTest static void test_getCaseListByID(){
        
        Set<ID> caseIDs = new Set<ID>();
        List<Case> caseList = [select id from case];
        for(Case c: caseList){
            caseIDs.add(c.id);
        }
        
        Test.startTest();
             List<Case> casesList2 = SLT_TI_SAP_API_Case.getCaseListByID(caseIDs);
        Test.stopTest();
        
        System.assertEquals(1, casesList2.size());
    }
}