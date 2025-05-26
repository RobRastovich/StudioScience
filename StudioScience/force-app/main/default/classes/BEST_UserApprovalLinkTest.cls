@IsTest()
public class BEST_UserApprovalLinkTest {
    
    @IsTest
    static void getPortalLinkTest() {
        BEST_UserApprovalLink obj = new BEST_UserApprovalLink();
        String portalLink = obj.getPortalLink();
        System.assert(portalLink != null);
    }

}