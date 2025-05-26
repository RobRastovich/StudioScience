@isTest
public class INT_EmailDeliveriesTest {
    
    @testSetup
    static void dataSetup() {
        
        Profile p = [SELECT Id 
                     FROM Profile 
                     WHERE Name = 'System Administrator'];
        
        User usr = new User(
            Alias = 'eops', 
            Email = 'emailopsuser@test.com', 
            Regional_Diplomat_Regions__c = 'Illinois;Indiana',
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Chicago', 
            UserName = 'emailopsuser@testusername.com'
        );
        insert usr;
        
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
            
        Id draftRecordTypeId = Schema.SObjectType.INT_EmailDelivery__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();    
        INT_EmailDelivery__c emailDelivery01 = new INT_EmailDelivery__c();
        emailDelivery01.INT_Brand__c = brands[0].Id;
        emailDelivery01.INT_Status__c = 'Draft';
        emailDelivery01.INT_CampaignName__c = 'Glen Garioch Test Campaign';
        emailDelivery01.RecordTypeId = draftRecordTypeId;
        
        INT_EmailDelivery__c emailDelivery02 = new INT_EmailDelivery__c();
        emailDelivery02.INT_Brand__c = brands[1].Id;
        emailDelivery02.INT_Status__c = 'Draft';
        emailDelivery02.INT_CampaignName__c = 'The Blend Test Campaign';
        emailDelivery02.RecordTypeId = draftRecordTypeId;
        
        INT_EmailDelivery__c emailDelivery03 = new INT_EmailDelivery__c();
        emailDelivery03.INT_Brand__c = brands[2].Id;
        emailDelivery03.INT_Status__c = 'Draft';
        emailDelivery03.INT_CampaignName__c = 'Hornitos Test Campaign';
        emailDelivery03.RecordTypeId = draftRecordTypeId;
        
        insert new List<INT_EmailDelivery__c>{emailDelivery01, emailDelivery02, emailDelivery03};  
    }
    
    @isTest
    static void validateBrandIdAssignment() {
        INT_Brand__c brand = [SELECT Id 
                              FROM INT_Brand__c 
                              WHERE Name = 'Glen Garioch Test'][0];
        
        Test.startTest();
        
        INT_EmailDelivery__c emailDelivery = new INT_EmailDelivery__c();
        emailDelivery.INT_Brand__c = brand.Id;
        insert emailDelivery;
        
        String brandId = [SELECT INT_BrandId__c 
                          FROM INT_EmailDelivery__c 
                          WHERE Id =:emailDelivery.Id][0].INT_BrandId__c;
        
        Test.stopTest();
        
        System.assertEquals(emailDelivery.INT_Brand__c, brandId, 'Failed to set the brand id on email delivery.');
    }
    
    @isTest
    static void validateOwnership() {
        Id readOnlyRecordTypeId = Schema.SObjectType.INT_EmailDelivery__c.getRecordTypeInfosByName().get('Read Only').getRecordTypeId(); 
        List<INT_EmailDelivery__c> updatedEmailDeliveries = new List<INT_EmailDelivery__c>();
        
        List<INT_EmailDelivery__c> emailDeliveries = [SELECT INT_Brand__r.Name, OwnerId 
                                                      FROM INT_EmailDelivery__c];
        
        if (emailDeliveries != null && emailDeliveries.size() > 0) {
            for (INT_EmailDelivery__c ed : emailDeliveries) {
                 switch on ed.INT_Brand__r.Name {
                        when 'Glen Garioch Test' {
                            ed.INT_Status__c = 'Submitted';
                        }
    
                        when 'The Blend Test' {
                            ed.INT_Status__c = 'Build';
                        }

                        when 'Hornitos Test' {
                            ed.INT_Status__c = 'Awaiting Approval';
                        }
                }
                ed.RecordTypeId = readOnlyRecordTypeId;
                updatedEmailDeliveries.add(ed);
            }
        }
        
        Test.startTest();
        
        if (updatedEmailDeliveries.size() > 0) {
            update updatedEmailDeliveries;
        }
        
        List<INT_EmailDelivery__c> updatedEmailRequestOwners = [SELECT OwnerId, CreatedById 
                                                                FROM INT_EmailDelivery__c];        
        
        Test.stopTest();
        
        System.assertNotEquals(updatedEmailRequestOwners[0].OwnerId, emailDeliveries[0].OwnerId, 'Email delivery request is assigned to Email Devops Team');
        System.assertEquals(updatedEmailRequestOwners[1].OwnerId, UserInfo.getUserId(), 'Failed to assign email delivery request to the current user');
        System.assertEquals(updatedEmailRequestOwners[2].OwnerId, updatedEmailRequestOwners[2].CreatedById, 'Failed to assign email delivery request to the request creator');
    }
    
    @isTest
    static void validateLockOwnership() {
        Boolean exceptionThrown = false;
        INT_EmailDelivery__c emailDelivery = [SELECT OwnerId 
                                              FROM INT_EmailDelivery__c][0];
        
        Test.startTest();
        
        try {
            if (emailDelivery != null) {
                emailDelivery.OwnerId = [SELECT Id FROM User][0].Id;
                update emailDelivery;
            }
        }
        catch (Exception ex) {
            exceptionThrown = ex.getMessage() != null ? true : false;
        }
        
        System.assertEquals(exceptionThrown, true, 'Unable to lock ownership.');
        
        Test.stopTest();
    } 
    
}