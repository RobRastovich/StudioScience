@isTest
private class TST_CNT_SOI_Announcement {
    @testSetup
    static void testDataSetup() {
        List<Announcement__c> announcementRecords = new List<Announcement__c>();
        Announcement__c announcementRecord1 = TST_TestDataFactory.createAnnouncement(false);
        announcementRecord1.Type__c = SOI_Constants.INNOVATION_TYPE;
        Announcement__c announcementRecord2 = TST_TestDataFactory.createAnnouncement(false);
        announcementRecord2.Message__c = 'This is another test Message';
        announcementRecord2.Type__c = SOI_Constants.INNOVATION_TYPE;
        announcementRecords.add(announcementRecord1);
        announcementRecords.add(announcementRecord2);
        insert announcementRecords;
    }
    
    @isTest
    private static void testGetAnnouncementsRecords() {
        List<CNT_SOI_Announcement.AnnouncementWrapper> announcementWrapperList =
            new List<CNT_SOI_Announcement.AnnouncementWrapper>();
        
        Test.startTest();
            announcementWrapperList = CNT_SOI_Announcement.getAnnouncementsRecords();
        Test.stopTest();
        
        System.assertEquals(true, announcementWrapperList.size() > 0, 'It should return Announcement Record list');
    }
}