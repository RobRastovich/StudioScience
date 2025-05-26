public without sharing class QC_FACTSFinderCtrl {

    public static final String CONSUMER = 'Consumer';
    public static final String RETAIL = 'Retail';
    public static final String DISTRIBUTOR = 'Distributor';
    public static final String BAILMENT = 'Bailment';

    @testVisible
    public static Boolean forceException = false;


    @AuraEnabled
    public static LightningComponentUtility.RequestStatus loadInitialData(Id recordId) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        LightningComponentUtility.RequestStatus requestStatus;

        try {

            if (Test.isRunningTest() && forceException) {
                DmlException e = new DmlException();
                e.setMessage('Error thrown for test class');
                throw e;
            }
            // get correct case
            Case caseRecord = getCaseRecord(recordId);
            List<Case> cases = getMatchingCases(caseRecord.Id);
            List<Incident__c> incidents = getCurrentIncidents();

            responseMap.put('caseRecord', caseRecord);
            responseMap.put('cases', cases);
            responseMap.put('incidents', incidents);

        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message += 'Error Message: ' + e.getMessage();
            message += ',\r';
            message += 'StackTrace: ' + e.getStackTraceString();
            success = false;

            Custom_Exception_Logs__c error = CreateExceptionLog.createExceptionLog('QC_FACTSFinderCtrl', 'loadInitialData', String.valueOf(message), 'Fatal', true);
            String endUserMessage = 'An Error Occurred, Please Contact Customer Service. Reference Id: ' + error.Id;

            requestStatus = new LightningComponentUtility.RequestStatus(success, endUserMessage, responseMap);
            return requestStatus;
        }
        requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }

    /**************************************************************************************************************
    Description:    Gets the case record (Quality Claim record type) of the currently opened record.  If the
                    currently opened record is a Quality Claim Subcase, the parent record (Quality Claim record type)
                    is returned instead.
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    2/2019      Connor Gallaher    Initial Creation

    ***************************************************************************************************************/
    @AuraEnabled
    public static Case getCaseRecord(Id recordId) {
        Case caseRecord = new Case();
        Case currentCase = getCaseById(recordId);


        if (currentCase.RecordTypeId == CSConstants.QC_SUBCASE_RT_ID) {
            caseRecord = getCaseById(currentCase.ParentId);
        } else {
            caseRecord = currentCase;
        }

        return caseRecord;
    }

    /**************************************************************************************************************
    Description:    Returns a list of cases that match on Lot Code, SKU (Beam Suntory Item Number) or Bottling Plant
                    of the currently opened case record.  Full Lot Code does not need to match - end of Lot Codes are
                    typically timestamped, so taking substrings is more effective.  Varies for Intl and NA.

    History
    <Date>      <Authors Name>     <Brief Description of Change>
    2/2019      Connor Gallaher    Initial Creation

    ***************************************************************************************************************/
    @AuraEnabled
    public static List<Case> getMatchingCases(Id recordId) {
        Id qualityRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Quality_Claim').getRecordTypeId();
        Case qualityCase = getCaseRecord(recordId);
        String qualityCaseLotCode = qualityCase.Lot_Code__c;
        //No Lot Code or blank Lot Code
        if (String.isBlank(qualityCaseLotCode)) {
            qualityCaseLotCode = '';
        }
        //Mainly applicable for international
        if (qualityCaseLotCode.length() > 0 && qualityCaseLotCode.length() < 8) {
            qualityCaseLotCode = qualityCaseLotCode.substring(0, qualityCaseLotCode.length());
        }
        //For US Plants
        if (qualityCaseLotCode.length() >= 8) {
            qualityCaseLotCode = qualityCaseLotCode.substring(0, 8);
        }
        qualityCaseLotCode += '%';

        List<Case> cases = getCasesByLotPlantItem(qualityCaseLotCode, qualityCase.Bottling_Plant__c, qualityCase.Beam_Suntory_Item_Number__c);

        List<Case> casesCopy = new List<Case>(cases);

        //Remove the case you are using to query against so that it's not displayed
        //as a related case in the table
        for (Case c : cases) {
            if (c.Id == qualityCase.Id) {
                casesCopy.remove(casesCopy.indexOf(c));
            }
        }
        return casesCopy;
    }

    /**************************************************************************************************************
    Description:    Returns all open FACTS Incidents.  Only will return Incidents that are the
                    top-level Incident (FACTS record type) and have a status of 'New' or 'Working'.
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    2/2019      Connor Gallaher    Initial Creation

    ***************************************************************************************************************/
    @AuraEnabled
    public static List<Incident__c> getCurrentIncidents() {
        Id factsRecordType = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get('FACTS').getRecordTypeId();
        return [SELECT Id
                , RecordTypeId
                , Name
                , Lot_Code_s__c
                , SKU__c
                , Bottling_Plant__c
                , Status__c FROM Incident__c WHERE Status__c != 'Closed' AND RecordTypeId = :factsRecordType];
    }

    /**************************************************************************************************************
    Description:    Adds the currently opened case record to the selected Incident.  Takes care of subincident
                    association.  If the selected FACTS Incident has an existing subincident created that matches
                    the case, it will be associated with that subincident of the parent FACTS Incident.  If not,
                    a new subincident will be created; the case will be associated with that new subincident and
                    the new subincident will lookup to the parent FACTS Incident.

    History
    <Date>      <Authors Name>     <Brief Description of Change>
    2/2019      Connor Gallaher    Initial Creation

    ***************************************************************************************************************/
    @AuraEnabled
    public static void addToIncident(Id currentCaseId, Id factsIncidentId) {
        Id consumerRecordType = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get(CONSUMER).getRecordTypeId();
        Id retailerRecordType = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get(RETAIL).getRecordTypeId();
        Id distributorRecordType = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get(DISTRIBUTOR).getRecordTypeId();
        List<Incident__c> subincidents = [SELECT Id, RecordTypeId, Parent_Incident__c, Account__c, Account_Name__c FROM Incident__c WHERE Parent_Incident__c = :factsIncidentId];

        Id defaultAccountId = getDefaultCSAccountId();
        Case c = getCaseRecord(currentCaseId);
        Boolean isConsumer = false;
        if (c.Complaint_Source__c == CONSUMER) {
            isConsumer = true;
        }

        //if its a consumer case
        if (isConsumer) {
            //consumer subincident already exists; find that subincident and set lookup on this case to that id
            for (Incident__c subincident : subincidents) {
                if (subincident.RecordTypeId == consumerRecordType) {
                    c.Incident__c = subincident.Id;
                }
            }
            //no existing consumer subincident found; create new subincident for consumer
            if (c.Incident__c == null) {
                Incident__c consumerIncident = new Incident__c();
                consumerIncident.RecordTypeId = consumerRecordType;
                consumerIncident.Parent_Incident__c = factsIncidentId;

                insert consumerIncident;

                c.Incident__c = consumerIncident.Id;
            }
        }
        //distributor, retailer, bailment
        else {
            //find subincident for that account
            for (Incident__c subincident : subincidents) {
                if (c.Complaint_Source__c == DISTRIBUTOR || c.Complaint_Source__c == BAILMENT) {
                    if (subincident.Account__c != null && subincident.Account__c == c.AccountId) {
                        c.Incident__c = subincident.Id;
                    } else if (!String.isBlank(subincident.Account_Name__c) && subincident.Account_Name__c == c.Location_Name__c) {
                        c.Incident__c = subincident.Id;
                    }
                } else if (c.Complaint_Source__c == RETAIL) {
                    if (subincident.Account__c != null && subincident.Account__c == c.AccountId) {
                        c.Incident__c = subincident.Id;
                    } else if (!String.isBlank(subincident.Account_Name__c) && subincident.Account_Name__c == c.Location_Name__c) {
                        c.Incident__c = subincident.Id;
                    }
                }
            }
            //no subincident for that account exists, so create one
            if (c.Incident__c == null) {
                if (c.Complaint_Source__c == DISTRIBUTOR || c.Complaint_Source__c == BAILMENT) {
                    Incident__c distributorIncident = new Incident__c();
                    distributorIncident.RecordTypeId = distributorRecordType;
                    if (c.AccountId != null && c.AccountId != defaultAccountId) {
                        distributorIncident.Account__c = c.AccountId;
                    } else if (!String.isBlank(c.Location_Name__c)) {
                        distributorIncident.Account_Name__c = c.Location_Name__c;
                    }
                    distributorIncident.Parent_Incident__c = factsIncidentId;

                    insert distributorIncident;

                    c.Incident__c = distributorIncident.Id;
                } else if (c.Complaint_Source__c == RETAIL) {
                    Incident__c retailerIncident = new Incident__c();
                    retailerIncident.RecordTypeId = retailerRecordType;
                    if (c.AccountId != null && c.AccountId != defaultAccountId) {
                        retailerIncident.Account__c = c.AccountId;
                    } else if (!String.isBlank(c.Location_Name__c)) {
                        retailerIncident.Account_Name__c = c.Location_Name__c;
                    }
                    retailerIncident.Parent_Incident__c = factsIncidentId;

                    insert retailerIncident;

                    c.Incident__c = retailerIncident.Id;
                }
            }
        }
        caseServices.runTrigger = false;
        update c;
    }

    /**************************************************************************************************************
    Description:    Returns a list of cases that match on various filters matching the filtered fields of
                    the currently opened case record.  These filters are selected by the user in the FACTS Finder
                    and the database is dynamically queried, with the list of cases returned when the user clicks the
                    "Apply Filters" button.

    History
    <Date>      <Authors Name>     <Brief Description of Change>
    2/2019      Connor Gallaher    Initial Creation

    ***************************************************************************************************************/
    @AuraEnabled
    public static List<Case> executeQuery(String queryString) {
        List<Case> cases = Database.query(queryString);
        return cases;
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

    public static Case getCaseById(Id caseId) {
        return [SELECT CaseNumber
                , Id
                , RecordTypeId
                , ParentId
                , CreatedDate
                , AccountId
                , Location_Name__c
                , Lot_Code__c
                , Bottling_Plant__c
                , Brand__c
                , Product_Size__c
                , Beam_Suntory_Item_Number__c
                , Type
                , Issue__c
                , Incident__c
                , Complaint_Source__c
                , Status
                FROM Case WHERE Id = :caseId LIMIT 1];
    }

    public static List<Case> getCasesByLotPlantItem(String lotCode, String bottlingPlant, String itemNumber) {
        return [SELECT Id
                , CaseNumber
                , RecordTypeId
                , CreatedDate
                , AccountId
                , Location_Name__c
                , Lot_Code__c
                , Bottling_Plant__c
                , Brand__c
                , Product_Size__c
                , Beam_Suntory_Item_Number__c
                , Type
                , Issue__c
                , Incident__c
                , Complaint_Source__c
                , Status FROM Case WHERE
                ((Lot_Code__c LIKE :lotCode AND Lot_Code__c != NULL)
                 OR (Bottling_Plant__c LIKE :bottlingPlant AND Bottling_Plant__c != NULL)
                 OR (Beam_Suntory_Item_Number__c = :itemNumber
                         AND Beam_Suntory_Item_Number__c != NULL))
                AND RecordTypeId = : CSConstants.QC_RT_ID
                                   AND Incident__c = NULL AND Status != 'Closed'];

    }
}