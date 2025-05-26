public class BEST_UserApprovalLink {
    
    private final String portalLink;
    public String recoId { get;set; }
    
    public BEST_UserApprovalLink() {
        Site bestEverSite = [SELECT Id FROM Site WHERE Name = 'BEST_EVER_Portal'];
        SiteDetail bestEverSiteDetail = [SELECT SecureURL from SiteDetail where DurableId = :bestEverSite.Id];
        portalLink = bestEverSiteDetail.SecureURL + '/s/UserApprovalRequest?recordId=';
    }
    
    public String getPortalLink() {
        return portalLink;
    }
    
}