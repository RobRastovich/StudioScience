Global  with sharing class TI_UPS_API_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts
{

    global final String query;
    global final String sObjectName;
    global final string sCarrier;
    
    global TI_UPS_API_Batch(string sourceName, string carrier){  
    	this.sObjectName = sourceName;
      	this.sCarrier = carrier;
      	this.query = 'select id, Tracking_Number__c, Case__r.Status, Name from ' + sourceName + ' where Tracking_Number__c <> null and CarrierNew__c ='+'\''+ sCarrier+ '\''+ 'AND Is_Manual__c = false AND Track_Status_Type__c not in (\'Delivered Origin CFS (Freight Only)\', \'Delivered Destination CFS (Freight Only)\', \'Delivered\') order by CreatedDate desc';
    } 

    global Database.QueryLocator start(Database.BatchableContext BC){
    	return Database.getQueryLocator(query);
    }
  
    global void execute(Database.BatchableContext BC, List<SObject> scope){    
        TI_UPS_APIService.updateBarrelTrackingInfo(scope);
    }
  
    global void finish(Database.BatchableContext BC){
        
    }
}