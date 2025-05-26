@isTest
private class TST_SLT_SOI_Announcement {
    @testSetup
    static void testDataSetup(){
        Announcement__c newAnnouncement = TST_TestDataFactory.createAnnouncement(false);
        newAnnouncement.Type__c = SOI_Constants.INNOVATION_TYPE;
        insert newAnnouncement;
    }

    @isTest
    private static void testgetAnnouncementsRecords() {
        List<Announcement__c> announcementList = new List<Announcement__c>();
        
        Test.startTest();
            announcementList = SLT_SOI_Announcement.getAnnouncementsRecords();
        Test.stopTest();

        System.assertEquals(true, announcementList.size() > 0, 'Should return Announcement records');
        System.assertEquals('This is the test Message', announcementList[0].Message__c,
            'Message value should be This is the test Message');
    }
}