Global  with sharing class SAPShipBatch implements Database.Batchable<SObject>, Database.AllowsCallouts
{
    global SAPShipBatch(){} 
    global Database.QueryLocator start(Database.BatchableContext BC){
    	return Database.getQueryLocator([
            SELECT Id,Case__r.SAP_Number__c,Ship_Date__c,Shipment_Number__c,Tracking_Number__c, Name 
            From Barrel__c
        	WHERE Case__r.SAP_Number__c != '' AND Ship_Date__c <= TODAY AND Tracking_Number__c = ''
            AND Ship_Date__c >= 2023-01-31]);
    }
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        TI_SAP_API_Service.updateShipmentNumberAndTrackingNumber(scope);
    }
    global void finish(Database.BatchableContext BC){
    
    }
}