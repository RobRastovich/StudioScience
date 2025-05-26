public class SLT_LSB_EmailTemplate {
    public static List<EmailTemplate> getEmailTemplateList(String developerName) {
        List<EmailTemplate> returnList = new List<EmailTemplate>();
        returnList = [SELECT Id, Subject, HtmlValue, DeveloperName, Body 
                                            FROM EmailTemplate 
                                            WHERE DeveloperName =: developerName
                                            LIMIT 1];
        return returnList;
    }
}