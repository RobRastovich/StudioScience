@isTest
public class INT_EmailDeliveryControllerTest {
    
    @testSetup
    static void dataSetup() {
        List<INT_Brand__c> brands = new List<INT_Brand__c> {
            new INT_Brand__c(
                Name = 'Glen Garioch Test',
                INT_Abbreviation__c = 'GG'
            ),
            new INT_Brand__c(
                Name = 'The Blend Test',
                INT_Abbreviation__c = 'TB'
            ),
            new INT_Brand__c(
                Name = 'Hornitos Test',
                INT_Abbreviation__c = 'HT'
            )
        }; 
        insert brands;

        List<INT_Market__c> markets = new List<INT_Market__c> {
            new INT_Market__c(
                Name = 'Australia Test',
                INT_Abbreviation__c = 'AU'
            ),
            new INT_Market__c(
                Name = 'Germany Test',
                INT_Abbreviation__c = 'DE'
            ),
            new INT_Market__c(
                Name = 'India Test',
                INT_Abbreviation__c = 'IN'
            )
        }; 
        insert markets;
        
        INT_Manager__c manager = new INT_Manager__c();
        manager.INT_User__c = UserInfo.getUserId();
        manager.INT_Brand__c = brands[0].Id;
        insert manager;
        
        Id draftRecordTypeId = Schema.SObjectType.INT_EmailDelivery__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();    
        INT_EmailDelivery__c emailDelivery = new INT_EmailDelivery__c();
        emailDelivery.INT_Brand__c = brands[0].Id;
        emailDelivery.INT_Status__c = 'Draft';
        emailDelivery.INT_CampaignName__c = 'Glen Garioch Test Campaign';
        emailDelivery.RecordTypeId = draftRecordTypeId;
        insert emailDelivery;
        
        INT_Segment__c segment = new INT_Segment__c();
        segment.Name = 'Test Segment';
        insert segment;
        
        INT_DeliverySegment__c deliverySegment = new INT_DeliverySegment__c();
        deliverySegment.INT_Description__c = 'Test Delivery Segment';
        deliverySegment.INT_Segment__c = segment.Id;
        deliverySegment.INT_EmailDelivery__c = emailDelivery.Id;
        insert deliverySegment;
        
        ContentVersion cv = new ContentVersion();
        cv.VersionData = Blob.valueOf('Test');
        cv.Title = 'Demo';
        cv.ContentLocation= 's';
        cv.PathOnClient = 'Demo.pdf';
        insert cv;     
    }
    
    @isTest
    static void validateSegmentData() {
        Id emailDeliveryId = [SELECT Id 
                              FROM INT_EmailDelivery__c][0].Id;
        
        List<INT_DeliverySegment__c> deliverySegmentList = [SELECT Id 
                                                            FROM INT_DeliverySegment__c];
        
        Test.startTest();
        
        List<INT_DeliverySegment__c> deliverySegments = INT_EmailDeliveryController.getDeliverySegments(emailDeliveryId);
        List<INT_Segment__c> segments = INT_EmailDeliveryController.getSegments();
        List<INT_EmailDelivery__c> emailDelivery = INT_EmailDeliveryController.getEmailDeliveryRecord(emailDeliveryId);
        INT_EmailDeliveryController.syncDeliverySegments(deliverySegmentList, deliverySegmentList);
        INT_EmailDeliveryController.getSegmentOptions();

        Test.stopTest();

        System.assertEquals(deliverySegments.size(), 1, 'Valid delivery segments could not be retrieved.');
        System.assertEquals(segments.size(), 1, 'Valid segments could not be retrieved.');
    }
    
    @isTest
    static void validateQueriedData() {
        Id brandId = [SELECT Id 
                      FROM INT_Brand__c 
                      WHERE Name = 'Glen Garioch Test'][0].Id;
        
        Test.startTest();
        
        List<INT_Brand__c> brands = INT_EmailDeliveryController.getBrands();
        
        List<INT_Market__c> markets = INT_EmailDeliveryController.getMarkets();
        List<INT_Manager__c> userSettings = INT_EmailDeliveryController.getUserSettings();
        List<INT_EmailDelivery__c> previousDeliveries = INT_EmailDeliveryController.getPreviousDeliveries(brandId);
        String baseUrl = INT_EmailDeliveryController.getBaseUrl();
        
        Test.stopTest();
        
        System.assertEquals(brands.size(), 3, 'Valid brands could not be retrieved.');
        System.assertEquals(markets.size(), 3, 'Valid markets could not be retrieved.');
        System.assertEquals(userSettings.size(), 1, 'Valid user settings could not be retrieved.');
        System.assertEquals(previousDeliveries.size(), 1, 'Valid previous deliveries could not be retrieved.');
    }
    
    @isTest
    static void validateDesignFilesData() {
        Id contentVersionId = [SELECT Id 
                               FROM ContentVersion][0].Id;
        
        Id contentDocId = [SELECT ContentDocumentId 
                           FROM ContentVersion 
                           WHERE Id = :contentVersionId].ContentDocumentId;
        
        Map<String, List<Id>> mapFileCategory = new Map<String, List<Id>>();
        List<Id> contentDocList = new List<Id>();
        
        contentDocList.add(contentDocId);
        mapFileCategory.put('Assets', contentDocList);
        
        String mapFileCategoryJson = JSON.serialize(mapFileCategory);
        
        Id emailDeliveryId = [SELECT Id 
                              FROM INT_EmailDelivery__c][0].Id;
        
        INT_DesignFiles__c designFile = new INT_DesignFiles__c();
        designFile.INT_Type__c = 'Binary';
        designFile.INT_EmailDelivery__c = emailDeliveryId;
        designFile.INT_Category__c = 'Assets';
        
        List<INT_DesignFiles__c> designFiles = new List<INT_DesignFiles__c>();
        designFiles.add(designFile);
        
        Test.startTest();
        
        INT_EmailDeliveryController.createDesignFileRecords(designFiles, mapFileCategoryJson);
        
        Test.stopTest();

    }
}