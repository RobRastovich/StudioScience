public class DTCCaseCreationRestHandler {
    public static RestResponse createCase(){
        ResponseWrapper responseWrapper;
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');
        try {
            String jsonString = request.requestBody.toString();
            Account accountDetails;
            Account userContactAccountDetails;
            Contact contactDetails;
            Case caseDetails;
            Case createdCase;
            Boolean isCaseDetailValidated = true;
            String typeOfCase;
            String magentoId;
            String isShipmentRequired;
            Map<String, String> booleanFieldValueMap = new Map<String, String>();
            Map<string, String> booleanFieldsApiNamesMap = DTC_Constants.MAP_CASE_BOOLEAN_FIELDS_API_NAMES;
            DTC_CaseUserAccountJSON caseUserAccountObj = (DTC_CaseUserAccountJSON)JSON.deserializeStrict(jsonString, 
                                                            DTC_CaseUserAccountJSON.class);
            if (caseUserAccountObj == null || String.isBlank(jsonString)) {
                responseWrapper = new ResponseWrapper(DTC_Constants.FAILURE, DTC_Constants.INVALID_REQUEST, 
                                                        DTC_Constants.MALFORMED_JSON, null);
                response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
                return response;
            } else {
                accountDetails = caseUserAccountObj.accountDetails;
                caseDetails = caseUserAccountObj.caseDetails;
                typeOfCase = caseUserAccountObj.Type;
                magentoId = caseUserAccountObj.MagentoID;
                isShipmentRequired = caseUserAccountObj.isShipmentRequired;
                booleanFieldValueMap = new Map<string, String>{'isCancelConfirmed' => caseUserAccountObj.IsCancelConfirmed,
                    'isShipmentRequired' => caseUserAccountObj.IsShipmentRequired};
                contactDetails = new Contact();
                contactDetails.MagentoID__c = magentoId;
                if (accountDetails == null) {
                    accountDetails = new Account();
                }
            }
            if (accountDetails != null && caseDetails != null && String.isNotBlank(typeOfCase) && String.isNotBlank(magentoId)){
                caseDetails.AdditionalInformation__c = typeOfCase;
                responseWrapper = validateCreateCaseRequest(typeOfCase, caseUserAccountObj, booleanFieldValueMap, 
                                                                booleanFieldsApiNamesMap, caseDetails, accountDetails);
                if (responseWrapper != null) {
                    response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
                    isCaseDetailValidated = false;
                    return response;
                }
                if(isCaseDetailValidated) {
                    accountDetails.PersonEmail = caseDetails.Email_Address__c;
                    contactDetails.LastName = caseDetails.Last_Name__c;
                    Id existingAccId = SRV_DTC_Account.getExistingAccountId(accountDetails.PersonEmail);
                    if(existingAccId != null) {
                        accountDetails.Id = existingAccId;
                        List<Account> lstAccInfo = SLT_DTC_Account.getPersonAccountsByIDs(new Set<ID>{accountDetails.Id});
                        if(lstAccInfo.size() > 0){
                            caseDetails.ContactId = lstAccInfo[0].PersonContactId;
                            caseDetails.AccountId = lstAccInfo[0].Id;
                            if(accountDetails.PersonMailingCountry != null || accountDetails.PersonMailingState != null 
                                || accountDetails.PersonMailingCity != null || accountDetails.PersonMailingPostalCode != null 
                                || accountDetails.PersonMailingStreet != null) {
                                Account updatedAccount = SRV_DTC_Account.updateAccount(lstAccInfo[0], accountDetails);
                            }
                        }
                    } else {
                        Account newAccount = SRV_DTC_Account.insertPersonAccountUsingUserDetail(caseDetails, accountDetails);
                        if(newAccount != null){
                            caseDetails.ContactId = newAccount.PersonContactId;
                            caseDetails.AccountId = newAccount.Id;
                        }
                    }
                    if(caseDetails.ContactId != null) {
                        createdCase = SRV_DTC_Case.caseCreation(caseDetails, typeOfCase, accountDetails, isShipmentRequired);
                        responseWrapper = new ResponseWrapper(DTC_Constants.SUCCESS, null, 
                                                                DTC_Constants.RECORD_CREATED_SUCCESSFULLY, createdCase);
                    }
                    if(contactDetails != null && createdCase != null) { 
                        SRV_DTC_Contact.createOrUpdateContact(contactDetails, accountDetails.PersonEmail);
                    }
                }
            } else {
                responseWrapper = new ResponseWrapper(DTC_Constants.FAILURE, DTC_Constants.INVALID_REQUEST, 
                                                        DTC_Constants.REQUIRED_ATTRIBUTES_ARE_MISSING, null);
            }
        } catch (Exception ex) {
            if (ex.getMessage().containsIgnoreCase(DTC_Constants.DATE_PARSING_ERROR)) {
                responseWrapper = new ResponseWrapper(DTC_Constants.FAILURE, DTC_Constants.INCORRECT_VALUE_FOR_DATE, 
                                                        DTC_Constants.DATE_PARSING_ERROR_MESSAGE, null);
            } else if (ex.getMessage().containsIgnoreCase(DTC_Constants.FIELD_CUSTOM_VALIDATION_EXCEPTION)){
                responseWrapper = new ResponseWrapper(DTC_Constants.FAILURE, DTC_Constants.DUPLICATE_VALUES_NOT_ALLOWED, 
                                                        ex.getMessage().substringBetween(',', '!').trim(), null);
            } else if (ex.getMessage().containsIgnoreCase(DTC_Constants.INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST)){
                responseWrapper = new ResponseWrapper(DTC_Constants.FAILURE, DTC_Constants.BAD_VALUE_FOR_RESTRICTED_PICKLIST, 
                                                        DTC_Constants.REFER_USER_GUIDE, null);
            } else {
                responseWrapper = new ResponseWrapper(DTC_Constants.FAILURE, 'Error', 
                                                        DTC_Constants.PLEASE_CONTACT_ADMINISTRATOR, null);
                String errorMessage = 'Error creating case via API' + ex.getMessage() + '\n' + ex.getStackTraceString();
                CreateExceptionLog.insertErrorLog('DTCCaseCreationRestHandler', 'createCase',
                    String.valueOf(errorMessage), 'Fatal');
            }
        }
        response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
        return response;
    }

    public static RestResponse updateCase(){
        ResponseWrapper responseWrapper;
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        
        try{
            Case caseDetails;
            Case avataxDetails;
            Case braintreeDetails;
            Case sapDetails;
            case caseStoreRecord;
            String statusNeedToBeUpdate, holdSuccessMessage;
            Boolean isOnlyCaseStatusUpdate = true;
            Boolean isCaseDetailValidated = true;
            DTC_CaseAvataxBraintreeSAPJSON caseAvataxBraintreeSapObj;
            String jsonBody = request.requestBody.toString();
            if(jsonBody != null)
                caseAvataxBraintreeSapObj = (DTC_CaseAvataxBraintreeSAPJSON)JSON.deserializeStrict(jsonBody, 
                                                DTC_CaseAvataxBraintreeSAPJSON.class);
            if(caseAvataxBraintreeSapObj == null){
                responseWrapper = new ResponseWrapper(DTC_Constants.FAILURE, DTC_Constants.INVALID_REQUEST, 
                                                        DTC_Constants.MALFORMED_JSON, null);
                response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
                return response;
            }
            else{
                caseDetails = caseAvataxBraintreeSapObj.caseDetails;
                avataxDetails = caseAvataxBraintreeSapObj.avataxDetails;
                sapDetails = caseAvataxBraintreeSapObj.sapDetails;
                braintreeDetails = caseAvataxBraintreeSapObj.braintreeDetails;
            }
            if(caseDetails != null){
                String validationMessageCase = validateCaseDetails(caseDetails, DTC_Constants.CASE_REQUIRED_FIELDS_UPDATE, null);
                if (String.isNotBlank(validationMessageCase)) {
                    responseWrapper = new ResponseWrapper(DTC_Constants.VALIDATION_FAILS, DTC_Constants.REQUIRED_FIELD_MISSING, 
                                                            validationMessageCase, caseStoreRecord);
                    response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
                    isCaseDetailValidated = false;
                    return response;
                } 
                if (isCaseDetailValidated && String.isNotBlank(caseDetails.Status)) {
                    String validationMsgForPicklist = validatePicklists(caseDetails, DTC_Constants.UPDATE_API);
                    if (String.isNotBlank(validationMsgForPicklist)) {
                        responseWrapper = new ResponseWrapper(DTC_Constants.VALIDATION_FAILS, 
                                                                DTC_Constants.BAD_VALUE_FOR_RESTRICTED_PICKLIST, 
                                                                validationMsgForPicklist, caseStoreRecord);
                        response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
                        isCaseDetailValidated = false;
                        return response;
                    }
                } 
                if(isCaseDetailValidated){
                    if(String.isNotBlank(caseDetails.CaseNumber)){
                        caseStoreRecord = SLT_DTC_Case.getCaseRecordByCaseNumber(caseDetails.CaseNumber);
                    }
                    if(caseStoreRecord != null){
                        if(caseStoreRecord.Status == DTC_Constants.CLOSED_STATUS){
                            responseWrapper = new ResponseWrapper(DTC_Constants.FAILURE, DTC_Constants.INVALID_REQUEST, 
                                                                    DTC_Constants.CASE_ALREADY_CLOSED, null); 
                            response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
                            return response;
                        }else if(caseStoreRecord.How_can_we_help__c == DTC_Constants.API && 
                           caseStoreRecord.AdditionalInformation__c == caseDetails.Status && 
                           caseDetails.Status == DTC_Constants.PAYMENT_DECLINE && 
                           caseDetails.Status != DTC_Constants.CLOSED_STATUS){
                               caseStoreRecord = SRV_DTC_Case.updateCaseReminderStep(caseStoreRecord);
                               responseWrapper = new ResponseWrapper(DTC_Constants.SUCCESS, null, 
                                                                        DTC_Constants.RECORD_UPDATED_SUCCESSFULLY, 
                                                                        caseStoreRecord);
                               response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
                               return response;
                        }else if(caseDetails.Status == DTC_Constants.PAYMENT_DECLINE && 
                            caseStoreRecord.AdditionalInformation__c != DTC_Constants.PAYMENT_DECLINE && 
                            caseDetails.Status != DTC_Constants.CLOSED_STATUS){
                                responseWrapper = new ResponseWrapper(DTC_Constants.FAILURE, DTC_Constants.INVALID_REQUEST, 
                                                                        DTC_Constants.CASE_TYPE_NOT_PAYMENT_DECLINE, null); 
                                response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
                                return response;
                        }
                        if(caseDetails.Status != null){
                            statusNeedToBeUpdate = caseDetails.Status;
                        }  
                        caseStoreRecord = SRV_DTC_Case.updateCaseAvataxBraintreeSAPStatus(statusNeedToBeUpdate, 
                                                                                                avataxDetails, 
                                                                                                braintreeDetails, 
                                                                                                sapDetails, caseStoreRecord);
                        responseWrapper = new ResponseWrapper(DTC_Constants.SUCCESS, null, 
                                                            DTC_Constants.RECORD_UPDATED_SUCCESSFULLY, caseStoreRecord);
                    }
                    else{
                        responseWrapper = new ResponseWrapper(DTC_Constants.FAILURE, DTC_Constants.INVALID_REQUEST, 
                                                                'Case Details cannot be empty. ', null);
                    }
                }
            }
            else{
                responseWrapper = new ResponseWrapper(DTC_Constants.FAILURE, DTC_Constants.INVALID_REQUEST, 
                                                        DTC_Constants.REQUIRED_ATTRIBUTES_ARE_MISSING, null);
            }
        }
        catch(Exception ex){
            responseWrapper = new ResponseWrapper(DTC_Constants.FAILURE, 'Error', 
                                                        DTC_Constants.PLEASE_CONTACT_ADMINISTRATOR, null);
                String errorMessage = 'Error updating case via API' + ex.getMessage() + '\n' + ex.getStackTraceString();
                CreateExceptionLog.insertErrorLog('DTCCaseCreationRestHandler', 'updateCase',
                    String.valueOf(errorMessage), 'Fatal');
        }
        response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
        return response;
    }

    @testVisible
    private static String validateCaseDetails(Case caseDetail, Set<String> requiredFields, String typeOfCase) {
        Set<String> setOfFieldAPINames = requiredFields;
        Set<String> secondSetOfFieldAPINames = DTC_Constants.CASE_REQUIRED_FIELDS_SET_2;
        Set<String> setOfFieldAPINamesForDisputeCase = DTC_Constants.DISPUTE_CASE_REQUIRED_FIELDS;
        String fieldLabels = '';
        Boolean ifValidationFails = false;
        for(String fieldName: setOfFieldAPINames) {
            if(caseDetail.get(fieldName) == false
                || String.isBlank(String.valueOf(caseDetail.get(fieldName)))) {
                String labelName = Schema.getGlobalDescribe().get('Case').
                    getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();
                if(!String.isBlank(labelName)) {
                    if (typeOfCase == DTC_Constants.ADD_INFO_DISPUTE 
                        && labelName == DTC_Constants.LABEL_CANCELATION_REASON) {
                        continue;
                    } else {
                    fieldLabels += labelName + ', ';
                    }
                }
                ifValidationFails = true;
            }
        }
        if (String.isNotBlank(typeOfCase) && typeOfCase == DTC_Constants.MEMBERSHIP_CANCELLATION 
            && caseDetail.Cancel_Confirmed__c == false) {
            for(String fieldName: secondSetOfFieldAPINames) {
                if(String.isBlank(String.valueOf(caseDetail.get(fieldName)))) {
                    String labelName = Schema.getGlobalDescribe().get('Case').
                        getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();
                    if(!String.isBlank(labelName)) {
                        fieldLabels += labelName + ', ';
                    }
                    ifValidationFails = true;
                }
            }
        }
        if (String.isNotBlank(typeOfCase) && typeOfCase == DTC_Constants.ADD_INFO_DISPUTE) {
            for(String fieldName: setOfFieldAPINamesForDisputeCase) {
                if(String.isBlank(String.valueOf(caseDetail.get(fieldName)))) {
                    String labelName = Schema.getGlobalDescribe().get('Case').
                        getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();
                    if(!String.isBlank(labelName)) {
                        fieldLabels += labelName + ', ';
                    }
                    ifValidationFails = true;
                }
            }
        }
        if(ifValidationFails){
            return appendFieldLabel(fieldLabels);
        }
        return null;
    }

    @testVisible
    private static String appendFieldLabel(String fieldLabels) {    
        fieldLabels = fieldLabels.removeEnd(', ');
        if (fieldLabels.countMatches(',')>1) {
            fieldLabels = DTC_Constants.REQUIRED_FIELDS_ARE_MISSING + fieldLabels;
        } else {
            fieldLabels = DTC_Constants.REQUIRED_FIELD_IS_MISSING + fieldLabels;
        }
        return fieldLabels;
    }

    @testVisible
    private static String validatePicklists(Case caseDetail, String operationType){
        String validationMessage = '' ;
        if (operationType == DTC_Constants.CREATE_API) {
            String messageBrand = validateCasePicklist('Brand__c', caseDetail.Brand__c);
            String messageCancelReason = validateCasePicklist('Cancelation_Reason__c', caseDetail.Cancelation_Reason__c);
            if (String.isNotBlank(messageBrand)) {
                validationMessage += messageBrand;
            }
            if (String.isNotBlank(messageCancelReason) 
                && caseDetail.AdditionalInformation__c != DTC_Constants.ADD_INFO_DISPUTE) {
                validationMessage += messageCancelReason;
            }
        }
        if (operationType == DTC_Constants.UPDATE_API) {
            String messageStatus = validateCasePicklist('Status', caseDetail.Status);
            if (String.isNotBlank(messageStatus)) {
                validationMessage += messageStatus;
            }
        }
        if (String.isNotBlank(validationMessage)) {
            validationMessage += DTC_Constants.REFER_USER_GUIDE;
        }
        return validationMessage;
    }

    @testVisible
    private static String validateCasePicklist(String fieldName, String fieldValue) {
        String message = '';
        if (String.isNotBlank(fieldName)) {
            String labelName = Schema.getGlobalDescribe().get('Case').
                    getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();
            if (fieldName == 'Cancelation_Reason__c') {
                if (!DTC_Constants.CASE_PICKLIST_CANCELLATION_REASON_SET.contains(fieldValue)) {
                    message = '"'+ fieldValue+'"'+' is '+ DTC_Constants.BAD_VALUE_FOR_RESTRICTED_PICKLIST +': '+ labelName +'. ';
                }
            }
            if (fieldName == 'Brand__c') {
                if (!DTC_Constants.CASE_PICKLIST_BRAND_SET.contains(fieldValue)) {
                    message = '"'+ fieldValue+'"'+' is '+ DTC_Constants.BAD_VALUE_FOR_RESTRICTED_PICKLIST +': '+ labelName +'. ';
                }
            }
            
            if (fieldName == 'Status') {
                if (!DTC_Constants.STATUS_PICKLIST_BRAND_SET.contains(fieldValue)) {
                    message = '"'+ fieldValue+'"'+' is '+ DTC_Constants.BAD_VALUE_FOR_RESTRICTED_PICKLIST +': '+ labelName +'. ';
                }
            }
        }
        return  message;
    }

    @testVisible
    private static Boolean validateBooleanFields(Map<String, String> booleanFieldValueMap, Map<String, 
                                                    String> booleanFieldsApiNamesMap,
        Case caseDetails) {
        Boolean isValidated = true;
        for (String key : booleanFieldValueMap.keySet()) {
            if (booleanFieldValueMap.get(key) != null) {
                if (booleanFieldValueMap.get(key).containsIgnoreCase('true') && booleanFieldsApiNamesMap.containsKey(key)) {
                    caseDetails.put(booleanFieldsApiNamesMap.get(key), true);
                } else if (booleanFieldValueMap.get(key).containsIgnoreCase('false') && 
                    booleanFieldsApiNamesMap.containsKey(key)) {
                    caseDetails.put(booleanFieldsApiNamesMap.get(key), false);
                } else {
                    isValidated = false;
                }
            }
        }
        return isValidated;
    }

    @testVisible
    private static ResponseWrapper validateCreateCaseRequest(String typeOfCase, DTC_CaseUserAccountJSON caseUserAccountObj, 
                                                                Map<String, String> booleanFieldValueMap, 
                                                                Map<String, String> booleanFieldsApiNamesMap,
                                                                Case caseDetails, Account accountDetails) {
        ResponseWrapper responseWrapper;
        if (typeOfCase == DTC_Constants.MEMBERSHIP_CANCELLATION && String.isBlank(caseUserAccountObj.IsCancelConfirmed)) {
            responseWrapper = new ResponseWrapper(DTC_Constants.FAILURE, DTC_Constants.INVALID_REQUEST, 
                                                    DTC_Constants.CANCELCONFIRMED_REQUIRED_FOR_MC_CASE, null);
            return responseWrapper;
        }
        if (typeOfCase != DTC_Constants.ADD_INFO_DISPUTE) {
            Boolean isBooleanFieldValidated = validateBooleanFields(booleanFieldValueMap, booleanFieldsApiNamesMap, caseDetails);
            if (!isBooleanFieldValidated){
                responseWrapper = new ResponseWrapper(DTC_Constants.VALIDATION_FAILS, 
                                                        DTC_Constants.INVALID_VALUE_PROVIDED 
                                                        + ' for either isCancelConfirmed or isShipmentRequired.', 
                                                        DTC_Constants.ONLY_TRUE_FALSE_IS_EXPECTED, null);
                return responseWrapper;
            }
        }
        if (typeOfCase == DTC_Constants.ADD_INFO_DISPUTE) {
            if(String.isBlank(accountDetails.PersonMailingCountry) && String.isBlank(accountDetails.PersonMailingState) 
            && String.isBlank(accountDetails.PersonMailingCity) && String.isBlank(accountDetails.PersonMailingPostalCode) 
            && String.isBlank(accountDetails.PersonMailingStreet)) {
                responseWrapper = new ResponseWrapper(DTC_Constants.VALIDATION_FAILS, 
                    DTC_Constants.REQUIRED_FIELD_MISSING, DTC_Constants.ONE_ADDRESS_FIELD_VALUE, null);
                    return responseWrapper;
            }
        }               
        String validationMessageCase = validateCaseDetails(caseDetails, DTC_Constants.CASE_REQUIRED_FIELDS, typeOfCase);
        if (String.isNotBlank(validationMessageCase)) {
            responseWrapper = new ResponseWrapper(DTC_Constants.VALIDATION_FAILS, DTC_Constants.REQUIRED_FIELD_MISSING, 
                                                    validationMessageCase, null);
            return responseWrapper;
        }
        String validationMsgForPicklist = validatePicklists(caseDetails, DTC_Constants.CREATE_API);
        if (String.isNotBlank(validationMsgForPicklist)) {
            responseWrapper = new ResponseWrapper(DTC_Constants.VALIDATION_FAILS, 
                                                    DTC_Constants.BAD_VALUE_FOR_RESTRICTED_PICKLIST, validationMsgForPicklist, 
                                                    null);
            return responseWrapper;
        }
        return responseWrapper;
    }
}