@isTest
public class SBP_OutOfOfficeCmpCtrlTest {
    
    public static testMethod void fetchUserOutOfOfficeStateTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing1', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = p.Id,
                          TimeZoneSidKey = 'America/Chicago',IsOutOfOffice__c = true ,UserName = 'beamsuntorytestuserooocct@test-user-system.com.test-only');
        System.runAs(u) {
            test.startTest();
            Boolean result = SBP_OutOfOfficeCmpCtrl.fetchUserOutOfOfficeState();
            test.stopTest();
            System.assert(result == true);
        }
    }
    
    public static testMethod void handleToggleChangeMethodTestWhenTrue() {
        test.startTest();
        SBP_OutOfOfficeCmpCtrl.handleToggleChangeMethod(true);
        test.stopTest();
        User userTest = [Select id,Name,IsOutOfOffice__c from User where id =: UserInfo.getUserId()];
        System.assert(userTest.IsOutOfOffice__c == true);        
    }
    
    public static testMethod void handleToggleChangeMethodTestWhenFalse() {
        test.startTest();
        SBP_OutOfOfficeCmpCtrl.handleToggleChangeMethod(false);
        test.stopTest();
        User userTest = [Select id,Name,IsOutOfOffice__c from User where id =: UserInfo.getUserId()];
        System.assert(userTest.IsOutOfOffice__c == false);        
    }
    
}