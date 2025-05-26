public class SLT_TI_SAP_API_Case {
    public static List<Case> getCaseListByID(Set<ID> caseIDs) {
        List<Case> casesList = [SELECT Id,SAP_Number__c FROM Case WHERE ID IN : caseIds];
        return casesList;
    }
}