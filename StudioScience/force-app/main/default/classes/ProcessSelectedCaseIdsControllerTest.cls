@isTest
private class ProcessSelectedCaseIdsControllerTest{
    static testMethod void testMethod1() 
    {
        List <Case> lstCases = new List<Case>();
        List<String> RecordTypeIdSet = new List<String>();
        recordType rt = [SELECT ID,Name from RecordType where name='Customer Data'];
        Case caserec = new Case();
        caserec.Type='CMIR Update';
        caserec.status ='New';
        Caserec.RecordTypeId = rt.id;
        
        lstCases.add(caserec);
        Case Caserec1 = new Case();
        caserec1.Type='Other';
        caserec1.status ='New';
        Caserec.RecordTypeId = rt.id;
        lstCases.add(caserec1);
        
        insert  lstCases;
        
        for(Case c : lstCases){
            RecordTypeIdSet.add(c.id);
        }
        
        // String CaseIds;
        
        // CaseIds.add(caserec.id);
        // CaseIds.add(caserec1.id);
        
        String customIdsStr = JSON.serialize(lstCases);
        
        Test.startTest();
        //Test.setCurrentPage(Page.YOUR_PAGE);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstCases);
        stdSetController.setSelected(lstCases);
        ProcessSelectedCaseIdsController process= new ProcessSelectedCaseIdsController(stdSetController);
        String Type = 'Item Investigation';
        
        ProcessSelectedCaseIdsController.updateType(Type,customIdsStr);
        ProcessSelectedCaseIdsController.getRecordType(RecordTypeIdSet);
        Test.stopTest();
    }
    
    static testMethod void testMethod2() 
    {
        List <Case> lstCases = new List<Case>();
        recordType rt = [SELECT ID,Name from RecordType where name='Customer Data'];
        Case caserec = new Case();
        caserec.Type='CMIR Update';
        caserec.status ='New';
        Caserec.RecordTypeId = rt.id;
        
        lstCases.add(caserec);
        Case Caserec1 = new Case();
        caserec1.Type='Other';
        caserec1.status ='New';
        Caserec.RecordTypeId = rt.id;
        lstCases.add(caserec1);
        
        insert  lstCases;
        
        List<String>CaseIds = new List<String>();
        
        CaseIds.add(caserec.id);
        CaseIds.add(caserec1.id);
        
        String customIdsStr = JSON.serialize(CaseIds);
        
        Test.startTest();
        //Test.setCurrentPage(Page.YOUR_PAGE);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstCases);
        stdSetController.setSelected(lstCases);
        ProcessSelectedCaseIdsController process= new ProcessSelectedCaseIdsController(stdSetController);
        String DistributorCategory = 'All';
        
        ProcessSelectedCaseIdsController.updateDistributorCategory(DistributorCategory,CaseIds);
        Test.stopTest();
    }
}