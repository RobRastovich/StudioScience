public class SLT_DTC_Email {
    public static List<EmailMessage> getEmailList(List<Case> newCases) {
        Set<String> companyEmailSet = DTC_Constants.COMPANY_MAIL_SET;
        List<EmailMessage> returnList = [SELECT Id, FromAddress, ParentId 
                                            FROM EmailMessage 
                                            WHERE FromAddress NOT IN : companyEmailSet 
                                            AND ParentId IN : newCases];
        return returnList;
    }
}