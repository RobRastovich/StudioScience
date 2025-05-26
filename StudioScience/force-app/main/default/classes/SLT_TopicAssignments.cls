public class SLT_TopicAssignments {
/**
    *  @description : This method is use to fetch TopicAssignments record from a given CaseId(CRM).
    *  @args        : Id 
    *  @return      : List<TopicAssignment>
    **/
    public static List<TopicAssignment> fetchTopicAssignments(Id caseId){
        List<TopicAssignment> topicsAssignmentsList = new List<TopicAssignment>();
        topicsAssignmentsList = [SELECT ID, EntityId, TopicId, 
                                    Topic.Name
                                    FROM TopicAssignment
                                    WHERE EntityId =: caseId];
        return topicsAssignmentsList;
    }
}