@isTest
public class TST_SLT_SBP_SBP_Approvers_CS {
    @testSetup 
    static void setup(){
        SBP_Approvers__c approver = new SBP_Approvers__c();
        approver.Name = 'xyzzz';
        approver.Brand__c = SBP_Constants.LAPHROAIG_SINGLE_CASK;
        approver.State__c = 'Raj';
        approver.Username__c = 'test1@gmail.com';
        insert approver;
    }
    
    @isTest
    static void testGetUsernameOfApprovers(){
        SBP_Approvers__c app = [SELECT ID, Brand__c, State__c, Username__c
                                   FROM SBP_Approvers__c 
                                   LIMIT 1];
        
        Test.startTest();
        	String uname = SLT_SBP_SBP_Approvers_CS.getUsernameOfApprovers(app.Brand__c);
        Test.stopTest();
        System.assertEquals('test1@gmail.com', uname, 'Username is not same');
    }
}