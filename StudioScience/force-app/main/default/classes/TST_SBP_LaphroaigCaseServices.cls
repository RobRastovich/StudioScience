@isTest
public class TST_SBP_LaphroaigCaseServices {
    @testSetup
    static void setUpTestData() { 
        Case laphroaigCase = SBP_TestDataFactory.createCase(null, true);
    }
    
    @isTest
    private static void testUpdateSTOCreationDate() {
        Case newCase = [SELECT id, STO_Number__c, STO_Created__c
                            FROM Case 
                            WHERE RecordTypeId =: SBP_Constants.SINGLE_BARREL_LAPHROAIG_RT_ID];   
        Case oldCase = newCase.clone(true, false, false, false);
        oldCase.STO_Number__c = null;
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id,oldCase);
        List<Case> newList = new List<Case>{newCase};
        Test.startTest();
            SBP_LaphroaigCaseServices.updateSTOCreationDate(newList, oldMap);
        Test.stopTest();
        System.assertEquals(true, newCase.STO_Created__c, 'value is not true');
    }

    @isTest
    private static void testUpdateCaseStatusAndSubStatus() {
        Case newCase = [SELECT Id, Status, Type
                            FROM Case 
                            WHERE RecordTypeId =: SBP_Constants.SINGLE_BARREL_LAPHROAIG_RT_ID];   
        Case oldCase = newCase.clone(true, false, false, false);
        oldCase.Type = null;
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id, oldCase);
        List<Case> newList = new List<Case>{newCase};

        Test.startTest();
            SBP_LaphroaigCaseServices.updateCaseStatusAndSubStatus(newList, oldMap);
        Test.stopTest();

        System.assertEquals(SBP_Constants.PREPARING_BARREL, newCase.Status, 'Case status not updated when expected to be.');
    }

    @isTest
    private static void testUpdateCaseStatusAndSubStatusToFinalDetail() {
        Case newCase = [SELECT Id, Status, Type, SAP_Number__c
                            FROM Case 
                            WHERE RecordTypeId =: SBP_Constants.SINGLE_BARREL_LAPHROAIG_RT_ID];   
        Case oldCase = newCase.clone(true, false, false, false);
        oldCase.SAP_Number__c = null;
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id, oldCase);
        List<Case> newList = new List<Case>{newCase};

        Test.startTest();
            SBP_LaphroaigCaseServices.updateCaseStatusAndSubStatus(newList, oldMap);
        Test.stopTest();

        System.assertEquals(SBP_Constants.PENDING_FINAL_DETAILS, newCase.Status, 'Case status not updated when expected to be.');
    }
    
    @isTest
    public static void testUpdateCaseSubject(){
        Case newCase = [SELECT Id, Status, Type, caseNumber
                            FROM Case 
                            WHERE RecordTypeId =: SBP_Constants.SINGLE_BARREL_LAPHROAIG_RT_ID]; 
        Case oldCase = newCase.clone(true, false, false, false);
        oldCase.Type = null;
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id, oldCase);
        List<Case> newList = new List<Case>{newCase};

        Test.startTest();
            SBP_LaphroaigCaseServices.updateCaseSubject(newList, oldMap);
        Test.stopTest();

        System.assertEquals(true, newCase.Subject.contains(SBP_Constants.TRIP_AND_TOUR), 'Subject is not correct');
        
    }
}