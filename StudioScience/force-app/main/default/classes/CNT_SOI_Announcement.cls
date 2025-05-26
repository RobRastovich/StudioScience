public class CNT_SOI_Announcement {
    @AuraEnabled(cacheable=true)
    public static List<AnnouncementWrapper> getAnnouncementsRecords() {
        List<Announcement__c> announcements = SLT_SOI_Announcement.getAnnouncementsRecords();
        List<AnnouncementWrapper> accountWrapperList = new List<AnnouncementWrapper>();
        for (Integer i = 0; i < announcements.size() ; i++) {
            AnnouncementWrapper announcement = new AnnouncementWrapper();
            announcement.Id = announcements[i].Id;
            announcement.Message = announcements[i].Message__c;
            announcement.TypeOfRecord = announcements[i].Type__c;
            if (math.mod(i, 2) == 0) {
                announcement.CssClass = SOI_Constants.RED_BORDER;
            } else {
                announcement.CssClass = SOI_Constants.BLUE_BORDER;
            } 
            accountWrapperList.add(announcement);
        }
       return accountWrapperList;
    }

    public class AnnouncementWrapper {
        @AuraEnabled
        public Id Id{get;set;}
        @AuraEnabled
        public String Message{get;set;}
        @AuraEnabled
        public String TypeOfRecord{get;set;}
        @AuraEnabled
        public String CssClass{get;set;}
    }
}