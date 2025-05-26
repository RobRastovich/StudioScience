public without sharing class LocalActionUtilityCtrl {
	/**************************************************************************************************************
	Author:        Craig Austgen
	Company:       Slalom, LLC
	Description:	Local action in visual flows to get the recordtype for the Single Barrel Program Objects
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	7/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus getRecordType(String brand, String sObjectName, String barrelType) {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();
		Map<String, Boolean> brandToIsActive = new Map<String, Boolean>();
		Map<String, RecordType> devNameToRecordType = new Map<String, RecordType>();
		Id recordTypeId;

		try {
			if (sObjectName == 'Case') {
				if (barrelType == 'Split') {
					recordTypeId = SBP_Constants.SINGLE_BARREL_SPLIT_BARREL_RT_ID;
				} else {
					recordTypeId = SBP_Constants.caseBrandsRTIdMap.get(brand);
				}

			} else if (sObjectName == 'Barrel') {
				if (barrelType == 'Full') {
					recordTypeId = SBP_Constants.fullBarrelBrandRTIdMap.get(brand);
				} else if (barrelType == 'Split') {
					recordTypeId = SBP_Constants.KNOB_CREEK_SPLIT_BARREL_RT_ID;
				} else if (barrelType == 'Sample Kit') {
					recordTypeId = SBP_Constants.sampleKitBrandRTIdMap.get(brand);
				}

			} else if (sObjectName == 'Plant Event') {
				recordTypeId = SBP_Constants.plantEventRtIdMap.get(brand);
			} else if (sObjectName == 'POS Customization') {
				if (barrelType == 'Full') {
					recordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID;
				} else if (barrelType == 'Split') {
					recordTypeId = SBP_Constants.POS_SPLIT_BARREL_RT_ID;
				}
			}

			responseMap.put('recordTypeId', recordTypeId);
		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage();
			success = false;
		}

		LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}

	/**************************************************************************************************************
	Author:        Craig Austgen
	Company:       Slalom, LLC
	Description:	Local action in visual flow to create a case and barrel group
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	7/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus createCaseAndBarrelGroup(String brand, String productType, String programType) {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();

		try {

			Database.DMLOptions dmo = new Database.DMLOptions();
			dmo.AssignmentRuleHeader.useDefaultRule = true;

			Barrel_Order_Group__c barrelGroup = new Barrel_Order_Group__c();
			barrelGroup.Type__c = programType;
			insert barrelGroup;

			Case c = new Case();
			c.Product_Type__c = productType;
			c.Origin = 'Customer Portal';
			c.RecordTypeId = SBP_Constants.caseBrandsRTIdMap.get(brand);
			c.Submitter__c = UserInfo.getUserId();
			c.Brand__c = brand;
			c.Type = programType;
			c.Barrel_Order_Group__c = barrelGroup.Id;

			Database.insert(c, dmo);


			responseMap.put('barrelGroupId', barrelGroup.Id);
			responseMap.put('caseId', c.Id);
			responseMap.put('caseRecordTypeId', c.RecordTypeId);

		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage();
			success = false;
		}

		LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}

	/**************************************************************************************************************
	Author:        Craig Austgen
	Company:       Slalom, LLC
	Description:	Local action in Single barrel visual flow to update a flag on all cases related to the barrel order group Id.
					This flag will indicate that the user completed the flow and did not end the flow early.  If the flow
					is not completed by the user then a time based workflow will close the case 3 hours after the case has been opened.
					This only applies to cases of the record type 'Single Barrel - Standard' and cases created from the
					community
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	10/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus updateCaseFlowCompleted(String barrelOrderGroupId) {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();
		List<Case> casesToUpdate = new List<Case>();

		try {

			for (Case c : [select id, Flow_Completed__c, Brand__c, RecordTypeId FROM Case 
                           WHERE (Barrel_Order_Group__c = :barrelOrderGroupId AND Barrel_Order_Group__c!= null)]) {
				if (c.RecordTypeId == SBP_Constants.SINGLE_BARREL_STANDARD_RT_ID || 
                    c.RecordTypeId == SBP_Constants.SINGLE_BARREL_PROOF_SPECIFIC_RT_ID || 
                    c.RecordTypeId == SBP_Constants.SINGLE_BARREL_SPLIT_BARREL_RT_ID) {
					c.Flow_Completed__c = true;
					casesToUpdate.add(c);
				}
			}

			if (!casesToUpdate.isEmpty()) {
				update casesToUpdate;
				CreateExceptionLog.insertErrorLog('LocalActionUtilityCtrl', 'updateCaseFlowCompleted', 'Case records related to Barrel Order Group have been completed: ' + barrelOrderGroupId , 'Info');
			} else {
				CreateExceptionLog.insertErrorLog('LocalActionUtilityCtrl', 'updateCaseFlowCompleted', 'No Case records related to Barrel Order Group have been found: ' + barrelOrderGroupId , 'Info');
			}

			responseMap.put('casesToUpdate', casesToUpdate);

		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage() + ' \n ';
			message = message + e.getStackTraceString();
			success = false;

			CreateExceptionLog.insertErrorLog('LocalActionUtilityCtrl', 'updateCaseFlowCompleted', 'An error occured while updating cases related to Barrel Order Group: ' + barrelOrderGroupId , 'Info');
			CreateExceptionLog.insertErrorLog('LocalActionUtilityCtrl', 'updateCaseFlowCompleted', 'Error: ' + message , 'Warning');

		}

		LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}
    
    /**************************************************************************************************************
	Description: Assign an account id to the record passed in
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	2/2019     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus assignAccountId(String recordId, String accountId, String accountApiName) {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();
        
        if(String.isBlank(recordId) || String.isBlank(accountId)){
            success = false;
            message = 'Missing Record Id or Account Id';
            responseMap.put('recordId' , recordId);
            responseMap.put('accountId' , accountId);
            return new LightningComponentUtility.RequestStatus(success, message, responseMap);
        }

		try {
			Id currentRecord = Id.valueOf(recordId);
			String currentObjectType = currentRecord.getSObjectType().getDescribe().getName();


			// Convert to schema.sObjectType
			Schema.SObjectType convertType = Schema.getGlobalDescribe().get(currentObjectType);

			// Create an instance of that type
			Sobject genericObject = convertType.newSObject();
			genericObject.put('Id', currentRecord);
			genericObject.put(accountApiName, Id.valueOf(accountId));
			update genericObject;


			responseMap.put('updatedRecord', genericObject);

		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage();
			success = false;
		}

		LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}
    /**************************************************************************************************************
	Description: Update Bonus Coupon once redeemed for Reatil & Wholesale MX Bonus Coupons Site
	Company:       TCS
	<Date>      <Authors Name>     <Brief Description of Change>
	2/2020     	Priyankar Saha       JIRA Story: SAL-228 (Force Sites Security Change to Impact MX Bonus Coupons Site)

	***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus updateBonusCoupon(Bonus_Coupon__c objBonusCoupon){
        Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();
        if(objBonusCoupon == null){
            success = false;
            message = 'Missing Bonus Coupon Record';
            responseMap.put('objBonusCoupon' , objBonusCoupon);
            return new LightningComponentUtility.RequestStatus(success, message, responseMap);
        }
        try{
            Database.update(objBonusCoupon);
            message = 'Bonus Coupon Redeemed Successfully';
        }
        catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage();
			success = false;
		}
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
    }
}