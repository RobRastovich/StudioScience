public class CNT_CSG_Claim {
    
    @AuraEnabled
    public static Map<String, String> createCase(Case caseObj) {
        List<User> lstUserDetail = SLT_User.getUserDetail(userinfo.getUserId());
        RecordType currentRecordTypeId = [select Id, name from recordtype where name =: caseObj.Change_Reason__c limit 1];
        caseObj.Origin = 'Portal';
        caseObj.ContactId = lstUserDetail[0].ContactId;
        caseObj.RecordTypeId = currentRecordTypeId.Id;
        caseObj.submitter__c = userinfo.getUserId();
        caseObj.Priority = 'Medium';
        String AccountId = [Select accountId from Contact where Id =: lstUserDetail[0].ContactId].accountId;
        caseObj.EntitlementId = [Select Id from Entitlement where  SlaProcess.Name = 'CSG Order Claim' and  Account.Id =:AccountId  AND SlaProcess.isActive = true Limit 1].Id;//'5506s0000004dPK';
        caseObj.BusinessHoursId = [Select Id from BusinessHours where name = 'Germany Business Hours' limit 1].Id;
        if(!String.isEmpty(caseObj.Id)){
            update caseObj;
        } else {
            insert caseObj;  
            CaseShare newCaseShare = new CaseShare();
        }
        return new Map<String, String>{'Id' => caseObj.Id};
            }
    
    @AuraEnabled
    public static Map<String, String> updateCase(Case caseObj) {
        System.debug('caseObj--'+caseObj);
        caseObj.Flow_Completed__c = true;
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule = true;
        caseObj.setOptions(dmlOpts);
        if(!String.isEmpty(caseObj.Id)){
            update caseObj;
        } 
        return new Map<String, String>{'Id' => caseObj.Id};
            }
    
    @AuraEnabled
    public static Map<String, String> getRecordTypeForCase(){
        Map<String, String> mapOfRecordType = New Map<String, String>();
        List<User> lstUserDetail = SLT_User.getUserDetail(userinfo.getUserId());
        List<Profile> lstProfile = SLT_Profile.getProfileDetail(lstUserDetail[0].ProfileId); 
        String profileName = '%'+ lstProfile[0].Name +'%';
        String accessGroup = '%'+ lstUserDetail[0].Access_Group__c +'%';
        String language = '%'+ lstUserDetail[0].LanguageLocaleKey +'%';
        SYstem.debug('language--'+language);
        List<CSG_Record_Type__c> lstCSGRecord = SLT_CustomSetting.getCSGRecordType(accessGroup, profileName, language); 
        for(CSG_Record_Type__c newRecordType : lstCSGRecord){
            mapOfRecordType.put(newRecordType.Label__c, newRecordType.Value__c);
        }
        return mapOfRecordType;
    }
    
    @AuraEnabled
    public static Map<String, String> getTypeSelectionForCase(String recordTypeName){
        Map<String, String> mapOfRecordType = New Map<String, String>();
        List<User> lstUserDetail = SLT_User.getUserDetail(userinfo.getUserId());
        List<Profile> lstProfile = SLT_Profile.getProfileDetail(lstUserDetail[0].ProfileId); 
        String profileName = '%'+ lstProfile[0].Name +'%';
        String accessGroup = '%'+ lstUserDetail[0].Access_Group__c +'%';
        String language = '%'+ lstUserDetail[0].LanguageLocaleKey +'%';
        recordTypeName = '%'+recordTypeName+'%';
        List<CSG_Type_Selection__c > lstCSGRecord = SLT_CustomSetting.getTypeSelection(accessGroup, profileName, language, recordTypeName);
        System.debug(lstCSGRecord+'*****'+lstUserDetail);
        for(CSG_Type_Selection__c newRecordType : lstCSGRecord){
            mapOfRecordType.put(newRecordType.Label__c, newRecordType.Value__c);
        }
        return mapOfRecordType;
    }
    
    
    @AuraEnabled
    public static Map<String, String> getProductSizeForCase(String recordTypeName){
        Map<String, String> mapOfRecordType = New Map<String, String>();
        List<User> lstUserDetail = SLT_User.getUserDetail(userinfo.getUserId());
        List<Profile> lstProfile = SLT_Profile.getProfileDetail(lstUserDetail[0].ProfileId); 
        String profileName = '%'+ lstProfile[0].Name +'%';
        String accessGroup = '%'+ lstUserDetail[0].Access_Group__c +'%';
        String language = '%'+ lstUserDetail[0].LanguageLocaleKey +'%';
        recordTypeName = '%'+recordTypeName+'%';
        List<CSG_Product_SIze__c> lstCSGRecord = SLT_CustomSetting.getProductSize(accessGroup, profileName, language, recordTypeName);
        for(CSG_Product_SIze__c newRecordType : lstCSGRecord){
            mapOfRecordType.put(newRecordType.Label__c, newRecordType.Value__c);
        }
        return mapOfRecordType;
    }
    
    @AuraEnabled
    public static Map<String, String> getQuantityTypeForCase(String recordTypeName){
        Map<String, String> mapOfRecordType = New Map<String, String>();
        List<User> lstUserDetail = SLT_User.getUserDetail(userinfo.getUserId());
        List<Profile> lstProfile = SLT_Profile.getProfileDetail(lstUserDetail[0].ProfileId); 
        String profileName = '%'+ lstProfile[0].Name +'%';
        String accessGroup = '%'+ lstUserDetail[0].Access_Group__c +'%';
        String language = '%'+ lstUserDetail[0].LanguageLocaleKey +'%';
        recordTypeName = '%'+recordTypeName+'%';
        List<CSG_Quantity_Type__c> lstCSGRecord = SLT_CustomSetting.getQunatityType(accessGroup, profileName, language, recordTypeName);
        for(CSG_Quantity_Type__c newRecordType : lstCSGRecord){
            mapOfRecordType.put(newRecordType.Label__c, newRecordType.Value__c);
        }
        return mapOfRecordType;
    }
    
    @AuraEnabled
    public static Map<String, String> getCategoryForCase(String recordTypeName, STring typeSelection){
        Map<String, String> mapOfRecordType = New Map<String, String>();
        List<User> lstUserDetail = SLT_User.getUserDetail(userinfo.getUserId());
        List<Profile> lstProfile = SLT_Profile.getProfileDetail(lstUserDetail[0].ProfileId); 
        String profileName = '%'+ lstProfile[0].Name +'%';
        String accessGroup = '%'+ lstUserDetail[0].Access_Group__c +'%';
        String language = '%'+ lstUserDetail[0].LanguageLocaleKey +'%';
        recordTypeName = '%'+recordTypeName+'%';
        List<CSG_Category__c> lstCSGRecord = SLT_CustomSetting.getCategory(accessGroup, profileName, language, recordTypeName, typeSelection);
        for(CSG_Category__c newRecordType : lstCSGRecord){
            mapOfRecordType.put(newRecordType.Label__c, newRecordType.Value__c);
        }
        return mapOfRecordType;
    }
    
    @AuraEnabled
    public static Map<String, String> getSubCategoryForCase(String recordTypeName, String category){
        Map<String, String> mapOfRecordType = New Map<String, String>();
        List<User> lstUserDetail = SLT_User.getUserDetail(userinfo.getUserId());
        List<Profile> lstProfile = SLT_Profile.getProfileDetail(lstUserDetail[0].ProfileId); 
        String profileName = '%'+ lstProfile[0].Name +'%';
        String accessGroup = '%'+ lstUserDetail[0].Access_Group__c +'%';
        String language = '%'+ lstUserDetail[0].LanguageLocaleKey +'%';
        recordTypeName = '%'+recordTypeName+'%';
        List<CSG_Sub_Category__c > lstCSGRecord = SLT_CustomSetting.getSubCategory(accessGroup, profileName, language, recordTypeName, category);
        for(CSG_Sub_Category__c  newRecordType : lstCSGRecord){
            mapOfRecordType.put(newRecordType.Label__c, newRecordType.Value__c);
        }
        return mapOfRecordType;
    }
    
    @AuraEnabled
    public static case getCaseRecordValue(String caseId){
        List<Case> lstCase = SLT_Case.getCaseByIDs(new List<ID>{caseId});
        return lstCase[0];
    }
}