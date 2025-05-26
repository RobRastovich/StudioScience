/************************************************************************************** 
 Apex Test Class Name     : AttachmentHandler
 Created Date             : 5/15/2016
 Function                 : Supplying test data for AttachmentHandler
*************************************************************************************/

@isTest
public class AttachmentHandlerTest{
    
    static testMethod void test() {
       
      Test.startTest();
       
      //Test data for case and attachment(attachment parent id is case id)  
      Case c = new Case();
      insert c;
     
      Attachment attach = new Attachment();
      attach.Name = 'Attachment';
      Blob bodyBlob=Blob.valueOf('Attachment Body');
      attach.parentId = c.id;
      attach.body=bodyBlob;
      insert attach;
        
      List<Attachment> attachments=[select id, name from Attachment where parent.id=:c.id];
      AttachmentHandler.AttachmentToFeed(attachments);
         
     
   Test.stopTest();
   
        
    }
    
    static testMethod void test1(){
      
      Test.startTest();
        
      //Test data for emailmessage and attachment(attachment parent id is emailmessage id)
      Case c1 = new Case();
      insert c1;
      
       
      EmailMessage msg = new EmailMessage(
            ToAddress = 'them.' + Datetime.now().format('yyyymmddhhmmss') + '@sforce.com',
            FromAddress = 'me.' + Datetime.now().format('yyyymmddhhmmss') + '@sforce.com',
            FromName = 'Thomas Train',
            TextBody = 'This is a test of the email attachment reassigner service',
            ParentId = c1.Id
            );
       
      insert msg;
        
      Attachment attach1 = new Attachment();
      attach1.Name = 'Attachmentnew';
      Blob bodyBlob1=Blob.valueOf('Attachment Bodynew');
      attach1.parentId = msg.Id;
      attach1.body=bodyBlob1;
      attach1.ContentType = 'application/pdf'; 
      insert attach1;
       
      System.debug('Attachment parent id is:::'+attach1.parentId);
      List<Attachment> attachmentss =[select id, name from Attachment where parent.id=:attach1.id];
      AttachmentHandler.AttachmentToFeed(attachmentss);
      
      Test.stopTest();
      //Delete Attachments to cover the deletion event
      Delete attachmentss;
    }
    
}