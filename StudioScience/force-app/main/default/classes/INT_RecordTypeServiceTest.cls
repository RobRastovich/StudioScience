@isTest
public class INT_RecordTypeServiceTest {
    @isTest
    static void validateRecordTypeByDeveloperName() {        
        Test.startTest();
        Map<String, RecordType> result = INT_RecordTypeService.getRecordTypesByDeveloperName('INT_EmailDelivery__c');
        
        Test.stopTest();
        
        System.assertEquals(result.size() > 0, true, 'Valid record types could not be retrieved.');
    }    
}