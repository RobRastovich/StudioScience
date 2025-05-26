@isTest(SeeAllData = false)

public class BarrelReadySubCaseCreationCntrlTest {  
    
    public static testMethod void barrelReadySubCase() {
        Id CASE_RT_BarrelReady = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Barrel Ready to Enter').getRecordTypeId();
        Case c = new Case();
        c.Status = 'New';
        c.Type = 'Barrel Ready to Enter';
        c.RecordTypeId = CASE_RT_BarrelReady ;
        insert c;
        List<Id>Caseids = new List<Id>();
        
        List<Case> Cases = [Select Id,Type from Case where Id in : CaseIds];
        Cases.add(c);
        BarrelReadySubCaseCreationCntrl.createSubCaseForBarrelReady(Cases);
    }   
  
        

}