@isTest(SeeAllData = false)
public class CustomerDataSubCaseCreationCntrlTest{
    public static testMethod void customerDatasubCase() {
        Id CustCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Data').getRecordTypeId();
        Case c = new Case();
        c.Status = 'New';
        c.In_field_Date__c= system.today()+2;
        c.RecordTypeId = CustCaseRecordTypeId ;
        insert c;
        List<Id>Caseids = new List<Id>();
        Caseids.add(c.id);
        
        CustomerDataSubCaseCreationCntrl.CreateCustomerDataSubCase(Caseids);
    }

}