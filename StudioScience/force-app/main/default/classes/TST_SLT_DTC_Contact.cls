@isTest
public class TST_SLT_DTC_Contact {
    @testSetup
    static void dataSetup() {
        Contact cont = TST_TestDataFactory.createContact(null, true);
        Account acnt = TST_TestDataFactory.createPersonAccount(DTC_Constants.ACCOUNT_CONSUMER_RECORDTYPEID, true);
    }

    @isTest
    private static void testSelectByEmailId() {
        Contact contact = [SELECT id, Email 
        FROM Contact][0];

        Test.startTest();
            List<Contact> fetchedContact = SLT_DTC_Contact.getContactByEmail(contact.Email);
        Test.stopTest();

        System.assertNotEquals(null, fetchedContact , 'No Records Returned when expected');
    }

    @isTest
    private static void testGetExistingContactId() {
        Contact contact = [SELECT id, Email 
        FROM Contact][0];

        Test.startTest();
            Id fetchedContactId = SLT_DTC_Contact.getExistingContactId(contact.Email);
        Test.stopTest();

        System.assertNotEquals(null, fetchedContactId , 'No Records Returned when expected');
    }

    @isTest
    private static void testGetContactsByIDs() {
        Contact contact = [SELECT id, Email 
        FROM Contact][0];

        Test.startTest();
            List<Contact> fetchedContact = SLT_DTC_Contact.getContactsByIDs(new Set<ID>{contact.Id});
        Test.stopTest();

        System.assertNotEquals(null, fetchedContact , 'No Records Returned when expected');
    }
}