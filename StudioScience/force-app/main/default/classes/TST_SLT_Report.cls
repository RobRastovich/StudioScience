@isTest
private class TST_SLT_Report {
    @isTest(SeeAllData = 'true')
    private static void testGetReport() {
        List<Report> reportList = new List<Report>();
        
        Test.startTest();
            reportList = SLT_Report.getReport();
        Test.stopTest();
        
        System.assertEquals(true, reportList.size() > 0, 'List cannot be empty');
    }
}