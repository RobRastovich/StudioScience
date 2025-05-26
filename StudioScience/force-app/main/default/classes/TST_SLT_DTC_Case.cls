@isTest
public class TST_SLT_DTC_Case {

    @testSetup
    static void dataSetup() {
        List<Case> casesList = new List<Case>();
        Case caseDetail = TST_TestDataFactory.createCase(null, false);
        caseDetail.OrderID__c = '12345';
        caseDetail.Status = 'In Progress';
        caseDetail.Sub_Status__c = 'Reship Confirmed';
        caseDetail.Origin = 'DHL Portal';
        caseDetail.DHL_Status__c = 'Returned to warehouse(Damage)';
        casesList.add(caseDetail);
        Case dhlCaseDetail = TST_TestDataFactory.createCase(null, false);
        dhlCaseDetail.OrderID__c = '123456';
        dhlCaseDetail.Status = 'In Progress';
        dhlCaseDetail.Sub_Status__c = 'Reship Confirmed';
        dhlCaseDetail.Origin = 'Magento';
        dhlCaseDetail.DHL_Status__c = 'Returned to warehouse(Damage)';
        casesList.add(dhlCaseDetail);
        Case caseGetCaseRecordsToEmailAndBrand = TST_TestDataFactory.createCase(null, false);
        caseGetCaseRecordsToEmailAndBrand.OrderID__c = 'Test123456';
        caseGetCaseRecordsToEmailAndBrand.Program_Subscription__C = 'Jim Beam';
        caseGetCaseRecordsToEmailAndBrand.Email_Address__c = 'abc@test.com';
        casesList.add(caseGetCaseRecordsToEmailAndBrand);
        if (casesList.size()>0) {
            insert casesList;
        }
        Group grp = TST_TestDataFactory.createGroup(true, null);
    }

    @isTest
    private static void testGetCaseByID() {
        Case caseDetail = [SELECT id, First_name__c, Last_name__c, Email_Address__c,
                                Brand__c 
                                FROM Case][0];

        Test.startTest();
            Case created = SLT_DTC_Case.getCaseByID(caseDetail.Id);
        Test.stopTest();

        System.assertNotEquals(null, created.Id , 'No Records created when expected');
    }
    
    @isTest
    private static void testGetCaseRecordByCaseNumber() {
        Case caseDetail = [SELECT id, CaseNumber, First_name__c, Last_name__c, Email_Address__c,
                                Brand__c 
                                FROM Case][0];

        Test.startTest();
            Case created = SLT_DTC_Case.getCaseRecordByCaseNumber(caseDetail.CaseNumber);
        Test.stopTest();

        System.assertNotEquals(null, created.Id , 'No Records created when expected');
    }
    
    @isTest
    private static void testGetCaseRecordByOrderID() {
        Case caseDetail = [SELECT id, CaseNumber, OrderID__c, First_name__c, Last_name__c, Email_Address__c,
                                Brand__c FROM Case][0];

        Test.startTest();
            Case created = SLT_DTC_Case.getCaseRecordByOrderID(caseDetail.OrderID__c);
        Test.stopTest();

        System.assertNotEquals(null, created.Id , 'No Records created when expected');
    }
    
    @isTest
    private static void testGetCaseDetailByID() {
        Case caseDetail = [SELECT id, CaseNumber, OrderID__c, First_name__c, Last_name__c, Email_Address__c,
                                Brand__c FROM Case][0];

        Test.startTest();
            Case created = SLT_DTC_Case.getCaseDetailByID(caseDetail.Id);
        Test.stopTest();

        System.assertNotEquals(null, created.Id , 'No Records created when expected');
    }
    
    @isTest
    private static void testGetCasesList() {
        Case caseDetail = [SELECT id, CaseNumber, RecordTypeId, OrderID__c, First_name__c, Last_name__c, Email_Address__c,
                                Brand__c, CreatedDate, DHL_Status__c, AdditionalInformation__c, Origin, Status 
                                FROM Case][0];
        Set<Id> recordTypeIds = new Set<Id>();
        recordTypeIds.add(caseDetail.RecordTypeId);
        
        Test.startTest();
            List<Case> createdCases = SLT_DTC_Case.getCasesList(1, 5, String.valueOf(caseDetail.CaseNumber) ,recordTypeIds, 
            String.valueOf(caseDetail.Origin), 'ASC');
        Test.stopTest();
        
        System.assertNotEquals(null, createdCases , 'No Records created when expected');
    }

    @isTest
    private static void testGetCasesListMagento() {
        Case caseDetail = [SELECT id, CaseNumber, RecordTypeId, OrderID__c, First_name__c, Last_name__c, Email_Address__c,
                                Brand__c, CreatedDate, DHL_Status__c, AdditionalInformation__c, Origin, Status 
                                FROM Case 
                                WHERE origin = 'Magento'][0];
        Set<Id> recordTypeIds = new Set<Id>();
        recordTypeIds.add(caseDetail.RecordTypeId);
        
        Test.startTest();
            List<Case> createdCases = SLT_DTC_Case.getCasesList(1, 5, String.valueOf(caseDetail.CaseNumber) ,recordTypeIds, 
            String.valueOf(caseDetail.Origin), 'ASC');
        Test.stopTest();
        
        System.assertNotEquals(null, createdCases , 'No Records created when expected');
    }
    
    @isTest
    private static void testGetCasesCount() {
        Case caseDetail = [SELECT id, CaseNumber, RecordTypeId, OrderID__c, First_name__c, Last_name__c, Email_Address__c,
                                Brand__c, CreatedDate, DHL_Status__c, AdditionalInformation__c, Origin, Status 
                                FROM Case][0];
        Set<Id> recordTypeIds = new Set<Id>();
        recordTypeIds.add(caseDetail.RecordTypeId);

        Test.startTest();
            Integer count = SLT_DTC_Case.getCasesCount(String.valueOf(caseDetail.CaseNumber) ,recordTypeIds, String.valueOf(caseDetail.Origin));
        Test.stopTest();
        
        System.assertNotEquals(0, count , 'Count should be greater than zero.');
    }
    
    @isTest
    private static void testGetDhlCaseByID() {
        Case caseDetail = [SELECT id, CaseNumber, RecordTypeId, OrderID__c, First_name__c, Last_name__c, Email_Address__c,
                                Brand__c 
                                FROM Case][0];
        
        Test.startTest();
            Case returnCase = SLT_DTC_Case.getDhlCaseByID(caseDetail.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, returnCase , 'No record returned when expected');
    }

    @isTest
    private static void testGetMapOfCasesToOrderID() {
        Case caseDetail = [SELECT id, CaseNumber, RecordTypeId, OrderID__c, First_name__c, Last_name__c, Email_Address__c,
                                Brand__c 
                                FROM Case][0];
        Set<String> orderIds = new Set<String>{caseDetail.orderID__c};
        Set<String> recordTypeIds = new Set<String>{DTC_Constants.CASE_DTC_RECORDTYPEID};    

        Test.startTest();
            Map<String, Case> orderIdToCaseMap = SLT_DTC_Case.getMapOfCasesToOrderID(orderIds, recordTypeIds);
        Test.stopTest();
        
        System.assertNotEquals(null, orderIdToCaseMap , 'No record returned when expected');
    }

    @isTest
    private static void testGetMapOfCasesToEmailID() {
        Case caseDetail = [SELECT id, RecordTypeId, Email_Address__c, Brand__c
                                FROM Case][0];
        Set<String> emailIds = new Set<String>{caseDetail.Email_Address__c};
        Set<String> recordTypeIds = new Set<String>{DTC_Constants.CASE_DTC_RECORDTYPEID};    

        Test.startTest();
            Map<String, Case> emailIdToCaseMap = SLT_DTC_Case.getMapOfCasesToEmailID(emailIds, recordTypeIds);
        Test.stopTest();
        
        System.assertNotEquals(null, emailIdToCaseMap , 'No record returned when expected');
    }
    @isTest
    private static void testGetCaseRecordsToEmailAndBrand(){
        Case caseRec= [SELECT ID, OrderID__c, Status, Sub_Status__c, CaseNumber, Program_Subscription__C,
                       Email_Address__c, Brand__c
                       FROM Case
                       WHERE OrderID__c= 'Test123456'];
        
        Test.startTest();
        List<Case> returnCases  = SLT_DTC_Case.getCaseRecordsToEmailAndBrand(caseRec.OrderID__c, caseRec.Email_Address__c, caseRec.Program_Subscription__C);
        Test.stopTest();
        System.assertNotEquals(0, returnCases.size() , 'No record returned when expected');
    }
    @isTest
    private static void testGetCaseRecordsToEmailAndBrandWhenOrderIdNull(){
        Case caseRec= [SELECT ID, OrderID__c, Status, Sub_Status__c, CaseNumber, Program_Subscription__C,
                       Email_Address__c, Brand__c
                       FROM Case
                       WHERE OrderID__c= 'Test123456'];
        
        Test.startTest();
        List<Case> returnCases  = SLT_DTC_Case.getCaseRecordsToEmailAndBrand(null, caseRec.Email_Address__c, caseRec.Program_Subscription__C);
        Test.stopTest();
        System.assertNotEquals(0, returnCases.size() , 'No record returned when expected');
    }		
}