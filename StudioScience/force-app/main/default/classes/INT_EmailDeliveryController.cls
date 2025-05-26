public without sharing class INT_EmailDeliveryController {
    
    @AuraEnabled
    public static List<INT_DeliverySegment__c> getDeliverySegments(Id emailDeliveryId){
        if (String.isBlank(emailDeliveryId)) {
            return new List<INT_DeliverySegment__c>();
        }
        
        return new List<INT_DeliverySegment__c>([
            SELECT Id, INT_Description__c, INT_Segment__c
            FROM INT_DeliverySegment__c
            WHERE INT_EmailDelivery__c = :emailDeliveryId
        ]);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<INT_Segment__c> getSegments(){
        return new List<INT_Segment__c>([
            SELECT Id, Name
            FROM INT_Segment__c
        ]);
    }
    
    @AuraEnabled
    public static void syncDeliverySegments(
        List<INT_DeliverySegment__c> segmentsToUpsert,
        List<INT_DeliverySegment__c> segmentsToDelete
    ){
        upsert segmentsToUpsert;
        delete segmentsToDelete;
    }
    
    @AuraEnabled
    public static Map<String, String> getSegmentOptions() {
        Map<String, String> result = new Map<String, String>();
        for (Schema.PicklistEntry e : INT_EmailDelivery__c.INT_Segmentation__c.getDescribe().getPicklistValues()) {
            result.put(e.value, e.label);
        }
        return result;
    }
    
    @AuraEnabled
    public static List<INT_Brand__c> getBrands() {
        return new List<INT_Brand__c>([
            SELECT Id, Name
            FROM INT_Brand__c
            ORDER BY Name ASC
        ]);
    }

    @AuraEnabled
    public static List<INT_Market__c> getMarkets() {
        return new List<INT_Market__c>([
            SELECT Id, Name
            FROM INT_Market__c
            ORDER BY Name ASC
        ]);
    }
    
    @AuraEnabled
    public static List<INT_Manager__c> getUserSettings() {
        return new List<INT_Manager__c>([
            SELECT
            Id, Name, INT_Brand__c
            FROM INT_Manager__c
            WHERE INT_User__c = :UserInfo.getUserId()
        ]);
    }
    
    @AuraEnabled
    public static List<INT_EmailDelivery__c> getPreviousDeliveries(String selectedBrand) {
        return new List<INT_EmailDelivery__c>([
            SELECT
            Id, Name, INT_CampaignName__c
            FROM INT_EmailDelivery__c
            WHERE INT_Brand__c = :selectedBrand
        ]);
    } 
    
    @AuraEnabled
    public static void createDesignFileRecords(List<INT_DesignFiles__c> designFileRecords, String mapFileCategoryJson) {
        Map<String, List<Id>> mapFileCategory = (Map<String, List<Id>>) JSON.deserialize(mapFileCategoryJson, Map<String, List<Id>>.class);
        
        if (designFileRecords != null && designFileRecords.size() > 0) {
            insert designFileRecords;
        }
        
        if (mapFileCategory.size() > 0) {
            for (INT_DesignFiles__c designFile : designFileRecords) {
                if (designFile.INT_Type__c == 'Binary') {
                    linkFilesToEmailDelivery(mapFileCategory.get(designFile.INT_Category__c), designFile.Id);
                }
            }
        }
    } 
    
    public static void linkFilesToEmailDelivery(List<Id> contentDocumentIds, Id designFileId) {
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        
        for (Id contentDocumentId : contentDocumentIds) {
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = contentDocumentId;
            link.LinkedEntityId = designFileId;
            link.ShareType = 'I';
            link.Visibility = 'AllUsers';
            links.add(link);
        }
        insert links;
    } 
    
    @AuraEnabled
    public static String getBaseUrl() {
        return URL.getOrgDomainURL().toExternalForm();
    }
    
    @AuraEnabled
    public static List<INT_EmailDelivery__c> getEmailDeliveryRecord(Id emailDeliveryId) {
        if (String.isBlank(emailDeliveryId)) {
            return new List<INT_EmailDelivery__c>();
        }
        
        return new List<INT_EmailDelivery__c>([
            SELECT
                Id,
                INT_CampaignName__c,
                INT_CommunicationType__c,
                INT_Brand__c,
                INT_Market__c,
                INT_Language__c,
                INT_SendOutDateTime__c,
                INT_PreviousDelivery__c,
                INT_FromName__c,
                INT_FromAddress__c,
                INT_Subject__c,
                INT_Preheader__c
            FROM INT_EmailDelivery__c
            WHERE Id = :emailDeliveryId
        ]);
    }
    
}