/**
 * class for SAL-1871
 * @author Sangeet
 */
public class SurveyQuestionResponseAfterInsertAction2 {
	
    /**************************************************************************************************************
    Method name:    surveyQuestionResponseAfterInsert
    Object:         SurveyQuestionResponse
    Event:          after insert
    Date:           1/2022
    ***************************************************************************************************************/
    @InvocableMethod(label='After Insert SurveyQuestionResponse1' description='Triggers email to Survery Questions with rating less than equal to 2' category= 'SurveyQuestionResponse')
    public static void surveyQuestionResponseAfterInsert1(List<SurveyQuestionResponse> newSurveyQuestionResponses)
    {
        system.debug('coming in class -----');
        List<Id> csSurveyInvitationIds = new List<Id>();
        for(SurveyQuestionResponse item : newSurveyQuestionResponses){
            if(item.DataType.equals('Number') && (item.ResponseValue.equals('1') || item.ResponseValue.equals('2'))){
            	csSurveyInvitationIds.add(item.InvitationId);
            }
        }
       
        
        
        List<Id> csSurveyIds = new List<Id>();
        for(Survey s : [SELECT Id from Survey where name IN ('Customer Satisfaction Survey')]){
            csSurveyIds.add(s.Id);
        }
      	List<SurveyInvitation> csSurveyInvitations = [SELECT id, Case__c, Email__c, ParticipantId, Survey_Submitter__c FROM SurveyInvitation where ID in : csSurveyInvitationIds
                                                      AND SurveyId IN : csSurveyIds];
        Map<Id, SurveyInvitation> casesToSendEmail = new Map<Id, SurveyInvitation>();
        
        System.debug('csSurveyInvitations' + csSurveyInvitations);
        
        for(SurveyInvitation obj : csSurveyInvitations){
            casesToSendEmail.put(obj.Case__c, obj);
        }
        System.debug('casesToSendEmail '+ casesToSendEmail);
        
        if (!casesToSendEmail.isEmpty()) {
            sendEmails(casesToSendEmail);
        }
                                       
    }

    
    public static void sendEmails(Map<Id, SurveyInvitation> casesToSendEmail) {
        
        String csEmailAddress = SBP_Constants.PROD_EMAIL_SERVICE_ADDRESS;
        OrgWideEmailAddress csEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :csEmailAddress LIMIT 1];
        
        EmailTemplate template = [SELECT Id, Subject, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName = 'QualityClaimNegative' LIMIT 1];
        
        List<Case> cases = [SELECT Id, SuppliedEmail, caseNumber,SuppliedName, Thread_Id__c FROM Case WHERE Id IN : casesToSendEmail.keySet()];
        Map<Id,Case>caseToMap = new Map<Id,Case>([SELECT Id, SuppliedEmail, caseNumber,SuppliedName, Thread_Id__c FROM Case WHERE Id IN : casesToSendEmail.keySet()]);
        System.debug(cases);
        
        String profileId = UserInfo.getProfileId();
        Set<String> profileRestricted= new Set<String>();
        for(Profile profile: [Select Id, Name from Profile where Id=:profileId AND Name in ('Beam Suntory Customer Community Profile') ]){
            profileRestricted.add(profile.Name);
            system.debug('ProfileName'+profile.Name);
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage singleMail;
        for (Case c : cases) {
            String htmlBody = template.HtmlValue;
            String thread_Id = c.Thread_Id__c;
            String caseNumber='';
            if(casesToSendEmail.get(c.Id).Case__c!=null)
            {
             caseNumber=caseToMap.get(casesToSendEmail.get(c.Id).Case__c).caseNumber;
            }
                       
           
            
            htmlBody = htmlBody.replace('{caseNum}', caseNumber);
        
            
            System.debug('html body ->>>' + htmlBody);
            
            
            singleMail = new Messaging.SingleEmailMessage();

            if(profileRestricted.isEmpty()){
              
            }
            singleMail.setHtmlBody(htmlBody);
            singleMail.setTargetObjectId(casesToSendEmail.get(c.Id).ParticipantId);
            String templateSubject = template.Subject.replace('{caseNum}', caseNumber);
            singleMail.setSubject(templateSubject);
            String[] toAddresses = new String[]{'dawn.masterson@beamsuntory.com','dionicia.sandoval@beamsuntory.com','elizabeth.tubbergen@beamsuntory.com'};
            
            singleMail.setToAddresses(toAddresses);
            singleMail.setTemplateId(template.Id);
            singleMail.setWhatId(c.Id);
            singleMail.setTreatTargetObjectAsRecipient(false);
            singleMail.setSaveAsActivity(false);
            singleMail.setReplyTo(csEmailAddress);
            emails.add(singleMail);
        }
        List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(emails);
    }

}