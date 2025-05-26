global class EmailToCaseCustom implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

        String body = email.plainTextBody == null? (email.htmlBody == null? '': email.htmlBody.stripHtmlTags()): email.plainTextBody;
        List<String> splitByNewLine = body.split('\n');

        String emailAddres;
        String submitterName;
        String emailSubject = email.subject;
        String emailBody = email.plainTextBody;

        for(String input: splitByNewLine){
            if(splitByNewLine != null){
                String delimiter = ':';
                String firstSplit = input.substringBefore(delimiter); 
                String lastSplit = input.substringAfter(delimiter);  
                if (firstSplit.contains('Email')){
                    emailAddres = lastSplit.split('<')[0].trim();
                }
                if (firstSplit.contains('Name')){
                    submitterName = lastSplit.trim();
                }
            }
        }


        list <Account> aCC = [select id, PersonContactId  from account where PersonEmail  =: emailAddres];
        Account a =  new Account();
        if (aCC.size() ==0){
                a.firstName = submitterName.split(' ')[0];
                a.lastName = submitterName.split(' ')[1];
                a.PersonEmail = emailAddres;
                a.RecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ConsumerAccount').getRecordTypeId();
                insert a; 
                a = [select id, PersonContactId  from account where id  =: a.id];
        }
        else {
            a = acc[0];
        }   

        case c = new case ();
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumer_Inquiry').getRecordTypeId();
        c.ContactId = a.PersonContactId;
        c.AccountId = a.id;
        c.Subject = emailSubject;
        c.SuppliedEmail = emailAddres;
        c.origin = 'email';
        c.brand__c = 'Maker\'s Mark';
        c.How_can_we_help__c = 'Ambassador Program';
        c.Description = emailBody;
        c.Ownerid = [select Id From Group Where DeveloperName='Maker_s_Mark' and Type = 'Queue'][0].id;// need query for the group by name.
        try{
            insert c;
            createEmailMessage( emailAddres,  emailSubject,  c.id,  body);

        }
        catch (Exception e) {
            String errorMessage = 'Error createEmailMessage ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('EmailToCaseCustom', 'handleInboundEmail', String.valueOf(errorMessage), 'Fatal');
        }
        return result;
    }

    @future
    public static void createEmailMessage(string emailAddres, string emailSubject, string parentId, string body) { 
        EmailMessage emailMessage = new EmailMessage();
        emailMessage.FromAddress = emailAddres;
        emailMessage.ToAddress = emailAddres;
        emailMessage.subject = emailSubject;
        emailMessage.ParentId = parentId;
        emailMessage.TextBody  = body;  
        try{
            insert emailMessage;
        }
        catch (Exception e) {
            String errorMessage = 'Error createEmailMessage ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('EmailToCaseCustom', 'createEmailMessage', String.valueOf(errorMessage), 'Fatal');
        }
    }
}