/************************************************************************************** 
 Apex Test Class Name     : UserAccessTest
 Created Date        	  : 5/19/2016
 Function                 : Supplying test data for UserAccess
*************************************************************************************/
@isTest
public class UserAccessTest {
	static testmethod void usertest() {
    	Case c = new Case();
        insert c;
        UserAccess userAceess = new UserAccess();
        Set<Case> caseSet = userAceess.userCases();
    }
}