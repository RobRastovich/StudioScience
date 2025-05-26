public class SLT_User {
    public static List<User> getUserDetail(String userId){
        List<User> lstUserDetail = [SELECT
                                    Id, UserName, Access_Group__c, ProfileId, LanguageLocaleKey, ContactId 
                                    FROM 
                                    User
                                    WHERE
                                    Id =: userId
                                    LIMIT 1];
        return lstUserDetail;
    }

    //Added By Nishant Khandal LSB-7
    public static List<User> getUserDetailUsername(String username){
        List<User> lstUserDetail = new List<User>();
        lstUserDetail = [SELECT
                            Id, Username, FirstName, LastName, Name
                            FROM 
                            User
                            WHERE
                            UserName =: UserName
                            LIMIT 1];
        return lstUserDetail;
    }
}