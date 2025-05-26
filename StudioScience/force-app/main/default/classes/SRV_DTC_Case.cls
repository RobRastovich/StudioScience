public class SRV_DTC_Case {

    public static Case caseCreation(Case caseDetails, String typeOfCase, Account accountDetails, String isShipmentRequired) {
        Group groupDetail;
        List<Account> accounts = SLT_DTC_Account.getAccountByName(DTC_Constants.DTC_DHL_ACCOUNT);
        case newCase  = new Case();
        Case createdCase;
        newCase.Origin = DTC_Constants.CASE_ORIGIN_MAGENTO;
        newCase.RecordTypeId = DTC_Constants.CASE_DTC_RECORDTYPEID;
        newCase.Email_Address__c = caseDetails.Email_Address__c;
        newCase.First_name__c = caseDetails.First_name__c;
        newCase.Last_name__c = caseDetails.Last_name__c;
        newCase.Cancelation_Reason__c = caseDetails.Cancelation_Reason__c;
        newCase.Notes__c = caseDetails.Notes__c;
        newCase.Brand__c = caseDetails.Brand__c;
        if (newCase.Brand__c == DTC_Constants.BRAND_MAKERS_MARK_APPOS) {
            groupDetail = SLT_DTC_Group.getQueueByDeveloperName(DTC_Constants.QUEUE_DTC);
            newCase.Automated_Notification_Email__c = DTC_Constants.EMAIL_WHISKY_DROP;
        } else {
            groupDetail = SLT_DTC_Group.getQueueByDeveloperName(DTC_Constants.QUEUE_BARRELED_BOXED);
            newCase.Automated_Notification_Email__c = DTC_Constants.EMAIL_BARRELED_AND_BOXED;
        }
        if (groupDetail != null) {
            newCase.OwnerID = groupDetail.Id;  
        }
        newCase.OrderID__c = caseDetails.OrderID__c;
        newCase.ProductID__c = caseDetails.ProductID__c;
        newCase.Batch_Billing__c = date.valueOf(caseDetails.Batch_Billing__c);
        newCase.How_can_we_help__c = DTC_Constants.API;
        newCase.AdditionalInformation__c = String.isNotBlank(typeOfCase) ? typeOfCase : DTC_Constants.MEMBERSHIP_CANCELLATION;
        newCase.ContactId = caseDetails.ContactId;
        newCase.AccountId = caseDetails.AccountId;
        newCase.Program_Subscription__c = caseDetails.Program_Subscription__c;
        newCase.Automated_Notification_Email__c = System.Label.DTC_EmailToCaseEmail;
        newCase.Cancel_Confirmed__c = caseDetails.Cancel_Confirmed__c;
        newCase.Shipment_Required__c = caseDetails.Shipment_Required__c;
        if (newCase.AdditionalInformation__c == DTC_Constants.MEMBERSHIP_CANCELLATION) {
            if (newCase.Cancel_Confirmed__c == false && (newCase.Shipment_Required__c == null || isShipmentRequired == null)) {
                newCase.status = DTC_Constants.IN_PROGRESS;
                newCase.Sub_status__c = DTC_Constants.SUB_STATUS_CONFIRMATION_EMAIL_SENT;
            } else if (newCase.Cancel_Confirmed__c == false && (newCase.Shipment_Required__c == false && 
                isShipmentRequired.containsIgnoreCase('false'))) {
                newCase.status = DTC_Constants.IN_PROGRESS;
                newCase.Sub_status__c = DTC_Constants.COMMUNICATE_WITH_DHL;
            } else if (newCase.Cancel_Confirmed__c == false && newCase.Shipment_Required__c == true) {
                newCase.status = DTC_Constants.IN_PROGRESS;
                newCase.Sub_status__c = DTC_Constants.SUB_STATUS_DO_NOT_CANCEL_SHIPMENT;
            } else if (newCase.Cancel_Confirmed__c == true) {
                newCase.status = DTC_Constants.CLOSED_STATUS;
                newCase.Sub_status__c = '';
            }
        } else if(newCase.AdditionalInformation__c == DTC_Constants.ADD_INFO_DISPUTE){
            newCase.status = DTC_Constants.NEW_STATUS;
            newCase.Braintree_Status__c = DTC_Constants.OPEN_STATUS;
        } else {
            newCase.status = DTC_Constants.IN_PROGRESS;
            newCase.Sub_status__c = DTC_Constants.SUB_STATUS_CONFIRMATION_EMAIL_SENT;
        }
        if (String.isNotBlank(accountDetails.PersonMailingCountry)) {
            newCase.Consumer_Country__c = accountDetails.PersonMailingCountry;
        }
        if (String.isNotBlank(accountDetails.PersonMailingState)) {
            newCase.Consumer_State__c = accountDetails.PersonMailingState;
        }
        if (String.isNotBlank(accountDetails.PersonMailingCity)) {
            newCase.Consumer_City__c = accountDetails.PersonMailingCity;
        }
        if (String.isNotBlank(accountDetails.PersonMailingPostalCode)) {
            newCase.Consumer_Postal_Code__c = accountDetails.PersonMailingPostalCode;
        }
        if (String.isNotBlank(accountDetails.PersonMailingStreet)) {
            newCase.Consumer_Street__c = accountDetails.PersonMailingStreet;
        }
        if (accounts != null && accounts.size()>0) {
            newCase.Retail_Account__c = accounts[0].Id;
        }
        if (newCase.AdditionalInformation__c == DTC_Constants.PAYMENT_DECLINE) {
            newCase.Follow_Up_Count__c = 1;
        }
        newCase.DisputeID__c = caseDetails.DisputeID__c;
        newCase.Transaction_Amount__c = caseDetails.Transaction_Amount__c;
        newCase.TransactionID__c = caseDetails.TransactionID__c;
        newCase.Received_Date__c = caseDetails.Received_Date__c;
        newCase.Response_Deadline__c = caseDetails.Response_Deadline__c;
        Insert newCase;
        if (newCase != null) {
            createdCase = SLT_DTC_Case.getCaseByID(newCase.Id);
        }
        return createdCase;
    }

    public static Case dhlCaseCreation(Case caseDetails) {
        Group groupDetail;
        List<Account> accounts = SLT_DTC_Account.getAccountByName(DTC_Constants.DTC_DHL_ACCOUNT);
        Case createdCase;
        Case newCase  = new Case();
        newCase.Origin = DTC_Constants.DHL_PORTAL;
        newCase.RecordTypeId = DTC_Constants.CASE_DTC_RECORDTYPEID;
        newCase.Email_Address__c = caseDetails.Email_Address__c;
        newCase.First_name__c = caseDetails.First_name__c;
        newCase.Last_name__c = caseDetails.Last_name__c;
        newCase.OrderID__c = caseDetails.OrderID__c;
        newCase.Program_Subscription__c = caseDetails.Program_Subscription__c;
        newCase.Automated_Notification_Email__c = System.Label.DTC_EmailToCaseEmail;
        newCase.Consumer_Country__c = caseDetails.Consumer_Country__c;
        newCase.Consumer_State__c = caseDetails.Consumer_State__c;
        newCase.Consumer_City__c = caseDetails.Consumer_City__c;
        newCase.Consumer_Postal_Code__c = caseDetails.Consumer_Postal_Code__c;
        newCase.Consumer_Street__c = caseDetails.Consumer_Street__c;
        newCase.UPS_Reason_For_Return__c = caseDetails.UPS_Reason_For_Return__c;
        newCase.UPS_Tracking_Number__c = caseDetails.UPS_Tracking_Number__c;
        newCase.ContactId = caseDetails.ContactId;
        newCase.AccountId = caseDetails.AccountId;
        newCase.How_can_we_help__c = DTC_Constants.COMMUNITY_CONSOLE;
        newCase.AdditionalInformation__c = DTC_Constants.RETURN_ADDINFORMATION;
        if (caseDetails.DHL_Status__c == DTC_Constants.DHL_STATUS_LOST
            || caseDetails.DHL_Status__c == DTC_Constants.DHL_STATUS_DAMAGE) {
                newCase.Damage_Issue__c = caseDetails.DHL_Status__c;
        }
        newCase.DHL_Status__c = 'Returned to warehouse('+caseDetails.DHL_Status__c+')';
        newCase.Brand__c = DTC_Constants.MAP_SUBSCRIPTION_TO_BRAND.get(caseDetails.Program_Subscription__c);
        if (newCase.Brand__c == DTC_Constants.BRAND_MAKERS_MARK_APPOS) {
            groupDetail = SLT_DTC_Group.getQueueByDeveloperName(DTC_Constants.QUEUE_DTC);
            newCase.Automated_Notification_Email__c = DTC_Constants.EMAIL_WHISKY_DROP;
        } else {
            groupDetail = SLT_DTC_Group.getQueueByDeveloperName(DTC_Constants.QUEUE_BARRELED_BOXED);
            newCase.Automated_Notification_Email__c = DTC_Constants.EMAIL_BARRELED_AND_BOXED;
        }
        newCase.status = DTC_Constants.NEW_STATUS;
        newCase.Customer_Phone_Number__c = caseDetails.Customer_Phone_Number__c;
        if (groupDetail != null) {
            newCase.OwnerID = groupDetail.Id;  
        }
        if (accounts != null && accounts.size()>0) {
            newCase.Retail_Account__c = accounts[0].Id;
        }
        Insert newCase;
        if (newCase != null) {
            createdCase = SLT_DTC_Case.getDhlCaseByID(newCase.Id);
        }
        return createdCase;
    }
    
     /**
    *  @description : Helper method use to update case fields value..
    *  @args        : String, Case caseObj, Case caseObj, Case caseObj, Case caseObj
    *  @return      : Case
    **/
    
    public static Case updateCaseAvataxBraintreeSAPStatus(String statusNeedToBeUpdate, Case avataxDetails, 
        Case braintreeDetails, Case sapDetails, Case caseStoreRecord) {
            if(caseStoreRecord.AdditionalInformation__c == DTC_Constants.ADD_INFO_DISPUTE 
                || (caseStoreRecord.Status == DTC_Constants.REFUND_STATUS 
                && caseStoreRecord.Sub_Status__c == DTC_Constants.INITIATED_SUB_STATUS)){
            
            if(avataxDetails != null){
                caseStoreRecord.Avatax_Status__c = String.isNotBlank(avataxDetails.Avatax_Status__c) ? 
                avataxDetails.Avatax_Status__c : caseStoreRecord.Avatax_Status__c;
                caseStoreRecord.Tax_Amount__c = String.isNotBlank(String.Valueof(avataxDetails.Tax_Amount__c)) ? 
                avataxDetails.Tax_Amount__c : caseStoreRecord.Tax_Amount__c;
            }
            if(sapDetails != null){
                caseStoreRecord.SAP_Status__c = String.isNotBlank(sapDetails.SAP_Status__c) ? 
                sapDetails.SAP_Status__c : caseStoreRecord.SAP_Status__c;
                caseStoreRecord.SAP_Order_Number__c = String.isNotBlank(sapDetails.SAP_Order_Number__c) ? 
                sapDetails.SAP_Order_Number__c : caseStoreRecord.SAP_Order_Number__c;
            }
            if(braintreeDetails != null){
                caseStoreRecord.Braintree_Status__c = String.isNotBlank(braintreeDetails.Braintree_Status__c) ? 
                braintreeDetails.Braintree_Status__c : caseStoreRecord.Braintree_Status__c;
                caseStoreRecord.Transaction_Amount__c = String.isNotBlank(String.Valueof(braintreeDetails.Transaction_Amount__c))
                 ? braintreeDetails.Transaction_Amount__c : caseStoreRecord.Transaction_Amount__c;
                caseStoreRecord.Date_of_Transaction__c = braintreeDetails.Date_of_Transaction__c != null ? 
                braintreeDetails.Date_of_Transaction__c : caseStoreRecord.Date_of_Transaction__c;
            }
        }
        
        if(statusNeedToBeUpdate != null) {
            caseStoreRecord.Status = statusNeedToBeUpdate;
            caseStoreRecord.Sub_Status__c = '';
        }  
        update caseStoreRecord;
        return caseStoreRecord;
    }

     /**
    *  @description : Helper method use to update case UPS Tracking Number value..
    *  @args        : Case, Case
    *  @return      : Case
    **/
    public static Case updateCaseTrackingNumber(Case caseObjUpdate, Map<String, Object> caseDetails) {
        if (String.isNotBlank(String.valueof(caseDetails.get('trackingNumber')))
        && String.valueof(caseDetails.get('trackingNumber')) != String.valueof(caseObjUpdate.UPS_Tracking_Number__c)) {
            caseObjUpdate.UPS_Tracking_Number__c = String.isNotBlank(String.valueof(caseDetails.get('trackingNumber'))) ?
            String.valueof(caseDetails.get('trackingNumber')) : caseObjUpdate.UPS_Tracking_Number__c;
            caseObjUpdate.Status = DTC_Constants.CLOSED_STATUS;
            caseObjUpdate.Sub_Status__c = '';
            update caseObjUpdate;
        }
        return caseObjUpdate;
    }
    
    /**
    *  @description : Helper method use to update case Status to Reopen.
    *  @args        : Case
    *  @return      : Case
    **/
    public static Case updateCaseStatusToReopen(Case caseObj) {
        Case caseObjUpdate = new Case();
        caseObjUpdate.Id = caseObj.Id;
        caseObjUpdate.Status = DTC_Constants.REOPEN_STATUS;
        caseObjUpdate.Sub_Status__c = '';
        return caseObjUpdate;
    }

    public static Case updateCaseReminderStep(Case caseObj) {
        Case caseObjUpdate = new Case();
        caseObjUpdate.Id = caseObj.Id;
        caseObjUpdate.Follow_Up_Count__c = String.isNotBlank(String.valueOf(caseObj.Follow_Up_Count__c))  ? 
        caseObj.Follow_Up_Count__c + 1 : 1;
        if(caseObjUpdate.Follow_Up_Count__c == 4){
            caseObjUpdate.Status = DTC_Constants.CLOSED_STATUS;
            caseObjUpdate.Sub_Status__c = '';
        }
        update caseObjUpdate;
        return caseObjUpdate;
    }
}