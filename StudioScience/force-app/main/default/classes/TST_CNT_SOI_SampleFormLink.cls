@isTest
private class TST_CNT_SOI_SampleFormLink {
    @isTest
    private static void testGetNewSalesFormLink() {
        CNT_SOI_SampleFormLink testSampleForm = new CNT_SOI_SampleFormLink();
        
        Test.startTest();
            String str = testSampleForm.getNewSalesFormLink();
        Test.stopTest();
        
        System.assertEquals(true, str != null, 'String should not be null');
    }
}