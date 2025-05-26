/**************************************************************************************
Apex Class Name     : DTC_EmailMessageServices
Created Date        : 3/2022
Function            : Methods called from the emailMessageTriggerHandler handlers
*************************************************************************************/
public class DTC_EmailMessageServices {
             /**************************************************************************************************************
Method name:    updateCaseStatusClosedWhenCaseCreatedBeforeBatchBilling
Object:         EmailMessage
Date:           3/2022       Nishant Khandal     Metacube  
Details and Notes:
Update Case status to Reopen and send Custom Notification
***************************************************************************************************************/
    public static void updateCaseStatusToReopenWhenReply(List<EmailMessage> emailMessages, 
                                                        Map<Id, EmailMessage> oldEmailMessages){
        List<Case> caseUpdates = new List<Case>();
        Set<Id> idsOfParentCases = new Set<Id>();
        for(EmailMessage emessage : emailMessages){
            if(emessage.Incoming == true && !DTC_Constants.COMPANY_MAIL_SET.contains(emessage.FromAddress)){
                idsOfParentCases.add(emessage.ParentId);
            }
        }
        if(idsOfParentCases.size() > 0 && !idsOfParentCases.isEmpty()){
            Map<Id, Case> mapCaseWithIDs = new Map<Id, Case>([SELECT RecordTypeId, OwnerId, CaseNumber, Status FROM Case WHERE 
                                                              (RecordTypeId =: DTC_Constants.CASE_DTC_RECORDTYPEID Or (RecordTypeId =: DTC_Constants.CASE_CONSUMER_INQ_RECORDTYPEID And 
                                                                                                                      How_can_we_help__c IN :DTC_Constants.WHISKY_DROP_BARRELED_AND_BOX_SET)) 
                                                           		 And Id IN :idsOfParentCases]); //modified on 1/12/22 by Vikash Kumar
            CustomNotificationType notificationType = SLT_DTC_CustomNotification.getCustomNotification
                (DTC_Constants.DTC_CUSTOM_NOTIFICATION);
            if(mapCaseWithIDs.keySet().size() > 0 && !mapCaseWithIDs.keySet().isEmpty()){
                for(EmailMessage emessage : emailMessages){
                    Set<String> addressee = new Set<String>();
                    if(notificationType != null){
                        String title = 'Case Number: '+mapCaseWithIDs.get(emessage.ParentId).CaseNumber+' '+emessage.Subject;
                        String body = DTC_Constants.NOTIFICATION_BODY+
                        mapCaseWithIDs.get(emessage.ParentId).CaseNumber;
                        addressee.add(mapCaseWithIDs.get(emessage.ParentId).OwnerId);
                        SRV_DTC_CustomNotification.sendCustomNotificatioToOwner(title, body, notificationType.Id, 
                        emessage.ParentId, addressee);
                    }
                    if(mapCaseWithIDs.get(emessage.ParentId).Status == DTC_Constants.CLOSED_STATUS){
                        Case caseUpdate = SRV_DTC_Case.updateCaseStatusToReopen(mapCaseWithIDs.get(emessage.ParentId));
                        caseUpdates.add(caseUpdate);
                    }
                }
                if(caseUpdates.size() > 0 && !caseUpdates.isEmpty()){
                    update caseUpdates;
                }
            }
        }
    }
}