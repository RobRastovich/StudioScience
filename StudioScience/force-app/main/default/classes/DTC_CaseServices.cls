/**************************************************************************************
Apex Class Name     : DTC_CaseServices
Created Date        : 2/2022
Function            : Methods called from the caseTriggerhandler handlers
*************************************************************************************/
public class DTC_CaseServices {
    public static Boolean runTrigger = true;
    public static Set<String> setStatusClose = new Set<String> {DTC_Constants.BRAIN_TREE_STATUS_WON, 
        DTC_Constants.BRAIN_TREE_STATUS_LOST};
    /**************************************************************************************************************
Method name:    checkStatusFlowOfCaseStatusDTC
Object:         Case
Date:           2/2022       Nishant Khandal     Metacube  
Details and Notes:
Check the status flow of the record wheather its correct or not and if it is not correct show an error message
***************************************************************************************************************/
    public static void checkStatusFlowOfCaseStatusDTC(List<Case> newCases, Map<Id, Case> oldMap){
        Map<Id, String> mapOfCaseIdWithNewStatusAndSubStatus = new Map<Id, String>();
        Map<Id, String> mapOfCaseIdWithOldStatusAndSubStatus = new Map<Id, String>();
        Map<Id, String> mapOfCurrentStatusWithNewStatus = new Map<Id, String>();
        Set<String> typesOfCase = new Set<String>();
        for(Case currCase : newCases){
            if((currCase.RecordTypeId == DTC_Constants.CASE_DTC_RECORDTYPEID && 
                ((oldMap.get(currCase.Id).Status != currCase.Status) || 
                (oldMap.get(currCase.Id).Sub_Status__c != currCase.Sub_Status__c))) &&
                currCase.OwnerId == oldMap.get(currCase.Id).OwnerId) {
                typesOfCase.add(currCase.AdditionalInformation__c);
                if(!mapOfCaseIdWithNewStatusAndSubStatus.containsKey(currCase.id)){
                    if(String.isNotBlank(currCase.Sub_Status__c)){
                        mapOfCaseIdWithNewStatusAndSubStatus.put(currCase.id, currCase.Status+'-'+currCase.Sub_Status__c);
                    }
                    else{
                        mapOfCaseIdWithNewStatusAndSubStatus.put(currCase.id, currCase.Status);
                    }
                }
                if(!mapOfCaseIdWithOldStatusAndSubStatus.containsKey(currCase.id)){
                    if(oldMap.get(currCase.Id).Sub_Status__c != null){
                        mapOfCaseIdWithOldStatusAndSubStatus.put(currCase.id, oldMap.get(currCase.Id).Status
                        +'-'+oldMap.get(currCase.Id).Sub_Status__c);
                    }
                    else{
                        mapOfCaseIdWithOldStatusAndSubStatus.put(currCase.id, oldMap.get(currCase.Id).Status);
                    }
                }
            }    
        } 
        if(!mapOfCaseIdWithNewStatusAndSubStatus.keySet().isEmpty() && !mapOfCaseIdWithOldStatusAndSubStatus.keySet().isEmpty()){
            List<DTC_Status_Flow__mdt> statusFlowsDTC = SLT_DTC_CustomMetadata.getCaseStatusFlowDTC(typesOfCase);
            if(!statusFlowsDTC.isEmpty()){
                for(Case currCase : newCases){
                    Set<String> setOfNewStatus = new Set<String>();
                    if(currCase.AdditionalInformation__c != null){
                        for(DTC_Status_Flow__mdt statusFlow : statusFlowsDTC){
                            if(currCase.AdditionalInformation__c == statusFlow.Type__c){
                                if(mapOfCaseIdWithOldStatusAndSubStatus.get(currCase.Id) == statusFlow.Current_Stage__c){
                                    setOfNewStatus.add(statusFlow.Next_Stage__c);
                                }
                            }
                        }
                        if(!setOfNewStatus.contains(mapOfCaseIdWithNewStatusAndSubStatus.get(currCase.Id))){
                            currCase.addError(DTC_Constants.INCORRECT_STATUS_MESSAGE);
                        }
                    }
                }
            }
        }
    }
    /**************************************************************************************************************
Method name:    updateCaseStatusClosed
Object:         Case
Date:           2/2022       Nishant Khandal     Metacube  
Details and Notes:
Update Case status to closed when Avatax, Braintree, SAP status are closed
***************************************************************************************************************/
    public static void updateCaseStatusClosed(List<Case> newCases, Map<Id, Case> oldMap){
        for(Case currCase : newCases){
            if(oldMap.get(currCase.Id).Avatax_Status__c != currCase.Avatax_Status__c ||
               oldMap.get(currCase.Id).Braintree_Status__c != currCase.Braintree_Status__c ||
               oldMap.get(currCase.Id).SAP_Status__c != currCase.SAP_Status__c) {
                if((currCase.Avatax_Status__c == DTC_Constants.AVATAX_COMMITED && currCase.Tax_Amount__c < 0 && 
                    currCase.Tax_Amount__c != null) && 
                    currCase.Braintree_Status__c == DTC_Constants.BRAINTREE_SETTLED && 
                    currCase.SAP_Status__c == DTC_Constants.SAP_RETURN_ORDER && 
                    currCase.Status == DTC_Constants.REFUND_STATUS && 
                    currCase.Sub_Status__c == DTC_Constants.INITIATED_SUB_STATUS &&
                    ((currCase.How_can_we_help__c == DTC_Constants.API && 
                    currCase.AdditionalInformation__c == DTC_Constants.MEMBERSHIP_CANCELLATION) ||
                    (currCase.How_can_we_help__c == DTC_Constants.COMMUNITY_CONSOLE && 
                    currCase.AdditionalInformation__c == DTC_Constants.RETURN_AND_CREDIT))){
                        currCase.Status =  DTC_Constants.CLOSED_STATUS;
                        currCase.Sub_Status__c =  '';
                }
            }
            else if (oldMap.get(currCase.Id).UPS_Tracking_Number__c != currCase.UPS_Tracking_Number__c){
                         if(currCase.Sub_Status__c == DTC_Constants.RESHIP_CONFIRMED || currCase.Sub_Status__c == DTC_Constants.RESHIPMENT_INITIATED){
                             DTC_MagentoHTTP_Util.getorderIdByIncId(currCase.OrderID__C, currCase.UPS_Tracking_Number__c);
                             currCase.Status =  DTC_Constants.CLOSED_STATUS;
                             currCase.Sub_Status__c =  '';  
                         }
                     }
        }
    }

    /**************************************************************************************************************
Method name:    updateCaseStatusCommunicateWithDHL
Object:         Case
Date:           2/2022       Nishant Khandal     Metacube  
Details and Notes:
Update Case status to Communicate with DHl and Change Owner 
***************************************************************************************************************/
public static void updateCaseStatusCommunicateWithDHL(List<Case> newCases, Map<Id, Case> oldMap){
    for(Case currCase : newCases){
        if(currCase.Sub_Status__c != oldMap.get(currCase.Id).Sub_Status__c && 
            currCase.Sub_Status__c == DTC_Constants.CANCEL_SHIPMENT && 
            currCase.Status == DTC_Constants.IN_PROGRESS && currCase.How_can_we_help__c == DTC_Constants.API &&
            currCase.AdditionalInformation__c == DTC_Constants.MEMBERSHIP_CANCELLATION ){
            currCase.Sub_Status__c = DTC_Constants.COMMUNICATE_WITH_DHL;
       }
    }
}
    
    /**************************************************************************************************************
    Method name:    updateCaseStatusShipmentAtWarehouse
Object:         Case
Date:           3/2022       Nishant Khandal     Metacube  
Details and Notes:
Update Case status to Shipped At Warehouse 
***************************************************************************************************************/
    public static void updateCaseStatusShipmentAtWarehouse(List<Case> newCases, Map<Id, Case> oldMap){
        Group jimBeamgroupDetail = SLT_DTC_Group.getQueueByDeveloperName(DTC_Constants.BARRELED_BOXED_MEMBERSHIP_PROGRAMM);
        Group makersMarkgroupDetail = SLT_DTC_Group.getQueueByDeveloperName(DTC_Constants.DIRECT_TO_CUSTOMER);
        CustomNotificationType notificationType = 
          SLT_DTC_CustomNotification.getCustomNotification(DTC_Constants.DTC_CUSTOM_NOTIFICATION);
        for(Case currCase : newCases){
            Set<String> addressee = new Set<String>();
            if(currCase.DHL_Status__c != oldMap.get(currCase.Id).DHL_Status__c && 
               currCase.How_can_we_help__c == DTC_Constants.API &&
               currCase.AdditionalInformation__c == DTC_Constants.MEMBERSHIP_CANCELLATION && 
               currCase.Status == DTC_Constants.IN_PROGRESS && 
               currCase.SUb_Status__c == DTC_Constants.COMMUNICATE_WITH_DHL &&
               (currCase.DHL_Status__c != null && currCase.DHL_Status__c != '') &&
               (currCase.DHL_Status__c == DTC_Constants.RETURN_TO_WAREHOUSE_UNSUCCESSFULL_DELIVERY || 
                currCase.DHL_Status__c == DTC_Constants.RETURN_TO_WAREHOUSE_DAMAGE ||
                currCase.DHL_Status__c == DTC_Constants.RETURN_TO_WAREHOUSE_LOST ||
                currCase.DHL_Status__c == DTC_Constants.DHL_STATUS_NOT_YET_SHIPPED)){
                    currCase.Status =  DTC_Constants.IN_PROGRESS;
                    currCase.Sub_Status__c =  DTC_Constants.SHIPPED_AT_WAREHOUSE;
                }
            else if(currCase.DHL_Status__c != oldMap.get(currCase.Id).DHL_Status__c && 
                    currCase.How_can_we_help__c == DTC_Constants.API &&
                    currCase.AdditionalInformation__c == DTC_Constants.MEMBERSHIP_CANCELLATION && 
                    currCase.Status == DTC_Constants.IN_PROGRESS && 
                    currCase.SUb_Status__c == DTC_Constants.COMMUNICATE_WITH_DHL &&
                    (currCase.DHL_Status__c == null || currCase.DHL_Status__c == '')){
                        currCase.adderror(DTC_Constants.DHL_STATUS_CANNOTBENULL); 
            }
        }
    }
    
    public static void checkDuplicateOrderId(List<Case> newCases, Map<Id, Case> oldMap){
        Set<String> orderIds = new Set<String>();
        Set<String> recordTypeIds = new Set<String>{DTC_Constants.CASE_DTC_RECORDTYPEID};
        Integer casesCount = 0;
        Map<String,Case> orderIdToCaseMap;
        for(Case currCase : newCases){
            if (oldMap == null || (oldMap != null 
                && currCase.OrderId__c != oldMap.get(currCase.id).OrderId__c)) {
                    orderIds.add(currCase.OrderId__c);    
            }
        }
        if (!orderIds.isEmpty()) {
            orderIdToCaseMap = SLT_DTC_Case.getMapOfCasesToOrderID(orderIds, recordTypeIds);
            if (orderIdToCaseMap != null && !orderIdToCaseMap.isEmpty()) {
                for(Case currCase : newCases){
                    if (orderIdToCaseMap.containsKey(currCase.OrderID__c) ) {
                        currCase.adderror('Duplicate OrderId. '+currCase.OrderID__c+' already exists.!'); 
                    }
                }
            }
        }
    }
    
    /**************************************************************************************************************
    Method name:    updateCaseAdditionalInformation
Object:         Case
Date:           3/2022       Nishant Khandal     Metacube  
Details and Notes:
Update Case Additional Information 
***************************************************************************************************************/
    public static void updateCaseAdditionalInformation(List<Case> newCases, Map<Id, Case> oldMap){
        for(Case currCase : newCases){
            if((currCase.Status != oldMap.get(currCase.Id).Status || 
            currCase.Sub_Status__c != oldMap.get(currCase.Id).Sub_Status__c) 
               && currCase.How_can_we_help__c == DTC_Constants.COMMUNITY_CONSOLE && 
               currCase.AdditionalInformation__c == DTC_Constants.RETURN_ADDINFORMATION){
                if(currCase.Status == DTC_Constants.IN_PROGRESS && 
                (currCase.Sub_Status__c == DTC_Constants.RESHIP_CONFIRMED || 
                currCase.Sub_Status__c == DTC_Constants.RESHIPMENT_INITIATED)){
                    currCase.AdditionalInformation__c = DTC_Constants.RETURN_AND_RESHIP; 
                }else if(currCase.Status == DTC_Constants.REFUND_STATUS && 
                currCase.Sub_Status__c == DTC_Constants.INITIATED_SUB_STATUS){
                    currCase.AdditionalInformation__c = DTC_Constants.RETURN_AND_CREDIT;
                }else if(currCase.Status == DTC_Constants.IN_PROGRESS && 
                currCase.Sub_Status__c == DTC_Constants.SUB_STATUS_CONFIRMATION_EMAIL_SENT){
                    currCase.Aging_Complete_On__c = DTC_Utilities.AddBusinessDays(Date.valueOf(currCase.CreatedDate), 3);
                    currCase.Availability_Date__c = DTC_Utilities.AddBusinessDays(Date.valueOf(currCase.CreatedDate), 5);                   
                }else if(currCase.Status == DTC_Constants.IN_PROGRESS && 
                    currCase.Sub_Status__c == DTC_Constants.REPLACEMENT_CONFIRMED_SUB_STATUS){
                    currCase.AdditionalInformation__c = DTC_Constants.REPLACEMENT;
                }
            }
        }
    }

    public static void checkDuplicateOpenReplacementCases(List<Case> newCases, Map<Id, Case> oldMap){
        Set<String> emailIds = new Set<String>();
        Set<String> recordTypeIds = new Set<String>{DTC_Constants.CASE_DTC_RECORDTYPEID};
        Integer casesCount = 0;
        Map<String,Case> emailIdToCaseMap;
        for(Case currCase : newCases){
            if (currCase.AdditionalInformation__c == DTC_Constants.REPLACEMENT
                && currCase.Status != DTC_Constants.CLOSED_STATUS
                && (oldMap == null || (oldMap != null 
                && currCase.Email_Address__c != oldMap.get(currCase.id).Email_Address__c))) {
                    emailIds.add(currCase.Email_Address__c);   
            }
        }
        if (!emailIds.isEmpty()) {
            emailIdToCaseMap = SLT_DTC_Case.getMapOfCasesToEmailID(emailIds, recordTypeIds);
            if (emailIdToCaseMap != null && !emailIdToCaseMap.isEmpty()) {
                Integer countJimBeamCases = 0;
                Integer countMakersMarkCases = 0;
                for(Case currCase : newCases){
                    if (emailIdToCaseMap.containsKey(currCase.Email_Address__c) ) {
                        if (emailIdToCaseMap.get(currCase.Email_Address__c).Brand__c == DTC_Constants.BRAND_JIM_BEAM) {
                            countJimBeamCases = countJimBeamCases + 1;
                        }
                        if (emailIdToCaseMap.get(currCase.Email_Address__c).Brand__c == DTC_Constants.BRAND_MAKERS_MARK_APPOS) {
                            countMakersMarkCases = countMakersMarkCases + 1;
                        }
                    }
                    if ((countJimBeamCases > 1 || countMakersMarkCases > 1)
                        || (countJimBeamCases == 1 && countMakersMarkCases == 1 
                        && (currCase.Brand__c == DTC_Constants.BRAND_JIM_BEAM 
                        || currCase.Brand__c == DTC_Constants.BRAND_MAKERS_MARK_APPOS) )) {
                        currCase.adderror('One case is already in open state for Email('+
                            currCase.Email_Address__c +') for replacement.'); 
                    }
                }
            }
        }
    }

    public static void updateCaseOwnerOnTheBasisOFBrand(List<Case> newCases, Map<Id, Case> oldMap){
        Group groupDetailMakersMark = SLT_DTC_Group.getQueueByDeveloperName(DTC_Constants.DIRECT_TO_CUSTOMER);
        Group groupDetailBarrelled = SLT_DTC_Group.getQueueByDeveloperName(DTC_Constants.QUEUE_BARRELED_BOXED); 
        Group groupDetailMMSpecialityBottleOrders = SLT_DTC_Group.getQueueByDeveloperName(DTC_Constants.QUEUE_MAKER_S_MARK_LIMITED_ONLINE_RELEASES);
        for(Case currCase : newCases){
            if(oldMap == null || (oldMap != null && currCase.Brand__c != oldMap.get(currCase.Id).Brand__c)){
                if(String.isNotBlank(currCase.Brand__c) && currCase.Brand__c == System.label.Makers_Mark_DTC 
                    && groupDetailMakersMark != null){
                        if(currCase.How_can_we_help__c == DTC_Constants.LIMITED_ONLINE_RELEASES){
                            currCase.OwnerID = groupDetailMMSpecialityBottleOrders.Id;
                        }else{
                            currCase.OwnerID = groupDetailMakersMark.Id;
                        }
                }
                if(String.isNotBlank(currCase.Brand__c) && currCase.Brand__c == System.label.Jim_Beam_Brand 
                    && groupDetailBarrelled != null){
                    currCase.OwnerID = groupDetailBarrelled.Id;
                }
            }
        }
    }

    public static void updateNextNotificationDate(List<Case> newCases, Map<Id, Case> oldMap){
        Date todaysDate = System.today();
        Map<Id, Integer> newCasesEmailCountMap = emailCountMap(newCases);
        for(Case currCase : newCases){
            if(currCase.Sub_Status__c != oldMap.get(currCase.Id).Sub_Status__c
                && currCase.AdditionalInformation__c == DTC_Constants.ADD_INFO_DISPUTE
                && currCase.Braintree_Status__c == DTC_Constants.OPEN_STATUS){
                if(currCase.Status == DTC_Constants.IN_PROGRESS
                    && currCase.Sub_Status__c == DTC_Constants.SUB_STATUS_CONFIRMATION_EMAIL_SENT) {
                        currCase.Next_Notification_Date__c = todaysDate.addDays(DTC_Constants.FIVE_DAYS);
                } else if(oldMap != null      
                    && oldMap.get(currCase.Id).Status == DTC_Constants.IN_PROGRESS
                    && oldMap.get(currCase.Id).Sub_Status__c == DTC_Constants.SUB_STATUS_INVALID
                    && currCase.Status == DTC_Constants.IN_PROGRESS
                    && currCase.Sub_Status__c == DTC_Constants.SUB_STATUS_BRAINTREE_RESPONSE) {
                        currCase.Next_Notification_Date__c = todaysDate.addDays(DTC_Constants.TEN_DAYS);
                } else if (currCase.Status == DTC_Constants.IN_PROGRESS
                    && currCase.Sub_Status__c == DTC_Constants.SUB_STATUS_FOLLOWUP_EMAIL_SENT) {
                    if(newCasesEmailCountMap.keySet().contains(currCase.Id)){
                        currCase.ConsumerResponseOnCase__c = newCasesEmailCountMap.get(currCase.Id);
                    } else {
                        currCase.ConsumerResponseOnCase__c = 0;
                    }
                    currCase.Next_Notification_Date__c = todaysDate.addDays(DTC_Constants.FIVE_DAYS);
                } else {
                    currCase.Next_Notification_Date__c = null;
                }
           }
        }
    }

    public static void sendBellNotification(List<Case> newCases, Map<Id, Case> oldMap){
        Set<Case> setOfCases = new Set<Case>();
        for(Case currCase : newCases){
            if (currCase.AdditionalInformation__c == DTC_Constants.ADD_INFO_DISPUTE
                && currCase.Status == DTC_Constants.IN_PROGRESS
                && (currCase.Sub_Status__c == DTC_Constants.SUB_STATUS_CONFIRMATION_EMAIL_SENT
                || currCase.Sub_Status__c == DTC_Constants.SUB_STATUS_BRAINTREE_RESPONSE)
                && currCase.Send_Bell_Notification__c == true
                && currCase.Braintree_Status__c == DTC_Constants.OPEN_STATUS) {
                    setOfCases.add(currCase);
            }
        }
        if (!setOfCases.isEmpty()) {
            CustomNotificationType notificationType = SLT_DTC_CustomNotification.getCustomNotification(
                DTC_Constants.DTC_CUSTOM_NOTIFICATION);
            Set<String> addressee = new Set<String>();
            if(notificationType != null){
                for(Case currCase : setOfCases){
                    String title = 'Case Number: '+currCase.CaseNumber;
                    String body;
                    if (currCase.Sub_Status__c == DTC_Constants.SUB_STATUS_CONFIRMATION_EMAIL_SENT) {
                        body = DTC_Constants.PLEASE_REVISIT+currCase.CaseNumber;
                    } else {
                        body = DTC_Constants.PLEASE_REVISIT_BRAINTREE+currCase.CaseNumber;
                    }
                    addressee.add(currCase.OwnerId);
                    SRV_DTC_CustomNotification.sendCustomNotificatioToOwner(title, body, notificationType.Id, 
                    currCase.Id, addressee);
                    currCase.Send_Bell_Notification__c = false;
                }
            }
        }       
    }
    
    public static void updateStatusAndSubStatus(List<Case> newCases, Map<Id, Case> oldMap){
        for(Case recordCase: newCases){
            if(recordCase.AdditionalInformation__c == DTC_Constants.ADD_INFO_DISPUTE 
               && recordCase.Braintree_Status__c != oldMap.get(recordCase.Id).Braintree_Status__c 
               && !setStatusClose.contains(oldMap.get(recordCase.Id).Braintree_Status__c)
               && setStatusClose.contains(recordCase.Braintree_Status__c)){
                   recordCase.Status = DTC_Constants.CLOSED_STATUS;
                   recordCase.Sub_Status__c = DTC_Constants.SUB_STATUS_SETTLED;
        	}
        }
    }
    
    public static void validationOnCaseStatusIsClose(List<Case> newCases, Map<Id, Case> oldMap){
        for(Case recordCase: newCases){
            if(recordCase.AdditionalInformation__c == DTC_Constants.ADD_INFO_DISPUTE 
                && recordCase.Status != oldMap.get(recordCase.Id).Status 
                && !setStatusClose.contains(recordCase.Braintree_Status__c)
                && recordCase.Status == DTC_Constants.CLOSED_STATUS){
                       recordCase.addError(DTC_Constants.CASE_CLOSED_ERROR);
            }
        }
    }

    public static void updateValidCaseList(List<Case> allCases) {
        Map<Id, Integer> newCasesEmailCountMap = emailCountMap(allCases);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(Case currCase: allCases) {
            if(currCase.Send_Bell_Notification__c == true && currCase.Status == DTC_Constants.IN_PROGRESS
                && currCase.Sub_Status__c == DTC_Constants.SUB_STATUS_FOLLOWUP_EMAIL_SENT
                && (currCase.ConsumerResponseOnCase__c == newCasesEmailCountMap.get(currCase.Id)
                || newCasesEmailCountMap.get(currCase.Id) == null)) {
                    currCase.Sub_Status__c = DTC_Constants.SUB_STATUS_BRAINTREE_RESPONSE;
                    List<String> toAddresses = DTC_Utilities.fetchGBSEmails();
                    Messaging.SingleEmailMessage mail = DTC_Utilities.createSingleEmailMessage(DTC_Constants.DTC_ET_DISPUTEVALID,
                        DTC_Constants.DTC_EMAIL_BEAMSUNTORY, toAddresses, currCase.Id);
                    mails.add(mail);
            }
        }
        if(mails.size() > 0) {
            DTC_Utilities.sendEmail(mails);
        }     
    }

    public static Map<Id, Integer> emailCountMap(List<Case> newCases) {
        Map<Id, Integer> newCasesEmailCountMap = new Map<Id, Integer>();
        List<EmailMessage> newCasesEmailList = SLT_DTC_Email.getEmailList(newCases);
        for(EmailMessage emailMsg: newCasesEmailList) {
            if(newCasesEmailCountMap.keySet().contains(emailMsg.ParentId)) {
                newCasesEmailCountMap.put(emailMsg.ParentId, newCasesEmailCountMap.get(emailMsg.ParentId) + 1);
            } else {
                newCasesEmailCountMap.put(emailMsg.ParentId, 1);
           }
        }
        return newCasesEmailCountMap;
    }

    public static void sendBellNotificationOnDHLStatusUpdate(Set<Case> setOfCases) {
        if (!setOfCases.isEmpty()) {
            CustomNotificationType notificationType = SLT_DTC_CustomNotification.getCustomNotification(
                DTC_Constants.DTC_CUSTOM_NOTIFICATION);
            Set<String> addressee = new Set<String>();
            if(notificationType != null){
                for(Case currCase : setOfCases){
                    String title = 'Case Number: '+currCase.CaseNumber;
                    String body = 'DHL team has updated status on '+currCase.CaseNumber+ ' Please review';
                    addressee.add(currCase.OwnerId);
                    SRV_DTC_CustomNotification.sendCustomNotificatioToOwner(title, body, notificationType.Id, 
                    currCase.Id, addressee);
                }
            }
        }
    }

    public static void updateSubStatusToBlank(List<Case> newCases, Map<Id, Case> oldMap){
        for(Case recordCase: newCases){
            if(recordCase.AdditionalInformation__c != DTC_Constants.ADD_INFO_DISPUTE 
               && recordCase.Status != oldMap.get(recordCase.Id).Status 
               && recordCase.Status == DTC_Constants.CLOSED_STATUS){
                   recordCase.Sub_Status__c = '';
        	}
        }
    }

    public static void sendBellNotificationPhysicalReturnDHL(List<Case> newCases){
        Set<Case> setOfCases = new Set<Case>();
        for(Case currCase : newCases){
            if (currCase.AdditionalInformation__c == DTC_Constants.RETURN_ADDINFORMATION
                && currCase.Status == DTC_Constants.IN_PROGRESS
                && currCase.Sub_Status__c == DTC_Constants.SUB_STATUS_CONFIRMATION_EMAIL_SENT
                && currCase.Send_Bell_Notification__c == true
                && currCase.Availability_Date__c == Date.today()) {
                    setOfCases.add(currCase);
            }
        }
        if (!setOfCases.isEmpty()) {
            CustomNotificationType notificationType = SLT_DTC_CustomNotification.getCustomNotification(
                DTC_Constants.DTC_CUSTOM_NOTIFICATION);
            Set<String> addressee = new Set<String>();
            if(notificationType != null){
                for(Case currCase : setOfCases){
                    String title = DTC_Constants.UPDATE_REQD_ON_CASE_NO+currCase.CaseNumber;
                    String body = DTC_Constants.NO_UPDATE_FROM_CUSTOMER+currCase.CaseNumber
                        + DTC_Constants.PLEASE_MARK_AS_REFUND_INITIATED;
                    addressee.add(currCase.OwnerId);
                    SRV_DTC_CustomNotification.sendCustomNotificatioToOwner(title, body, notificationType.Id, 
                    currCase.Id, addressee);
                    currCase.Send_Bell_Notification__c = false;
                }
            }
        }       
    }

    public static void updateRetailAccount(List<Case> newCases) {
        List<Account> accounts = SLT_DTC_Account.getAccountByName(DTC_Constants.DTC_DHL_ACCOUNT);
        for(Case recordCase: newCases){
            if(recordCase.Retail_Account__c == null && accounts != null && accounts.size()>0) {
                recordCase.Retail_Account__c = accounts[0].Id;
            }
        }
    }
}