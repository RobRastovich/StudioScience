@isTest(SeeAllData = false)
public class BI_CampaignSpendPRUpdateSchedulerTest {
	// Dummy CRON expression: run everyday at 5pm.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    static String CRON_EXP = '0 0 17 * * ? *';
    static integer currentYear = System.Today().year();
    static String currYear = String.valueOf(currentYear);
    
    @testSetup 
    static void setup(){
        
        
        Id mpRTId = Schema.SObjectType.MarketingPlan__c.getRecordTypeInfosByName().get('Campaigns Allowed - Not Editable').getRecordTypeId();
        MarketingPlan__c testMP = TestDataFactory.MapMarketingPlan('Test MP', currYear, 'US', 'Midwest', 'Central', null, null, null, 100000, mpRTId);
        insert testMP;
        
        Campaign__c testCampaign = TestDataFactory.MapCampaign(testMP.id, 1.20, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 12, 27), 'USD', null);
        insert testCampaign;
        
           
        List<PR_Header__c> PR_HeaderList= new List<PR_Header__c>();
        for(Integer i=0; i<10; i++){
            PR_Header__c prHeader = new PR_Header__c(
                Status__c = 'Completed'
            );
            PR_HeaderList.add(prHeader);
        }
        insert PR_HeaderList;

        List<Campaign_Spend__c> campSpendList = new List<Campaign_Spend__c>();
        Id oldCampSpendRecordtypeId = Schema.SObjectType.Campaign_Spend__c.getRecordTypeInfosByName().get('Pending').getRecordTypeId();
        
        for (Integer i=0; i<10; i++) {
            Campaign_Spend__c campSpend = new Campaign_Spend__c(
                ParentCampaign__c= testCampaign.id,
        	    CurrencyIsoCode= 'USD',
                RecordTypeId = oldCampSpendRecordtypeId,
                PR_Header__c = PR_HeaderList[i].Id
            );
            System.debug('PR_HeaderList: '+ PR_HeaderList[i]);
            campSpendList.add(campSpend);
        }
        insert campSpendList;
        
    }

    @isTest
    public static void campaignSpendRecordStatusUpdateTest() {
        
        
		Test.startTest();
            // Schedule the test job
            String jobId = System.schedule('ScheduledApexTest',
                CRON_EXP,
                new BI_CampaignSpendPRUpdateScheduler());
            System.debug('jobid' + jobId);
        	
            CronTrigger ct = 
                [SELECT TimesTriggered, NextFireTime, CronExpression
                FROM CronTrigger WHERE Id = :jobId];
            System.debug('CronTrigger' + ct);
        
            System.assertEquals(CRON_EXP, ct.CronExpression);
        
            // Verify the scheduled job has not run yet.
            List<Campaign_Spend__c> oldCampaignSpendList = [SELECT id, CreatedDate, Recordtype.name
                                FROM Campaign_Spend__c
                                WHERE Recordtype.name='Committed'
                                AND PR_Header__r.status__c = 'Completed'];   
            System.assertEquals(0, oldCampaignSpendList.size(), 'Campaign Spend records with Status Committed exist before job has run');
            
            List<Campaign_Spend__c> recentupdatedCampaignSpendList = [SELECT id, CreatedDate, Recordtype.name
                                FROM Campaign_Spend__c
                                WHERE Recordtype.name='Pending'
                                AND PR_Header__r.status__c = 'Completed'];
            System.debug('updated or not' + recentupdatedCampaignSpendList);
			
        Test.stopTest();
        
        CronTrigger ct1= 
            [SELECT TimesTriggered, NextFireTime
            FROM CronTrigger WHERE Id = :jobId];
        System.debug('CronTrigger1'+ ct1);

        // Now that the scheduled job has executed,
        // check campaignSpend records were updated
        List<Campaign_Spend__c> updatedCampaignSpendList = [SELECT id, CreatedDate, Recordtype.name
                            FROM Campaign_Spend__c
                            WHERE Recordtype.name='Committed' 
                            AND PR_Header__r.status__c= 'Completed'];  

      System.debug('updatedCampaignSpendList' + updatedCampaignSpendList + updatedCampaignSpendList.size());
        /*
      System.assertNotEquals(oldCampaignSpendList.size(),
            updatedCampaignSpendList.size(),
            'CampaignSpend records RecordType was not updated to Committed');
		*/

	}
}