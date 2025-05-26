public class CNT_TopicList {
    //public static Integer lastTopicCount = 0;
    /**
*  @description : This method is used to fetch topic created by particular group of users.
*  @args        : Case Record ID
*  @return      : List<TopicWrapper>
**/
    @AuraEnabled(cacheable = false)
    public static List<TopicWrapper> fetchTopicList(Id caseId){
        Map<String, TopicAssignment> topicNameWithTopicAssignemntsMap = new Map<String, TopicAssignment>();
        Set<String> topics = new Set<String>();
        List<Topic_Added_For_User__c> topicsList = new List<Topic_Added_For_User__c>();
        Boolean flag = false;
        Integer lastTopicCount = 0;
        List<TopicWrapper> wrapperReturn = new List<TopicWrapper>();
        List<String> topicsNamesFromCustomSettings = new List<String>();
        TopicWrapperInner innerWrapper = new TopicWrapperInner();
        List<GroupMember> memberRecord = SLT_GroupMember.getMemberRecordFromGivenGroup(CRM_Constants.TOPIC_USER_GROUP,
            String.valueOf(UserInfo.getUserId()));
        if(memberRecord.size() > 0 && !memberRecord.isEmpty()){
            innerWrapper.isUserAccessibleInsertButton = true; 
        }else{
            innerWrapper.isUserAccessibleInsertButton = false;
        }
        
        for(TopicAssignment topicAssignmentRecord : SLT_TopicAssignments.fetchTopicAssignments(caseId)){
            if(!topicNameWithTopicAssignemntsMap.containsKey(topicAssignmentRecord.Topic.Name)){
                topicNameWithTopicAssignemntsMap.put(topicAssignmentRecord.Topic.Name, topicAssignmentRecord);
            }
        }
        for(Topic_Added_For_User__c topicName : SLT_CustomSetting.getTopicsName()){
            if(String.isNotBlank(topicName.Name)){
                Integer latestCount = Integer.valueOf(topicName.Name);
                lastTopicCount =  latestCount > lastTopicCount ? latestCount : lastTopicCount;  
            }
            topics.add(topicName.Topic_Name__c);
        } 
        innerWrapper.countOfLastTopic = lastTopicCount + 1;
        if(topicNameWithTopicAssignemntsMap.keyset().size() > 0){
            topics.addAll(topicNameWithTopicAssignemntsMap.keyset());
        }
        if(topics.size() > 0 && !topics.isEmpty()){
            for(Topic topic : SLT_Topic.getTopicList(topics)){
                TopicWrapper wrapper = new TopicWrapper();
                if(!flag){
                    wrapper.innerWrapper = innerWrapper;
                    flag = true;
                }
                wrapper.topicRecord = topic;
                if(topicNameWithTopicAssignemntsMap.containskey(topic.Name)){
                    wrapper.topicAssignmentId = topicNameWithTopicAssignemntsMap.get(topic.Name).Id;
                    wrapper.isSelected = true;
                }else{
                    wrapper.isSelected = false;
                }
                wrapperReturn.add(wrapper);
            }
        }else{
            TopicWrapper wrapper = new TopicWrapper();
            wrapper.innerWrapper = innerWrapper;
            wrapperReturn.add(wrapper);
        }
        return wrapperReturn;
    }
    
    /**
*  @description : This method is used to fetch topic created by particular group of users.
*  @args        : List of Topic Ids, Case Record Id
*  @return      : void
**/
    @AuraEnabled(cacheable = false)
    public static void insertTopicAssignments(List<Id> topicsIds, String caseId){
        if(!String.isBlank(caseId) && !topicsIds.isEmpty()){
            List<TopicAssignment> insertTopicsAssignemnt = new List<TopicAssignment>();
            for(Id topicId : topicsIds){
                TopicAssignment ta = new TopicAssignment();
                ta.TopicId = topicId;
                ta.EntityId =  caseId;
                insertTopicsAssignemnt.add(ta);
            }
            if(!insertTopicsAssignemnt.isEmpty() && insertTopicsAssignemnt.size() > 0){
                try{
                    insert insertTopicsAssignemnt;
                }catch(Exception e){
                    CreateExceptionLog.insertErrorLog('CNT_TopicList',
                                                         'insertTopicAssignments',
                                                         String.valueOf(e), 'Fatal');
                }
            }
        }
    }
    
    /**
*  @description : This method is used to fetch topic created by particular group of users.
*  @args        : String Topic Assignment Id
*  @return      : void
**/
    @AuraEnabled(cacheable = false)
    public static void deleteTopicAssignments(String topicAssgId){
        if(!String.isBlank(topicAssgId)){
            try{
                TopicAssignment deleteAssgId = new TopicAssignment(Id = Id.valueOf(topicAssgId));
                delete deleteAssgId;
            }catch(Exception e){
                CreateExceptionLog.insertErrorLog('CNT_TopicList',
                                                     'deleteTopicAssignments',
                                                     String.valueOf(e), 'Fatal');
            }
        }
    }
    
    /**
*  @description : This method is used to insert Topic as well as in Custom settings.
*  @args        : String
*  @return      : Wrapper
**/
    @AuraEnabled(cacheable = false)
    public static InsertTopicWrapper insertTopic(String topicName, Integer topicscount){
        Boolean insertTopic = false;
        Topic topic = new Topic();
        InsertTopicWrapper insertTopicWrapper = new InsertTopicWrapper();
        Topic_Added_For_User__c insertSetting = new Topic_Added_For_User__c();
        List<Topic> topicList = new List<Topic>();
        List<Topic_Added_For_User__c> topicListInCustomSettings = new List<Topic_Added_For_User__c>();
        if(String.isNotBlank(topicName)) {
            topicList = SLT_Topic.checkTopicExistinSystem(topicName);
            if(topicList.size() > 0 && !topicList.isEmpty()){
                insertSetting = SRV_CustomSettings.createInstanceTopic(topicName, topicscount);
                insertTopicWrapper.type = CRM_Constants.SUCCESS_TYPE;
                insertTopicWrapper.message = CRM_Constants.RECORD_INSERTED;
            }else{
                topic.Name = topicName;
                insertTopic = true;
                insertSetting = SRV_CustomSettings.createInstanceTopic(topicName,topicscount);
                insertTopicWrapper.type = CRM_Constants.SUCCESS_TYPE;
                insertTopicWrapper.message = CRM_Constants.RECORD_INSERTED;
            }
            try {
                if(String.isNotBlank(insertSetting.Name)){
                    insert insertSetting;
                }
                if(insertTopic){
                    insert topic;
                }
            }
            catch(Exception e) {
                insertTopicWrapper.type = CRM_Constants.ERROR_TYPE;
                insertTopicWrapper.message = CRM_Constants.CONTACT_ADMIN_MESSAGE;
                CreateExceptionLog.insertErrorLog('CNT_TopicList',
                                                     'insertTopic',
                                                     String.valueOf(e), 'Fatal');
            }
        }
        return insertTopicWrapper;
    }
    
    public class TopicWrapper{
        @AuraEnabled
        public Topic topicRecord{get;set;}
        @AuraEnabled
        public Boolean isSelected{get;set;}
        @AuraEnabled
        public String topicAssignmentId{get;set;}
        @AuraEnabled
        public TopicWrapperInner innerWrapper{get;set;}
    }
    
    public class TopicWrapperInner{
        @AuraEnabled
        public Boolean isUserAccessibleInsertButton{get;set;}
        @AuraEnabled
        public Integer countOfLastTopic{get;set;}
    }
    
    public class InsertTopicWrapper {
        @AuraEnabled
        public String type {get; set;}
        @AuraEnabled
        public String message {get; set;}
    }
}