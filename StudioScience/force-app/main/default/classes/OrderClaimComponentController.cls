/**************************************************************************************
 Apex Class Name     : OrderClaimComponentController
 Created Date        : 2/2018
 Function            : Methods called from a lightning component OrderClaimComponent
*************************************************************************************/
public without sharing class OrderClaimComponentController {
	public static Id orderClaimRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CSConstants.ORDER_CLAIM_RECORDTYPE_LABEL).getRecordTypeId();
	public static Id orderClaimSubCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CSConstants.ORDER_CLAIM_SUB_CASE_RECORDTYPE_LABEL).getRecordTypeId();

	/**************************************************************************************************************
	Method name:    getRelatedCases
	Object:         Case
	RecordType:     Order Claim
	Date:           2/2018
	Details and Notes:
	Pulls in and child cases related to the passed in parent case id
	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus getRelatedCases(Id caseId) {
		System.debug(LoggingLevel.INFO, 'Label: ' + System.Label.Claim_Amount);
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();

		try {
			Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id
			        , Type
			        , Product_Description__c
			        , Product_Size__c
			        , Quantity_Bottles_or_Cases__c
			        , Quantity_Type__c
			        , Seal_Intact__c
			        , Shipping_Plant__c
			        , Claim_Amount__c
			        , Distibutor_Currency__c
			        , Carrier__c
			        , Freight_Claim_Type__c
			        , Claim_Description__c
			        , Beam_Suntory_Order_Number__c
			        , Purchase_Order_Number__c
			        , Beam_Suntory_Item_Number__c
			        , Order_Claim_Amount__c
			        , OTC_Storage_Location__c
			        , StateCode__c
			        , Product_Destination_Country__c
			        , Overage__c
			        , Additional_Details_Rich_Text__c
                    , Single_Barrel_Case_Number__c
                    , Single_Barrel_Number__c                                  
			        , Ship_Date__c FROM Case WHERE ParentId = : caseId]);
			responseMap.put('caseMap', caseMap);
		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage();
			success = false;
			String error = e.getMessage() + '\n' + e.getStackTraceString();
			CreateExceptionLog.insertErrorLog('OrderClaimComponent', 'getRelatedCases', error, 'Fatal');

		}

		LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}

	/**************************************************************************************************************
	Method name:    getParentCase
	Object:         Case
	RecordType:     Order Claim
	Date:           2/2018
	Details and Notes:
	Returns parent case information
	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus getParentCase(Id caseId) {
		System.debug(LoggingLevel.INFO, 'Label: ' + System.Label.Claim_Amount);
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();

		try {
			Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id
			        , Type
			        , Product_Description__c
			        , Product_Size__c
			        , Quantity_Bottles_or_Cases__c
			        , Quantity_Type__c
			        , Seal_Intact__c
			        , Shipping_Plant__c
			        , Claim_Amount__c
			        , Carrier__c
			        , State__c
			        , Distibutor_Currency__c
			        , Freight_Claim_Type__c
			        , Claim_Description__c
			        , Beam_Suntory_Order_Number__c
			        , Purchase_Order_Number__c
			        , Beam_Suntory_Item_Number__c
			        , Product_Destination_Country__c FROM Case WHERE Id = : caseId]);
			responseMap.put('parentCase', caseMap);
		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage();
			success = false;

			String error = e.getMessage() + '\n' + e.getStackTraceString();
			CreateExceptionLog.insertErrorLog('OrderClaimComponent', 'getParentCase', error, 'Fatal');

		}

		LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}

	/**************************************************************************************************************
	Method name:    upsertClaimSubCase
	Object:         Case
	RecordType:     Order Claim
	Date:           2/2018
	Details and Notes:
	Upserts child cases
	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus upsertClaimSubCase(Case caseRec, String acctId) {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();

		Case parentCase = [select id, AccountId from Case where Id = :caseRec.ParentId];

		try {
			caseRec.RecordtypeId = orderClaimSubCaseRecordTypeId;
			caseRec.Origin = 'Customer Portal';
			if (String.isNotBlank(acctId)) {
				caseRec.AccountId = Id.valueOf(acctId);
			} else {
				caseRec.AccountId = parentCase.AccountId;
			}
			Database.DMLOptions dmo = new Database.DMLOptions();
			dmo.AssignmentRuleHeader.useDefaultRule = true;
			caseRec.setOptions(dmo);
			upsert caseRec;

			responseMap.put('caseId', caseRec.Id);
		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage() + '\n' + e.getStackTraceString());
			message = e.getMessage();
			success = false;

			String error = e.getMessage() + '\n' + e.getStackTraceString();
			CreateExceptionLog.insertErrorLog('OrderClaimComponent', 'upsertClaimSubCase', error, 'Fatal');
		}

		LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}

	/**************************************************************************************************************
	Method name:    updateParentCase
	Object:         Case
	RecordType:     Order Claim
	Date:           2/2018
	Details and Notes:
	Updates parent case and related fields
	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus updateParentCase(Id parentCaseId, String poNumber, String beamOrderNumber, Boolean isBailment, Boolean isGTR, Boolean isSingleBarrel, String country, String carrier, String state) {
		Boolean success = true;
		String message = null;
		Boolean updateCase = false;
		Map<String, Object> responseMap = new Map<String, Object>();
		List<Case> casesToUpdate = new List<Case>();

		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.AssignmentRuleHeader.useDefaultRule = true;

		Case parentCase = [select id
		                   , Purchase_Order_Number__c
		                   , Beam_Suntory_Order_Number__c
		                   , Is_Bailment_Claims__c
		                   , AccountId
		                   , Carrier__c
		                   , State__c
		                   , Product_Destination_Country__c
		                   , Is_GTR_Distributor__c
                           , Is_Single_Barrel_Claims__c from Case where Id = :parentCaseId limit 1][0];

		parentCase = checkUserForAccount(parentCase);

		if (poNumber != parentCase.Purchase_Order_Number__c) {
			parentCase.Purchase_Order_Number__c = poNumber;
		}
		if (beamOrderNumber != parentCase.Beam_Suntory_Order_Number__c) {
			parentCase.Beam_Suntory_Order_Number__c = beamOrderNumber;
		}
		if (state != parentCase.State__c) {
			parentCase.State__c = state;
		}
		if (country != parentCase.Product_Destination_Country__c) {
			parentCase.Product_Destination_Country__c = country;
			parentCase.setOptions(dmo);
		}
		if (isBailment != parentCase.Is_Bailment_Claims__c) {
			parentCase.Is_Bailment_Claims__c = isBailment;
			parentCase.setOptions(dmo);
		}
		if (isGTR != parentCase.Is_GTR_Distributor__c) {
			parentCase.Is_GTR_Distributor__c = isGTR;
			parentCase.setOptions(dmo);
		}
        if(isSingleBarrel != parentCase.Is_Single_Barrel_Claims__c){
            parentCase.Is_Single_Barrel_Claims__c = isSingleBarrel;
            parentCase.setOptions(dmo);
        }
		if (carrier != parentCase.Carrier__c) {
			parentCase.Carrier__c = carrier;
			parentCase.setOptions(dmo);
		}

		casesToUpdate.add(parentCase);


		for (Case c : checkForChildCases(parentCaseId)) {
			if (c.Purchase_Order_Number__c != parentCase.Purchase_Order_Number__c) {
				c.Purchase_Order_Number__c = parentCase.Purchase_Order_Number__c;
			}
			if (c.Beam_Suntory_Order_Number__c != parentCase.Beam_Suntory_Order_Number__c) {
				c.Beam_Suntory_Order_Number__c = parentCase.Beam_Suntory_Order_Number__c;
			}
			casesToUpdate.add(c);
		}

		try {

			update casesToUpdate;
			responseMap.put('parentCase', parentCase);

		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage();
			success = false;

			String error = e.getMessage() + '\n' + e.getStackTraceString();
			CreateExceptionLog.insertErrorLog('OrderClaimComponent', 'updateParentCase', error, 'Fatal');
		}

		LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}



	/**************************************************************************************************************
	Method name:    updateParentCase
	Object:         Case
	RecordType:     Order Claim
	Date:           2/2018
	Details and Notes:
	Removes a sub case
	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus removeClaimSubCase(Id caseId) {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();

		try {
			delete new Case(Id = caseId);
		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage();
			success = false;

			String error = e.getMessage() + '\n' + e.getStackTraceString();
			CreateExceptionLog.insertErrorLog('OrderClaimComponent', 'removeClaimSubCase', error, 'Fatal');
		}

		LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}

	/**************************************************************************************************************
	Method name:    getClaimsIdLabelMap
	Object:         Case
	RecordType:     Order Claim
	Date:           2/2018
	Details and Notes:
	Returns labels used in the order claim component
	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus getClaimsIdLabelMap() {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();

		try {
			Map<String, String> auraIdLabelMap = new Map<String, String> {
				'beam_suntory_item_number' 	 			=> System.Label.CS_Label_Beam_Item_Number,
				'beam_suntory_order_number'	 			=> System.Label.CS_Label_Beam_Suntory_Order_Number,
				'claim_amount' 				 			=> System.Label.Claim_Amount,
				'claim_description'			 			=> System.Label.CS_Label_Description,
				'distributor_currency'		 			=> System.Label.Distributor_Currency,
				'freight_claim_type'		 			=> System.Label.Freight_Claim_Type,
				'otc_storage_location'		 			=> System.Label.OTC_Storage_Location_Label,
				'product_description'		 			=> System.Label.Product_Description_Label,
				'product_size'				 			=> System.Label.Product_Size_Label,
				'purchase_order_number'		 			=> System.Label.Purchase_Order_Number_Label,
				'quantity'					 			=> System.Label.Quantity_Label,
				'quantity_type'				 			=> System.Label.Quantity_Type_Label,
				'seal_intact'				 			=> System.Label.Seal_Intact,
				'shipping_plant'			 			=> System.Label.Shipping_Plant_Label,
				'state_code'				 			=> System.Label.StateCode_Label,
				'type'						 			=> System.Label.Type,
				'yes'						 			=> System.Label.Yes,
				'no'						 			=> System.Label.No,
				'missing_value'				 			=> System.Label.Please_enter_a_value,
				'actions'					 			=> System.Label.Actions,
				'order_claim_instructions'   			=> System.Label.Order_Claim_Component_Instructions,
				'add_claim'					 			=> System.Label.Add_Claim,
				'error'						 			=> System.Label.Error,
				'claims_pending_submission'  			=> System.Label.Claims_Pending_Submission,
				'edit'						 			=> System.Label.Edit,
				'remove'					 			=> System.Label.Remove,
				'save_claim'				 			=> System.Label.Save_Claim,
				'product_destination_country' 			=> System.Label.Product_Destination_Country,
				'product_destination_country_parent' 	=> System.Label.Product_Destination_Country,
				'ship_date'								=> System.Label.Ship_Date,
				'nonePicklist'							=> System.Label.None_Picklist,
				'none'									=> System.Label.None,
				'additional_information'				=> System.Label.Additional_Information,
				'shortage_claim_description'     		=> System.Label.Shortage_Claim_Descrip,
				'overage_claim_description' 			=> System.Label.Overage_Claim_Descrip,
				'mis_shipment_claim_description' 		=> System.Label.Mis_Ship_Descrip,
				'damage_claim_description'   			=> System.Label.Damage_Claim_Descrip,
				'freight_claim_description' 			=> System.Label.Freight_Claim_Descrip,
				'carrier'								=> System.Label.Carrier,
				'state'									=> System.Label.State,
				'order_claim_information'				=> System.Label.Order_Claim_Information,
                'single_barrel_case_number'             => System.Label.Single_Barrel_Case_Number,
                'single_barrel_number'                  => System.Label.Single_Barrel_Number
                   
			};
			responseMap.put('labelMap', auraIdLabelMap);
		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage();
			success = false;

			String error = e.getMessage() + '\n' + e.getStackTraceString();
			CreateExceptionLog.insertErrorLog('OrderClaimComponent', 'getClaimsIdLabelMap', error, 'Fatal');
		}

		LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}

	/**************************************************************************************************************
	Method name:    getPicklistValues
	Object:         Case
	RecordType:     Order Claim
	Date:           2/2018
	Details and Notes:
	Returns picklist values used in the order claim component
	***************************************************************************************************************/
	@AuraEnabled
	public static Map<String, List<String>> getPicklistValues() {
		List<String> plants = getAllPlantCustomMetadata();
		//plants.add(CSConstants.UNKNOWN_PLANT);


		return new Map<String, List<String>> {
			'type' 									=> new List<String>{'Damage Claim', 'Overage Claim', 'Shortage Claim', 'Mis-Shipment Claim', 'Compliance Claim'} ,
			'freight_claim_type' 					=> getCasePicklistValues(CSConstants.FREIGHT_CLAIM_TYPE_APINAME),
			'product_size'			 				=> getCasePicklistValues(CSConstants.PRODUCT_SIZE_APINAME),
			'seal_intact' 							=> getCasePicklistValues(CSConstants.SEAL_INTACT_APINAME),
			'distributor_currency' 					=> getCasePicklistValues(CSConstants.DISTRIBUTOR_CURRENCY_APINAME),
			'shipping_plant'                        => plants,
			'otc_storage_location' 					=> getOTCStorageLocationCustomMetadata(),
			'product_destination_country' 			=> getCasePicklistValues(CSConstants.PRODUCT_DESTINATION_COUNTRY_APINAME),
			'product_destination_country_parent' 	=> getCasePicklistValues(CSConstants.PRODUCT_DESTINATION_COUNTRY_APINAME),
			'quantity_type' 						=> getCasePicklistValues(CSConstants.QUANTITY_TYPE_APINAME),
			'overage_disposition' 					=> getCasePicklistValues(CSConstants.OVERAGE_DISPOSITION_APINAME),
			'state'									=> getCasePicklistValues(CSConstants.STATE_APINAME)
		};
	}

	/**************************************************************************************************************
	Method name:    getRadioPicklistValues
	Object:         Case
	RecordType:     Order Claim
	Date:           2/2018
	Details and Notes:
	Returns picklist values used for radio buttons, radio buttons work differently in lightning components so they are
	handled here
	***************************************************************************************************************/
	@AuraEnabled
	public static Map<String, List<String>> getRadioPicklistValues() {
		return new Map<String, List<String>> {
			'quantity_type' => getCasePicklistValues(CSConstants.QUANTITY_TYPE_APINAME)
		};
	}

	public static List<String> getCasePicklistValues(String apiName) {
		List<String> returnedTypeList = new List<String>();
		List<String> optionLabels = new List<String>();
		Map<String, Schema.SObjectField> fieldMap = Case.getSObjectType().getDescribe().fields.getMap();
		List<Schema.PicklistEntry> picklistValues = fieldMap.get(apiName).getDescribe().getPickListValues();

		for (Schema.PicklistEntry ple : picklistValues) {
			optionLabels.add(ple.getLabel());
		}

		return optionLabels;
	}

	/**************************************************************************************************************
	Method name:    checkUserForAccount
	Object:         Case
	RecordType:     Order Claim
	Date:           2/2018
	Details and Notes:
	If there is not account attached to the case then a default one will be assigned
	***************************************************************************************************************/
	public static Case checkUserForAccount(Case parentCase) {
		List<Account> accts = [select id, name, RecordType.Name from Account where Name = 'Beam Suntory' AND RecordType.Name = 'Distributor' limit 1];

		// check if the user has a contact and an account tied to it
		User u = [select id, ContactId from User where Id = :Userinfo.getUserId()];
		if (u.ContactId == null && parentCase.AccountId == null) {
			// this user is an internal user
			// they dont have an account related to them
			if (!accts.isEmpty()) {
				parentCase.AccountId = accts[0].Id;
			}
		}

		return parentCase;
	}

	public static List<String> getAllPlantCustomMetadata() {
		List<String> plants = new List<String>();
		for (CS_Plant_Setting__mdt plantSetting : [Select id, Plant__c, isInternational__c from CS_Plant_Setting__mdt]) {
			plants.add(plantSetting.Plant__c);
		}
		plants.sort();
		return plants;
	}

	public static List<String> getOTCStorageLocationCustomMetadata() {
		List<String> otcCodes = new List<String>();
		for (OTC_Storage_Location__mdt otc : [Select MasterLabel from OTC_Storage_Location__mdt]) {
			otcCodes.add(otc.MasterLabel);
		}
		otcCodes.sort();
		return otcCodes;
	}

	public static List<Case> checkForChildCases(Id parentId) {
		return [select id
		        , Purchase_Order_Number__c
		        , Beam_Suntory_Order_Number__c
		        , Is_Bailment_Claims__c
		        , AccountId
		        , Carrier__c
		        , Product_Destination_Country__c
		        , Is_GTR_Distributor__c
                , Is_Single_Barrel_Claims__c from Case where ParentId = :parentId];
	}


}