@isTest
public class TST_DTC_CNT_URL {
	@testSetup
    static void setUpTestData() {
        Case newCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        newCase.OrderID__c = 'testJimBeam';
        DTC_CNT_URL.caseNum= newCase.Id;
        insert newCase;
    }
    
    @isTest
    static void testGetCommunityURLOrg(){
        List<Site> siteId= [SELECT Id, name FROM Site WHERE name= 'Beam_Suntory_Customer_Community_C'];
        String communityURL= [SELECT SecureURL FROM SiteDetail WHERE DurableId =: siteId.get(0).Id].SecureUrl;
        Case caseObj= [SELECT Id FROM Case LIMIT 1];
        
        
        Test.startTest();
           String url= DTC_CNT_URL.getCommunityURLOrg();
        Test.stopTest();
        
        System.assertEquals(true, url.contains('dhlcases'), 'URLs are not matching');
    }
    
    @isTest
    static void testGetCaseNumber(){
        Case caseObj= [SELECT OrderID__c, CaseNumber FROM Case LIMIT 1];
        DTC_CNT_URL.caseNum= caseObj.Id;
        Test.startTest();
            String caseNo= DTC_CNT_URL.getCaseNumber();
        Test.stopTest();
        
        System.assertEquals(caseNo, caseObj.CaseNumber, 'caseNumber are not matching');
    }
}