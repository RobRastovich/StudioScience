public with sharing class QC_MasterSheetParser {

	public static final String CONSUMER = 'Consumer';
	public static final String RETAIL = 'Retail';
	public static final String DISTRIBUTOR = 'Distributor';
	public static final String BAILMENT = 'Bailment';

    /**************************************************************************************************************
    Description:    Creates case for each line of the CSV file uploaded during the FACTS Flow.
    				If the FACTS Incident has an existing subincident created that matches
                    the case, it will be associated with that subincident of the parent FACTS Incident.  If not,
                    a new subincident will be created; the case will be associated with that new subincident and
                    the new subincident will lookup to the parent FACTS Incident.

    History
    <Date>      <Authors Name>     <Brief Description of Change>
    2/2019      Connor Gallaher    Initial Creation

    ***************************************************************************************************************/
	@AuraEnabled
	public static void createRecords(Map<Integer, List<String>> objs, Integer indexOfShipDate, Integer indexOfOrderNumber, 
		Integer indexOfDeliveryNumber, Integer indexOfCustomer, Integer indexOfShipToCountry, 
		Integer indexOfState, Integer indexOfSku, Integer indexOfDescription, Integer indexOfLot, 
		Integer indexOfNumberCases, Id parentIncidentId) {
		
		//Only distributor/bailment accounts will be in these CSVs
		List<Incident__c> distributorIncidents = [SELECT Id, Account__c, Account_Name__c, Parent_Incident__c FROM Incident__c WHERE Parent_Incident__c = :parentIncidentId];
		Set<String> accountNames = new Set<String>();

		for (Integer i : objs.keySet()) { 
			if (!String.isEmpty(objs.get(i)[indexOfCustomer])) {
				accountNames.add(objs.get(i)[indexOfCustomer]);
			}
		}

		Map<String, Id> accountNameToId = getAccountsByName(accountNames);
		Case c;
		List<Case> cases = new List<Case>();
		String accountName;
		Decimal numCases;
        Id qualityRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Quality_Claim').getRecordTypeId();
		
		//Create a case for each line in the CSV
		for (Integer j : objs.keySet()) {
			if (!String.isEmpty(objs.get(j)[indexOfCustomer])) {
				c = new Case();
				accountName = objs.get(j)[indexOfCustomer];
				c.RecordTypeId = qualityRecordType;
				if (objs.get(j)[indexOfShipDate].toLowerCase().contains('ship date')) {
					c.Ship_Date__c = null;
				}
				else {
					c.Ship_Date__c = Date.parse(objs.get(j)[indexOfShipDate]);
				}
				//}
				c.Beam_Suntory_Order_Number__c = objs.get(j)[indexOfOrderNumber];
				c.Delivery_Number__c = objs.get(j)[indexOfDeliveryNumber];
				if (accountNameToId.get(accountName) != null) {
					c.AccountId = accountNameToId.get(accountName);
				}
				else {
					c.Location_Name__c = accountName;
				}
				c.Ship_To_Country__c = objs.get(j)[indexOfShipToCountry];
				c.State__c = objs.get(j)[indexOfState];
				c.Beam_Suntory_Item_Number__c = objs.get(j)[indexOfSku];
				c.Product_Description__c = objs.get(j)[indexOfDescription];
				c.Lot_Code__c = objs.get(j)[indexOfLot];
				if (objs.get(j)[indexOfNumberCases].toLowerCase().contains('cases')) {
					numCases = 0;
				}
				else {
					numCases = Decimal.valueOf(String.valueOf(objs.get(j)[indexOfNumberCases].trim()));
					c.Number_of_Cases__c = numCases;
				}

				c.Status = 'New';
				c.Type = 'FACT';
				cases.add(c);
			}
		}
		//Rip out first case, as it contains headers/labels
		cases.remove(0);

		caseServices.runTrigger = false;
		insert cases;

		List<Case> remainingCases = cases.clone();
		//find cases with an incident that matches, if one exists
		for (Case currentCase : cases) {
			for (Incident__c currentIncident : distributorIncidents) {
				if (currentCase.AccountId != null && currentIncident.Account__c != null 
						&& currentCase.AccountId == currentIncident.Account__c) {
					currentCase.Incident__c = currentIncident.Id;
					remainingCases.remove(remainingCases.indexOf(currentCase));
				}
				else if (!String.isBlank(currentCase.Location_Name__c) && !String.isBlank(currentIncident.Account_Name__c) 
						&& currentCase.Location_Name__c == currentIncident.Account_Name__c) {
					currentCase.Incident__c = currentIncident.Id;
					remainingCases.remove(remainingCases.indexOf(currentCase));
				}
			}
		}

		caseServices.runTrigger = false;
		update cases;

		Map<String, List<Case>> remainingCasesNeedingIncidents = new Map<String, List<Case>>();

		//Determine unique distributors that will need incidents created
		//Use AccountId when possible, if account is in Salesforce
		//Otherwise, Account is not in Salesforce, will need to use Location_Name__c
		for (Case remaining : remainingCases) {
			if (remaining.AccountId != null) {
				if (remainingCasesNeedingIncidents.containsKey(String.valueOf(remaining.AccountId))) {
					remainingCasesNeedingIncidents.get(String.valueOf(remaining.AccountId)).add(remaining);
				}
				else {
					remainingCasesNeedingIncidents.put(String.valueOf(remaining.AccountId), new List<Case>());
					remainingCasesNeedingIncidents.get(String.valueOf(remaining.AccountId)).add(remaining);
				}
			}
			else if (remaining.AccountId == null && !String.isBlank(remaining.Location_Name__c)) {
				if (remainingCasesNeedingIncidents.containsKey(remaining.Location_Name__c)) {
					remainingCasesNeedingIncidents.get(remaining.Location_Name__c).add(remaining);
				}
				else {
					remainingCasesNeedingIncidents.put(remaining.Location_Name__c, new List<Case>());
					remainingCasesNeedingIncidents.get(remaining.Location_Name__c).add(remaining);
				}
			}
		}

		Set<String> remainingAccounts = new Set<String>();
		
		for (String str : remainingCasesNeedingIncidents.keySet()) {
			remainingAccounts.add(str);
		}

		Map<String, Id> remainingAccountsForIncidents = getAccountsByName(remainingAccounts);
		Incident__c newIncident;
		Id distributorId = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get(DISTRIBUTOR).getRecordTypeId();
		List<Incident__c> newIncidents = new List<Incident__c>();
		List<Incident__c> incidentsWithAccountInSF = new List<Incident__c>();
		List<Incident__c> incidentsWithoutAccountInSF = new List<Incident__c>();

		for (String remainingAccountName : remainingCasesNeedingIncidents.keySet()) {
			newIncident = new Incident__c();
			newIncident.RecordTypeId = distributorId;
			newIncident.Parent_Incident__c = parentIncidentId;
			try {
				newIncident.Account__c = Id.valueOf(remainingAccountName);
				incidentsWithAccountInSF.add(newIncident);
			}
			catch (Exception e) {
				newIncident.Account_Name__c = remainingAccountName;
				incidentsWithoutAccountInSF.add(newIncident);
			}
		}
		newIncidents.addAll(incidentsWithAccountInSF);
		newIncidents.addAll(incidentsWithoutAccountInSF);

		insert newIncidents;

		//Create lookup for cases with Account in SF
		for (Incident__c newInc : incidentsWithAccountInSF) {
			for (Case remain : remainingCasesNeedingIncidents.get(String.valueOf(newInc.Account__c))) {
				remain.Incident__c = newInc.Id;
			}
		}

		//Create lookup for cases without Account in SF
		for (Incident__c newInc : incidentsWithoutAccountInSF) {
			for (Case remain : remainingCasesNeedingIncidents.get(newInc.Account_Name__c)) {
				remain.Incident__c = newInc.Id;
			}
		}

		List<Case> finalUpdatedCases = new List<Case>();
		for (String acctName : remainingCasesNeedingIncidents.keySet()) {
			finalUpdatedCases.addAll(remainingCasesNeedingIncidents.get(acctName));
		}

		caseServices.runTrigger = false;
		update finalUpdatedCases;
	}

	/**************************************************************************************************************
    Description:    Returns a map of accounts in Salesforce with their account name as the key and their
    				Salesforce Id as the value

    History
    <Date>      <Authors Name>     <Brief Description of Change>
    2/2019      Connor Gallaher    Initial Creation

    ***************************************************************************************************************/
	public static Map<String, Id> getAccountsByName(Set<String> accountNames) {
		Map<String, Id> accountNameToId = new Map<String, Id>();

		for (Account acc : [SELECT Name, Id FROM Account WHERE Name IN :accountNames]) {
			accountNameToId.put(acc.Name, acc.Id);
		}

		return accountNameToId;
	}

	/**************************************************************************************************************
    Description:    Initial parsing is done here, including determining indices of the various fields.  CSV is
    				passed in as a string, which is then split up and mapped, then passed to createRecords method
    				which creates a Case record for each line in the CSV file.

    History
    <Date>      <Authors Name>     <Brief Description of Change>
    2/2019      Connor Gallaher    Initial Creation

    ***************************************************************************************************************/
	@AuraEnabled
	public static Map<Integer, List<String>> parseFile(String s, String parentIncId) {
		
		Id parentIncidentId = Id.valueOf(parentIncId);
		//Split each line of CSV
		List<String> tokens = s.split('\n');
		Map<Integer, List<String>> objs = new Map<Integer, List<String>>();
		List<String> token;
		String tmp;

		//Then split each comma-separated value of each line
		for (Integer i = 0; i < tokens.size(); i++) {
			token = tokens.get(i).split(',');
			objs.put(i, token);
		}

		Integer indexOfShipDate, indexOfOrderNumber, indexOfDeliveryNumber, indexOfCustomer, indexOfShipToCountry, 
		indexOfState, indexOfSku, indexOfDescription, indexOfLot, indexOfNumberCases = -1;

		//Get indices of each field to be parsed in the CSV
		for (Integer j : objs.keySet()) {
			for (Integer k = 0; k < objs.get(j).size(); k++) {
				if (j == 0) {
					//refactor all to get proper headings
					if (objs.get(j)[k].toLowerCase().contains('ship date')) {
						indexOfShipDate = k;
					}
					if (objs.get(j)[k].toLowerCase().contains('order number')) {
						indexOfOrderNumber = k;
					}
					if (objs.get(j)[k].toLowerCase().contains('delivery number')) {
						indexOfDeliveryNumber = k;
					}
					if (objs.get(j)[k].toLowerCase().contains('customer')) {
						indexOfCustomer = k;
					}
					if (objs.get(j)[k].toLowerCase().contains('ship to country')) {
						indexOfShipToCountry = k;
					}
					if (objs.get(j)[k].toLowerCase().contains('state')) {
						indexOfState = k;
					}
					if (objs.get(j)[k].toLowerCase().contains('sku')) {
						indexOfSku = k;
					}
					if (objs.get(j)[k].toLowerCase().contains('description')) {
						indexOfDescription = k;
					}
					if (objs.get(j)[k].toLowerCase().contains('lot code')) {
						indexOfLot = k;
					}
					if (objs.get(j)[k].toLowerCase().contains('cases shipped')) {
						indexOfNumberCases = k;
					}
				}
			}
		}
		createRecords(objs, indexOfShipDate, indexOfOrderNumber, indexOfDeliveryNumber, indexOfCustomer, indexOfShipToCountry, 
			indexOfState, indexOfSku, indexOfDescription, indexOfLot, indexOfNumberCases, parentIncidentId);

		return objs;
	}
}