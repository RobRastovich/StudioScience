/**
	@company : Copyright © 2020, BeamSuntory
	All rights reserved.
	Redistribution and use in source form, with or without modification, are prohibited without the express written consent of BeamSuntory,Inc.
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
	INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
	IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	@website : https://www.beamsuntory.com/
	@author BeamSuntory
	@version V_1.0
	@date 25/01/2021
	@description This is test class for batch that is used to update PR details on Vendor
*/
@isTest
public class TST_PR_UpdateVendorPRDetails {
    
    //Data creation
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
            prHeader.Status__c = 'Submitted';
            update prHeader;
            list<Campaign_Spend__c>  Campaign_Spend_List=BS_PR_TestService_UtilityCls.createCampaignSpends(prHeader.Id,null);
        }
    }
    
    //test the batchable part
    public static testMethod void testBCH_PR_UpdateVendorPRDetails() {
        
        PR_Header__c prHeader = [SELECT Id, Status__c, PR_Year__c, Vendor_Name__c, Total_PR_Amount_USD__c FROM PR_Header__c LIMIT 1];
        
        Boolean arePRsOver50KCurrentyear = prHeader.Total_PR_Amount_USD__c>= 50000;
        
        Test.StartTest();
        ID batchprocessid = Database.executeBatch(new BCH_PR_UpdateVendorPRDetails(100, new List<Id>{prHeader.Vendor_Name__c}));
        Test.StopTest();
        
        Account vendor = [Select Id, Name, Total_PR_amount_Current_year__c, PRs_Over_50K_Current_year__c, PRs_Over_50K_Previous_year__c FROM Account where ID=:prHeader.Vendor_Name__c];
        System.assertEquals(arePRsOver50KCurrentyear, vendor.PRs_Over_50K_Current_year__c);
        
    }
    
    //test the schedulable part
    public static testMethod void testScheduledBCH_PR_UpdateVendorPRDetails() {
        
        PR_Header__c prHeader = [SELECT Id, Status__c, PR_Year__c, Vendor_Name__c, Total_PR_Amount_USD__c FROM PR_Header__c LIMIT 1];
        Boolean arePRsOver50KCurrentyear = prHeader.Total_PR_Amount_USD__c>= 50000;
        
        //Specifies every year on 1 January 20'o Clock
        String CRON_EXP = '0 0 20 1 1 ? *';
        
        Test.StartTest();
        String jobId = System.Schedule('Vendor PR Details Update ' + String.valueOf(DateTime.now()), CRON_EXP, new BCH_PR_UpdateVendorPRDetails());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        System.assertEquals(String.valueOf(Date.today().year()+1) + '-01-01 20:00:00', String.valueOf(ct.NextFireTime));
        Test.StopTest();
        
        Account vendor = [Select Id, Name, Total_PR_amount_Current_year__c, PRs_Over_50K_Current_year__c, PRs_Over_50K_Previous_year__c FROM Account where ID=:prHeader.Vendor_Name__c];
        System.assertEquals(arePRsOver50KCurrentyear, vendor.PRs_Over_50K_Current_year__c);
        
    }
}