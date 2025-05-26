Public class BS_PR_CreateCampaignSpend_FromPhasing{
    @future
    public static void upsertCampaignSpends(set<id> phasingIds) {                
        BS_PR_SubmitPRForApproval_VFCtrl PRApproval_cls=new BS_PR_SubmitPRForApproval_VFCtrl();
        list<Campaign_Spend__c> Campaign_Spend_CreateList=PRApproval_cls.campaignSpendsFieldsMaping(phasingIds);
        list<PR_Phasing__c> PR_Phasing_UpdateList=new list<PR_Phasing__c>();
        if(Campaign_Spend_CreateList.size()>0){
            Schema.SObjectField f = Campaign_Spend__c.Fields.PR_Unique_key__c;
            Database.upsertResult [] upsertResultList = Database.upsert(Campaign_Spend_CreateList,f,false);
            //Database.SaveResult[] srList = Database.Insert(Campaign_Spend_CreateList,false);                        
            for(Integer i=0;i<upsertResultList.size();i++){
                id phid=Campaign_Spend_CreateList[i].PR_Phasing__c;
                PR_Phasing__c Phasing=new PR_Phasing__c(id=phid);
                if(upsertResultList[i].isSuccess()){
                    Phasing.Campaign_Spend__c=Campaign_Spend_CreateList[i].id;
                    Phasing.Campaign_Spend_Created__c=true;
                    Phasing.Campaign_Spend_Creation_Error__c=null;
                }
                else if(!upsertResultList[i].isSuccess()){
                    Phasing.Campaign_Spend_Creation_Error__c=string.valueOf(upsertResultList[i].getErrors());
                    Phasing.Campaign_Spend_Created__c=false;
                    Phasing.Campaign_Spend__c=null;                                                           
                }
                PR_Phasing_UpdateList.add(Phasing);
            }            
        }
        if(PR_Phasing_UpdateList.size()>0) database.update(PR_Phasing_UpdateList,false);
    }        
    @future
    public static void deleteCampaignSpend(set<id> CampaignSpendIds){ 
    	delete [Select id from Campaign_Spend__c Where id IN : CampaignSpendIds];
    }
}