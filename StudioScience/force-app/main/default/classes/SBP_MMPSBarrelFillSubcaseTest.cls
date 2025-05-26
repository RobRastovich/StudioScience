@isTest(SeeAllData = false)

public class SBP_MMPSBarrelFillSubcaseTest {  
    
    public static testMethod void barrelReadySubCase() {
        Id CASE_RT_BarrelReady = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Barrel Ready to Enter').getRecordTypeId();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
                              EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                              LocaleSidKey = 'en_US', ProfileId = p.Id,
                              TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestusermmpsbfst@test-user-system.com.test-only');
            insert u;
            
            Account testAccount = new Account();
            testAccount.Name = 'Test Account';
            testAccount.BillingState = 'IL';
            testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();
            
            Account retailAccount = new Account();
            retailAccount.Name = 'Retail Account';
            retailAccount.BillingState = 'IL';
            retailAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();
            insert new List<Account>{testAccount, retailAccount};
            Case c = new Case();
            c.Status = 'New';
            c.Type = 'Barrel Ready to Enter';
            c.RecordTypeId = CASE_RT_BarrelReady ;
            c.Brand__c = 'Makers Mark';
            c.Retail_Account__c = retailAccount.Id;
            c.Regional_Diplomat__c = u.Id;
            c.Heritage_Manager__c = u.Id;
            insert c;
            Barrel_Recipe__c br = new Barrel_Recipe__c();
            br.Brand__c = 'Makers Mark';
            insert br;        
            Barrel__c b = new Barrel__c();
            b.Case__c = c.Id;
            b.Barrel_Recipe__c = br.Id;
            insert b;

            Test.startTest();
                SBP_MMPSBarrelFillSubcase.createSubCaseForBarrelReady(new List<Case>{c});
                List<Single_Barrel_Stave_Setting__mdt> staves = [select MasterLabel, Brand__c, isActive__c, Order__c, Static_Resource_Name__c, Stave_Name__c from Single_Barrel_Stave_Setting__mdt where isActive__c = true AND Brand__c = 'Makers Mark' order by Order__c asc];
                Map<String, Integer> listOfStaves = SBP_MMPSBarrelFillSubcase.getStaveQuantity(staves, c.Id );
            Test.stopTest();
            
            System.assert(listOfStaves != null);
        }   
        
    }
    
}