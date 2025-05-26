@isTest
public class Clone_Campaign_To_Program_Test{
/*
    static testmethod void testProgramClone() {
        
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
        
        List<String> planNames = new List<String>();
        Map<String, ID> tagsMap;
        
        System.runAs(u1) {  
            //Create test data
            TestDataFactory.createMarketingPlanHierarchy();
            TestDataFactory.createProgramTranspose();
            tagsMap = TestDataFactory.GetTagsMap();
    
            //Get the Marketing Plan(s) that we'll be adding child Campaigns under.
            
            planNames.add('2018 US JBW American AMR SDP Heritage Arkansas $5K'); 
            planNames.add('2018 US JBW American AMR SDP Heritage Louisana $15K'); 
            planNames.add('2018 US JBW American AMR SDP Legacy Missouri $20K');    
        }
        
        Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
        MarketingPlan__c plan1 = plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K');
        //MarketingPlan__c plan2 = plans.get('2018 US JBW American AMR SDP Heritage Louisana $15K');
        //MarketingPlan__c plan3 = plans.get('2018 US JBW American AMR SDP Legacy Missouri $20K');

        //Plan1 will not have a Next Sequence Number set yet.
        plan1.Next_IO_Sequence__c = null;
        plan1.SAP_Controlling_Area__c = '2000';
        plan1.SAP_Company_Code__c = 'US30';
        plan1.SAP_Cost_Center__c = 'US30NA33';
  
        update plan1;
            
        
        
        Campaign__c camp1;
        Campaign__c camp2;
        List<Campaign__c> insertCampaign = new List<Campaign__c>();
        List<Program__c> clonedPrograms;
        System.runAs(u1) {          
            //Create the campaigns
            camp1 = TestDataFactory.MapCampaign(plan1.Id, 300.00, date.newinstance(2018, 1, 5), date.newinstance(2018, 1, 27), 'USD', tagsMap.get('BQ_Jim Beam White'));
            camp2 = TestDataFactory.MapCampaign(plan1.Id, 1000.00, date.newinstance(2018, 1, 5), date.newinstance(2018, 1, 27), 'USD', tagsMap.get('BQ_Jim Beam White'));
            insertCampaign.add(camp1);
            insertCampaign.add(camp2);
            insert insertCampaign;
            
            clonedPrograms = [SELECT Id,SourceBICampaign__c,SpendDescription__c,ProgrammingType__c,ProgramFocus__c,Channel__c FROM Program__c WHERE SourceBICampaign__c=:camp1.Id];
            
            system.debug('clonedPrograms'+clonedPrograms[0]);
            system.assertEquals(clonedPrograms[0].SpendDescription__c,camp1.GLDescription__c);
            system.assertEquals(clonedPrograms[0].ProgramFocus__c,'Other');
            system.assertEquals(clonedPrograms[0].ProgrammingType__c,'Other');
            
            camp1.GLDescription__c = 'Cinema Paid Advertising';
            update camp1;
            
            clonedPrograms = [SELECT Id,SourceBICampaign__c,SpendDescription__c,ProgrammingType__c,ProgramFocus__c,Channel__c,OwnerId FROM Program__c WHERE SourceBICampaign__c=:camp1.Id];
            system.debug('From test class clonedPrograms[0].SpendDescription__c'+clonedPrograms[0].SpendDescription__c);
            system.debug('From test class camp1.GLDescription__c'+camp1.GLDescription__c);
            
            
        
        }
        system.assertEquals(clonedPrograms[0].OwnerId,u1.Id);
        System.runAs(u2) {        
            plan1.OwnerId = u2.Id;        
            update plan1;
        }
        clonedPrograms = [SELECT OwnerId FROM Program__c WHERE SourceBICampaign__c=:camp1.Id];
        system.assertEquals(clonedPrograms[0].OwnerId,u2.Id);
        
        System.runAs(u1) {  
            clonedPrograms[0].SourceBICampaign__c=camp2.id;
            update clonedPrograms;
        }    
         
    }
*/
}