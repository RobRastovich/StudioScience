@istest
public class ApexHelperControllerTest {

    @testSetup static void testDataSetup() {
        user adminUser=BS_PR_TestService_UtilityCls.adminUserSetup();
        system.runAs(adminUser){
            List<Account> AccountDataList=BS_PR_TestService_UtilityCls.setupAccountData();
        }
    }

    @isTest static void ApexHelperController_executeSoql_Test() {
        string dynamicSOQL = 'SELECT id,Name,RecordTypeId from Account WHERE RecordType.Name=\'Vendor\'';
        List<Account> accountList = ApexHelperController.executeSoql(dynamicSOQL);
        System.assert(accountList.size() > 0);
    }
    
}