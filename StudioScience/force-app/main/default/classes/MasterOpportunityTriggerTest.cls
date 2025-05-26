@isTest
public class MasterOpportunityTriggerTest{

    static testmethod void testOpportunityCreateUpdate(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
    
        User u1 = new User(Alias = 'standt11', Email='adminuser1@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='beamadminuser1@testorg.com');
        
        User u2 = new User(Alias = 'standt2', Email='adminuseruser2@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='beamadminuser2@testorg.com');
        
        List<user> users = new List<user>();
        users.add(u1);
        users.add(u2);
        insert users;
        
        Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();
        List<Account> parentAccounts = new List<Account>();
        
        
        System.runAs(u1) {  
            parentAccounts.add( new Account(Name='Test Account1',PremiseType__c='Non-Premise'));
            parentAccounts.add( new Account(Name='Test Account2',PremiseType__c='Off-Premise'));
            
            insert parentAccounts;
            
            opportunity opp = new Opportunity(AccountId=parentAccounts[0].Id,StageName='Open - Aperity Provided',BrandVariety__c=tagsMap.get('2 Gingers'),SizeDescription__c='test',CloseDate=date.Today().addDays(1));
            insert opp;
            
            Account accUpdate = new Account(Id=parentAccounts[0].Id,Name='Test Account11',OwnerId=u2.Id);
            
            update accUpdate;
        }
    }
    
    /*static testmethod void testOpportunityUpdate(){
        
    }
    
    static testmethod void testAccountUpdate(){
        
    }*/
    
}