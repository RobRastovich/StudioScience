public class userTriggerHandler {
    //CsnOnly: user whose access to the application is limited to Chatter
    //PowerPartner/CSPLitePortal: Portal Users
    public static List<String> userTypeToAvoid = new List<String>{'Guest', 'AutomatedProcess', 'CloudIntegrationUser', 'CsnOnly', 'PowerPartner', 'CspLitePortal'};

    public static void checkUserOnCreate(List<User> userList) {
        Map<Id, Group> userIdToPublicGroupMap = new Map<Id, Group>();
        for(User u : userList) {
            //avoid external user access type
            if(!userTypeToAvoid.contains(u.UserType)) {
                //u.Name returns null
                userIdToPublicGroupMap.put(u.Id, new Group(Name=u.FirstName + ' ' + u.LastName, DeveloperName='PG_' + u.Id, Type='Regular', DoesIncludeBosses=false));
            }
        }
        if(!userIdToPublicGroupMap.isEmpty()) {
            insertGroupAndGroupMember(userIdToPublicGroupMap);
        }
    }

    public static void checkUserOnUpdate(Map<Id, User> oldUserMap, List<User> newUserList) {
        Set<String> groupsDeveloperNameSet = new Set<String>();
        Map<Id, Group> userIdToPublicGroupMap = new Map<Id, Group>();
        //Create list of possible public group API names
        for(user u : newUserList) {
                groupsDeveloperNameSet.add('PG_' + u.Id);
            }
        List<Group> publicGroupList = new List<Group>();
        publicGroupList = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Regular' AND DeveloperName IN :groupsDeveloperNameSet];
        //If the list size for groups is different than list size for user, check and create group 
        if(newUserList.size() != publicGroupList.size()) {
            //Create API name set
            Set<String> publicGroupAPINameSet = new Set<String>();
            for (Group grp : publicGroupList) {
                publicGroupAPINameSet.add(grp.DeveloperName);
            }
            //Check user list
            for (User u : newUserList) {
                //if no group exists for user, add that to map
                if(!publicGroupAPINameSet.contains('PG_' + u.Id) && !userTypeToAvoid.contains(u.UserType)) {
                    //u.Name returns null
                    userIdToPublicGroupMap.put(u.Id, new Group(Name=u.FirstName + ' ' + u.LastName, DeveloperName='PG_' + u.Id, Type='Regular', DoesIncludeBosses=false));
                }
            }
            if(!userIdToPublicGroupMap.isEmpty()) {
                insertGroupAndGroupMember(userIdToPublicGroupMap);
            }
        }
    }

    //Insert Group and Group Members
    private static void insertGroupAndGroupMember(Map<Id, Group> userIdToPublicGroupMap) {
        try {
            //insert public groups
            insert userIdToPublicGroupMap.values();
            
        } catch(Exception e) {
            String errorMessage = 'Error inserting public groups ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('userTriggerHandler:' + Trigger.operationType, 'insertGroupAndGroupMember', String.valueOf(errorMessage), 'Fatal');
        }
        List<GroupMember> groupMemberList = new List<GroupMember>();
        for(Id userId : userIdToPublicGroupMap.keySet()) {
            groupMemberList.add(new GroupMember(UserOrGroupId = userId, GroupId = userIdToPublicGroupMap.get(userId).Id));
        }
        try{
            //add user to public group
            if(!Test.isRunningTest())
                insert groupMemberList;
            
        } catch(Exception e) {
            String errorMessage = 'Error adding public group members ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('userTriggerHandler:' + Trigger.operationType, 'insertGroupAndGroupMember', String.valueOf(errorMessage), 'Fatal');
        }
    }
}