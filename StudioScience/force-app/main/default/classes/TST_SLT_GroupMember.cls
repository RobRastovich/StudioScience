@isTest
private class TST_SLT_GroupMember {
    @testSetup
    static void dataSetup() {
        Group grp = new Group();
        grp.name = 'Test Group1';
        grp.DeveloperName = 'ABC';
        grp.Type = 'Regular'; 
        Insert grp; 
 
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = UserInfo.getUserId();
        grpMem1.GroupId = grp.Id;
        Insert grpMem1;
    }
   
    @isTest
    private static void testGetMemberRecordFromGivenGroup() {
    	Group grpRecord = [SELECT Id, DeveloperName 
                              FROM Group 
                              WHERE DeveloperName = 'ABC'];
        String UserId = UserInfo.getUserId();
        
        Test.startTest();
        	List<GroupMember> grpMemberList = SLT_GroupMember.getMemberRecordFromGivenGroup(grpRecord.DeveloperName, 
                                                                                           	   UserId);
        Test.stopTest();
		
        System.assertEquals(true, grpMemberList.size()>0, 'It should contain group Members');
    }
}