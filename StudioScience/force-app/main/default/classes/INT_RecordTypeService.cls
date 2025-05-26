public without sharing class INT_RecordTypeService {
    @AuraEnabled
    public static Map<String, RecordType> getRecordTypesByDeveloperName(String sObjectApiName){
        Map<String, RecordType> result = new Map<String, RecordType>();

        if (String.isNotBlank(sObjectApiName)) {
            for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = :sObjectApiName]) {
                result.put(
                    rt.DeveloperName,
                    rt
                );
            }
        }

        return result;
    }
}