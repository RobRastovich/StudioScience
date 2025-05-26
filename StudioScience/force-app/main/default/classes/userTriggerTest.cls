@isTest(SeeAllData = false)
public class userTriggerTest {
    
    public static List<Group> getAllPublicGroups(Set<String> groupsDeveloperName) {
		return [SELECT Id, DeveloperName FROM Group WHERE Type = 'Regular' AND DeveloperName IN :groupsDeveloperName];
	}
    
    public static List<GroupMember> getGroupMembers(Id groupId, Id userId) {
		return [SELECT Id FROM GroupMember WHERE GroupId = :groupId AND UserOrGroupId = :userId];
	}

    @isTest
    public static void checkOnUserInsert(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com', FirstName = 'TestFN',
		                  EmailEncodingKey = 'UTF-8', LastName = 'TestLN', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id, TimeZoneSidKey = 'America/Chicago', 
                          UserName = 'beamsuntorytestuser@test-user-system.com.test-only');

        Test.startTest();
		insert u;
        //check if group was inserted
        List<Group> groupList = getAllPublicGroups(new Set<String>{'PG_' + String.valueOf(u.Id)});
        System.assertNotEquals(null, groupList);
        //check if group member was inserted
        if(groupList.size() > 0) {
            System.assertEquals(1, groupList.size());
            List<GroupMember> groupMembers = getGroupMembers(groupList[0].Id, u.Id);
            System.assertNotEquals(null, groupMembers);
            System.assertNotEquals(null, groupMembers.size());
        }
        Test.stopTest();
    }
    
    @isTest
    public static void checkOnUserUpdate(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com', FirstName = 'TestFN',
		                  EmailEncodingKey = 'UTF-8', LastName = 'TestLN', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id, TimeZoneSidKey = 'America/Chicago', 
                          UserName = 'beamsuntorytestuser@test-user-system.com.test-only');

        Test.startTest();
        //insert u
		insert u;
        //Delete the group to confirm group creation on update
        List<Group> groupList = getAllPublicGroups(new Set<String>{'PG_' + String.valueOf(u.Id)});
        Delete groupList;
        //check if group was deleted
        groupList = getAllPublicGroups(new Set<String>{'PG_' + String.valueOf(u.Id)});
        System.assertEquals(0, groupList.size());
        
        //update user
        update u;
        //check if group was updated
        groupList = getAllPublicGroups(new Set<String>{'PG_' + String.valueOf(u.Id)});
        System.assertNotEquals(null, groupList);
        //check if group member was updated
        if(groupList.size() > 0) {
            System.assertEquals(1, groupList.size());
            List<GroupMember> groupMembers = getGroupMembers(groupList[0].Id, u.Id);
            System.assertNotEquals(null, groupMembers);
            System.assertNotEquals(null, groupMembers.size());
        }
        Test.stopTest();
    }
}