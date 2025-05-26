@isTest
public class CNT_CaseOwnerChange_Test {
    
    @testSetup
    static void setupMethod(){
        Case cse = new Case();
		cse.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumer_Inquiry').getRecordTypeId();
		cse.Brand__c = 'Knob Creek';
        cse.Product_Type__c = 'Bourbon';
        cse.Status ='Resolved';
        insert new List<Case> {cse};
         
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        User usr = new User();
        usr.Email = 'ABC.Metacube@gmail.com';
        usr.Username = 'ABC.Metacube@gmail.com';
        usr.LastName ='XYZ';
        usr.Alias = 'ABC';
        usr.TimeZoneSidKey = 'America/Los_Angeles';
        usr.LocaleSidKey = 'en_US';
        usr.EmailEncodingKey =  'ISO-8859-1';
        usr.ProfileId = pf.Id ;
        usr.LanguageLocaleKey = 'en_US';
        insert usr;
        
       	ConsumerServices__c consumerServices = new ConsumerServices__c();
        consumerServices.Agent_Email__c=usr.Email;
        insert consumerServices;
            
    }
    
    @isTest
    static void testUpdateStatusMethod(){
        
       Test.startTest();
        	Case c= [SELECT Id FROM Case WHERE Brand__c='Knob Creek' LIMIT 1];
        	CNT_CaseOwnerChange.updateStatus(c,c.Id);
       Test.stopTest();
       Case caseAfterProcessed = [SELECT Id,CaseClosedType__c FROM Case limit 1];
       System.assertEquals('Agent Closed', caseAfterProcessed.CaseClosedType__c);
        
       String recId='50003000003tJbWAAU';
        try{
            CNT_CaseOwnerChange.updateStatus(c,recId);
        }
        catch(Exception e){
            
     }
}
    @isTest
    static void testchangeRecordMethod(){
        
       Test.startTest();
       		Case c = [SELECT Id,RecordTypeId,CaseNumber FROM Case WHERE Brand__c='Knob Creek' LIMIT 1];
       		CNT_CaseOwnerChange.changeRecord(c,c.Id,c.RecordTypeId,c.CaseNumber);
       Test.stopTest();
       Case caseAfterProcessed = [SELECT Id,How_can_we_help__c FROM Case limit 1];
       System.assertEquals('Product or Packaging issue', caseAfterProcessed.How_can_we_help__c);
}
    
    @isTest
    static void testEscalateCaseApexMethod(){
        
       Test.startTest();
           Case c = [SELECT Id, RecordTypeId FROM Case WHERE Product_Type__c = 'Bourbon' LIMIT 1];
           CNT_CaseOwnerChange.escalateCaseApex(c,c.Id,c.RecordTypeId);
       Test.stopTest();
       Case caseAfterProcessed = [SELECT Id,IsEscalated FROM Case limit 1];
       System.assertEquals(true, caseAfterProcessed.IsEscalated);
       
	}
    
    @isTest
    static void testisUserAccessibleForCloningmethod(){
        
        Test.startTest();
            Case c= [SELECT Id FROM Case WHERE Brand__c='Knob Creek' LIMIT 1];
            Boolean isUserAccesible = CNT_CaseOwnerChange.isUserAccessibleForCloning(c.id,'abc@.Metacube@BeamSuntory.com');
        Test.stopTest();
        
        System.assertNOTEquals(true,isUserAccesible);
    }
    
    @isTest
    static void testcloneCaseMethod(){
        
        Test.startTest();
            case c = [SELECT Id FROM Case WHERE Product_Type__c = 'Bourbon' LIMIT 1];   
            CNT_CaseOwnerChange.cloneCaseMethod(c,c.Id);
        Test.stopTest();
        
        case cse= [select id , ParentId from case where ParentId =:c.Id];
        System.assertEquals (c.id,cse.ParentId);
    }
    
}