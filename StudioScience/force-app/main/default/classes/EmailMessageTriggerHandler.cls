/**************************************************************************************
Apex Class Name     : EmailMessageTriggerHandler
Created Date        : 20-11-2021
Function            : Handles events from the EmailMessage Trigger
*************************************************************************************/
public class EmailMessageTriggerHandler {

    public static void handleAfterInsert(List<EmailMessage> emailMessages) { 
        List<EmailMessage> emailMessageDTCRecords = new List<EmailMessage>();
        for(EmailMessage emessage : emailMessages){
            if(emessage.ParentId != null &&
                emessage.ParentId.getSObjectType().getDescribe().getName() == DTC_Constants.CASE_OBJECT
                ) {
                emailMessageDTCRecords.add(emessage);
            }
        }
        Map<Id,EmailMessage> oldEmailMessages = new Map<Id,EmailMessage>();
        if(emailMessageDTCRecords.size() > 0){
            DTC_EmailMessageServices.updateCaseStatusToReopenWhenReply(emailMessageDTCRecords, 
                oldEmailMessages); 
        }
        EmailMessageServices.updateParentCaseToReopen(emailMessages);
        //Added for SCR-11
        EmailMessageServices.updateParentCaseFlags(emailMessages);
        EmailMessageServices.updateTimeToRespond(emailMessages);
        EmailMessageServices.updateBrandFamily(emailMessages);
        EmailMessageServices.countCounsumerInquiryEmailTemplates(emailMessages);
    }
    public static void handleBeforeInsert(List<EmailMessage> emailMessages) { 
        List<EmailMessage> newEmailMessages = new List<EmailMessage>();
        EmailMessageServices.createNewCaseFromClosed(emailMessages);
        EmailMessageServices.updateAgentConsumerResponses(emailMessages);
        for(EmailMessage emailMessage : emailMessages){
            if(emailMessage.ParentId != null 
               && emailMessage.ParentId.getSObjectType().getDescribe().getName() == DTC_Constants.CASE_OBJECT
               && (emailMessage.ToAddress == DTC_Constants.WHISKYDROP_MM 
                   || emailMessage.ToAddress == DTC_Constants.BARREDANDBOXED_BD)){
                   newEmailMessages.add(emailMessage);
            }
        }
        if(newEmailMessages.size() > 0){
            EmailMessageServices.updateBrandOnCaseRecord(newEmailMessages);
        }
    }
    public static void handleAfterUpdate(List<EmailMessage> emailMessages) { 
       // EmailMessageServices.updateTimeToRespond(emailMessages);
    }
    public static void handleBeforeUpdate(List<EmailMessage> emailMessages, Map<Id, EmailMessage> oldEmailMessages) {
    }
}