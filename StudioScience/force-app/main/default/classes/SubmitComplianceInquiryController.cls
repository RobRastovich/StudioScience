public without sharing class SubmitComplianceInquiryController {
    public SubmitComplianceInquiryController() {
        
    }

    @AuraEnabled
    public static CaseComplianceUtility.RequestStatus getPicklistValueMap(){
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();

        try{
            List<String> caseTypePicklistValues = getCaseTypePicklistValues();
            List<String> userStatePicklistValues = getStatePicklistValues();
            responseMap.put('typeValues', caseTypePicklistValues);
            responseMap.put('stateValues', userStatePicklistValues);
        } catch(Exception e){
            success = false;
            message = e.getMessage();
        }

        CaseComplianceUtility.RequestStatus requestStatus = new CaseComplianceUtility.RequestStatus(success, message, responseMap);
        return requestStatus;
    }

    @AuraEnabled
    public static CaseComplianceUtility.RequestStatus getContentDocumentData(List<Id> documentIdList){
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();

        try{
            List<ContentDocument> documentList = getContentDocumentsByIdList(documentIdList);
            responseMap.put('documentList', documentList);
        } catch(Exception e){
            success = false;
            message = e.getMessage();
        }

        CaseComplianceUtility.RequestStatus requestStatus = new CaseComplianceUtility.RequestStatus(success, message, responseMap);
        return requestStatus;
    }

    @AuraEnabled
    public static CaseComplianceUtility.RequestStatus deleteContentDocumentList(Id deletedDocumentId, List<Id> fullDocumentIdList){
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();

        try{
            ContentDocument deletedCd = new ContentDocument(Id=deletedDocumentId);
            delete deletedCd;

            List<ContentDocument> documentList = getContentDocumentsByIdList(fullDocumentIdList);
            responseMap.put('documentList', documentList);
        } catch(Exception e){
            success = false;
            message = e.getMessage();
        }

        CaseComplianceUtility.RequestStatus requestStatus = new CaseComplianceUtility.RequestStatus(success, message, responseMap);
        return requestStatus;
    }
    
    @AuraEnabled
    public static CaseComplianceUtility.RequestStatus retrieveComplianceAccount(){
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();        
        
        try{
            String complianceAccount = ComplianceConstants.COMPLIANCE_ACCOUNT_NAME;
            List<Account> acc = [SELECT Id FROM Account WHERE Name =: complianceAccount LIMIT 1];
            if(!acc.isEmpty()){
                responseMap.put('accountId', acc[0].Id);
            } else{
                Account compAccount = new Account(Name=complianceAccount);
                insert compAccount;
                responseMap.put('accountId', compAccount.Id);
            }
        } catch(Exception e){
            success = false;
            message = e.getMessage();
        }

        CaseComplianceUtility.RequestStatus requestStatus = new CaseComplianceUtility.RequestStatus(success, message, responseMap);
        return requestStatus;
    }

    @AuraEnabled
    public static CaseComplianceUtility.RequestStatus insertComplianceInquiryCase(String state, String inquiryType, String details, List<Id> documentIdList){
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();

        try{
            String inquiryRTName = ComplianceConstants.RECORDTYPE_COMPLIANCE_INQUIRY;
            Id inquiryRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(inquiryRTName).getRecordTypeId();
            Id currentUserId = UserInfo.getUserId();
            
            Case inquiryCase = new Case();
            inquiryCase.Submitter__c = currentUserId;
            inquiryCase.RecordTypeId = inquiryRecordTypeId;
            inquiryCase.State__c = state;
            inquiryCase.Origin = 'Portal';
            inquiryCase.Type = inquiryType;
            inquiryCase.Description = details;
            insert inquiryCase;

            if(documentIdList.size() > 0){
                List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                for(Id documentId: documentIdList){
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.LinkedEntityId = inquiryCase.Id;
                    cdl.ContentDocumentId = documentId;
                    cdl.ShareType = 'V';
                    cdlList.add(cdl);
                }
                insert cdlList;             
            }

            inquiryCase = [SELECT Id, CaseNumber FROM Case WHERE Id =: inquiryCase.Id];
            responseMap.put('case', inquiryCase);

            //List<String> toAddressList = getStateRepresentativeEmailList(state);
            List<String> toAddressList = getStateRepresentativecomplianceMail(state);
            system.debug('inside compliance inquiry controller after calling getStateRepresentativeEmailList::::'+toAddressList);
            CaseComplianceUtility.sendNotificationOnComplianceInquiryCreation(inquiryCase.Id, toAddressList);

        } catch(Exception e){
            success = false;
            message = e.getMessage();
        }

        CaseComplianceUtility.RequestStatus requestStatus = new CaseComplianceUtility.RequestStatus(success, message, responseMap);
        return requestStatus;
    }

    public static List<ContentDocument> getContentDocumentsByIdList(List<Id> contentDocumentIdList){
        List<ContentDocument> documentList = [SELECT Id, Title, FileType, ContentSize FROM ContentDocument WHERE Id IN :contentDocumentIdList];
        return documentList;
    }

    public static List<String> getCaseTypePicklistValues(){
        String caseTypeAPIName = ComplianceConstants.CASE_TYPE_FIELD_API_NAME;
        List<String> inquiryTypeList = ComplianceConstants.COMPLIANCE_INQUIRY_TYPE_LIST;
        List<String> returnedTypeList = new List<String>();     
        Set<String> optionLabels = new Set<String>();
        Map<String, Schema.SObjectField> fieldMap = Case.getSObjectType().getDescribe().fields.getMap();
        List<Schema.PicklistEntry> picklistValues = fieldMap.get(caseTypeAPIName).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry ple : picklistValues) {
            optionLabels.add(ple.getLabel());
        }

        //This ensures that only valid type values are returned.
        for(String inquiryType: inquiryTypeList){
            if(optionLabels.contains(inquiryType)){
                returnedTypeList.add(inquiryType);
            }
        }

        return returnedTypeList;
    }

    public static List<String> getStatePicklistValues(){
        String userStatesAPIName = ComplianceConstants.USER_REPRESENTED_STATES_FIELD_API_NAME;
        List<String> optionLabels = new List<String>();
        Map<String, Schema.SObjectField> fieldMap = User.getSObjectType().getDescribe().fields.getMap();
        List<Schema.PicklistEntry> picklistValues = fieldMap.get(userStatesAPIName).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry ple : picklistValues) {
            optionLabels.add(ple.getLabel());
        }

        return optionLabels;
    }

    public static List<String> getStateRepresentativeEmailList(String state){
        String quoteRequestProfile = ComplianceConstants.QUOTE_REQUEST_COMPLIANCE_COORDINATOR_PROFILE;
        String complianceGroupName = ComplianceConstants.GROUP_COMPLIANCE_TEAM_API_NAME;
        List<String> emailList = new List<String>();
        User stateRep = CaseComplianceUtility.getComplianceCoordinatorByState(state, quoteRequestProfile);
        system.debug('inside compliance inquiry controller getStateRepresentativeEmailList::::'+stateRep );
        if(stateRep != null){
        system.debug('inside compliance inquiry controller getStateRepresentativeEmailList::::inside if:::');
            emailList.add(stateRep.Email);
        system.debug('inside compliance inquiry controller getStateRepresentativeEmailList::::inside if:::'+emailList);    
        } else{
        system.debug('inside compliance inquiry controller getStateRepresentativeEmailList::::inside else:::');
            List<Group> complianceTeamGroup = [SELECT Id, Email, DeveloperName, Type, (SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE DeveloperName =: complianceGroupName LIMIT 1];
            if(complianceTeamGroup.size() > 0){
                Set<Id> userIdList = new Set<Id>();

                for(GroupMember gm: complianceTeamGroup[0].GroupMembers){
                    userIdList.add(gm.UserOrGroupId);
                }
                system.debug('inside compliance inquiry controller getStateRepresentativeEmailList::::afert for:::'+userIdList);
                List<User> groupMemberList = [SELECT Email FROM User WHERE Id IN :userIdList];
                for(User groupUser: groupMemberList){
                    emailList.add(groupUser.Email);
                }
                
            }
        }
        system.debug('inside compliance inquiry controller getStateRepresentativeEmailList::::afert for:::'+emailList);
        return emailList;
    }
    
    public static List<String> getStateRepresentativecomplianceMail(String state){
        String quoteRequestProfile = ComplianceConstants.QUOTE_REQUEST_COMPLIANCE_COORDINATOR_PROFILE;
        String complianceGroupName = ComplianceConstants.GROUP_COMPLIANCE_TEAM_API_NAME;
        String complianceMail = ComplianceConstants.PROD_COMPLIANCE_ADDRESS;
        List<String> emailList = new List<String>();
        User stateRep = CaseComplianceUtility.getComplianceCoordinatorByState(state, quoteRequestProfile);
        system.debug('inside compliance inquiry controller getStateRepresentativeEmailList::::'+stateRep );
        if(stateRep != null){
        system.debug('inside compliance inquiry controller getStateRepresentativeEmailList::::inside if:::');
            emailList.add(stateRep.Email);
        system.debug('inside compliance inquiry controller getStateRepresentativeEmailList::::inside if:::'+emailList);    
        } 
        else{ 
              emailList.add(complianceMail);
             }
           
        system.debug('inside compliance inquiry controller getStateRepresentativeEmailList::::afert for:::'+emailList);
        return emailList;
    }
}