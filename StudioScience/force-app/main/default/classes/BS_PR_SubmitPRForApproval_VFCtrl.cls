/**************************************************************************************
 Apex Class Name     : BS_PR_SubmitPRForApproval_VFCtrl
 Created Date        : 10-Dec-2019
 Auther              : Harikrishna P 
 Function            : This class will submit the PR and creates the Campaign Spend records.
 Test Class          : BS_PR_SubmitPRForApproval_VFCtrl_Test
 Updates :
*************************************************************************************/

public class BS_PR_SubmitPRForApproval_VFCtrl{    
    
    id PR_Headerid;
    public PR_Header__c PRHeaderRec{set;get;}
    map<id,PR_Phasing__c> PR_Phasing_Map;
    public boolean stopProcess{set;get;}
    public boolean displaySubmitPR{set;get;}
    list<PR_Detail__c> PR_Detail_NotEligibleForSubmission=new list<PR_Detail__c>();
    list<PR_Detail__c> PR_Detail_SAPCompanyCodeNotMatching=new list<PR_Detail__c>();
    set<string> PR_Detail_Exceeding_CampaignBalance=new set<string>();
    public static boolean handleCampaignSpendBeforeInsert_IsExecuted=false;
    public BS_PR_SubmitPRForApproval_VFCtrl() {
        
    }
    public BS_PR_SubmitPRForApproval_VFCtrl(ApexPages.StandardController controller) {
        stopProcess=false;
        displaySubmitPR=true;
        PR_Headerid=ApexPages.currentPage().getParameters().get('id');
        PRHeaderRec=[SELECT id,Status__c,OwnerId,Vendor_Company_Code_Status__c,PR_Details_With_No_Phasing__c,PR_Details_Records_Count__c,
                     Total_PR_Amount__c,Total_Phasing_Amount__c,Total_PR_Amount_USD__c
                     from PR_Header__c where id=:PR_Headerid];        
        try{
            for(PR_Detail__c prd:[select id,PR_Header__c,OverAll_Status__c,SAP_Company_Code_Matching__c from PR_Detail__c Where 
                              PR_Header__c =:PR_Headerid AND (OverAll_Status__c=false OR SAP_Company_Code_Matching__c=false)]){
                if(prd.OverAll_Status__c==false) PR_Detail_NotEligibleForSubmission.add(prd);
                if(prd.SAP_Company_Code_Matching__c==false) PR_Detail_SAPCompanyCodeNotMatching.add(prd);
            }
            for(AggregateResult agr:[SELECT sum(PR_Amount_USD__c) pramt,avg(Campaign_Balance_USD__c) campBal,IOCode__c FROM PR_Detail__c 
                                 WHERE PR_Header__c=:PR_Headerid GROUP BY IOCode__c]){
                decimal PR_AmountUSD=(decimal)agr.get('pramt');
                decimal Campaign_BalanceUSD=(decimal)agr.get('campBal');                                 
                if(PR_AmountUSD>Campaign_BalanceUSD) PR_Detail_Exceeding_CampaignBalance.add((string)agr.get('IOCode__c'));                        
            }
        } catch(exception e){
            system.debug('exception e..'+e);
        }       
    }
    public pagereference SubmitPR(){
        list<Attachment> prAttachmentList=[select id,ParentId from Attachment where ParentId=:PR_Headerid];                                            
        if(PRHeaderRec.Status__c!='New'){           
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'PR already submitted for approval. '));
            stopProcess=true;
            displaySubmitPR=false;
        }
        if(PRHeaderRec.OwnerId!=Userinfo.getUserId()){          
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'You are not allowed to submit the PR. '));
            stopProcess=true;
            displaySubmitPR=false;
        }       
        if(prAttachmentList.isEmpty()){            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'An attachment is required to submit the PR request. '));
            stopProcess=true;
            displaySubmitPR=false;
        }
        if(PR_Detail_Exceeding_CampaignBalance!=null && PR_Detail_Exceeding_CampaignBalance.size()>0){            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Insufficient Campaign Balance. '+PR_Detail_Exceeding_CampaignBalance));
            stopProcess=true;
            displaySubmitPR=false;
        }
        if(PR_Detail_NotEligibleForSubmission!=null && PR_Detail_NotEligibleForSubmission.size()>0){            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please correct all PR Detail lines with errors. Errors are identified with a red flag. '));
            stopProcess=true;
            displaySubmitPR=false;
        }
        if(PR_Detail_SAPCompanyCodeNotMatching!=null && PR_Detail_SAPCompanyCodeNotMatching.size()>0){            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'You can not submit this PR for approval. IOs with unmatched Company Codes exist. '));
            stopProcess=true;
            displaySubmitPR=false;
        }
        if(PRHeaderRec.PR_Details_Records_Count__c==null || PRHeaderRec.PR_Details_Records_Count__c==0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'No PR Details found.  Please add PR Details before submitting. '));
            stopProcess=true;
            displaySubmitPR=false;
        }
        if(PRHeaderRec.Total_PR_Amount__c.setScale(2)!=PRHeaderRec.Total_Phasing_Amount__c.setScale(2)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'PR Details and Phasing amount mismatched. Please review PR Detail records with red flag. '));
            stopProcess=true;
            displaySubmitPR=false;
        }
        if(PRHeaderRec.PR_Details_With_No_Phasing__c>0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Phasing records are missing. Please correct all PR Detail lines with red flags. '));
            stopProcess=true;
            displaySubmitPR=false;
        }
        if(!PRHeaderRec.Vendor_Company_Code_Status__c){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Inactive Vendor Company Code. '));
            stopProcess=true;
            displaySubmitPR=false;
        }
        if(!stopProcess) createCampaignSpends();        
        return null;
    }
    public list<Campaign_Spend__c> campaignSpendsFieldsMaping(set<id> phasingIds) {
        PR_Phasing_Map=new map<id,PR_Phasing__c>([SELECT id,Campaign_Spend__c,Month__c,Phasing_Amount__c,Phasing_Amount_USD__c,PR_Detail__c,Delivery_Date__c,
                              PR_Detail__r.Name,PR_Detail__r.Campaign__c,PR_Detail__r.Campaign_Balance__c,PR_Detail__r.GLAccountType__c,IO_Code__c,Campaign__c,
                              PR_Detail__r.GL_Code2__c,PR_Detail__r.GL_Code_Description__c,PR_Detail__r.GL_Code_Options__c,PR_Header__c,PR_Header__r.name,
                              PR_Detail__r.GL_Comments__c,PR_Detail__r.GLDescription2__c,PR_Detail__r.GL_Details__c,PR_Detail__r.IOCode__c
                              FROM PR_Phasing__c WHERE PR_Header__c =: PR_Headerid OR ID IN:phasingIds]);
        map<string,string> monthmap=new map<string,string>{'1'=>'Jan','2'=>'Feb','3'=>'Mar','4'=>'Apr',
        '5'=>'May','6'=>'Jun','7'=>'Jul','8'=>'Aug','9'=>'Sep','10'=>'Oct','11'=>'Nov','12'=>'Dec'};        
        Id CSRecordTypeId = Schema.SObjectType.Campaign_Spend__c.getRecordTypeInfosByName().get('Pending').getRecordTypeId();                        
        list<Campaign_Spend__c> Campaign_Spend_CreateList=new list<Campaign_Spend__c>();        
        for(PR_Phasing__c ph:PR_Phasing_Map.values()){            
            Campaign_Spend__c cs=new Campaign_Spend__c(
                Amount_USD__c=ph.Phasing_Amount_USD__c,
                Amount__c=ph.Phasing_Amount_USD__c,
                IOCode__c=ph.IO_Code__c,
                ParentCampaign__c=ph.Campaign__c,
                Forecast_Month__c=monthmap.get(ph.Month__c),                
                RecordTypeID=CSRecordTypeId,
                CurrencyIsoCode='USD',                
                Status__c='New',
                Document_Number__c=ph.PR_Header__r.name,
                //Posting_Date__c=lastDayOfMonth,
                Posting_Date__c=system.today(),
                Debit_Date__c=ph.Delivery_Date__c,
                Document_Date__c=ph.Delivery_Date__c,
                PR_Unique_key__c=ph.id,
                PR_Header__c=ph.PR_Header__c,
                PR_Phasing__c=ph.id);
            Campaign_Spend_CreateList.add(cs);
        }
        system.debug('Campaign_Spend_CreateList...'+Campaign_Spend_CreateList);
        return Campaign_Spend_CreateList;
    }
    public pagereference createCampaignSpends() {                
        list<Campaign_Spend__c> Campaign_Spend_CreateList=campaignSpendsFieldsMaping(null);
        // Create a savepoint to rollback if the Campaign_Spend creation is failed for at least one phasing.
        Savepoint sp = Database.setSavepoint();                      
        set<string> errorSet=new set<string>();
        if(Campaign_Spend_CreateList.size()>0){
            Schema.SObjectField f = Campaign_Spend__c.Fields.PR_Unique_key__c;
            Database.upsertResult [] upsertResultList = Database.upsert(Campaign_Spend_CreateList,f,false);
            //Database.SaveResult[] srList = Database.Insert(Campaign_Spend_CreateList,false);                        
            for(Integer i=0;i<upsertResultList.size();i++){
                id phid=Campaign_Spend_CreateList[i].PR_Phasing__c;                               
                if(upsertResultList[i].isSuccess()){
                    PR_Phasing_Map.get(phid).Campaign_Spend__c=Campaign_Spend_CreateList[i].id;
                    PR_Phasing_Map.get(phid).Campaign_Spend_Created__c=true;
                    PR_Phasing_Map.get(phid).Campaign_Spend_Creation_Error__c=null;
                }
                else if(!upsertResultList[i].isSuccess()){
                    system.debug('errors in spend creation...'+upsertResultList[i].getErrors());
                    PR_Phasing_Map.get(phid).Campaign_Spend_Creation_Error__c=string.valueOf(upsertResultList[i].getErrors());
                    PR_Phasing_Map.get(phid).Campaign_Spend_Created__c=false;
                    PR_Phasing_Map.get(phid).Campaign_Spend__c=null;                                       
                    errorSet.add(PR_Phasing_Map.get(phid).PR_Detail__r.IOCode__c);
                }                
            }            
        }
        system.debug('Campaign_Spend_CreateList...after insert.....'+Campaign_Spend_CreateList);        
        // Rollback to the previous Savepoint if there are any errors.
        if(errorSet.size()>0) Database.rollback(sp); 
        if(errorSet.size()>0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Campaign Spend creation failed for: '+JSON.serialize(errorSet)));
            stopProcess=true;
            displaySubmitPR=true;
        }
        else{           
            try{                
                submitPRForApproval(PRHeaderRec.id);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'PR request was submitted successfully.  An email confirmation will be sent shortly.'));
                stopProcess=false;
                displaySubmitPR=false;                
            }catch(system.DmlException ex){
                system.debug('Exception while submitting the PR for approval..'+PRHeaderRec);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Exception:'+ex.getMessage()));            
                stopProcess=true;
            }            
        }
        system.debug('PR_Phasing_Map...**...'+PR_Phasing_Map);
        if(PR_Phasing_Map.size()>0) database.update(PR_Phasing_Map.values(),false);        
        return null;        
    }
    public void submitPRForApproval(id PRHeaderRecId){
    
        PR_Header__c    prhead = new PR_Header__c();
        prhead = [SELECT id,name,Total_PR_Amount_USD__c,Vendor_Name__c, Approval_Process_Recalled__c FROM PR_Header__c WHERE Id=:PRHeaderRecId];
       
        if(prhead.Approval_Process_Recalled__c){
        	prhead.Approval_Process_Recalled__c = false;
        	update prhead;
        }
        
        Account vendor = new Account();
        vendor = [SELECT id,name,Total_PR_amount_Current_year__c,PRs_Over_50K_Current_year__c FROM Account WHERE Id=:prhead.Vendor_Name__c];
        
        if(vendor.Total_PR_amount_Current_year__c==null){
            vendor.Total_PR_amount_Current_year__c =0;
        }
        
        vendor.Total_PR_amount_Current_year__c = vendor.Total_PR_amount_Current_year__c + prhead.Total_PR_Amount_USD__c;
        
        if(vendor.Total_PR_amount_Current_year__c >=50000){
            vendor.PRs_Over_50K_Current_year__c  = true;
        } else{
            vendor.PRs_Over_50K_Current_year__c = false;
        }
        update vendor;
        
        // Send PR for an approval
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        //req1.setComments('Submitting the PR for Procurement/finance team for approval');
        req1.setObjectId(PRHeaderRecId);                
        Approval.ProcessResult result = Approval.process(req1);                       
    }
    
}