global class BatchSAPCompanyCodeVendorAccount implements Database.Batchable<sObject>,Database.Stateful {
    
    public Set<Id> sAPCompanyCodeIdSet = new Set<Id>();
    Map<id,SAP_Company_Code__c> IdSAPCodeBatch=new Map<id,SAP_Company_Code__c>();
    
    global BatchSAPCompanyCodeVendorAccount(Map<id,SAP_Company_Code__c> idMap){
        IdSAPCodeBatch=idMap;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String str_query = 'Select Id, SAP_Vendor__c, Account__c From SAP_Company_Code__c Where  Account__c = Null AND SAP_Vendor__c!= Null';
        return Database.getQueryLocator(str_query);
    }
    global void execute(Database.BatchableContext BC, List<SAP_Company_Code__c> scope){
        Set<String> sapVendorIdSet = new Set<String>();
        for(SAP_Company_Code__c sp : scope){
            if(sp.SAP_Vendor__c != null){
                sapVendorIdSet.add(sp.SAP_Vendor__c);
            }
        }
        try{
            Map<String,Account> mapAccount = new Map<String,Account>();
            for(Account acc : [Select Id, SAP_Vendor_ID__c From Account Where SAP_Vendor_ID__c IN : sapVendorIdSet]){
                mapAccount.put(acc.SAP_Vendor_ID__c, acc);
            }
            for(SAP_Company_Code__c sp : scope){
                if(sp.SAP_Vendor__c != null && mapAccount.containsKey(sp.SAP_Vendor__c)){
                    sp.Account__c = mapAccount.get(sp.SAP_Vendor__c).Id;
                    sAPCompanyCodeIdSet.add(sp.Id);
                }
            }
            Database.update(scope,false);
        } 
        catch(Exception e){
            System.debug('Error Occured:::'+e.getMessage());
        }
    }
    global void finish(Database.BatchableContext BC){
        System.debug('Records Processed:::'+sAPCompanyCodeIdSet.size());
        System.debug('Display SAP Company Code Set:::'+sAPCompanyCodeIdSet);
    }
}