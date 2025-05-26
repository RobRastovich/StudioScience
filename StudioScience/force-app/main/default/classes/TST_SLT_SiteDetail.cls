@isTest
private class TST_SLT_SiteDetail {
    @isTest
    private static void testGetCommunityURL() {
        List<Site> siteList = [SELECT Id, Name FROM Site
                                  WHERE Name =: SOI_Constants.BEAM_SUNTORY_CUSTOMER_COMMUNITY];
        
        Test.startTest();
            String url = SLT_SiteDetail.getCommunityURL(siteList.get(0).Id);
        Test.stopTest();
        
        System.assertEquals(true, String.isNotBlank(url), 'URL should not be blank');
    }
}