/**************************************************************************************
Apex Class Name     : EmailMessageServices
Created Date        : 20-11-2021
Function            : Handles events from the EmailMessage Trigger
*************************************************************************************/
public  class EmailMessageServices {

    public static Boolean skipForGeneralQueue = true;

    /**************************************************************************************************************
Method name:    updateParentCaseToReopen
Object:         EmailMessage
Date:           22/11/2021
Details and Notes: SR-09
This methods change the parent case status from resovled to reopen in case any email get triggered with in 48 hours(This value 
get determines from custom setting named ConsumerServices__c )
Added by: Deepak Jain
*****************************************************************************************************************************/
    public static void updateParentCaseToReopen(List<EmailMessage> emailMessages) {
        Set<Id> caseIds = new Set<Id>();
        Map<Id,List<EmailMessage>> parentIdToEmailMessage=new Map<Id,List<EmailMessage>>();
        for(EmailMessage em : emailMessages) {
            if(em.Incoming == true && em.FromName != 'Mail Delivery System'
               && !(CRM_Constants.Consumer_Response_Brand_Emails.contains(em.FromAddress))) {
                caseIds.add(em.ParentId);
                List<EmailMessage> emailMessageList;
                if(parentIdToEmailMessage.containsKey(em.ParentId)) { 
                    emailMessageList = parentIdToEmailMessage.get(em.ParentId);
                } else {
                    emailMessageList = new List<EmailMessage>();
                }
                emailMessageList.add(em);
                parentIdToEmailMessage.put(em.ParentId,emailMessageList);
            }
        }
        Id consumerInquiryRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumer_Inquiry').getRecordTypeId();
        List<Case> lstCases = [SELECT Id, CaseNumber, Subject, status, ResolvedDate__c,ClosedDate,RecordTypeId
                               FROM Case 
                               WHERE Id IN :caseIds and status = :EmailMessageConstants.CASE_STATUS_RESOLVED]; 
        List<Case> listToBeUpdated = new List<Case>();
        ConsumerServices__c cs = ConsumerServices__c.getInstance();
        Double emailMessageTimeFrame = cs != null ? (cs.EmailMessageTimeFrameOnResolved__c !=null ? cs.EmailMessageTimeFrameOnResolved__c : 48 ) : 48;
        for(Case c : lstCases) {
            if(c.RecordTypeId == consumerInquiryRecordTypeID) {
                List<EmailMessage> emailList = parentIdToEmailMessage.get(c.Id);
                for(EmailMessage emailMessage:emailList) {
                    Long dateDiffInHour = (emailMessage.CreatedDate.getTime()-c.ClosedDate.getTime())/(1000*60*60);
                    if(dateDiffInHour <= emailMessageTimeFrame) {
                        c.Status = EmailMessageConstants.CASE_STATUS_REOPEN;
                        listToBeUpdated.add(c);  
                    }
                }
            }
        } 
        if(!listToBeUpdated.isEmpty()) {
            update listToBeUpdated;
        }
    }
    
    /**************************************************************************************************************
Method name:    updateParentCaseFlags
Object:         EmailMessage
Date:           26/11/2021
Details and Notes: SR-11
This methods used for reseting the flag on parent case when there is a response sent from agent to customer.
Added by: Naman Jangid
*****************************************************************************************************************************/
    public static void updateParentCaseFlags(List<EmailMessage> emailMessages) {
        Set<Id> caseIds = new Set<Id>();
        Set<Id> caseIdsOfIncommingMsg = new Set<Id>();
        Map<Id,List<EmailMessage>> parentIdToEmailMessage=new Map<Id,List<EmailMessage>>();
        for(EmailMessage em : emailMessages) {
            if(em.Incoming == false) {
                caseIds.add(em.ParentId);
                List<EmailMessage> emailMessageList;
                if(parentIdToEmailMessage.containsKey(em.ParentId)) { 
                    emailMessageList = parentIdToEmailMessage.get(em.ParentId);
                } else {
                    emailMessageList = new List<EmailMessage>();
                }
                emailMessageList.add(em);
                parentIdToEmailMessage.put(em.ParentId,emailMessageList);
            }else
            {
                caseIdsOfIncommingMsg.add(em.ParentId);
            }
        }
        Id consumerInquiryRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumer_Inquiry').getRecordTypeId();
        List<Case> listToBeUpdated = new List<Case>();
        List<Case> lstCases = [SELECT Id, CaseNumber, Subject, status, ResolvedDate__c,ClosedDate,RecordTypeId
                               FROM Case WHERE Id IN :caseIds]; 
        List<Case> lstCasesOfIncommingMsg = [SELECT Id, CaseNumber, Subject, status, ResolvedDate__c,ClosedDate,RecordTypeId
                                             FROM Case WHERE Id IN :caseIdsOfIncommingMsg]; 
        for(Case c : lstCases) {
            if(c.RecordTypeId == consumerInquiryRecordTypeID) {
                c.New_Activity__c = false;
                listToBeUpdated.add(c);  
            }                  
        }
        for(Case c : lstCasesOfIncommingMsg) {
            if(c.RecordTypeId == consumerInquiryRecordTypeID) {
                System.debug('status of case >>>>>>>>>>>'+c.Status);
                if(c.Status == EmailMessageConstants.CASE_STATUS_NEW || c.Status == EmailMessageConstants.CASE_STATUS_CLOSED){
                    c.New_Activity__c = false;
                }else{
                    c.New_Activity__c = true;
                }
                listToBeUpdated.add(c);  
            }                  
        }
        if(!listToBeUpdated.isEmpty()) {
            update listToBeUpdated;
        }
    }
    /**************************************************************************************************************
Method name:    createNewCaseFromClosed
Object:         EmailMessage
Date:           24/11/2021
Details and Notes: SR-10
This methods creates new case whenever a email comes over closed case.If it finds a new case already created for the 
closed case then it won't create new case, It will refer existing case only to email message thread.
*****************************************************************************************************************************/
    public static void createNewCaseFromClosed(List<EmailMessage> emailMessages) {               
        if(skipForGeneralQueue){
            Set<Id> caseIds = new Set<Id>();
            Map<Id , List<EmailMessage>> parentIdToEmailMessage = new Map<Id , List<EmailMessage>>();
            List<Case> caseListToBeCreated = new List<Case>();
            List<Case> closedCasesToBeTraced = new List<Case>(); 
            Map<ID , ID> existingCreatedCase = new Map<ID , ID>();
            for(EmailMessage em : emailMessages) {
                if(em.Incoming == true && em.FromName != 'Mail Delivery System'
                   && !(CRM_Constants.Consumer_Response_Brand_Emails.contains(em.FromAddress))) {
                    if(!String.isBlank(em.ParentId))
                        caseIds.add(em.ParentId);
                    List<EmailMessage> emailMessageList;
                    if(parentIdToEmailMessage.containsKey(em.ParentId)) { 
                        emailMessageList = parentIdToEmailMessage.get(em.ParentId);
                    } else {
                        emailMessageList = new List<EmailMessage>();
                    }
                    emailMessageList.add(em);
                    parentIdToEmailMessage.put(em.ParentId , emailMessageList);
                }
            }
            Id consumerInquiryRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumer_Inquiry').getRecordTypeId();
            List<Schema.fieldSetMember> fieldMemberToCloneCase = SObjectType.Case.FieldSets.getMap().get('FieldsToBeClonedFromClosedCase').getFields();
            List<Case> closedCasesList = new List<Case>();
            if(caseIds.size() > 0){
                String closedCasesQuery = 'SELECT Id, Status, ParentId';
                for(Schema.FieldSetMember fieldSetMember : fieldMemberToCloneCase) {
                    closedCasesQuery += ', ' + fieldSetMember.getFieldPath();
                }
                closedCasesQuery += ' FROM case WHERE (Id IN :caseIds and status=\'Closed\' and RecordType.Name =\'Consumer Inquiry\' ) or (parentId IN :caseIds and status != \'Resolved\' and status != \'Closed\' and RecordType.Name =\'Consumer Inquiry\')';
                system.debug('closedCases query>'+closedCasesQuery);
                closedCasesList = Database.query(closedCasesQuery);
            }

            //Start changes for SCR-158 report for Auto Response Quality
            for(Case cse : closedCasesList) {
                if(cse.ParentId == null && caseIds.contains(cse.Id)){
                    cse.Is_Auto_Response_Quality_Not_Maintained__c = true;
                }
            }
            //End changes for SCR-158 report for Auto Response Quality
            
            for(Case cse : closedCasesList) {
                if(cse.ParentId != null && cse.status != EmailMessageConstants.CASE_STATUS_RESOLVED &&  cse.status != EmailMessageConstants.CASE_STATUS_CLOSED) {
                    system.debug('coming in existingcreatedCase');
                    existingCreatedCase.put(cse.ParentId,cse.Id);
                }
                else if(cse.Status == EmailMessageConstants.CASE_STATUS_CLOSED) {
                    closedCasesToBeTraced.add(cse);
                }
            }
            for(Case oldCase : closedCasesToBeTraced) {
                if(oldCase.RecordTypeId == consumerInquiryRecordTypeID) {
                    if(! existingCreatedCase.containsKey(oldCase.Id)) {
                        Case newCase = new Case();
                        for(Schema.fieldSetMember field : fieldMemberToCloneCase) {
                            newCase.put(field.getFieldPath() , oldCase.get(field.getFieldPath()));
                        }
                        newCase.ParentId = oldCase.Id;
                        newCase.Status = EmailMessageConstants.CASE_STATUS_NEW;
                        caseListToBeCreated.add(newCase);
                    }
                }
            } 
            if(! caseListToBeCreated.isEmpty()) {
                insert caseListToBeCreated;
                for(Case newCase : caseListToBeCreated) {
                    List<EmailMessage> emailmsglist = parentIdToEmailMessage.get(newCase.ParentId);
                    for(EmailMessage em : emailmsglist) {
                        em.ParentId = newCase.Id;
                    }
                }
            }
            system.debug('existingCreatedCase '+existingCreatedCase);
            for(ID parentId : existingCreatedCase.keySet()) {
                system.debug('coming  to update email thread id ---');
                List<EmailMessage> emailmsglist = parentIdToEmailMessage.get(parentId);
                for(EmailMessage em : emailmsglist){
                    em.ParentId = existingCreatedCase.get(parentId);
                }
            }
        }
    }


    public static void updateTimeToRespond(List<EmailMessage> emailMessages) {
        Set<Id> caseIdsOfOutgoingMsg = new Set<Id>();
        for(EmailMessage em : emailMessages) {
            if(em.Incoming == false)
            {
                caseIdsOfOutgoingMsg.add(em.ParentId);
            }
        }
        Id consumerInquiryRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumer_Inquiry').getRecordTypeId();
        Id qualityClaimRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Quality_Claim').getRecordTypeId();
        List<Case> listToBeUpdated = new List<Case>();

        List<Case> lstCasesOfOutgoingMsg = [SELECT Id, Time_To_Respond__c, status, CreatedDate, RecordTypeId,Total_Hours_To_First_Respond__c
                                            FROM Case WHERE Id IN :caseIdsOfOutgoingMsg];                                    

        for(Case c : lstCasesOfOutgoingMsg) {  
            if(c.RecordTypeId == consumerInquiryRecordTypeID || c.RecordTypeId == qualityClaimRecordTypeID) {
                if(c.Time_To_Respond__c == null) {
                    c.Time_To_Respond__c = System.now();
                }
                if(c.Total_Hours_To_First_Respond__c == null){
                    Decimal totalWorkingHours = calculateFirstResponseTime(c.CreatedDate, system.now());
                    c.Total_Hours_To_First_Respond__c = totalWorkingHours;
                }
                listToBeUpdated.add(c); 
            }                
        }      
        if(!listToBeUpdated.isEmpty()) {
            update listToBeUpdated;
        }
    }
    
    public static void updateAgentConsumerResponses(List<EmailMessage> emailMessages) {
        Set<Id> caseIds = new Set<Id>();
        Map<Id,List<EmailMessage>> parentIdToEmailMessage=new Map<Id,List<EmailMessage>>();
        for(EmailMessage em : emailMessages) {
            caseIds.add(em.ParentId);
            List<EmailMessage> emailMessageList;
            if(parentIdToEmailMessage.containsKey(em.ParentId)) { 
                emailMessageList = parentIdToEmailMessage.get(em.ParentId);
            } else {
                emailMessageList = new List<EmailMessage>();
            }
            emailMessageList.add(em);
            parentIdToEmailMessage.put(em.ParentId,emailMessageList);
        }
        Id consumerInquiryRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumer_Inquiry').getRecordTypeId();
        List<Case> lstCases = [SELECT Id,AgentResponseOnCase__c,ConsumerResponseOnCase__c,RecordTypeId
                               FROM Case 
                               WHERE Id IN :caseIds and status != :EmailMessageConstants.CASE_STATUS_CLOSED]; 
        List<Case> listToBeUpdated = new List<Case>();
        for(Case c : lstCases) {
            if(c.RecordTypeId == consumerInquiryRecordTypeID) {
                List<EmailMessage> emailList = parentIdToEmailMessage.get(c.Id);
                for(EmailMessage emailMessage:emailList) {
                    system.debug('coming in emailmessage loop .. values are--');
                    system.debug(emailMessage.Incoming +'-----');
                    system.debug(c.ConsumerResponseOnCase__c);
                    if(emailMessage.Incoming && c.ConsumerResponseOnCase__c !=null){
                        c.ConsumerResponseOnCase__c = c.ConsumerResponseOnCase__c + 1;
                    }
                    if(emailMessage.Incoming && c.ConsumerResponseOnCase__c ==null){
                        c.ConsumerResponseOnCase__c = 1;
                    }
                    if(!emailMessage.Incoming && c.AgentResponseOnCase__c !=null) {
                        c.AgentResponseOnCase__c = c.AgentResponseOnCase__c + 1;
                    }
                    if(!emailMessage.Incoming && c.AgentResponseOnCase__c ==null) {
                        c.AgentResponseOnCase__c = 1;
                    }
                    listToBeUpdated.add(c);    
                }
            }
        } 
        if(!listToBeUpdated.isEmpty()) {
            update listToBeUpdated;
        }
    }
    
    public static void updateBrandFamily(List<EmailMessage> emailMessages){
        List<Case> cases = new List<Case>();
        Map<String, String> mapHoldBrandWithIncomingAddress = new Map<String, String>();
        for(Brand_Incoming_Address_Mapping__mdt brandIncomingAdd : SLT_CustomMetadata.getBrandFromIncomingAddress()){
            mapHoldBrandWithIncomingAddress.put(brandIncomingAdd.Incoming_Address__c, brandIncomingAdd.Brand__c);
        }
        for(EmailMessage em : emailMessages) {
            if(String.isNotBlank(em.ToAddress)){
                if(mapHoldBrandWithIncomingAddress.containsKey(em.ToAddress)){
                    Case cse = new Case(ID = em.ParentId);
                    cse.Brand__c = mapHoldBrandWithIncomingAddress.get(em.ToAddress);
                    cse.Brand_Family__c = mapHoldBrandWithIncomingAddress.get(em.ToAddress);
                    cases.add(cse);
                } 
            }
        }
        if(!cases.isEmpty()) {
            upsert cases;
        }
    }
    
    public static void countCounsumerInquiryEmailTemplates(List<EmailMessage> emailMessages){
        List<Email_Template__c> emailtmp = new List<Email_Template__c>();  
        Set<String> EmailTemplateIds  = new Set<String>();
        Set<Id> CaseID = new Set<Id>(); 
        Set<Id> EmailId = new Set<Id>();
        Map<ID, List<EmailMessage> > caseToEmailMessage = new Map<ID, List<EmailMessage> >();
        for(EmailMessage em : emailMessages) {
            if(caseToEmailMessage.containsKey(em.ParentId)){
                (caseToEmailMessage.get(em.ParentId)).add(em);
            }
            else{
                caseToEmailMessage.put(em.ParentId, new List<EmailMessage>{em});    
            }
            CaseID.add(em.ParentId);
            EmailId.add(em.EmailTemplateId);
        }
        
        Map<String, Email_Template__c> existingTemplates = new Map<String, Email_Template__c>();
        for(Email_Template__c empTmp : [SELECT EmailTemplateId__c, Email_Template_Name__c, Used_Count__c 
                                      FROM Email_Template__c 
                                      WHERE EmailTemplateId__c In:EmailId]){
                                          existingTemplates.put(empTmp.EmailTemplateId__c, empTmp);
                                      }
        
        Map<Id, EmailTemplate> emailName = new Map<Id, EmailTemplate>([SELECT ID, Name 
                                                                              From EmailTemplate 
                                                                              Where id In:EmailId]);
                                                                              
        for (case c :[SELECT id from Case where id in:CaseID and RecordTypeId =: CSConstants.CONSUMER_INQUIRY_RT_ID ]) {
            for(EmailMessage e : caseToEmailMessage.get(c.Id)){
                if(existingTemplates.containsKey(e.EmailTemplateId)){
                    Email_Template__c emailRecord = existingTemplates.get(e.EmailTemplateId);
                    emailRecord.Used_Count__c += 1;
                    emailtmp.add(emailRecord);
                }else{
                    Email_Template__c emailRecord = new Email_Template__c();
                    String emlName = '';
                    if(e.EmailTemplateId != null && (emailName.get(e.EmailTemplateId)) != null){
                    emlName = (emailName.get(e.EmailTemplateId)).Name;
                    emailRecord.Email_Template_Name__c = emlName;
                    emailRecord.EmailTemplateId__c = e.EmailTemplateId;
                    existingTemplates.put(e.EmailTemplateId, emailRecord);
                    emailtmp.add(emailRecord);
                    }
                }
            }
        }  
        if(!emailtmp.isEmpty()){
            upsert emailtmp;
        }  
    }
    
    /**
    * @description This method is used to capture the total working hours taken for the first response.
    * @author Jaiveer Jha | 11-01-2023 
    * @param startDate 
    * @param endDate 
    * @return Integer 
    **/
    public static Decimal calculateFirstResponseTime(Datetime startDate, Datetime endDate) {
        Decimal workingHours = 8;
        Decimal hoursToRespond = 0;
        Boolean firstStartTimeCapture = true;
        DateTime CreatedDate = startDate;
        while (startDate.dateGMT() <= endDate.dateGMT()) {
            if (startDate.format('E') != 'Sat' && startDate.format('E') != 'Sun') {
                if(startDate.hourGmt() >= 17 && firstStartTimeCapture && !(startDate.dateGMT() == endDate.dateGMT())){
                    hoursToRespond = 24 - (startDate.hourGmt() + Decimal.valueOf(startDate.minuteGmt())/Decimal.valueOf(60));
                    if(CreatedDate.format('E') == 'Sat' || CreatedDate.format('E') == 'Sun'){
                        hoursToRespond = workingHours;
                    }
                    firstStartTimeCapture = false;
                }else{
                    if(startDate.dateGMT() == endDate.dateGMT() && endDate.hourGmt() <= 7 && CreatedDate.dateGMT() != endDate.dateGMT()){
                        hoursToRespond = hoursToRespond + (endDate.hourGmt() + Decimal.valueOf(endDate.minuteGmt())/Decimal.valueOf(60));
                    }else{
                        hoursToRespond = hoursToRespond + workingHours;
                    }
                }
            }
            startDate = startDate.addDays(1);
        }
        if(hoursToRespond == workingHours){
            Decimal hoursDiff = (Decimal.valueOf(endDate.getTime()) - Decimal.valueOf(startDate.addDays(-1).getTime()))/Decimal.valueOf((1000*60*60));
            hoursToRespond = (hoursDiff < workingHours && hoursDiff > 0) ? hoursDiff : workingHours ;
        }
        return hoursToRespond.setScale(3);
    }
    
    public static void updateBrandOnCaseRecord(List<EmailMessage> emailMessages){
        List<Case> updateCases = new List<Case>();
        for(EmailMessage eMessage : emailMessages){
            Case updateCase = new Case();
            updateCase.Id = eMessage.ParentId;
            if(eMessage.ToAddress == DTC_Constants.WHISKYDROP_MM){
                updateCase.Brand__c = DTC_Constants.BRAND_MAKERS_MARK_APPOS;
                updateCase.How_can_we_help__c = DTC_Constants.WHISKY_DROP;
                updateCase.AdditionalInformation__c = DTC_Constants.ADDITIONAL_INFORMATION_OTHER;
            }else if(eMessage.ToAddress == DTC_Constants.BARREDANDBOXED_BD) {
                updateCase.Brand__c = DTC_Constants.BRAND_JIM_BEAM;
                updateCase.How_can_we_help__c = DTC_Constants.BARRELED_BOXED;
                updateCase.AdditionalInformation__c = DTC_Constants.ADDITIONAL_INFORMATION_OTHER;
            }
            updateCases.add(updateCase);
        }
        if(updateCases.size()>0){
            update updateCases;
        }
    }
}