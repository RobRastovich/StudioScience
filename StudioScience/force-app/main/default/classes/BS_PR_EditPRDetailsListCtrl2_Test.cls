@istest
public class BS_PR_EditPRDetailsListCtrl2_Test {
    @testSetup static void testDataSetup() {
        user adminUser=BS_PR_TestService_UtilityCls.adminUserSetup();
        system.runAs(adminUser){
            List<Campaign__c>  CampaignDataList=BS_PR_TestService_UtilityCls.setupCampaignData();
            List<Account> AccountDataList=BS_PR_TestService_UtilityCls.setupAccountData();
            List<Account> vendorAccountList=[SELECT id,Name,RecordTypeId from Account WHERE RecordType.Name='Vendor'];
            List<SAP_Company_Code__c> SAPCompanyCodeDataList=BS_PR_TestService_UtilityCls.setupSAPCompanyCodeData(vendorAccountList[0].id);
            PR_Header__c prHeader=BS_PR_TestService_UtilityCls.setupPRHeaderData(vendorAccountList[0].id,SAPCompanyCodeDataList[0].id);
            list<PR_Detail__c>  PR_DetailList=BS_PR_TestService_UtilityCls.setupPRDetailsData(prHeader.Id,CampaignDataList);
            system.debug('PR_DetailList...'+PR_DetailList);
        }
    }
    
    @isTest static void editPRDetailsTestMethod1() {
        PR_Header__c prHeader=[SELECT id FROM PR_Header__c LIMIT 1];
        system.debug('***prHeader...'+prHeader);
        test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(prHeader);
            ApexPages.currentPage().getParameters().put('id',prHeader.id);
            BS_PR_EditPRDetailsListCtrl2 prd=new BS_PR_EditPRDetailsListCtrl2(sc);
            List<PR_Detail__c> PRDetailsList=prd.queryPRDetailsList();
            system.assert(PRDetailsList.size()>0);            
            
        	//update the PR details to create phasing records.
        	PRDetailsList=BS_PR_TestService_UtilityCls.update_PRDetails_Create_Update_Phasing(PRDetailsList,'Straight Line');
        
            prd.updatePRDetailsList();
            prd.prdRecordID=PRDetailsList[0].id;
            prd.editRow();
            prd.editAll();
            prd.viewAll();
            prd.saveRow(); 
        	prd.autoSaveRow();
        	
        	//Update the record to pass the error conditions
        	prd.PR_Detail_Map.get(prd.prdRecordID).PR_Amount__c=55000;        	
        	prd.updatePRDetailsList();
        	prd.saveRow();
        	
        	prd.clonePRDetailRecord();
        	prd.clonePRDetailRecord();
        	prd.copyMonthValuesToPRDetails();
        
            prd.cancelRow();
            prd.queryPhasingData();
            prd.showPopup();
            prd.closePopup();
            prd.updatePRDetailRecord();
            prd.updatePhasingList();
            
            prd.cancelAll();
        	prd.deleteRow();
        test.stopTest();
        
    }
}