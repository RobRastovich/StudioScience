public class SLT_SBP_SBP_Approvers_CS {
    public static String getUsernameOfApprovers(String brand){
        String username;
        List<SBP_Approvers__c> brandApprovers = new List<SBP_Approvers__c>();
        if(!String.isEmpty(brand)){
            brandApprovers = [SELECT ID, Brand__c, State__c, Username__c
                              FROM SBP_Approvers__c
                              WHERE Brand__c =: brand
                              AND
                              Username__c != null];
            username = brandApprovers.size()>0  ? String.valueOf(brandApprovers[0].Username__c) : null; 
        }
        
        return username;
    }
}