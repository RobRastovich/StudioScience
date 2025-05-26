@isTest
public class TST_CNT_DTC_DHLCases {
    @testSetup
    static void setUpTestData() {    
        Case newCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        newCase.Origin = 'DHL Portal';
        newCase.OrderID__c = 'Test12345';
        newCase.DHL_Status__c = 'Returned to warehouse(Damage)';
        insert newCase;
        
        Account accnt = TST_TestDataFactory.createPersonAccount(DTC_Constants.ACCOUNT_CONSUMER_RECORDTYPEID, false);
        accnt.PersonEmail = newCase.Email_Address__c;
        insert accnt;

        Contact cont = TST_TestDataFactory.createContact(null, false);
        cont.Email = newCase.Email_Address__c;
        insert cont;

        Case cs = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        cs.Email_Address__c = 'test12345qwerty@gmail.com';
        insert cs;
    }
    
    @isTest
    private static void testGetCasesList() {
        Case cs = [Select id, CaseNumber, Origin from case limit 1];
        
        Test.startTest();
            List<Case> cases = CNT_DTC_DHLCases.getCasesList(0, 10, 0, cs.CaseNumber, cs.Origin, 'ASC');
        Test.stopTest();

        System.assertNotEquals(null, cases , 'No Records returned when expected');
    }
    
     @isTest
    private static void testGetCasesCount() {
        Case cs = [Select id, CaseNumber, Origin from case limit 1];
        
        Test.startTest();
            Integer count = CNT_DTC_DHLCases.getCasesCount(cs.CaseNumber, cs.Origin);
        Test.stopTest();

        System.assertEquals(1, count , 'Return Count not equal to 1.');
    }
    
    @isTest
    private static void testCreateCaseException() {
        Case newCase = [Select Id, CaseNumber, First_Name__c, Last_Name__c, Email_Address__c, Origin, Consumer_Country__c,
                            Consumer_City__c, Consumer_Postal_Code__c, Consumer_Street__c, Program_Subscription__c, 
                            DHL_Status__c,Customer_Phone_Number__c, Consumer_State__c, UPS_Tracking_Number__c, 
                            UPS_Reason_For_Return__c
                            FROM case limit 1];
        Test.startTest();
            try {
                Case returnCase = CNT_DTC_DHLCases.createCase(newCase);
            }
            catch(exception e){
            }     
        Test.stopTest();

        Case createdCase = [Select Id From Case where First_Name__c =: newCase.First_Name__c limit 1];
        System.assertNotEquals(null, createdCase , 'No Records returned when expected');
    }

    @isTest
    private static void testCaseWhenRequiredFieldsAreMissing() {
       Case cs = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        cs.Consumer_Country__c = '';
        cs.UPS_Tracking_Number__c = '';
        cs.UPS_Reason_For_Return__c = '';
        cs.DHL_Status__c = '';
        
        Test.startTest();
            Boolean isValidated = CNT_DTC_DHLCases.isValidated(cs);
        Test.stopTest();
        
        System.assertNotEquals(true, isValidated , 'Validation should return false.');
    }
    
    @isTest
    private static void testCaseIsValidatedShouldReturnFalse() {
       Case caseNew;
        
        Test.startTest();
            Boolean isValidated = CNT_DTC_DHLCases.isValidated(caseNew);
        Test.stopTest();
        
        System.assertNotEquals(true, isValidated , 'Validation should return false.');
    }
    @isTest
    private static void testManageContactDetails() {
        Case caseCreated = [Select id, CaseNumber, First_Name__c, Last_Name__c, Email_Address__c, Origin 
                                FROM case limit 1];
        
        Test.startTest();
            CNT_DTC_DHLCases.manageContactDetails(caseCreated);
        Test.stopTest();
        
        Contact contactDetail = [SELECT Id, Name, Email, MagentoID__c FROM Contact 
                                    WHERE Email =: caseCreated.Email_Address__c LIMIT 1];
        
        System.assertNotEquals(null, contactDetail , 'No Records returned when expected');
    }
    
    @isTest
    private static void testManageAccountDetails() {
        Case cs = [Select Id, CaseNumber, First_Name__c, Last_Name__c, Email_Address__c, Origin, Consumer_Country__c,
                        Consumer_City__c, Consumer_Postal_Code__c, Consumer_Street__c, Consumer_State__c 
                        FROM case limit 1];
        
        Test.startTest();
            Case returnCase = CNT_DTC_DHLCases.manageAccountDetails(cs);
        Test.stopTest();

        System.assertNotEquals(null, returnCase , 'No Records returned when expected');
    }
    
     @isTest
    private static void testManageAccountDetailsWhenAccountNotExist() {
        Case cs = [SELECT Id, CaseNumber, First_Name__c, Last_Name__c, Email_Address__c, Origin, Consumer_Country__c,
                        Consumer_City__c, Consumer_Postal_Code__c, Consumer_Street__c, Consumer_State__c 
                        FROM case 
                        WHERE Email_Address__c = 'test12345qwerty@gmail.com' 
                        LIMIT 1];
        
        Test.startTest();
            Case returnCase = CNT_DTC_DHLCases.manageAccountDetails(cs);
        Test.stopTest();

        System.assertNotEquals(null, returnCase , 'No Records returned when expected');
    }

    @isTest
    private static void testCheckStatusFlowOfCaseStatusDTC() {
        List<Case> newList = [SELECT id, OwnerId, Status FROM Case];

        Test.startTest();
            Case cas = CNT_DTC_DHLCases.getCaseRecord(newList[0].Id);
        Test.stopTest();

        System.assertEquals(newList[0].Id, cas.Id, 'The returnd case is incorrect. ');
    }
}