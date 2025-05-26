public without sharing class SBP_CustomPath {
    @AuraEnabled  
    public static List<String> getStatus(String brand) {
        List<SBP_Custom_Path__mdt> statusList = SLT_CustomMetadata.getCustomPathMetadataRecords(new Set<String>{brand});
        List<String> listOfStatusWithSubStatus = new List<String>();
        for (SBP_Custom_Path__mdt record : statusList) {
            if (String.isNotBlank(record.Status__c)) {
                if (String.isNotBlank(record.SubStatus__c)) {
                    listOfStatusWithSubStatus.add(String.valueOf(record.Status__c) + '-' +record.SubStatus__c);
                } else {
                    listOfStatusWithSubStatus.add(String.valueOf(record.Status__c));
                }
            }
        }
        return listOfStatusWithSubStatus;
    }

    @AuraEnabled  
    public static Case getCaseRecord(String recordId) {
        case caseRecord;
        if (String.isNotBlank(recordId) ) {
            caseRecord = SLT_Case.getCaseDetailByID(recordId);
        }
        return caseRecord;
    }
}