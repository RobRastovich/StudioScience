Global  with sharing class ShipmentTrackingBatch implements Database.Batchable<SObject>, Database.AllowsCallouts
{

    global final String query;
    global final String sObjectName;
    global final string sCarrier;

    global ShipmentTrackingBatch(string sourceName, string carrier){  
      this.sObjectName = sourceName;
      this.sCarrier = carrier;     
      this.query = 'select id, Tracking_Number__c, Delivery_Status__c from ' + sourceName + ' where Tracking_Number__c <> null and carrier__c ='+'\''+ sCarrier+ '\''+ 'and Delivery_Status__c not  in(\'Delivered\') and Is_Manual__c = False order by CreatedDate desc';
    } 

    global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
    }
  
    global void execute(Database.BatchableContext BC, List<SObject> scope){    
        ShipmentTrackingService.fetchAndUpdateDeliveryStatus(scope,sCarrier);     
    }
  
    global void finish(Database.BatchableContext BC){
        
    }
}