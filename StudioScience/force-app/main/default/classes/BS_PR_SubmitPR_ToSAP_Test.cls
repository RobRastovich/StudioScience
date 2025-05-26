/*************************************************************
 * Class Name: BS_PR_SubmitPR_ToSAP_Test
 * Parent Class: BS_PR_SubmitPR_ToSAP
 * Authour: Harikrishna P
 * Description: Test class for BS_PR_SubmitPR_ToSAP_Test
 * Modification Logs:  
**************************************************************/
@istest
public class BS_PR_SubmitPR_ToSAP_Test {
    @testSetup static void testDataSetup() {
        user adminUser=BS_PR_TestService_UtilityCls.adminUserSetup();
        system.debug('>>>>>>>>>>>>> enter setup >>>>>>>> ');
        system.runAs(adminUser){
            List<Campaign__c>  CampaignDataList=BS_PR_TestService_UtilityCls.setupCampaignData();
            List<Account> AccountDataList=BS_PR_TestService_UtilityCls.setupAccountData();
            List<Account> vendorAccountList=[SELECT id,Name,RecordTypeId from Account WHERE RecordType.Name='Vendor'];
            system.debug('>> vendorAccountList: ' + vendorAccountList);
            List<SAP_Company_Code__c> SAPCompanyCodeDataList=BS_PR_TestService_UtilityCls.setupSAPCompanyCodeData(vendorAccountList[0].id);
            system.debug('>> SAPCompanyCodeDataList: ' + SAPCompanyCodeDataList);
            PR_Header__c prHeader=BS_PR_TestService_UtilityCls.setupPRHeaderData(vendorAccountList[0].id,SAPCompanyCodeDataList[0].id);
            list<PR_Detail__c>  PR_DetailList=BS_PR_TestService_UtilityCls.setupPRDetailsData(prHeader.Id,CampaignDataList);
            PR_DetailList=BS_PR_TestService_UtilityCls.update_PRDetails_Create_Update_Phasing(PR_DetailList,'Straight Line');
            Attachment att=BS_PR_TestService_UtilityCls.setupPRAttachments(PRHeader.Id);
			BS_PR_TestService_UtilityCls.Create_PR_Attachment(PRHeader.Id,att);
			list<Campaign_Spend__c>  Campaign_Spend_List=BS_PR_TestService_UtilityCls.createCampaignSpends(prHeader.Id,null);
            prHeader.Status__c='Approved By Finance ';
            update prHeader;
            BS_PR_TestService_UtilityCls.createPRStoredCredentials();
        }
    }
    
    @isTest static void BS_PR_SubmitPR_ToSAPTestMethod1() {       
        PR_Header__c prHeader=[SELECT id,Name,Status__c,pr_currency__c,Payment_Terms__c,SAP_Company_Code__c,SAP_Support__c,Vendor_Number__c,
                               Vendor_Name__r.name,CreatedBy.Firstname,CreatedBy.Lastname,OwnerId FROM PR_Header__c LIMIT 1];
        system.debug('***prHeader...'+prHeader);
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'BS_PR_SAP_PR_Response' LIMIT 1];
        String PRResponsebody = sr.Body.toString();
        test.startTest();
            Map<String, String> responseHeaders=new Map<String, String>();
            responseHeaders.put('x-csrf-token','abc123456789');
            responseHeaders.put('Set-Cookie','abc123456789');
            Test.setMock(HttpCalloutMock.class, new BS_PR_SAPCallout_RequestMock(201,'Created',PRResponsebody,responseHeaders));
            ApexPages.StandardController sc = new ApexPages.StandardController(prHeader);
            ApexPages.currentPage().getParameters().put('id',prHeader.id);
            BS_PR_SubmitPR_ToSAP prd=new BS_PR_SubmitPR_ToSAP(sc);
            prd.confirmToSubmitPR();       
        test.stopTest(); 
    }            
}