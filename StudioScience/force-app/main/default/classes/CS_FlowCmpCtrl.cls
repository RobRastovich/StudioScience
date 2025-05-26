public without sharing class CS_FlowCmpCtrl {
	@testVisible
	public static Boolean forceException = false;
	public static Account userAccount;
	public static User currentUser;
	public static String DEFAULT_CS_COUNTRY = 'US';
	public static String DEFAULT_LANGUAGE = 'en_US';
	public static Map<String, String> valueToLabelTranslationMap = new Map<String, String>();
	public static Map<String, String> labelToValueTranslationMap = new Map<String, String>();
	public static Map<Id, String> picklistIdToValue = new Map<Id, String>();
	public static Map<Id, List<PicklistWrapper>> picklistIdToIdsMap = new Map<Id, List<PicklistWrapper>>();
	public static Map<String, Map<String, String>> picklistFieldValueToLabelMap = new Map<String, Map<String, String>>();
	public static Map<String, Map<String, String>> picklistFieldLabelToValueMap = new Map<String, Map<String, String>>();

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

	// is the user access group allowed to view this picklist
	public static Boolean accessGroupAllowed(String userAccessGroup, String accessGroupsAllowed) {
		Boolean isAllowed = false;

		if (String.isNotBlank(accessGroupsAllowed)) {
			List<String> accessGroups = accessGroupsAllowed.trim().toUpperCase().split(',');

			if (accessGroups.indexOf(userAccessGroup.toUpperCase()) > -1) {
				isAllowed = true;
			}
		}
		return isAllowed;
	}

	// filter out team category values that should not be visible to the user
	@AuraEnabled
	public static List<CS_Flow_Type_Category_Setting__mdt> parseTeamCategoryCustomMetaData() {
		List<CS_Flow_Type_Category_Setting__mdt> typeOptions = new List<CS_Flow_Type_Category_Setting__mdt>();

		for (CS_Flow_Type_Category_Setting__mdt typeOption : getTypeCategoryCustomMetaData()) {
			Boolean accessGroupAllowed = accessGroupAllowed(currentUser.Access_Group__c, typeOption.Access_Groups__c);

			if (accessGroupAllowed) {
				typeOptions.add(typeOption);
			}
		}
		return typeOptions;
	}

	// filter out primary category values that should not be visible to the user
	@AuraEnabled
	public static List<CS_Flow_Primary_Category_Setting__mdt> parsePrimaryCategoryCustomMetaData() {
		List<CS_Flow_Primary_Category_Setting__mdt> primaryOptions = new List<CS_Flow_Primary_Category_Setting__mdt>();

		for (CS_Flow_Primary_Category_Setting__mdt primaryOption : getPrimaryCategoryCustomMetaData()) {
			Boolean accessGroupAllowed = accessGroupAllowed(currentUser.Access_Group__c, primaryOption.Access_Groups__c);

			if (accessGroupAllowed) {
				primaryOptions.add(primaryOption);
			}
		}

		return primaryOptions;
	}
    
    // 2/02/2022 - The below code is commented for SAL-1815 by tanvisha.
    // filter out secondary category values that should not be visible to the user
 /*   
    @AuraEnabled
    public static List<CS_Flow_Secondary_Category_Setting__mdt> parseSecondaryCategoryCustomMetaData() {
        List<CS_Flow_Secondary_Category_Setting__mdt> secondaryOptions = new List<CS_Flow_Secondary_Category_Setting__mdt>();
        
        for (CS_Flow_Secondary_Category_Setting__mdt secondaryOption : getSecondaryCategoryCustomMetaData()) {
            Boolean accessGroupAllowed = accessGroupAllowed(currentUser.Access_Group__c, secondaryOption.Access_Groups__c);
            
            if (accessGroupAllowed) {
                secondaryOptions.add(secondaryOption);
            }
            
        }
        return secondaryOptions;
    }
*/
    
    // 2/02/2022 - The below code is commented for SAL-1815 by tanvisha.
    // filter out tertiary category values that should not be visible to the user
/*
@AuraEnabled
public static List<CS_Flow_Tertiary_Category_Setting__mdt> parseTertiaryCategoryCustomMetaData() {
List<CS_Flow_Tertiary_Category_Setting__mdt> tertiaryOptions = new List<CS_Flow_Tertiary_Category_Setting__mdt>();

for (CS_Flow_Tertiary_Category_Setting__mdt tertiaryOption : getTertiaryCategoryCustomMetaData()) {
Boolean accessGroupAllowed = accessGroupAllowed(currentUser.Access_Group__c, tertiaryOption.Access_Groups__c);

if (accessGroupAllowed ) {
tertiaryOptions.add(tertiaryOption);
}
}
return tertiaryOptions;
}
*/

    /**************************************************************************************************************
    Author:       Tanvisha Varshney
    Company:       Metacube
    Description:	This method will filter out issue type category values that should not be visible to the user (for SAL-1815)
    Date:          02/02/2021
    
    
    ***************************************************************************************************************/

    
    @AuraEnabled
    public static List<CS_Flow_Issue_Type_Category_Setting__mdt> parseIssueTypeCategoryCustomMetaData() {
        List<CS_Flow_Issue_Type_Category_Setting__mdt> tertiaryOptions = new List<CS_Flow_Issue_Type_Category_Setting__mdt>();
        
        for (CS_Flow_Issue_Type_Category_Setting__mdt tertiaryOption : getIssueTypeCategoryCustomMetaData()) {
            Boolean accessGroupAllowed = accessGroupAllowed(currentUser.Access_Group__c, tertiaryOption.Access_Groups__c);
            
            if (accessGroupAllowed ) {
                tertiaryOptions.add(tertiaryOption);
            }
        }
        return tertiaryOptions;
    }
    
// create map of team => primary category dependencies
	public static Set<Id> mapTeamToPrimary() {
		Set<Id> typeSettingIds = new Set<Id>();

		for (CS_Flow_Type_Category_Setting__mdt typeSetting : parseTeamCategoryCustomMetaData()) {
			picklistIdToValue.put(typeSetting.Id, typeSetting.CS_Flow_Picklist_Setting__r.Value__c);
			typeSettingIds.add(typeSetting.Id);
			picklistIdToIdsMap.put(typeSetting.Id, new List<PicklistWrapper>());

			for (CS_Flow_Primary_Category_Setting__mdt primarySetting : typeSetting.CS_Flow_Primary_Category_Settings__r) {
				Boolean accessGroupAllowed = accessGroupAllowed(currentUser.Access_Group__c, primarySetting.Access_Groups__c);
				//Boolean isUserVIP = isUserAndPicklistVIP(currentUser.GBS_VIP_User__c, primarySetting.Visible_to_VIP_User__c);
				//Boolean showPicklistValueBasedOnCountry = isPicklistAvaiableForGBSCenter(primarySetting.GBS_Centers__c);

				if (accessGroupAllowed) {
					picklistIdToIdsMap.get(typeSetting.Id).add(new PicklistWrapper(primarySetting.Id, Integer.valueOf(primarySetting.Order__c), primarySetting.CS_Flow_Picklist_Setting__r.Value__c  ));
				}
			}
		}
		return typeSettingIds;
	}
    // 2/02/2022 - The below code is commented for SAL-1815 by tanvisha.
	// create map of primary => secondary category dependencies
	/*
    @AuraEnabled
	public static void mapPrimaryToSecondary() {
		for (CS_Flow_Primary_Category_Setting__mdt primarySetting : parsePrimaryCategoryCustomMetaData()) {
			picklistIdToValue.put(primarySetting.Id, primarySetting.CS_Flow_Picklist_Setting__r.Value__c);
			picklistIdToIdsMap.put(primarySetting.Id, new List<PicklistWrapper>());

			for (CS_Flow_Secondary_Category_Setting__mdt secondarySetting : primarySetting.CS_Flow_Secondary_Category_Settings__r) {
				Boolean accessGroupAllowed = accessGroupAllowed(currentUser.Access_Group__c, secondarySetting.Access_Groups__c);
				//Boolean isUserVIP = isUserAndPicklistVIP(currentUser.GBS_VIP_User__c, secondarySetting.Visible_to_VIP_User__c);
				//Boolean showPicklistValueBasedOnCountry = isPicklistAvaiableForGBSCenter(secondarySetting.GBS_Centers__c);

				if (accessGroupAllowed) {
					picklistIdToIdsMap.get(primarySetting.Id).add(new PicklistWrapper(secondarySetting.Id, Integer.valueOf(secondarySetting.Order__c), secondarySetting.CS_Flow_Picklist_Setting__r.Value__c));
				}
			}
		}
	}

    // The below code is commented for SAL-1815 by tanvisha.
	// create map of secondary => tertiary category dependencies
	@AuraEnabled
	public static void mapSecondaryToTertiary() {
		for (CS_Flow_Secondary_Category_Setting__mdt secondarySetting : parseSecondaryCategoryCustomMetaData()) {
			picklistIdToValue.put(secondarySetting.Id, secondarySetting.CS_Flow_Picklist_Setting__r.Value__c);
			picklistIdToIdsMap.put(secondarySetting.Id, new List<PicklistWrapper>());

			for (CS_Flow_Tertiary_Category_Setting__mdt tertiarySetting : secondarySetting.CS_Flow_Tertiary_Category_Settings__r) {
				Boolean accessGroupAllowed = accessGroupAllowed(currentUser.Access_Group__c, tertiarySetting.Access_Groups__c);
				//Boolean isUserVIP = isUserAndPicklistVIP(currentUser.GBS_VIP_User__c, tertiarySetting.Visible_to_VIP_User__c);
				//Boolean showPicklistValueBasedOnCountry = isPicklistAvaiableForGBSCenter(tertiarySetting.GBS_Centers__c);

				if (accessGroupAllowed) {
					picklistIdToIdsMap.get(secondarySetting.Id).add(new PicklistWrapper(tertiarySetting.Id, Integer.valueOf(tertiarySetting.Order__c), tertiarySetting.CS_Flow_Picklist_Setting__r.Value__c));
				}
			}
		}
	}
 */
       
   /**************************************************************************************************************
    Author:       Tanvisha Varshney
    Company:       Metacube
    Description:   create map of primary  => issue type category dependencies (for SAL-1815)
    Date:          02/02/2021
    
    
    ***************************************************************************************************************/
    
    // create map of primary => issue type category dependencies
    @AuraEnabled
    public static void mapPrimaryToIssueType() {
        for (CS_Flow_Primary_Category_Setting__mdt primarySetting : parsePrimaryCategoryCustomMetaData()) {
            picklistIdToValue.put(primarySetting.Id, primarySetting.CS_Flow_Picklist_Setting__r.Value__c);
            picklistIdToIdsMap.put(primarySetting.Id, new List<PicklistWrapper>());
            
            for (CS_Flow_Issue_Type_Category_Setting__mdt secondarySetting : primarySetting.CS_Flow_Issue_Type_Category_Setting__r) {
                Boolean accessGroupAllowed = accessGroupAllowed(currentUser.Access_Group__c, secondarySetting.Access_Groups__c);
                //Boolean isUserVIP = isUserAndPicklistVIP(currentUser.GBS_VIP_User__c, secondarySetting.Visible_to_VIP_User__c);
                //Boolean showPicklistValueBasedOnCountry = isPicklistAvaiableForGBSCenter(secondarySetting.GBS_Centers__c);
                
                if (accessGroupAllowed) {
                    picklistIdToIdsMap.get(primarySetting.Id).add(new PicklistWrapper(secondarySetting.Id, Integer.valueOf(secondarySetting.Order__c), secondarySetting.CS_Flow_Picklist_Setting__r.Value__c));
                }
            }
            
        }
        
    }
      /**************************************************************************************************************
    Author:       Tanvisha Varshney
    Company:       Metacube
    Description:   create map of issue type => issue type category dependencies (for SAL-1815)
    Date:          02/02/2021
    
    
    ***************************************************************************************************************/
    
    //create map of issue type => issue type category dependencies
    @AuraEnabled
    public static void mapIssueTypeToQuaternary() {
        for (CS_Flow_Issue_Type_Category_Setting__mdt tertiarySetting : parseIssueTypeCategoryCustomMetaData()) {
            picklistIdToValue.put(tertiarySetting.Id, tertiarySetting.CS_Flow_Picklist_Setting__r.Value__c);
        }
    }
 
    
    //  The below code is commented for SAL-1815 by tanvisha.
	// create map of secondary => tertiary category dependencies
	/*
    @AuraEnabled
	public static void mapTertiaryToQuaternary() {
		for (CS_Flow_Tertiary_Category_Setting__mdt tertiarySetting : parseTertiaryCategoryCustomMetaData()) {
			picklistIdToValue.put(tertiarySetting.Id, tertiarySetting.CS_Flow_Picklist_Setting__r.Value__c);
		}
	}

*/
	// build the picklist options required for the GBS Flow
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus buildPicklistOptions() {
		Boolean success = true;
		String message = '';
		Map<String, Object> responseMap = new Map<String, Object>();
		// used to identify correct field value once it has been translated in the lightning component
		Map<String, String> labelToTranslationMap = new Map<String, String>();
		LightningComponentUtility.RequestStatus requestStatus;


		try {
			if (Test.isRunningTest() && forceException) {
				DmlException e = new DmlException();
				e.setMessage('Error thrown for test class');
				throw e;
			}

			currentUser = getCurrentUserInfo();

			getCasePicklistValues('Type', 'type');
            getCasePicklistValues('Complaint_Source__c', 'primary');
            //The below code is commented for SAL-1815 by tanvisha.
            //getCasePicklistValues('Type', 'secondary');
			//getCasePicklistValues('Issue__c', 'tertiary');
			
            // by tanvisha for SAL-1815
            getCasePicklistValues('Issue__c','issuetype');
            
            //  The below code is commented for SAL-1815 by tanvisha.
            //	mapPrimaryToSecondary();
            //	mapSecondaryToTertiary();
            //	mapTertiaryToQuaternary();
            
            // by tanvisha for SAL-1815
            mapIssueTypeToQuaternary();
            mapPrimaryToIssueType();
			

			responseMap.put('typeCategoryIds', mapTeamToPrimary());
			responseMap.put('labelToValueTranslationMap', picklistFieldLabelToValueMap);
			responseMap.put('valueToLabelTranslationMap', picklistFieldValueToLabelMap);
			responseMap.put('picklistIdToValue', picklistIdToValue);
			responseMap.put('picklistIdToIdsMap', picklistIdToIdsMap);

		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message += 'Error Message: ' + e.getMessage();
			message += ',\r';
			message += 'StackTrace: ' + e.getStackTraceString();
			success = false;

			Custom_Exception_Logs__c error = CreateExceptionLog.createExceptionLog('CS_FlowCmpCtrl', 'buildPicklistOptions', String.valueOf(message), 'Fatal', true);
			String endUserMessage = 'An Error Occurred, Please Contact Customer Service. Reference Id: ' + error.Id;

			requestStatus = new LightningComponentUtility.RequestStatus(success, endUserMessage, responseMap);
			return requestStatus;
		}

		requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
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

		public PicklistWrapper(Id recordId, Integer order, String value) {
			this.recordId = recordId;
			this.order = order;
			this.value = value;
		}
	}

	public static List<CS_Flow_Type_Category_Setting__mdt> getTypeCategoryCustomMetaData() {
		return  [select Id
		         , MasterLabel
		         , Access_Groups__c
		         , Order__c
		         , CS_Flow_Picklist_Setting__r.Custom_Label__c
		         , CS_Flow_Picklist_Setting__r.Value__c
		         , (Select CS_Flow_Picklist_Setting__r.Value__c, Order__c, Access_Groups__c from CS_Flow_Primary_Category_Settings__r) from CS_Flow_Type_Category_Setting__mdt];
	}

	public static List<CS_Flow_Primary_Category_Setting__mdt> getPrimaryCategoryCustomMetaData() {
		return [select Id
		        , MasterLabel
		        , Access_Groups__c
		        , Order__c
		        , CS_Flow_Type_Category_Setting__c
		        , CS_Flow_Picklist_Setting__r.Custom_Label__c
		        , CS_Flow_Picklist_Setting__r.Value__c
                //, (Select CS_Flow_Picklist_Setting__r.Value__c, Order__c, Access_Groups__c from CS_Flow_Secondary_Category_Settings__r) from CS_Flow_Primary_Category_Setting__mdt
               // by tanvisha for SAL-1815
                ,(Select CS_Flow_Picklist_Setting__r.Value__c, Order__c, Access_Groups__c from CS_Flow_Issue_Type_Category_Setting__r) from CS_Flow_Primary_Category_Setting__mdt];
        
	}

	public static List<CS_Flow_Secondary_Category_Setting__mdt> getSecondaryCategoryCustomMetaData() {
		return [select Id
		        , MasterLabel
		        , Access_Groups__c
		        , Order__c
		        , CS_Flow_Primary_Category_Setting__c
		        , CS_Flow_Picklist_Setting__r.Custom_Label__c
		        , CS_Flow_Picklist_Setting__r.Value__c
		        , (Select CS_Flow_Picklist_Setting__r.Value__c, Order__c, Access_Groups__c from CS_Flow_Tertiary_Category_Settings__r) from CS_Flow_Secondary_Category_Setting__mdt];
	}

	public static List<CS_Flow_Tertiary_Category_Setting__mdt> getTertiaryCategoryCustomMetaData() {
		return [select Id
		        , MasterLabel
		        , Access_Groups__c
		        , Order__c
		        , CS_Flow_Secondary_Category_Setting__c
		        , CS_Flow_Picklist_Setting__r.Custom_Label__c
		        , CS_Flow_Picklist_Setting__r.Value__c from CS_Flow_Tertiary_Category_Setting__mdt ];
	}

            /**************************************************************************************************************
   
    Author:       Tanvisha Varshney
    Company:       Metacube
    Description:   getIssueTypeCategoryCustomMetaData (For SAL-1815)
    Date:          02/02/2021
    
    
    ***************************************************************************************************************/
    
    public static List<CS_Flow_Issue_Type_Category_Setting__mdt> getIssueTypeCategoryCustomMetaData() {
        List<CS_Flow_Issue_Type_Category_Setting__mdt> test5 = [select Id
                                                                , MasterLabel
                                                                , Access_Groups__c
                                                                , Order__c
                                                                , CS_Flow_Primary_Category_Setting__c
                                                                , CS_Flow_Picklist_Setting__r.Custom_Label__c
                                                                , CS_Flow_Picklist_Setting__r.Value__c from CS_Flow_Issue_Type_Category_Setting__mdt ];
        system.debug('getIssueTypeCategoryCustomMetaData');
        system.debug(test5);
        return test5;
    }
    
}