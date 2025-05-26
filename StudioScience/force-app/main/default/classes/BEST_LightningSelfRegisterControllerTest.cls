@IsTest()
public with sharing class BEST_LightningSelfRegisterControllerTest {

 @IsTest
 static void testSiteAsContainerEnabled() {
  System.assertNotEquals(null, BEST_LightningSelfRegisterController.siteAsContainerEnabled('https://portaleu1-developer-edition.eu11.force.com'));
 }

    /* Verifies the selfRegistration method flow with various invalid inputs */
    @IsTest
    static void testSelfRegistration() {
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        Contact con = new Contact();
        con.LastName = 'user';
        con.AccountId = acc.Id;
        con.Email = 'test@test.com';
        con.User_Approval_Status__c = 'Rejected';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Portal_User').getRecordTypeId();
        insert con;
        
        Contact cont = new Contact();
        cont.LastName = 'userin';
        cont.AccountId = acc.Id;
        cont.Email = 'test@testinj.com';
        insert cont;
        Map < String, String > paramsMap = initializeParams();
        System.assertNotEquals(null, paramsMap);
        System.assertEquals(Label.Site.lastname_is_required, BEST_LightningSelfRegisterController.selfRegisterContactCreation(paramsMap.get('firstName'), '', paramsMap.get('email'), null, paramsMap.get('territory')));
        System.assertEquals(Label.Site.email_is_required, BEST_LightningSelfRegisterController.selfRegisterContactCreation(paramsMap.get('firstName'), paramsMap.get('lastName'), '', null, paramsMap.get('territory')));
        System.assertEquals('First Name is required.', BEST_LightningSelfRegisterController.selfRegisterContactCreation(null, paramsMap.get('lastName'), '', null, paramsMap.get('territory')));
        System.assertNotEquals(null, BEST_LightningSelfRegisterController.selfRegisterContactCreation(paramsMap.get('firstName'), paramsMap.get('lastName'), '', null, paramsMap.get('territory')));
        System.assertNotEquals(null, BEST_LightningSelfRegisterController.selfRegisterContactCreation(paramsMap.get('firstName'), paramsMap.get('lastName'), 'test@test.com', acc.Id, paramsMap.get('territory')));
        System.assertNotEquals(null, BEST_LightningSelfRegisterController.selfRegisterContactCreation(paramsMap.get('firstName'), paramsMap.get('lastName'), 'test@te.com', acc.Id, paramsMap.get('territory')));
    }


 /* Verifies the selfRegistration flow for valid inputs */
 @IsTest
 static void testSelfRegisterWithProperCredentials() {
  Map < String, String > paramsMap = initializeParams();
  System.assertEquals('Agency is required.', BEST_LightningSelfRegisterController.selfRegisterContactCreation(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), null, paramsMap.get('territory')));
 }
    
    @IsTest
    static void testselfRegisterContactCreation() {
        Map < String, String > paramsMap = initializeParams();
        System.assertEquals('Agency is required.', BEST_LightningSelfRegisterController.selfRegisterContactCreation(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), null, 'Alaska'));
    }
    
    @IsTest
    static void getPicklistValuesTest() {
        System.assertNotEquals(null, BEST_LightningSelfRegisterController.getPicklistValues('Contact', 'Territory__c'));
    }
    
    @IsTest
    static void setExperienceIdTest() {
        System.assertNotEquals(null, BEST_LightningSelfRegisterController.setExperienceId('123'));
    }

 @IsTest
 static void BEST_LightningSelfRegisterControllerInstantiation() {
  BEST_LightningSelfRegisterController controller = new BEST_LightningSelfRegisterController();
  System.assertNotEquals(controller, null);
 }

 /* Helper method to initialize the parameters required for SelfRegistration. */
 private static Map < String, String > initializeParams() {
  Map < String, String > paramsMap = new Map < String, String > ();
  String firstName = 'test';
  String lastName = 'User';
  String email = 'testUser@salesforce.com';
  String password = 'testuser123';
  String confirmPasswordCorrect = 'testuser123';
  String confirmPasswordWrong = 'wrongpassword';
  String accountId = 'testuser123';
  String regConfirmUrl = 'http://registration-confirm.com';
  String startUrl = 'http://my.company.salesforce.com';
  String territory = 'Alaska';   
  paramsMap.put('firstName', firstName);
  paramsMap.put('lastName', lastName);
  paramsMap.put('email', email);
  paramsMap.put('password', password);
  paramsMap.put('confirmPasswordCorrect', confirmPasswordCorrect);
  paramsMap.put('confirmPasswordWrong', confirmPasswordWrong);
  paramsMap.put('accountId', accountId);
  paramsMap.put('regConfirmUrl', regConfirmUrl);
  paramsMap.put('startUrl', startUrl);
  paramsMap.put('territory', territory);
  return paramsMap;
 }
}