public without sharing class GBS_FlowCmpCtrl {
    public static Account userAccount;
    public static User currentUser;
    public static String gbsCenter;
    public static String DEFAULT_GBS_COUNTRY = 'US';
    public static String DEFAULT_GBS_CENTER = 'US/Canada';
    public static String DEFAULT_LANGUAGE = 'en_US';
    public static List<String> userGBSCenters = new List<String>();
    public static Map<String, String> valueToLabelTranslationMap = new Map<String, String>();
    public static Map<String, String> labelToValueTranslationMap = new Map<String, String>();
    public static Map<Id, String> picklistIdToValue = new Map<Id, String>();
    public static Map<Id, List<PicklistWrapper>> picklistIdToIdsMap = new Map<Id, List<PicklistWrapper>>();
    public static Map<String, Map<String, String>> picklistFieldValueToLabelMap = new Map<String, Map<String, String>>();
    public static Map<String, Map<String, String>> picklistFieldLabelToValueMap = new Map<String, Map<String, String>>();
    
    public static Map<String, String> countryToGbsCenter = new Map<String, String> {
        'MX' 			=> 'Mexico',
            'Mexico' 		=> 'Mexico',
            'US' 			=> DEFAULT_GBS_CENTER,
            'United States' => DEFAULT_GBS_CENTER,
            'Madrid'		=> 'Madrid',
            'ES'			=> 'Madrid',
            'Spain'			=> 'Madrid',
            'IN'			=> 'India',
            'India'			=> 'India',
            'SG'			=> 'Singapore',
            'Singapore'		=> 'Singapore',
            'SBFE'			=> 'SBFE'
            };
                
                public static Map<String, String> countryFullNameToAbbreviation = new Map<String, String> {
                    'UNITED STATES' => 'US',
                        'MEXICO'        => 'MX',
                        'MADRID'		=> 'ES',
                        'SPAIN'			=> 'ES',
                        'INDIA'			=> 'IN',
                        'SINGAPORE'		=> 'SG',
                        'SBFE'			=> 'SBFE'
                        };
                            
                            public static Map<String, String> languageToGBSCenters = new Map<String, String> {
                                'en_US' => 'US/Canada',
                                    'es_MX' => 'Mexico'
                                    };
                                        
                                        
                                        ////8/19/
                                        public static Set<String> acceptedAbbreviations = new Set<String> {'US', 'MX', 'SG', 'IN', 'ES', 'SBFE'};
                                            
                                            @AuraEnabled
                                            public static User getCurrentUserInfo() {
                                                Id recordId = UserInfo.getUserId();
                                                
                                                DescribeSObjectResult describeResult = recordId.getSObjectType().getDescribe();
                                                List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet());
                                                String query = ' SELECT ' + String.join(fieldNames, ',') + ' FROM ' + describeResult.getName() +
                                                    ' WHERE ' +
                                                    ' Id = :recordId' + ' LIMIT 1';
                                                
                                                return Database.query(query);
                                            }
    
    @AuraEnabled
    public static Account getUserAccount(User u) {
        if (u.ContactId != null) {
            return [select Id, BillingCountry from Account where Id = :u.AccountId];
        } else {
            return null;
        }
    }
    
    // is the user access group allowed to view this picklist
    public static Boolean accessGroupAllowed(String userAccessGroup, String accessGroupsAllowed) {
        Boolean isAllowed = false;
        List<String> accessGroups = new List<String>();
        
        if (String.isNotBlank(accessGroupsAllowed)) {
            
            for (String s : accessGroupsAllowed.trim().toUpperCase().split(',')) {
                accessGroups.add(s.trim());
            }
            
            if (accessGroups.indexOf(userAccessGroup.toUpperCase()) > -1) {
                isAllowed = true;
            }
        }
        return isAllowed;
    }
    
    // is the user a vip and is the picklist value visible to vip users
    public static Boolean isUserAndPicklistVIP(String userVIP, Boolean fieldVIPStatus) {
        Boolean isVIP = false;
        
        if (String.isNotBlank(userVIP)) {
            if (userVIP.containsIgnoreCase('VIP')) {
                isVIP = true;
            }
        }
        return isVIP;
    }
    
    // is this picklist value available for this gbs center
    public static Boolean isPicklistAvaiableForGBSCenter(String acceptedGBSCenters) {
        Boolean isAvailable = false;
        
        List<String> gbsCenters = acceptedGBSCenters.remove('\"').toUpperCase().trim().split(',');
        
        for (String userGBSCenter : userGBSCenters) {
            if (gbsCenters.indexOf(userGBSCenter.toUpperCase().trim()) > -1) {
                isAvailable = true;
                break;
            }
        }
        
        return isAvailable;
    }
    
    // set the country based on the account related to the contact if there is one
    public static void setUserGBSCenters() {
        if (String.isNotBlank(currentUser.GBS_Centers__c)) {
            userGBSCenters.addAll(currentUser.GBS_Centers__c.split(';'));
        } else {
            if (userAccount != null) {
                
                if (String.isNotBlank(userAccount.BillingCountry)) {
                    userGBSCenters.add(getCountryAbbreviation(userAccount.BillingCountry.toUpperCase()));
                } else {
                    userGBSCenters.add(DEFAULT_GBS_COUNTRY);
                    CreateExceptionLog.insertErrorLog('GBSFlowCmpCtrl', 'setUserGBSCenters', 'User: ' + currentUser.Id + ' ' + 'is missing a valid Billing Country for the GBS Flow', 'Warning');
                }
            } else if (String.isBlank(currentUser.GBS_Centers__c)) {
                userGBSCenters.add(DEFAULT_GBS_COUNTRY);
            }
        }
    }
    
    // set the gbs center that will also be set on the case record
    public static void setGBSCenterBasedOnLanguage() {
        // if the user has an account Id then it is a vendor
        if (String.isNotBlank(currentUser.GBS_Centers__c)) {
            gbsCenter = userGBSCenters[0];
        } else {
            if (userAccount != null) {
                if (String.isNotBlank(userAccount.BillingCountry)) {
                    gbsCenter = getCountryAbbreviation(userAccount.BillingCountry.toUpperCase());
                } else {
                    gbsCenter = DEFAULT_GBS_CENTER;
                    CreateExceptionLog.insertErrorLog('GBSFlowCmpCtrl', 'setGBSCenterBasedOnLanguage', 'User: ' + currentUser.Id + ' ' + 'is missing a valid Billing Country for the GBS Flow', 'Warning');
                }
            } else if (String.isBlank(currentUser.GBS_Centers__c)) {
                gbsCenter = DEFAULT_GBS_CENTER;
                CreateExceptionLog.insertErrorLog('GBSFlowCmpCtrl', 'setGBSCenterBasedOnLanguage', 'User: ' + currentUser.Id + ' ' + 'is missing an assigned GBS Center for the GBS Flow', 'Warning');
            }
        }
    }
    
    
    // determine if the country is valid, else return default country US and log an error
    public static String getCountryAbbreviation(String country) {
        if (!acceptedAbbreviations.contains(country)) {
            if (countryFullNameToAbbreviation.containsKey(country)) {
                return countryFullNameToAbbreviation.get(country);
            } else {
                CreateExceptionLog.insertErrorLog('GBSFlowCmpCtrl', 'getCountryAbbreviation', 'User: ' + currentUser.Id + ' ' + 'is missing a valid Billing Country for the GBS Flow', 'Warning');
                return DEFAULT_GBS_COUNTRY;
            }
        } else {
            return country;
        }
    }
    
    // filter out team category values that should not be visible to the user
    @AuraEnabled
    public static List<GBS_Flow_Team_Category_Setting__mdt> parseTeamCategoryCustomMetaData() {
        List<GBS_Flow_Team_Category_Setting__mdt> teamOptions = new List<GBS_Flow_Team_Category_Setting__mdt>();
        
        for (GBS_Flow_Team_Category_Setting__mdt teamOption : getTeamCategoryCustomMetaData()) {
            Boolean accessGroupAllowed = accessGroupAllowed(currentUser.Access_Group__c, teamOption.Access_Groups__c);
            Boolean isUserVIP = isUserAndPicklistVIP(currentUser.GBS_VIP_User__c, teamOption.Visible_to_VIP_User__c);
            Boolean showPicklistValueBasedOnCountry = isPicklistAvaiableForGBSCenter(teamOption.GBS_Centers__c);
            
            if ((accessGroupAllowed || isUserVIP) && showPicklistValueBasedOnCountry) {
                teamOptions.add(teamOption);
            }
        }
        return teamOptions;
    }
    
    // filter out primary category values that should not be visible to the user
    @AuraEnabled
    public static List<GBS_Flow_Primary_Category_Setting__mdt> parsePrimaryCategoryCustomMetaData() {
        List<GBS_Flow_Primary_Category_Setting__mdt> primaryOptions = new List<GBS_Flow_Primary_Category_Setting__mdt>();
        
        for (GBS_Flow_Primary_Category_Setting__mdt primaryOption : getPrimaryCategoryCustomMetaData()) {
            Boolean accessGroupAllowed = accessGroupAllowed(currentUser.Access_Group__c, primaryOption.Access_Groups__c);
            Boolean isUserVIP = isUserAndPicklistVIP(currentUser.GBS_VIP_User__c, primaryOption.Visible_to_VIP_User__c);
            Boolean showPicklistValueBasedOnCountry = isPicklistAvaiableForGBSCenter(primaryOption.GBS_Centers__c);
            Boolean isRestricted = false;
            
            //Exclude Payroll category "Vendor" not be available for EXTERNAL users in Mexico
            //added for SCTASK0029906
            try{
                if(primaryOption.MasterLabel.equalsIgnoreCase('Vendor requests') && currentUser.Access_Group__c.toUpperCase().contains('EXTERNAL') && userGBSCenters.contains('MX'))
                    isRestricted = true;
            }
            catch(Exception e){
                String errorMessage = 'Error in GBS_Flow_Primary_Category_Setting__mdt' + e.getMessage() + '\n' + e.getStackTraceString();
                CreateExceptionLog.insertErrorLog('GBS_FlowCmpCtrl', 'parsePrimaryCategoryCustomMetaData', String.valueOf(errorMessage), 'Fatal');
                System.debug('exception e..'+e);
            }
            if ((accessGroupAllowed || isUserVIP) && showPicklistValueBasedOnCountry) {
                if(!isRestricted){
                    primaryOptions.add(primaryOption);
                }
            }
        }
                
        return primaryOptions;
    }
    
    // filter out secondary category values that should not be visible to the user
    @AuraEnabled
    public static List<GBS_Flow_Secondary_Category_Setting__mdt> parseSecondaryCategoryCustomMetaData() {
        List<GBS_Flow_Secondary_Category_Setting__mdt> secondaryOptions = new List<GBS_Flow_Secondary_Category_Setting__mdt>();
        
        for (GBS_Flow_Secondary_Category_Setting__mdt secondaryOption : getSecondaryCategoryCustomMetaData()) {
            Boolean accessGroupAllowed = accessGroupAllowed(currentUser.Access_Group__c, secondaryOption.Access_Groups__c);
            Boolean isUserVIP = isUserAndPicklistVIP(currentUser.GBS_VIP_User__c, secondaryOption.Visible_to_VIP_User__c);
            Boolean showPicklistValueBasedOnCountry = isPicklistAvaiableForGBSCenter(secondaryOption.GBS_Centers__c);
            
            if ((accessGroupAllowed || isUserVIP) && showPicklistValueBasedOnCountry) {
                secondaryOptions.add(secondaryOption);
            }
            
        }
        return secondaryOptions;
    }
    
    // filter out tertiary category values that should not be visible to the user
    @AuraEnabled
    public static List<GBS_Flow_Tertiary_Category_Setting__mdt> parseTertiaryCategoryCustomMetaData() {
        List<GBS_Flow_Tertiary_Category_Setting__mdt> tertiaryOptions = new List<GBS_Flow_Tertiary_Category_Setting__mdt>();
        
        for (GBS_Flow_Tertiary_Category_Setting__mdt tertiaryOption : getTertiaryCategoryCustomMetaData()) {
            Boolean accessGroupAllowed = accessGroupAllowed(currentUser.Access_Group__c, tertiaryOption.Access_Groups__c);
            Boolean isUserVIP = isUserAndPicklistVIP(currentUser.GBS_VIP_User__c, tertiaryOption.Visible_to_VIP_User__c);
            Boolean showPicklistValueBasedOnCountry = isPicklistAvaiableForGBSCenter(tertiaryOption.GBS_Centers__c);
            
            if ((accessGroupAllowed || isUserVIP) && showPicklistValueBasedOnCountry) {
                tertiaryOptions.add(tertiaryOption);
            }
        }
        return tertiaryOptions;
    }
    
    // create map of team => primary category dependencies
    public static Set<Id> mapTeamToPrimary() {
        Set<Id> teamSettingIds = new Set<Id>();
        
        for (GBS_Flow_Team_Category_Setting__mdt teamSetting : parseTeamCategoryCustomMetaData()) {
            picklistIdToValue.put(teamSetting.Id, teamSetting.GBS_Flow_Picklist_Setting__r.Value__c);
            teamSettingIds.add(teamSetting.Id);
            picklistIdToIdsMap.put(teamSetting.Id, new List<PicklistWrapper>());
            
            for (GBS_Flow_Primary_Category_Setting__mdt primarySetting : teamSetting.GBS_Flow_Primary_Category_Settings__r) {
                Boolean accessGroupAllowed = accessGroupAllowed(currentUser.Access_Group__c, primarySetting.Access_Groups__c);
                Boolean isUserVIP = isUserAndPicklistVIP(currentUser.GBS_VIP_User__c, primarySetting.Visible_to_VIP_User__c);
                Boolean showPicklistValueBasedOnCountry = isPicklistAvaiableForGBSCenter(primarySetting.GBS_Centers__c);
                
                if ((accessGroupAllowed || isUserVIP) && showPicklistValueBasedOnCountry) {
                    picklistIdToIdsMap.get(teamSetting.Id).add(new PicklistWrapper(primarySetting.Id, Integer.valueOf(primarySetting.Order__c), primarySetting.GBS_Flow_Picklist_Setting__r.Value__c  ));
                }
            }
        }
        return teamSettingIds;
    }
    
    // create map of primary => secondary category dependencies
    @AuraEnabled
    public static void mapPrimaryToSecondary() {
        for (GBS_Flow_Primary_Category_Setting__mdt primarySetting : parsePrimaryCategoryCustomMetaData()) {
            picklistIdToValue.put(primarySetting.Id, primarySetting.GBS_Flow_Picklist_Setting__r.Value__c);
            picklistIdToIdsMap.put(primarySetting.Id, new List<PicklistWrapper>());
            
            for (GBS_Flow_Secondary_Category_Setting__mdt secondarySetting : primarySetting.GBS_Flow_Secondary_Category_Settings__r) {
                Boolean accessGroupAllowed = accessGroupAllowed(currentUser.Access_Group__c, secondarySetting.Access_Groups__c);
                Boolean isUserVIP = isUserAndPicklistVIP(currentUser.GBS_VIP_User__c, secondarySetting.Visible_to_VIP_User__c);
                Boolean showPicklistValueBasedOnCountry = isPicklistAvaiableForGBSCenter(secondarySetting.GBS_Centers__c);
                
                if ((accessGroupAllowed || isUserVIP) && showPicklistValueBasedOnCountry) {
                    picklistIdToIdsMap.get(primarySetting.Id).add(new PicklistWrapper(secondarySetting.Id, Integer.valueOf(secondarySetting.Order__c), secondarySetting.GBS_Flow_Picklist_Setting__r.Value__c));
                }
            }
        }
    }
    
    // create map of secondary => tertiary category dependencies
    @AuraEnabled
    public static void mapSecondaryToTertiary() {
        for (GBS_Flow_Secondary_Category_Setting__mdt secondarySetting : parseSecondaryCategoryCustomMetaData()) {
            picklistIdToValue.put(secondarySetting.Id, secondarySetting.GBS_Flow_Picklist_Setting__r.Value__c);
            picklistIdToIdsMap.put(secondarySetting.Id, new List<PicklistWrapper>());
            
            for (GBS_Flow_Tertiary_Category_Setting__mdt tertiarySetting : secondarySetting.GBS_Flow_Tertiary_Category_Settings__r) {
                Boolean accessGroupAllowed = accessGroupAllowed(currentUser.Access_Group__c, tertiarySetting.Access_Groups__c);
                Boolean isUserVIP = isUserAndPicklistVIP(currentUser.GBS_VIP_User__c, tertiarySetting.Visible_to_VIP_User__c);
                Boolean showPicklistValueBasedOnCountry = isPicklistAvaiableForGBSCenter(tertiarySetting.GBS_Centers__c);
                
                if ((accessGroupAllowed || isUserVIP) && showPicklistValueBasedOnCountry) {
                    picklistIdToIdsMap.get(secondarySetting.Id).add(new PicklistWrapper(tertiarySetting.Id, Integer.valueOf(tertiarySetting.Order__c), tertiarySetting.GBS_Flow_Picklist_Setting__r.Value__c));
                    
                }
            }
        }
    }
    
    // create map of secondary => tertiary category dependencies
    @AuraEnabled
    public static void mapTertiaryToQuaternary() {
        for (GBS_Flow_Tertiary_Category_Setting__mdt tertiarySetting : parseTertiaryCategoryCustomMetaData()) {
            picklistIdToValue.put(tertiarySetting.Id, tertiarySetting.GBS_Flow_Picklist_Setting__r.Value__c);
        }
    }
    
    @AuraEnabled
    public static String getGBSCenter(String gbsCenter) {
        if (countryToGbsCenter.containsKey(gbsCenter)) {
            return countryToGbsCenter.get(gbsCenter);
        } else {
            return gbsCenter;
        }
    }
    
    
    // build the picklist options required for the GBS Flow
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus buildPicklistOptions() {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        // used to identify correct field value once it has been translated in the lightning component
        Map<String, String> labelToTranslationMap = new Map<String, String>();
        
        
        try {
            currentUser = getCurrentUserInfo();
            userAccount = getUserAccount(currentUser);
            setUserGBSCenters();
            setGBSCenterBasedOnLanguage();
            
            getCasePicklistValues('Type', 'type');
            getCasePicklistValues('Category_1__c', 'primary');
            getCasePicklistValues('Category_2__c', 'secondary');
            getCasePicklistValues('Category_3__c', 'tertiary');
            
            mapPrimaryToSecondary();
            mapSecondaryToTertiary();
            mapTertiaryToQuaternary();
            
            responseMap.put('teamCategoryIds', mapTeamToPrimary());
            responseMap.put('labelToValueTranslationMap', picklistFieldLabelToValueMap);
            responseMap.put('valueToLabelTranslationMap', picklistFieldValueToLabelMap);
            responseMap.put('gbsCenter', getGBSCenter(gbsCenter));
            responseMap.put('picklistIdToValue', picklistIdToValue);
            responseMap.put('picklistIdToIdsMap', picklistIdToIdsMap);
            
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage();
            message = +'\n';
            message = + e.getStackTraceString();
            success = false;
        }
        
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
    
    public static void getCasePicklistValues(String apiName, String label) {
        Map<String, Schema.SObjectField> fieldMap = Case.getSObjectType().getDescribe().fields.getMap();
        List<Schema.PicklistEntry> picklistValues = fieldMap.get(apiName).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry ple : picklistValues) {
            if (!picklistFieldValueToLabelMap.containsKey(label)) {
                picklistFieldValueToLabelMap.put(label, new Map<String, String> {ple.getValue() => ple.getLabel()});
            } else {
                picklistFieldValueToLabelMap.get(label).put(ple.getValue(), ple.getLabel());
            }
            
            if (!picklistFieldLabelToValueMap.containsKey(label)) {
                picklistFieldLabelToValueMap.put(label, new Map<String, String> {ple.getLabel() => ple.getValue()});
            } else {
                picklistFieldLabelToValueMap.get(label).put(ple.getLabel(), ple.getValue());
            }
        }
    }
    
    public class PicklistWrapper {
        @AuraEnabled public Id recordId;
        @AuraEnabled public Integer order;
        @AuraEnabled public String value;
        @AuraEnabled public String label;
        
        public PicklistWrapper(Id recordId, Integer order, String value) {
            this.recordId = recordId;
            this.order = order;
            this.value = value;
        }
        
        public PicklistWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
        
    }
    
    public static List<GBS_Flow_Team_Category_Setting__mdt> getTeamCategoryCustomMetaData() {
        return  [select Id
                 , GBS_Centers__c
                 , MasterLabel
                 , Visible_to_VIP_User__c
                 , Access_Groups__c
                 , Order__c
                 , GBS_Flow_Picklist_Setting__r.Custom_Label__c
                 , GBS_Flow_Picklist_Setting__r.Value__c
                 , (Select GBS_Flow_Picklist_Setting__r.Value__c, Order__c, Access_Groups__c, Visible_to_VIP_User__c, GBS_Centers__c from GBS_Flow_Primary_Category_Settings__r) from GBS_Flow_Team_Category_Setting__mdt];
    }
    
    public static List<GBS_Flow_Primary_Category_Setting__mdt> getPrimaryCategoryCustomMetaData() {
        return [select Id
                , GBS_Centers__c
                , MasterLabel
                , Visible_to_VIP_User__c
                , Access_Groups__c
                , Order__c
                , GBS_Flow_Team_Setting__c
                , GBS_Flow_Picklist_Setting__r.Custom_Label__c
                , GBS_Flow_Picklist_Setting__r.Value__c
                , (Select GBS_Flow_Picklist_Setting__r.Value__c, Order__c, Access_Groups__c, Visible_to_VIP_User__c, GBS_Centers__c from GBS_Flow_Secondary_Category_Settings__r) from GBS_Flow_Primary_Category_Setting__mdt];
    }
    
    public static List<GBS_Flow_Secondary_Category_Setting__mdt> getSecondaryCategoryCustomMetaData() {
        return [select Id
                , GBS_Centers__c
                , MasterLabel
                , Visible_to_VIP_User__c
                , Access_Groups__c
                , Order__c
                , GBS_Flow_Primary_Category_Setting__c
                , GBS_Flow_Picklist_Setting__r.Custom_Label__c
                , GBS_Flow_Picklist_Setting__r.Value__c
                , (Select GBS_Flow_Picklist_Setting__r.Value__c, Order__c, Access_Groups__c, Visible_to_VIP_User__c, GBS_Centers__c from GBS_Flow_Tertiary_Category_Settings__r) from GBS_Flow_Secondary_Category_Setting__mdt];
    }
    
    public static List<GBS_Flow_Tertiary_Category_Setting__mdt> getTertiaryCategoryCustomMetaData() {
        return [select Id
                , GBS_Centers__c
                , MasterLabel
                , Visible_to_VIP_User__c
                , Access_Groups__c
                , Order__c
                , GBS_Flow_Secondary_Category_Setting__c
                , GBS_Flow_Picklist_Setting__r.Custom_Label__c
                , GBS_Flow_Picklist_Setting__r.Value__c from GBS_Flow_Tertiary_Category_Setting__mdt ];
    }
    
    public static List<PicklistWrapper> getPicklistFieldValues(String objectName, String pickListFieldName){
        List<PicklistWrapper> picklistValues = new List<PicklistWrapper>();
        
        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        List<Schema.PicklistEntry> values = objectType.getDescribe().fields.getMap().get(pickListFieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry picklistVal : values) {
            picklistValues.add(new PicklistWrapper(picklistVal.getLabel(),picklistVal.getValue()));
        }
        return picklistValues;
    }
    
    /**************************************************************************************************************
Description:	Returns picklist values
History
<Date>      <Authors Name>     <Brief Description of Change>
3/2019     Craig Austgen       Initial Creation

***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getPicklistOptions() {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        LightningComponentUtility.RequestStatus requestStatus;
        
        try {
            responseMap.put('companyCode', getPicklistFieldValues('Case','Company_Code__c'));
            responseMap.put('employeeLocation', getPicklistFieldValues('Case', 'Employee_Location__c'));
            responseMap.put('countryOfInterest', getPicklistFieldValues('Case', 'Country_of_Interest__c'));
            responseMap.put('region', getPicklistFieldValues('Case','Region__c'));
            responseMap.put('region_claims', getPicklistFieldValues('Case', 'Region_Claims__c'));
            responseMap.put('requestType', getPicklistFieldValues('Case','Request_Type__c'));
            
            
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message += 'Error Message: ' + e.getMessage();
            message += ',\r';
            message += 'StackTrace: ' + e.getStackTraceString();
            success = false;
            Custom_Exception_Logs__c error = CreateExceptionLog.createExceptionLog('GBS_FlowCmpCtrl', 'getPicklistOptions', String.valueOf(message), 'Fatal', true);
            String endUserMessage = 'An Error Occurred, Please Contact Customer Service. Reference Id: ' + error.Id;
            
            requestStatus = new LightningComponentUtility.RequestStatus(success, endUserMessage, responseMap);
            return requestStatus;
        }
        
        requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
    
    
}