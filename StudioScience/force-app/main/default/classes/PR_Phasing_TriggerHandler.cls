/**************************************************************************************
 Apex Class Name     : PR_Phasing_TriggerHandler
 Created Date        : 03-Dec-2019
 Auther              : Harikrishna P 
 Function            : Handles events from the PR_Phasing_Trigger
 Test Class          : PR_Phasing_TriggerHandler_Test
 Updates :
*************************************************************************************/

public class PR_Phasing_TriggerHandler{
    
    public static void handleBeforeDelete(Map<Id, PR_Phasing__c> trigger_oldMap) {
        set<id> CampaignSpendIds=new set<id>();
        for(PR_Phasing__c ph: trigger_oldMap.values()){
            if(ph.Campaign_Spend__c!=null) CampaignSpendIds.add(ph.Campaign_Spend__c);
        }
        if(CampaignSpendIds.size()>0) BS_PR_CreateCampaignSpend_FromPhasing.deleteCampaignSpend(CampaignSpendIds);
    }
    
    public static void handleBeforeInsert(list<PR_Phasing__c> trigger_New) {        
        for(PR_Phasing__c ph: trigger_New){
            ph.CurrencyIsoCode=ph.PR_Request_Currency__c;
        }        
    }
    public static void handleAfterInsert(Map<Id, PR_Phasing__c> trigger_NewMap) {
        set<id> PhasingIds=new set<id>();
        for(PR_Phasing__c ph: trigger_NewMap.values()){
            if(ph.Campaign_Spend__c==null && ph.Phasing_Amount__c!=null && ph.Month__c!=null && ph.PR_Header_RecordType__c=='Submitted'){
                PhasingIds.add(ph.id);
            }
        }
        if(PhasingIds.size()>0) BS_PR_CreateCampaignSpend_FromPhasing.upsertCampaignSpends(PhasingIds);
    }
    public static void handleAfterUpdate(Map<Id, PR_Phasing__c> trigger_NewMap, Map<Id, PR_Phasing__c> trigger_OldMap) {
        set<id> PhasingIds=new set<id>();
        for(PR_Phasing__c ph: trigger_newMap.values()){
            if(ph.Campaign_Spend__c!=null && ph.Phasing_Amount_USD__c!=trigger_oldMap.get(ph.id).Phasing_Amount_USD__c){
                PhasingIds.add(ph.id);
            }
        }
        if(PhasingIds.size()>0) BS_PR_CreateCampaignSpend_FromPhasing.upsertCampaignSpends(PhasingIds);
    }
    public static void handleBeforeUpdate(Map<Id, PR_Phasing__c> trigger_NewMap, Map<Id, PR_Phasing__c> trigger_OldMap) {        
        for(PR_Phasing__c ph: trigger_newMap.values()){
            if(ph.Campaign_Spend__c==null && trigger_oldMap.get(ph.id).Campaign_Spend__c!=null){
                ph.Campaign_Spend_Created__c=false;
            }
        }
    }
}