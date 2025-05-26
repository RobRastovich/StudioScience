public without sharing class SBP_AccountInfoCmpCtrl {

	/**************************************************************************************************************
	Author:        Craig Austgen
	Company:       Slalom, LLC
	Description:	Returns custom labels used in the lightning component SBP_AccountInfoCmp
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	7/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
    public static map<Integer, String> mapOfMonth = new Map<Integer, String> {1 => 'January', 2=> 'February', 3=> 'March', 4=> 'April', 
            5=> 'May', 6=> 'June', 7=> 'July', 8=> 'August', 9=> 'September', 10=> 'October', 11=> 'November' , 12=> 'December'};
    public static map<String, String> mapOfMonthQuarter = new Map<String, String>{'January' => 'Quarter 1', 'February' => 'Quarter 1', 'March' => 'Quarter 1',
            'April' => 'Quarter 2', 'May' => 'Quarter 2', 'June' => 'Quarter 2', 'July' => 'Quarter 3', 'August' => 'Quarter 3', 'September' => 'Quarter 3',
            'October' => 'Quarter 4', 'November' => 'Quarter 4', 'December' => 'Quarter 4'};
    public static String YEARLY = 'Yearly';
    public static String MONTHLY = 'Monthly';
    public static String QUARTERLY = 'Quarterly';
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus getSingleBarrelLabels() {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();

		try {
            Map<String, String> auraIdLabelMap = new Map<String, String> {
				'yes'							=> System.Label.Yes,
				'corresponding_collaborators'   => System.Label.Corresponding_Collaborators,
				'no'							=> System.Label.No,
				'missing_value'					=> System.Label.Please_enter_a_value,
				'actions'						=> System.Label.Actions,
				'error'							=> System.Label.Error,
				'edit'							=> System.Label.Edit,
				'remove'						=> System.Label.Remove,
				'nonePicklist'					=> System.Label.None_Picklist,
				'none'							=> System.Label.None,
				'state'							=> System.Label.State,
				'stateAbbreviation'				=> System.Label.State_Abbreviation,
				'account'						=> 'Account/TDLinx',
				'contact'						=> 'Distributor Contact',
				'account_details'				=> 'Account Information',
				'premise'						=> 'Premise',
				'region' 						=> 'Region',
				'market'						=> 'Market',
				'distributor'					=> 'Distributor',
				'attention'						=> 'Attention',
				'company'						=> 'Company',
				'address' 						=> 'Address Information',
				'street'						=> 'Street',
				'address2'						=> 'Address 2',
				'city'							=> 'City',
				'zip'							=> 'Zip Code',
				'phone'							=> 'Phone',
				'distributor_information' 		=> 'Distributor Shipping Information',
				'date_selection'				=> 'Date Information',
				'date'							=> 'Requested Date',
				'split'							=> 'Is this barrel being split by the Distributor across multiple store locations/accounts?',
				'nationalAccount'				=> 'Is this barrel for a National Account?',    
				'account_name'					=> 'Account Name'
            };
			responseMap.put('labelMap', auraIdLabelMap);
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
	Description:	Returns picklist values used in the lightning component SBP_AccountInfoCmp
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	7/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static Map<String, List<String>> getSingleBarrelPicklistValues() {

		return new Map<String, List<String>> {
			'premise' 	=> getAccountPicklistValues(SBP_Constants.PREMISE_APINAME),
			'states'    => getCasePicklistValues(SBP_Constants.STATE_APINAME)
		};
	}

	/**************************************************************************************************************
	Author:        Craig Austgen
	Company:       Slalom, LLC
	Description:	once a user completes the account info page in the Single Barrel Program flow the related case
					will be updated with the account info selected
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	7/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus updateCase(String jsonCases,boolean AvailableforSingleBarrel ) {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();
		System.debug(jsonCases);

		try {
			List<Case> caseList = (List<Case>)System.JSON.deserialize(jsonCases, List<Case>.Class);
			Case caseFromComponent = caseList[0];
            system.debug('<<<caseFromComponent' + caseFromComponent);

			Account acct = [select id from Account where Name = 'Single Barrel International Account'];
			
			Case existingCase = [select id, Retail_Account__c, Brand__c,Product_Type__c, Premise__c,Single_Barrel_State__c,Single_Barrel_Region__c,Single_Barrel_Country__c from Case where Id = :caseFromComponent.Id];
			system.debug('<<<existingCase' + existingCase);
			List<Barrel__c> barrels = [select id from Barrel__c where Case__c = :existingCase.Id];
			if (barrels.isEmpty()) {
				Barrel__c barrel = new Barrel__c();
				barrel.Brand__c = existingCase.Brand__c;
				barrel.Product_Type__c = existingCase.Product_Type__c;
				barrel.RecordTypeId = SBP_Constants.fullBarrelBrandRTIdMap.get(existingCase.Brand__c);
				barrel.Case__c = existingCase.Id;
                    insert barrel;
			}
            
			// update approval status
			if (caseFromComponent.Remote_Selection_Date__c != null) {
				caseFromComponent.Approval_Status__c = 'Pending Approval';
			}

			// if there is not retail account
			if (caseFromComponent.Retail_Account__c == null) {
				if (existingCase.Retail_Account__c == null) {
					caseFromComponent.Account_Missing__c = true;
					caseFromComponent.Retail_Account__c = acct.Id;
				} else {
					caseFromComponent.Retail_Account__c = existingCase.Retail_Account__c;
				}
			} else if (existingCase.Retail_Account__c != null) {
				caseFromComponent.Retail_Account__c = existingCase.Retail_Account__c;
			}

			if (existingCase.Premise__c != '') {
				caseFromComponent.Premise__c = existingCase.Premise__c;
			}
            caseValidWrapper wrapperClass = checkAllocationValidation(caseFromComponent);
            System.debug('wrapperClass--'+wrapperClass);
            if(wrapperClass != null) {
                if(!String.isEmpty(wrapperClass.newCase.Single_Barrel_State__c))
                    caseFromComponent.Single_Barrel_State__c = wrapperClass.newCase.Single_Barrel_State__c;
                if(!String.isEmpty(wrapperClass.newCase.Single_Barrel_Region__c))
                    caseFromComponent.Single_Barrel_Region__c = wrapperClass.newCase.Single_Barrel_Region__c;
                if(!String.isEmpty(wrapperClass.newCase.Single_Barrel_Country__c))
                    caseFromComponent.Single_Barrel_Country__c = wrapperClass.newCase.Single_Barrel_Country__c;
                caseFromComponent.Allocation_Allocated_From__c = wrapperClass.newCase.Allocation_Allocated_From__c;
                caseFromComponent.State_Allocation_From__c = wrapperClass.newCase.State_Allocation_From__c;
                caseFromComponent.Region_Allocation_From__c = wrapperClass.newCase.Region_Allocation_From__c;
                caseFromComponent.Brand_Allocation__c = wrapperClass.newCase.Brand_Allocation__c;
                caseFromComponent.Distributor_Allocation_From__c = wrapperClass.newCase.Distributor_Allocation_From__c;
                if(!wrapperClass.isValid){
                    message = Label.SB2_Allocation_is_not_available_for_this_barrel_order_Please_contact_your_state;
                    success = false;
                    caseFromComponent.status = 'Cancelled-Allocation';
                } 
                if(!AvailableforSingleBarrel) {
                    caseFromComponent.status = 'Canceled';
                }
            }
            System.debug('caseFromComponent--'+caseFromComponent);
            update caseFromComponent;
			responseMap.put('cases', caseFromComponent);
		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage()+e.getStackTraceString());
			message = e.getMessage();
			message = message + jsonCases;
			success = false;

		}

		LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}


	public static List<String> getAccountPicklistValues(String apiName) {
		List<String> returnedTypeList = new List<String>();
		List<String> optionLabels = new List<String>();
		Map<String, Schema.SObjectField> fieldMap = Account.getSObjectType().getDescribe().fields.getMap();
		List<Schema.PicklistEntry> picklistValues = fieldMap.get(apiName).getDescribe().getPickListValues();

		for (Schema.PicklistEntry ple : picklistValues) {
			optionLabels.add(ple.getLabel());
		}

		return optionLabels;
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
    
    public static CaseValidWrapper checkAllocationValidation(Case newCase){
        Boolean isValid = true;
        List<Case> lstCase = SLT_Case.getCaseByIDs(new List<Id> {newCase.Id});
        List<Account> lstRetailorAccount;
        if(!String.isEmpty(newCase.Retail_Account__c)) {
            lstRetailorAccount = SLT_Account.getAccountsByIDs(new Set<Id> {newCase.Retail_Account__c});
        }else if(!lstCase.isEmpty() && !String.isEmpty(lstCase[0].Retail_Account__c)){
            lstRetailorAccount = SLT_Account.getAccountsByIDs(new Set<Id> {lstCase[0].Retail_Account__c});
        }
        List<Account> lstDistributorAccount = SLT_Account.getAccountsByIDs(new Set<Id> {newCase.AccountId});
        Case existingCase;
        CaseValidWrapper newCaseWrapper;
        if(!lstCase.isEmpty()){
            existingCase = lstCase[0];
        }

        List<Brand_Country_Region_State_Dist_Alloc__c> lstDistributorAlloc = new List<Brand_Country_Region_State_Dist_Alloc__c>();
        String selectedBrandAllocation;

        selectedBrandAllocation = getSelectedBrandAllocation(existingCase);
        if(!String.isEmpty(selectedBrandAllocation)){
            selectedBrandAllocation = selectedBrandAllocation.substring(0,15);
            isValid = true;
        }       	
        existingCase.Brand_Allocation__c = selectedBrandAllocation;
        System.debug('--'+lstDistributorAccount.isEMpty());
        if(newCase.National_Account_Flag__c && lstDistributorAccount[0].Military__c != 'Military' && lstDistributorAccount[0].Military__c != 'Military Export') {
            if(!lstRetailorAccount.isEmpty()){
                newCaseWrapper = checkForNationalAccount(lstRetailorAccount[0], selectedBrandAllocation, existingCase);
            }
        }else if(!lstDistributorAccount.isEmpty() ){
            if( lstDistributorAccount[0].Military__c == 'Military' || 
               lstDistributorAccount[0].Military__c == 'Military Export'){
                   newCaseWrapper = checkForMilitary(lstDistributorAccount[0], selectedBrandAllocation, existingCase);
                   
               } else{
                   lstDistributorAlloc = SLT_SB2_BrandCountryRegionStateDistAlloc.getDistAllocByAccountAndBrandAlloc(selectedBrandAllocation, newCase.AccountId);
                   if(!lstDistributorAlloc.isEmpty()){
                       newCaseWrapper = checkForDistAllocIsAvailable(lstDistributorAlloc, existingCase, selectedBrandAllocation);
                   }
                   else{
                       if(!lstDistributorAccount.isEmpty()){
                           List<Brand_Country_Region_State_Allocation__c> lstStateAlloc = SLT_SB2_BrandCountryRegionStateAlloc.getStateAllocationByBrandAllocationAndState(
                               lstDistributorAccount[0].BillingState.toUpperCase(), selectedBrandAllocation, lstDistributorAccount[0].BillingCountry);
                           if(!lstStateAlloc.isEmpty()) {
                               newCaseWrapper = checkForStateAllocIsAvailable(lstStateAlloc, existingCase, selectedBrandAllocation);
                           } else{
                               newCaseWrapper = checkForRegionAllocIsAvailable(lstDistributorAccount[0], selectedBrandAllocation, existingCase);
                           }
                       }
                   }
               }
        }
        else{
            
        }
        return newCaseWrapper;
    }
    
    public static CaseValidWrapper checkForRegionAllocIsAvailable(Account distributorAccount, 
        String selectedBrandAllocation, case existingCase){
        List<State__c> lstState = SLT_SB2_State.getStateInfoFromAccount(distributorAccount.BillingState.toUpperCase());
        Boolean isvalid = true;
        if(!lstState.isEmpty()){
        	List<Brand_Country_Region_Allocation__c> lstRegionAlloc = 
                SLT_SB2_BrandCountryRegionAlloc.getRegionAllocationByCountryAndRegionAndBrand(lstState[0].Region__r.Name,
             	distributorAccount.BillingCountry, selectedBrandAllocation);
            for(Brand_Country_Region_Allocation__c regionAlloc : lstRegionAlloc){
           		if(regionAlloc.Is_Leaf_Node__c && regionAlloc.Allocations_Per_Interval__c == regionAlloc.Used_Allocations__c){
                	isValid = false;
                } else if(regionAlloc.Is_Leaf_Node__c && regionAlloc.Allocations_Per_Interval__c != regionAlloc.Used_Allocations__c){
                    existingCase.Allocation_Allocated_From__c = 'Region';
                    isValid = true;
                }
                existingCase.Brand_Allocation__c = selectedBrandAllocation;
                existingCase.Single_Barrel_Region__c = regionAlloc.Region__r.Name;
                existingCase.Single_Barrel_Country__c = regionAlloc.Brand_Country_Allocation__r.Country__r.Name;
                existingCase.Region_Allocation_From__c = regionAlloc.Id;
            }
        }
        return new CaseValidWrapper(existingCase, isValid);
    }
    
    public static CaseValidWrapper checkForStateAllocIsAvailable(
        List<Brand_Country_Region_State_Allocation__c> lstStateAlloc, Case existingCase, String selectedBrandAllocation){
        Boolean isValid = true;
        for(Brand_Country_Region_State_Allocation__c stateAlloc : lstStateAlloc){
            if(stateAlloc.Is_Active__c && stateAlloc.Is_Leaf_Node__c && 
            	(stateAlloc.Allocations_Per_Interval__c == stateAlloc.Used_Allocations__c || 
                stateAlloc.Allocations_Per_Interval__c == 0)){
                isValid = false;
                } else if(stateAlloc.Is_Active__c && stateAlloc.Is_Leaf_Node__c && 
            		(stateAlloc.Allocations_Per_Interval__c != stateAlloc.Used_Allocations__c ||
                	stateAlloc.Allocations_Per_Interval__c != 0)){
                    existingCase.Allocation_Allocated_From__c = 'State';
                    isValid = true;
                } else if(stateAlloc.Is_Active__c && !stateAlloc.Is_Leaf_Node__c && stateAlloc.Brand_Country_Region_Allocation__r.Is_Leaf_Node__c &&
                	(stateAlloc.Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c == stateAlloc.Brand_Country_Region_Allocation__r.Used_Allocations__c
                	|| stateAlloc.Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c == 0)){
                	isValid = false;
                } else if(stateAlloc.Is_Active__c && !stateAlloc.Is_Leaf_Node__c && stateAlloc.Brand_Country_Region_Allocation__r.Is_Leaf_Node__c &&
                	stateAlloc.Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c != stateAlloc.Brand_Country_Region_Allocation__r.Used_Allocations__c
                	&& stateAlloc.Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c != 0){
                    existingCase.Allocation_Allocated_From__c = 'Region';
                    isValid = true;
                }
            existingCase.Brand_Allocation__c = selectedBrandAllocation;
            existingCase.Single_Barrel_State__c = stateAlloc.State__r.Name;
            existingCase.Single_Barrel_Region__c = stateAlloc.Brand_Country_Region_Allocation__r.Region__r.Name;
            existingCase.Single_Barrel_Country__c = stateAlloc.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Country__r.Name;
            existingCase.Region_Allocation_From__c = stateAlloc.Brand_Country_Region_Allocation__r.Id;
            existingCase.State_Allocation_From__c = stateAlloc.Id;
        }
        return new CaseValidWrapper(existingCase, isValid);
    }
    
    public static CaseValidWrapper checkForDistAllocIsAvailable(
        List<Brand_Country_Region_State_Dist_Alloc__c> lstDistributorAlloc, Case existingCase, String selectedBrandAllocation){
        Boolean isValid = true;
        if(!lstDistributorAlloc.isEmpty()){
            for(Brand_Country_Region_State_Dist_Alloc__c distAlloc : lstDistributorAlloc){
                if(distAlloc.Is_Active__c && distAlloc.Is_Leaf_Node__c && (distAlloc.Allocations_Per_Interval__c == 0 || 
                   distAlloc.Allocations_Per_Interval__c == distAlloc.Used_Allocations__c)) {
                       isValid = false;
                   } else if(distAlloc.Is_Active__c && distAlloc.Is_Leaf_Node__c && distAlloc.Allocations_Per_Interval__c != 0 && 
                   distAlloc.Allocations_Per_Interval__c != distAlloc.Used_Allocations__c){
                       existingCase.Allocation_Allocated_From__c = 'Distributor';
                   }
                 if(distAlloc.Is_Active__c && !distAlloc.Is_Leaf_Node__c && 
                        distAlloc.Brand_Country_Region_State_Allocation__r.Is_Active__c && distAlloc.Brand_Country_Region_State_Allocation__r.Is_Leaf_Node__c 
                        && (distAlloc.Brand_Country_Region_State_Allocation__r.Allocations_Per_Interval__c == distAlloc.Brand_Country_Region_State_Allocation__r.Used_Allocations__c ||
                   		distAlloc.Brand_Country_Region_State_Allocation__r.Allocations_Per_Interval__c == 0)) {
                            isValid = false;
                        } else if(distAlloc.Is_Active__c && !distAlloc.Is_Leaf_Node__c && distAlloc.Brand_Country_Region_State_Allocation__r.Allocations_Per_Interval__c != 0 &&
                        distAlloc.Brand_Country_Region_State_Allocation__r.Is_Active__c && distAlloc.Brand_Country_Region_State_Allocation__r.Is_Leaf_Node__c 
                        && distAlloc.Brand_Country_Region_State_Allocation__r.Allocations_Per_Interval__c != distAlloc.Brand_Country_Region_State_Allocation__r.Used_Allocations__c){
                            existingCase.Allocation_Allocated_From__c = 'State';
                        }
                if(distAlloc.Is_Active__c && !distAlloc.Is_Leaf_Node__c && distAlloc.Brand_Country_Region_State_Allocation__r.Is_Active__c
                   		&& !distAlloc.Brand_Country_Region_State_Allocation__r.Is_Leaf_Node__c && 
                        distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Is_Leaf_Node__c 
                        && distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c == 
                        distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Used_Allocations__c) {
                        	isValid = false;
                        } else if(distAlloc.Is_Active__c && !distAlloc.Is_Leaf_Node__c && distAlloc.Brand_Country_Region_State_Allocation__r.Is_Active__c
                   		&& !distAlloc.Brand_Country_Region_State_Allocation__r.Is_Leaf_Node__c && 
                        distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Is_Leaf_Node__c 
                        && distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c != 
                        distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Used_Allocations__c && 
                                 distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c != 0){
                            existingCase.Allocation_Allocated_From__c = 'Region';
                        }
                existingCase.Brand_Allocation__c = selectedBrandAllocation;
                existingCase.Single_Barrel_State__c = distAlloc.Brand_Country_Region_State_Allocation__r.State__r.Name;
                existingCase.Single_Barrel_Region__c = distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Region__r.Name;
                existingCase.Single_Barrel_Country__c = distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Country__r.Name;
                existingCase.State_Allocation_From__c = distAlloc.Brand_Country_Region_State_Allocation__r.Id;
                existingCase.Region_Allocation_From__c = distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Id;
                existingCase.Distributor_Allocation_From__c = distAlloc.Id;
            }
        }
        return new CaseValidWrapper(existingCase, isValid);
    }
    
    public static CaseValidWrapper checkForMilitary(Account distributorAccount, String selectedBrandAllocation, Case existingCase){
        List<Brand_Country_Region_State_Allocation__c> lstStateAlloc = SLT_SB2_BrandCountryRegionStateAlloc.getStateAllocationWithRegion(
            'USA Military','Military', selectedBrandAllocation);
        Boolean isValid = true;
        if(!lstStateAlloc.isEmpty()){
            for(Brand_Country_Region_State_Allocation__c stateAlloc : lstStateAlloc){
                if(stateAlloc.Is_Leaf_Node__c && stateAlloc.Is_Active__c && 
                   stateAlloc.Allocations_Per_Interval__c == stateAlloc.Used_Allocations__c){
                       isValid = false;
                   }
                existingCase.Allocation_Allocated_From__c = 'State';
                existingCase.Brand_Allocation__c = selectedBrandAllocation;
                existingCase.Single_Barrel_State__c = stateAlloc.State__r.Name;
                existingCase.Single_Barrel_Region__c = stateAlloc.Brand_Country_Region_Allocation__r.Region__r.Name;
                existingCase.Single_Barrel_Country__c = stateAlloc.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Country__r.Name;
                existingCase.State_Allocation_From__c = stateAlloc.Id;
                existingCase.Region_Allocation_From__c = stateAlloc.Brand_Country_Region_Allocation__r.Id;
            }
        }
        return new CaseValidWrapper(existingCase, isValid);
    }
    
    public static CaseValidWrapper checkForNationalAccount(Account retailorAccount, String selectedBrandAllocation, 
        Case existingCase){
        List<Brand_Country_Region_State_Allocation__c> lstStateAlloc = 
            SLT_SB2_BrandCountryRegionStateAlloc.getStateAllocationWithRegion(retailorAccount.PremiseType__c, 
            'National Accounts', selectedBrandAllocation);
        System.debug(retailorAccount.PremiseType__c+'--'+selectedBrandAllocation+'--'+retailorAccount.BillingCountry);
        System.debug('lstStateAlloc--'+lstStateAlloc);
        Boolean isValid = true;
        if(!lstStateAlloc.isEmpty()){
            for(Brand_Country_Region_State_Allocation__c stateAlloc : lstStateAlloc){
                if(stateAlloc.Is_Leaf_Node__c && stateAlloc.Is_Active__c && 
                   stateAlloc.Allocations_Per_Interval__c == stateAlloc.Used_Allocations__c){
                       isValid = false;
                   }
                existingCase.Allocation_Allocated_From__c = 'State';
                existingCase.Brand_Allocation__c = selectedBrandAllocation;
                System.debug('stateAlloc.State__r.Name--'+stateAlloc.State__r.Name);
                existingCase.Single_Barrel_State__c = stateAlloc.State__r.Name;
                SYstem.debug('--'+stateAlloc.Brand_Country_Region_Allocation__r.Region__r.Name);
                existingCase.Single_Barrel_Region__c = stateAlloc.Brand_Country_Region_Allocation__r.Region__r.Name;
                System.debug('-'+stateAlloc.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Country__r.Name);
                existingCase.Single_Barrel_Country__c = stateAlloc.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Country__r.Name;
                System.debug('--'+stateAlloc.Id);
                existingCase.State_Allocation_From__c = stateAlloc.Id;
                System.debug('--'+stateAlloc.Brand_Country_Region_Allocation__r.Id);
                existingCase.Region_Allocation_From__c = stateAlloc.Brand_Country_Region_Allocation__r.Id;
                System.debug('existingCase---'+existingCase);
            }
        }
        CaseValidWrapper newCaseWrapper = new CaseValidWrapper(existingCase, isValid);
        return newCaseWrapper;
    }
    
    public static String getSelectedBrandAllocation(Case existingCase){
        String brandName = existingCase.Brand__c;
        if(!String.isEmpty(existingCase.Product_Type__c)){
            brandName += ' '+ existingCase.Product_Type__c;
        }
        String yearOfCaseCreation = String.valueOf(existingCase.CreatedDate.year());
        String monthOfCaseCreation = mapOfMonth.get(existingCase.CreatedDate.month());
        String qarterOfCaseCreation = mapOfMonthQuarter.get(monthOfCaseCreation);
        if(existingCase.Plant_Event__c != null){
            List<Plant_Event__c > lstPlantEvent = [select Id, Scheduled_Date__c  from Plant_Event__c  where Id =: existingCase.Plant_Event__c];
            yearOfCaseCreation = String.valueOf(lstPlantEvent[0].Scheduled_Date__c.year());
            monthOfCaseCreation = mapOfMonth.get(lstPlantEvent[0].Scheduled_Date__c.month());
            qarterOfCaseCreation = mapOfMonthQuarter.get(monthOfCaseCreation);
        }
        String selectedBrandAllocation;
        System.debug('brandName--'+brandName);
        List<Brand_Allocation__c> lstBrandAllocation = SLT_SB2_BrandAllocation.getBrandAllocation(brandName, existingCase.Type, yearOfCaseCreation);
                if(!lstBrandAllocation.isEmpty()){
            for(Brand_Allocation__c brandAlloc : lstBrandAllocation){
                if(brandAlloc.Is_Active__c && brandAlloc.Time_Period__c == YEARLY){
                    selectedBrandAllocation = brandAlloc.Id;
                } else if(brandAlloc.Is_Active__c && brandAlloc.Time_Period__c == QUARTERLY && 
                          brandAlloc.Time_Interval__c == qarterOfCaseCreation) {
                    selectedBrandAllocation = brandAlloc.Id;
                } else if(brandAlloc.Is_Active__c && brandAlloc.Time_Period__c == MONTHLY && 
                          brandAlloc.Time_Interval__c == monthOfCaseCreation){
                    selectedBrandAllocation = brandAlloc.Id;
                 }
        	}
    	}
    	return selectedBrandAllocation;
    }
    public class CaseValidWrapper{
        public Case newCase;
        public Boolean isValid;
        
        public CaseValidWrapper(Case newCase, Boolean isValid){
            this.newCase = newCase;
            this.isValid = isValid;
        }
    }
    
	@AuraEnabled
	public static String getProductType(String caseId) {
		return [SELECT Product_Type__c FROM case where Id =: caseId Limit 1].Product_Type__c;
		
	}
    
    //Added By Nishant Khandal for LSB-20 specific for Laphroaig Single Cask
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getDetailsOfCaseAccountLSC(String caseId) {
        Boolean success = true;
		String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        Case recordCase = new Case();
        Contact recordContact = new Contact();
        try{
            recordCase = SLT_Case.getCaseAccountDetailsByID(caseId);
            responseMap.put('rAccount', new Account(Id = recordCase.Retail_Account__c, Name = recordCase.Retail_Account__r.Name,
                                                    PremiseType__c = recordCase.Retail_Account__r.PremiseType__c,
                                                    BillingCity = recordCase.Retail_Account__r.BillingCity,
                                                    BillingState =  recordCase.Retail_Account__r.BillingState,
                                                    BillingPostalCode = recordCase.Retail_Account__r.BillingPostalCode,
                                                    Phone = recordCase.Retail_Account__r.Phone,
                                                    BillingStreet = recordCase.Retail_Account__r.BillingStreet));
            responseMap.put('dAccount', new Account(Id = recordCase.AccountId, Name = recordCase.Account.Name, 
                                                    Attention__c = recordCase.Account.Attention__c,
                                                    TDL_Match_Code__c = recordCase.Account.TDL_Match_Code__c, 
                                                    PremiseType__c = recordCase.Account.PremiseType__c,
                                                    BillingCity = recordCase.Account.BillingCity, BillingState =  
                                                    recordCase.Account.BillingState,
                                                    BillingPostalCode = recordCase.Account.BillingPostalCode, 
                                                    Phone = recordCase.Account.Phone, 
                                                    BillingStreet = recordCase.Account.BillingStreet));
            recordContact = SLT_Contact.getContactByID(String.valueOf(recordCase.ContactId));
            responseMap.put('dContact', recordContact);
            responseMap.put('nationalAccount', recordCase.National_Account_Flag__c);
            responseMap.put('timeIntervalSlot', recordCase.Plant_Event__r.Time_Interval__r.Date_Range_Label__c);
        }catch(Exception e){
            message = e.getMessage();
			success = false;
        }
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, 
                                                                                                            message, 
                                                                                                            responseMap);
        return requestStatus;		
    }
}