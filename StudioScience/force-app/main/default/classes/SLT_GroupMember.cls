public class SLT_GroupMember {
        /**
    *  @description : This method is use to fetch Group Member records by given pulic group dev. name(CRM).
    *  @args        : String, String 
    *  @return      : List<GroupMember>
    **/
    public static List<GroupMember> getMemberRecordFromGivenGroup(String publicGroupDevName, String userId){
        List <GroupMember> members = new List<GroupMember>();
        members = [SELECT ID, UserOrGroupId 
                      FROM GroupMember
                      WHERE GroupId IN(SELECT ID From GROUP Where DeveloperName =: publicGroupDevName)
                      AND UserOrGroupId =: userId];
        return members;
    }
}