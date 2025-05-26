/*
** Name: CalendarDistributorUpdateBatch
** Description: This Batch class will create parent child relation ship between territory and Distributor 
                Type Account record and insert value in Calendar Distributor Values Custom settings.
** Version History
Date            Version         By                    Description
---------------------------------------------------------------------------------------
01/20/2016          1       TCS DEV team          created CalendarDistributorUpdateBatch

*/
global class CalendarDistributorUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{

global final String Query;
   global dateTime currentDateTime=system.now();

   

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator('select id,TerritoryTag__r.Name,Name from Account where TerritoryTag__c!=\'\'  and ProgramPartner__c=true and recordtype.Name=\'Distributor\'');
   }
   
   global void execute(Database.BatchableContext BC, List<sObject> scope){
       Map<String,set<string>> territoryDistributorMap= new Map<String,set<string>>();
       List<Calendar_Dependent_Values__c> CalDistrValLst= new List<Calendar_Dependent_Values__c>();
       Map<string,Id> distributorIdMap= new Map<string,Id>();
       
       for(sObject s : scope){
          Account a = (Account)s;
          if(territoryDistributorMap.get(a.TerritoryTag__r.Name)!=null){
               territoryDistributorMap.get(a.TerritoryTag__r.Name).add(a.Name);
           }
           else{
               set<string> distributorSet= new set<string>();
               distributorSet.add(a.Name);
               territoryDistributorMap.put(a.TerritoryTag__r.Name,distributorSet);
           } 
           distributorIdMap.put(a.name,a.id);   
         }
       
    
       if(territoryDistributorMap.size()>0){
           for(string Key : territoryDistributorMap.keySet()){
               Calendar_Dependent_Values__c noDistObj= new Calendar_Dependent_Values__c();
               noDistObj.Setting__c='Program__c.Distributor__c';
               noDistObj.Value__c='*No Distributor';
               noDistObj.Controlling_Value__c=Key ;
               string settingname=Key+':'+'No Distributor'.replaceAll( '\\s+', '');
               if(settingname.length()>38){
                  
                  noDistObj.Name=settingname.substring(0,35);
               }
               else{
                   noDistObj.Name=settingname;
               }
               
              
               noDistObj.External_Id__c=Key+':'+'No Distributor';
               noDistObj.Object__c='Account';
               CalDistrValLst.add(noDistObj);
               for(string valMap: territoryDistributorMap.get(key)){
                   system.debug('##### distributorIdMap'+distributorIdMap);  
                   Calendar_Dependent_Values__c calDistrValObj= new Calendar_Dependent_Values__c();
                   calDistrValObj.Setting__c='Program__c.Distributor__c';
                   calDistrValObj.Value__c=valMap;
                   calDistrValObj.Controlling_Value__c=Key ;
                   system.debug(key+'distributorIdMap.get(key)'+distributorIdMap.get(key));
                   string nameString=distributorIdMap.get(valMap)+':'+key.replaceAll( '\\s+', '');
                   system.debug('@@@ Length'+nameString.length());
                   if(nameString.length()>38){
                       system.debug('@@@ nameString'+nameString);
                       system.debug('@@@ substring'+nameString.substring(0,35));
                       calDistrValObj.Name=nameString.substring(0,35);
                    }
                    else{
                        calDistrValObj.Name=nameString;
                     }
                    
                     calDistrValObj.External_Id__c=Key+':'+valMap;
                     calDistrValObj.Object__c='Account';
                     CalDistrValLst.add(calDistrValObj);
                }   
           }
       
       }
       if(CalDistrValLst!=null && !CalDistrValLst.isEmpty()){
           upsert CalDistrValLst External_Id__c;
       
       }

   }
   
   
   global void finish(Database.BatchableContext BC){
       List<Calendar_Dependent_Values__c> delCalDistrVal=[select id from Calendar_Dependent_Values__c where lastModifiedDate<:currentDateTime and Object__c='Account'];
       if(delCalDistrVal!=null && !delCalDistrVal.isEmpty()){
           delete delCalDistrVal;
       }    
    }

}