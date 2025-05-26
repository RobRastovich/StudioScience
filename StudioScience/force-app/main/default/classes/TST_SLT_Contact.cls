@isTest
public class TST_SLT_Contact {
    @testSetup
    static void dataSetup() { 
        Contact contact = SBP_TestDataFactory.createContact(null, true);
    }
    
    @isTest
    public static void testGetContactByID(){
        Contact con = [SELECT Id 
                       FROM Contact 
                       LIMIT 1];
        
        Test.startTest();
            Contact recordContact = SLT_Contact.getContactByID(con.Id);
        Test.stopTest();
        
        System.assertEquals(false, recordContact == null, 'Contact Is Fetched By ID');
    }
}