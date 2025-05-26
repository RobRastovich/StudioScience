public class EmailController {
    
    @InvocableMethod
    public static void sendHighballReminderEmail(list<EmailWrapper> lstEmailWrapper){
		Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();
        
        objEmail.setToAddresses(new list<String>{lstEmailWrapper[0].strRecipientEmail});
        
        objEmail.setCcAddresses(new list<String>{[select id, CcAddress from EmailMessage where Subject like '%Highball Activation - IO Code Notification%' and RelatedToId =:lstEmailWrapper[0].strRecipientId order by CreatedDate desc limit 1].CcAddress});
        
        objEmail.setTemplateId([SELECT Name FROM EmailTemplate WHERE Name = 'Highball BI Reminder' LIMIT 1].Id);
        
        objEmail.setTargetObjectId(lstEmailWrapper[0].strRecipientId);
        //objEmail.setTreatTargetObjectAsRecipient(false);
        
        Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {objEmail});
        if(!emailResult[0].isSuccess()){
            System.debug('Error :' +emailResult[0].getErrors());
        } else{
            System.debug('Success');
        } 
    }
}