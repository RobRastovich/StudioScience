@isTest
public class TST_DTC_CaseUserAccountJSON {
    @isTest
    public static void testDTCCaseUserAccountJSON() {
        Case caseDetails = new DTC_CaseUserAccountJSON().caseDetails;
        Account accountDetails = new DTC_CaseUserAccountJSON().accountDetails;
        String type = new DTC_CaseUserAccountJSON().Type;
        String magentoID = new DTC_CaseUserAccountJSON().MagentoID;
        String isCancelConfirmed = new DTC_CaseUserAccountJSON().isCancelConfirmed;
        String isShipmentRequired = new DTC_CaseUserAccountJSON().isShipmentRequired;
    }
}