@isTest
public class TST_DTC_CaseDetailsRest {
	@isTest
    private static void testgetCaseDetails() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            DTC_CaseDetailsRest.getCaseDetails();
        Test.stopTest();
      
        
        
    }
}