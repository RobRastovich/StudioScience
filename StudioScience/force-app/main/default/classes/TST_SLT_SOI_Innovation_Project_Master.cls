@isTest
private class TST_SLT_SOI_Innovation_Project_Master {
    @testSetup
    static void testDataSetup() {
        TST_TestDataFactory.createInnovationMaster(true);
    }
    
    private static Innovation_Project_Master__c getInnovationMaster() {
        return [SELECT Id FROM Innovation_Project_Master__c LIMIT 1];
    }
    
    @isTest
    private static void testGetInnovationSampleRecords() {
        List<Innovation_Project_Master__c> sampleList = new List<Innovation_Project_Master__c>();
        
        Test.startTest();
            sampleList = SLT_SOI_Innovation_Project_Master.getInnovationSampleRecords();
        Test.stopTest();
        
        System.assertEquals(true, sampleList.size() > 0, 'Should return Innovation Sample records');
        System.assertEquals('Test Project Master', sampleList[0].Name, 'Name of Record should be Test Project Master');
    }
    
    @isTest
    private static void testGetProjectName() {
        Innovation_Project_Master__c innovationProject = getInnovationMaster();
        String projectName;
        
        Test.startTest();
            projectName = SLT_SOI_Innovation_Project_Master.getProjectName(innovationProject.Id);
        Test.stopTest();
        
        System.assertEquals('Test Project Master', projectName, 'Project Name Should Be Test Project Master');
    }
}