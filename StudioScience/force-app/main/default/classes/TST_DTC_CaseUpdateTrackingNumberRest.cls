@isTest
public class TST_DTC_CaseUpdateTrackingNumberRest {
    @isTest
    private static void testUpdateCase() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTC_CaseUpdateTrackingNumberRest.updateCase();
        Test.stopTest();
    }
}