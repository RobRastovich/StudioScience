@isTest(seeAllData=false)
public class TST_SLT_Account {
	@isTest
    public static void testGetAccountsByName() {
        Account newAccount = new Account();
        newAccount.Name = 'Laphroaig Distillery';
        insert newAccount;
        String accountName = [SELECT Id, Name 
                              FROM Account 
                              WHERE Name = 'Laphroaig Distillery' LIMIT 1].Name;
        Test.startTest();
        Account result= SLT_Account.getAccountsByName(accountName);
        Test.stopTest();
        System.assertEquals(false, result == null, 'Account is fetched');
    }
}