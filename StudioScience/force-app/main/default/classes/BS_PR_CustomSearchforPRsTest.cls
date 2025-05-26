@istest
public class BS_PR_CustomSearchforPRsTest {
    @testSetup static void testDataSetup() {
        user adminUser=BS_PR_TestService_UtilityCls.adminUserSetup();
        system.runAs(adminUser){
            List<Campaign__c>  CampaignDataList=BS_PR_TestService_UtilityCls.setupCampaignData();
            List<Account> AccountDataList=BS_PR_TestService_UtilityCls.setupAccountData();
            List<Account> vendorAccountList=[SELECT id,Name,RecordTypeId from Account WHERE RecordType.Name='Vendor'];
            List<SAP_Company_Code__c> SAPCompanyCodeDataList=BS_PR_TestService_UtilityCls.setupSAPCompanyCodeData(vendorAccountList[0].id);
            PR_Header__c prHeader=BS_PR_TestService_UtilityCls.setupPRHeaderData(vendorAccountList[0].id,SAPCompanyCodeDataList[0].id);
            list<PR_Detail__c>  PR_DetailList=BS_PR_TestService_UtilityCls.setupPRDetailsData(prHeader.Id,CampaignDataList);
            PR_DetailList=BS_PR_TestService_UtilityCls.update_PRDetails_Create_Update_Phasing(PR_DetailList,'Straight Line');
            Attachment att=BS_PR_TestService_UtilityCls.setupPRAttachments(PRHeader.Id);
			BS_PR_TestService_UtilityCls.Create_PR_Attachment(PRHeader.Id,att);
			list<Campaign_Spend__c>  Campaign_Spend_List=BS_PR_TestService_UtilityCls.createCampaignSpends(prHeader.Id,null);
            prHeader.Status__c='Approved By Finance';
            update prHeader;
        }
    }
    @isTest static void BS_PR_CustomSearchforPRs_fetchPRWrapper_Test() { 
        
        String searchKey = 'Test';
        String startDate = Datetime.now().addDays(-1).format('yyyy-MM-dd');
        String endDate = Datetime.now().addDays(1).format('yyyy-MM-dd'); 
        
        List<BS_PR_CustomSearchforPRs.PRWrapper> test = BS_PR_CustomSearchforPRs.fetchPRWrapper(searchKey, startDate, endDate);
        System.assert(test.size() > 0);
    }
}