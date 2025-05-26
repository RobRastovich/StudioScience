public class QC_AdditionalFlaggedCases {

    public static final String CONSUMER = 'Consumer';
    public static final String RETAIL = 'Retail';
    public static final String DISTRIBUTOR = 'Distributor';
    public static final String BAILMENT = 'Bailment';

    /**************************************************************************************************************
    Description:    Returns a list of cases that match on Lot Code(s), based on the Lot Code(s) input during the
                    FACTS Flow input screen.  This is to assist with identifying any cases that already exist
                    in Salesforce that users may want to pull into this FACTS Case.

    History
    <Date>      <Authors Name>     <Brief Description of Change>
    2/2019      Connor Gallaher    Initial Creation

    ***************************************************************************************************************/
    @AuraEnabled
    public static List<Case> getAdditionalCases(Id parentIncidentId) {
        Incident__c parentIncident = [SELECT Id, Lot_Code_s__c FROM Incident__c WHERE Id = :parentIncidentId];
        List<String> lotCodes = parentIncident.Lot_Code_s__c.split(';');
        List<String> adjLotCodes = new List<String>();

        Id qualitySubcaseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Quality_Claim_Sub_Case').getRecordTypeId();

        for (String lotCode : lotCodes) {
            if (lotCode.length() < 8) {
                lotCode = lotCode.substring(0, lotCode.length());
            }
            else {
                lotCode = lotCode.substring(0, 8);
            }
        	adjLotCodes.add(lotCode);
        }

        Boolean first = true;
        //Initial query string
        String queryStr = 'SELECT CaseNumber, Id, RecordTypeId, Lot_Code__c, AccountId, Location_Name__c, Incident__c, CreatedDate, Complaint_Source__c, Type, Status FROM Case';
       
        //Build query, adding in each Lot Code
        for (String adjLotCode : adjLotCodes) {
            if (!first) {
                queryStr = queryStr + ' OR';
            } 
            else {
                queryStr = queryStr + ' WHERE (';
            }
            queryStr = queryStr + ' Lot_Code__c LIKE \'' + adjLotCode + '%\'';
            first = false;
        }
        queryStr += ' ) AND Type != ';
        queryStr += '\'' + String.escapeSingleQuotes('FACT') + '\'';
        queryStr += ' AND Incident__c = null';
        queryStr += ' AND Status != ';
        queryStr += '\'' + String.escapeSingleQuotes('Closed') + '\'';
        queryStr += ' AND RecordTypeId != ';
        queryStr += '\'' + String.escapeSingleQuotes(qualitySubcaseRecordType) + '\'';

        List<Case> potentialCases = Database.query(queryStr);

        return potentialCases;
    }

    /**************************************************************************************************************
    Description:    For each case selected, adds each case to the FACTS Incident. Takes care of subincident
                    association.  If the FACTS Incident has an existing subincident created that matches
                    the case, it will be associated with that subincident of the parent FACTS Incident.  If not,
                    a new subincident will be created; the case will be associated with that new subincident and
                    the new subincident will lookup to the parent FACTS Incident.

    History
    <Date>      <Authors Name>     <Brief Description of Change>
    2/2019      Connor Gallaher    Initial Creation

    ***************************************************************************************************************/
    @AuraEnabled
    public static void insertCases(Id parentIncidentId, List<Case> casesToAdd) {
    	List<Incident__c> subincidents = [SELECT Id, RecordTypeId, Account__c, Account_Name__c, Parent_Incident__c FROM Incident__c WHERE Parent_Incident__c = :parentIncidentId];

    	Id distributorId = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get(DISTRIBUTOR).getRecordTypeId();
        Id retailerId = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get(RETAIL).getRecordTypeId();
        Id consumerId = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get(CONSUMER).getRecordTypeId();

    	Boolean consumerIncidentCreated = false;
        Boolean consumerIncidentNeeded = false;
        //Look for existing consumer subincident
        for (Incident__c subInc : subincidents) {
            if (subInc.RecordTypeId == consumerId) {
                consumerIncidentCreated = true;
            }
        }

        //Determine if a new consumer subincident needs to be created
        for (Case c : casesToAdd) {
            if (c.Complaint_Source__c == CONSUMER && !consumerIncidentCreated) {
                consumerIncidentNeeded = true;
            }
        }

        Incident__c consumerInc;
        //Create new consumer subincident, if needed
        if (consumerIncidentNeeded) {
            consumerInc = new Incident__c();
            consumerInc.RecordTypeId = consumerId;
            consumerInc.Parent_Incident__c = parentIncidentId;
            insert consumerInc;
            subincidents.add(consumerInc);
        }

        Incident__c potentialNewInc;
        List<Incident__c> newIncidents = new List<Incident__c>();
        Map<String, Incident__c> uniqueRetailerIncidents = new Map<String, Incident__c>();
        Map<String, Incident__c> uniqueDistributorIncidents = new Map<String, Incident__c>();

        for (Case c : casesToAdd) {
            //Iterate through existing subincidents, see if one matches current case
            //If there's a match, create lookup
    		for (Incident__c subInc : subincidents) {
                if (c.Complaint_Source__c == CONSUMER && subInc.RecordTypeId == consumerId) {
                    c.Incident__c = subInc.Id;
                }
                else if (c.AccountId != null && c.AccountId == subInc.Account__c) {
                    if (c.Complaint_Source__c == RETAIL &&  subInc.RecordTypeId == retailerId) {
                        c.Incident__c = subInc.Id;
                    }
                    else if ((c.Complaint_Source__c == BAILMENT || c.Complaint_Source__c == DISTRIBUTOR) && subInc.RecordTypeId == distributorId) {
                        c.Incident__c = subInc.Id;
                    }
                }
                else if (!String.isBlank(c.Location_Name__c) && c.Location_Name__c == subInc.Account_Name__c) {
                    if (c.Complaint_Source__c == RETAIL &&  subInc.RecordTypeId == retailerId) {
                        c.Incident__c = subInc.Id;
                    }
                    else if ((c.Complaint_Source__c == BAILMENT || c.Complaint_Source__c == DISTRIBUTOR) && subInc.RecordTypeId == distributorId) {
                        c.Incident__c = subInc.Id;
                    }
                }
    		}
            //if case is not already associated with a previous incident, need to resolve to new incident
    		if (c.Incident__c == null) {
                if (c.Complaint_Source__c == RETAIL) {
                    if (c.AccountId != null) {
                        if (!uniqueRetailerIncidents.containsKey(String.valueOf(c.AccountId))) {
                            potentialNewInc = new Incident__c();
                            potentialNewInc.RecordTypeId = retailerId;
                            potentialNewInc.Parent_Incident__c = parentIncidentId;
                            potentialNewInc.Account__c = c.AccountId;
                            uniqueRetailerIncidents.put(String.valueOf(c.AccountId), potentialNewInc);
                        }
                    }
                    else if (!String.isBlank(c.Location_Name__c)) {
                        if (!uniqueRetailerIncidents.containsKey(c.Location_Name__c)) {
                            potentialNewInc = new Incident__c();
                            potentialNewInc.RecordTypeId = retailerId;
                            potentialNewInc.Parent_Incident__c = parentIncidentId;
                            potentialNewInc.Account_Name__c = c.Location_Name__c;
                            uniqueRetailerIncidents.put(c.Location_Name__c, potentialNewInc);
                        }
                    }
                }
                else if (c.Complaint_Source__c == BAILMENT || c.Complaint_Source__c == DISTRIBUTOR) {
                    if (c.AccountId != null) {
                        if (!uniqueDistributorIncidents.containsKey(String.valueOf(c.AccountId))) {
                            potentialNewInc = new Incident__c();
                            potentialNewInc.RecordTypeId = distributorId;
                            potentialNewInc.Parent_Incident__c = parentIncidentId;
                            potentialNewInc.Account__c = c.AccountId;
                            uniqueDistributorIncidents.put(String.valueOf(c.AccountId), potentialNewInc);
                        }
                    }
                    else if (!String.isBlank(c.Location_Name__c)) {
                        if (!uniqueDistributorIncidents.containsKey(c.Location_Name__c)) {
                            potentialNewInc = new Incident__c();
                            potentialNewInc.RecordTypeId = distributorId;
                            potentialNewInc.Parent_Incident__c = parentIncidentId;
                            potentialNewInc.Account_Name__c = c.Location_Name__c;
                            uniqueDistributorIncidents.put(c.Location_Name__c, potentialNewInc);
                        }
                    }
                }
    		}
    	}
        //Add each incident to list - distributors/bailment, retail, consumer
        for (Incident__c newInc : uniqueRetailerIncidents.values()) {
            newIncidents.add(newInc);
        }
        for (Incident__c newInc : uniqueDistributorIncidents.values()) {
            newIncidents.add(newInc);
        }
        if (!newIncidents.isEmpty()) {
            insert newIncidents;
        }

        //Create lookup to new incidents
        for (Case c : casesToAdd) {
            for (Incident__c i : newIncidents) {
                if (c.Complaint_Source__c == RETAIL && i.RecordTypeId == retailerId) {
                    if (c.AccountId != null & c.AccountId == i.Account__c) {
                        c.Incident__c = i.Id;
                    }
                    else if (!String.isBlank(c.Location_Name__c) && c.Location_Name__c == i.Account_Name__c) {
                        c.Incident__c = i.Id;
                    }
                }
                else if ((c.Complaint_Source__c == BAILMENT || c.Complaint_Source__c == DISTRIBUTOR) && i.RecordTypeId == distributorId) {
                    if (c.AccountId != null & c.AccountId == i.Account__c) {
                        c.Incident__c = i.Id;
                    }
                    else if (!String.isBlank(c.Location_Name__c) && c.Location_Name__c == i.Account_Name__c) {
                        c.Incident__c = i.Id;
                    }
                }
            }
        }
    	caseServices.runTrigger = false;
    	update casesToAdd;
    }
}