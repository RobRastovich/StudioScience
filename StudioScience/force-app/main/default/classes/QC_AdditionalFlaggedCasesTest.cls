@isTest
public class QC_AdditionalFlaggedCasesTest {

    public static Id factsRecordType = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get('FACTS').getRecordTypeId();
    public static Id qualityClaimRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Quality_Claim').getRecordTypeId();
    public static Id distributorRecordType = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get('Distributor').getRecordTypeId();
    public static Id retailerRecordType = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get('Retail').getRecordTypeId();
    public static Id consumerRecordType = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();

    @testSetup static void setupAdditionalFlaggedCases() {

        List<Account> accounts = new List<Account>();

        Account distributorAccount = new Account();
        distributorAccount.Name = 'Test Distributor Account';
        accounts.add(distributorAccount);

        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Retailer Account';
        accounts.add(retailerAccount);

        Account accountNoIncident = new Account();
        accountNoIncident.Name = 'Account No Incident';
        accounts.add(accountNoIncident);

        Account accountNoIncident2 = new Account();
        accountNoIncident2.Name = 'Account No Incident 2';
        accounts.add(accountNoIncident2);

        insert accounts;

        Incident__c parentIncident = new Incident__c();
        parentIncident.RecordTypeId = factsRecordType;
        parentIncident.Lot_Code_s__c = '1234;1234567890';
        insert parentIncident;

        List<Incident__c> subincidents = new List<Incident__c>();

        Incident__c retailerWithAccountSubincident = new Incident__c();
        retailerWithAccountSubincident.RecordTypeId = retailerRecordType;
        retailerWithAccountSubincident.Parent_Incident__c = parentIncident.Id;
        retailerWithAccountSubincident.Account__c = retailerAccount.Id;
        subincidents.add(retailerWithAccountSubincident);

        Incident__c retailerWithoutAccountSubincident = new Incident__c();
        retailerWithoutAccountSubincident.RecordTypeId = retailerRecordType;
        retailerWithoutAccountSubincident.Parent_Incident__c = parentIncident.Id;
        retailerWithoutAccountSubincident.Account_Name__c = 'Test Retailer NO ACCOUNT';
        subincidents.add(retailerWithoutAccountSubincident);

        Incident__c distributorWithAccountSubincident = new Incident__c();
        distributorWithAccountSubincident.RecordTypeId = distributorRecordType;
        distributorWithAccountSubincident.Parent_Incident__c = parentIncident.Id;
        distributorWithAccountSubincident.Account__c = distributorAccount.Id;
        subincidents.add(distributorWithAccountSubincident);

        Incident__c distributorWithoutAccountSubincident = new Incident__c();
        distributorWithoutAccountSubincident.RecordTypeId = distributorRecordType;
        distributorWithoutAccountSubincident.Parent_Incident__c = parentIncident.Id;
        distributorWithoutAccountSubincident.Account_Name__c = 'Test Distributor NO ACCOUNT';
        subincidents.add(distributorWithoutAccountSubincident);

        insert subincidents;

        List<Case> cases = new List<Case>();

        Case consumerCase = new Case();
        consumerCase.RecordTypeId = qualityClaimRecordType;
        consumerCase.Complaint_Source__c = 'Consumer';
        consumerCase.Lot_Code__c = '1234';
        cases.add(consumerCase);

        Case distributorCaseWithAccountInSF = new Case();
        distributorCaseWithAccountInSF.RecordTypeId = qualityClaimRecordType;
        distributorCaseWithAccountInSF.Complaint_Source__c = 'Distributor';
        distributorCaseWithAccountInSF.Lot_Code__c = '1234567890';
        distributorCaseWithAccountInSF.AccountId = distributorAccount.Id;
        cases.add(distributorCaseWithAccountInSF);

        Case distributorCaseWithAccount = new Case();
        distributorCaseWithAccount.RecordTypeId = qualityClaimRecordType;
        distributorCaseWithAccount.Complaint_Source__c = 'Distributor';
        distributorCaseWithAccount.Lot_Code__c = '1234567890';
        distributorCaseWithAccount.AccountId = accountNoIncident.Id;
        cases.add(distributorCaseWithAccount);

        Case distributorCaseWithoutAccount = new Case();
        distributorCaseWithoutAccount.RecordTypeId = qualityClaimRecordType;
        distributorCaseWithoutAccount.Complaint_Source__c = 'Distributor';
        distributorCaseWithoutAccount.Lot_Code__c = '1234567890';
        distributorCaseWithoutAccount.Location_Name__c = 'Test Distributor NO ACCOUNT';
        distributorCaseWithoutAccount.Incident__c = distributorWithoutAccountSubincident.Id;
        cases.add(distributorCaseWithoutAccount);

        Case distributorCaseWithoutAccount2 = new Case();
        distributorCaseWithoutAccount2.RecordTypeId = qualityClaimRecordType;
        distributorCaseWithoutAccount2.Complaint_Source__c = 'Distributor';
        distributorCaseWithoutAccount2.Lot_Code__c = '1234567890';
        distributorCaseWithoutAccount2.Location_Name__c = 'Test Distributor NO ACCOUNT #2';
        cases.add(distributorCaseWithoutAccount2);

        Case retailerCaseWithAccountInSF = new Case();
        retailerCaseWithAccountInSF.RecordTypeId = qualityClaimRecordType;
        retailerCaseWithAccountInSF.Complaint_Source__c = 'Retail';
        retailerCaseWithAccountInSF.Lot_Code__c = '1234567890';
        retailerCaseWithAccountInSF.AccountId = retailerAccount.Id;
        retailerCaseWithAccountInSF.Incident__c = retailerWithAccountSubincident.Id;
        cases.add(retailerCaseWithAccountInSF);

        Case retailerCaseWithAccount = new Case();
        retailerCaseWithAccount.RecordTypeId = qualityClaimRecordType;
        retailerCaseWithAccount.Complaint_Source__c = 'Retail';
        retailerCaseWithAccount.Lot_Code__c = '1234567890';
        retailerCaseWithAccount.AccountId = accountNoIncident.Id;
        cases.add(retailerCaseWithAccount);

        Case retailerCaseWithoutAccount = new Case();
        retailerCaseWithoutAccount.RecordTypeId = qualityClaimRecordType;
        retailerCaseWithoutAccount.Complaint_Source__c = 'Retail';
        retailerCaseWithoutAccount.Lot_Code__c = '1234';
        retailerCaseWithoutAccount.Location_Name__c = 'Test Retailer NO ACCOUNT';
        retailerCaseWithoutAccount.Incident__c = retailerWithoutAccountSubincident.Id;
        cases.add(retailerCaseWithoutAccount);

        Case retailerCaseWithoutAccount2 = new Case();
        retailerCaseWithoutAccount2.RecordTypeId = qualityClaimRecordType;
        retailerCaseWithoutAccount2.Complaint_Source__c = 'Retail';
        retailerCaseWithoutAccount2.Lot_Code__c = '1234';
        retailerCaseWithoutAccount2.Location_Name__c = 'Test Retailer NO ACCOUNT #2';
        cases.add(retailerCaseWithoutAccount2);

        insert cases;
    }



    @isTest static void testGetAdditionalCases() {
        Incident__c inc = [SELECT Id FROM Incident__c LIMIT 1];

        Test.startTest();

		List<Case> cases = QC_AdditionalFlaggedCases.getAdditionalCases(inc.Id);

        Test.stopTest();

		System.assertEquals(true, cases.size() > 0);        
    }

    @isTest static void insertCasesTest() {
        Incident__c inc = [SELECT Id FROM Incident__c LIMIT 1];
        List<Case> cases = [SELECT Id, Complaint_Source__c, Location_Name__c, AccountId, Incident__c, RecordTypeId FROM Case WHERE Lot_Code__c = '1234' OR Lot_Code__c = '1234567890'];

        Test.startTest();

        QC_AdditionalFlaggedCases.insertCases(inc.Id, cases);

        Test.stopTest();

        List<Incident__c> subincidents = [SELECT Id, Parent_Incident__c, RecordTypeId, Account_Name__c FROM Incident__c WHERE Parent_Incident__c = :inc.Id];
        List<Account> accounts = [SELECT Id, Name FROM Account];

        System.assertEquals(true, subincidents.size() > 0);

        Account accountNoIncident;
        for (Account account : accounts) {
            if (account.Name == 'Account No Incident') {
                accountNoIncident = account;
            }
        }

        Integer countOfConsumerIncidents = 0;
        Integer countOfRetailerIncidents = 0;
        Integer countOfDistributorIncidents = 0;

        for (Incident__c subinc : subincidents) {
            if (subinc.RecordTypeId == consumerRecordType) {
                countOfConsumerIncidents++;
                System.assertEquals(true, subinc.RecordTypeId == consumerRecordType);
            }
            if (subinc.RecordTypeId == distributorRecordType) {
                countOfDistributorIncidents++;
                System.assertEquals(true, subinc.RecordTypeId == distributorRecordType);
                if (subInc.Account_Name__c != null && subInc.Account_Name__c == accountNoIncident.Name) {
                    System.assertEquals(true, subInc.Account_Name__c == accountNoIncident.Name);
                }
            }
            if (subinc.RecordTypeId == retailerRecordType) {
                countOfRetailerIncidents++;
                System.assertEquals(true, subinc.RecordTypeId == retailerRecordType);
                if (subInc.Account_Name__c != null && subInc.Account_Name__c == accountNoIncident.Name) {
                    System.assertEquals(true, subInc.Account_Name__c == accountNoIncident.Name);
                }
            }
        }
        System.assertEquals(1, countOfConsumerIncidents);
        System.assertEquals(4, countOfRetailerIncidents);
        System.assertEquals(4, countOfDistributorIncidents);
    }
}