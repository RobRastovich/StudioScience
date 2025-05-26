@isTest(SeeAllData=false)
public class FeedCommentTriggerHandlerTest {
	public static final String CASE_RT_GMDM= 'GMDM';
	public static id caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CASE_RT_GMDM).getRecordTypeId();
	public static testMethod void testFeedItemTrigger(){
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		User ownerUser = new User(Alias = 'beamow', Email='standardowner@testorg.com',
			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
			LocaleSidKey='en_US', ProfileId = p.Id,
			TimeZoneSidKey='America/Chicago', UserName='beamsuntorytestowner@test-user-system.com.test-only');
		User submitterUser = new User(Alias = 'beamsu', Email='standardsubmitter@testorg.com',
			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
			LocaleSidKey='en_US', ProfileId = p.Id,
			TimeZoneSidKey='America/Chicago', UserName='beamsuntorytestsubmitter@test-user-system.com.test-only');
		insert new List<User>{ownerUser, submitterUser};
		
		//Insert the root case
		System.runAs(submitterUser){
			Case c = new Case();
			c.Status = 'Logged';
			c.RecordTypeId = caseRTId;
			c.Submitter__c = submitterUser.Id;
			c.OwnerId = ownerUser.Id;
			insert c;
		}
		Case queriedCase = [SELECT Id, OwnerId, Status, New_Activity__c, Submitter__c FROM Case];

		//Insert the root post for comments to be added to
		System.runAs(ownerUser){
			FeedItem post = new FeedItem();
			post.ParentId = queriedCase.Id;
			post.Body = 'This is the source post';
			insert post;
		}
		queriedCase = [SELECT Id, OwnerId, Status, New_Activity__c, Submitter__c FROM Case];
		System.assertEquals(false, queriedCase.New_Activity__c);
		System.assertEquals('Logged', queriedCase.Status);

		List<FeedItem> relatedFeedItems = [SELECT Id FROM FeedItem WHERE ParentId =: queriedCase.Id];
		System.assertEquals(1, relatedFeedItems.size());

		Test.startTest();
		System.runAs(submitterUser){
			FeedComment comment = new FeedComment();
			comment.FeedItemId = relatedFeedItems[0].Id;
			comment.CommentBody = 'Submitter comment';
			insert comment;
		}

		queriedCase = [SELECT Id, OwnerId, Status, New_Activity__c FROM Case];
		queriedCase.OwnerId = ownerUser.Id;
		update queriedCase;

		System.runAs(ownerUser){
			FeedComment comment = new FeedComment();
			comment.FeedItemId = relatedFeedItems[0].Id;
			comment.CommentBody = 'Owner comment';
			insert comment;
		}
		queriedCase = [SELECT Id, OwnerId, Status, New_Activity__c FROM Case];
		System.debug(queriedCase);
		System.debug(ownerUser.Id);
		queriedCase.Status = 'Waiting on 3rd Party';
		update queriedCase;
		queriedCase = [SELECT Id, OwnerId, Status, New_Activity__c FROM Case];
		Test.stopTest();
	}
}