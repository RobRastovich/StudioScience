/************************************************************************************** 
 Apex Test Class Name    : ExportCampaignControllerTest
 Created Date            : 5/19/2017
 Function                : Add export XL report functionality at Campaign Grid on Marketing Plan Object.
 Author                  : Ashok Royal
*************************************************************************************/
@isTest
public class ExportCampaignControllerTest{
    static integer currentYear = System.Today().year();  
    @testSetup
    static void setup()
    {
        Id platformRecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Platform').getRecordTypeId();
        Program__c testProgram = new Program__c();
        testProgram.Name = 'Other';
        testProgram.RecordTypeId = platformRecordTypeId;

        Id programRecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Focus Calendar National Priority').getRecordTypeId();
        Program__c testProgram2 = new Program__c();
        testProgram2.Name = 'Other';
        testProgram2.RecordTypeId = programRecordTypeId;
        testProgram2.FocusType__c = 'Current Program';

        insert new List<Program__c>{testProgram, testProgram2};
    }
    
    static Program__c getOtherProgram()
    {
        Id programRecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Focus Calendar National Priority').getRecordTypeId();
        return [SELECT Id FROM Program__c WHERE Name = 'Other' AND RecordTypeId =: programRecordTypeId];
    }

    static testmethod void ExportXLIO ()
    {
     PageReference pageRef = Page.ExportCampaigns;
     Test.setCurrentPage(pageRef);
     pageRef.getParameters().put('integrationType','IO');

     List<String> planNames = new List<String>();
     Map<String, ID> tagsMap;
     TestDataFactory.createMarketingPlanHierarchy();
     
     //Get the Marketing Plan(s) that we'll be adding child Campaigns under.
            
            planNames.add('2018 US JBW American AMR SDP Heritage Arkansas $5K'); 
            Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            tagsMap = TestDataFactory.GetTagsMap();
            MarketingPlan__c plan1 = plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K');            
            pageRef.getParameters().put('mPlanId',plan1.Id);

     Campaign__c camp1;
     List<Campaign__c> insertCampaign = new List<Campaign__c>();          
         camp1 = TestDataFactory.MapCampaign(plan1.Id, 300.00, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 1, 27), 'USD', tagsMap.get('BQ_Jim Beam White'));
         camp1.Related_Priority__c = getOtherProgram().Id;
         insertCampaign.add(camp1);
         insert insertCampaign;         
    
    
    Test.startTest();
    ExportCampaignController objExport = new ExportCampaignController();
    Test.stopTest();
    }

    static testmethod void ExportXLWBS ()
    {
       //*********** Test Export Campaign Spend **************//
       
        PageReference pageRef = Page.ExportCampaigns;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('integrationType','WBS');

        List<String> planNames = new List<String>();
        Map<String, ID> tagsMap;
        TestDataFactory.createMarketingPlanHierarchy();

        //Get the Marketing Plan(s) that we'll be adding child Campaigns under.
        planNames.add('2018 US JBW American AMR SDP Heritage Arkansas $5K'); 
        Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
        tagsMap = TestDataFactory.GetTagsMap();
        MarketingPlan__c plan1 = plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K');
        pageRef.getParameters().put('mPlanId',plan1.Id);

        Campaign__c camp1;
        List<Campaign__c> insertCampaign = new List<Campaign__c>();          
        camp1 = TestDataFactory.MapCampaign(plan1.Id, 300.00, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 1, 27), 'AUD', tagsMap.get('BQ_Jim Beam White'));
        camp1.Related_Priority__c = getOtherProgram().Id;
        insertCampaign.add(camp1);
        insert insertCampaign;         

        Test.startTest();
        ExportCampaignController objExport = new ExportCampaignController();
        Test.stopTest();
     }   
        //******** Test Export Campaign Spend***********//
       static testmethod void ExportCampaignSpend ()
       { 
        PageReference pageRef1 = Page.ExportCampaignSpend;
        Test.setCurrentPage(pageRef1);
        pageRef1.getParameters().put('CampaignID','campId');

        List<String> planNames1 = new List<String>();
        Map<String, ID> tagsMap1;
        TestDataFactory.createMarketingPlanHierarchy();

        //Get the Marketing Plan(s) that we'll be adding child Campaigns under.
        planNames1.add('2018 US JBW American AMR Heritage Arkansas $10K'); 
        Map<String, MarketingPlan__c> plans1 = TestDataFactory.retrieveMarketingPlansByName(planNames1);
        tagsMap1 = TestDataFactory.GetTagsMap();
        MarketingPlan__c plan2 = plans1.get('2018 US JBW American AMR Heritage Arkansas $10K');
       // pageRef1.getParameters().put('mPlanId',plan2.Id);

       /* Campaign__c camp2;
        List<Campaign__c> insertCampaign1 = new List<Campaign__c>();          
        camp2 = TestDataFactory.MapCampaign(plan2.Id, 300.00, date.newinstance(2018, 1, 5), date.newinstance(2018, 1, 27), 'AUD', tagsMap1.get('BQ_Jim Beam White'));
        camp2.Related_Priority__c = getOtherProgram().Id;
        insertCampaign1.add(camp2);
        insert insertCampaign1;         
      */
        Test.startTest();
        ExportCampaignSpendController objExport1 = new ExportCampaignSpendController();
        Test.stopTest();
       }
}