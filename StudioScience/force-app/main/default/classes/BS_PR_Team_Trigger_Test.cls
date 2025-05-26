@istest
public class BS_PR_Team_Trigger_Test {
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
    
    @isTest static void PR_Team_TriggerTestMethod1() {       
        PR_Header__c prHeader=[select id,ownerId from PR_Header__c limit 1];
        user adminUser=[select id from user where id=:prHeader.ownerId];
        id currentUserid=userinfo.getUserId();
        PR_Team__c pt_SysUser=new PR_Team__c(
                PR_Header__c=prHeader.id,
                Collaborator__c=userinfo.getUserId(),
                Access_Level__c='Edit');
        try{
            insert pt_SysUser;
        }catch(exception e){}
        
        PR_Team__c pt2;
        system.runAs(adminUser){
            test.startTest();           
                PR_Team__c pt=new PR_Team__c(
                    PR_Header__c=prHeader.id,
                    Collaborator__c=currentUserid,
                    Access_Level__c='Edit');
                insert pt;
                delete pt;
                
                pt2=new PR_Team__c(
                    PR_Header__c=prHeader.id,
                    Collaborator__c=currentUserid,
                    Access_Level__c='Edit');
                insert pt2;
            test.stopTest();
        }
        try{
            delete pt2;
        }catch(exception e){}
    }    
}