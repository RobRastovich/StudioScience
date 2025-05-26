/**
* @description       : This is the test class of LeadTrigger and LeadTriggerHandler class
* @author            : Jaiveer Jha
* @group             : 
* @last modified on  : 07-10-2024
* @last modified by  : Jaiveer Jha
**/
@isTest
public class LeadTriggerHandler_Test {
    
    public static void createUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User userObj = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
                                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                                LocaleSidKey = 'en_US', ProfileId = p.Id,
                                TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser@test-user-system.com.test-only');
        insert userObj;     
    }
    
    public static void createWebLead() {
        Lead leadObj = new Lead(
            FirstName='Test',
            LastName='Tester',
            Email='test123@testclass.com',
            Telephone__c='0000000000',
            Privacy_Consent__c = true,
            Prestige_Lead_Source__c = 'Web',
            leadSource = 'Web'
        );
        insert leadObj;
    }
    public static void createManualLead() {
        Lead leadObj = new Lead(
            FirstName='Test',
            LastName='Tester',
            Email='test123@testclass.com',
            Telephone__c='0000000000',
            Privacy_Consent__c = true,
            Prestige_Lead_Source__c = 'Manual',
            leadSource = 'Web'
        );
        insert leadObj;
    }
    
    
    @testSetup
    static void loadTestData(){
        createUser();
        createWebLead();
        createManualLead();
    }
    
    @isTest
    static void testMethodOne(){
        test.startTest();
        List<Lead> listLead = [SELECT Id,Email,OwnerId,owner.email FROM Lead];
        Set<ID> setLeadIDs = new Set<Id>{listLead.get(0).Id};
            Id userId = [Select Id from User where Email = 'standarduser@testorg.com'].Id;
        Lead updateLead = new Lead(
            Id = listLead.get(0).Id,
            ownerId = userId
        );
        update updateLead;
        LeadTriggerHandler.sendEmailNotificationToCustomer(listLead);
        LeadTriggerHandler.sendEmailNotificationToQueueMembers(listLead);
        LeadTriggerHandler.sendEmailNotificationToBrandAmbassdor(listLead);
        system.assert(userId != null);
        test.stopTest();
    }
    @isTest
    static void testMethodLeadConvert(){
        test.startTest();
        List<Lead> listLead = [SELECT Id,Email,OwnerId,owner.email FROM Lead];
        User u = [SELECT Id FROM user WHERE Email = 'standarduser@testorg.com'];
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(listLead.get(0).Id);
        lc.setDoNotCreateOpportunity(false);
        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.setOwnerId(u.Id);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        test.stopTest();
    }
}