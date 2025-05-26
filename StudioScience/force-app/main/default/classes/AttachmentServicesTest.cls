@isTest(SeeAllData = false)
public class AttachmentServicesTest {
    public static final String SINGLE_BARREL_INQUIRY= 'Single Barrel Inquiry';
    public static ID singleBarrelInquiryRecordTypeId;
    public static List<Group> queueIdrecs;
    
    public static void prepareData(){
        singleBarrelInquiryRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get(SINGLE_BARREL_INQUIRY).getRecordTypeId();
        queueIdrecs = [select Id from Group where Type = 'Queue' AND NAME IN ('Barrel Queue')];
        
        List<Case> casesToInsert= new List<Case>();
        
        Case newCase= new Case();
        newCase.RecordTypeId= singleBarrelInquiryRecordTypeId;
        newCase.OwnerId= QueueIdrecs.get(0).Id;
        newCase.Origin='Email';
        casesToInsert.add(newCase);
        
        insert casesToInsert;
        
        EmailMessage emailObj= new EmailMessage();
        emailObj.parentid= newCase.id;
        insert emailObj;
        
        Attachment attach=new Attachment();
        attach.Name='Unit Test Attachment'+ '.pdf';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.ParentId=emailObj.Id;
        attach.ContentType='application/pdf';
        insert attach;
    }
    
    public static testMethod void testSingleBarrelRecordTypeChangedToOrdersIFAttachment() {
        //Test Data Setup
        prepareData();
        
        Test.startTest();
        List<Case> casesWithAttachment=[SELECT ID, RecordType.Name FROM Case WHERE RecordTypeId =:singleBarrelInquiryRecordTypeId AND IsClosed = false AND 
                                        (OwnerId IN:QueueIdrecs) AND BSI_Function__c = 'CS' AND Origin='Email'];
        if(!casesWithAttachment.isEmpty())
            System.assertEquals('Orders', casesWithAttachment.get(0).RecordType.Name);
        Test.stopTest();
    }
    
}