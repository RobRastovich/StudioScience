@isTest
public class ScheduleEskerEmailTest {
    
    public static testMethod void testConstructor(){
		ScheduleEskerEmail con = new ScheduleEskerEmail();
	} 
    
    public static testMethod void executeBatchEsker(){
         System.runAs(new User(Id=UserInfo.getUserId()))
        {
        Test.startTest();    
		Group testGroup = new Group(Name='Orders Queue', Type='Queue');
        insert testGroup;
       	QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
        insert testQueue;
        String ordersRTName = CSConstants.ORDERS;
        Id ordersRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ordersRTName).getRecordTypeId();
        Case testCase = new Case();
        testCase.RecordTypeId = ordersRecordTypeId;
        testCase.Type='Standard';
        testCase.Origin='Customer Portal';
        testCase.Email_Sent_to_Esker__c=false;
        testCase.OwnerId = testGroup.Id;
        testCase.status='New';
        testCase.Subject='Testing';
        testCase.Flow__c=false;
        insert testCase;
        ContentVersion eskarDoc = CaseServicesTest.createContentVersion();
        eskarDoc = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :eskarDoc.Id LIMIT 1];
        ContentDocumentLink docLink = CaseServicesTest.createContentDocumentLink(testCase.Id, eskarDoc.ContentDocumentId);
        
		ScheduleEskerEmail b = new ScheduleEskerEmail();
        DataBase.executeBatch(b);
        
        System.assertEquals(0, Limits.getEmailInvocations(), 'Eskar email should have been sent.');

		Test.stopTest();
    }
    }

}