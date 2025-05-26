/*************************************************************
 * Class Name: BS_PRHeader_Trigger_Test
 * Parent Class: PRDetail_TriggerHandler
 * Authour: Harikrishna P
 * Description: Test class for PRDetail_TriggerHandler
 * Modification Logs:  
**************************************************************/

@istest
public class BS_PRHeader_Trigger_Test {
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
            BS_PR_TestService_UtilityCls.setupPRAttachments(PRHeader.Id);
            list<Campaign_Spend__c>  Campaign_Spend_List=BS_PR_TestService_UtilityCls.createCampaignSpends(prHeader.Id,null);
        }
    }
    
    @isTest static void PRHeader_TriggerTestMethod1() {
        PR_Header__c prHeader=[SELECT id,Status__c FROM PR_Header__c LIMIT 1];
        list<PR_Phasing__c> PR_Phasing_QueryResults=[SELECT id FROM PR_Phasing__c Where PR_Header__c =:prHeader.id];
        list<Campaign_Spend__c> Campaign_Spend_QueryResults=[SELECT id FROM Campaign_Spend__c Where PR_Header__c =:prHeader.id];
        System.assert(PR_Phasing_QueryResults.size()>0);        
        //System.assert(Campaign_Spend_QueryResults.size()>0);
        test.startTest();                       
            prHeader.Status__c='Submitted';
            prHeader.OwnerId=userinfo.getUserId();
            update prHeader;
        test.stopTest();
        prHeader.Status__c='Approved By Finance';         
        update prHeader;
        prHeader.Status__c='New';         
        update prHeader;         
    }
    
    @isTest static void PRHeader_TriggerTestMethod2() {
        PR_Header__c prHeader=[SELECT id,Status__c FROM PR_Header__c LIMIT 1];                
        test.startTest();                       
            prHeader.Status__c='Completed';         
            update prHeader;
        test.stopTest();        
        
    }
    
    @isTest static void PRHeader_TriggerTestMethod3() {
        PR_Header__c prHeader=[SELECT id,Status__c FROM PR_Header__c LIMIT 1];                
        test.startTest();                       
            prHeader.Status__c='Canceled';         
            update prHeader;
        test.stopTest();               
    }
   
    @isTest static void PRHeader_TriggerTestMethod4() {
        PR_Header__c prHeader=[SELECT id,PR_Currency__c FROM PR_Header__c LIMIT 1];                
        test.startTest();                       
            prHeader.PR_Currency__c='CAD';         
            update prHeader;
        test.stopTest();                 
    }
    @isTest static void PRHeader_TriggerTestMethod5(){
        PRHeader_TriggerHandler prg = new PRHeader_TriggerHandler();
        PR_Header__c prHeader=[SELECT id,PR_Currency__c FROM PR_Header__c LIMIT 1]; 
        Map<id,PR_Header__c> hMap = new Map<Id,PR_Header__c>();
        hmap.put(prHeader.id,prHeader);
        PRHeader_TriggerHandler.UpdatingPRAmount(hmap);
    }
    
    
}