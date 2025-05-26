public class DTC_Utilities {
    public static Date AddBusinessDays(Date StartDate, integer BusinessDaysToAdd){
        Date finalDate;
        if(StartDate != null){
            finalDate = StartDate;
            integer direction = BusinessDaysToAdd < 0 ? -1 : 1;
            while(BusinessDaysToAdd != 0)
            {
                finalDate = finalDate.AddDays(direction);
                if (!isWeekendDay(finalDate)){
                    BusinessDaysToAdd -= direction;
                }
            }
        }
        return finalDate;
    }

    @testVisible
    private static Boolean IsWeekendDay(Date dateParam){
        boolean result = false;
        Date startOfWeek = dateParam.toStartOfWeek();
        Integer dayOfWeek = startOfWeek.daysBetween(dateParam);
        result = dayOfWeek == 0 || dayOfWeek == 6 ? true : false;
        return result;
    }

    public static Messaging.SingleEmailMessage createSingleEmailMessage(String templateName, String fromEmailAddress,
        List<String> toAddresses, Id emailWhatId) {
        OrgWideEmailAddress orgWideAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: fromEmailAddress LIMIT 1];
        EmailTemplate template = [SELECT Id, Name, Body, HtmlValue, Subject FROM EmailTemplate WHERE Name =: templateName LIMIT 1];        
        Messaging.SingleEmailMessage mail;
        if(orgWideAddress != null && template != null) {
            mail = Messaging.renderStoredEmailTemplate(template.Id, NULL, emailWhatId);
            mail.setToAddresses(toAddresses);
            mail.setOrgWideEmailAddressId(orgWideAddress.Id);
        }
        return mail;
    }

    public static void sendEmail(List<Messaging.SingleEmailMessage> mails) {
        if(mails != null && mails.size() > 0) {
            List<Messaging.SingleEmailMessage> mailsList = new List<Messaging.SingleEmailMessage>();
            List<String> toAddresses;
            for (Integer i = 0; i < mails.size(); i++) {
                mailsList.add(mails[i]);
            }
            if(!Test.isRunningTest()) {
                if(!mailsList.isEmpty()) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(mailsList);
                }
            }
        }
    }

    public static List<String> fetchGBSEmails() {
        DTC_Settings__c dtcSettings = DTC_Settings__c.getValues(DTC_Constants.GBS_EMAILS);
        List<String> emailsList = new List<String>();
        if (dtcSettings != null) {
            String dtcEmails = dtcSettings.Emails__c;
            if (dtcEmails != null) {
                if (dtcEmails.contains(',')) {
                    emailsList = dtcEmails.split(',');
                } else {
                    emailsList.add(dtcEmails);
                }
            }
        }
        if (!emailsList.isEmpty()) {
            return emailsList;
        } else {
            return null;
        }
    }
}