/*
Author : Harikrishna Potru
Date : 07-Oct-2019
*/
public with sharing class BS_PR_CreatePRDetails{    
    static string campYear=string.valueOf(System.Today().Year());
    
    @AuraEnabled(cacheable=true) 
    public static List<Campaign__c> fetchCampaignWrapper(String searchKey,string PRID,string companyCode){   
        String key = '%' + searchKey + '%';
        //if(companyCode!=null && companyCode.contains('USC0')) companyCode='USC0';
        //else companyCode='US30';
        map<string,Campaign__c> CampaignMap=new map<string,Campaign__c>();
        set<string> prdUniqueKey=new set<string>();
        for(PR_Detail__c prd:[SELECT Unique_Key__c FROM PR_Detail__c WHERE PR_Header__c=:PRID]){
            prdUniqueKey.add(prd.Unique_Key__c);
        }
        for(Campaign__c camp : [Select id,Name,CampaignType__c,Brand__c,GLCode__c,GLAccountType__c,GLDescription__c,
                                Description__c,IOCode__c,Territory__c,CampaignBalance__c,UserRecordAccess.HasEditAccess From Campaign__c where 
                                year__c=:campYear AND
                                SAP_Company_Code__c=:companyCode AND 
                                IOCode__c!=null AND CampaignBalance__c>0 AND (
                                name like :key OR 
                                Brand__c like :key OR  
                                IOCode__c like :key OR 
                                Territory__c like :key) 
                                Limit 999]){
            if(camp.UserRecordAccess.HasEditAccess==true){
            	Campaign__c campNew=new Campaign__c();
                campNew=camp;
                system.debug('campNew...'+campNew);
                system.debug('camp old value...'+camp);
                string Uq=PRID+''+camp.Id+''+camp.IOCode__c+''+camp.GLCode__c;
            	IF(!prdUniqueKey.contains(Uq)) CampaignMap.put(Uq,campNew);                            
            }
			
        }
        return CampaignMap.values(); 
    }        
        
    @AuraEnabled
    public static void insertPRDetails(string PRID, string campIds){
        list<Campaign__c> camList=(List<Campaign__c>)JSON.deserialize(campIds, List<Campaign__c>.class);
        list<PR_Detail__c> PR_Detail_InsertList=new list<PR_Detail__c>();
        system.debug('campIds size in insert method....'+camList.size());
        for(Campaign__c cm:camList){            
            PR_Detail__c prd=new PR_Detail__c(
                PR_Header__c=PRID
                ,Campaign__c=cm.Id
                ,Campaign_ID__c=cm.Id
                ,Campaign_Name__c=cm.Name
                ,Brand__c=cm.Brand__c
                ,GLAccountType__c=cm.GLAccountType__c
                ,GL_Code2__c=cm.GLCode__c
                ,IOCode__c=cm.IOCode__c
                ,Territory__c=cm.Territory__c
                ,GLDescription2__c=cm.GLDescription__c                
                ,Unique_Key__c=PRID+cm.Id+cm.IOCode__c+cm.GLCode__c
            );
            PR_Detail_InsertList.add(prd);
        }        
        if(PR_Detail_InsertList.size()>0){
            Schema.SObjectField f = PR_Detail__c.Fields.Unique_Key__c;
            set<string> errorsList=new set<string>();
            Database.upsertResult [] upsertResultList = Database.upsert(PR_Detail_InsertList,f,false);
            
            for (Database.upsertResult sr : upsertResultList) {
                if (sr.isSuccess()) {
                    // Operation was successful
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        errorsList.add(string.valueof(err.getMessage()));
                    }
                }
            }
            if(errorsList.size()>0) throw new AuraHandledException(JSON.serialize(errorsList));
        }    
    }
}