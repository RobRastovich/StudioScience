public class SLT_Topic {
    /**
    *  @description : This method is use to fetch Topic records by given Topics Name(CRM).
    *  @args        : IDs 
    *  @return      : List<Topic>
    **/
    public static List<Topic> getTopicList(Set<String> topicsName){
        List<Topic> topics = new List<Topic>();
        topics = [SELECT ID, Name
                     FROM Topic 
                     WHERE Name IN: topicsName
                     ORDER BY Name ASC];
        return topics;
    }
    
    /**
    *  @description : This method is use to fetch Topic record from a given Topic Name(CRM).
    *  @args        : String 
    *  @return      : List<Topic>
    **/
    public static List<Topic> checkTopicExistinSystem(String topicName){
        List<Topic> topics = new List<Topic>();
        topics = [SELECT ID, Name
                     FROM Topic
                     WHERE Name =: topicName];
        return topics;
    }
}