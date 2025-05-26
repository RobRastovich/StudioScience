public class SOI_ProjectReportController {
    public Id projectMasterId {get;set;}
    public String projectName {get;set;}
    public List<String> getReportColumns() {
        List<String> labelList = new List<String>();
        List<Report> reportList = new List<Report>();
        reportList = SLT_Report.getReport();
        String reportId;
        if(projectMasterId != null && reportList.size() > 0) {
            if(reportList[0].get('Id') != null) {
                reportId = (String)reportList[0].get('Id');
                Reports.ReportResults results = Reports.ReportManager.runReport(reportId, true);
                if(results.getReportExtendedMetadata() != null) {
                    Reports.ReportExtendedMetadata rmd = results.getReportExtendedMetadata();
                    Map<String, Reports.DetailColumn> colMap = rmd.getDetailColumnInfo();
                    for(String key : colMap.KeySet()) {
                        labelList.add(colMap.get(key).getLabel());
                    } 
                }
            }
        }
        return labelList;
    }
    
    public List<Reports.ReportDetailRow> getReportData() {
        List<Report> reportList = new List<Report>();
        reportList = SLT_Report.getReport();
        String reportId;
        List<Reports.ReportDetailRow> detailRowList = new List<Reports.ReportDetailRow>();
        if(projectMasterId != null && reportList.size() > 0) {
            if(reportList[0].get('Id') != null) {
                reportId = (String)reportList.get(0).get('Id');
                Reports.ReportResults results = Reports.ReportManager.runReport(reportId, true);
                if(results.getGroupingsDown() != null) {
                    Reports.Dimension dim = results.getGroupingsDown();
                    projectName = SLT_SOI_Innovation_Project_Master.getProjectName(projectMasterId);
                    if(projectName != null) {
                        for(Reports.GroupingValue groupingVal : dim.getGroupings()) {
                            String reportProjectName = groupingVal.getLabel();  
                            if(reportProjectName == projectName) {
                                String factMapKey = groupingVal.getKey() + '!T';
                                Reports.ReportFactWithDetails factDetails =
                                    (Reports.ReportFactWithDetails)results.getFactMap().get(factMapKey);
                                detailRowList = factDetails.getRows();
                                break;
                            }
                        } 
                    }
                }   
            }
        }
        return detailRowList;
    }
}