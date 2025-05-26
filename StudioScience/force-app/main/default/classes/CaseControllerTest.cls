/**************************************************************************************
 Apex Test Class Name     : CaseControllerTest
 Created Date             : 5/13/2016
 Function                 : Supplying test data for CaseController
*************************************************************************************/
@isTest
public class CaseControllerTest {

   enum PortalType { CSPLiteUser, PowerCustomerSuccess, PowerPartner, CustomerSuccess }

   static testmethod void usertest() {
      User pu = getPortalUser(PortalType.PowerCustomerSuccess, null, true);

      System.assert([select isPortalEnabled
                     from user
                     where id = :pu.id].isPortalEnabled,
                    'User was not flagged as portal enabled.');

      System.RunAs(pu) {
         System.assert([select isPortalEnabled
                        from user
                        where id = :UserInfo.getUserId()].isPortalEnabled,
                       'User wasnt portal enabled within the runas block. ');
         List<Case> cases = CaseController.getCases();
         List<Case> closedCases = CaseController.getClosedCases();
         List<Case> openCases = CaseController.getOpenCases();
         Boolean userProf = CaseController.getUserProf();
         CaseController.getAllClosedCases();
         CaseController.getAllOpenCases();
      }


   }

   public static User getPortalUser(PortalType portalType, User userWithRole, Boolean doInsert) {

      System.debug('portalType is::::::::' + portalType);
      /* Make sure the running user has a role otherwise an exception
         will be thrown. */
      if (userWithRole == null) {

         if (UserInfo.getUserRoleId() == null) {
            /*
            *Original code snippet
              UserRole r = new UserRole(name = 'TEST ROLE');
              Database.insert(r);
            */
            /*
            *Creating a User Role and then subsequently performing DML on a non-setup object
            *causes an error. Rather than insert a new UserRole, query an existing one
            *Note: UserRoles are visible from Test Context
            *
            *If by some chance there are no UserRoles in the org, the original
            *code will be used to insert a new one. However this WILL throw an exception
            */
            UserRole r;
            List<UserRole> roleList = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
            if (!roleList.isEmpty()) {
               r = roleList[0];
            } else {
               r = new UserRole(name = 'TEST ROLE');
               Database.insert(r);
            }

            userWithRole = new User(alias = 'hasrole', email = 'userwithrole@roletest1.com', userroleid = r.id,
                                    emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                                    localesidkey = 'en_US', profileid = UserInfo.getProfileId(),
                                    timezonesidkey = 'America/Los_Angeles', username = 'userwithrole@testorg.com');
         } else {
            userWithRole = new User(Id = UserInfo.getUserId(), UserRoleId = UserInfo.getUserRoleId());
         }

         System.assert(userWithRole.userRoleId != null,
                       'This test requires the target org to have at least one UserRole created. Please create a user role in this organization and try again.');
      }

      Account a;
      Contact c;
      System.runAs(userWithRole) {

         a = new Account(name = 'TEST ACCOUNT');
         Database.insert(a);

         c = new Contact(AccountId = a.id, lastname = 'lastname');
         Database.insert(c);

      }

      /* Get any profile for the given type.*/
      Profile p = [select id from profile where name ='Customer Community Plus User Test' and usertype = :portalType.name() limit 1];

      String testemail = 'puser000@amamama.com';
      User pu = new User(profileId = p.id, username = testemail, email = testemail,
                         emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                         languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                         alias = 'cspu', lastname = 'lastname', contactId = c.id);

      if (doInsert) {
         Database.insert(pu);
      }
      return pu;
   }

   static testmethod void reopenCasesTest() {
      caseServices.runTrigger = false;
      //Test successful case reopening flow
      contact con = new contact(LastName='testCon');
      insert con;
      User submitter = [select id from user where isActive = false limit 1];
       
      Test.startTest();
       
      Id GMDMRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GMDM').getRecordTypeId();
      Case closedCaseSuccess = new Case(Submitter__c = submitter.Id, ContactId = con.Id,RecordTypeId = GMDMRecordTypeId, Subject = 'Test Case Success', Category_1__c = 'Cat1', Category_2__c = 'Cat2', Status = 'Closed');
      insert closedCaseSuccess;

      closedCaseSuccess = [SELECT Id, RecordTypeId, Status FROM Case WHERE Id = : closedCaseSuccess.Id];
      System.assertEquals('Closed', closedCaseSuccess.Status);

      CaseController.reopenCases(new List<String> {closedCaseSuccess.Id}, '{"' + closedCaseSuccess.Id + '": "explanation"}');
      closedCaseSuccess = [SELECT Id, RecordTypeId, Status FROM Case WHERE Id = : closedCaseSuccess.Id];

      Test.stopTest();

      System.assertEquals('In Progress', closedCaseSuccess.Status);
      //Test flow failure, where Case Id does not exist
      CaseController.reopenCases(new List<String> {'500000000000000'}, '{"500000000000000": "explanation"}');
   }
}