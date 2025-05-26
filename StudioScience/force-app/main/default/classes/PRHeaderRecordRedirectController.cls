public class PRHeaderRecordRedirectController {
    
    @AuraEnabled
    public static String getDomainURL(){
        String URL= URL.getSalesforceBaseUrl().toExternalForm();
        return URL;
    }  
}