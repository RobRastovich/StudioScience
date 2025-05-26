public class SLT_Report {
    public static List<Report> getReport() {
        List<Report> reportList = new List<Report>();
        reportList = [SELECT Id, DeveloperName FROM Report
                         WHERE DeveloperName =: SOI_Constants.SOI_REPORT_DEVELOPER_NAME];
        return reportList;
    }
}