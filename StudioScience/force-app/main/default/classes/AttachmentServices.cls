/**************************************************************************************
Apex Class Name     : AttachmentServices
Created Date        : 5/2021
Function            : Methods called from the AttachmentTriggerhandler handler
*************************************************************************************/
public class AttachmentServices {
    
    /**************************************************************************************************************
    Description:    Once a Single Barrel Case is created from email 'single.barrel@beamsuntory.com' and it has pdf
    or a non-pdf attachment then its Record type is updated to 'Orders'
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    5/2021      Shobhit Bhatnagar       Initial Creation
    ***************************************************************************************************************/
    public static void updateSingleBarrelCaseRecordTypeWithAttachment(Map<ID, Attachment> newMap){
        String ordersRTName = CSConstants.ORDERS;
        String singleBarrelInquiryRTName= CSConstants.SINGLE_BARREL_INQUIRY;
        Id ordersRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ordersRTName).getRecordTypeId();
        Id singleBarrelInquiryRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get(singleBarrelInquiryRTName).getRecordTypeId();
        
        List<Group>QueueIdrecs = [select Id from Group where Type = 'Queue' AND NAME IN ('Barrel Queue')];
        
        Set<ID> caseIds = new Set<ID>();
        List<ID> attachmentParentIds= new List<ID>();
        
        for( Attachment a : newMap.values() ) {  
            String parentId = String.valueof( a.parentid );
            // Check the parent ID - if it's 02s, this is for an email message 
            if(parentId.substring(0, 3) == '02s' && a.ContentType =='application/pdf') {
                attachmentParentIds.add(parentId);
            }  
        }
        if(!attachmentParentIds.isEmpty()) {
            for(EmailMessage messageItem : [select parentID from EmailMessage where id in: attachmentParentIds]){
                caseIds.add(messageItem.parentId);
                System.debug(LoggingLevel.INFO,' inside emailMessage and case id is: '+ messageItem.parentId);
            }
        }
        if(!caseIds.isEmpty()){
            Map<ID,Case> singleBarrelCaseMap = new Map<ID,Case>([select ID, RecordTypeId, BSI_Function__c, OwnerId, Type, Origin from Case where ID in: caseIds 
                                  AND RecordTypeId =:singleBarrelInquiryRecordTypeId AND IsClosed = false AND 
                                  (OwnerId IN:QueueIdrecs) AND BSI_Function__c = 'CS' AND Origin='Email']);
            System.debug(LoggingLevel.INFO,'singleBarrelCaseMap.size() *************' + singleBarrelCaseMap.size());
            
            List<Case> caseListWithAttachments= new List<Case>();
            for (Id caseId : singleBarrelCaseMap.keySet()) {  
                if(!caseIds.isEmpty() && singleBarrelCaseMap.containsKey(caseId)){
                    singleBarrelCaseMap.get(caseId).RecordTypeId= ordersRecordTypeId;
                    caseListWithAttachments.add(singleBarrelCaseMap.get(caseId));
                }
            }
            if(!caseListWithAttachments.isEmpty())
                update caseListWithAttachments;
        }
        
    }
}