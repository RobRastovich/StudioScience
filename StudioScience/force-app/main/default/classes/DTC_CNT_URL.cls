public class DTC_CNT_URL {
    public static Id caseNum{get;set;}
    public static String getCommunityURLOrg(){
         List<Site> siteId= [SELECT Id, name FROM Site WHERE name= 'Beam_Suntory_Customer_Community_C'];
         String communityURL= [SELECT SecureURL FROM SiteDetail WHERE DurableId =: siteId.get(0).Id].SecureUrl;
         return communityURL+'/dhlcases?Id='+caseNum;
    } 
    
    public static String getCaseNumber(){
        Case caseObj= [SELECT CaseNumber FROM Case WHERE Id=: caseNum];
        return caseObj.CaseNumber;
    }
}