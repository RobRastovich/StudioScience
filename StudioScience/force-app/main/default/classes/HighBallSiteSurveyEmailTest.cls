@isTest(SeeAllData = false)
public class HighBallSiteSurveyEmailTest {  
    @isTest static void surveyEmailTest() {   
        Account acct = new Account();       
        acct.Name = 'Test Account';
        acct.BillingState = 'FL';
        acct.BillingStreet = '8765 S FEDERAL HWY';
        acct.BillingCity = 'PORT SAINT LUCIE';
        acct.BillingPostalCode = '34952';
        acct.Account_Territory__c = 'SO CALIFORNIA';
        acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OnPremise').getRecordTypeId();
        insert acct;
        
        Contact con = new Contact();
        con.FirstName = 'TestFirstName';
        con.LastName = 'Tester';
        con.AccountId = acct.Id;
        con.Email = 'test@test.com';
        insert con;       
        
        Highball__c hc = new Highball__c();
        hc.Local_BSI_Contact__c = UserInfo.getUserId();
        hc.Highball_Specialist__c = UserInfo.getUserId();
        hc.Contact__c = con.Id;
        hc.Buyer_Contact__c = con.Id;    
        hc.Spirits_Brand__c = 'Haku';
        hc.Type_of_Technology__c = 'Machine';
        hc.No_of_Machines__c = 1 ;
        hc.Type_of_Tower__c = 'Traditional-Front Bar';     
        hc.Site_Survey_Request_Date_1__c = Date.newInstance(2023,03,01);
        hc.Site_Survey_Request_Date_2__c = Date.newInstance(2023,03,03);
        hc.Site_Survey_Request_Date_3__c = Date.newInstance(2023,03,05);
        hc.Available_Hours_for_Site_Survey__c = '2';
        hc.Preferred_Installation_Company__c = 'Test';
        hc.Account__c = acct.Id; 
        hc.Expected_Installation_Date__c = Date.today();
        insert hc;
        
        Test.startTest();        
        HighBallSiteSurveyEmail.sendEmail(new List<Id> {hc.Id});    
        Test.stopTest();	  
        
    }    
}