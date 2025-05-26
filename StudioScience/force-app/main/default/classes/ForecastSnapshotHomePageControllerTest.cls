@isTest
private class ForecastSnapshotHomePageControllerTest {
	
	@isTest static void getReportURLTest() {
		ForecastSnapshotHomePageController forecastCntrl = new ForecastSnapshotHomePageController();
		String testReportUrl = forecastCntrl.getReportURL();
		System.assertEquals('Report does not exist', testReportUrl, 'Should return text for report not existing since getContent() method does not return neccessary data in test context');
	}

	@isTest static void takeSnapshotTest() {
		ForecastSnapshotHomePageController forecastCntrl = new ForecastSnapshotHomePageController();
		Test.startTest();
			forecastCntrl.takeSnapshot();
		Test.stopTest();
		System.assertEquals(true, forecastCntrl.batchProcessed, 'Should return true since batch class is called from this method');
		System.assertEquals(true, forecastCntrl.batchInfoObj.showProgressBar, 'Should return true since the batch class is called and the progress bar will be visible');
	}

	@isTest static void getBatchMessageTest() {
		ForecastSnapshotHomePageController forecastCntrl = new ForecastSnapshotHomePageController();
		Test.startTest();
			forecastCntrl.takeSnapshot();
			System.assertEquals(true, forecastCntrl.batchProcessed, 'Should return true since batch class is called from this method');
			System.assertEquals(true, forecastCntrl.batchInfoObj.showProgressBar, 'Should return true since the batch class is called and the progress bar will be visible');
			forecastCntrl.getBatchMessage();
			System.assertEquals(0, forecastCntrl.batchInfoObj.percent, 'Should return 0 since the batch job is queued');
		Test.stopTest();
			forecastCntrl.getBatchMessage();
			System.assertEquals(true, forecastCntrl.batchComplete, 'Should return true since the apex job will be completed');
			System.assertEquals(100, forecastCntrl.batchInfoObj.percent, 'Should return 100 since the apex job will be completed');
			System.assertEquals('100%', forecastCntrl.batchInfoObj.batchMsg, 'Should return 100% since the apex job will be completed');
	}
}