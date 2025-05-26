@isTest(SeeAllData=false)
private class ScheduleSAPCompanyCodeVendorAccountTest {
    
    public static Integer nextYear = System.Today().year() + 1;
    public static String timeCronValue = '0 0 0 15 3 ? '+ String.valueOf(nextYear);
    public static String CRON_EXP = timeCronValue;
    
    @testSetup static void testDataSetup() {
        //insert Account
        List<Account> acctList = new List<Account>();
        Account a1 = new Account();
        a1.Name='testAccount1';
        a1.SAP_Vendor_ID__c='testVendor1';
        acctList.add(a1);
        
        Account a2 = new Account();
        a2.Name='testAccount2';
        a2.SAP_Vendor_ID__c='testVendor2';
        acctList.add(a2);
        
        insert acctList;
        
        //insert SAP Company Code
        List<SAP_Company_Code__c> sapCompanyCodeList = new List<SAP_Company_Code__c>();
        SAP_Company_Code__c sapCompanyCode1 = new SAP_Company_Code__c();
        sapCompanyCode1.Name = 'TestSapCompanyCode1';
        sapCompanyCode1.VendorCompanycodeKey__c='testVendor1TestSapCompanyCode1';
        sapCompanyCode1.SAP_Vendor__c = 'testVendor1';
        sapCompanyCodeList.add(sapCompanyCode1);
        
        SAP_Company_Code__c sapCompanyCode2 = new SAP_Company_Code__c();
        sapCompanyCode2.Name = 'TestSapCompanyCode2';
        sapCompanyCode2.VendorCompanycodeKey__c='testVendor2TestSapCompanyCode2';
        sapCompanyCode2.SAP_Vendor__c = 'testVendor2';
        sapCompanyCodeList.add(sapCompanyCode2);
        
        insert sapCompanyCodeList;
    }
    @isTest static void schedulableSAPCompanyCodeVendorAccount() {
		Test.startTest();
			// Schedule the test job
			String jobId = System.schedule('SchedulableSAPCompanyCodeVendorAccount',
			                               CRON_EXP,
			                               new ScheduleSAPCompanyCodeVendorAccount());

			// Get the information from the CronTrigger API object
			CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
			                  NextFireTime
			                  FROM CronTrigger WHERE id = :jobId];

			// Verify the expressions are the same
			System.assertEquals(CRON_EXP,
			                    ct.CronExpression);

			// Verify the job has not run
			System.assertEquals(0, ct.TimesTriggered);

			// Verify the next time the job will run
			String nextTime = String.valueOf(nextYear) + '-03-15 00:00:00';
			System.assertEquals(nextTime,
			                    String.valueOf(ct.NextFireTime));
		Test.stopTest();
	}
}