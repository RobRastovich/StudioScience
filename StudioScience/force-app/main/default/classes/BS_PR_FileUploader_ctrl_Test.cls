/*************************************************************
 * Class Name: BS_PR_FileUploader_ctrl_Test
 * Parent Class: BS_PR_FileUploader_ctrl
 * Authour: Harikrishna P
 * Description: Test class for BS_PR_FileUploader_ctrl_Test
 * Modification Logs:  
**************************************************************/

@istest
public class BS_PR_FileUploader_ctrl_Test {
    @testSetup static void testDataSetup() {
        user adminUser=BS_PR_TestService_UtilityCls.adminUserSetup();
        system.runAs(adminUser){            
            List<Account> AccountDataList=BS_PR_TestService_UtilityCls.setupAccountData();
            List<Account> vendorAccountList=[SELECT id,Name,RecordTypeId from Account WHERE RecordType.Name='Vendor'];
            List<SAP_Company_Code__c> SAPCompanyCodeDataList=BS_PR_TestService_UtilityCls.setupSAPCompanyCodeData(vendorAccountList[0].id);
            PR_Header__c prHeader=BS_PR_TestService_UtilityCls.setupPRHeaderData(vendorAccountList[0].id,SAPCompanyCodeDataList[0].id);            
            BS_PR_TestService_UtilityCls.setupPRAttachments(prHeader.Id);         
        }
    }
    
    @isTest static void BS_PR_SubmitPR_ToSAPTestMethod1() {       
        PR_Header__c prHeader=[SELECT id,status__c,OwnerId FROM PR_Header__c LIMIT 1];
        system.debug('***prHeader...'+prHeader);
        System.assert(prHeader.id!=null);
        List<Attachment> attachments= [SELECT id,Name,Owner.Name,CreatedDate FROM Attachment WHERE ParentId=:prHeader.id];
        System.assert(attachments.size()>0);
        
        test.startTest();
            BS_PR_FileUploader_ctrl prd=new BS_PR_FileUploader_ctrl();
            prd.Parent_id=prHeader.id;
            prd.getAttachmentsList();
        
        	prd.attachment_id=attachments[0].id;
            prd.deleteFile();        	
        
            List<Attachment> attachments_Result=[select id, name from Attachment where parent.id=:PRHeader.Id];
            System.assertEquals(0, attachments_Result.size());
        test.stopTest(); 
    }
       
    @isTest static void BS_PR_SubmitPR_ToSAPTestMethod2() {              
        test.startTest();
            BS_PR_FileUploader_ctrl prd=new BS_PR_FileUploader_ctrl();            
            prd.getAttachmentsList();        
        test.stopTest(); 
    }
}