public without sharing class ItemAvailabilityTemplateController {
    public Id caseId {get;set;}
    public List<Quote_Request__c> quoteRequestList {get;set;}
    //Key: Availability, Value: List of Available Items' Quote Requests
    public Map<String, List<Quote_Request__c>> typeQuoteRequestMap {get;set;}

    public Boolean hasItemAvailable {get;set;}
    public Boolean hasItemUnavailable {get;set;}
    public Set<String> keySet {get;set;}

    public ItemAvailabilityTemplateController() {
        System.debug(LoggingLevel.INFO, 'My Case Id: ' + caseId);
        typeQuoteRequestMap = new Map<String, List<Quote_Request__c>>();
    }

    public List<Quote_Request__c> getQuoteRequests(){
        quoteRequestList = [SELECT Id, State__c, Item_Name__c, Item_Size__c, Item_Available__c, Price_Needed__c, Unavailability_Reason__c, Unavailability_Reason_Other__c FROM Quote_Request__c WHERE Case__c =: caseId];
        return quoteRequestList;
    }

    public Map<String, List<Quote_Request__c>> getQuoteRequestMap(){
        quoteRequestList = [SELECT Id, State__c, Item_Name__c, Item_Size__c, Item_Available__c, Price_Needed__c, Unavailability_Reason__c, Unavailability_Reason_Other__c FROM Quote_Request__c WHERE Case__c =: caseId];
        typeQuoteRequestMap = new Map<String, List<Quote_Request__c>>();
        typeQuoteRequestMap.put('Item Available', new List<Quote_Request__c>());
        typeQuoteRequestMap.put('Item Unavailable', new List<Quote_Request__c>());

        for(Quote_Request__c qr: quoteRequestList){
            if(qr.Item_Available__c == 'Yes'){
                typeQuoteRequestMap.get('Item Available').add(qr);
            } else if(qr.Item_Available__c == 'No'){
                typeQuoteRequestMap.get('Item Unavailable').add(qr);
            }
        }

        hasItemAvailable = typeQuoteRequestMap.get('Item Available').size() > 0;
        hasItemUnavailable = typeQuoteRequestMap.get('Item Unavailable').size() > 0;
        return typeQuoteRequestMap;
    }
}