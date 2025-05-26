@isTest
private class TST_SLT_Site {
    @isTest
    private static void testGetSiteList() {
        List<Site> siteList = new List<Site>();
        
        Test.startTest();
            siteList = SLT_Site.getSiteList();
        Test.stopTest();
        
        System.assertEquals(1, siteList.size(), 'It should return a Site list');
    }
}