public class SLT_SOI_Announcement {
    public static List<Announcement__c> getAnnouncementsRecords() {
        List<Announcement__c> announcements = new List<Announcement__c>();
        announcements = [SELECT Id, Message__c, Type__c
                            FROM Announcement__c
                            WHERE Type__c = :SOI_Constants.INNOVATION_TYPE];
        return announcements;
    }
}