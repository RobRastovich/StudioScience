public with sharing class TopicReport {
    @AuraEnabled
    public static Map<String,List<Case>> mapTopicAssignments(String startDate,String endDate, List<String> recordTypeList){
        List<Case> caseList = new List<Case>();
        Map<String,List<Case>> mapCaseList = new Map<String, List<Case>>();
        if(!recordTypeList.isEmpty() && startDate != null && endDate != null){
            caseList = CRM_SLT_Case.getQClaimAndCInquiryRecorTypeCases(Date.valueof(startDate), Date.valueof(endDate), recordTypeList);
        }
        for(Case caseRecord : caseList){
            for(TopicAssignment topicAssignRecord : caseRecord.TopicAssignments){
                if(!mapCaseList.containskey(topicAssignRecord.Topic.Name)){
                    mapCaseList.put(topicAssignRecord.Topic.Name, new List<Case>{caseRecord});
                }
                else{
                    mapCaseList.get(topicAssignRecord.Topic.Name).add(caseRecord);
                }
            }
        }
        return mapCaseList;
    }
}