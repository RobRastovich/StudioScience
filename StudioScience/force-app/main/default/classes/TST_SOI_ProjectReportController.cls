@isTest
private class TST_SOI_ProjectReportController {
    @isTest(SeeAllData = 'true')
    private static void testGetReportColumns() {
        Innovation_Project_Master__c projectMaster = TST_TestDataFactory.createInnovationMaster(true);
        SOI_ProjectReportController reportControllerInstance = new SOI_ProjectReportController();
        reportControllerInstance.projectMasterId = projectMaster.Id;
        List<String> reportList = new List<String>();
        
        Test.startTest();
            reportList = reportControllerInstance.getReportColumns();
        Test.stopTest();
        
        System.assertEquals(true, reportList.size() > 0, 'It should return a report list');
    }
    
    @isTest(SeeAllData = 'true')
    private static void testGetReportData() {
        List<Report> reportList = [SELECT Id, DeveloperName FROM Report
                                      WHERE DeveloperName =: SOI_Constants.SOI_REPORT_DEVELOPER_NAME];
        String reportId = (String)reportList.get(0).get('Id');
        Innovation_Project_Master__c innovationMaster = TST_TestDataFactory.createInnovationMaster(true);
        Innovation_Sample_Requests__c innovationRequest = TST_TestDataFactory.createInnovationRequest(false);
        innovationRequest.Innovation_Samples__c = innovationMaster.Id;
        insert innovationRequest;
        Innovation_Project_Details__c innovationDetail = TST_TestDataFactory.createInnovationDetail(false);
        innovationDetail.InnovationId__c = innovationRequest.Id;
        insert innovationDetail;
        Reports.ReportResults results = Reports.ReportManager.runReport(reportId, true);
        Reports.Dimension dim = results.getGroupingsDown();
        SOI_ProjectReportController reportControllerInstance = new SOI_ProjectReportController();
        List<Reports.ReportDetailRow> detailRowList = new List<Reports.ReportDetailRow>();
        if(dim.getGroupings() != null) {
            reportControllerInstance.projectName = dim.getGroupings()[0].getLabel();
            reportControllerInstance.projectMasterId = innovationMaster.Id;
        }
        
        Test.startTest();
            detailRowList = reportControllerInstance.getReportData();
        Test.stopTest();
        
        System.assertEquals(true, detailRowList.size() > 0, 'It should return a report detail row list');
    }
}