@isTest
public class TST_DTCCaseCreationRest {
    @isTest
    private static void testCreateCase() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRest.createCase();
        Test.stopTest();
    }
    
    @isTest
    private static void testUpdateCase() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTCCaseCreationRest.updateCase();
        Test.stopTest();
    }
}