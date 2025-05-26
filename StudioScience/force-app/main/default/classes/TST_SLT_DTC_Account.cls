@isTest
public class TST_SLT_DTC_Account {

    @testSetup
    static void dataSetup() {
        Account acnt = TST_TestDataFactory.createPersonAccount(DTC_Constants.ACCOUNT_CONSUMER_RECORDTYPEID, true);
    }
    
    @isTest
    private static void testGetAccountByEmail() {
        Account accnt = [SELECT Id, PersonContactId, PersonEmail, PersonMailingCountry, PersonMailingState,
                            PersonMailingCity, PersonMailingPostalCode, PersonMailingStreet, FirstName, Lastname
                            FROM Account][0];

        Test.startTest();
            List<Account> accnts = SLT_DTC_Account.getAccountByEmail(accnt.PersonEmail);
        Test.stopTest();

        System.assertNotEquals(null, accnts , 'No Records Returned when expected');
    }

    @isTest
    private static void testGetPersonAccountByIDs() {
        Account accnt = [SELECT Id, PersonContactId, PersonEmail, PersonMailingCountry, PersonMailingState,
                            PersonMailingCity, PersonMailingPostalCode, PersonMailingStreet, FirstName, Lastname
                            FROM Account][0];

        Test.startTest();
            List<Account> accnts = SLT_DTC_Account.getPersonAccountsByIDs(new Set<ID>{accnt.Id});
        Test.stopTest();

        System.assertNotEquals(null, accnts , 'No Records Returned when expected');
    }
    
    @isTest
    private static void testGetAccountByName() {
        Account accnt = [SELECT Id, PersonContactId, Name, PersonEmail, PersonMailingCountry, PersonMailingState,
                            PersonMailingCity, PersonMailingPostalCode, PersonMailingStreet, FirstName, Lastname
                            FROM Account][0];

        Test.startTest();
            List<Account> accnts = SLT_DTC_Account.getAccountByName(accnt.Name);
        Test.stopTest();

        System.assertNotEquals(null, accnts , 'No Records Returned when expected');
    }
}