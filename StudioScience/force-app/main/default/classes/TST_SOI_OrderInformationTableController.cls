@isTest
private class TST_SOI_OrderInformationTableController {
    @testSetup
    static void testDataSetup() {
        Innovation_Project_Master__c testInnovationMaster = TST_TestDataFactory.createInnovationMaster(true);
        
        Innovation_Sample_Requests__c testInnovationRequest = TST_TestDataFactory.createInnovationRequest(false);
        testInnovationRequest.Innovation_Samples__c = testInnovationMaster.Id;
        insert testInnovationRequest;
        
        Innovation_Project_Details__c testInnovationDetail = TST_TestDataFactory.createInnovationDetail(false);
        testInnovationDetail.InnovationId__c = testInnovationRequest.id;
        insert testInnovationDetail;
    }
    
    private static Innovation_Sample_Requests__c getInnovationRequest() {
        return [SELECT Id FROM Innovation_Sample_Requests__c LIMIT 1];
    }
    
    @isTest
    private static void testGetInnovationProjectDetails() {
        SOI_OrderInformationTableController testInformationTableController = new SOI_OrderInformationTableController();
        Innovation_Sample_Requests__c innovationRequest = getInnovationRequest();
        testInformationTableController.innovationSampleRequestId = innovationRequest.Id;
        List<Innovation_Project_Details__c> projectDetailList = new List<Innovation_Project_Details__c>();
        
        Test.startTest();
            projectDetailList = testInformationTableController.getInnovationProjectDetails();
        Test.stopTest();
        
        System.assertEquals(true, projectDetailList.size() > 0, 'It should return Project Detail list');
    }
}