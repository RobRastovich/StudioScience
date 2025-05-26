@isTest
public class TST_SRV_DTC_Account {

    @testSetup
    static void dataSetup() {
        Case caseDetail = TST_TestDataFactory.createCase(null, true);
        Account accnt = TST_TestDataFactory.createPersonAccount(DTC_Constants.ACCOUNT_CONSUMER_RECORDTYPEID, true);
    }

    @isTest
    private static void testInsertPersonAccountUsingUserDetail() {
        Account accnt = [SELECT Id, PersonContactId, PersonEmail, PersonMailingCountry, PersonMailingState,
            PersonMailingCity, PersonMailingPostalCode, PersonMailingStreet, FirstName, Lastname
            FROM Account][0];
            accnt.personemail  = 'test@exampleUnique.com';
            accnt.FirstName = 'testUnique';
            accnt.LastName = 'paccountUnique';
            Case caseDetail = [SELECT id, First_name__c, Last_name__c, Email_Address__c,
            Brand__c FROM Case][0];

        Test.startTest();
            Account accntCreated = SRV_DTC_Account.insertPersonAccountUsingUserDetail(caseDetail, accnt);
        Test.stopTest();

        System.assertNotEquals(null, accntCreated.Id , 'No Records Returned when expected');
    }

    @isTest
    private static void testupdateAccount() {
        Account accnt = [SELECT Id, PersonContactId, PersonEmail, PersonMailingCountry, PersonMailingState,
        PersonMailingCity, PersonMailingPostalCode, PersonMailingStreet, FirstName, Lastname
        FROM Account][0];
        Account accntCloned = accnt.clone(false, false, false, false);
        accntCloned.personemail  = 'test@exampleClone.com';
        accntCloned.FirstName = 'testCloned';
        accntCloned.LastName = 'paccountcloned';
        insert accntCloned;

        Test.startTest();
            Account accntCreated = SRV_DTC_Account.updateAccount(accnt, accntCloned);
        Test.stopTest();
        
        System.assertNotEquals(null, accntCreated.Id , 'No Records updated when expected');
    }

    @isTest
    private static void testGetExistingAccountId() {
        Account accnt = [SELECT Id, PersonContactId, PersonEmail, PersonMailingCountry, PersonMailingState,
        PersonMailingCity, PersonMailingPostalCode, PersonMailingStreet, FirstName, Lastname
        FROM Account 
        WHERE PersonEmail = 'test@example.com'][0];

        Test.startTest();
            Id accountId = SRV_DTC_Account.getExistingAccountId(accnt.personEmail);
        Test.stopTest();
        
        System.assertNotEquals(null, accountId , 'No Records returned when expected');
    }

    @isTest
    private static void testupdateDhlAccount() {
        Case caseDetail = [SELECT id, CaseNumber, RecordTypeId, Consumer_Country__c, Consumer_State__c, Consumer_City__c, 
        Consumer_Postal_Code__c, Consumer_Street__c from Case][0];
        Account accnt = [SELECT Id, PersonContactId, PersonEmail, PersonMailingCountry, PersonMailingState,
        PersonMailingCity, PersonMailingPostalCode, PersonMailingStreet, FirstName, Lastname
        FROM Account][0];

        Test.startTest();
            Account accntCreated = SRV_DTC_Account.updateDhlAccount(accnt, caseDetail);
        Test.stopTest();
        
        System.assertNotEquals(null, accntCreated.Id , 'No Records updated when expected');
    }
}