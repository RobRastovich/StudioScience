@istest
public class BS_PRDetail_Trigger_Test {
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
    
    @isTest static void PRDetail_TriggerTestMethod1() {       
        test.startTest();           
            List<PR_Detail__c> PR_DetailList=[select id,name from PR_Detail__c];
        	PR_DetailList=BS_PR_TestService_UtilityCls.update_PRDetails_Create_Update_Phasing(PR_DetailList,'Straight Line');                     
        test.stopTest();        
    }
    @isTest static void PRDetail_TriggerTestMethod2() {
        test.startTest();           
            List<PR_Detail__c> PR_DetailList=[select id,name from PR_Detail__c];
        	PR_DetailList=BS_PR_TestService_UtilityCls.update_PRDetails_Create_Update_Phasing(PR_DetailList,'Monthly');                                          
        test.stopTest();        
    }
    @isTest static void PRDetail_TriggerTestMethod3() {
        test.startTest();           
            List<PR_Detail__c> PR_DetailList=[select id,name from PR_Detail__c];
        	PR_DetailList=BS_PR_TestService_UtilityCls.update_PRDetails_Create_Update_Phasing(PR_DetailList,'Monthly');
        test.stopTest();        
    }
    @isTest static void PRDetail_TriggerTestMethod4() {        
        PR_Header__c prHeader=[SELECT id,Status__c FROM PR_Header__c LIMIT 1];
        test.startTest();           
            List<PR_Detail__c> PR_DetailList=[select id,name,Campaign__c,Campaign_ID__c,Campaign_Name__c,Brand__c,
                                              GLAccountType__c,GL_Code2__c,IOCode__c,Territory__c,GLDescription2__c 
                                              from PR_Detail__c WHERE PR_Header__c=:prHeader.id];            
        	List<PR_Detail__c> PR_Detail_ClonedList=new List<PR_Detail__c>();
        	for(PR_Detail__c prdrecord: PR_DetailList){
                PR_Detail__c prd=new PR_Detail__c(
                    PR_Header__c=prHeader.id
                    ,Campaign__c=prdrecord.Campaign__c
                    ,Campaign_ID__c=prdrecord.Campaign_ID__c
                    ,Campaign_Name__c=prdrecord.Campaign_Name__c
                    ,Brand__c=prdrecord.Brand__c
                    ,GLAccountType__c=prdrecord.GLAccountType__c
                    //,GL_Code2__c=prdrecord.GL_Code2__c
                    ,IOCode__c=prdrecord.IOCode__c
                    ,Territory__c=prdrecord.Territory__c
                    ,GLDescription2__c=prdrecord.GLDescription2__c
                  ,Cloned_From__c=prdrecord.id
                    ,Unique_Key__c=prHeader.id+prdrecord.Campaign_ID__c+prdrecord.IOCode__c+prdrecord.id
                );
                PR_Detail_ClonedList.add(prd);
            }
            insert PR_Detail_ClonedList;
        	PR_DetailList=BS_PR_TestService_UtilityCls.update_PRDetails_Create_Update_Phasing(PR_Detail_ClonedList,'Monthly');
        test.stopTest();        
    }
    
    @isTest static void PRDetail_TriggerTestMethod5() {
        test.startTest();           
            delete [select id,name from PR_Detail__c];                                           
        test.stopTest();        
    }
}