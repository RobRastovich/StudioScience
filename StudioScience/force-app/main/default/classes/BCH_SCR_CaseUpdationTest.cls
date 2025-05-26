@isTest 
public class BCH_SCR_CaseUpdationTest 
{
    static testMethod void testMethod1() 
    {
        List<Case> cases= new List<Case>();
        Id ConsumerInquiryRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumer_Inquiry').getRecordTypeId();
        for(Integer i = 0 ; i < 5 ; i++)
        {
            Case testCase = new Case();
            testCase.recordTypeId = ConsumerInquiryRecordTypeId;
            testCase.Status = 'Resolved';
            testCase.CaseClosedType__c = NULL;
            testCase.AgentResponseOnCase__c = null;
            testCase.Brand__c = 'Knob Creek';
            testCase.ConsumerResponseOnCase__c = null;
            cases.add(testCase);
        }
        for(Integer i = 0 ; i < 5 ; i++)
        {
            Case testCase = new Case();
            testCase.recordTypeId = ConsumerInquiryRecordTypeId;
            testCase.Status = 'Closed';
            testCase.CaseClosedType__c = NULL;
            testCase.AgentResponseOnCase__c = null;
            testCase.ConsumerResponseOnCase__c = null;
            testCase.Brand__c = 'Knob Creek';
            cases.add(testCase);
        }        
        insert cases;
        
        Test.startTest();
        
            BCH_SCR_CaseUpdation obj = new BCH_SCR_CaseUpdation();
            DataBase.executeBatch(obj, 50); 
        
        Test.stopTest();
        
        List<Case> casesToTest = [SELECT Id, Status, CaseClosedType__c FROM Case WHERE Status IN ('Resolved', 'Closed') AND recordTypeId =: ConsumerInquiryRecordTypeId AND CaseClosedType__c = NULL];
        System.assertEquals(0, casesToTest.size());
    }

    static testMethod void testMethod3() 
    {
        List<EmailMessage> emailMessages= new List<EmailMessage>();
        List<Case> cases = new List<Case>();
        Id ConsumerInquiryRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumer_Inquiry').getRecordTypeId();
        
        Case testOpenCase = new Case();
        testOpenCase.recordTypeId = ConsumerInquiryRecordTypeId;
        testOpenCase.Status = 'Open';  
        testOpenCase.AgentResponseOnCase__c = null;
        testOpenCase.ConsumerResponseOnCase__c = null;     
        cases.add(testOpenCase);
        
        Case testOpenCase2 = new Case();
        testOpenCase2.recordTypeId = ConsumerInquiryRecordTypeId;
        testOpenCase2.Status = 'Open';   
        testOpenCase2.AgentResponseOnCase__c = null;
        testOpenCase2.ConsumerResponseOnCase__c = null;    
        cases.add(testOpenCase2);
		insert cases;

        EmailMessage testOpenEmailMessage = new EmailMessage();
        testOpenEmailMessage.Incoming = true;
        testOpenEmailMessage.FromAddress = 'test@test.com';
        testOpenEmailMessage.ParentId = testOpenCase.Id;
        emailMessages.add(testOpenEmailMessage);
        
        EmailMessage testOpenEmailMessage2 = new EmailMessage();
        testOpenEmailMessage2.Incoming = false;
        testOpenEmailMessage2.FromAddress = 'consumerinquiries@beamsuntory.com';
        testOpenEmailMessage2.ParentId = testOpenCase2.Id;
        emailMessages.add(testOpenEmailMessage2);

        insert emailMessages;
        
        Test.startTest();
        
            BCH_SCR_CaseResponseUpdation obj = new BCH_SCR_CaseResponseUpdation();
            DataBase.executeBatch(obj, 50); 
        
        Test.stopTest();
        
        List<Case> casesToTest = [SELECT Id, AgentResponseOnCase__c, ConsumerResponseOnCase__c, (SELECT Id, Status, FromAddress, Incoming, CreatedDate, CreatedBy.Name FROM EmailMessages) FROM Case WHERE recordTypeId =: ConsumerInquiryRecordTypeId AND (AgentResponseOnCase__c = NULL OR ConsumerResponseOnCase__c = NULL)];
        System.assertEquals(0, casesToTest.size());
    }
    
    static testMethod void testMethod4() 
    {
        List<Case> cases= new List<Case>();
        Id ConsumerInquiryRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumer_Inquiry').getRecordTypeId();
        for(Integer i = 0 ; i < 5 ; i++)
        {
            Case testCase = new Case();
            testCase.recordTypeId = ConsumerInquiryRecordTypeId;
            testCase.Status = 'DUP - No Action';
            cases.add(testCase);
        }        
        insert cases;
        
        Test.startTest();
        
            BCH_SCR_CaseStatusUpdationToDuplicate obj = new BCH_SCR_CaseStatusUpdationToDuplicate();
            DataBase.executeBatch(obj, 50); 
        
        Test.stopTest();
        
        List<Case> casesToTest = [SELECT Id, Status FROM Case WHERE Status = 'DUP - No Action' AND recordTypeId =: ConsumerInquiryRecordTypeId];
        System.assertEquals(0, casesToTest.size());
    }
    
    static testMethod void testMethod5() 
    {
        List<Case> cases= new List<Case>();
        Id ConsumerInquiryRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumer_Inquiry').getRecordTypeId();
        for(Integer i = 0 ; i < 10 ; i++)
        {
            Case testCase = new Case();
            testCase.recordTypeId = ConsumerInquiryRecordTypeId;
            testCase.Status = 'Open';
            testCase.ownerId = '0051J000005rvV3QAI';
            cases.add(testCase);
        }      
        insert cases;
        
        Test.startTest();
        
            BCH_SCR_CaseStatusUpdationToAssigned obj = new BCH_SCR_CaseStatusUpdationToAssigned();
            DataBase.executeBatch(obj, 50); 
        
        Test.stopTest();
        
        List<Case> casesToTest = [SELECT Id, Status, OwnerId FROM Case WHERE Status = 'Open' AND recordTypeId =: ConsumerInquiryRecordTypeId];
        System.assertEquals(0, casesToTest.size());
    }
}