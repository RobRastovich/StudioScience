public class SLT_DTC_CustomNotification {
    /**
    *  @description : This method is use to fetch Custom Notification.
    *  @args        : Developer Name(String) 
    *  @return      : CustomNotificationType
    **/
    public static CustomNotificationType getCustomNotification(String developerName){
        CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                       FROM CustomNotificationType 
                                                       WHERE DeveloperName =: developerName];
        return notificationType;
    }
}