@isTest
public class SBP_PlantEventsScheduledEmailToUserTest {

 @testSetup static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User demoUser = new User(Alias = 'alias', Email = 'test@test.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
                                     EmailEncodingKey = 'UTF-8', LastName = 'demoUser', LanguageLocaleKey = 'en_US',
                                     LocaleSidKey = 'en_US', ProfileId = p.Id,
                                     TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuserpeset@test-user-system.com.test-only',User_Type__c = 'Diplomat');
        insert demoUser;
        Plant_Event__c p2 = (new Plant_event__c(Scheduled_Date__c = System.Today().addDays(42)));
        p2.ownerId = demoUser.id;
        p2.Time_of_day__c = 'PM';
        p2.Brand__C = 'Makers Mark';
        insert p2;
    }
    
    public static testMethod void sendmailTest() {
        test.startTest();
        SBP_PlantEventsScheduledEmailToUser.sendmail();           
        test.stopTest();
        List<Plant_Event__c> p1 = [Select id,Scheduled_Date__c from Plant_Event__c];
        if(!p1.isEmpty())
        	System.assert(p1[0].Scheduled_Date__c > System.Today());
    }
    
}