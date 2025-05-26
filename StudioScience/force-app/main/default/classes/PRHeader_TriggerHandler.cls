/**************************************************************************************
Apex Class Name     : PRHeader_TriggerHandler 
Test Class          : BS_PRHeader_Trigger_Test 
Auther              : Harikrishna P 
Function            : Handles events from the PRHeader_Trigger trigger 
Updates :
*************************************************************************************/

public class PRHeader_TriggerHandler{
public static boolean isFirstTime=true;
    public static void handleBeforeInsert(list<PR_Header__c> Trigger_new) {
        System.debug('PRHeader_TriggerHandler...handleBeforeInsert...');
        for(PR_Header__c prh:Trigger_new){
            prh.CurrencyIsoCode=prh.PR_Currency__c;
        }
    }
    public static void handleBeforeUpdate(Map<Id, PR_Header__c> Trigger_newMap, Map<Id, PR_Header__c> Trigger_oldMap) {
        System.debug('PRHeader_TriggerHandler...handleBeforeUpdate...');
        for(PR_Header__c prh:Trigger_newMap.values()){
            if(prh.CurrencyIsoCode!=prh.PR_Currency__c) prh.CurrencyIsoCode=prh.PR_Currency__c;
        }

    }
    
    public static void handleAfterUpdate(Map<Id, PR_Header__c> Trigger_newMap, Map<Id, PR_Header__c> Trigger_oldMap) {
        System.debug('PRHeader_TriggerHandler...handleAfterUpdate...');
        set<id> prHeaderIDSet=new set<id>();
        set<id> vendorIDSet=new set<id>();
        set<id> campaign_PR_HeaderIDSet=new set<id>();
        set<id> CanceledPR_HeaderIdSet=new set<id>();
        set<id> prHeaderIDSet_CurrencyChange=new set<id>();
        Map<Id, PR_Header__c> approvalValidation_Map=new Map<Id, PR_Header__c>();
        Map<Id,PR_Header__c>VendorMap = new Map<Id,PR_header__c>();
        for(PR_Header__c prh:Trigger_newMap.values()){
            if(prh.Status__c=='Submitted' && Trigger_oldMap.get(prh.id).status__c=='New' && prh.OwnerId==Userinfo.getUserId()){
                System.debug('submitted for approval....'+prh);                
                campaign_PR_HeaderIDSet.add(Prh.id);
            }            
            if(prh.PR_Currency__c!= Trigger_oldMap.get(prh.id).PR_Currency__c){                                
                prHeaderIDSet_CurrencyChange.add(Prh.id);
            }
            if(prh.Status__c=='Approved By Finance'){
                approvalValidation_Map.put(prh.id,prh);                
            }
            if(prh.Status__c=='Submitted' && Trigger_oldMap.get(prh.id).status__c!='Submitted'){                                
                vendorIDSet.add(prh.Vendor_Name__c);
            }
            if((prh.Status__c=='Canceled' && Trigger_oldMap.get(prh.id).status__c!='Canceled') ||
               (prh.Status__c=='New' && Trigger_oldMap.get(prh.id).status__c!='New')){                
                   CanceledPR_HeaderIdSet.add(Prh.id);
               }
          
          
            //Added by Sripal             
            /*if((prh.Procurement_Rejected__c || prh.Finance_Rejected__c || prh.Approval_Process_Recalled__c) && prh.Status__c=='New'){
               system.debug('===============firsttime'+prh.Approval_Process_Recalled__c);
                VendorMap.put(prh.Vendor_Name__c,prh);
                
            }*/
            
            //added by arun sharma
            system.debug('=========Procurement_Rejected__c ======='+prh.Procurement_Rejected__c+'=================rejected old=='+Trigger_oldMap.get(prh.id).Procurement_Rejected__c+'===='+prh.Status__c);
            system.debug('=========Finance_Rejected__c ======='+prh.Finance_Rejected__c +'=================rejected old=='+Trigger_oldMap.get(prh.id).Finance_Rejected__c+'===='+prh.Status__c);
            system.debug('=========Approval_Process_Recalled__c ======='+prh.Approval_Process_Recalled__c +'=================old=='+Trigger_oldMap.get(prh.id).Approval_Process_Recalled__c +'===='+prh.Status__c);
            if(((prh.Procurement_Rejected__c && prh.Procurement_Rejected__c != Trigger_oldMap.get(prh.id).Procurement_Rejected__c) 
                || (prh.Finance_Rejected__c && (prh.Finance_Rejected__c != Trigger_oldMap.get(prh.id).Finance_Rejected__c))
                || (prh.Approval_Process_Recalled__c 
                && (prh.Approval_Process_Recalled__c != Trigger_oldMap.get(prh.id).Approval_Process_Recalled__c))
                ) && prh.Status__c=='New'){
                system.debug('===============firsttime'+prh.Approval_Process_Recalled__c);
                VendorMap.put(prh.Vendor_Name__c,prh);
            }
        }
           
        if(!VendorMap.isEmpty()) UpdatingPRAmount(VendorMap);
        
        if(vendorIDSet.size()>0) rollup_PRAmount_ToVendor(vendorIDSet);
        if(prHeaderIDSet_CurrencyChange.size()>0) updatePRDetails(prHeaderIDSet_CurrencyChange);
        if(campaign_PR_HeaderIDSet.size()>0) create_Campaign_PRRecords(campaign_PR_HeaderIDSet);
        if(CanceledPR_HeaderIdSet.size()>0) deleteCampaignSpendRecords(CanceledPR_HeaderIdSet);
        if(!approvalValidation_Map.isEmpty()) validateBeforeApproval(approvalValidation_Map);
    }    
    public static void validateBeforeApproval(Map<Id, PR_Header__c> Trigger_newMap) {
        Map<Id, PR_Detail__c> PRDetail_Map=new Map<Id, PR_Detail__c>();
        Map<Id, PR_Detail__c> PRDetail_CCode_Map=new Map<Id, PR_Detail__c>();
        for(PR_Detail__c prd:[select id,PR_Header__c,OverAll_Status__c,SAP_Company_Code_Matching__c from PR_Detail__c Where 
                              PR_Header__c IN:Trigger_newMap.keyset() AND (OverAll_Status__c=false OR SAP_Company_Code_Matching__c=false)]){
            if(prd.OverAll_Status__c==false) PRDetail_Map.put(prd.PR_Header__c, prd);
            if(prd.SAP_Company_Code_Matching__c==false) PRDetail_CCode_Map.put(prd.PR_Header__c, prd);
        }
        for(PR_Header__c prh:Trigger_newMap.values()){            
            if(prh.Status__c=='Approved By Finance' && (prh.PR_Details_Approved_By_Finance__c >0 || PRDetail_Map.containsKey(prh.id))){             
                prh.Status__c.adderror('You can not approve the PR if rejected Details exist. Click on reject to submit back to requester.');
            }
            if(prh.Status__c=='Approved By Finance' && PRDetail_CCode_Map.containsKey(prh.id)){             
                prh.Status__c.adderror('You can not approve this PR. IOs with unmatched Company Codes exist. ');
            }
        }
    }
    public static void UpdatingPRAmount(Map<Id,PR_Header__c>VendorPRMap){
        List<Account>Vendors = new List<Account>();
        Vendors = [SELECT  id,Name,Total_PR_amount_Current_year__c FROM Account WHERE ID IN: VendorPRMap.keyset()];
        
        for(Account acc:Vendors){
            system.debug('================== before Total_PR_amount_Current_year__c ==========='+acc.Total_PR_amount_Current_year__c+'====='+VendorPRMap.get(acc.id).Total_PR_Amount__c);
            // INC0022405(SAL-643) | 25 Jan 2021 | As PR's PR Amount USD is added for Total PR amount on account, it should be subtracted 
            acc.Total_PR_amount_Current_year__c = acc.Total_PR_amount_Current_year__c - VendorPRMap.get(acc.id).Total_PR_Amount_USD__c;
            system.debug('================== after Total_PR_amount_Current_year__c ==========='+acc.Total_PR_amount_Current_year__c+'====='+VendorPRMap.get(acc.id).Total_PR_Amount__c);
        }
        update Vendors;
        
    }
    @future
    public static void updatePRDetails(set<id> prHeaderIDSet_CurrencyChange){
        list<PR_Detail__c> PR_Detail_list=new list<PR_Detail__c>();
        list<PR_Phasing__c> Phasing_list=new list<PR_Phasing__c>();
        for(PR_Detail__c prd: [select id,PR_Header__r.PR_Currency__c from PR_Detail__c where PR_Header__c IN:prHeaderIDSet_CurrencyChange]){            
            prd.CurrencyIsoCode=prd.PR_Header__r.PR_Currency__c;
            PR_Detail_list.add(prd);
        }
        for(PR_Phasing__c ph: [select id,PR_Header__r.PR_Currency__c from PR_Phasing__c where PR_Header__c IN:prHeaderIDSet_CurrencyChange]){            
            ph.CurrencyIsoCode=ph.PR_Header__r.PR_Currency__c;
            Phasing_list.add(ph);
        }
        if(PR_Detail_list.size()>0) database.update(PR_Detail_list,false);
        if(Phasing_list.size()>0) database.update(Phasing_list,false);        
    }
    
    @future
    public static void rollup_PRAmount_ToVendor(set<id> vendorIDSet){
        string PRYear=string.valueOf(system.today().year());
        list<Account> vendorAccoutListToUpdate=new list<Account>();
        for(AggregateResult agr: [SELECT Vendor_Name__c,Sum(Total_PR_Amount__c) pramt FROM PR_Header__c
                                  WHERE Vendor_Name__c IN:vendorIDSet AND PR_Year__c=:PRYear  AND Total_PR_Amount__c > 0 AND (Status__c='Submitted' OR Status__c='Approved By Procurement' OR Status__c='Approved By Finance' OR Status__c='Completed')
                                  GROUP BY Vendor_Name__c]){
                                      account acc=new account(Id=(id)agr.get('Vendor_Name__c'),
                                                              Total_PR_amount_Current_year__c=(decimal)agr.get('pramt'));
                                      system.debug('=======Total_PR_amount_Current_year__c======='+acc.Total_PR_amount_Current_year__c);                        
                                      vendorAccoutListToUpdate.add(acc);
                                  }
         
        if(vendorAccoutListToUpdate.size()>0){
            database.update(vendorAccoutListToUpdate,false);
        }
    }
    
    @future
    public static void create_Campaign_PRRecords(set<id> prHeaderIDSet){
        map<string,Campaign_PR__c> Campaign_PRMap=new map<string,Campaign_PR__c>();
        for(PR_Detail__c prd: [select id,Campaign_ID__c,PR_Header__c,IOCode__c,GL_Code2__c from PR_Detail__c where PR_Header__c IN:prHeaderIDSet]){            
            Campaign_PR__c cpr=new Campaign_PR__c(
                Campaign__c=prd.Campaign_ID__c
                ,PR_Header__c=prd.PR_Header__c                
                ,Unique_Key__c=prd.Campaign_ID__c+prd.PR_Header__c+prd.IOCode__c+prd.GL_Code2__c
            );
            Campaign_PRMap.put(cpr.Unique_Key__c,cpr);
        }
        if(!Campaign_PRMap.isEmpty()){
            Schema.SObjectField f = Campaign_PR__c.Fields.Unique_Key__c;            
            Database.upsertResult [] upsertResultList = database.upsert(Campaign_PRMap.values(),f,false);
            for (Database.upsertResult sr : upsertResultList) {
                if (sr.isSuccess()) {
                    // Operation was successful
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('error has occurred.' + err.getStatusCode() + ': ' + err.getMessage());                    
                        System.debug('fields that affected this error: ' + err.getFields());                        
                    }
                }
            }
        } 
    }
    @future
    public static void deleteCampaignSpendRecords(set<id> HeaderIdSet){
        try{            
            Delete [SELECT id FROM Campaign_Spend__c WHERE RecordType.Name='Pending' AND PR_Header__c IN: HeaderIdSet];    
        }catch(system.DmlException ex){
            String errorMessage = 'Error deleting campaign Spend Records ' + ex.getMessage() + '\n' + ex.getStackTraceString();
            CreateExceptionLog.insertErrorLog('PRHeader_TriggerHandler', 'deleteCampaignSpendRecords', String.valueOf(errorMessage), 'Error');
            system.debug('deleteCampaignSpendRecords:::exception in deletion...'+ex);
        } 
    }
    
    
}