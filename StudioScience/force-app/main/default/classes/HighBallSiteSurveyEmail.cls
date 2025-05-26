/**********************************************************************************************************************
Apex Class Name     : HighBallSiteSurveyEmail
Created Date        : 3/2023
Function            : Once site survey is completed on the HighBall object then send an email to Local BSI Contact, 
Highball Specialist, Highball team and 3rd party
**************************************************************************************************************************/
public class HighBallSiteSurveyEmail {
    
    @InvocableMethod(label='Send Site Survey Email' description='Send an email to Local BSI Contact,Highball Specialist, Highball team and 3rd party')
    public static void sendEmail(List<Id> highBallIds) {            
        EmailTemplate template = [SELECT Id,Name,Subject,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName ='HighBall_Site_Survey_Email_Template' limit 1];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<EmailMessage> emailRecords = new List<EmailMessage>();
        List<String> emailsToSendTo = new List<String>();   
        
        List<Highball__c>  highBallRec = [select id, Local_BSI_Contact__r.FirstName,Local_BSI_Contact__r.LastName,Local_BSI_Contact__r.Phone,
                                          Highball_Specialist__r.FirstName,Highball_Specialist__r.LastName,Spirits_Brand__c,Type_of_Technology__c,
                                          No_of_Machines__c,Type_of_Tower__c,Account__r.Name,Account_Address__c,Account_City__c,Account_State__c,
                                          Account__r.BillingPostalCode,Contact__r.Name,Site_Survey_Request_Date_1__c,Site_Survey_Request_Date_2__c,
                                          Site_Survey_Request_Date_3__c,Available_Hours_for_Site_Survey__c,Buyer_Contact__r.Name,Local_BSI_Contact__r.Email,
                                          Highball_Specialist__r.Email,Account__r.Account_Territory__c,Contact__r.Email,Contact__r.Phone,Buyer_Contact__r.Email,
                                          Buyer_Contact__r.Phone from Highball__c where Id IN:highBallIds]; 
        Highball_Email__mdt highballEmails = UserInfo.getOrganizationId() == CSConstants.PRODUCTION_ORGANIZATION_ID ? Highball_Email__mdt.getInstance('Production'):Highball_Email__mdt.getInstance('Sandbox') ;
        for(Highball__c higball : highBallRec){           
            if (!String.isEmpty(higball.Local_BSI_Contact__r.Email)){
                emailsToSendTo.add(higball.Local_BSI_Contact__r.Email);
            }
            if (!String.isEmpty(higball.Highball_Specialist__r.Email)){
                emailsToSendTo.add(higball.Highball_Specialist__r.Email);
            }
            if(!String.isEmpty(higball.Account__r.Account_Territory__c) && higball.Account__r.Account_Territory__c == 'NO CALIFORNIA'){
                emailsToSendTo.addAll(highballEmails.NO_CALIFORNIA_Email__c.split(','));
                
            }
            if(!String.isEmpty(higball.Account__r.Account_Territory__c) && higball.Account__r.Account_Territory__c == 'SO CALIFORNIA'){
                emailsToSendTo.addAll(highballEmails.SO_CALIFORNIA_Email__c.split(','));
                
               
            }
            if(!String.isEmpty(higball.Account__r.Account_Territory__c) && (higball.Account__r.Account_Territory__c == 'OREGON' || higball.Account__r.Account_Territory__c == 'WASHINGTON')){
                emailsToSendTo.addAll(highballEmails.OREGON_WASHINGTON_Email__c.split(','));
                 
            }
            //Highball Team
            emailsToSendTo.addAll(highballEmails.Others__c.split(','));

           
            
            String subject = template.Subject;            
            String htmlBody = template.HtmlValue;
            htmlBody = htmlBody.replace('<p> : </p>','');  
            if(higball.Local_BSI_Contact__r.FirstName == null || higball.Local_BSI_Contact__r.LastName == null ||
               higball.Local_BSI_Contact__r.Email == null){                  
                   htmlBody = htmlBody.replace('{!Highball__c.Local_BSI_Contact__r.FirstName}', '')+'<br/>';
                   htmlBody = htmlBody.replace('{!Highball__c.Local_BSI_Contact__r.LastName}', '')+'<br/>';
                   htmlBody = htmlBody.replace('{!Highball__c.Local_BSI_Contact__r.Email}', '')+'<br/>';                 
               }else{                 
                   htmlBody = htmlBody.replace('{!Highball__c.Local_BSI_Contact__r.FirstName}', higball.Local_BSI_Contact__r.FirstName)+'<br/>'; 
                   htmlBody = htmlBody.replace('{!Highball__c.Local_BSI_Contact__r.LastName}',  higball.Local_BSI_Contact__r.LastName)+'<br/>';
                   htmlBody = htmlBody.replace('{!Highball__c.Local_BSI_Contact__r.Email}', higball.Local_BSI_Contact__r.Email)+'<br/>';                   
               } 
            if(higball.Local_BSI_Contact__r.Phone == null){
                htmlBody = htmlBody.replace('{!Highball__c.Local_BSI_Contact__r.Phone}', '')+'<br/>';
            }else{           
                htmlBody = htmlBody.replace('{!Highball__c.Local_BSI_Contact__r.Phone}', higball.Local_BSI_Contact__r.Phone)+'<br/>'; 
            }
            if(higball.Highball_Specialist__r.FirstName == null || higball.Highball_Specialist__r.LastName == null || 
               higball.Highball_Specialist__r.Email == null){
                   htmlBody = htmlBody.replace('{!Highball__c.Highball_Specialist__r.FirstName}', '')+'<br/>';
                   htmlBody = htmlBody.replace('{!Highball__c.Highball_Specialist__r.LastName}', '')+'<br/>';
                   htmlBody = htmlBody.replace('{!Highball__c.Highball_Specialist__r.Email}', '')+'<br/>';
               }else{
                   htmlBody = htmlBody.replace('{!Highball__c.Highball_Specialist__r.FirstName}', higball.Highball_Specialist__r.FirstName)+'<br/>';
                   htmlBody = htmlBody.replace('{!Highball__c.Highball_Specialist__r.LastName}', higball.Highball_Specialist__r.LastName)+'<br/>';
                   htmlBody = htmlBody.replace('{!Highball__c.Highball_Specialist__r.Email}', higball.Highball_Specialist__r.Email)+'<br/>';
               }
            htmlBody = htmlBody.replace('{!Highball__c.Spirits_Brand__c}', higball.Spirits_Brand__c)+'<br/>';
            htmlBody = htmlBody.replace('{!Highball__c.Type_of_Technology__c}', higball.Type_of_Technology__c)+'<br/>';
            htmlBody = htmlBody.replace('{!Highball__c.No_of_Machines__c}', higball.No_of_Machines__c.format())+'<br/>';
            if(higball.Type_of_Tower__c == null){
                htmlBody = htmlBody.replace('{!Highball__c.Type_of_Tower__c}', '')+'<br/>';
            }else{
                htmlBody = htmlBody.replace('{!Highball__c.Type_of_Tower__c}', higball.Type_of_Tower__c)+'<br/>';
            }          
            htmlBody = htmlBody.replace('{!Highball__c.Account__r.Name}', higball.Account__r.Name)+'<br/>';
            htmlBody = htmlBody.replace('{!Highball__c.Account_Address__c}', higball.Account_Address__c)+'<br/>';
            htmlBody = htmlBody.replace('{!Highball__c.Account_City__c}', higball.Account_City__c)+'<br/>';
            htmlBody = htmlBody.replace('{!Highball__c.Account_State__c}', higball.Account_State__c)+'<br/>';
            htmlBody = htmlBody.replace('{!Highball__c.Account__r.BillingPostalCode}', higball.Account__r.BillingPostalCode)+'<br/>';
            if(higball.Contact__r.Name == null){
                htmlBody = htmlBody.replace('{!Highball__c.Contact__r.Name}', '')+'<br/>';
            }else{
                htmlBody = htmlBody.replace('{!Highball__c.Contact__r.Name}', higball.Contact__r.Name)+'<br/>';
            }			
            if(higball.Contact__r.Email == null){
                htmlBody = htmlBody.replace('{!Highball__c.Contact__r.Email}', '')+'<br/>';
            }else{
                htmlBody = htmlBody.replace('{!Highball__c.Contact__r.Email}', higball.Contact__r.Email)+'<br/>';
            }			
            if(higball.Contact__r.Phone == null){
                htmlBody = htmlBody.replace('{!Highball__c.Contact__r.Phone}', '')+'<br/>';
            }else{
                htmlBody = htmlBody.replace('{!Highball__c.Contact__r.Phone}', higball.Contact__r.Phone)+'<br/>';
            }			
            if(higball.Buyer_Contact__r.Name == null){
                htmlBody = htmlBody.replace('{!Highball__c.Buyer_Contact__r.Name}', '')+'<br/>';
            }else{
                htmlBody = htmlBody.replace('{!Highball__c.Buyer_Contact__r.Name}', higball.Buyer_Contact__r.Name)+'<br/>';
            }			
            if(higball.Buyer_Contact__r.Email == null){
                htmlBody = htmlBody.replace('{!Highball__c.Buyer_Contact__r.Email}', '')+'<br/>';
            }else{
                htmlBody = htmlBody.replace('{!Highball__c.Buyer_Contact__r.Email}', higball.Buyer_Contact__r.Email)+'<br/>';
            }			
            if(higball.Buyer_Contact__r.Phone == null){
                htmlBody = htmlBody.replace('{!Highball__c.Buyer_Contact__r.Phone}', '')+'<br/>';
            }else{
                htmlBody = htmlBody.replace('{!Highball__c.Buyer_Contact__r.Phone}', higball.Buyer_Contact__r.Phone)+'<br/>';
            }                  
            htmlBody = htmlBody.replace('{!Highball__c.Site_Survey_Request_Date_1__c}', higball.Site_Survey_Request_Date_1__c.format())+'<br/>';           
            if(higball.Site_Survey_Request_Date_2__c == null){
                htmlBody = htmlBody.replace('{!Highball__c.Site_Survey_Request_Date_2__c}', '')+'<br/>';
            }else{
                htmlBody = htmlBody.replace('{!Highball__c.Site_Survey_Request_Date_2__c}', higball.Site_Survey_Request_Date_2__c.format())+'<br/>';
            }
            if(higball.Site_Survey_Request_Date_3__c == null){    
                htmlBody = htmlBody.replace('{!Highball__c.Site_Survey_Request_Date_3__c}', '')+'<br/>';
            }else{
                htmlBody = htmlBody.replace('{!Highball__c.Site_Survey_Request_Date_3__c}', higball.Site_Survey_Request_Date_3__c.format())+'<br/>';
            }
            htmlBody = htmlBody.replace('{!Highball__c.Available_Hours_for_Site_Survey__c}', higball.Available_Hours_for_Site_Survey__c)+'<br/>';
            
            String plainBody = template.Body;
            plainBody = plainBody.replace('<p> : </p>','');
            if(higball.Local_BSI_Contact__r.FirstName == null || higball.Local_BSI_Contact__r.LastName == null ||
               higball.Local_BSI_Contact__r.Email == null){
                   plainBody = plainBody.replace('{!Highball__c.Local_BSI_Contact__r.FirstName}', '')+'<br/>';
                   plainBody = plainBody.replace('{!Highball__c.Local_BSI_Contact__r.LastName}', '')+'<br/>';
                   plainBody = plainBody.replace('{!Highball__c.Local_BSI_Contact__r.Email}', '')+'<br/>';                		
               }else{
                   plainBody = plainBody.replace('{!Highball__c.Local_BSI_Contact__r.FirstName}', higball.Local_BSI_Contact__r.FirstName)+'<br/>'; 
                   plainBody = plainBody.replace('{!Highball__c.Local_BSI_Contact__r.LastName}', higball.Local_BSI_Contact__r.LastName)+'<br/>';
                   plainBody = plainBody.replace('{!Highball__c.Local_BSI_Contact__r.Email}', higball.Local_BSI_Contact__r.Email)+'<br/>';                 
               }  
            if(higball.Local_BSI_Contact__r.Phone == null){
                plainBody = plainBody.replace('{!Highball__c.Local_BSI_Contact__r.Phone}', '')+'<br/>';
            }else{          
                plainBody = plainBody.replace('{!Highball__c.Local_BSI_Contact__r.Phone}', higball.Local_BSI_Contact__r.Phone)+'<br/>'; 
            }
            if(higball.Highball_Specialist__r.FirstName == null || higball.Highball_Specialist__r.LastName == null || 
               higball.Highball_Specialist__r.Email == null){
                   plainBody = plainBody.replace('{!Highball__c.Highball_Specialist__r.FirstName}', '')+'<br/>';
                   plainBody = plainBody.replace('{!Highball__c.Highball_Specialist__r.LastName}', '')+'<br/>';
                   plainBody = plainBody.replace('{!Highball__c.Highball_Specialist__r.Email}', '')+'<br/>';
               }else{
                   plainBody = plainBody.replace('{!Highball__c.Highball_Specialist__r.FirstName}', higball.Highball_Specialist__r.FirstName)+'<br/>';
                   plainBody = plainBody.replace('{!Highball__c.Highball_Specialist__r.LastName}', higball.Highball_Specialist__r.LastName)+'<br/>';
                   plainBody = plainBody.replace('{!Highball__c.Highball_Specialist__r.Email}', higball.Highball_Specialist__r.Email)+'<br/>';
               }
            plainBody = plainBody.replace('{!Highball__c.Spirits_Brand__c}', higball.Spirits_Brand__c)+'<br/>';
            plainBody = plainBody.replace('{!Highball__c.Type_of_Technology__c}', higball.Type_of_Technology__c)+'<br/>';
            plainBody = plainBody.replace('{!Highball__c.No_of_Machines__c}', higball.No_of_Machines__c.format())+'<br/>';
            if(higball.Type_of_Tower__c == null){
                plainBody = plainBody.replace('{!Highball__c.Type_of_Tower__c}', '')+'<br/>';
            }else{
                plainBody = plainBody.replace('{!Highball__c.Type_of_Tower__c}', higball.Type_of_Tower__c)+'<br/>';
            }
            plainBody = plainBody.replace('{!Highball__c.Account__r.Name}', higball.Account__r.Name)+'<br/>';
            plainBody = plainBody.replace('{!Highball__c.Account_Address__c}', higball.Account_Address__c)+'<br/>';
            plainBody = plainBody.replace('{!Highball__c.Account_City__c}', higball.Account_City__c)+'<br/>';
            plainBody = plainBody.replace('{!Highball__c.Account_State__c}', higball.Account_State__c)+'<br/>';
            plainBody = plainBody.replace('{!Highball__c.Account__r.BillingPostalCode}', higball.Account__r.BillingPostalCode)+'<br/>';
            if(higball.Contact__r.Name == null){
                plainBody = plainBody.replace('{!Highball__c.Contact__r.Name}', '')+'<br/>';
            }else{
                plainBody = plainBody.replace('{!Highball__c.Contact__r.Name}', higball.Contact__r.Name)+'<br/>';
            }			
            if(higball.Contact__r.Email == null){
                plainBody = plainBody.replace('{!Highball__c.Contact__r.Email}', '')+'<br/>';
            }else{
                plainBody = plainBody.replace('{!Highball__c.Contact__r.Email}', higball.Contact__r.Email)+'<br/>';
            }			
            if(higball.Contact__r.Phone == null){
                plainBody = plainBody.replace('{!Highball__c.Contact__r.Phone}', '')+'<br/>';
            }else{
                plainBody = plainBody.replace('{!Highball__c.Contact__r.Phone}', higball.Contact__r.Phone)+'<br/>';
            }			
            if(higball.Buyer_Contact__r.Name == null){
                plainBody = plainBody.replace('{!Highball__c.Buyer_Contact__r.Name}', '')+'<br/>';
            }else{
                plainBody = plainBody.replace('{!Highball__c.Buyer_Contact__r.Name}', higball.Buyer_Contact__r.Name)+'<br/>';
            }			
            if(higball.Buyer_Contact__r.Email == null){
                plainBody = plainBody.replace('{!Highball__c.Buyer_Contact__r.Email}', '')+'<br/>';
            }else{
                plainBody = plainBody.replace('{!Highball__c.Buyer_Contact__r.Email}', higball.Buyer_Contact__r.Email)+'<br/>';
            }			
            if(higball.Buyer_Contact__r.Phone == null){
                plainBody = plainBody.replace('{!Highball__c.Buyer_Contact__r.Phone}', '')+'<br/>';
            }else{
                plainBody = plainBody.replace('{!Highball__c.Buyer_Contact__r.Phone}', higball.Buyer_Contact__r.Phone)+'<br/>';
            } 		                    
            plainBody = plainBody.replace('{!Highball__c.Site_Survey_Request_Date_1__c}', higball.Site_Survey_Request_Date_1__c.format())+'<br/>';            
            if(higball.Site_Survey_Request_Date_2__c == null){
                plainBody = plainBody.replace('{!Highball__c.Site_Survey_Request_Date_2__c}', '')+'<br/>';
            }else{
                plainBody = plainBody.replace('{!Highball__c.Site_Survey_Request_Date_2__c}', higball.Site_Survey_Request_Date_2__c.format())+'<br/>';
            }
            if(higball.Site_Survey_Request_Date_3__c == null){    
                plainBody = plainBody.replace('{!Highball__c.Site_Survey_Request_Date_3__c}', '')+'<br/>';
            }else{
                plainBody = plainBody.replace('{!Highball__c.Site_Survey_Request_Date_3__c}', higball.Site_Survey_Request_Date_3__c.format())+'<br/>';
            }
            plainBody = plainBody.replace('{!Highball__c.Available_Hours_for_Site_Survey__c}', higball.Available_Hours_for_Site_Survey__c)+'<br/>';
            
            Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
            singleMail.setToAddresses(emailsToSendTo);                       
            singleMail.setTargetObjectId(UserInfo.getUserId());
            singleMail.setTreatTargetObjectAsRecipient(false);         
            singleMail.setTemplateId(template.Id);                  
            singleMail.setSaveAsActivity(false);
            singleMail.setSubject(subject);
            singleMail.setHtmlBody(htmlBody);
            singleMail.setPlainTextBody(plainBody);      
            emails.add(singleMail);
            
            EmailMessage emailMsg = new EmailMessage();
            emailMsg.FromAddress = UserInfo.getUserEmail();
            emailMsg.ToAddress = String.join(singleMail.getToAddresses(),',');
            emailMsg.Subject = singleMail.getSubject();
            emailMsg.HtmlBody = singleMail.getHtmlBody();
            emailMsg.RelatedToId = higball.Id; 
            emailMsg.MessageDate = system.now();
            emailMsg.Status = '1';
            emailRecords.add(emailMsg);
        }
        if(!emails.isEmpty()) {       
            List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(emails);
            for(Integer i=0;i<emailResults.size();i++){
                if(!emailResults[i].isSuccess()){
                    emailRecords.remove(i);
                }
            }
        }
        if(!emailRecords.isEmpty()){
            insert emailRecords;
        }    
    }
}