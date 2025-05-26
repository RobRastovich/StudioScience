public class SLT_Profile {
    public static List<Profile> getProfileDetail(String profileId){
        List<Profile> lstProfile = [SELECT 
                                    Id, Name
                                    FROM
                                    Profile
                                    WHERE
                                    Id =: profileId
                                    LIMIT 1];
        return lstProfile;
    }
}