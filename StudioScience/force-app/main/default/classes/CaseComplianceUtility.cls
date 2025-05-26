public without sharing class CaseComplianceUtility {

    //Format Sample
    /**
    * Object:           Case
    * Record Type:      
    * Functionality:    
    *
    *
    *
    */
    // used to bypass compliance trigger hanlder methods
    public static Boolean runCaseComplianceTriggerLogic = true;

    public static void doBrandRegistrationBeforeInsert(List<Case> newCases){
        String brandRegistrationRTName = ComplianceConstants.RECORDTYPE_BRAND_REGISTRATION;
        Id brandRegistrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(brandRegistrationRTName).getRecordTypeId();
        String projNumber = ComplianceConstants.BRAND_REG_PROJ_NUMBER_DEFAULT;


        for(Case currCase: newCases){
            if(currCase.RecordTypeId == brandRegistrationRecordTypeId){
                if(currCase.Project_Number__c == null){
                    currCase.Project_Number__c = projNumber;
                }
            }
        }
    }


    /**
    * Object:           Case
    * Record Type:      Brand Registration
    * Functionality:    When a 'Brand Registration' Case is kicked off, send an email to the Compliance team using the Email Template,
    *                   including Content Documents marked as Document Type == 'Kickoff' as Email Attachments.
    *                   This method is run in the "After Update" context, as no changes are made to the Case
    *
    */
    public static void doComplianceKickoff(List<Case> newCases, Map<Id, Case> oldMap){
        String brandRegistrationRTName = ComplianceConstants.RECORDTYPE_BRAND_REGISTRATION;
        Id brandRegistrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(brandRegistrationRTName).getRecordTypeId();
        Map<Id, Case> actionableCaseMap = new Map<Id, Case>();
        //Added to create Brand Registration subcases after kick off 
        Map<Id, Case> subCaseMap= new Map<Id, Case>();
        for(Case currCase: newCases){
            if(currCase.RecordTypeId == brandRegistrationRecordTypeId){
                if(currCase.Kick_Off_Brand_Registration__c && !oldMap.get(currCase.Id).Kick_Off_Brand_Registration__c){
                    actionableCaseMap.put(currCase.Id, currCase);
                }else if((currCase.VAP_LTO_Allocation_picklist__c== 'No' && oldMap.get(currCase.Id).VAP_LTO_Allocation_picklist__c != 'No') || (currCase.Traypack_Audit_picklist__c== 'No' && oldMap.get(currCase.Id).Traypack_Audit_picklist__c != 'No') || (currCase.Giftshop_Pricing__c== 'No' && oldMap.get(currCase.Id).Giftshop_Pricing__c != 'No'))
                    subCaseMap.put(currCase.Id, currCase);
            }
        }
        if(actionableCaseMap.size() > 0){
            sendEmailOnBrandRegistrationKickoff(actionableCaseMap);
            createBrandRegistrationSubCases(actionableCaseMap.keySet());
        }
        if(subCaseMap.size() > 0)
            createBrandRegistrationSubCasesAfterUpdate(subCaseMap);
    }
    
    //Added r.e.f SAL-650 
    /**
    *  @description : When a 'Brand Registration' Case is kicked off, then if we update the parent case Kick off for VAP/LTO Allocation
    *                 and TrayPack Audit then the subcases are created if they are not already created for these 2 Case Type. 
    *  @args        : Map<Id, Case> subCaseMap
    **/
    public static void createBrandRegistrationSubCasesAfterUpdate(Map<Id, Case> subCaseMap){
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.useDefaultRule = true;
        string typeVapLTOAllocation   = ComplianceConstants.SUB_CASE_TYPE_VAP_LTO_ALLOCATION;
        string typeTraypackAudit  =   ComplianceConstants.SUB_CASE_TYPE_TRAY_PACK_AUDIT;
        string typeGiftshopPricing  =   ComplianceConstants.SUB_CASE_TYPE_GIFTSHOP_PRICING;
        string InquiryRTName = ComplianceConstants.RECORDTYPE_INQUIRY;
        Id InquirySubCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(InquiryRTName).getRecordTypeId();
        
        String subCaseRTName = ComplianceConstants.RECORDTYPE_SUB_CASE;
        String brandRegistrationRTName = ComplianceConstants.RECORDTYPE_BRAND_REGISTRATION;
        String typeBrandRegistration = ComplianceConstants.SUB_CASE_TYPE_BRAND_REGISTRATION;
        Id brandRegistrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(brandRegistrationRTName).getRecordTypeId();
        Id complianceSubCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(subCaseRTName).getRecordTypeId();
        List<Case> casesToInsert = new List<Case>();
        
        //Added by Deekshika 19-12-2022 - Operation with limits in loop
        List<Case> casesWithParentId = [SELECT Id, RecordTypeId, Type, ParentId from Case where ParentId IN: subCaseMap.keySet()];
        for(Id parentId: subCaseMap.keySet()){
            Case parentCase = subCaseMap.get(parentId);
            //System.debug(LoggingLevel.INFO, actionableCaseMap.get(parentId).Available_States__c);
            Set<String> childCases= new Set<String>();
            //Added by Deekshika 19-12-2022 - Operation with limits in loop
            for(Case c : casesWithParentId) {
                if(c.ParentId == parentId) {
                    childCases.add(c.Type);
                }
            }
            System.debug('childCases'+ childCases);
            System.debug('typeTraypackAudit'+ typeTraypackAudit);
            System.debug('typeVapLTOAllocation' + typeVapLTOAllocation);
            if(parentCase.Traypack_Audit_picklist__c== 'No' && !childCases.contains(typeTraypackAudit)){   
                // Creating 2 more Compliance Sub Cases with the type Tray Pack, VLO
                Case subCase2 = new Case();
                subCase2.RecordTypeId=complianceSubCaseRecordTypeId;
                subCase2.Type = typeTraypackAudit;
                subCase2.Origin = 'Console';
                subCase2.ParentId = parentCase.Id;
                subcase2.Status ='Not Submitted';
                
                casesToInsert.add(subCase2);
                
            }     
            if(parentCase.VAP_LTO_Allocation_picklist__c == 'No' && !childCases.contains(typeVapLTOAllocation)){
                Case subCase3 = new Case();
                subCase3.RecordTypeId=complianceSubCaseRecordTypeId;
                subCase3.Type = typeVapLTOAllocation;
                subCase3.Origin = 'Console';
                subcase3.Status ='Not Submitted';
                subCase3.ParentId = parentCase.Id;
                
                casesToInsert.add(subCase3);
                
            }
            // Added by Shubham Khandelwal for SAL-5035
            if(parentCase.Giftshop_Pricing__c== 'No' && !childCases.contains(typeGiftshopPricing)){   
                // Creating new Compliance Sub Cases with the type Giftshop Pricing
                Case subCase4 = new Case();
                subCase4.RecordTypeId=complianceSubCaseRecordTypeId;
                subCase4.Type = typeGiftshopPricing;
                subCase4.Origin = 'Console';
                subCase4.ParentId = parentCase.Id;
                subcase4.Status ='Not Submitted';
                
                casesToInsert.add(subCase4);
            }    
            
        }
        
        if(!casesToInsert.isEmpty()){
            Savepoint sp = Database.setSavepoint();
            try{
                insert casesToInsert;
            } catch(Exception e){
                Database.rollback(sp);
                for(Case c: subCaseMap.values()){
                    c.addError(e.getMessage());
                }
            }
        }
    }

    public static void setFlagOnBrandRegistrationBeforeUpdate(List<Case> newCases, Map<Id, Case> oldMap){
        String brandRegistrationRTName = ComplianceConstants.RECORDTYPE_BRAND_REGISTRATION;
        Id brandRegistrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(brandRegistrationRTName).getRecordTypeId();
        Map<Id, Case> kickedOffCaseMap = new Map<Id, Case>();
        Map<Id, Case> submittedCaseMap = new Map<Id, Case>();
        for(Case currCase: newCases){
            if(currCase.RecordTypeId == brandRegistrationRecordTypeId){
                if(currCase.Kick_Off_Brand_Registration__c && !oldMap.get(currCase.Id).Kick_Off_Brand_Registration__c){
                    kickedOffCaseMap.put(currCase.Id, currCase);
                } else if(currCase.Submitted_Compliance__c && !oldMap.get(currCase.Id).Submitted_Compliance__c){
                    submittedCaseMap.put(currCase.Id, currCase);
                }
            }
        }
        if(kickedOffCaseMap.size() > 0){
            String brandRegistrationKickoffFlag = ComplianceConstants.FLAG_BRAND_REG_KICKED_OFF;
            for(Case currCase: kickedOffCaseMap.values()){
                currCase = setComplianceFlagsetValue(currCase, brandRegistrationKickoffFlag);
            }
        }

        if(submittedCaseMap.size() > 0){
            String brandRegistrationSubmitted = ComplianceConstants.FLAG_BRAND_REG_ALL_SUB_CASES_CLOSED;
            for(Case currCase: submittedCaseMap.values()){
                currCase = setComplianceFlagsetValue(currCase, brandRegistrationSubmitted);
            }
        }
    }

    /**
    * Object:           Case
    * Record Type:      Price Filing
    * Functionality:    A Utility method that is called from the SetPriceFilingApprovalComponent Lightning Component's
    *                   Apex Controller. Depending on if the Workbook was Approved or Rejected, queries an email template
    *                   accordingly and sends an email to the Case Owner, Case's State Manager, and the Email Service Address.
    *                   
    */
    public static void sendEmailOnPriceFilingApprovalStatusChange(String caseId, Boolean response){
        String emailServiceAddress = ComplianceConstants.EMAIL_SERVICE_ADDRESS;
        String systemUserId = ComplianceConstants.SYSTEM_EMAIL_USER_ID;
        String priceFilingApprovedTemplateName = ComplianceConstants.PRICE_FILING_WORKBOOK_APPROVED;
        String priceFilingRejectedTemplateName = ComplianceConstants.PRICE_FILING_WORKBOOK_REJECTED;
        String finalTemplateName = response ? priceFilingApprovedTemplateName : priceFilingRejectedTemplateName;
        Id finalTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName=:finalTemplateName].Id;
        Case currCase = [SELECT Id, Owner.Email, State_Manager_Email__c FROM Case WHERE Id =: caseId];
        
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(finalTemplateId, systemUserId, currCase.Id);
        mail.setSaveAsActivity(false);
        mail.setTargetObjectId(currCase.OwnerId);
        List<String> toAddressList = new List<String>();
        List<String> ccAddressList = new List<String>{emailServiceAddress};
        if(String.isNotBlank(currCase.Owner.Email)){
            toAddressList.add(currCase.Owner.Email);
        }
        if(String.isNotBlank(currCase.State_Manager_Email__c)){
            toAddressList.add(currCase.State_Manager_Email__c);
        }
        System.debug(LoggingLevel.INFO, toAddressList);
        mail.setToAddresses(toAddressList);
        mail.setCcAddresses(ccAddressList);
        mail.setWhatId(currCase.Id);
        allMails.add(mail);
        Messaging.sendEmail(allMails);
    }

    /**
    * Object:           Case
    * Record Type:      Brand Registration
    * Functionality:    When a 'Brand Registration' Case is kicked off, send an email to the Compliance team using the Email Template,
    *                   including Content Documents marked as Document Type == 'Kickoff' as Email Attachments.
    *                   This method is run in the "After Update" context, as no changes are made to the Case
    *
    */
    public static void sendEmailOnBrandRegistrationKickoff(Map<Id, Case> actionableCaseMap){
        List<Id> caseIdList = new List<Id>(actionableCaseMap.keySet());
        String documentTypeFilter = ComplianceConstants.DOCUMENT_TYPE_KICKOFF;
        List<String> cvIdList = new List<String>();
        Id senderId = UserInfo.getUserId();

        Map<Id, ContentDocumentLink> contentDocumentToLinkMap = new Map<Id, ContentDocumentLink>();
        List<ContentDocumentLink> cdLinkList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: caseIdList];
        for(ContentDocumentLink cdl: cdLinkList){
            contentDocumentToLinkMap.put(cdl.ContentDocumentId, cdl);
        }

        Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE 
                                                                        Document_Type__c=: documentTypeFilter AND 
                                                                        IsLatest=true AND 
                                                                        ContentDocumentId IN: contentDocumentToLinkMap.keySet()]);
        Map<Id, List<Id>> caseToCVMap = new Map<Id, List<Id>>();
        for(ContentVersion cv: cvMap.values()){
            Id entityId = contentDocumentToLinkMap.get(cv.ContentDocumentId).LinkedEntityId;
            if(!caseToCVMap.containsKey(entityId)){
                caseToCVMap.put(entityId, new List<Id>{cv.Id});
            } else {
                caseToCVMap.get(entityId).add(cv.Id);
            }
        }
        String brKickoffTemplateName = ComplianceConstants.BRAND_REG_KICK_OFF_TEMPLATE_API_NAME;
        String emailServiceAddress = ComplianceConstants.EMAIL_SERVICE_ADDRESS;
        String complianceAddress = ComplianceConstants.COMPLIANCE_ADDRESS;
        EmailTemplate brKickoffTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: brKickoffTemplateName LIMIT 1];
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        for(Id caseId: actionableCaseMap.keySet()){
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(brKickoffTemplate.Id, senderId, caseId);
            if(String.isNotBlank(actionableCaseMap.get(caseId).ContactId)){ 
                mail.setSaveAsActivity(true);
                mail.setTargetObjectId(actionableCaseMap.get(caseId).ContactId);
            } else {
                mail.setSaveAsActivity(false);
            }
            mail.setCcAddresses(new List<String>{UserInfo.getUserEmail(), emailServiceAddress});
            mail.setToAddresses(new List<String>{complianceAddress});
            mail.setWhatId(caseId);
            if(caseToCVMap.containsKey(caseId)){
                mail.setEntityAttachments(caseToCVMap.get(caseId));
            }
            allMails.add(mail);
        }
        Messaging.sendEmail(allMails);
    }

    /**
    * Object:           Case
    * Record Type:      Price Filing
    * Functionality:    When a 'Blank Workbook' is uploaded to a 'Price Filing' Case, send an email to the State Manager and Commercial Finance user
    *                   using the Email Template, including Content Documents marked as Document Type == 'Blank Workbook' as Email Attachments.
    *                   This method is run in the "After Update" context, as no changes are made to the Case
    *
    */
    public static void sendEmailOnPriceFilingBlankBookUpload(Map<Id, Case> actionableCaseMap){
        List<Id> caseIdList = new List<Id>(actionableCaseMap.keySet());

        String documentTypeFilter = 'Blank Workbook';
        List<String> cvIdList = new List<String>();

        Map<Id, ContentDocumentLink> contentDocumentToLinkMap = new Map<Id, ContentDocumentLink>();
        List<ContentDocumentLink> cdLinkList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: caseIdList];
        for(ContentDocumentLink cdl: cdLinkList){
            contentDocumentToLinkMap.put(cdl.ContentDocumentId, cdl);
        }

        Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE 
                                                                        Document_Type__c=: documentTypeFilter AND 
                                                                        IsLatest=true AND 
                                                                        ContentDocumentId IN: contentDocumentToLinkMap.keySet() ORDER BY CreatedDate]);
        Map<Id, List<Id>> caseToCVMap = new Map<Id, List<Id>>();
        for(ContentVersion cv: cvMap.values()){
            Id entityId = contentDocumentToLinkMap.get(cv.ContentDocumentId).LinkedEntityId;
            if(!caseToCVMap.containsKey(entityId)){
                caseToCVMap.put(entityId, new List<Id>{cv.Id});
            } else {
                caseToCVMap.get(entityId).add(cv.Id);
            }
        }

        String emailServiceAddress = ComplianceConstants.EMAIL_SERVICE_ADDRESS;
        String systemUserId = ComplianceConstants.SYSTEM_EMAIL_USER_ID;
        String priceFilingBlankWorkbookTemplateName = ComplianceConstants.PRICE_FILING_BLANK_WORKBOOK_UPLOADED;
        EmailTemplate priceFilingBlankWorkbookTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: priceFilingBlankWorkbookTemplateName LIMIT 1];
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        for(Id caseId: actionableCaseMap.keySet()){
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(priceFilingBlankWorkbookTemplate.Id, systemUserId, caseId);
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(actionableCaseMap.get(caseId).OwnerId);
            mail.setToAddresses(new List<String>{actionableCaseMap.get(caseId).State_Manager_Email__c});
            mail.setCCAddresses(new List<String>{emailServiceAddress});
            mail.setWhatId(caseId);
            if(caseToCVMap.containsKey(caseId)){
                mail.setEntityAttachments(new List<Id>{caseToCVMap.get(caseId)[0]});
            }
            allMails.add(mail);
        }
        Messaging.sendEmail(allMails);
    }

    /**
    * Object:           Case
    * Record Type:      Price Filing
    * Functionality:    When a 'Finalized Workbook' is uploaded to a 'Price Filing' Case, send an email to the State Manager and Commercial Finance user
    *                   using the Email Template, including Content Documents marked as Document Type == 'Finalized Workbook' as Email Attachments.
    *                   This method is run in the "After Update" context, as no changes are made to the Case
    *
    */
    public static void sendEmailOnPriceFilingFinalizedBookUpload(Map<Id, Case> actionableCaseMap){
        List<Id> caseIdList = new List<Id>(actionableCaseMap.keySet());

        String documentTypeFilter = 'Finalized Workbook';
        List<String> cvIdList = new List<String>();


        Map<Id, ContentDocumentLink> contentDocumentToLinkMap = new Map<Id, ContentDocumentLink>();
        List<ContentDocumentLink> cdLinkList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: caseIdList];
        for(ContentDocumentLink cdl: cdLinkList){
            contentDocumentToLinkMap.put(cdl.ContentDocumentId, cdl);
        }

        Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE 
                                                                        Document_Type__c=: documentTypeFilter AND 
                                                                        IsLatest=true AND 
                                                                        ContentDocumentId IN: contentDocumentToLinkMap.keySet() ORDER BY CreatedDate]);
        Map<Id, List<Id>> caseToCVMap = new Map<Id, List<Id>>();
        for(ContentVersion cv: cvMap.values()){
            Id entityId = contentDocumentToLinkMap.get(cv.ContentDocumentId).LinkedEntityId;
            if(!caseToCVMap.containsKey(entityId)){
                caseToCVMap.put(entityId, new List<Id>{cv.Id});
            } else {
                caseToCVMap.get(entityId).add(cv.Id);
            }
        }
        String emailServiceAddress = ComplianceConstants.EMAIL_SERVICE_ADDRESS;
        String systemUserId = ComplianceConstants.SYSTEM_EMAIL_USER_ID;
        String commercialFinanceAddress = ComplianceConstants.COMMERCIAL_FINANCE_ADDRESS;
        String priceFilingFinalizedWorkbookTemplateName = ComplianceConstants.PRICE_FILING_FINALIZED_WORKBOOK_UPLOADED;
        EmailTemplate priceFilingFinalizedWorkbookTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: priceFilingFinalizedWorkbookTemplateName LIMIT 1];
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        for(Id caseId: actionableCaseMap.keySet()){
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(priceFilingFinalizedWorkbookTemplate.Id, systemUserId, caseId);
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(actionableCaseMap.get(caseId).OwnerId);
            mail.setToAddresses(new List<String>{commercialFinanceAddress});
            mail.setCCAddresses(new List<String>{emailServiceAddress});
            mail.setWhatId(caseId);
            if(caseToCVMap.containsKey(caseId)){
                mail.setEntityAttachments(new List<Id>{caseToCVMap.get(caseId)[0]});
            }
            allMails.add(mail);
        }
        Messaging.sendEmail(allMails);
    }

    /**
    * Object:           Case
    * Record Type:      Quote Request
    * Functionality:    A Utility method that is called from the SetPriceFilingApprovalComponent Lightning Component's
    *                   Apex Controller. Sends an email to the Case's State Manager and the Owner using the Quote Request
    *                   Item Availability Email Template.
    *
    */
    public static void sendEmailQuoteRequestItemAvailability(Id caseId){
        Case currCase = [SELECT Id, OwnerId, State_Manager_Email__c FROM Case WHERE Id =: caseId LIMIT 1];
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        String emailServiceAddress = ComplianceConstants.EMAIL_SERVICE_ADDRESS;
        String systemUserId = ComplianceConstants.SYSTEM_EMAIL_USER_ID;
        String qrItemAvailability = ComplianceConstants.QUOTE_REQUEST_ITEM_AVAILABILITY;
        EmailTemplate qrItemAvailabilityTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: qrItemAvailability LIMIT 1];
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(qrItemAvailabilityTemplate.Id, systemUserId, caseId);
        mail.setSaveAsActivity(false);
        mail.setTargetObjectId(currCase.OwnerId);
        List<String> toAddressList = new List<String>();
        if(String.isNotBlank(currCase.State_Manager_Email__c)){
            toAddressList.add(currCase.State_Manager_Email__c);
        }
        mail.setToAddresses(toAddressList);
        mail.setCCAddresses(new List<String>{emailServiceAddress, UserInfo.getUserEmail()});
        mail.setWhatId(caseId);
        allMails.add(mail);
        //Messaging.sendEmail(allMails);
        //
        
        
        
        String quoteRequestRTName = ComplianceConstants.RECORDTYPE_QUOTE_REQUEST;
        Id quoteRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(quoteRequestRTName).getRecordTypeId();
        
        String complianceCommunitySiteUrl = 'https://beam.force.com/compliance';


        List<Quote_Request__c> quotes = [SELECT Id, Item_Name__c, State__c, Item_Size__c, Item_Available__c, Price_Needed__c, Case__c FROM Quote_Request__c WHERE Case__c =:caseId];
    

        //For Cases that have one or more Items Available
        List<Quote_Request__c> availablePriceNeededQuoteList = new List<Quote_Request__c>();
        for(Quote_Request__c quote: quotes){
            if(quote.Item_Available__c == 'Yes' && quote.Price_Needed__c == 'Yes'){
                availablePriceNeededQuoteList.add(quote);
            }
        }


            if(!availablePriceNeededQuoteList.isEmpty()){
                String subjectItems = '';
                String emailHtmlItemBody = '';
                String emailPlainTextItemBody = '';
                for(Quote_Request__c quote: availablePriceNeededQuoteList){
                    emailHtmlItemBody += '<a href="'+complianceCommunitySiteUrl+'/s/detail/'+quote.Id+'">'+quote.Item_Name__c+'</a> - '+quote.State__c+' - '+quote.Item_Size__c+'<br></br>';
                    //emailHtmlItemBody += quote.Item_Name__c + '<br></br>';
                    emailPlainTextItemBody += quote.Item_Name__c +' - '+quote.State__c+' - '+quote.Item_Size__c+'\n';
                }

                if(availablePriceNeededQuoteList.size() > 1){
                    subjectItems = 'Multiple Items';
                } else if(availablePriceNeededQuoteList.size() == 1){
                    subjectItems = availablePriceNeededQuoteList.get(0).Item_Name__c;
                }
            
            

        String commercialFinanceAddress = ComplianceConstants.COMMERCIAL_FINANCE_ADDRESS;               
        String qrPriceNeeded = ComplianceConstants.QUOTE_REQUEST_PRICE_NEEDED_FROM_FINANCE;
        EmailTemplate qrPriceNeededTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: qrPriceNeeded LIMIT 1];

            Messaging.SingleEmailMessage mail1 = Messaging.renderStoredEmailTemplate(qrPriceNeededTemplate.Id, systemUserId, currCase.Id);
            mail1.setSubject(mail1.getSubject().replace('[item-name]', subjectItems));
            mail1.setHTMLBody(mail1.getHTMLBody().replace('[items-body]', emailHtmlItemBody));
            mail1.setPlainTextBody(mail1.getPlainTextBody().replace('[items-body]', emailPlainTextItemBody));
            mail1.setSaveAsActivity(false);
            mail1.setTargetObjectId(currCase.OwnerId);
            mail1.setToAddresses(new List<String>{commercialFinanceAddress});
            
            List<String> ccAddressList = new List<String>{emailServiceAddress};
            if(String.isNotBlank(currCase.State_Manager_Email__c)){
                ccAddressList.add(currCase.State_Manager_Email__c);
            }

            mail1.setCCAddresses(ccAddressList);
            mail1.setWhatId(currCase.Id);
            allMails.add(mail1);
            }   
            System.debug(LoggingLevel.INFO, allMails.size());
            Messaging.sendEmail(allMails);
        
    }

    /**
    * Object:           Case
    * Record Type:      Brand Registration
    * Functionality:    Create new Cases with Record Type "Compliance Sub Case" and Type "Brand Registration"
    *                   One case for each state selected on the Parent Case's "Available States" multi-select picklist
    *
    * TBD:              Assign ownership of each Sub Case to corresponding state's Queue?
    */
    @future
    public static void createBrandRegistrationSubCases(Set<id> parentCases){
        Database.DMLOptions dmo = new Database.DMLOptions();
	Map<id,Case> actionableCaseMap = new Map<id,Case>([Select id,RecordTypeId,Available_States__c,Due_Date__c,Traypack_Audit_picklist__c,VAP_LTO_Allocation_picklist__c,Pallet_Moving_for_France_SKU__c,Description,Giftshop_Pricing__c  from Case where id =:parentCases]);
        dmo.AssignmentRuleHeader.useDefaultRule = true;
        string typeVapLTOAllocation   = ComplianceConstants.SUB_CASE_TYPE_VAP_LTO_ALLOCATION;
        string typeTraypackAudit  =   ComplianceConstants.SUB_CASE_TYPE_TRAY_PACK_AUDIT;
        string  typeGiftshopPricing =   ComplianceConstants.SUB_CASE_TYPE_GIFTSHOP_PRICING;
        string InquiryRTName = ComplianceConstants.RECORDTYPE_INQUIRY;
        Id InquirySubCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(InquiryRTName).getRecordTypeId();

        String subCaseRTName = ComplianceConstants.RECORDTYPE_SUB_CASE;
        String brandRegistrationRTName = ComplianceConstants.RECORDTYPE_BRAND_REGISTRATION;
        String typeBrandRegistration = ComplianceConstants.SUB_CASE_TYPE_BRAND_REGISTRATION;
        Id brandRegistrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(brandRegistrationRTName).getRecordTypeId();
        Id complianceSubCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(subCaseRTName).getRecordTypeId();
        List<Case> casesToInsert = new List<Case>();

        for(Id parentId: actionableCaseMap.keySet()){
            Case parentCase = actionableCaseMap.get(parentId);
            System.debug(LoggingLevel.INFO, actionableCaseMap.get(parentId).Available_States__c);
            if(parentCase.RecordTypeId == brandRegistrationRecordTypeId && parentCase.Available_States__c != null){ 
                List<String> subCaseStates = (parentCase.Available_States__c).split(';');
                for(String state: subCaseStates){
                    Case subCase = new Case(RecordTypeId=complianceSubCaseRecordTypeId);
                    subCase.State__c = state;
                    subCase.Type = typeBrandRegistration;
                    subCase.Origin = 'Console';
                    subCase.ParentId = parentCase.Id;
                    subCase.Due_Date__c = parentCase.Due_Date__c;
                    subCase.setOptions(dmo);
                    casesToInsert.add(subCase);
                    
                }
                
            }
             if(parentCase.Traypack_Audit_picklist__c== 'No'){   
             // Creating 2 more Compliance Sub Cases with the type Tray Pack, VLO
                Case subCase2 = new Case();
                subCase2.RecordTypeId=complianceSubCaseRecordTypeId;
                subCase2.Type = typeTraypackAudit;
                subCase2.Origin = 'Console';
                subCase2.ParentId = parentCase.Id;
                subcase2.Status ='Not Submitted';
               
                casesToInsert.add(subCase2);

               }     
            if(parentCase.VAP_LTO_Allocation_picklist__c == 'No'){
                Case subCase3 = new Case();
                subCase3.RecordTypeId=complianceSubCaseRecordTypeId;
                subCase3.Type = typeVapLTOAllocation;
                subCase3.Origin = 'Console';
                subcase3.Status ='Not Submitted';
                subCase3.ParentId = parentCase.Id;
              
                casesToInsert.add(subCase3);
 
               }
               if(parentCase.Pallet_Moving_for_France_SKU__c){
                Case subCase4 = new Case();
                subCase4.RecordTypeId=InquirySubCaseRecordTypeId;
                subCase4 .Type = 'France Pallet Rounding';
                subCase4 .Additional_Details_Rich_Text__c=parentCase.Description;
                subCase4.Status= 'New';
                subCase4 .Origin = 'Console';
                subCase4 .ParentId = parentCase.Id;

                casesToInsert.add(subCase4);
               }
            // Added by Shubham Khandelwal for SAL-5035
            if(parentCase.Giftshop_Pricing__c=='No'){
                Case subCase5 = new Case();
                subCase5.RecordTypeId=complianceSubCaseRecordTypeId;
                subCase5 .Type = typeGiftshopPricing;
                subCase5.Status= 'Not Submitted';
                subCase5 .Origin = 'Console';
                subCase5 .ParentId = parentCase.Id;

                casesToInsert.add(subCase5);
               }
            system.debug('casesToInsert------>');
            system.debug(casesToInsert);
            system.debug(casesToInsert.size());
        }
      
        if(!casesToInsert.isEmpty()){
            Savepoint sp = Database.setSavepoint();
            try{
                insert casesToInsert;
            } catch(Exception e){
                Database.rollback(sp);
                for(Case c: actionableCaseMap.values()){
                    c.addError(e.getMessage());
                }
            }
        }
    }
     
    /************************************************************************************************************************************************
    Description:    This method is used to create subcase for Customer data queue once the brand registration kick off gets initiated 
                  
    <Date>      <Authors Name>     <Company>     <Brief Description of Change>
    7/30/2020    Sripal Kotha         TCS              Initial Creation
    ************************************************************************************************************************************************/
    
    public static void kickoffCustomerdata(List <Case> cases, Map<Id, Case> oldMap) {
        String subCaseRTName = ComplianceConstants.RECORDTYPE_SUB_CASE;
        String brandRegistrationRTName = ComplianceConstants.RECORDTYPE_BRAND_REGISTRATION;
        string customerDataRTName = ComplianceConstants.RECORDTYPE_CUSTOMER_DATA;
        string typeVapLTOAllocation   = ComplianceConstants.SUB_CASE_TYPE_VAP_LTO_ALLOCATION;
        //Id BrandRegistrationId= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Brand_Registration').getRecordTypeId();
        Id CustomerDataId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(customerDataRTName).getRecordTypeId();
        Id BrandRegistrationId= Schema.SObjectType.Case.getRecordTypeInfosByName().get(brandRegistrationRTName).getRecordTypeId();
        Id complianceSubCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(subCaseRTName).getRecordTypeId();

        Map<Id,Case>NewCaseRecMap = new Map<id,Case>();
        for(Case caserec: Cases){
           if(!NewCaseRecMap.containskey(caserec.Id)){
                NewCaseRecMap.put(caserec.Id,caserec);
           }else{
               NewCaseRecMap.get(caserec.Id);
           }
        }
        
        List<Case>casesToInsert = new List<Case>();
        set<Id>ParentCaseIds = new Set<Id>();
        List<Case>ParentCases = [Select Id, RecordTypeId, CaseNumber,Due_Date__c,Available_States__c, Status,Type,Brand__c,Customer_Data__c,Traypack_Audit__c,VAP_LTO_Allocation__c,
                                 Pallet_Moving_for_France_SKU__c ,Giftshop_Pricing__c,In_field_Date__c,Customerdata_Created__c,Additional_Details_Rich_Text__c From Case Where Id IN: oldMap.keySet()];
        for(Case c :ParentCases) {
            ParentCaseIds.add(c.id);
            if(c.Id != null ){
            if (c.RecordTypeId == BrandRegistrationId  && ('Waiting for Sub Cases'.equalsIgnoreCase(c.Status))) {
              if(c.customer_Data__c && !c.Customerdata_Created__c /*c.customer_Data__c!= oldMap.get(c.Id).Customer_Data__c*/ ){
                System.debug('Trigger New Map:::'+Trigger.newMap.get(c.Id));
                Case newSubCase = (Case) Trigger.newMap.get(c.Id).clone(false, false, false, false);
                newSubCase.ParentId = c.Id;
                newSubCase.Status = 'New'; 
                newSubCase.Sub_Status__c = null;
                newSubCase.Available_States__c ='';
                newSubCase.Type = 'Other';
                newSubcase.In_field_Date__c=c.In_field_Date__c;
                newSubcase.Additional_Details_Rich_Text__c=c.Additional_Details_Rich_Text__c;
                newSubCase.RecordTypeId = CustomerDataId;
                casesToInsert.add(newSubCase);
             }    
             c.Customerdata_Created__c =true;
            }
            
         }
      }
          update ParentCases;
          if (!casesToInsert.isEmpty()) {
            try {
                insert casesToInsert;
             } catch (Exception e) {
                String errorMessage = 'Error creating cases ' + e.getMessage() + '\n' + e.getStackTraceString();
                CreateExceptionLog.insertErrorLog('caseServices', 'kickoffCustomerdata', String.valueOf(errorMessage), 'Fatal');
                // throw so that we can detect issues before deploying
                if (Test.isRunningTest()) {
                    throw new CS_CustomException(e.getMessage());
            }
            
          }
           
       } 
        
     /*List<Case> childCases = new List<Case>();
     childCases = [SELECT id,CaseNumber FROM Case WHERE ParentId IN:ParentCaseIds  AND (Recordtype.DeveloperName='Customer_Data' OR Recordtype.DeveloperName='Inquiry')];
     List<ContentDocument> DocumentList = new List<ContentDocument>();  
     Set<Id> documentIds = new Set<Id>();  //store file ids
     List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
     if(ParentCaseIds.size()>0){
      cdl=[select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink 
                                    where LinkedEntityId IN:ParentCaseIds];
      }                                
     for(ContentDocumentLink cdLink:cdl){  
       documentIds.add(cdLink.ContentDocumentId);  // Document ids
     }
     
         List<ContentDocumentLink> childcontdoclist = new  List<ContentDocumentLink>();
         List<ContentDocumentLink> Existingcontdoclist = new  List<ContentDocumentLink>();
         Set<Id>CaseIds = new Set<Id>();
         
         for(Case caserec:childCases){
             CaseIds.add(caserec.id);
         }
         Map<id,ContentDocumentLink>ExistingContDocMap = new Map<id,ContentDocumentLink>();
         if(CaseIds.size()>0){
         Existingcontdoclist = [SELECT ID,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN:documentIds AND LinkedEntityId IN: CaseIdS];
         }
         
         if(Existingcontdoclist.size()>0){
         for(ContentDocumentLink cont:Existingcontdoclist ){
             if(!ExistingContDocMap.containsKey(cont.ContentDocumentId)){
                 ExistingContDocMap.put(cont.ContentDocumentId,cont);
             }else 
                 ExistingContDocMap.get(cont.ContentDocumentId);
         }

         for(id child:documentIds){
           if(ExistingContDocMap.containsKey(child) ){
               documentIds.remove(child);
               CaseIds.remove(ExistingContDocMap.get(child).LinkedEntityId);
           }

        }
      }
      
      //DocumentList = [select Id,Title,FileType,ContentSize,Description from ContentDocument where id IN: documentIds];  
      List<ContentVersion> parentContentVersion  = new List<ContentVersion>(); 
      parentContentVersion =[select id,ContentDocumentId,ContentLocation,ContentSize,FileExtension,FileType,IsMajorVersion,Origin,OwnerId,
      PathOnClient,RecordTypeId,Title,PublishStatus,VersionData,VersionNumber,Document_Type__c from ContentVersion WHERE ContentDocumentId IN: documentIds];
      List<ContentVersion>ContentVerList = new List<ContentVersion>();
        for(ContentVersion con:parentContentVersion){
            ContentVersion cv = new ContentVersion();
            cv = con.clone();
            ContentVerList.add(cv);
        }
        insert ContentVerList;
        
      for(id caserec:CaseIds){
         for(id child:documentIds){
            ContentDocumentLink docLink = new ContentDocumentLink();
                docLink.LinkedEntityId = caserec;
                docLink.ContentDocumentId = child;
                childcontdoclist.add(docLink);
          }
        }
        try{
        insert childcontdoclist;
        }
        catch(exception e){
        String errorMessage = 'Error creating attachments' + e.getMessage() + '\n' + e.getStackTraceString();
                CreateExceptionLog.insertErrorLog('caseServices', 'kickoffCustomerdata', String.valueOf(errorMessage), 'Fatal');
        }
        
       */
        
        
      
    } 
 
     
    /**
    * Object:           Case
    * Record Type:      Compliance Sub Case
    * Functionality:    On create of a Compliance Sub Case: retrieves the custom setting for State Metadata and assigns the Compliance Sub Case's
    *                   State Type based on the State.
    *
    */
    public static void setComplianceSubCaseStateType(List<Case> newCases){
        String subCaseRTName = ComplianceConstants.RECORDTYPE_SUB_CASE;
        String typeBrandRegistration = ComplianceConstants.SUB_CASE_TYPE_BRAND_REGISTRATION;
        Id complianceSubCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(subCaseRTName).getRecordTypeId();
        Map<String, Compliance_State_Metadata__c> stateMetadataMap = Compliance_State_Metadata__c.getAll();

        for(Case currCase: newCases){
            if(currCase.RecordTypeId == complianceSubCaseRecordTypeId && currCase.Type == typeBrandRegistration && String.isNotBlank(currCase.State__c) && stateMetadataMap.containsKey(currCase.State__c)){
                currCase.State_Type__c = stateMetadataMap.get(currCase.State__c).State_Type__c;
            }
        }
    }

    /**
    * Object:           Case
    * Record Type:      Compliance Sub Case
    * Functionality:    On update of a Compliance Sub Case: if the Case's State is a Price Posting State and isn't New York and the Posting Date is  
    *                   filled out, the case is moved to the 'Closed' Status.
    *
    *
    */
    public static void closePostingStateWithPostingDate(List<Case> newCases, Map<Id, Case> oldMap){
        String subCaseRTName = ComplianceConstants.RECORDTYPE_SUB_CASE;
        Id complianceSubCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(subCaseRTName).getRecordTypeId();
        Map<Id, Case> actionableCaseMap = new Map<Id, Case>();
        for(Case currCase: newCases){
            if(currCase.RecordTypeId == complianceSubCaseRecordTypeId && 
                oldMap.get(currCase.Id).Posting_Date__c == null && 
                currCase.Posting_Date__c != null &&
                currCase.State_Type__c.contains('Price Posting') &&
                currCase.State__c != 'New York' &&
                currCase.Type == 'Brand Registration'){
                actionableCaseMap.put(currCase.Id, currCase);
            }
        }

        if(actionableCaseMap.size() > 0){
            for(Case currCase: actionableCaseMap.values()){
                currCase.Status = 'Closed';
            }
        }
    }

    /**
    * Object:           Case
    * Record Type:      Compliance General/Compliance Utility Method
    * Functionality:    Helper method for Compliance Methods. Retreives users who have a state representation affiliation
    *                   and returns a Map of Maps. The Key of the first map is the State name, the key of the second map is
    *                   the name of the Profile. The value of the second map is the User Id of the user who represents that 
    *                   state and profile
    *
    *                   Map<State Name, Map<Profile Name, User Id>>
    *                   Consumes: 1 query
    */
    public static Map<String, Map<String, Id> > retrieveComplianceUserStateAffiliation(){
        Map<String, Map<String, Id>> stateAffiliationMap = new Map<String, Map<String, Id>>();
        List<User> stateAffiliatedUsers = [SELECT Id, Profile.Name, Represented_States__c FROM User WHERE Represented_States__c != null];
        for(User u: stateAffiliatedUsers){
            if(u.Represented_States__c != null && !String.isBlank(u.Represented_States__c)){
                for(String state: u.Represented_States__c.split(';')){
                    if(!stateAffiliationMap.containsKey(state)){
                        Map<String, Id> profileUserIdMap = new Map<String, Id>{u.Profile.Name => u.Id};
                        stateAffiliationMap.put(state, profileUserIdMap);
                    } else {
                        stateAffiliationMap.get(state).put(u.Profile.Name, u.Id);
                    }
                }
            }
        }
        return stateAffiliationMap;
    }

    /**
    * Object:           Case
    * Record Type:      Compliance General/Compliance Utility Method
    * Functionality:    Helper method for Compliance Methods. Using the current logged in User's Id, retrieves their
    *                   assigned Represented States.
    *
    *                   Consumes 1 query
    */
    public static List<String> retrieveCurrentLoggedInUserStateAffiliation(){
        Id userId = UserInfo.getUserId();
        User u = [SELECT Id, Represented_States__c FROM User WHERE Id =: userId];
        if(!String.isBlank(u.Represented_States__c) && u.Represented_States__c != null){
            List<String> userStates = u.Represented_States__c.split(';');
            return userStates;
        } else {
            return new List<String>();
        }
    }

    /**
    * Object:           Case
    * Record Type:      Brand Registration
    * Functionality:    When a Compliance Sub Case with Type of "Brand Registration" is updated,
    *                   check if all of the Parent's Sub Cases are submitted, closed or waiting for posting. If all Sub Cases are submitted, Email Template is
    *                   rendered and sent to the Owner of the Parent Case. If all Sub Cases are not submitted, no action is taken
    *
    * TBD:              
    */
    public static void doAllChildCasesClosed(List<Case> newCases, Map<Id, Case> oldMap){
       CaseComplianceUtility.runCaseComplianceTriggerLogic =true;
        //List of Cases that were updated
        List<Case> updatedCases = new List<Case>();
        Set<Id> updatedCaseIdSet = new Set<Id>();
        Set<Id> updatedCaseParentIdSet = new Set<Id>();
        String subCaseRTName = ComplianceConstants.RECORDTYPE_SUB_CASE;
        Id complianceSubCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(subCaseRTName).getRecordTypeId();
        //Key: ParentId, Value: Sub Case
        Map<Id, List<Case>> parentToSubCaseMap = new Map<Id, List<Case>>();
        Map<Id, Boolean> parentSubmissionStatusMap = new Map<Id, Boolean>();
        Map<Id, Boolean> parentSubmissionStatusMapSubmitted = new Map<Id, Boolean>();

        for(Case currCase: newCases){
            if(currCase.RecordTypeId==complianceSubCaseRecordTypeId && currCase.Type !='Traypack Audit' && currCase.Type !='VAP/LTO Allocation' && currCase.Type !='Giftshop Pricing'){
                updatedCases.add(currCase);
                updatedCaseIdSet.add(currCase.Id);
                updatedCaseParentIdSet.add(currCase.ParentId);
            }
        }

        //This list represents the Parent Cases of Compliance Sub Cases that were closed
        //We use this list to query all Compliance Sub Cases whose Parent is in this list
        //Then we check if all of the Compliance Sub Cases on a given Parent are closed
        //If all of a Parent's Sub Cases are closed, mark the "Submitted_Compliance__c" checkbox as True
        //  * This field is re-used from the Sub Case *
        //If all of a Parent's Sub Cases are NOT closed, no action is taken
        if(!updatedCaseParentIdSet.isEmpty()){
            //Query all child cases where their parent is in the Id set and their record type is 'Compliance Sub Case'
            List<Case> allSubCases = [SELECT Id, Status, IsClosed, ParentId, submitted_compliance__c, submission_date_not_required__c, state_type__c, Submission_date__c FROM Case WHERE RecordTypeId =: complianceSubCaseRecordTypeId AND Type NOT IN ('Traypack Audit','VAP/LTO Allocation','Giftshop Pricing') AND ParentId IN: updatedCaseParentIdSet];
            for(Case subCase: allSubCases){
                if(!parentToSubCaseMap.containsKey(subCase.ParentId)){
                    parentToSubCaseMap.put(subCase.ParentId, new List<Case>{subCase});
                } else {
                    parentToSubCaseMap.get(subCase.ParentId).add(subCase);
                }
            }
            Map<Id, Case> parentCases = new Map<Id, Case>([Select Id, Status, Isclosed, submitted_compliance__c from Case where Id IN:updatedCaseParentIdSet]);

            //Check if all of a parent's cases are closed and store the result in a map
            //Key: Parent Id, Value: All Children Closed? (Boolean)
            for(Id parentId: parentToSubCaseMap.keySet()){
                Boolean allChildrenClosed = true;
                Boolean allChildrenSubmitted = true;
                for(Case childCase: parentToSubCaseMap.get(parentId)){
                    if(!childCase.IsClosed){
                        //If one child case is not closed, no need to look at all child cases. 
                        //Break to save CPU time
                        allChildrenClosed = false;
                        break;
                    }
                }
                for(Case childCase: parentToSubCaseMap.get(parentId)){
                    if(!childCase.submitted_compliance__c 
                        &&!(childCase.state_type__c!=null 
                        && childCase.state_type__c.contains('Price Posting')
                        && childCase.submission_date_not_required__c)
                        &&
                        childCase.status != 'Closed - No Action'
                        && 
                        !childCase.isClosed)
                    {
                            allChildrenSubmitted = false;
                            break;
                    }
                }
                parentSubmissionStatusMap.put(parentId, allChildrenClosed);
                parentSubmissionStatusMapSubmitted.put(parentId, allChildrenSubmitted);

            }


            if(!parentSubmissionStatusMapSubmitted.isEmpty()){
                List<Case> submittedParentCasesSubmitted = new List<Case>();
                for(Id parentId: parentSubmissionStatusMapSubmitted.keySet()){
                    
                    if(parentSubmissionStatusMapSubmitted.get(parentId) && !parentCases.get(parentId).submitted_compliance__c){
                        submittedParentCasesSubmitted.add(new Case(Id = parentId, Submitted_Compliance__c = true));
                    }           
                }    
                if(!submittedParentCasesSubmitted.isEmpty()){
                    update submittedParentCasesSubmitted;
                }
            }

            //If there are any parents whose children are all closed, we need to mark them as Submitted
            //If there are none, the method will end here. No DML should be done if there are no cases to update
            if(!parentSubmissionStatusMap.isEmpty()){
                List<Case> submittedParentCasesClosed = new List<Case>();
                for(Id parentId: parentSubmissionStatusMap.keySet()){
                    
                    if(parentSubmissionStatusMap.get(parentId) && !parentCases.get(parentId).Isclosed){
                        submittedParentCasesClosed.add(new Case(Id = parentId, Submitted_Compliance__c = true, Status = 'Closed'));
                    }
                }           
                if(!submittedParentCasesClosed.isEmpty()){
                    update submittedParentCasesClosed;
                }
            } 
            

        }
        
        //Closing brnad reg case start
        /*List<Case>BrandRegCases  = new List<Case>();
        Set<Id>ParentCaseIds = new Set<Id>();
        for(Case currCase: newCases){
            if(currCase.RecordTypeId==complianceSubCaseRecordTypeId && currCase.Type =='Brand Registration')
             {
              if(currCase.Status!='Closed'){
                BrandRegCases.add(currCase);
              }
              ParentCaseIds.add(currCase.ParentId);
            }
        }
        List<Case> ParentRecords = new List<Case>();
        if(BrandRegCases.size()==0){
            ParentRecords = [SELECT id,Status FROM Case WHERE ID IN:ParentCaseIds];
        }
        if(ParentRecords.size()>0){
            for(case casrec:ParentRecords){
                casrec.Status ='Closed';
            }
            update ParentRecords;
            
        }*/ // closing the BR parent case ends
        
        
    }

    /**
    * Object:           Case
    * Record Type:      Brand Registration
    * Functionality:    When all of a Brand Registration Case's Sub Cases are moved to a "Closed" status, the Brand 
    *                   Registration Case is considered "Submitted". When the Brand Registration Case moves from unsubmitted
    *                   to submitted, we must calculate the "Number of Registrations" that were completed. This number is 
    *                   calculated by multiplying the "Number of SKUs" from the Brand Registration Case by the total number
    *                   of Sub Cases that were submitted.
    */
    public static void calculateNumberOfRegistrationsOnSubmission(List<Case> newCases, Map<Id, Case> oldMap){
        String subCaseRTName = ComplianceConstants.RECORDTYPE_SUB_CASE;
        String brandRegistrationRTName = ComplianceConstants.RECORDTYPE_BRAND_REGISTRATION;
        Id brandRegistrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(brandRegistrationRTName).getRecordTypeId();
        Id complianceSubCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(subCaseRTName).getRecordTypeId();
        Map<Id, Case> actionableCaseMap = new Map<Id, Case>();
        for(Case currCase: newCases){
            if(currCase.RecordTypeId == brandRegistrationRecordTypeId && !oldMap.get(currCase.Id).Submitted_Compliance__c && currCase.Submitted_Compliance__c){
                actionableCaseMap.put(currCase.Id, currCase);
            }
        }

        if(!actionableCaseMap.isEmpty()){
            /*
            * Query all cases whose record type is "Compliance Sub Case" and whose parent is in the map
            * - add to a map of Parent Id to List<Case>
            * Calculate total of all children cases, store value in the actionableCaseMap
            */
            Map<Id, List<Case>> parentToSubCaseMap = new Map<Id, List<Case>>();
            List<Case> allSubCases = [SELECT Id, ParentId, Submitted_Compliance__c, Status, IsClosed FROM Case WHERE RecordTypeId =: complianceSubCaseRecordTypeId AND ParentId IN: actionableCaseMap.keySet()];
            for(Case subCase: allSubCases){
                if(!parentToSubCaseMap.containsKey(subCase.ParentId)){
                    parentToSubCaseMap.put(subCase.ParentId, new List<Case>{subCase});
                } else {
                    parentToSubCaseMap.get(subCase.ParentId).add(subCase);
                }
            }

            for(Case parentCase: actionableCaseMap.values()){
                Integer parentTotalRegistrations = 0;
                for(Case subCase: parentToSubCaseMap.get(parentCase.Id)){
                    if(subCase.Submitted_Compliance__c){
                        parentTotalRegistrations += parentCase.Number_of_COLAs__c.intValue();
                    }
                }
                parentCase.Number_Of_Registrations__c = parentTotalRegistrations;
            }
        }
    }

    public static void sendEmailsOnQuoteRequestApproval(List<Case> newCases, Map<Id, Case> oldMap){
        
            String quoteRequestRTName = ComplianceConstants.RECORDTYPE_QUOTE_REQUEST;
            Id quoteRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(quoteRequestRTName).getRecordTypeId();
            Map<Id, Case> actionableCaseMap = new Map<Id, Case>();
            Map<Id, List<Quote_Request__c>> caseQuoteRequestMap = new Map<Id, List<Quote_Request__c>>();
            Map<Id, String> caseSubjectItemsMap = new Map<Id, String>();
            Map<Id, String> caseHtmlItemBodyMap = new Map<Id, String>();
            Map<Id, String> casePlainTextItemBodyMap = new Map<Id, String>();
            List<Messaging.SingleEmailMessage> allMail = new List<Messaging.SingleEmailMessage>();
    
            for(Case currCase: newCases){
                if(currCase.RecordTypeId == quoteRequestRecordTypeId && !oldMap.get(currCase.Id).Approved__c && currCase.Approved__c){
                    actionableCaseMap.put(currCase.Id, currCase);
                }
            }
    
            if(!actionableCaseMap.isEmpty()){
                List<Quote_Request__c> quotes = [SELECT Id, Item_Name__c, State__c, Item_Size__c, Item_Available__c, Item_Price__c, Price_Needed__c, Case__c, CurrencyIsoCode FROM Quote_Request__c 
                                                    WHERE Case__c IN :actionableCaseMap.keySet() AND Item_Available__c = 'Yes' AND Price_Needed__c = 'Yes'];
    
                if(!quotes.isEmpty()){
                    for(Quote_Request__c quote: quotes){
                        if(!caseQuoteRequestMap.containsKey(quote.Case__c)){
                            caseQuoteRequestMap.put(quote.Case__c, new List<Quote_Request__c>{quote});
                        } else {
                            caseQuoteRequestMap.get(quote.Case__c).add(quote);
                        }
                    }
    
                    for(Id caseId: caseQuoteRequestMap.keySet()){
                        if(!caseQuoteRequestMap.get(caseId).isEmpty()){
                            String subjectItems = '';
                            String emailHtmlItemBody = '';
                            String emailPlainTextItemBody = '';
                            for(Quote_Request__c quote: caseQuoteRequestMap.get(caseId)){
                                emailHtmlItemBody += quote.Item_Name__c+' - '+quote.Item_Size__c+' - '+quote.Item_Price__c+' '+quote.CurrencyIsoCode+'<br></br>';
                                emailPlainTextItemBody += quote.Item_Name__c+' - '+quote.Item_Size__c+' - '+quote.Item_Price__c+' '+quote.CurrencyIsoCode+'\n';
                            }
    
                            if(caseQuoteRequestMap.get(caseId).size() > 1){
                                subjectItems = 'Multiple Items';
                            } else if(caseQuoteRequestMap.get(caseId).size() == 1){
                                subjectItems = caseQuoteRequestMap.get(caseId).get(0).Item_Name__c;
                            }
                            caseSubjectItemsMap.put(caseId, subjectItems);
                            caseHtmlItemBodyMap.put(caseId, emailHtmlItemBody);
                            casePlainTextItemBodyMap.put(caseId, emailPlainTextItemBody);
                        }
                    }
    
                    String commercialFinanceAddress = ComplianceConstants.COMMERCIAL_FINANCE_ADDRESS;
                    String emailServiceAddress = ComplianceConstants.EMAIL_SERVICE_ADDRESS;
                    String qrQuotesApproved = ComplianceConstants.QUOTE_REQUEST_APPROVED_BY_FINANCE;
                    String systemUserId = ComplianceConstants.SYSTEM_EMAIL_USER_ID;
                    EmailTemplate qrPriceNeededTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: qrQuotesApproved LIMIT 1];
    
                    for(Id caseId: caseHtmlItemBodyMap.keySet()){
                        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(qrPriceNeededTemplate.Id, systemUserId, caseId);
                        mail.setSubject(mail.getSubject().replace('[item-name]', caseSubjectItemsMap.get(caseId)));
                        mail.setHTMLBody(mail.getHTMLBody().replace('[items-body]', caseHtmlItemBodyMap.get(caseId)));
                        mail.setPlainTextBody(mail.getPlainTextBody().replace('[items-body]', casePlainTextItemBodyMap.get(caseId)));
                        mail.setSaveAsActivity(false);
                        mail.setTargetObjectId(actionableCaseMap.get(caseId).OwnerId);
                        mail.setToAddresses(new List<String>{commercialFinanceAddress});
                        mail.setWhatId(caseId);
                        List<String> ccAddressList = new List<String>{emailServiceAddress};
                        if(String.isNotBlank(actionableCaseMap.get(caseId).State_Manager_Email__c)){
                            ccAddressList.add(actionableCaseMap.get(caseId).State_Manager_Email__c);
                        }
                        mail.setCCAddresses(ccAddressList);
    
                        allMail.add(mail);
                    }
    
                    Messaging.sendEmail(allMail);
                }
            }
        }

    public static void sendEmailsOnQuoteRequestSubmission(List<Case> newCases, Map<Id, Case> oldMap){
        String quoteRequestRTName = ComplianceConstants.RECORDTYPE_QUOTE_REQUEST;
        Id quoteRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(quoteRequestRTName).getRecordTypeId();
        Map<Id, Case> actionableCaseMap = new Map<Id, Case>();
        Map<Id, List<Quote_Request__c>> caseAllQuoteRequestMap = new Map<Id, List<Quote_Request__c>>();
        Map<Id, List<Quote_Request__c>> caseQuoteRequestMap = new Map<Id, List<Quote_Request__c>>();
        Map<Id, String> caseSubjectItemsMap = new Map<Id, String>();
        Map<Id, String> caseHtmlItemBodyMap = new Map<Id, String>();
        Map<Id, String> casePlainTextItemBodyMap = new Map<Id, String>();
        List<Messaging.SingleEmailMessage> allMail = new List<Messaging.SingleEmailMessage>();

        String complianceCommunitySiteUrl = 'https://beam.force.com/compliance';

        for(Case currCase: newCases){
            if(currCase.RecordTypeId == quoteRequestRecordTypeId && !oldMap.get(currCase.Id).Submitted_Compliance__c && currCase.Submitted_Compliance__c){
                actionableCaseMap.put(currCase.Id, currCase);
            }
        }

        if(!actionableCaseMap.isEmpty()){
            List<Quote_Request__c> quotes = [SELECT Id, Item_Name__c, State__c, Item_Size__c, Item_Available__c, Price_Needed__c, Case__c FROM Quote_Request__c 
                                                WHERE Case__c IN :actionableCaseMap.keySet()];

            for(Quote_Request__c quote: quotes){
                if(!caseAllQuoteRequestMap.containsKey(quote.Case__c)){
                    caseAllQuoteRequestMap.put(quote.Case__c, new List<Quote_Request__c>{quote});
                } else {
                    caseAllQuoteRequestMap.get(quote.Case__c).add(quote);
                }
            }

            //For Cases that have NO Items Available
            for(Id caseId: caseAllQuoteRequestMap.keySet()){
                Boolean allUnavailable = true;
                for(Quote_Request__c qr: caseAllQuoteRequestMap.get(caseId)){
                    if(qr.Item_Available__c == 'Yes'){
                        allUnavailable = false;
                        break;
                    }
                }
                if(allUnavailable){
                    actionableCaseMap.get(caseId).Status = 'Close Pending';
                }
            }

            //For Cases that have one or more Items Available
            List<Quote_Request__c> availablePriceNeededQuoteList = new List<Quote_Request__c>();
            for(Quote_Request__c quote: quotes){
                if(quote.Item_Available__c == 'Yes' && quote.Price_Needed__c == 'Yes'){
                    availablePriceNeededQuoteList.add(quote);
                }
            }
            if(!availablePriceNeededQuoteList.isEmpty()){
                for(Quote_Request__c quote: availablePriceNeededQuoteList){
                    if(!caseQuoteRequestMap.containsKey(quote.Case__c)){
                        caseQuoteRequestMap.put(quote.Case__c, new List<Quote_Request__c>{quote});
                    } else {
                        caseQuoteRequestMap.get(quote.Case__c).add(quote);
                    }
                }

                for(Id caseId: caseQuoteRequestMap.keySet()){
                    if(!caseQuoteRequestMap.get(caseId).isEmpty()){
                        String subjectItems = '';
                        String emailHtmlItemBody = '';
                        String emailPlainTextItemBody = '';
                        for(Quote_Request__c quote: caseQuoteRequestMap.get(caseId)){
                            emailHtmlItemBody += '<a href="'+complianceCommunitySiteUrl+'/s/detail/'+quote.Id+'">'+quote.Item_Name__c+'</a> - '+quote.State__c+' - '+quote.Item_Size__c+'<br></br>';
                            //emailHtmlItemBody += quote.Item_Name__c + '<br></br>';
                            emailPlainTextItemBody += quote.Item_Name__c +' - '+quote.State__c+' - '+quote.Item_Size__c+'\n';
                        }

                        if(caseQuoteRequestMap.get(caseId).size() > 1){
                            subjectItems = 'Multiple Items';
                        } else if(caseQuoteRequestMap.get(caseId).size() == 1){
                            subjectItems = caseQuoteRequestMap.get(caseId).get(0).Item_Name__c;
                        }
                        caseSubjectItemsMap.put(caseId, subjectItems);
                        caseHtmlItemBodyMap.put(caseId, emailHtmlItemBody);
                        casePlainTextItemBodyMap.put(caseId, emailPlainTextItemBody);
                    }
                }

                String emailServiceAddress = ComplianceConstants.EMAIL_SERVICE_ADDRESS;
                String commercialFinanceAddress = ComplianceConstants.COMMERCIAL_FINANCE_ADDRESS;               
                String qrPriceNeeded = ComplianceConstants.QUOTE_REQUEST_PRICE_NEEDED_FROM_FINANCE;
                String systemUserId = ComplianceConstants.SYSTEM_EMAIL_USER_ID;
                EmailTemplate qrPriceNeededTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: qrPriceNeeded LIMIT 1];

                for(Id caseId: caseHtmlItemBodyMap.keySet()){
                    Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(qrPriceNeededTemplate.Id, systemUserId, caseId);
                    mail.setSubject(mail.getSubject().replace('[item-name]', caseSubjectItemsMap.get(caseId)));
                    mail.setHTMLBody(mail.getHTMLBody().replace('[items-body]', caseHtmlItemBodyMap.get(caseId)));
                    mail.setPlainTextBody(mail.getPlainTextBody().replace('[items-body]', casePlainTextItemBodyMap.get(caseId)));
                    mail.setSaveAsActivity(false);
                    mail.setTargetObjectId(actionableCaseMap.get(caseId).OwnerId);
                    mail.setToAddresses(new List<String>{commercialFinanceAddress});
                    
                    List<String> ccAddressList = new List<String>{emailServiceAddress};
                    if(String.isNotBlank(actionableCaseMap.get(caseId).State_Manager_Email__c)){
                        ccAddressList.add(actionableCaseMap.get(caseId).State_Manager_Email__c);
                    }

                    mail.setCCAddresses(ccAddressList);
                    mail.setWhatId(caseId);
                    allMail.add(mail);
                }
                System.debug(LoggingLevel.INFO, allMail.size());
                Messaging.sendEmail(allMail);
            }
        }
    }

    /**
    * Object:           Case
    * Record Type:      Quote Request
    * Functionality:    When a Quote Request Case is submitted via the portal (Customer Community), the Compliance Coordinator 
    *                   in charge of that state recieves an email. If there is a Compliance Coordinator that represents this state,
    *                   the email address is passed in as toAddress. If for some reason there is no Compliance Coordinator associated
    *                   with this Case's state, the email address of the Quote Request queue is passed in as toAddress.
    */
    public static void sendNotificationOnQuoteRequestCreation(Id caseId, String toAddress){
        String emailServiceAddress = ComplianceConstants.EMAIL_SERVICE_ADDRESS;
        String systemUserId = ComplianceConstants.SYSTEM_EMAIL_USER_ID;
        String qrNewQuote = ComplianceConstants.QUOTE_REQUEST_NEW_QUOTE_AVAILABLE;
        EmailTemplate qrNewQuoteTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: qrNewQuote LIMIT 1];

        List<Quote_Request__c> relatedQuoteRequests = [SELECT Id, Item_Name__c, Item_Size__c FROM Quote_Request__c WHERE Case__c =: caseId];

        List<Messaging.SingleEmailMessage> allMail = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(qrNewQuoteTemplate.Id, systemUserId, caseId);
        mail.setSaveAsActivity(false);
        mail.setToAddresses(new List<String>{toAddress});
        mail.setCCAddresses(new List<String>{emailServiceAddress, UserInfo.getUserEmail()});
        mail.setWhatId(caseId);
        if(relatedQuoteRequests.size() > 0){
            String htmlBody = mail.getHTMLBody();
            String textBody = mail.getPlainTextBody();
            String items = '';
            for(Integer index = 0; index < relatedQuoteRequests.size(); index++){
                Integer row = index + 1;
                Quote_Request__c qr = relatedQuoteRequests[index];
                items = items + String.valueOf(row) + ') '+qr.Item_Name__c + ' - ' + qr.Item_Size__c + '<br></br>';
            }
            mail.setHTMLBody(htmlBody.replace('[items]', items));
            mail.setPlainTextBody(textBody.replace('[items]', items));
        }
        allMail.add(mail);
        Messaging.sendEmail(allMail);
    }

    public static void sendEmailDiscountNeedsApproval(List<Case> caseList){
        Set<Id> caseIdSet = new Set<Id>();
        for(Case currCase: caseList){
            caseIdSet.add(currCase.Id);
        }

        Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, Owner.Email FROM Case WHERE Id IN: caseIdSet]);
        for(Case c: caseMap.values()){
            System.debug(LoggingLevel.INFO, 'Case email: ' + c.Owner.Email);
        }

        String documentTypeFilter = ComplianceConstants.DOCUMENT_TYPE_DISCOUNTS_DOCUMENT;
        List<String> cvIdList = new List<String>();

        Map<Id, ContentDocumentLink> contentDocumentToLinkMap = new Map<Id, ContentDocumentLink>();
        List<ContentDocumentLink> cdLinkList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: caseIdSet];
        for(ContentDocumentLink cdl: cdLinkList){
            contentDocumentToLinkMap.put(cdl.ContentDocumentId, cdl);
        }

        Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE 
                                                                        Document_Type__c=: documentTypeFilter AND 
                                                                        IsLatest=true AND 
                                                                        ContentDocumentId IN: contentDocumentToLinkMap.keySet() ORDER BY CreatedDate DESC]);
        Map<Id, List<Id>> caseToCVMap = new Map<Id, List<Id>>();
        for(ContentVersion cv: cvMap.values()){
            Id entityId = contentDocumentToLinkMap.get(cv.ContentDocumentId).LinkedEntityId;
            if(!caseToCVMap.containsKey(entityId)){
                caseToCVMap.put(entityId, new List<Id>{cv.Id});
            } else {
                caseToCVMap.get(entityId).add(cv.Id);
            }
        }

        String discountsNeedApproval = ComplianceConstants.DISCOUNTS_DOCUMENT_NEEDS_APPROVAL;
        EmailTemplate discountsNeedApprovalTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: discountsNeedApproval LIMIT 1];      
        List<Messaging.SingleEmailMessage> allMail = new List<Messaging.SingleEmailMessage>();
        String emailServiceAddress = ComplianceConstants.EMAIL_SERVICE_ADDRESS;
        String commercialFinanceAddress = ComplianceConstants.COMMERCIAL_FINANCE_ADDRESS;
        String systemUserId = ComplianceConstants.SYSTEM_EMAIL_USER_ID;

        for(Case currCase: caseList){
            Id caseId = currCase.Id;
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(discountsNeedApprovalTemplate.Id, systemUserId, caseId);
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(caseMap.get(caseId).OwnerId);
            List<String> toAddressList = new List<String>{commercialFinanceAddress};
            if(String.isNotBlank(caseMap.get(caseId).Owner.Email)){
                toAddressList.add(caseMap.get(caseId).Owner.Email);
            }
            mail.setToAddresses(toAddressList);
            mail.setCCAddresses(new List<String>{emailServiceAddress});
            mail.setWhatId(caseId);
            if(caseToCVMap.containsKey(caseId)){
                mail.setEntityAttachments(new List<Id>{caseToCVMap.get(caseId)[0]});
            }
            allMail.add(mail);
        }
        Messaging.sendEmail(allMail);
    }

    public static void sendEmailOnDiscountApprovalStatusChange(String caseId, Boolean response){
        String emailServiceAddress = ComplianceConstants.EMAIL_SERVICE_ADDRESS;
        String systemUserId = ComplianceConstants.SYSTEM_EMAIL_USER_ID;
        String discountApprovedTemplateName = ComplianceConstants.DISCOUNTS_DOCUMENT_APPROVED;
        String discountRejectedTemplateName = ComplianceConstants.DISCOUNTS_DOCUMENT_REJECTED;
        String finalTemplateName = response ? discountApprovedTemplateName : discountRejectedTemplateName;
        Id finalTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName=:finalTemplateName].Id;
        Case currCase = [SELECT Id, OwnerId, Owner.Email, State_Manager_Email__c FROM Case WHERE Id =: caseId];
        
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(finalTemplateId, systemUserId, currCase.Id);
        mail.setSaveAsActivity(false);
        mail.setTargetObjectId(currCase.OwnerId);
        List<String> toAddressList = new List<String>();
        if(String.isNotBlank(currCase.Owner.Email)){
            toAddressList.add(currCase.Owner.Email);
        }
        if(String.isNotBlank(currCase.State_Manager_Email__c)){
            toAddressList.add(currCase.State_Manager_Email__c);
        }
        mail.setToAddresses(toAddressList);
        mail.setCCAddresses(new List<String>{emailServiceAddress});
        mail.setWhatId(currCase.Id);
        allMails.add(mail);
        Messaging.sendEmail(allMails);
    }

    public static void evaluateDiscountApprovalNeeded(List<Case> newCases, Map<Id, Case> oldMap){
        String discountRTName = ComplianceConstants.RECORDTYPE_DISCOUNT;
        Id discountRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(discountRTName).getRecordTypeId();
        Map<Id, Case> actionableCaseMap = new Map<Id, Case>();
        for(Case currCase: newCases){
            if(currCase.RecordTypeId == discountRecordTypeId){
                if(String.isNotBlank(currCase.Approval_Needed__c) && currCase.Approval_Needed__c != oldMap.get(currCase.Id).Approval_Needed__c && !currCase.IsClosed){
                    actionableCaseMap.put(currCase.Id, currCase);
                }
            }
        }
        if(actionableCaseMap.size() > 0){
            String documentTypeFilter = ComplianceConstants.DOCUMENT_TYPE_DISCOUNTS_DOCUMENT;
            List<String> cvIdList = new List<String>();
            Set<Id> caseIdSet = actionableCaseMap.keySet();

            Map<Id, ContentDocumentLink> contentDocumentToLinkMap = new Map<Id, ContentDocumentLink>();
            List<ContentDocumentLink> cdLinkList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: caseIdSet];
            for(ContentDocumentLink cdl: cdLinkList){
                contentDocumentToLinkMap.put(cdl.ContentDocumentId, cdl);
            }

            Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE 
                                                                            Document_Type__c=: documentTypeFilter AND 
                                                                            IsLatest=true AND 
                                                                            ContentDocumentId IN: contentDocumentToLinkMap.keySet() ORDER BY CreatedDate]);
            Map<Id, List<Id>> caseToCVMap = new Map<Id, List<Id>>();
            for(ContentVersion cv: cvMap.values()){
                Id entityId = contentDocumentToLinkMap.get(cv.ContentDocumentId).LinkedEntityId;
                if(!caseToCVMap.containsKey(entityId)){
                    caseToCVMap.put(entityId, new List<Id>{cv.Id});
                } else {
                    caseToCVMap.get(entityId).add(cv.Id);
                }
            }

            List<Case> approvalNeededCases = new List<Case>();
            for(Case currCase: actionableCaseMap.values()){
                if(currCase.Approval_Needed__c == 'Yes'){
                    if(caseToCVMap.containsKey(currCase.Id) && caseToCVMap.get(currCase.Id).size() > 0){
                        approvalNeededCases.add(currCase);
                        currCase.Status = 'Waiting for Approval';
                    } else{
                        currCase.addError('There are no Discount Documents attached to this Case. Please attach a document and try again.');
                    }
                } else if(currCase.Approval_Needed__c == 'No - Discount Matches Calendar'){
                    currCase.Status = 'Waiting for Submission';
                } else if(currCase.Approval_Needed__c == 'No - No Discounts'){
                    currCase.Status = 'Closed';
                }
            }
            if(approvalNeededCases.size() > 0){
                sendEmailDiscountNeedsApproval(approvalNeededCases);
            }
        }
    }

    public static void setStateManagerEmailOnInsert(List<Case> newCases){
        Map<String, Compliance_State_Metadata__c> metadataMap = Compliance_State_Metadata__c.getAll();
        //Quote Requests?
        String discountRTName = ComplianceConstants.RECORDTYPE_DISCOUNT;
        String priceFilingRTName = ComplianceConstants.RECORDTYPE_PRICE_FILING;
        Id discountRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(discountRTName).getRecordTypeId();
        Id priceFilingRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(priceFilingRTName).getRecordTypeId();
        List<Case> actionableCases = new List<Case>();
        for(Case currCase: newCases){
            if(currCase.RecordTypeId == discountRecordTypeId || currCase.RecordTypeId == priceFilingRecordTypeId){
                actionableCases.add(currCase);
            }
        }

        if(actionableCases.size() > 0){
            for(Case currCase: actionableCases){
                //If the State is filled out, Custom Setting has the state, and the Custom Setting has an email for this state

                if(String.isNotBlank(currCase.State__c) && metadataMap.containsKey(currCase.State__c)){
                    if(String.isNotBlank(metadataMap.get(currCase.State__c).State_Manager_Email__c)){
                        currCase.State_Manager_Email__c = metadataMap.get(currCase.State__c).State_Manager_Email__c;
                    }
                    if(String.isNotBlank(metadataMap.get(currCase.State__c).State_Manager_Name__c)){
                        currCase.Name__c = metadataMap.get(currCase.State__c).State_Manager_Name__c;
                    }
                }
            }
        }   
    }

    /**
    * Object:           Case
    * Record Type:      General
    * Functionality:    Helper method to retrieve the specific Compliance Coordinator that represents a specified state. If there is no Compliance Coordinator
    *                   matching the profile and state, null will be returned.
    */
    public static User getComplianceCoordinatorByState(String state, String profileName){
    system.debug('inside getComplianceCoordinatorByState:::'+'state is:::'+state+'profileName is::::'+profileName);
        User selectedUser;
        List<User> usersWithProfile = [SELECT Id, Email, Represented_States__c FROM User WHERE Represented_States__c != null AND Profile.Name =: profileName];
        system.debug('inside getComplianceCoordinatorByState:::'+usersWithProfile);
        for(User u: usersWithProfile){
        system.debug('inside getComplianceCoordinatorByState:::for::::');
            if(state !='' && (u.Represented_States__c).contains(state)){
            system.debug('inside getComplianceCoordinatorByState:::if::::'+u);
                selectedUser = u;
                break;
            }
        }
        system.debug('selected user::::'+selectedUser);
        return selectedUser;
    }
    
    /**************************************************************************************************************
     * Description:    This method will be used to send emails when in field date or due date changed for brand registration
     * <Date>      <Authors Name>     <Company>
     * 21/10/2022  Deekshika Sharma   Metacube
	**************************************************************************************************************/
    public static void sendEmailOnInFieldChanged(List<Case> newCases, Map<Id, Case> oldMap) {
        String brandRegistrationRTName = ComplianceConstants.RECORDTYPE_BRAND_REGISTRATION;
        Id brandRegistrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(brandRegistrationRTName).getRecordTypeId();
        String inFieldDateTemplateName = ComplianceConstants.BRAND_REG_IN_FIELD_DATE_CHANGED_TEMPLATE_API_NAME;
        String dueDateTemplateName = ComplianceConstants.BRAND_REG_DUE_DATE_CHANGED_TEMPLATE_API_NAME;
        Map<String, Id> templateIdMap = new Map<String, Id>();
        for(EmailTemplate emailTemp: [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName IN (:inFieldDateTemplateName, :dueDateTemplateName)]) {
            templateIdMap.put(emailTemp.DeveloperName, emailTemp.Id);
        }
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        String emailServiceAddress = ComplianceConstants.EMAIL_SERVICE_ADDRESS;
        String complianceAddress = ComplianceConstants.COMPLIANCE_ADDRESS;
        String systemUserId = ComplianceConstants.SYSTEM_EMAIL_USER_ID;
        
	//Badri-changes SAL-1973-start
        String customerDataAddress = ComplianceConstants.CUSTOMER_DATA_ADDRESS;
        Id templateId;
        
        List<Case> actionableCases = new List<Case>();
        for(Case currCase: newCases){
            if(currCase.RecordTypeId == brandRegistrationRecordTypeId &&
               String.isNotBlank(currCase.Explanation_of_Change__c) &&
                currCase.Explanation_of_Change__c != oldMap.get(currCase.Id).Explanation_of_Change__c &&
                (currCase.In_field_Date__c != oldMap.get(currCase.Id).In_field_Date__c ||
                currCase.Due_Date__c != oldMap.get(currCase.Id).Due_Date__c)) {
                    actionableCases.add(new Case(Id=currCase.Id, Explanation_of_Change__c=null));
                    if(currCase.In_field_Date__c != oldMap.get(currCase.Id).In_field_Date__c) {
                        templateId = templateIdMap.get(inFieldDateTemplateName);
                    } else if(currCase.Due_Date__c != oldMap.get(currCase.Id).Due_Date__c) {
                        templateId = templateIdMap.get(dueDateTemplateName);
                    }
                    Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId, systemUserId, currCase.Id);
                    mail.setSaveAsActivity(false);
                	mail.setTargetObjectId(currCase.OwnerId);
                	mail.setToAddresses(new List<String>{emailServiceAddress, complianceAddress});
                	mail.setWhatId(currCase.Id);
                	allMails.add(mail);
            }
        }
        
        if(allMails.size() > 0){
            Messaging.sendEmail(allMails);
        }
        
        if(actionableCases.size() > 0){
            update actionableCases;
        }
    }

    public static Case setComplianceFlagsetValue(Case updateCase, String picklistValue){
        try{
            String flagset = String.isBlank(updateCase.Compliance_Flagset__c) ? '' : updateCase.Compliance_Flagset__c;
            if(!flagset.contains(picklistValue)){
                if(!flagset.endsWith(';')){
                    if(flagset.length() > 0){
                        flagset += ';';
                    }
                }

                flagset += picklistValue;
                
                if(!flagset.endsWith(';')){
                    if(flagset.length() > 0){
                        flagset += ';';
                    }
                }

                updateCase.Compliance_Flagset__c = flagset;
            }
        } catch(Exception e){
            System.debug(LoggingLevel.INFO, e.getMessage());
        }

        return updateCase;
    }

    /**
    * Object:           Case
    * Record Type:      Compliance Inquiry
    * Functionality:    
    *
    */
    public static void sendNotificationOnComplianceInquiryCreation(Id caseId, List<String> toAddressList){
    system.debug('inside sendNotificationOnComplianceInquiryCreation::::'+toAddressList+''+caseId);
        String emailServiceAddress = ComplianceConstants.EMAIL_SERVICE_ADDRESS;
        String systemUserId = ComplianceConstants.SYSTEM_EMAIL_USER_ID;
        String inquiryNewCase = ComplianceConstants.INQUIRY_NEW_CASE_SUBMITTED;
        EmailTemplate inquiryNewCaseTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: inquiryNewCase LIMIT 1];

        List<Quote_Request__c> relatedQuoteRequests = [SELECT Id, Item_Name__c, Item_Size__c FROM Quote_Request__c WHERE Case__c =: caseId];

        List<Messaging.SingleEmailMessage> allMail = new List<Messaging.SingleEmailMessage>();
        
        system.debug('inside sendNotificationOnComplianceInquiryCreation::::'+inquiryNewCaseTemplate.Id+'systemUserId::'+systemUserId+'caseId:::'+caseId+'emailServiceAddress is:::'+emailServiceAddress+'inquiryNewCaseTemplate is:::'+inquiryNewCaseTemplate+'inquiryNewCase is::::'+inquiryNewCase);
        
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(inquiryNewCaseTemplate.Id, systemUserId, caseId);
        mail.setSaveAsActivity(false);
        mail.setToAddresses(toAddressList);
        mail.setCCAddresses(new List<String>{emailServiceAddress, UserInfo.getUserEmail()});
        mail.setWhatId(caseId);
        allMail.add(mail);
        Messaging.sendEmail(allMail);
    }

    public class RequestStatus{
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public Map<String, Object> responseMap;

        public RequestStatus(Boolean success, String message, Map<String, Object> responseMap){
            this.success = success;
            this.message = message;
            this.responseMap = responseMap; 
        }
    }


    /**
    * Object:           Case
    * Record Type:      Compliance Sub Case
    * Functionality:    On update of a Compliance Sub Case: if the Case's State is a Price Posting State and the Submission Date not Required is checked,
    *                    the case should move to waiting for posting status.
    *
    * Added on 8/7/2018
    */
    public static void moveStatustoWaitingForPosting(List<Case> newCases, Map<Id, Case> oldMap){
        String subCaseRTName = ComplianceConstants.RECORDTYPE_SUB_CASE;
        Id complianceSubCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(subCaseRTName).getRecordTypeId();
        Map<Id, Case> actionableCaseMap = new Map<Id, Case>();
        for(Case currCase: newCases){
            if(currCase.RecordTypeId == complianceSubCaseRecordTypeId && 
                !oldMap.get(currCase.Id).Submission_Date_Not_Required__c && 
                currCase.Submission_Date_Not_Required__c &&
                currCase.State_Type__c.contains('Price Posting') &&
                currCase.Type == 'Brand Registration'){
                actionableCaseMap.put(currCase.Id, currCase);
            }
        }

        if(actionableCaseMap.size() > 0){
            for(Case currCase: actionableCaseMap.values()){
                currCase.Status = 'Waiting for Posting';
            }
        }
    }
    
    /**
    * Object:           Case
    * Record Type:      Brand Registration
    * Functionality:    When a 'Brand Registration' Case's 'Due Date' is Changed, this method will collect all the parent case ID's and
    *                   send it to 'changeDueDateOnSubcases' method for changing the due date on subcases as well.
    *                   
    *
    */
    public static void isDueDateChanged(List<Case> newCases, Map<Id, Case> oldMap){
        String brandRegistrationRTName = ComplianceConstants.RECORDTYPE_BRAND_REGISTRATION;
        Id brandRegistrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(brandRegistrationRTName).getRecordTypeId();
        List<Id> actionableCaseIds = new List<Id>();
        
        for(Case currCase: newCases){
            if(currCase.RecordTypeId == brandRegistrationRecordTypeId &&
                currCase.Due_Date__c != oldMap.get(currCase.Id).Due_Date__c){
                    
                    actionableCaseIds.add(currCase.Id);
                    
            }
        }
        
        if(actionableCaseIds.size()>0){
            changeDueDateOnSubcases(actionableCaseIds);
        }
   
    }
    
    /**
    * Object:           Case
    * Record Type:      Compliance Sub Case
    * Functionality:    On update of 'Due Date' on Parent's case, change the 'Due Date' on Subcases as well.
    *
    * Added on 8/7/2018
    */
    @future
    public static void changeDueDateOnSubcases(List<Id> parentCaseIds){
        List<Case> casesToUpdate = new List<Case>();
        for (Case currCase : [select Id, Parent.Due_Date__c	 from Case where ParentId =: parentCaseIds]) {
                System.debug('Testing change sue date future method on subcases');
                System.debug(currCase.Parent.Due_Date__c);
                currCase.Due_Date__c = currCase.Parent.Due_Date__c;
                casesToUpdate.add(currCase);
            }
        
        if(casesToUpdate.size()>0){
            update casesToUpdate;
        }
        
    }  
    
      /*******************************************************************************************************************************
Description:    This method is used to close Compliance Subcases if parent case is closed. 
<Date>          <Authors Name>     <Company>     <Brief Description of Change>
03/2024          Devyani Gupta      Metacube       Initial Creation
******************************************************************************************************************************/  
    @future
    public static void closeComplianceSubcases(String casesJSON){
        List<Case> parentCaseList = (List<Case>)JSON.deserialize(casesJSON,list<case>.class);
        List<Case> CasesList = new List<Case>();
        List<Id> parentCaseIdList = new List<Id>();
        for (Case pcase : parentCaseList) {
            if (pcase.IsClosed == True) {
                parentCaseIdList.add(pcase.Id);
            }
        }
        if (parentCaseIdList.size()>0) {
            CasesList = [Select Id, CaseNumber, Status from Case where IsClosed = false and 
                         RecordType.Name!='Inquiry' and RecordType.Name!='Customer Data' and 
                         Type!='Traypack Audit' And Type!='VAP/LTO Allocation' And Type!='Giftshop Pricing' 
                         and ParentId in :parentCaseIdList];
        }
        
        for (Case subCase : CasesList) {
            subCase.Status = 'Closed';
        }
	     if (CasesList.Size()>0) {
            caseServices.runTrigger = False;
            CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
            update CasesList;	
        }
    }
    
      /*******************************************************************************************************************************
Description:    This method is used to update status of State License Registration Cases. 
<Date>          <Authors Name>     <Company>     <Brief Description of Change>
03/2024          Devyani Gupta      Metacube       Initial Creation
******************************************************************************************************************************/  
    @future
    public static void stateLicenseStatusChange(String casesJSON){
        List<Case> parentCaseList = (List<Case>)JSON.deserialize(casesJSON,list<case>.class);
        System.debug('parentCaseList---'+parentCaseList);
        List<Case> CasesList = new List<Case>();
        for (Case pcase : parentCaseList) {
            if (pcase.Submitted_Date__c != null) {
                CasesList.add(pcase);
            }
        }
        System.debug('CasesList---'+CasesList);
        if (CasesList.size()>0) {
            for (case cse : CasesList){
                if (!cse.License_Received_Audit__c && !cse.Pending_3rd_party__c ) {
                    if (cse.License_Received_Date__c == null){
                        cse.Status = ComplianceConstants.CASE_STATUS_SUBMITTED_WAITING_FOR_LICENSE_COPY;
                    }
                    else {
                        cse.Status = 'Ready for Audit';
                    }
                }
                else if (cse.License_Received_Audit__c && cse.License_Received_Date__c != null){
                    cse.Status = 'Closed';
                }
            }
            System.debug('CasesList22---'+CasesList);
            caseServices.runTrigger = False;
            CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
            update CasesList;	
        }
    }
}