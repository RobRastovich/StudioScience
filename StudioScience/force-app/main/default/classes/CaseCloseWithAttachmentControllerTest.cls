@isTest(SeeAllData = false)
public class CaseCloseWithAttachmentControllerTest {
    
    public static testMethod void saveCase(){
        Id caseRecordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HR').getRecordTypeId();
        Case objCase = new Case();
        objCase.RecordTypeId = caseRecordTypeId;
        objCase.Type = 'Human Resources';
        objCase.Category_1__c = 'Benefits';
        objCase.Category_2__c = 'Relocation';
        objCase.Submitter__c = UserInfo.getUserId();
        objCase.OwnerId = UserInfo.getUserId();
        insert objCase;
        Blob b = Blob.valueOf('Test Data');
        Attachment objAttachment = new Attachment();
        objAttachment.ParentId = objCase.Id;
        objAttachment.Name = objCase.CaseNumber+' - '+ 'Test Attachment for Parent';
        objAttachment.Body = b;
        insert objAttachment;
        System.debug('---Case Details---'+objCase);
        ApexPages.currentPage().getParameters().put('Id',objCase.id);
        CaseCloseWithAttachmentController objCaseCloseWithAttachmentController = new CaseCloseWithAttachmentController(new ApexPages.StandardController(new Case()));
        test.startTest();
        objCaseCloseWithAttachmentController.SaveAttachments();
        objCaseCloseWithAttachmentController.getStatusValue();
        objCaseCloseWithAttachmentController.doSave();
        objCaseCloseWithAttachmentController.doCancel();
        objCaseCloseWithAttachmentController.ChangeCount();
        test.stopTest();
    }
    
    public static testmethod void testSendEmailLogisticRequest(){
       //Id changesRecordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Changes').getRecordTypeId();
       //Id logisticsRequestRecordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Logistics request').getRecordTypeId(); 
       Case objChangesCase = new Case(Type = 'Customer Change', Status = 'New', OwnerId = UserInfo.getUserId()); 
       insert objChangesCase;
       objChangesCase.OwnerId = UserInfo.getUserId();
       update objChangesCase;
       System.debug('---Changes Case---'+objChangesCase.Id); 
       Case objLogisticRequestCase = new Case(ParentId = objChangesCase.Id, Status = 'New', OwnerId = UserInfo.getUserId());
       insert objLogisticRequestCase;
       System.debug('---Logistics Request---'+objLogisticRequestCase.Id); 
       objLogisticRequestCase.Status = 'Closed - Approved';
       update objLogisticRequestCase;
       List<Id> lst_Id = new List<Id>(); 
       lst_Id.add(objLogisticRequestCase.Id); 
       test.startTest();
       CaseCloseWithAttachmentController.sendEmailLogistics(lst_Id);
       test.stopTest();
    }
    public static testmethod void testSendEmailLogisticRequest2(){
        Case objLogisticRequestCase = new Case(Status = 'New', OwnerId = UserInfo.getUserId());
        insert objLogisticRequestCase;
        objLogisticRequestCase.Status = 'Closed - Approved';
        update objLogisticRequestCase;
        List<Id> lst_Id = new List<Id>(); 
        lst_Id.add(objLogisticRequestCase.Id);
        test.startTest();
        CaseCloseWithAttachmentController.sendEmailLogistics(lst_Id);
        test.stopTest(); 
    }
}