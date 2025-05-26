public class GBS_MultipleLanguageEmailController {

    public GBS_MultipleLanguageEmailController() {
        
    }

    public String emailRelatedToId {get; set;}
    public Id emailWhoId {get; set;}
    public String emailTemplateDeveloperName {get; set;}
    public Boolean isHtml {get; set;}

    public EmailTemplate emailTemplate {
        get{
            List<String>Templates = new List<String>();
            Templates = emailTemplateDeveloperName.split('-');
            Case Caserec = new Case();
            Caserec = [SELECT ID,Origin FROM Case WHERE Id=:emailRelatedToId ];
            if (emailTemplate == null) {
                if(Caserec.Origin=='Outlook'){
                    emailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = : Templates[1] LIMIT 1];
             
                }
                else{
                    emailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = : Templates[0] LIMIT 1];
                }
            }
            return emailTemplate;
        }
        set;
    }

    private Messaging.SingleEmailMessage renderedEmail {
        get {
            if (renderedEmail == null) {
                renderedEmail = Messaging.renderStoredEmailTemplate(emailTemplate.Id, emailWhoId, emailRelatedToId);
            }
            return renderedEmail;
        }
        set;
    }

    public String getMergedEmailHtmlBody() {
        return renderedEmail.getHtmlBody();
    }

    public String getMergedEmailPlainTextBody() {
        return renderedEmail.getPlainTextBody();
    }

    public String getMergedEmailSubject() {
        return renderedEmail.getSubject();
    }
}