/*************************************************************
 * Class Name: BS_PR_SubmitPRForApproval_VFCtrl_Test
 * Parent Class: BS_PR_SubmitPRForApproval_VFCtrl
 * Authour: Harikrishna P
 * Description: Test class for BS_PR_SubmitPRForApproval_VFCtrl
 * Modification Logs:  
**************************************************************/
@istest
public class BS_PR_SubmitPRForApproval_VFCtrl_Test {
    @testSetup static void testDataSetup() {
        user adminUser=BS_PR_TestService_UtilityCls.adminUserSetup();
        system.runAs(adminUser){
            List<Campaign__c>  CampaignDataList=BS_PR_TestService_UtilityCls.setupCampaignData();
            List<Account> AccountDataList=BS_PR_TestService_UtilityCls.setupAccountData();
            List<Account> vendorAccountList=[SELECT id,Name,RecordTypeId from Account WHERE RecordType.Name='Vendor'];
            List<SAP_Company_Code__c> SAPCompanyCodeDataList=BS_PR_TestService_UtilityCls.setupSAPCompanyCodeData(vendorAccountList[0].id);
            PR_Header__c prHeader=BS_PR_TestService_UtilityCls.setupPRHeaderData(vendorAccountList[0].id,SAPCompanyCodeDataList[0].id);
            list<PR_Detail__c>  PR_DetailList=BS_PR_TestService_UtilityCls.setupPRDetailsData(prHeader.Id,CampaignDataList);            
        }
    }
    
    @isTest static void PR_SubmitPRForApprovalTestMethod1() {       
        PR_Header__c prHeader=[SELECT id,status__c,OwnerId FROM PR_Header__c LIMIT 1];
        system.debug('***prHeader...'+prHeader);
        user adminUser=[select id from user where id=:prHeader.ownerId];
        list<PR_Detail__c>  PR_DetailList=[select id from PR_Detail__c];        
        system.runAs(adminUser){
            PR_DetailList=BS_PR_TestService_UtilityCls.update_PRDetails_Create_Update_Phasing(PR_DetailList,'Straight Line');            
            BS_PR_TestService_UtilityCls.setupPRAttachments(PRHeader.Id);
            test.startTest();
                ApexPages.StandardController sc = new ApexPages.StandardController(prHeader);
                ApexPages.currentPage().getParameters().put('id',prHeader.id);
                BS_PR_SubmitPRForApproval_VFCtrl prd=new BS_PR_SubmitPRForApproval_VFCtrl(sc);
                prd.SubmitPR();             
            test.stopTest(); 
        }
    }
    @isTest static void PR_SubmitPRForApprovalTestMethod2() {       
        PR_Header__c prHeader=[SELECT id,OwnerId FROM PR_Header__c LIMIT 1];
        system.debug('***prHeader...'+prHeader);
        prHeader.Status__c='Submitted';
        update prHeader;
        test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(prHeader);
            ApexPages.currentPage().getParameters().put('id',prHeader.id);
            BS_PR_SubmitPRForApproval_VFCtrl prd=new BS_PR_SubmitPRForApproval_VFCtrl(sc);          
            try{
                prd.SubmitPR();    
            }catch(exception e){} 
                
        test.stopTest(); 
    }
    
    @isTest static void PR_SubmitPRForApprovalTestMethod3() {       
        PR_Header__c prHeader=[SELECT id,status__c,OwnerId FROM PR_Header__c LIMIT 1];
        system.debug('***prHeader...'+prHeader);
        list<PR_Detail__c>  PR_DetailList=[select id from PR_Detail__c];
        PR_DetailList=BS_PR_TestService_UtilityCls.update_PRDetails_Create_Update_Phasing(PR_DetailList,'Straight Line');        
        BS_PR_TestService_UtilityCls.setupPRAttachments(PRHeader.Id);
        List<Campaign__c> CampaignList = [Select id from Campaign__c];
        for(Campaign__c cmp: CampaignList){
            cmp.PlannedCampaignSpend__c=0;
            cmp.Comments__c='changing Campaign Budget to fail the spend record creation';
        }
        update CampaignList;
        user adminUser=[select id from user where id=:prHeader.ownerId];
        
        system.runAs(adminUser){            
            test.startTest();
                ApexPages.StandardController sc = new ApexPages.StandardController(prHeader);
                ApexPages.currentPage().getParameters().put('id',prHeader.id);
                BS_PR_SubmitPRForApproval_VFCtrl prd=new BS_PR_SubmitPRForApproval_VFCtrl(sc);
                try{
                    prd.SubmitPR();    
                }catch(exception e){}
                    
            test.stopTest(); 
        }
    }
}