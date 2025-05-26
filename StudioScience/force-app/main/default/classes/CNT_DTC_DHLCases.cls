public without sharing class CNT_DTC_DHLCases {

    @AuraEnabled(cacheable = true)  
    public static List<Case> getCasesList(Integer pagenumber, Integer numberOfRecords, Integer pageSize, String searchString,  
                                            String addInfo, String sortOrder) { 
        if (pagenumber == null || pagenumber <=0) {
            pagenumber = 1;
        }
        if (pageSize == null || pageSize <=0) {
            pageSize = 5;
        }
        List<Case> casesList = SLT_DTC_Case.getCasesList(pagenumber, pageSize, searchString, 
                                                            new Set<Id>{DTC_Constants.CASE_DTC_RECORDTYPEID}, addInfo, sortOrder);
        for (Integer i = 0; i < casesList.size(); i++) {
            if (!String.isEmpty(casesList[i].AdditionalInformation__c) &&
                casesList[i].AdditionalInformation__c == 'Membership Cancellation') {
                casesList[i].AdditionalInformation__c = 'Cancel Shipment';
            }
        }
        return casesList;
    }  
   
    @AuraEnabled(cacheable = true)  
    public static Integer getCasesCount(String searchString, String addInfo) {  
        Integer count = SLT_DTC_Case.getCasesCount(searchString, new Set<Id>{DTC_Constants.CASE_DTC_RECORDTYPEID}, addInfo);
        return count;
    } 
    
    @AuraEnabled  
    public static Case createCase(Case caseInfo) {
        Case createdCase;
        try {
            if (caseInfo != null) {
                Boolean validCase = isValidated(caseInfo);
                if (validCase) {
                    manageContactDetails(caseInfo);
                    Case caseToBeCreated = manageAccountDetails(caseInfo);
                    if (caseToBeCreated != null && caseToBeCreated.AccountId != null 
                        && caseToBeCreated.ContactId != null) {
                        createdCase = SRV_DTC_Case.dhlCaseCreation(caseToBeCreated);
                    }
                }
            }
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return createdCase;
    }

    public static Boolean isValidated(Case caseDetail) {
        if (caseDetail == null) {
            return false;
        }
        Set<String> setOfFieldAPINames;
        if (String.isNotBlank(caseDetail.AdditionalInformation__c) 
            && caseDetail.AdditionalInformation__c == DTC_Constants.REPLACEMENT) {
                setOfFieldAPINames = DTC_Constants.DHL_REPLACEMENT_CASE_REQUIRED_FIELDS;
        } else {
            setOfFieldAPINames = DTC_Constants.DHL_CASE_REQUIRED_FIELDS;
        }
        Boolean isRecordValid = true;
        for(String fieldName: setOfFieldAPINames) {
            if(String.isBlank(String.valueOf(caseDetail.get(fieldName)))) {
                isRecordValid = false;
                break;
            }
        }
        return isRecordValid;
    }

    public static void manageContactDetails(Case caseDetail){
        Contact contactDetails = new Contact();
        contactDetails.FirstName = caseDetail.First_Name__c;
        contactDetails.LastName = caseDetail.Last_Name__c;
        contactDetails.Email = caseDetail.Email_Address__c;
        SRV_DTC_Contact.createOrUpdateContact(contactDetails, contactDetails.Email);
    }

    public static Case manageAccountDetails(Case caseDetails){
        Account accountDetails = new Account();
        accountDetails.PersonEmail = caseDetails.Email_Address__c;
        Id existingAccId = SRV_DTC_Account.getExistingAccountId(accountDetails.PersonEmail);
        if(existingAccId != null) {
            accountDetails.Id = existingAccId;
            List<Account> lstAccInfo = SLT_DTC_Account.getPersonAccountsByIDs(new Set<ID>{accountDetails.Id});
            if(lstAccInfo.size() > 0){
                caseDetails.ContactId = lstAccInfo[0].PersonContactId;
                caseDetails.AccountId = lstAccInfo[0].Id;
                if(caseDetails.Consumer_Country__c != null || caseDetails.Consumer_State__c != null 
                    || caseDetails.Consumer_City__c != null || caseDetails.Consumer_Postal_Code__c != null 
                    || caseDetails.Consumer_Street__c != null) {
                    Account updatedAccount = SRV_DTC_Account.updateDhlAccount(lstAccInfo[0], caseDetails);
                }
            }
        }else {
            Account newAccount = SRV_DTC_Account.insertPersonAccountUsingUserDetail(caseDetails, accountDetails);
            if(newAccount != null){
                caseDetails.ContactId = newAccount.PersonContactId;
                caseDetails.AccountId = newAccount.Id;
            }
        }
        return caseDetails;
    }

    @AuraEnabled(cacheable=true)
    public static Case getCaseRecord(String recordId) {
        String caseId = String.escapeSingleQuotes(recordId);
        Case recordCase = new Case();
        recordCase = SLT_DTC_Case.getDhlCaseByID(caseId);
        if (!String.isEmpty(recordCase.AdditionalInformation__c) &&
            recordCase.AdditionalInformation__c == 'Membership Cancellation') {
                recordCase.AdditionalInformation__c = 'Cancel Shipment';
        }
        return recordCase; 
    }
}