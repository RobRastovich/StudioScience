public class SRV_DTC_CustomNotification {
    public static Boolean isNotificationSent;
    public static void sendCustomNotificatioToOwner(String title, String body, Id notificationTypeId, Id targetId, Set<String> addressee ) {
        if(String.isNotBlank(title) && String.isNotBlank(body) && String.isNotBlank(String.valueOf(notificationTypeId)) &&
           String.isNotBlank(String.valueOf(targetId)) && addressee.size() > 0){
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle(title);
            notification.setBody(body);
            notification.setNotificationTypeId(notificationTypeId);
            notification.setTargetId(targetId);
            if(addressee.size() > 0){
                notification.send(addressee);
                isNotificationSent = true;
            }
        }
    }
}