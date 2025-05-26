public class SLT_DTC_Group {
    /**
    *  @description : This method is use to fetch Queue.
    *  
    *  @return      : Group
    **/
    public static Group getQueueByName(String howCanWeHelpYou){
        Group groupDetail = [SELECT Id, Name, DeveloperName, Type 
                             FROM Group 
                             WHERE DeveloperName =:DTC_Constants.MAP_HOLD_HOW_CAN_WE_HELP_WITH_QUEUE.get(howCanWeHelpYou)  
                             AND Type = 'Queue' 
                             limit 1];
        return groupDetail;
    }
    
    /**
    *  @description : This method is use to fetch Queue.
    *  @args        : String DeveloperName
    *  @return      : Group
    **/
    public static Group getQueueByDeveloperName(String developerName){
        Group groupDetail = [SELECT Id, Name, DeveloperName, Type 
                             FROM Group 
                             WHERE DeveloperName =: developerName and Type = 'Queue' 
                             limit 1];
        return groupDetail;
    }
}