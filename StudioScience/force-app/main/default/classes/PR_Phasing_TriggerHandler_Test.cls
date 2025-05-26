/*************************************************************
 * Class Name: PR_Phasing_TriggerHandler_Test
 * Parent Class: PR_Phasing_TriggerHandler
 * Authour: Harikrishna P
 * Description: Test class for PR_Phasing_TriggerHandler
 * Modification Logs:  
**************************************************************/

@istest
public class PR_Phasing_TriggerHandler_Test {
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
            list<Campaign_Spend__c>  Campaign_Spend_List=BS_PR_TestService_UtilityCls.createCampaignSpends(prHeader.Id,null);
        }
    }
    
    @isTest static void PR_Phasing_TriggerHandlerTestMethod1() {               
        List<PR_Detail__c> PR_DetailList=[select id,name,PR_Amount__c from PR_Detail__c];
        System.assert(PR_DetailList.size()>0);
        list<PR_Phasing__c> PR_Phasing_QueryResults=[SELECT id FROM PR_Phasing__c];
		System.assert(PR_Phasing_QueryResults.size()>0);
        test.startTest();                   	        	
        	for(PR_Phasing__c ph:PR_Phasing_QueryResults){
                ph.Phasing_Amount__c=10;
            }
        	update PR_Phasing_QueryResults;
        
        test.stopTest();        
    }
    @isTest static void PR_Phasing_TriggerHandlerTestMethod2() {               
        PR_Header__c prHeader=[SELECT id,Status__c FROM PR_Header__c LIMIT 1];
        List<PR_Detail__c> PR_DetailList=[select id,name from PR_Detail__c];
        System.assert(PR_DetailList.size()>0);
        list<PR_Phasing__c> PR_Phasing_QueryResults=[SELECT id FROM PR_Phasing__c];
		System.assert(PR_Phasing_QueryResults.size()>0);
        test.startTest();                   	        	
        	prHeader.Status__c='Submitted';	
        	Update prHeader;	
        	for(PR_Phasing__c ph:PR_Phasing_QueryResults){
                ph.Campaign_Spend__c=null;
            }
        	update PR_Phasing_QueryResults;
        
        test.stopTest();        
    }
    
    @isTest static void PR_Phasing_TriggerHandlerTestMethod3() {
        List<PR_Detail__c> PR_DetailList=[select id,name from PR_Detail__c];
        System.assert(PR_DetailList.size()>0);
        list<PR_Phasing__c> PR_Phasing_QueryResults=[SELECT id FROM PR_Phasing__c];
		System.assert(PR_Phasing_QueryResults.size()>0);
        
        test.startTest();                   	        	
        	
        	Delete PR_Phasing_QueryResults;
        
        test.stopTest();        
    }
}