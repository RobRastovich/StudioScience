public without sharing class SBP_SelectionCmpCtrl {


	/**************************************************************************************************************
	Author:        Craig Austgen
	Company:       Slalom, LLC
	Description:	Pulls in the custom metadata for each brand to populate the data for the lightning flow in
					the customer community for the single barrel program
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	7/2018     	Craig Austgen       Initial Creation
	5/2021      Yash Jain           adding check for diplomats/Heritage Managers/Plant team members/State managers
									to submit account application for Makers Mark									 

	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus getSingleBarrelImages(String caseId, String userId, String acctId) {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();
		Map<String, SBP_SelectionCmpCtrl.Brand> brandMap = new Map<String, SBP_SelectionCmpCtrl.Brand>();
		Map<String, Boolean> brandIsActiveMap = new Map<String, Boolean>();

		Boolean allowSplitBarrel = isApartOfNationalAccountQueue(Id.valueOf(userId));
		Boolean hasRecipes = doesAccountHaveExistingRecipes(caseId);
		Boolean hasDateHolds = doesUserHaveDateHolds(userId);
		Set<String> brandsAdded = new Set<String>();
		String loggedInUserType = SBP_CaseSearchController.getUserType();

		List<Single_Barrel_Brand_Setting__mdt> singleBarrelBrandSettingMdtList = [select MasterLabel
			        , Plant__c
			        , Brand__c
			        , Flavor__c
			        , hasApplication__c
			        , Distiller_s_Choice__c
			        , Recent_Recipes__c
			        , Date_Hold__c
			        , Remote_Selection__c
			        , Sample_Kit__c
			        , Trip_and_Tour__c
			        , Split_Barrel__c
			        , Order__c
			        , Static_Resource_Name__c
			        , isActive__c from Single_Barrel_Brand_Setting__mdt where isActive__c = true order by Order__c asc];
		if(String.isNotBlank(loggedInUserType) && (loggedInUserType == 'Diplomat' || loggedInUserType == 'Heritage Manager' || loggedInUserType == 'Super Heritage Manager')){
					singleBarrelBrandSettingMdtList = [select MasterLabel
					, Plant__c
					, Brand__c
					, Flavor__c
					, hasApplication__c
					, Distiller_s_Choice__c
					, Recent_Recipes__c
					, Date_Hold__c
					, Remote_Selection__c
					, Sample_Kit__c
					, Trip_and_Tour__c
					, Split_Barrel__c
					, Order__c
					, Static_Resource_Name__c
					, isActive__c from Single_Barrel_Brand_Setting__mdt where isActive__c = true AND Brand__c = 'Makers Mark' order by Order__c asc];
		}

		try {

			for (Single_Barrel_Brand_Setting__mdt brandSetting : singleBarrelBrandSettingMdtList) {
				List<String> programTypes = new List<String>();
				if (brandSetting.Distiller_s_Choice__c) {
					programTypes.add('Distiller\'s Choice');
				}
				if (brandSetting.Recent_Recipes__c && hasRecipes) {
					programTypes.add('Recent Recipes');
				}
				if (brandSetting.Remote_Selection__c) {
					programTypes.add('Remote Selection');
				}
				if (brandSetting.Sample_Kit__c) {
					programTypes.add('Sample Kit');
				}
				if (brandSetting.Trip_and_Tour__c) {
					programTypes.add('Trip and Tour');
				}
				if (brandSetting.Split_Barrel__c && allowSplitBarrel) {
					programTypes.add('Split Barrel');
				}
				if (brandSetting.Date_Hold__c && hasDateHolds) {
					programTypes.add('Date Hold');
				}
				brandIsActiveMap.put(brandSetting.Brand__c, brandSetting.isActive__c);


				brandMap.put(brandSetting.MasterLabel, new Brand(programTypes, brandSetting.Static_Resource_Name__c, brandSetting.Brand__c, brandSetting.MasterLabel, brandSetting.Plant__c, brandSetting.hasApplication__c, brandSetting.Flavor__c));
			}

			responseMap.put('brandMap', brandMap);
			responseMap.put('brandIsActiveMap', brandIsActiveMap);

		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage();
			success = false;

		}

		LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}

	public class Brand {
		@AuraEnabled public List<String> programTypes;
		@AuraEnabled public String staticResourceName;
		@AuraEnabled public String brand;
		@AuraEnabled public String label;
		@AuraEnabled public String plant;
		@AuraEnabled public Boolean hasApplication;
		@AuraEnabled public String flavor;

		public Brand(List<String> programTypes, String staticResourceName, String brand, String label, String plant, Boolean hasApplication, String flavor) {
			this.programTypes = programTypes;
			this.staticResourceName = staticResourceName;
			this.brand = brand;
			this.label = label;
			this.plant = plant;
			this.hasApplication = hasApplication;
			this.flavor = flavor;
		}
	}

	/**************************************************************************************************************
	Author:        Craig Austgen
	Company:       Slalom, LLC
	Description:	If the user is apart of the national account queue then they will be able to see Split Barrels
					as an option in the customer community for the single barrel program
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	7/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static Boolean isApartOfNationalAccountQueue(Id userId) {
		Boolean isNationalAccount = false;
		Group nationalAccountGroup = [Select Id from Group where Name = 'National Accounts' limit 1];

		List<GroupMember> groupMembers = [Select UserOrGroupId From GroupMember where GroupId = :nationalAccountGroup.Id];

		for (GroupMember gMember : groupMembers) {
			if (gMember.UserOrGroupId == userId) {
				isNationalAccount = true;
				break;
			}
		}

		return isNationalAccount;
	}

	/**************************************************************************************************************
	Author:        Craig Austgen
	Company:       Slalom, LLC
	Description:	Checks to see if there are any existing recipes for this account and displays that option
					to them in the customer community for the single barrel program
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	7/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	public static Boolean doesAccountHaveExistingRecipes(String caseId) {
		Boolean hasRecipes = false;

		if (String.isNotBlank(caseId)) {
			Case c = [select id, Retail_Account__c, Retail_Account_Name__c, Account_Missing__c from Case where Id = :Id.valueOf(caseId) limit 1];
			AggregateResult agrResult = [SELECT COUNT(Barrel_Recipe__c) recipeCount FROM Barrel__c WHERE Case__r.Retail_Account__c =: c.Retail_Account__c AND Barrel_Recipe__c != null];
			if(Integer.valueOf(agrResult.get('recipeCount')) > 0) {
				hasRecipes = true;
			}
			if (c.Account_Missing__c) {
				List<Account_Barrel_Recipe__c> recipes = [select id, Account_Name__c from Account_Barrel_Recipe__c where Account_Name__c = :c.Retail_Account_Name__c];
				if (!recipes.isEmpty()) {
					hasRecipes = true;
				}
			} else {
				List<Account_Barrel_Recipe__c> recipes = [select id from Account_Barrel_Recipe__c where Account__c = : c.Retail_Account__c];
				if (!recipes.isEmpty()) {
					hasRecipes = true;
				}
			}
		}
		return hasRecipes;
	}

	/**************************************************************************************************************
	Author:        Craig Austgen
	Company:       Slalom, LLC
	Description:	Checks if there are date holds and displays that option to the end user in the customer community
					for the single barrel program
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	7/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	public static Boolean doesUserHaveDateHolds(String userId) {
		Boolean hasDateHolds = false;

		if (String.isNotBlank(userId)) {
			List<Time_Interval__c> dateHolds = [select id, Type__c, Submitter__c from Time_Interval__c where Type__c = 'Date Hold' and Submitter__c = : Id.valueOf(userId) ];
			if (!dateHolds.isEmpty()) {
				hasDateHolds = true;
			}
		}

		return hasDateHolds;
	}

	/**************************************************************************************************************
	Author:        Craig Austgen
	Company:       Slalom, LLC
	Description:
	Inputs:        accountId:
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	7/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus getCaseRecord(String caseId) {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();
		Map<String, Boolean> brandToIsActive = new Map<String, Boolean>();
		Map<String, RecordType> devNameToRecordType = new Map<String, RecordType>();



		try {
			if (String.isNotBlank(caseId)) {
				Case c = [select id, Brand__c, AccountId, Account.PremiseType__c, Retail_Account__c, Retail_Account__r.PremiseType__c from Case where Id = :Id.ValueOf(caseId) limit 1];
				responseMap.put('premiseType', c.Retail_Account__r.PremiseType__c);
				responseMap.put('brand', c.Brand__c);
			} else {
				responseMap.put('premiseType', null);
			}

		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage();
			success = false;
		}

		LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}

}