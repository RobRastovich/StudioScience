@isTest
private class TST_SLT_SOI_Innovation_Project_Details {
    @testSetup
    static void testDataSetup() {
        Innovation_Project_Master__c innovationMaster = TST_TestDataFactory.createInnovationMaster(true);
        Innovation_Sample_Requests__c innovationRequest = TST_TestDataFactory.createInnovationRequest(false);
        innovationRequest.Innovation_Samples__c = innovationMaster.Id;
        insert innovationRequest;
        Innovation_Project_Details__c innovationDetail = TST_TestDataFactory.createInnovationDetail(false);
        innovationDetail.InnovationId__c = innovationRequest.Id;
        insert innovationDetail;
    }
    
    private static Innovation_Sample_Requests__c getInnovationRequest() {
        return [SELECT Id, Name FROM Innovation_Sample_Requests__c
                   WHERE Name = 'Test Innovation Request' LIMIT 1];
    }
    
    @isTest
    private static void testGetInnovationProjectDetails() {
        List<Innovation_Project_Details__c> detailList = new List<Innovation_Project_Details__c>();
        Innovation_Sample_Requests__c innovationRequest = getInnovationRequest();
        Id innovationRequestId = innovationRequest.Id;
        
        Test.startTest();
            detailList = SLT_SOI_Innovation_Project_Details.getInnovationProjectDetails(innovationRequestId);
        Test.stopTest();
        
        System.assertEquals(true, detailList.size() > 0, 'Should return Innovation Project Details records');
        System.assertEquals(100, detailList[0].Quantity__c, 'Quantity value should be 100');
    }
}