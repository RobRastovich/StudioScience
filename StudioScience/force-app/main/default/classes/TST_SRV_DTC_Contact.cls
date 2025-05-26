@isTest
public class TST_SRV_DTC_Contact {

    @testSetup
    static void dataSetup() {
        Contact cont = TST_TestDataFactory.createContact(null, true);
        Account accnt = TST_TestDataFactory.createPersonAccount(null, true);
    }

    @isTest
    private static void testCreateContact() {
        Contact cntct = [SELECT id, FirstName, LastName, Email, MagentoID__c 
        FROM Contact][0];
        Account acnt = [SELECT id, FirstName, LastName, personemail 
        FROM Account][0];
		acnt.personEmail = 'demo@example.com';
        
        Test.startTest();
            SRV_DTC_Contact.CreateContact(cntct, acnt.personEmail);
        Test.stopTest();

        System.assertNotEquals(null, cntct.Id , 'No Records Returned when expected');
    }

    @isTest
    private static void testUpdateContact() {
        Contact cntct = [SELECT id, FirstName, LastName, Email, MagentoID__c 
        FROM Contact][0];
        Account acnt = [SELECT id, FirstName, LastName,  personemail 
        FROM Account][0];

        Test.startTest();
            SRV_DTC_Contact.updateContact(cntct, acnt.personEmail, cntct.magentoId__c);
        Test.stopTest();

        Contact updatedCntct = [SELECT id, Email,FirstName, LastName, MagentoID__c 
        FROM Contact][0];
        System.assertNotEquals(null, updatedCntct.MagentoID__c , 'No Records updated when expected');
    }

    @isTest
    private static void testCreateOrUpdateContact() {
        Contact cntct = [SELECT id, FirstName, LastName, Email, MagentoID__c FROM Contact][0];
        Account acnt = [SELECT id, FirstName, LastName, personemail FROM Account][0];

        Test.startTest();
            SRV_DTC_Contact.createOrUpdateContact(cntct, acnt.personEmail);
        Test.stopTest();

        Contact updatedCntct = [SELECT id, Email,FirstName, LastName,  MagentoID__c 
        FROM Contact][0];
        System.assertNotEquals(null, updatedCntct.MagentoID__c , 'No Records updated when expected');
    }
}