public class ContentDocumentLinkServices {

    /**************************************************************************************************************
    Author:        Craig Austgen
    Company:       Slalom, LLC
    Description:    For the Single Barrel Program a purchase order needs to be uploaded via the Customer Community
                    and once a file is updated it is assumed that the file is the purchase order and the related case
                    will be updated to reflect that
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    7/2018      Craig Austgen       Initial Creation

    ***************************************************************************************************************/
   	public static Boolean runFirstTime = true;
    public static void updatePoUploadFlagOnCase(List<ContentDocumentLink> files, Map<Id, ContentDocumentLink> fileMap) {
        if(ContentDocumentLinkServices.runFirstTime){ // Added Static check to stop recurssion - 24th Feb 2022
            Set<Id> caseIds = new Set<Id>();
            Map<Id, Case> casesToUpdate = new Map<Id, Case>();
            Set<Id> barrelIds = new Set<Id>();
            Set<Id> fileIds = fileMap.keySet();
            List<ContentDocumentLink> contentDocLinks = new List<ContentDocumentLink>();
            Set<String> contentDocId = new Set<String>();
            Map<String, String> contentDocVsFileExt = new Map<String, String>();
            Set<String> imageFormats = new Set<String>{'jpg', 'jpeg', 'png'};
            Map<Id,List<String>> mapOfEmailAttachments = new Map<Id,List<String>>();    
            system.debug('coming in content documentlinkservices ---------');
            system.debug(Limits.getLimitQueries());
            for (ContentDocumentLink cdl : [select Id, ContentDocument.LatestPublishedVersionId,LinkedEntity.Type, ContentDocumentId, LinkedEntityId from ContentDocumentLink where Id IN :fileIds]) {
                contentDocId.add(cdl.ContentDocumentId);
                contentDocLinks.add(cdl);
            }
            system.debug('After first query in loop');
            system.debug(Limits.getQueries());
            for(ContentVersion version: [select ContentDocumentId,FileExtension from ContentVersion where ContentDocumentId IN:contentDocId]) {
                contentDocVsFileExt.put(version.ContentDocumentid, version.FileExtension);
            }
            system.debug('After second query in loop');
            system.debug('queries '+Limits.getQueries());
            for (ContentDocumentLink cdl: contentDocLinks) {
                if (!imageFormats.contains(contentDocVsFileExt.get(cdl.ContentDocumentId))) {
                    System.debug('linked entity type is  = ' + cdl.LinkedEntityId);
                    if(cdl.LinkedEntity.Type == 'Case') { 
                        caseIds.add(cdl.LinkedEntityId);
                        if(mapOfEmailAttachments.containsKey(cdl.LinkedEntityId)){
                            mapOfEmailAttachments.get(cdl.LinkedEntityId).add(String.valueOf(cdl.ContentDocument.LatestPublishedVersionId));
                        } else{
                            mapOfEmailAttachments.put(cdl.LinkedEntityId,new List<String>{String.valueOf(cdl.ContentDocument.LatestPublishedVersionId)});
                        }
                        
                        
                    } else if(cdl.LinkedEntity.Type == 'Barrel__c') {
                        barrelIds.add(cdl.LinkedEntityId);
                    }
                }
            }
    
            if(!barrelIds.isEmpty()){
                for (Barrel__c barrel:[select id, Case__r.id from Barrel__c where Id IN: barrelIds]) {
                    caseIds.add(barrel.Case__r.id);
                }
            }
    
            List<Case> cases = [select id, Purchase_Order_Uploaded__c, RecordTypeId from Case where Id IN :caseIds AND
                                (RecordTypeId IN :SBP_Constants.caseSingleBarrelRtIds)];

            for (Case c : cases) {
                c.Purchase_Order_Uploaded__c = true;
                casesToUpdate.put(c.Id, c);
            }
            
            if (!casesToUpdate.isEmpty()) {
                System.debug('list is not empty'+casesToUpdate);
                
                String profileId = UserInfo.getProfileId();
                Profile profile = [Select Id, Name from Profile where Id=:profileId];
                if(profile.Name == 'Distributor Community'){
                    sendEmailNotification(mapOfEmailAttachments);
                }
                
                update casesToUpdate.values();
            }
            ContentDocumentLinkServices.runFirstTime = false; // Added Static check to stop recurssion - 24th Feb 2022
        }
    }
    
    // Send an Email Notification when PO is Uploaded by Distributor
    public static void sendEmailNotification(Map<id,List<String>> caseAttachments){
        
        String csEmailAddress = SBP_Constants.PROD_EMAIL_SERVICE_ADDRESS;
        OrgWideEmailAddress csEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :csEmailAddress LIMIT 1];
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'SBP PO Uploaded Notification'];
        List<Case> cases = [SELECT Id, caseNumber FROM Case WHERE Id IN : caseAttachments.keySet()];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage singleMail;
       
        for(Case c: cases){
            
         singleMail = new Messaging.SingleEmailMessage();
         String[] toAddresses = new String[]{SBP_Constants.singleBarrelOWEA_SERVICE_ADDRESS};
         String subject = emailTemplate.Subject.replace('{!Case.CaseNumber}', c.caseNumber);
         String htmlBody = emailTemplate.HtmlValue.replace('{!Case.CaseNumber}', c.caseNumber);
         String plainBody = emailTemplate.Body.replace('{!Case.CaseNumber}', c.caseNumber );
   
         singleMail.setToAddresses(toAddresses);
         singleMail.setTemplateId(emailTemplate.Id);
         singleMail.setTargetObjectId(UserInfo.getUserId());
         singleMail.setTreatTargetObjectAsRecipient(false);  
         singleMail.setSaveAsActivity(false);
         singleMail.setSubject(subject);
         singleMail.setHtmlBody(htmlBody);
         singleMail.setPlainTextBody(plainBody);
         singleMail.setWhatId(c.Id);
         singleMail.setEntityAttachments(caseAttachments.get(c.Id));
         singleMail.setOrgWideEmailAddressId(csEmail.Id);   
         emails.add(singleMail);
        
        }
        
        if(!emails.isEmpty()) {       
            List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(emails);
        }
    } 
}