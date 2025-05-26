@isTest(seeAllData=false)
public class BCH_DSC_UpdateTriggerFieldTest 
{
    @testSetup
    static void setup() {
        List<TriggerWords__c> lstTriggerWord = new List<TriggerWords__c>();
        lstTriggerWord.add(new TriggerWords__c(Name='Cut', Priority__c='Critical', Type__c='Complaint', Status__c='Active'));
        lstTriggerWord.add(new TriggerWords__c(Name='Urgent', Priority__c='High', Type__c='Complaint', Status__c='Active'));
        lstTriggerWord.add(new TriggerWords__c(Name='Nutritional Information', Priority__c='High', Type__c='Inquiry', Status__c='Active'));
        lstTriggerWord.add(new TriggerWords__c(Name='test', Priority__c='Low', Type__c='Inquiry', Status__c='Active'));
        insert lstTriggerWord;
        
        caseServices.runTrigger = false;
        Case testCase = new Case();
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Quality Claim').getRecordTypeId();
        testCase.Description='cut';
        
        insert testCase;
        
        
    }
    
    static testmethod void testIfTriggerFieldGotChecked()
    {
        Test.startTest();
        BCH_DSC_UpdateTriggerField bdu = new BCH_DSC_UpdateTriggerField();
        Database.executeBatch(bdu);
        Test.stopTest();
        Case updatedCase= [Select trigger_word__c from case];
        System.assertEquals(true,updatedCase.trigger_word__c,'trigger word field is not true.');
    }
}