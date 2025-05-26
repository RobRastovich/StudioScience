public without sharing class TimeRemainingCmpApexController {
    @AuraEnabled
    public static String getPOSRecordBrand(String recordId) {
        String titleLabel = null;
        try {
            if(!String.isEmpty(recordId)){
                String objectType = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
                if (objectType != null && objectType == SBP_Constants.CASE_STRING) {
                    Case recordCase = SLT_Case.getCaseByID(recordId);
                    titleLabel = recordCase.Brand__c;
                }
            }
            
        } catch (Exception e) {
            return null;
        }
        return titleLabel;
    }
    @AuraEnabled
    public static void sendEmail(String recordId){
        try {
            if(!String.isEmpty(recordId) || recordId != null) {
                
                EmailTemplate laphroaigEmailTemplate = SLT_LSB_EmailTemplate.getEmailTemplateList(
                    SBP_Constants.LAPHROAIG_TRIP_AND_TOUR_TIMER_EXPIRED_TEMPLATE)[0];
                Account_Application__c app = SLT_Account_Application.getAccountApplicationByCaseId(recordId);
                List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                if(app != null ) {
                    List<String> emailsToSendTo = new List<String>();
                    Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
                    singleMail.setTargetObjectId(app.Submitter__c);
                    singleMail.setTemplateId(laphroaigEmailTemplate.Id);
                    singleMail.setWhatId(app.Id);
                    singleMail.setSaveAsActivity(false);
                    singleMail.setReplyTo(SBP_Constants.CUSTOMER_SERVICE_EMAIL_ID);
                    singleMail.setSenderDisplayName(SBP_Constants.CUSTOMER_SERVICE_EMAIL_DISPLAY_NAME);
                    singleMail.setUseSignature(false);
                    emails.add(singleMail);
                }
                List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(emails);
                
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}