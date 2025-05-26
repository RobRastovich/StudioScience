@isTest
public class BCH_SCR_CaseUpdationBrandFamilyTest
{
    static Id ConsumerInquiryRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumer_Inquiry').getRecordTypeId();
    static testMethod void testMethod1()
    {
        List<Case> cases= new List<Case>();

        for(Integer i = 0 ; i < 5 ; i++)
        {
            Case testCase = new Case();
            testCase.recordTypeId = ConsumerInquiryRecordTypeId;
            testCase.Status = 'Open';
            testCase.Brand__c = 'Jim Beam';
            testCase.CaseClosedType__c = NULL;
            cases.add(testCase);
        }
        for(Integer i = 0 ; i < 6 ; i++)
        {
            Case testCase = new Case();
            testCase.recordTypeId = ConsumerInquiryRecordTypeId;
            testCase.Status = 'Open';
            testCase.Brand__c = 'Bowmore';
            testCase.CaseClosedType__c = NULL;
            cases.add(testCase);
        }
        insert cases;

        Test.startTest();

            BCH_SCR_CaseUpdationBrandFamily obj = new BCH_SCR_CaseUpdationBrandFamily();
            DataBase.executeBatch(obj, 100); 

        Test.stopTest();

        List<Case> casesToTest = [SELECT Id, Status, CaseClosedType__c FROM Case WHERE Status IN ('Resolved', 'Closed') AND recordTypeId =: ConsumerInquiryRecordTypeId AND CaseClosedType__c = NULL];
        System.assertEquals(0, casesToTest.size());
    }
}