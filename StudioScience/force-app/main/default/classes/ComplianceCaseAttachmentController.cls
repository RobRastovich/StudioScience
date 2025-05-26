public with sharing class ComplianceCaseAttachmentController{
    public ComplianceCaseAttachmentController() {
        
    }

    @AuraEnabled
    public static List<String> getDocumentTypePicklistValues(String caseId){
        List<Case> currentCaseList = [SELECT Id, Type, RecordTypeId, RecordType.Name, Status FROM Case WHERE Id =: caseId LIMIT 1];
        Set<String> allowedDocumentTypes = new Set<String>();
        
        if(!currentCaseList.isEmpty()){
            Case currentCase = currentCaseList[0];
            String rtName = currentCase.RecordType.Name;
            if(rtName.equals(ComplianceConstants.RECORDTYPE_BRAND_REGISTRATION)){
                allowedDocumentTypes.addAll(ComplianceConstants.BR_DOC_TYPE_LIST);
            } else if(rtName.equals(ComplianceConstants.RECORDTYPE_SUB_CASE)){
                String notSubmitted = ComplianceConstants.CASE_STATUS_NOT_SUBMITTED;
                String waitingForApproval = ComplianceConstants.CASE_STATUS_WAITING_FOR_APPROVAL;
                String waitingForResubmission = ComplianceConstants.CASE_STATUS_REJECTED_WAITING_FOR_RESUBMISSION;
                String documentTypeSubmission = ComplianceConstants.DOCUMENT_TYPE_SUBMISSION;
                String documentTypeApproval = ComplianceConstants.DOCUMENT_TYPE_APPROVAL;

                if(currentCase.Status == notSubmitted || currentCase.Status == waitingForResubmission){
                    allowedDocumentTypes.add(documentTypeSubmission);
                } else if(currentCase.Status == waitingForApproval){
                    allowedDocumentTypes.add(documentTypeApproval);
                }
                allowedDocumentTypes.add('Other');
            } else if(rtName.equals(ComplianceConstants.RECORDTYPE_QUOTE_REQUEST)){
                allowedDocumentTypes.addAll(ComplianceConstants.QR_DOC_TYPE_LIST);
            } else if(rtName.equals(ComplianceConstants.RECORDTYPE_PRICE_POSTING)){
                allowedDocumentTypes.addAll(ComplianceConstants.PP_DOC_TYPE_LIST);
            } else if(rtName.equals(ComplianceConstants.RECORDTYPE_PRICE_FILING)){
                allowedDocumentTypes.addAll(ComplianceConstants.PF_DOC_TYPE_LIST);
            } else if(rtName.equals(ComplianceConstants.RECORDTYPE_DISCOUNT)){
                allowedDocumentTypes.addAll(ComplianceConstants.DISC_DOC_TYPE_LIST);
            } else {
                allowedDocumentTypes.add('Other');
            }
        }

        List<String> optionLabels = new List<String>();
        String documentTypeAPIName = ComplianceConstants.CONTENT_VERSION_DOCUMENT_TYPE_FIELD_API_NAME;
        Map<String, Schema.SObjectField> fieldMap = ContentVersion.getSObjectType().getDescribe().fields.getMap();
        List<Schema.PicklistEntry> picklistValues = fieldMap.get(documentTypeAPIName).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry ple : picklistValues) {
            if(allowedDocumentTypes.contains(ple.getLabel())){
                optionLabels.add(ple.getLabel());
            }
        }

        //In the event that there are no active picklist values, populate the list with an 'Other' option
        if(optionLabels.isEmpty()){
            optionLabels.add('Other');
        }

        return optionLabels;
    }

    @AuraEnabled
    public static void assignDocumentTypesAfterUpload(String documentType, List<Id> contentVersionIdList,String ParentCaseId){
        
        List<ContentVersion> cvList = [SELECT Id, Document_Type__c FROM ContentVersion WHERE ContentDocumentId IN: contentVersionIdList];
        for(ContentVersion cv: cvList){
            cv.Document_Type__c = documentType;
        }
        update cvList;
        
     //Below lines added by Sripal 08/16
     List<Case> childCases = new List<Case>();
     childCases = [SELECT id,CaseNumber FROM Case WHERE ParentId=:ParentCaseId AND (Recordtype.DeveloperName='Customer_Data' OR Recordtype.DeveloperName='Inquiry')];
     List<ContentDocument> DocumentList = new List<ContentDocument>();  
     Set<Id> documentIds = new Set<Id>();  //store file ids
     List<ContentDocumentLink> cdl=[select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:ParentCaseId];  
     for(ContentDocumentLink cdLink:cdl){  
       documentIds.add(cdLink.ContentDocumentId);  // Document ids
     }      
     DocumentList = [select Id,Title,FileType,ContentSize,Description from ContentDocument where id IN: documentIds];  
     List<ContentVersion> parentContentVersion  = new List<ContentVersion>(); 
        parentContentVersion =[select id,ContentDocumentId,ContentLocation,ContentSize,FileExtension,FileType,IsMajorVersion,Origin,OwnerId,
          PathOnClient,RecordTypeId,Title,PublishStatus,VersionData,VersionNumber,Document_Type__c from ContentVersion WHERE ContentDocumentId IN: contentVersionIdList];
	  system.debug('======parentContentVersion==='+parentContentVersion);
      List<ContentVersion>ContentVerList = new List<ContentVersion>();
        for(ContentVersion con:parentContentVersion){
            ContentVersion cv = new ContentVersion();
            cv = con.clone();
            ContentVerList.add(cv);
        }
        insert ContentVerList;
        system.debug('===========ContentVerList========='+ContentVerList);
         List<ContentDocumentLink> childcontdoclist = new  List<ContentDocumentLink>();
       
         for(ContentVersion child:ContentVerList){
            for(Case caserec:childCases){
            ContentDocumentLink docLink = new ContentDocumentLink();
            docLink.LinkedEntityId = caserec.id;
            docLink.ContentDocumentId = child.ContentDocumentId;
            childcontdoclist.add(docLink);
        	}
        }
        insert childcontdoclist;
        system.debug('===========childcontdoclist========='+childcontdoclist);
		
        
        
    }

    public static void deleteAllButMostRecentDocumentType(String caseId, String documentType){
        Map<Id, ContentDocumentLink> contentDocumentToLinkMap = new Map<Id, ContentDocumentLink>();
        List<ContentDocumentLink> cdLinkList = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.CreatedDate
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =: caseId
                                                ORDER BY ContentDocument.CreatedDate DESC];

        
        Map<Id, DateTime> contentDocumentDateMap = new Map<Id, DateTime>();
        for(ContentDocumentLink cdl: cdLinkList){
            contentDocumentDateMap.put(cdl.ContentDocumentId, cdl.ContentDocument.CreatedDate);
        }
        System.debug(LoggingLevel.INFO, contentDocumentDateMap);
    }

    @AuraEnabled
    public static void setSelectedAttachmentFlag(String caseId, String documentType){
        String subCaseRTName = ComplianceConstants.RECORDTYPE_SUB_CASE;
        String brandRegistrationRTName = ComplianceConstants.RECORDTYPE_BRAND_REGISTRATION;
        String quoteRequestRTName = ComplianceConstants.RECORDTYPE_QUOTE_REQUEST;
        String pricePostingRTName = ComplianceConstants.RECORDTYPE_PRICE_POSTING;
        String priceFilingRTName = ComplianceConstants.RECORDTYPE_PRICE_FILING;
        String discountRTName = ComplianceConstants.RECORDTYPE_DISCOUNT;
        String approvedValue = ComplianceConstants.APPROVED;
        String rejectedValue = ComplianceConstants.REJECTED;

        String statusNew = ComplianceConstants.CASE_STATUS_NEW;
        String statusWorking = ComplianceConstants.CASE_STATUS_WORKING;
        String statusNotSubmitted = ComplianceConstants.CASE_STATUS_NOT_SUBMITTED;
        String statusWaitingForKickoff = ComplianceConstants.CASE_STATUS_WAITING_FOR_KICKOFF;
        String statusWaitingForSubmission = ComplianceConstants.CASE_STATUS_WAITING_FOR_SUBMISSION;
        String statusWaitingForApproval = ComplianceConstants.CASE_STATUS_WAITING_FOR_APPROVAL;
        String statusWaitingForPosting = ComplianceConstants.CASE_STATUS_WAITING_FOR_POSTING;
        String statusWatingForStateManager = ComplianceConstants.CASE_STATUS_WAITING_FOR_STATE_MANAGER;
        String statusWaitingForResubmission = ComplianceConstants.CASE_STATUS_REJECTED_WAITING_FOR_RESUBMISSION;
        String statusClosed = ComplianceConstants.CASE_STATUS_CLOSED;
        String statusClosedNoAction = ComplianceConstants.CASE_STATUS_CLOSED_NO_ACTION;

        String documentTypeKickoff = ComplianceConstants.DOCUMENT_TYPE_KICKOFF;
        String documentTypeSubmission = ComplianceConstants.DOCUMENT_TYPE_SUBMISSION;
        String documentTypeSubmissionConfirmation = ComplianceConstants.DOCUMENT_TYPE_SUBMISSION_CONFIRMATION;
        String documentTypeStateManagerApproval = ComplianceConstants.DOCUMENT_TYPE_STATE_MANAGER_APPROVAL;
        String documentTypeApproval = ComplianceConstants.DOCUMENT_TYPE_APPROVAL;
        String documentTypeQuote = ComplianceConstants.DOCUMENT_TYPE_QUOTE;
        String documentTypeBlankWorkbook = ComplianceConstants.DOCUMENT_TYPE_BLANK_WORKBOOK;
        String documentTypeFinalizedWorkbook = ComplianceConstants.DOCUMENT_TYPE_FINALIZED_WORKBOOK;
        String documentTypeDiscountsDocument = ComplianceConstants.DOCUMENT_TYPE_DISCOUNTS_DOCUMENT;
        String documentTypeOther = ComplianceConstants.DOCUMENT_TYPE_OTHER;

        String generalAttachmentFlag = ComplianceConstants.FLAG_GENERAL_ATTACHMENT;

        Id brandRegistrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(brandRegistrationRTName).getRecordTypeId();
        Id complianceSubCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(subCaseRTName).getRecordTypeId();
        Id quoteRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(quoteRequestRTName).getRecordTypeId();
        Id pricePostingRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(pricePostingRTName).getRecordTypeId();
        Id priceFilingRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(priceFilingRTName).getRecordTypeId();
        Id discountRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(discountRTName).getRecordTypeId();
        Case currentCase = [SELECT Id, RecordTypeId, OwnerId, State_Type__c, Compliance_Flagset__c, Approval_Status__c, Approval_Needed__c, Approval_Date__c, Submission_Date__c, Posting_Date__c, State__c, State_Manager_Email__c FROM Case WHERE Id =: caseId];
        Boolean needsUpdate = false;

        if(currentCase.RecordTypeId == complianceSubCaseRecordTypeId){
            if(documentType.equals(documentTypeSubmission)){
                if(currentCase.State_Type__c.contains('Auto Approval')){
                    if(currentCase.Submission_Date__c == null){
                        currentCase.Submission_Date__c = System.Today();
                    }
                    if(currentCase.Approval_Date__c == null){
                        currentCase.Approval_Date__c = System.Today();
                    }
                    currentCase.Approved__c = true;
                    currentCase.Approval_Status__c = approvedValue;
                    if(!currentCase.State_Type__c.contains('Price Posting')){
                        currentCase.Status = 'Closed';
                    } else {
                        currentCase.Status = 'Waiting for Posting';
                    }
                } else if(currentCase.State_Type__c.contains('Prior Approval')){
                    if(currentCase.Submission_Date__c == null){
                        currentCase.Submission_Date__c = System.Today();
                    }
                    currentCase.Status = 'Waiting for Approval';
                }
                currentCase.Submitted_Compliance__c = true;
                
                needsUpdate = true;
            } else if(documentType.equals(documentTypeApproval)){
                if(currentCase.Approval_Date__c == null){
                    currentCase.Approval_Date__c = System.Today();
                }
                currentCase.Approved__c = true;
                currentCase.Approval_Status__c = approvedValue;

                if(currentCase.State_Type__c.contains('Price Posting')){
                    currentCase.Status = 'Waiting for Posting';
                } else {
                    currentCase.Status = 'Closed';
                }
                currentCase.Submitted_Compliance__c = true;
                if(currentCase.Submission_Date__c == null){
                    currentCase.Submission_Date__c = System.Today();
                }
                needsUpdate = true;
            }
        } else if(currentCase.RecordTypeId == pricePostingRecordTypeId){
            if(documentType.equals(documentTypeSubmission)){
                currentCase.Submitted_Compliance__c = true;
                if(currentCase.Submission_Date__c == null){
                    currentCase.Submission_Date__c = System.Today();
                }
                currentCase.Status = 'Close Pending';
                needsUpdate = true;
            } else if(documentType.equals(documentTypeSubmissionConfirmation)){
                String submissionConfirmation = ComplianceConstants.FLAG_PRICE_POSTING_SUBMISSION_CONFIRMATION;
                String flagset = String.isBlank(currentCase.Compliance_Flagset__c) ? '' : currentCase.Compliance_Flagset__c;
                if(!flagset.contains(submissionConfirmation)){
                    flagset += ';'+submissionConfirmation+';';
                    currentCase.Compliance_Flagset__c = flagset;
                    needsUpdate = true;
                }
            } else if(documentType.equals(documentTypeStateManagerApproval)){
                String stateManagerApproval = ComplianceConstants.FLAG_PRICE_POSTING_STATE_MANAGER_APPROVAL;
                String flagset = String.isBlank(currentCase.Compliance_Flagset__c) ? '' : currentCase.Compliance_Flagset__c;
                if(!flagset.contains(stateManagerApproval)){
                    flagset += ';'+stateManagerApproval+';';
                    currentCase.Compliance_Flagset__c = flagset;
                    needsUpdate = true;
                }
            }
        } else if(currentCase.RecordTypeId == priceFilingRecordTypeId){
            if(documentType.equals(documentTypeBlankWorkbook)){
                String blankWorkbookFlag = ComplianceConstants.FLAG_PRICE_FILING_HAS_BLANK_WORKBOOK;
                CaseComplianceUtility.sendEmailOnPriceFilingBlankBookUpload(new Map<Id, Case>{currentCase.Id => currentCase});
                currentCase.Status = 'Waiting for State Manager';
                currentCase = CaseComplianceUtility.setComplianceFlagsetValue(currentCase, blankWorkbookFlag);
                needsUpdate = true;
            } else if(documentType.equals(documentTypeFinalizedWorkbook)){
                //Reset the progress of the case, as a new Finalized Workbook was uploaded
                String finalizedWorkbookFlag = ComplianceConstants.FLAG_PRICE_FILING_HAS_FINALIZED_WORKBOOK;
                CaseComplianceUtility.sendEmailOnPriceFilingFinalizedBookUpload(new Map<Id, Case>{currentCase.Id => currentCase});
                currentCase.Rejected__c = false;
                currentCase.Approved__c = false;
                currentCase.Approval_Status__c = null;
                currentCase.Approval_Date__c = null;
                currentCase.Status = 'Waiting for Approval';
                currentCase = CaseComplianceUtility.setComplianceFlagsetValue(currentCase, finalizedWorkbookFlag);
                needsUpdate = true;
                try{
                    deleteAllButMostRecentDocumentType(caseId, documentType);
                } catch(Exception e){
                    System.debug(LoggingLevel.INFO, e.getMessage());
                }           
            } else if(documentType.equals(documentTypeSubmission)){
                currentCase.Submitted_Compliance__c = true;
                currentCase.Submission_Date__c = System.Today();
                currentCase.Status = 'Close Pending';
                needsUpdate = true;
            }
        } else if(currentCase.RecordTypeId == discountRecordTypeId){
            if(documentType.equals(documentTypeDiscountsDocument) && currentCase.Approval_Status__c != 'Approved'){
                String hasDiscountDocumentFlag = ComplianceConstants.FLAG_DISCOUNT_HAS_DISCOUNT_DOCUMENT;               
                if(currentCase.Approval_Needed__c == 'Yes'){
                    CaseComplianceUtility.sendEmailDiscountNeedsApproval(new List<Case>{currentCase});
                }
                currentCase.Approved__c = false;
                currentCase.Rejected__c = false;
                currentCase.Approval_Status__c = null;
                currentCase = CaseComplianceUtility.setComplianceFlagsetValue(currentCase, hasDiscountDocumentFlag);

                needsUpdate = true;
            }
        }
        
        String generalFlagset = String.isBlank(currentCase.Compliance_Flagset__c) ? '' : currentCase.Compliance_Flagset__c;
        if(!generalFlagset.contains(generalAttachmentFlag)){
            generalFlagset += ';'+generalAttachmentFlag+';';
            currentCase.Compliance_Flagset__c = generalFlagset;
            needsUpdate = true;
        }
        
        try{
            if(needsUpdate){
                update currentCase;
            }
        } catch(Exception e){
            System.debug(LoggingLevel.INFO, e.getMessage());
        }
    }
}