global class SalesOrderEmailController {
  public gvp__Sales_Order__c order { get; set; }
  public Id attachmentId { 
    get {
      return getAttachmentId();
    }
  }

  private Id getAttachmentId() {
    if (order == null) {
      return null;
    }
    List<Attachment> attachments = [SELECT Id FROM Attachment WHERE ParentId = :order.Id LIMIT 1];
    if (attachments.isEmpty()) {
      return null;
    }
    return attachments[0].Id;
  }
}