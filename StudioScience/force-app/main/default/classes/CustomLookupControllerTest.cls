@isTest
public class CustomLookupControllerTest {

    @testSetup static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com',
                              EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                              LocaleSidKey = 'en_US', ProfileId = p.Id,
                              TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuserclct@test-user-system.com.test-only');
            insert u;
            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Distributor').getRecordTypeId();
            
            Account offPremiseAccount = new Account();
            offPremiseAccount.Name = 'Test Off Premise';
            offPremiseAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();
            
            Account distAccount = new Account();
            distAccount.Name = 'Test Dist';
            distAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Distributor').getRecordTypeId();
            
            insert new List<Account> {acct, offPremiseAccount, distAccount};
                
            Contact c = new Contact();
            c.AccountId = distAccount.Id;
            c.FirstName = 'Test';
            c.LastName = 'Contact';
            insert c;
            
            //insert Vendor Account for PR Header
            Account objVendorAccount = new Account();
            objVendorAccount.Name = 'Test Vendor Account';
            objVendorAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Vendor').getRecordTypeId();
            insert objVendorAccount;
            
            //insert SAP Company Code for PR Header
            SAP_Company_Code__c sapCode = new SAP_Company_Code__c();
            sapCode.Name = 'Test SAP Code';
            sapCode.Status__c = 'Active';
            sapCode.VendorCompanycodeKey__c = 'TestSapCodeExternalId';
            sapCode.Account__c = objVendorAccount.Id;
            insert sapCode;
            
            //insert PR Header Record
            PR_Header__c prHeader = new PR_Header__c();
            prHeader.Vendor_Name__c = objVendorAccount.Id;
            prHeader.SAP_Company_Code__c = sapCode.Id;
            prHeader.Payment_Terms__c = 'Standard Terms';
            prHeader.PR_Currency__c = 'USD';
            prHeader.Request_Date__c = Date.today();
            prHeader.SAP_Support__c = 'XHPOTRU';
            insert prHeader;
            
            Diplomatic_Hierarchy__c d = new Diplomatic_Hierarchy__c();
            d.Diplomat__c = u.Id;
            d.Manager__c = u.Id;
            d.User_Type__c = 'Heritage Manager';
            insert d;           
        }        
    }

    public static List<Account> getAccountByName(String name) {
        return [select id, Name from Account where Name = :name];
    }
    
    //Added by Mahesh
    public static List<User> getUserByName(String name) {
        return [select id, Name from User where Name = :name];
    }

    public static testMethod void testLookingUpAccount() {
        Test.startTest();

        List<Account> accounts = CustomLookupController.fetchLookUpValues('Test Acco', 'Account');

        Test.stopTest();

        System.assertEquals(1, accounts.size());
        System.assertEquals('Test Account', accounts[0].Name);
    }

    public static testMethod void testGetBaseUrl() {
        Test.startTest();

        String baseUrl = CustomLookupController.getEnvironmentUrl();

        Test.stopTest();

        System.assertNotEquals(NULL, baseUrl);
    }


    public static testMethod void getDistributorRecordTypeTest() {
        Account acc = [select Id, Name from Account where Name = 'Test Vendor Account'];
        acc.BillingCity = 'Test City';
        acc.BillingState = 'Test State';
        acc.RecordTypeId = '012o0000000peiJ';
        update acc;
        Test.startTest();

        List<Account> accounts = CustomLookupController.getDistributorRecordType(acc.Name, 'Account', 10, acc.BillingState);
        List<Account> account1 = CustomLookupController.getDistributorRecordType(acc.Name, 'Account', 0, acc.BillingState);
        
        System.assertEquals(1, accounts.size());
        //System.assertEquals('Test Vendor Account', accounts[0].Name);
        
        Test.stopTest();
    }

    public static testMethod void getPremiseRecordTypeTest() {
        Test.startTest();
        Account acc = [select Id, Name from Account where Name = 'Test Vendor Account'];
        acc.BillingCity = 'Test City';
        acc.BillingState = 'Test State';
        acc.RecordTypeId = '012o0000000peiL';
        acc.Available_for_Single_barrel__c =true;
        update acc;
        
        List<Account> accounts =  CustomLookupController.getPremiseRecordType(acc.Name, 'Account', 10, acc.BillingCity, acc.BillingState,acc.Available_for_Single_barrel__c,new list<string>(), '');
        List<Account> accounts1 = CustomLookupController.getPremiseRecordType(acc.Name, 'Account', 10, '', '',acc.Available_for_Single_barrel__c,new list<string>(), '');
        List<Account> accounts4 = CustomLookupController.getPremiseRecordType(acc.Name, 'Account', 0, '', '',acc.Available_for_Single_barrel__c,new list<string>(), '');
        List<Account> accounts2 = CustomLookupController.getPremiseRecordType(acc.Name, 'Account', 10, acc.BillingCity, '',acc.Available_for_Single_barrel__c,new list<string>(), '');
        List<Account> accounts3 = CustomLookupController.getPremiseRecordType(acc.Name, 'Account', 10, '', acc.BillingState,acc.Available_for_Single_barrel__c,new list<string>(), '');
        Test.stopTest();

        System.assertEquals(1, accounts.size());
        System.assertEquals('Test Vendor Account', accounts[0].Name);
    }

    public static testMethod void getDistributorContactForAccountTest() {
        List<Account> a = getAccountByName('Test Dist');
        Test.startTest();

        List<Contact> contacts = CustomLookupController.getDistributorContactForAccount('Test', 'Contact', Id.valueOf(a[0].Id));

        Test.stopTest();

        System.assertEquals(1, contacts.size());
        System.assertEquals('Test Contact', contacts[0].Name);
    }
    
    public static testMethod void testGetSAPCompanyForVendorAccount() {
        Account acc = [select Id, Name from Account where Name = 'Test Vendor Account'];
        test.startTest();
        List <SAP_Company_Code__c> sapList = CustomLookupController.getSAPCompanyForVendorAccount(acc.Id);
        test.stopTest();
        System.assert(sapList.size()>0, 'Account should have atleast one SAP Company Code');
    }
    
    public static testMethod void testgetAccountAndSAPCompanyCodeDetails() {
        PR_Header__c objPRHeader = [Select Id From PR_Header__c Where Vendor_Name__r.Name = 'Test Vendor Account'];
        test.startTest();
        Map<String, Object> returnMap = CustomLookupController.getAccountAndSAPCompanyCodeDetails(objPRHeader.Id);
        test.stopTest();
        System.assert(returnMap.size()>0,'PR Header Record should have Vendor & SAP Company Code');
    }
    
    public static testMethod void testUpdatePRHeader() {
        PR_Header__c objPRHeader = [Select Id, Vendor_Name__c, SAP_Company_Code__c, Payment_Terms__c, PR_Currency__c,
                                   Request_Date__c, SAP_Support__c From PR_Header__c Where Vendor_Name__r.Name = 'Test Vendor Account' Limit 1];
        String jsonPRHeader = '[{"Id":"' + objPRHeader.Id + '",'
                            + '"Vendor_Name__c" : "' + objPRHeader.Vendor_Name__c + '",'
                            + '"SAP_Company_Code__c" : "' + objPRHeader.SAP_Company_Code__c + '",'
                            + '"Payment_Terms__c" : "' + objPRHeader.Payment_Terms__c + '",'
                            + '"PR_Currency__c" : "' + objPRHeader.PR_Currency__c + '",'
                            + '"Request_Date__c" : "2019-12-26",'
                            + '"SAP_Support__c" : "' + objPRHeader.SAP_Support__c +'"}]';
        test.startTest();
        String retString = CustomLookupController.updatePRHeader(jsonPRHeader);
        test.stopTest();
        System.assert(retString.length()>0, 'PR Record Saved Successfully');
    }
    
    public static testMethod void testGetMyAccounts() {
        Account acc = [select Id, Name from Account where Name = 'Test Vendor Account'];
        test.startTest();
        List <Account> sapList = CustomLookupController.getMyAccounts('test', 'Account', acc.Id);
        test.stopTest();
    }
    
    
    //Added by Mahesh
    public static testMethod void getPRPicklistvaluesTest() {
        Test.startTest();

        List<String> prheaders = CustomLookupController.getPRPicklistvalues('PR_Header__c', 'Vendor_Name__c', true);

        Test.stopTest();

        System.assert(prheaders.size()>0);
    }
    
    public static testMethod void getDiplomatsTest() {
        Test.startTest();
        
        List <sObject> res = CustomLookupController.getDiplomats('David Kearns', 1);
        
        Test.stopTest();
        
        System.assert(res != null);
    }
    
    public static testMethod void searchCaseTest() {
        Test.startTest();
        
        List <sObject> res = CustomLookupController.searchCase('00797204');
        
        Test.stopTest();
        
        System.assert(res != null);
    }
    
    public static testMethod void getHeritageManagerTest() {
        String brand = 'Makers Mark';
        Diplomatic_Hierarchy__c u = [Select Diplomat__c from Diplomatic_Hierarchy__c where user_type__c = 'Heritage Manager' limit 1];
        Test.startTest();
        List<sObject> objName = CustomLookupController.getHeritageManager(u.Diplomat__c,brand);
        Test.stopTest();
        System.assert(objName != null);
    } 
    
    public static testMethod void getCollaboratorUserTest() {
        Test.startTest();
        
        List <sObject> res = CustomLookupController.getCollaboratorUser('Shubham', 0);
        
        Test.stopTest();
        
        System.assert(res != null);
    }
}