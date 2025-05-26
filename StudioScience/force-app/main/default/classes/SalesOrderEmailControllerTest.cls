@isTest
private class SalesOrderEmailControllerTest {

  private static @isTest void sendemail_with_no_attachment_test() {
    Account testAccount = new Account(Name = 'test');
    insert testAccount;

    gvp__Sales_Order__c order = new gvp__Sales_Order__c(
      gvp__Account__c = testAccount.Id,
      gvp__Order_Date__c = Date.Today()
    );
    insert order;

    SalesOrderEmailController controller = new SalesOrderEmailController();
    controller.order = order;
    System.AssertEquals(null, controller.attachmentId, 'No attachment found');
  }

  private static @isTest void sendemail_with_attachment_test() {
    Account testAccount = new Account(Name = 'test');
    insert testAccount;

    gvp__Sales_Order__c order = new gvp__Sales_Order__c(
      gvp__Account__c = testAccount.Id,
      gvp__Order_Date__c = Date.Today()
    );
    insert order;

    Attachment testAttachment = new Attachment(
      ParentId = order.Id,
      Name = 'test attachment',
      Body = Blob.valueOf('test body')
    );
    insert testAttachment;

    SalesOrderEmailController controller = new SalesOrderEmailController();
    controller.order = order;
    System.AssertEquals(testAttachment.Id, controller.attachmentId, 'No attachment found');
  }
}