public with sharing class CaseCloseWithAttachmentController {
    
    public Case objcase{get;set;}
    public String currentRecordId {get;set;}
    public ApexPages.standardController m_sc = null;
    public String selectedVal{get;set;}
    public List<SelectOption> filesCountList {get;set;}
    public Integer FileCount {get;set;}
    public List<Attachment> allFileList {get;set;}
    public Boolean showSectionFlag {get;set;}
    public Integer attachSize {get;set;}
    
    public CaseCloseWithAttachmentController(ApexPages.StandardController sc){
        showSectionFlag = false;
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        objCase = new Case();
        objCase = [Select Id, CaseNumber, Status, Case_Resolution_Details__c, Submitter__r.Email, Case_Closed_from_CaseCloseAttachmentPage__c From Case Where Id =: currentRecordId];
        System.debug('---Case Status---'+objCase.Status);
        if(objcase.Status =='Closed' || objcase.Status =='Closed - No Action'){
            showSectionFlag = true;
        }
        m_sc = sc; 
        filesCountList = new List<SelectOption>();
        FileCount = 0;
        allFileList = new List<Attachment>();
        for(Integer i = 1 ; i < 11 ; i++){
            filesCountList.add(new SelectOption(''+i , ''+i));
        }    
    }
    
    public List<SelectOption> getStatusValue(){
        List<SelectOption> options = new List<Selectoption>();
        options.add(new SelectOption('Closed','Closed'));
        options.add(new SelectOption('Closed - No Action','Closed - No Action'));
        return options;
    }
    
    public PageReference doSave(){
        try{
            objCase.Status = selectedVal;
            objCase.Case_Closed_from_CaseCloseAttachmentPage__c = true; //this field will determine that the case is closed from CaseCloseWithAttachment Page
            update objCase;
            if(objCase.Submitter__r.Email != null && selectedVal != 'Closed - No Action'){
                String submitterEmail = objCase.Submitter__r.Email;
                String searchText = '%'+objCase.CaseNumber+'%';
                System.debug('---Search Text---'+searchText);
                List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>([Select Id,ContentDocumentId From ContentDocumentLink Where LinkedEntityId =: objCase.Id]);
                System.debug('---Attachments Retrieved---'+contentDocumentList);
                Set<Id> setContentDocumentId = new Set<Id>();
                for(ContentDocumentLink cd : contentDocumentList){
                    setContentDocumentId.add(cd.ContentDocumentId);
                }
                List<ContentDocument> finalContentDocument = new List<ContentDocument>([Select Id, Title From ContentDocument Where Id in :setContentDocumentId And Title like :searchText]);
                System.debug('---Final Content---'+finalContentDocument);
                Set<Id> cdIdSet = new Set<Id>();
                for (ContentDocument cd : finalContentDocument){
                    cdIdSet.add(cd.Id);
                }
                System.debug('---Set of Id---'+cdIdSet);
                List<ContentVersion> cvList = new List<ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: cdIdSet]);
                System.debug('---CV List---'+cvList);
                List<Id> attachmentIdList = new List<Id>();
                for(ContentVersion cv : cvList){
                    attachmentIdList.add(cv.Id);
                }
                
                String gbs_CaseClosedEmailName = 'Case_Closed_en_US';
                EmailTemplate gbs_CaseClosedEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: gbs_CaseClosedEmailName LIMIT 1];
                OrgWideEmailAddress owe = [SELECT ID,IsAllowAllProfiles,DisplayName,Address FROM OrgWideEmailAddress WHERE Address = 'gbs@beamsuntory.com' LIMIT 1];
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(gbs_CaseClosedEmailTemplate.Id, objCase.Submitter__c, objcase.Id);
                mail.setSaveAsActivity(false);
                mail.setToAddresses(new List<String> {submitterEmail});
                mail.setOrgWideEmailAddressId(owe.Id);
                mail.setWhatId(objcase.Id);
                mail.setEntityAttachments(attachmentIdList);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            PageReference pageRef = new PageReference('/' + objCase.Id);
            pageRef.setRedirect(true);
            return pageRef;
        }
        catch(Exception ex){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
            ApexPages.addMessage(msg);
            return null;
        }
    }
    
    public PageReference doCancel(){
        String searchText = '%'+objCase.CaseNumber+'%';
        List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>([Select Id,ContentDocumentId From ContentDocumentLink Where LinkedEntityId =: objCase.Id]);
        System.debug('---Attachments Retrieved---'+contentDocumentList);
        Set<Id> setContentDocumentId = new Set<Id>();
        for(ContentDocumentLink cd : contentDocumentList){
            setContentDocumentId.add(cd.ContentDocumentId);
        }
        List<ContentDocument> finalContentDocument = new List<ContentDocument>([Select Id, Title From ContentDocument Where Id in :setContentDocumentId And Title like :searchText]);
        System.debug('---Final Content---'+finalContentDocument);
        Database.delete(finalContentDocument);
        return m_sc.cancel();
    }
    
    public Pagereference SaveAttachments(){
        Integer consolidated_size = 0;
        System.debug('---Size of attachment--'+attachSize);
        for(Attachment att : allFileList){
            consolidated_size += att.body.size();
        }
        System.debug('---Consolidated Size of all attachments---'+consolidated_size);    
        if(consolidated_size > 20000000){
            allFileList = new List<Attachment>();
            FileCount = 0;
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'File size exceeded limit.'));
            return null;
        }
        String caseId = System.currentPagereference().getParameters().get('id');
        if(FileCount == null || FileCount == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'Please select how many files you want to upload.'));
        }
        List<Attachment> listToInsert = new List<Attachment>();
        for(Attachment a: allFileList)
        {
            if(a.name != '' && a.name != '' && a.body != null)
                listToInsert.add(new Attachment(parentId = caseId, name = objCase.CaseNumber + ' - ' +a.name, body = a.body)) ;
        }
        if(listToInsert.size() > 0)
        {
            insert listToInsert ;
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.INFO, listToInsert.size() + ' file(s) are uploaded successfully'));
            FileCount = 0 ;
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'Please select at-least one file'));
        }
        FileCount = 0;
        allFileList = new List<Attachment>();
        return null;
    }
    public PageReference ChangeCount()
    {
        allFileList = new List<Attachment>();
        //Adding multiple attachments instance
        for(Integer i = 1 ; i <= Integer.valueOf(FileCount) ; i++)
            allFileList.add(new Attachment()) ;
        return null ;
    }
    @InvocableMethod(label = 'Send Email To Parent Case' description = 'Send Email To Parent Case On Child Logistic Request Close')
    public static void sendEmailLogistics(List<Id> caseId) {
        try{
            Set<Id> caseSetId = new Set<Id>();
            caseSetId.addAll(caseId);
            List<Case> caseList = [Select Id, ParentId, Parent.OwnerId From Case Where Id in : caseSetId];
            Set<Id> userIdSet = new Set<Id>(); 
            for(Case c: caseList) userIdSet.add(c.Parent.OwnerId);
            Map<Id,User> userMap = new Map<Id,User>([Select Id, Email, Name From User Where Id IN :userIdSet]);
            
            String logisticsCaseClosedEmailTemplateName = 'Logistic_Child_Case_Close_Notification';
            EmailTemplate logisticsCaseClosedEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: logisticsCaseClosedEmailTemplateName LIMIT 1];    
            OrgWideEmailAddress owe = [SELECT ID,IsAllowAllProfiles,DisplayName,Address FROM OrgWideEmailAddress WHERE Address = 'logistics@beamsuntory.com' LIMIT 1];
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            
            for(Case c1 : caseList){
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(logisticsCaseClosedEmailTemplate.Id, c1.Parent.OwnerId, c1.Id);
                mail.setSaveAsActivity(false);
                mail.setToAddresses(new List<String> {userMap.get(c1.Parent.OwnerId).Email});
                mail.setWhatId(c1.Id);
                mail.setOrgWideEmailAddressId(owe.Id); 
                emailList.add(mail);
            }
            System.debug('emailList::'+emailList);
            Messaging.sendEmail(emailList);
        }
        catch(Exception e){
            System.debug('Error while sending the email::: ' + e.getMessage());
            CreateExceptionLog.insertErrorLog('CaseCloseWithAttachmentController', 'sendEmail', String.valueOf(e), 'Warning');
        }
    }  
}