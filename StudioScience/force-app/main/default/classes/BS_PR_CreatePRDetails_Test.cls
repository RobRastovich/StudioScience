@istest
public class BS_PR_CreatePRDetails_Test {
    @testSetup static void testDataSetup() {
        user adminUser=BS_PR_TestService_UtilityCls.adminUserSetup();
        system.runAs(adminUser){
            List<Campaign__c>  CampaignDataList=BS_PR_TestService_UtilityCls.setupCampaignData();
            List<Account> AccountDataList=BS_PR_TestService_UtilityCls.setupAccountData();
            List<Account> vendorAccountList=[SELECT id,Name,RecordTypeId from Account WHERE RecordType.Name='Vendor'];
            List<SAP_Company_Code__c> SAPCompanyCodeDataList=BS_PR_TestService_UtilityCls.setupSAPCompanyCodeData(vendorAccountList[0].id);
            PR_Header__c prHeader=BS_PR_TestService_UtilityCls.setupPRHeaderData(vendorAccountList[0].id,SAPCompanyCodeDataList[0].id);
        }
    }
    
    @isTest static void campaignSearchTestMethod1() {
        PR_Header__c prHeader=[SELECT id FROM PR_Header__c LIMIT 1];
        test.startTest();
            List<Campaign__c> Campaigns_Created_List=BS_PR_CreatePRDetails.fetchCampaignWrapper('test',prHeader.id,'USC0');
			System.assert(Campaigns_Created_List.size()>0);
            BS_PR_CreatePRDetails.insertPRDetails(prHeader.id, JSON.serialize(Campaigns_Created_List));
        test.stopTest();
        BS_PR_CreatePRDetails.insertPRDetails(prHeader.id, JSON.serialize(Campaigns_Created_List));
        List<PR_Detail__c> PR_DetailList=[select id,name from PR_Detail__c];
        System.assert(PR_DetailList.size()>0);
    }    
}