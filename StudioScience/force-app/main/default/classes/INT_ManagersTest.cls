@isTest
public class INT_ManagersTest {
    
    @testSetup
    static void dataSetup() {

        Profile p = [SELECT Id 
                     FROM Profile 
                     WHERE Name = 'System Administrator'];

        User usr01 = new User(
            Alias = 'eops', 
            Email = 'emailopsuser1@test.com', 
            Regional_Diplomat_Regions__c = 'Illinois;Indiana',
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Email Ops Admin 1', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Chicago', 
            UserName = 'emailopsuser1@testusername.com'
        );
        insert usr01;

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

        INT_Manager__c manager = new INT_Manager__c();
        manager.INT_User__c = UserInfo.getUserId();
        manager.INT_Brand__c = brands[0].Id;
        insert manager;
    }
    
    @isTest
    static void validateNewGroupMembership() {
        String brandId = [SELECT Id 
                          FROM INT_Brand__c 
                          WHERE Name = 'Glen Garioch Test'][0].Id;
        
        String userId = [SELECT Id 
                         FROM User 
                         WHERE LastName = 'Email Ops Admin 1'][0].Id;
        
        Test.startTest();
        
        INT_Manager__c manager = new INT_Manager__c();
        manager.INT_User__c = userId;
        manager.INT_Brand__c = brandId;
        insert manager;   
        
        Test.stopTest();
    }
    
    @isTest
    static void validateModifiedGroupMembership() {
        String userId = [SELECT Id 
                         FROM User 
                         WHERE LastName = 'Email Ops Admin 1'][0].Id;
        
        Test.startTest();
        
        INT_Manager__c manager = [SELECT Id 
                                  FROM INT_Manager__c 
                                  WHERE INT_User__c = :UserInfo.getUserId()][0];
        
        INT_Manager__c updatedManager = new INT_Manager__c(Id=manager.Id);
        updatedManager.INT_User__c = userId;
        update updatedManager;
        
        Test.stopTest();
    }
    
    @isTest
    static void validateRemovedGroupMembership() {   
        Test.startTest();
        
        INT_Manager__c manager = [SELECT Id 
                                  FROM INT_Manager__c 
                                  WHERE INT_User__c = :UserInfo.getUserId()][0];

        delete manager;

        Test.stopTest();
    }
}