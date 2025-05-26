/**************************************************************************************
Apex Class Name     : SurveyQuestionResponseAfterInsertAction
Created Date        : 8/2021
Function            : Triggers email to Survey submitter when Survery Question Response with rating less than equal to 2
*************************************************************************************/
public class SurveyQuestionResponseAfterInsertAction {
	/**************************************************************************************************************
    Method name:    surveyQuestionResponseAfterInsert
    Object:         SurveyQuestionResponse
    Event:          after insert
    Date:           8/2021
    ***************************************************************************************************************/
    @InvocableMethod(label='After Insert SurveyQuestionResponse' description='Triggers email to Survery Questions with rating less than equal to 2' category= 'SurveyQuestionResponse')
    public static void surveyQuestionResponseAfterInsert(List<SurveyQuestionResponse> newSurveyQuestionResponses)
    {
        List<Id> csSurveyInvitationIds = new List<Id>();
        for(SurveyQuestionResponse item : newSurveyQuestionResponses){
            if(item.DataType.equals('Number') && (item.ResponseValue.equals('1') || item.ResponseValue.equals('2'))){
            	csSurveyInvitationIds.add(item.InvitationId);
            }
        }
        //Step- 0 get Survey id of Survey 'CS Customer Survey Changes'
        //Step -1 get those SurveyInvitations which have these ids and where SurveyName is like %CS Customer Survey Changes%
        //Step-2 filter out SurveyQuestionReponse which have SurveyInvitations with the above SurveyInvitationids
        //Step-3 Create new Map of type <Id, SurveyInvitation>
        //Step-4 get cases attached on SurveyInvitation list and add to map created above
        //Step-5 pass those caseids to sendEmail method
        
        
        List<Id> csSurveyIds = new List<Id>();
        for(Survey s : [SELECT Id from Survey where name IN ('CS Customer Survey Changes', 'CS Customer Survey Escalated Form')]){
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
        
        EmailTemplate template = [SELECT Id, Subject, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName = 'CS_Survey_Negative_Feedback_Email_Template' LIMIT 1];
        
        List<Case> cases = [SELECT Id, SuppliedEmail, SuppliedName, Thread_Id__c FROM Case WHERE Id IN : casesToSendEmail.keySet()];
        
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
            String submitterName = casesToSendEmail.get(c.Id).Survey_Submitter__c;
                       
            /*if(String.isNotBlank(c.Submitter_Name__c)){
                submitterName = c.Submitter_Name__c;
            }
            else if(String.isNotBlank(c.Contact_Name__c)){
                submitterName = c.Contact_Name__c;
            }
            else if(String.isNotBlank(c.SuppliedName)){
                submitterName = c.SuppliedName;
            }
            else{
                submitterName = 'Customer';
            }
			*/
            
            System.debug('submitterName ' + submitterName);
            
            htmlBody = htmlBody.replace('{Customer}', submitterName);
            htmlBody = htmlBody.replace('{!Case.Thread_Id}', thread_Id);
            
            System.debug('html body ->>>' + htmlBody);
            
            
            singleMail = new Messaging.SingleEmailMessage();

            if(profileRestricted.isEmpty()){
                singleMail.setOrgWideEmailAddressId(csEmail.Id);
            }
            singleMail.setHtmlBody(htmlBody);
            singleMail.setTargetObjectId(casesToSendEmail.get(c.Id).ParticipantId);
            singleMail.setSubject(template.Subject + ' ['+ thread_Id + ']');
            singleMail.setToAddresses(new String[]{casesToSendEmail.get(c.Id).Email__c});
            singleMail.setTemplateId(template.Id);
            singleMail.setWhatId(c.Id);
            singleMail.setSaveAsActivity(false);
            singleMail.setReplyTo(csEmailAddress);
            emails.add(singleMail);
        }
        List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(emails);
    }
}