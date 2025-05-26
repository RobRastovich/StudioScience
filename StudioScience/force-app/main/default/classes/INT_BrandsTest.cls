@isTest
public class INT_BrandsTest {
    
    @isTest
    static void validateGroupCreation() {
        INT_Brand__c brand = new INT_Brand__c();
        brand.Name = 'Glen Garioch Test';
        brand.INT_Abbreviation__c = 'GG';
        insert brand;
        
        Test.startTest();
        Group g = [SELECT Id, DeveloperName, Name 
                   FROM Group 
                   WHERE DeveloperName = :brand.Id][0];
        Test.stopTest();
        
        System.assertEquals(g.Name, 'Glen Garioch Test', 'Failed to create group with name Glen Garioch.');
    }
    
    @isTest
    static void validateGroupUpdate() {
        INT_Brand__c brand = new INT_Brand__c();
        brand.Name = 'Glen Garioch Test';
        brand.INT_Abbreviation__c = 'GG';
        insert brand;
        
        brand.Name = 'Knob Creek Test';
        brand.INT_Abbreviation__c = 'KC';
        update brand;
        
        Test.startTest();
        Group g = [SELECT Id, DeveloperName, Name 
                   FROM Group 
                   WHERE DeveloperName = :brand.Id][0];
        Test.stopTest();
        
        System.assertEquals(g.Name, 'Knob Creek Test', 'Failed to update group with name Knob Creek Test.');
    }
    
}