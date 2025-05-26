public class SLT_SiteDetail {
    public static String getCommunityURL(Id siteId) {
        String communityURL = '';
        if(String.isNotBlank(siteId)) {
            SiteDetail siteDetail = [SELECT SecureURL FROM SiteDetail
                                        WHERE DurableId =: siteId];
            if(siteDetail != null) {
                communityURL = siteDetail.SecureUrl;
            }
        }
        return communityURL;
    }
}