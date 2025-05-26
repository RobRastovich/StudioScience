@isTest
private class ScheduleEmailSingleBarrelMissingItemTest {

	// CRON expression: midnight on March 15.
	// Because this is a test, job executes
	// immediately after Test.stopTest().
    public static Integer nextYear = System.Today().year() + 1;
    public static String timeCronValue = '0 0 0 15 3 ? '+ String.valueOf(nextYear);
    public static String CRON_EXP = timeCronValue;

	@isTest static void schedulableEmailSingleBarrelMissingItems() {
		Test.startTest();
			// Schedule the test job
			String jobId = System.schedule('ScheduleEmailSingleBarrelMissingItems',
			                               CRON_EXP,
			                               new ScheduleEmailSingleBarrelMissingItems());

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