/**************************************************************************************
Apex Class Name     : EmailMessageServicesTest
Created Date        : 20-11-2021
Function            : Test class of EmailMessageServices class.
*************************************************************************************/
@isTest
public class EmailMessageServicesTest {
    @testSetup
    static void setupMethod(){
        Case cse = new Case();
		cse.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumer_Inquiry').getRecordTypeId();
		cse.Brand__c = 'Knob Creek';
		cse.Barrel_Selected__c = false;
		cse.Product_Type__c = 'Bourbon';
		cse.ccEmail__c = 'test@test.com';
        cse.Status='Resolved';
        insert new List<Case> {cse};
    }
    @isTest
    static void testResolvedCase() {
        Case caseToBeProcessed = [SELECT Id,Status FROM CASE limit 1];
        Test.startTest();
            EmailMessage em=new EmailMessage();
            em.ParentId=caseToBeProcessed.Id;
            em.Incoming=true;
            insert em;
        Test.stopTest();
        Case caseAfterProcessed = [SELECT Id,Status FROM Case limit 1];
        System.assertEquals('Reopen', caseAfterProcessed.Status,'Case should be in reopen status');
	}
    @isTest
    static void testClosedCase() {
        Case caseToBeProcessed = [SELECT Id,Status FROM CASE limit 1];
        caseToBeProcessed.Status = 'Closed';
        update caseToBeProcessed;
        Test.startTest();
            EmailMessage em = new EmailMessage();
            em.ParentId = caseToBeProcessed.Id;
            em.Incoming = true;
            insert em;
        Test.stopTest();
        List<Case> caseAfterProcessed = [SELECT Id,Status FROM Case];
        System.assertEquals(2, caseAfterProcessed.size(),'New case should be created if email is received on closed case');
	}
    @isTest
    static void testUpdateTimeToRespond() {
        Case caseToBeProcessed = [SELECT Id,Status,Time_To_Respond__c FROM CASE limit 1];
        Test.startTest();
            EmailMessage em = new EmailMessage();
            em.ParentId = caseToBeProcessed.Id;
            em.Incoming = false;
            insert em;
            List<EmailMessage> emList = new List<EmailMessage>();
            emList.add(em);
            EmailMessageServices.updateTimeToRespond(emList);
            em.Subject = 'Test Subject';
            update em;
        Test.stopTest();
        Case caseAfterProcessed = [SELECT Id,Status,Time_To_Respond__c FROM CASE limit 1];
        System.assertNotEquals(NULL,caseAfterProcessed.Time_To_Respond__c,'Time to respond updated');
	}
    @isTest
    static void testUpdateBrandFamily(){
        Case caseToBeProcessed = [SELECT ID, Brand__c, Brand_Family__c FROM Case LIMIT 1];
        caseToBeProcessed.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumer_Inquiry').getRecordTypeId();
        caseToBeProcessed.Status = 'NEW';
        caseToBeProcessed.Brand__c = null;
        caseToBeProcessed.Brand_Family__c = null;
        update caseToBeProcessed;
        Test.startTest();
            EmailMessage em = new EmailMessage();
            em.ParentId = caseToBeProcessed.Id;
            em.Incoming = true;
            em.ToAddress = 'info@makersmark.com';
            em.Subject = 'Test Subject';
            insert em;
        Test.stopTest();
        Case caseAfterProcessed = [SELECT Id,Brand__c, Brand_Family__c FROM CASE limit 1];
        System.assertEquals('Maker\'s Mark',caseAfterProcessed.Brand__c,'Brand Updated');
        System.assertEquals('Maker\'s Mark',caseAfterProcessed.Brand_Family__c,'Brand Family Updated');
    }
    @isTest
    static void testCountCounsumerInquiryEmailTemplates(){
        Case caseToBeProcessed = [SELECT Id,Status FROM CASE limit 1];
        EmailTemplate emptmp = [select Id from EmailTemplate limit 1];
        Test.startTest();
            EmailMessage em = new EmailMessage();
            em.ParentId = caseToBeProcessed.Id;
            em.Incoming = true;
            em.EmailTemplateId = emptmp.Id ;
            em.ToAddress = 'info@makersmark.com';
            em.Subject = 'Test Subject';
            insert em;
        Test.stopTest();
        List<Email_Template__c> emailRecord = [SELECT Id, Name, Used_Count__c from Email_Template__c where EmailTemplateId__c =: em.EmailTemplateId ];
        if(!emailRecord.isEmpty()){
            System.assertEquals(1,emailRecord[0].Used_Count__c);
        }
    }
    @isTest
    static void testUpdateBrandOnCaseRecord() {
        Case caseToBeProcessed = [SELECT Id,Status FROM CASE limit 1];
        List<EmailMessage> emailMessages = new List<EmailMessage>();
        EmailMessage em = new EmailMessage();
        em.ParentId = caseToBeProcessed.Id;
        em.ToAddress = 'thewhiskydrop@makersmark.com';
        em.Subject = 'Test Subject';
        emailMessages.add(em);
        insert emailMessages;
        
        Test.startTest();
        	EmailMessageServices.updateBrandOnCaseRecord(emailMessages);
        Test.stopTest();
        
        Case caseAfterProcessed = [SELECT Id, How_can_we_help__c FROM CASE limit 1];
        System.assertEquals(DTC_Constants.WHISKY_DROP, 
                            caseAfterProcessed.How_can_we_help__c, 'How_can_we_help__c Updated');
    }
}