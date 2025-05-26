public class SLT_Site {
    public static List<Site> getSiteList() {
        List<Site> siteList = new List<Site>();
        siteList = [SELECT Id, Name FROM Site
                       WHERE Name =: SOI_Constants.BEAM_SUNTORY_CUSTOMER_COMMUNITY];
        return siteList;
    }
}