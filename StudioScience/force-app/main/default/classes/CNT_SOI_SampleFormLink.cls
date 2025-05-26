public class CNT_SOI_SampleFormLink {
    public String getNewSalesFormLink() {
        List<Site> siteList = SLT_Site.getSiteList();
        Id siteId;
        String communityURL = '';
        if(siteList.size() >= 0)
            siteId = siteList.get(0).Id;
        if(siteId != null) {
            communityURL = SLT_SiteDetail.getCommunityURL(siteId);
        }
        return communityURL;
    }
}