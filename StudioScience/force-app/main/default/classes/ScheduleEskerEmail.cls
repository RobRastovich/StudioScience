/**************************************************************************************
 Apex Class Name     : ScheduleEskerEmail
 Created Date        : 3/2019
 Function            : Esker job will be scheduled from Anonymous Block
 Details and Notes   : Auto-forward email to Esker from salesforce when cases are landed in orders queue.                        
*************************************************************************************/
global class ScheduleEskerEmail implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    
    global String query;
    global Esker_Email_Settings__mdt edringtonEskerSettings;
         
    global ScheduleEskerEmail(){
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String ordersRTName = CSConstants.ORDERS;
        Id ordersRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ordersRTName).getRecordTypeId();
        Id sampleOrdersRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sample_Orders').getRecordTypeId();
        
        Map<String, Esker_Email_Settings__mdt> eskerEmailSetting = Esker_Email_Settings__mdt.getAll();
        edringtonEskerSettings = new Esker_Email_Settings__mdt();
        for(String keySetString : eskerEmailSetting.keySet()){
            if(keySetString == 'Esker_Edrington'){
                edringtonEskerSettings = eskerEmailSetting.get(keySetString);
            }
        }
        
        List<Group> QueueIdrecs = [select Id, Name from Group where Type = 'Queue' AND NAME IN ('Orders Queue','Canada Queue','Edrington Queue')];
        Set<Id> QueueIds = new Set<Id>();
        for(Group gr : QueueIdrecs){
            if(gr.Name == 'Edrington Queue' && edringtonEskerSettings != null){
                if(edringtonEskerSettings.Enable_Esker__c)
                    QueueIds.add(gr.Id);
            }
            else {
                QueueIds.add(gr.Id);
            }
        }
        
        //List<Esker_Email_Settings__mdt> eskerEmailSetting = [Select Enable_Esker_for_Edrington__c From Esker_Email_Settings__mdt];
        //Boolean enabaleEskerForEdrington = eskerEmailSetting[0].Enable_Esker_for_Edrington__c;
        Map<String, Date_Type__c> dateTypeMap = Date_Type__c.getAll();
        DateTime currentDateTime;
        if (Test.isRunningTest()) {
            currentDateTime = System.today().addDays(-1);
        } else {
            currentDateTime = dateTypeMap.get('EskerDate').EskerDate__c;
        }
        
        // Updated below query by Sripal 06/24/2020 to hold the multiple queues
        query = 'Select Id, RecordType.Name, RecordType.DeveloperName, BSI_Function__c, OwnerId, Type, Origin, Email_Sent_to_Esker__c from case where'+
        '(RecordTypeId IN(\'' + ordersRecordTypeId + '\', \'' + sampleOrdersRecordTypeId + '\') AND IsClosed = false AND Status != \'DUP - No Action\' AND (OwnerId IN:QueueIdrecs) AND BSI_Function__c = \'CS\' )' +
        'AND' + '(Type=\'Standard\' OR Type = null OR (Type=\'Edrington\' AND owner.name =\'Edrington Queue\' AND (Not Subject like \'%Invoice%\'))) AND (Origin=\'Customer Portal\' OR Origin=\'Email\') AND Email_Sent_to_Esker__c != true AND Flow__c != true AND (owner.name =\'Orders Queue\' OR (owner.name =\'Canada Queue\' AND (Not Subject like \'%Order Acknowledgment%\'))';
        
        if(edringtonEskerSettings != null && !edringtonEskerSettings.Enable_Esker__c) {
            query += ') AND CreatedDate >: currentDateTime';
        } else {
            query += ' OR owner.name =\'Edrington Queue\') AND CreatedDate >: currentDateTime';
        }
        return Database.getQueryLocator(query);
 
    }
    
    global void execute(Database.BatchableContext bc, List<Case> scope){
       
        //String prodEdringtonEskerEmailAddress;
        //String sandboxEdringtonEskerEmailAddress;
        String edringtonEskerEmailAddress;
        
        if(edringtonEskerSettings != null){
            edringtonEskerEmailAddress = UserInfo.getOrganizationId() == CSConstants.PRODUCTION_ORGANIZATION_ID ? edringtonEskerSettings.PROD_Esker_Email_Address__c : edringtonEskerSettings.Sandbox_Esker_Email_Address__c;
        }
        /*List<Esker_Email_Settings__mdt> eskerEmailSetting = [Select PROD_Edrington_Esker_Email_Address__c, Sandbox_Edrington_Esker_Email_Address__c From Esker_Email_Settings__mdt];
        if(eskerEmailSetting != null && eskerEmailSetting.size() > 0) {
            prodEdringtonEskerEmailAddress = eskerEmailSetting[0].PROD_Edrington_Esker_Email_Address__c;
            sandboxEdringtonEskerEmailAddress = eskerEmailSetting[0].Sandbox_Edrington_Esker_Email_Address__c;
        }*/
        
        //Added by Deekshika on 22-6-23 - added code for Edrington Queue
        Group edringtonQueue = [select Id from Group where Type = 'Queue' AND NAME = 'Edrington Queue'];
        //String edringtonEskerEmailAddress = CSConstants.Edrington_ESKER_EmailAddress;
        Set<ID> actionableCaseSet = new Set<Id>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Set<Id> finalCaseSet = new Set<Id>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        try{ 
        /*Getting Esker email address, systemUserId and TemplateName from CSConstants starts*/
        Integer size = 0;
        String eskerEmailAddress = CSConstants.Esker_EmailAddress;
        String systemUserId = CSConstants.SYSTEM_EMAIL_USER_ID;
        String OrdersCaseCreationforEskerTemplateName = CSConstants.Orders_Case_Creation_for_Esker;
        EmailTemplate OrdersCaseCreationforEskerTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = : OrdersCaseCreationforEskerTemplateName LIMIT 1];
        /*Getting Esker email address,TemplateName from CSConstants ends*/
        
            if(scope!=null && !scope.isEmpty()){
                for (Case c : scope) {
                    caseMap.put(c.Id, c);
                    actionableCaseSet.add(c.Id); 
                    //if(c.OwnerId == edringtonQueue.Id && enabaleEskerForEdrington)
                }
            }
       
        Map<Id, ContentDocumentLink> contentDocumentToLinkMap = new Map<Id, ContentDocumentLink>();
        
        if (actionableCaseSet != null && !actionableCaseSet.isEmpty() ) {
            
            Map<Id, Case> actionableCaseMap = new Map<Id, Case>([Select Id, Email_Sent_to_Esker__c, CreatedDate from Case Where Id in :actionableCaseSet]);
        
            List<ContentDocumentLink> cdLinkList = [SELECT Id, LinkedEntityId, ContentDocumentId
                                                    FROM ContentDocumentLink WHERE LinkedEntityId IN: actionableCaseSet];
            for (ContentDocumentLink cdl : cdLinkList) {
                contentDocumentToLinkMap.put(cdl.ContentDocumentId, cdl);
            }

        
        /*Code for getting list of attachment whose fileextension is Pdf and max size per Pdf is less than 10MB Starts*/
        Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>([SELECT Id, ContentDocumentId, ContentSize, FileExtension, FileType, PathOnClient FROM ContentVersion WHERE
                                                                     FileExtension = 'pdf' AND ContentSize < 10000000 AND
                                                                     ContentDocumentId IN: contentDocumentToLinkMap.keySet()]);
        Map<Id, List<Id>> caseToCVMap = new Map<Id, List<Id>>();
        for (ContentVersion cv : cvMap.values()) {
            Id entityId = contentDocumentToLinkMap.get(cv.ContentDocumentId).LinkedEntityId;
            if(caseMap.get(entityId).recordType.DeveloperName == 'Orders' || (caseMap.get(entityId).recordType.DeveloperName == 'Sample_Orders' && cv.PathOnClient.containsIgnoreCase('Esker'))) {
                if (!caseToCVMap.containsKey(entityId)) {
                    caseToCVMap.put(entityId, new List<Id> {cv.Id});
                } else {
                    caseToCVMap.get(entityId).add(cv.Id);
                }
            }
        }
        /*Code for getting list of attachment whose fileextension is Pdf and max size per Pdf is less than 10MB Ends*/
        
        /*Code for sending an email to Esker and checking the max size per email is less than 28MB starts*/
        for (Id caseId : actionableCaseMap.keySet()) {
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(OrdersCaseCreationforEskerTemplate.Id, CSConstants.SYSTEM_EMAIL_USER_ID, caseId);
            mail.setSaveAsActivity(false);
            
            if (caseToCVMap.containsKey(caseId)) {
                
                List<Id> attachmentList = caseToCVMap.get(caseId);
                List<Id> finalAttachmentList = new List<Id>();
                map<String,Id>mapOfPathNameToId = new map<String,Id>();
                for (ID cv : attachmentList){
                    
                    system.Debug('coming in loop again'+cvMap.get(cv).PathOnClient);
                    mapOfPathNameToId.put(cvMap.get(cv).PathOnClient,cv);
                }
                system.debug('pathonclient values are '+mapOfPathNameToId.keyset());
                finalAttachmentList = mapOfPathNameToId.values();
                size = 0;
                for (ID cv : finalAttachmentList)
                    size += cvMap.get(cv).ContentSize;
                if (size > 28000000) break;
                mail.setEntityAttachments(finalAttachmentList);
                //mail.setToAddresses(new List<String> {eskerEmailAddress});
                //Added by Deekshika on 22-6-23 o- added Edrington Queue check
                if(caseMap.get(caseId).OwnerId == edringtonQueue.Id && edringtonEskerEmailAddress != null) {
                    mail.setToAddresses(new List<String> {edringtonEskerEmailAddress});
                } else {
                    mail.setToAddresses(new List<String> {eskerEmailAddress});
                }
                mail.setWhatId(caseId);
                finalCaseSet.add(caseId);
                mails.add(mail);
            }
             
        }
        
          List<Case> caselist = new List<Case>();
          if(mails!=null && !mails.isEmpty()){  
          Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
         
          if(results!=null && !results.isEmpty()){  
              if (results[0].success) {
                  caselist = [Select id, Email_Sent_to_Esker__c from case where Id IN: finalCaseSet]; 
                  for(case c:caselist){    
                      c.Email_Sent_to_Esker__c = true;
                  }
                  update caselist;
              }
           }
          }    
        } 
          /*Code for sending an email to Esker and checking the max size per email is less than 28MB ends*/
        }catch (Exception e) {
             CreateExceptionLog.insertErrorLog('ScheduleEskerEmail', 'execute', String.valueOf(e), 'Fatal');
          } 
        }
    
    global void finish(Database.BatchableContext bc){

    }
    
    global void execute(SchedulableContext sc) {
        Id batchInstanceId = Database.executeBatch(new ScheduleEskerEmail(),50);        
    }

}