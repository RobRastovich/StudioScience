public without sharing class SubmitQuoteRequestController {
    public SubmitQuoteRequestController() {
        
    }

    public static String getStateRepresentativeEmail(String state){
        String quoteRequestProfile = ComplianceConstants.QUOTE_REQUEST_COMPLIANCE_COORDINATOR_PROFILE;
        String queueDevName = ComplianceConstants.QUOTE_REQUEST_QUEUE_API_NAME;
        String email = '';
        User stateRep = CaseComplianceUtility.getComplianceCoordinatorByState(state, quoteRequestProfile);
        if(stateRep != null){
            email = stateRep.Email;
        } else{
            List<Group> quoteRequestQueue = [SELECT Id, Email, DeveloperName, Type FROM Group WHERE Type = 'Queue' AND DeveloperName =: queueDevName LIMIT 1];
            if(!quoteRequestQueue.isEmpty() && quoteRequestQueue[0].Email != null){
                email = quoteRequestQueue[0].Email;
            }
        }
        return email;
    }

    @AuraEnabled
    public static CaseComplianceUtility.RequestStatus getUserAttributeMap(){
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();

        try{
            Map<String, Boolean> attrMap = new Map<String, Boolean>();
            Id userId = UserInfo.getUserId();
            User currUser = [SELECT Id, Profile.Name FROM User WHERE Id =: userId];

            String stateContactProfile = ComplianceConstants.COMMUNITY_STATE_CONTACT_PROFILE;
            String stateManagerProfile = ComplianceConstants.COMMUNITY_STATE_MANAGER_PROFILE;
            String stateManagerProfileEdge = ComplianceConstants.COMMUNITY_STATE_MANAGER_PROFILE_EDGE;
            Boolean isStateContact = (currUser.Profile.Name).equalsIgnoreCase(stateContactProfile);
            Boolean isStateManager = ((currUser.Profile.Name).equalsIgnoreCase(stateManagerProfile)) || ((currUser.Profile.Name).equalsIgnoreCase(stateManagerProfileEdge));

            attrMap.put('contact', isStateContact);
            attrMap.put('manager', isStateManager);
            attrMap.put('other', !(isStateContact || isStateManager));
            responseMap.put('attributeMap', attrMap);           
        } catch(Exception e){
            success = false;
            message = e.getMessage();
        }

        CaseComplianceUtility.RequestStatus requestStatus = new CaseComplianceUtility.RequestStatus(success, message, responseMap);
        return requestStatus;
    }

    public static List<String> getStatePicklistValues(){
        List<String> representedStates = CaseComplianceUtility.retrieveCurrentLoggedInUserStateAffiliation();
        return representedStates;
    }

    public static List<String> getQuoteRequestItemSizePicklistValues(){
        String itemSizeAPIName = ComplianceConstants.QUOTE_REQUEST_ITEM_SIZE_FIELD_API_NAME;
        List<String> optionLabels = new List<String>();
        Map<String, Schema.SObjectField> fieldMap = Quote_Request__c.getSObjectType().getDescribe().fields.getMap();
        List<Schema.PicklistEntry> picklistValues = fieldMap.get(itemSizeAPIName).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry ple : picklistValues) {
            optionLabels.add(ple.getLabel());
        }

        return optionLabels;
    }

    public static List<String> getQuoteRequestQuoteTypePicklistValues(){
        String quoteTypeAPIName = ComplianceConstants.QUOTE_REQUEST_QUOTE_TYPE_FIELD_API_NAME;
        List<String> optionLabels = new List<String>();
        Map<String, Schema.SObjectField> fieldMap = Quote_Request__c.getSObjectType().getDescribe().fields.getMap();
        List<Schema.PicklistEntry> picklistValues = fieldMap.get(quoteTypeAPIName).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry ple : picklistValues) {
            optionLabels.add(ple.getLabel());
        }

        return optionLabels;
    }

    @AuraEnabled
    public static CaseComplianceUtility.RequestStatus getPicklistValueMap(){
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        try{
            List<String> stateList = getStatePicklistValues();
            List<String> itemSizeList = getQuoteRequestItemSizePicklistValues();
            List<String> quoteTypeList = getQuoteRequestQuoteTypePicklistValues();
            Map<String, List<String>> picklistMap = new Map<String, List<String>>{
                'state' => stateList,
                'item_size' => itemSizeList,
                'quote_type' => quoteTypeList
            };
            responseMap.put('picklistValueMap', picklistMap);
        } catch(Exception e){
            success = false;
            message = e.getMessage();
        }

        CaseComplianceUtility.RequestStatus requestStatus = new CaseComplianceUtility.RequestStatus(success, message, responseMap);
        return requestStatus;
    }

    @AuraEnabled
    public static CaseComplianceUtility.RequestStatus insertNewQuoteRequest(List<Quote_Request__c> quoteRequestList, String state, String priority, String type, String recipient){
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();

        try{
            String quoteRequestRTName = ComplianceConstants.RECORDTYPE_QUOTE_REQUEST;
            Id quoteRequestRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(quoteRequestRTName).getRecordTypeId();
            Id currentUserId = UserInfo.getUserId();
            String stateContactEmail = '';
            String stateManagerEmail = '';
            String repEmail = getStateRepresentativeEmail(state);
            String entitlementType = null;

            Map<String, Compliance_State_Metadata__c> metadataMap = Compliance_State_Metadata__c.getAll();
            if(metadataMap.containsKey(state)){
                stateManagerEmail = metadataMap.get(state).State_Manager_Email__c;
            }

            Case quoteRequestCase = new Case();
            quoteRequestCase.Submitter__c = currentUserId;
            quoteRequestCase.RecordTypeId = quoteRequestRTId;
            quoteRequestCase.State__c = state;
            quoteRequestCase.Priority = priority;
            quoteRequestCase.Origin = 'Portal';
            quoteRequestCase.Type = type;
            quoteRequestCase.Status = null;
            quoteRequestCase.Name__c = recipient;
            quoteRequestCase.State_Manager_Email__c = stateManagerEmail;

            if(quoteRequestList.size() > 1){
                quoteRequestCase.Description = 'Multiple Items';
            } else if(quoteRequestList.size() == 1){
                Quote_Request__c qr = quoteRequestList[0];
                quoteRequestCase.Description = qr.Item_Name__c + ' - ' + qr.Item_Size__c;
            }

            if(String.isNotBlank(priority)){
                entitlementType = ComplianceConstants.ENTITLEMENT_QUOTE_REQUEST;
            }

            if(String.isNotBlank(entitlementType)){
                Entitlement ent = [SELECT Id FROM Entitlement WHERE Name=:entitlementType LIMIT 1];
                quoteRequestCase.EntitlementId = ent.Id;
            }

            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.AssignmentRuleHeader.useDefaultRule = true;
            quoteRequestCase.setOptions(dmo);

            insert quoteRequestCase;
            for(Quote_Request__c qr: quoteRequestList){
                qr.Case__c = quoteRequestCase.Id;
            }
            insert quoteRequestList;
            CaseComplianceUtility.sendNotificationOnQuoteRequestCreation(quoteRequestCase.Id, repEmail);
            quoteRequestCase = [SELECT Id, CaseNumber FROM Case WHERE Id =: quoteRequestCase.Id];
            responseMap.put('quoteRequestCase', quoteRequestCase);
        } catch(Exception e){
            success = false;
            message = e.getMessage();
        }

        CaseComplianceUtility.RequestStatus requestStatus = new CaseComplianceUtility.RequestStatus(success, message, responseMap);
        return requestStatus;
    }
}