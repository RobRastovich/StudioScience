public without sharing class QC_FACTSIncidentCtrl {

	public static final String CONSUMER = 'Consumer';
    public static final String RETAIL = 'Retail';
    public static final String DISTRIBUTOR = 'Distributor';
    public static final String BAILMENT = 'Bailment';

	/**************************************************************************************************************
    Description:    Creates top-level FACTS Incident and all subincidents, if applicable (if FACTS case creation
    				is initiated from the FACTS Finder).  Associates all cases selected with proper subincidents.
    				Parent FACTS Incident is returned.

    History
    <Date>      <Authors Name>     <Brief Description of Change>
    2/2019      Connor Gallaher    Initial Creation

    ***************************************************************************************************************/
	@AuraEnabled
    public static Incident__c createIncident(String casesForIncident) {

		List<Case> cases = (List<Case>)System.JSON.deserialize(casesForIncident, List<Case>.Class);
		
		//for retailers and distributors with accountId populated
		Set<Id> acctIdsForDistInc = new Set<Id>();
		Set<Id> acctIdsForRetInc = new Set<Id>();
		
		//for consumer cases and retailers and distributors with no accountId populated
		List<Case> consumerCases = new List<Case>();
		List<Case> retailerCasesNoAcct = new List<Case>();
		List<Case> distributorCasesNoAcct = new List<Case>();

		List<Case> casesWithoutAcctInSF = new List<Case>();
		Id defaultAccountId = getDefaultCSAccountId();

		//to hold all subincidents (both distributors and consumer)
		List<Incident__c> allSubincidents = new List<Incident__c>();

		for (Case c : cases) {
			//for cases associated with account
			if ((c.AccountId != null && c.AccountId != defaultAccountId) && (c.Complaint_Source__c == DISTRIBUTOR || c.Complaint_Source__c == BAILMENT)) {
				acctIdsForDistInc.add(c.AccountId);
			}
			else if (c.AccountId != null && c.AccountId != defaultAccountId && c.Complaint_Source__c == RETAIL) {
				acctIdsForRetInc.add(c.AccountId);
			}
			else if (c.Complaint_Source__c == CONSUMER) {
				consumerCases.add(c);
			}
			else {
				if (c.Complaint_Source__c == RETAIL) {
					retailerCasesNoAcct.add(c);
				}
				else if (c.Complaint_Source__c == DISTRIBUTOR || c.Complaint_Source__c == BAILMENT) {
					distributorCasesNoAcct.add(c);
				}
			}
		}
		
		//to hold distrbutor incidents only
		List<Incident__c> distributorIncidents = new List<Incident__c>();
		List<Incident__c> retailerIncidents = new List<Incident__c>();

		Incident__c distributorInc;
		Id distributorRecordType = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get(DISTRIBUTOR).getRecordTypeId();
		//create incident record for each distributor; associate it with the correct account
		for (Id acctIdForDistInc : acctIdsForDistInc) {
			distributorInc = new Incident__c();
			distributorInc.RecordTypeId = distributorRecordType;
			distributorInc.Account__c = acctIdForDistInc;
			distributorIncidents.add(distributorInc);
		}

		Incident__c retailerInc;
		Id retailerRecordType = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get(RETAIL).getRecordTypeId();
		for (Id acctIdForRetInc : acctIdsForRetInc) {
			retailerInc = new Incident__c();
			retailerInc.RecordTypeId = retailerRecordType;
			retailerInc.Account__c = acctIdForRetInc;
			retailerIncidents.add(retailerInc);
		}


		//need to create incident for each UNIQUE Location_Name__c
		Map<String, Incident__c> distLocNameToInc = new Map<String, Incident__c>();
		for (Case c : distributorCasesNoAcct) {
			if (!distLocNameToInc.containsKey(c.Location_Name__c)) {
				distLocNameToInc.put(c.Location_Name__c, new Incident__c());
				distLocNameToInc.get(c.Location_Name__c).RecordTypeId = distributorRecordType;
				distLocNameToInc.get(c.Location_Name__c).Account_Name__c = c.Location_Name__c;
				distributorIncidents.add(distLocNameToInc.get(c.Location_Name__c));
			}
		}

		Map<String, Incident__c> retLocNameToInc = new Map<String, Incident__c>();
		for (Case c : retailerCasesNoAcct) {
			if (!retLocNameToInc.containsKey(c.Location_Name__c)) {
				retLocNameToInc.put(c.Location_Name__c, new Incident__c());
				retLocNameToInc.get(c.Location_Name__c).RecordTypeId = retailerRecordType;
				retLocNameToInc.get(c.Location_Name__c).Account_Name__c = c.Location_Name__c;
				retailerIncidents.add(retLocNameToInc.get(c.Location_Name__c));
			}
		}


		//add all distributor incidents to the subincidents list
		allSubincidents.addAll(distributorIncidents);
		allSubincidents.addAll(retailerIncidents);

		Incident__c consumerIncident;
		Id consumerRecordType = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get(CONSUMER).getRecordTypeId();
		
		//create consumer incident, if consumer cases will be included with this facts call
		if (!consumerCases.isEmpty()) {
			consumerIncident = new Incident__c();
			consumerIncident.RecordTypeId = consumerRecordType;
			allSubincidents.add(consumerIncident);
			//insert list here will only happen if there is a consumer incident that needs
			//to be included as part of this facts call
			insert allSubincidents;
		}
		else {
			//otherwise list will just be inserted with only distributor and retailer incidents included
			insert allSubincidents;
			System.debug('INCIDENTS> '+ allSubincidents);
		}

		//update lookups on all cases with a newly created matching incident, then update these
		//need to do for both retailers and distributors
		for (Case c : cases) {
			for (Incident__c inc : allSubincidents) {

				if (c.AccountId != null && c.AccountId == inc.Account__c) {
					if (c.Complaint_Source__c == RETAIL && inc.RecordTypeId == retailerRecordType) {
						c.Incident__c = inc.Id;
					}
					else if ((c.Complaint_Source__c == DISTRIBUTOR || c.Complaint_Source__c == BAILMENT) && inc.RecordTypeId == distributorRecordType) {
						c.Incident__c = inc.Id;
					}
				}
				else if ((c.AccountId == null || c.AccountId == defaultAccountId) && !String.isBlank(c.Location_Name__c)) {
					if (c.Complaint_Source__c == RETAIL && inc.RecordTypeId == retailerRecordType) {
						if (c.Location_Name__c == inc.Account_Name__c) {
							c.Incident__c = inc.Id;
						}
					}
					else if ((c.Complaint_Source__c == DISTRIBUTOR || c.Complaint_Source__c == BAILMENT) && inc.RecordTypeId == distributorRecordType) {
						if (c.Location_Name__c == inc.Account_Name__c) {
							c.Incident__c = inc.Id;
						}
					}
				}
			}
		}
		update cases;

		//then update consumer cases with lookup to newly created matching consumer incident, if needed
		if (!consumerCases.isEmpty()) {
			for (Case c : consumerCases) {
				c.Incident__c = consumerIncident.Id;
			}
			update consumerCases;
		}

		//create parent/top-level facts incident
    	Incident__c parentInc = new Incident__c();
    	parentInc.RecordTypeId = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get('FACTS').getRecordTypeId();

    	insert parentInc;

    	//populate all parent incident lookups for all subincidents (both distributors and consumer, if applicable)
    	for (Incident__c inc : allSubincidents) {
    		inc.Parent_Incident__c = parentInc.Id;
    	}
    	update allSubincidents;

    	return parentInc;
    }


	/**************************************************************************************************************
    Description:    If user closes out of the FACTS Flow modal and clicks confirm, this method is called.  It
    				deletes the in-progress FACTS Incident, all subincidents, and all cases uploaded from CSV, if
    				applicable.  These cases are created with Type = 'FACT', and this method only deletes cases
    				related to the indicated parent Incident with a Type of 'FACT'.  This ensures no other cases are
    				deleted from Salesforce.

    History
    <Date>      <Authors Name>     <Brief Description of Change>
    2/2019      Connor Gallaher    Initial Creation

    ***************************************************************************************************************/
    @AuraEnabled
    public static void destroyIncident(Id parentIncId) {
		Id qcRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Quality_Claim').getRecordTypeId();
		Id qcscRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Quality_Claim_Sub_Case').getRecordTypeId();

    	if (parentIncId != null) {
    		//want to delete parent/top-level facts incident
	    	Incident__c parentInc = [SELECT Id FROM Incident__c WHERE Id = :parentIncId LIMIT 1];
	    	//and all newly created subincidents with lookup to parent incident
	    	List<Incident__c> subIncs = [SELECT Id, Parent_Incident__c FROM Incident__c WHERE Parent_Incident__c = :parentIncId];
	    	//so, add parent incident to list of subincidents as all will need deletion
	    	subIncs.add(parentInc);

	    	//type 'FACT' will only be on cases created from csv - these are only new cases
	    	//do NOT want to delete cases already in salesforce
	    	List<Case> casesForIncident = [SELECT Id, Incident__c, Type, RecordTypeId FROM Case WHERE Incident__c IN :subIncs AND Type = 'FACT' AND RecordTypeId = :qcRT];
	    	List<Id> casesIds = new List<Id>();
	    	for (Case caseForIncident : casesForIncident) {
	    		casesIds.add(caseForIncident.Id);
	    	}
	    	List<Case> subcasesForIncident = [SELECT Id, ParentId, RecordTypeId FROM Case WHERE ParentId IN :casesIds AND RecordTypeId = :qcscRT];

	    	delete subcasesForIncident;

	    	delete casesForIncident;

	    	delete subIncs;
	    }
    }

    public static Id getDefaultCSAccountId() {
        List<Account> accts = [SELECT Id, RecordTypeId, Name
                               FROM Account
                               WHERE Name = :CSConstants.DEFAULT_ACCOUNT_NAME
                                            AND RecordTypeId = :CSConstants.DEFAULT_ACCOUNT_RT_ID LIMIT 1];
        if (!accts.isEmpty()) {
            return accts[0].Id;
        } else {
            return null;
        }
    }
}