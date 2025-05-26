@IsTest(SeeAllData = false)
public class FeedItemTriggerHandlerTest {
    public static final String CASE_RT_GMDM = 'GMDM';
    public static id caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CASE_RT_GMDM).getRecordTypeId();

    public static testMethod void caseFeedCreatedByOwnerOfCaseTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User submitterUser = new User(Alias = 'beamsu', Email = 'standardsubmitter@testorg.com',
                                      EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                                      LocaleSidKey = 'en_US', ProfileId = p.Id,
                                      TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestsubmitter@test-user-system.com.test-only');
        insert submitterUser;

        Case c = new Case();
        caseServices.runTrigger = false;

        Test.startTest();

        // create case, gets routed to queue
        System.runAs(submitterUser) {
            c.Status = 'Logged';
            c.RecordTypeId = caseRTId;
            c.Submitter__c = submitterUser.Id;
            insert c;
        }

        // update case to submitter as the owner
        caseServices.runTrigger = false;
        Case updatedCase = [SELECT Id, OwnerId, Status, New_Activity__c, Submitter__c FROM Case where Id = :c.Id LIMIT 1];
        updatedCase.OwnerId = submitterUser.Id;
        update updatedCase;

        System.runAs(submitterUser) {
            FeedItem post = new FeedItem();
            post.ParentId = updatedCase.Id;
            post.Body = 'This is the submitter\'s post';
            insert post;
        }

        Case updatedCase2 = [SELECT Id, OwnerId, Status, New_Activity__c, Submitter__c FROM Case where Id = :updatedCase.Id LIMIT 1];
        Test.stopTest();
        System.assertEquals(false, updatedCase2.New_Activity__c, 'Activity Flag should be set to false');
    }

    public static testMethod void caseFeedCreatedBySubmitterOfCaseTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User ownerUser = new User(Alias = 'beamow', Email = 'standardowner@testorg.com',
                                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                                  LocaleSidKey = 'en_US', ProfileId = p.Id,
                                  TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestowner@test-user-system.com.test-only');
        User submitterUser = new User(Alias = 'beamsu', Email = 'standardsubmitter@testorg.com',
                                      EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                                      LocaleSidKey = 'en_US', ProfileId = p.Id,
                                      TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestsubmitter@test-user-system.com.test-only');
        insert new List<User> {ownerUser, submitterUser};

        Case c = new Case();
        caseServices.runTrigger = false;

        Test.startTest();

        //Insert the root case
        System.runAs(ownerUser) {
            c.Status = 'Logged';
            c.RecordTypeId = caseRTId;
            insert c;
        }

        caseServices.runTrigger = false;
        Case updatedCase = [SELECT Id, OwnerId, Status, New_Activity__c, Submitter__c, CreatedById FROM Case where Id = :c.Id LIMIT 1];
        updatedCase.Submitter__c = submitterUser.Id;
        updatedCase.OwnerId = ownerUser.Id;
        update updatedCase;

        FeedItem post = new FeedItem();
        System.runAs(submitterUser) {
            post.ParentId = updatedCase.Id;
            post.Body = 'This is the submitter\'s post';
            insert post;
        }

        Case updatedCase2 = [SELECT Id, OwnerId, Status, New_Activity__c, Submitter__c, CreatedById FROM Case where Id = :updatedCase.Id LIMIT 1];
        Test.stopTest();

        System.assertEquals(ownerUser.Id, updatedCase2.CreatedById, 'Case creator should be the owneruser');
        System.assertEquals(submitterUser.Id, updatedCase2.Submitter__c, 'Case submitter should be the submitterUser');
        System.assertEquals(true, updatedCase2.New_Activity__c, 'Activity Flag should be set to true');
        System.assertEquals('In Progress', updatedCase2.Status, 'Status should be In Progress');
    }
}