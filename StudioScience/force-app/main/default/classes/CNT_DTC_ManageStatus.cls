public without sharing class CNT_DTC_ManageStatus {
    @AuraEnabled  
    public static Case manageStatus(String status, String substatus, String recordId) {
        case returnCaseRecord;
        Boolean isCaseUpdated = false;
        try {
            if (String.isNotBlank(status) && String.isNotBlank(recordId) ) {
                case caseRecord = SLT_DTC_Case.getCaseDetailByID(recordId);
                if (caseRecord != null) {
                    caseRecord.Status = status;
                    if (String.isNotBlank(substatus) && substatus.containsIgnoreCase('undefined')) {
                        caseRecord.Sub_Status__c = '';
                    } else if (String.isNotBlank(substatus) && !substatus.containsIgnoreCase('undefined')) {
                        caseRecord.Sub_Status__c = substatus;
                    }else {
                        caseRecord.Sub_Status__c = '';
                    }
                    if (caseRecord.How_can_we_help__c == DTC_Constants.COMMUNITY_CONSOLE 
                        && caseRecord.AdditionalInformation__c == DTC_Constants.RETURN_ADDINFORMATION) {
                        if(caseRecord.Status == DTC_Constants.IN_PROGRESS && 
                            (caseRecord.Sub_Status__c == DTC_Constants.RESHIP_CONFIRMED || 
                            caseRecord.Sub_Status__c == DTC_Constants.RESHIPMENT_INITIATED)){
                            caseRecord.AdditionalInformation__c = DTC_Constants.RETURN_AND_RESHIP; 
                        }else if(caseRecord.Status == DTC_Constants.REFUND_STATUS && 
                            caseRecord.Sub_Status__c == DTC_Constants.INITIATED_SUB_STATUS){
                            caseRecord.AdditionalInformation__c = DTC_Constants.RETURN_AND_CREDIT;
                        }
                    } else if(caseRecord.How_can_we_help__c == DTC_Constants.API 
                        && caseRecord.AdditionalInformation__c == DTC_Constants.MEMBERSHIP_CANCELLATION) {
                        if (caseRecord.Sub_Status__c == DTC_Constants.CANCEL_SHIPMENT 
                            && caseRecord.Status == DTC_Constants.IN_PROGRESS) {
                                caseRecord.Sub_Status__c = DTC_Constants.COMMUNICATE_WITH_DHL;
                        }    
                    }
                    if(caseRecord.Status == DTC_Constants.IN_PROGRESS && 
                        caseRecord.Sub_Status__c == DTC_Constants.REPLACEMENT_CONFIRMED_SUB_STATUS){
                        caseRecord.AdditionalInformation__c = DTC_Constants.REPLACEMENT;
                    }
                    update caseRecord;
                    isCaseUpdated = true;
                }
            }
            if (isCaseUpdated) {
                returnCaseRecord = SLT_DTC_Case.getCaseDetailByID(recordId);
            }
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return returnCaseRecord;
    }

    @AuraEnabled  
    public static Case getCaseRecord(String recordId) {
        case caseRecord;
        if (String.isNotBlank(recordId) ) {
            caseRecord = SLT_DTC_Case.getCaseDetailByID(recordId);
        }
        return caseRecord;
    }

    @AuraEnabled  
    public static Map<String,List<String>> getStatusFromMetadata(String caseType, String howCanWeHelpYou) {
        Map<String,List<String>> mapOfStatusToSubStatusList = new Map<String,List<String>>();
        if(String.isNotBlank(caseType) && String.isNotBlank(howCanWeHelpYou)){
            List<DTC_Manage_Status__mdt> statusList = SLT_DTC_CustomMetadata.getManageStatusRecords(new Set<String>{caseType}, howCanWeHelpYou);
            for (DTC_Manage_Status__mdt record : statusList) {
                List<String> subStatuslist = new List<String>();
                if (String.isNotBlank(record.Sub_Status__c) && record.Sub_Status__c.contains(',')) {
                    subStatuslist = record.Sub_Status__c.split(',');
                    mapOfStatusToSubStatusList.put(String.valueOf(record.Status__c), subStatuslist);
                } else if (String.isNotBlank(record.Sub_Status__c) && !record.Sub_Status__c.contains(',')) {
                    subStatuslist.add(record.Sub_Status__c.trim());
                    mapOfStatusToSubStatusList.put(String.valueOf(record.Status__c), subStatuslist);
                } else if (String.isBlank(record.Sub_Status__c)) {
                    mapOfStatusToSubStatusList.put(String.valueOf(record.Status__c), subStatuslist);
                }
            }
        }
        return mapOfStatusToSubStatusList;
    }
}