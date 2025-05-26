@isTest(SeeAllData = false)
public class ContactQueryTest {
		
    public static final String Admin_Profile = 'System Administrator';
    public static final String Admin_Role = 'Application Admin';
    public static final String ACCOUNT_RT_Distributor = 'Distributor';
    @isTest
    public static void testGetContactList() {

        Profile p0 = [SELECT Id FROM Profile WHERE Name = :Admin_Profile];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = :Admin_Role];
        User u0 = new User(Alias = 'beamtu2', Email = 'standarduser2@testorg22.com',
                           EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                           LocaleSidKey = 'en_US', ProfileId = p0.Id, UserRoleId = r.Id,
                           TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser2@test-user-system.com.test-only');
        insert u0;

        Test.startTest();

        System.runAs(u0) {
            Account a = new Account();
            a.RecordTypeId = accountRTId;
            a.Name = 'Test Account';
            insert a;
            system.debug('Account Owner: ' + a.OwnerId);
			Contact con = new Contact();
            con.LastName = 'Tester';
            con.AccountId = a.Id;
            con.Email = 'test@test.com';
            insert con;
            ContactQuery.getContactList(a.Id);
        }
        test.stopTest();
    }
    private static Id accountRTId {
        get{
            if (accountRTId == null) {
                accountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ACCOUNT_RT_Distributor).getRecordTypeId();
            }
            return accountRTId;
        }
        set;
    }
}